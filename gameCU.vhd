library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gameCU is
    port (
        clk : in std_logic;
        reset : in std_logic;

        P1, P2, P3, P4 : in std_logic; -- button inputs
        start : in std_logic; -- switch input
        led : out std_logic_vector(15 downto 0); -- led outputs

        endT : in std_logic; -- timer end signal
        enableT, resetT : out std_logic; -- timer control signals

        endB : in std_logic; -- blink signal for festive LEDs
        enableB, resetB : out std_logic; -- blink control signals

        won, fs : in std_logic; -- input signals from the other CU
        hello, enable, go : out std_logic -- output signals to the other CU
    );
end gameCU;

architecture behavioral of gameCU is

    type state_type is (IDLE, START_STATE, ZERO, A, B, C, D, GO_STATE, FS_STATE, ENDING);
    signal state : state_type := IDLE;

    signal buttonAnd : std_logic; -- signal that is high when all 4 buttons are pressed
    signal blink : std_logic := '0'; -- signal to switch between festive LED patterns

begin

    buttonAnd <= P1 and P2 and P3 and P4;

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            led <= (others => '0');
            enableT <= '0';
            resetT <= '1';
            enable <= '0';
            go <= '0';
            hello <= '0';

        elsif rising_edge(clk) then
            case state is

                -- game is on but not started, waiting for start signal
                when IDLE =>
                    led <= "0000000000000000";
                    hello <= '1';
                    enableT <= '0';
                    resetT <= '1';
                    enable <= '0';
                    go <= '0';
                    if start = '1' then
                        state <= START_STATE;
                        led <= "1000000000000001";
                        hello <= '0';
                    end if;
                
                -- game started, waiting for players to press their buttons
                when START_STATE =>

                    -- lighting up the leds corresponding to the players that pressed their buttons
                    if P1 = '1' then
                        led(9) <= '1';
                    else
                        led(9) <= '0';
                    end if;
                    if P2 = '1' then
                        led(8) <= '1';
                    else
                        led(8) <= '0';
                    end if;
                    if P3 = '1' then
                        led(7) <= '1';
                    else 
                        led(7) <= '0';
                    end if;
                    if P4 = '1' then
                        led(6) <= '1';
                    else
                        led(6) <= '0';
                    end if;

                    -- waiting for all players to press their buttons to start the game
                    if buttonAnd = '1' then
                        enableT <= '1';
                        enable <= '1';
                        state <= ZERO;
                    end if;

                    -- if game is stopped, go back to idle
                    if start = '0' then
                        state <= IDLE;
                    end if;
                
                -- sequence of traffic light states
                when ZERO =>
                    enable <= '0';
                    resetT <= '0';
                    led <= "0000000000000000";
                    if endT = '1' then
                        state <= A;
                        resetT <= '1';
                    elsif fs = '1' then
                        state <= FS_STATE;
                        resetT <= '1';
                    end if;

                when A =>
                    resetT <= '0';
                    led <= "1111000000000000";
                    if endT = '1' then
                        state <= B;
                        resetT <= '1';
                    elsif fs = '1' then
                        state <= FS_STATE;
                        resetT <= '1';
                    end if;

                when B =>
                    resetT <= '0';
                    led <= "1111111100000000";
                    if endT = '1' then
                        state <= C;
                        resetT <= '1';
                    elsif fs = '1' then
                        state <= FS_STATE;
                        resetT <= '1';
                    end if;
                
                when C =>
                    resetT <= '0';
                    led <= "1111111111110000";
                    if endT = '1' then
                        state <= D;
                        resetT <= '1';
                    elsif fs = '1' then
                        state <= FS_STATE;
                        resetT <= '1';
                    end if;

                when D =>
                    resetT <= '0';
                    led <= "1111111111111111";
                    if endT = '1' then
                        resetT <= '1';
                        if fs = '1' then
                            state <= FS_STATE;
                            resetT <= '1';
                        else
                            state <= GO_STATE;
                            resetT <= '1';
                        end if;
                    end if;
                -- sequence end
                
                when GO_STATE =>
                    led <= "0000000000000000";
                    enableT <= '0';
                    go <= '1';
                    if won = '1' then
                        state <= ENDING;
                    elsif fs = '1' then
                        state <= FS_STATE;
                    end if;

                when FS_STATE =>
                    led <= "00000000000000";
                    go <= '0';
                    if start = '0' then
                        state <= IDLE;
                    end if;

                when ENDING =>
                    go <= '0';
                    if start = '0' then
                        state <= IDLE;
                    end if;

                    -- festive LEDs
                    enableB <= '1';
                    resetB <= '0';

                    if blink = '0' then
                        led <= "1010101010101010";
                    else
                        led <= "0101010101010101";
                    end if;

                    if endB = '1' then
                        blink <= not blink;
                        resetB <= '1';
                    end if;
                
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end behavioral;