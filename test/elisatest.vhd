library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elisaCU is
    port (
        clk : in std_logic;
        reset : in std_logic;

        enable, go : in std_logic; -- input signals from the other CU
        P1, P2, P3, P4 : in std_logic; -- button inputs
        false_start : in std_logic_vector(3 downto 0); -- vector from the PIPO register
        
        won, ts : out std_logic; -- output signals to the other CU
        winner : out std_logic_vector(1 downto 0); -- winner signal to the other CU
        fs1, fs2, fs3, fs4 : out std_logic; -- parallel set signals to the PIPO register
        resetFS : out std_logic; -- reset signal to the PIPO register

        led : out std_logic_vector(15 downto 0) -- led outputs
    );
end elisaCU;

architecture behavioral of elisaCU is

    type state_type is (IDLE, CHECK_FS, CHECK_W);
    signal state : state_type := IDLE;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            won <= '0';
            ts <= '0';
            winner <= "00"; -- can be any value, because it's not displayed
            fs1 <= '0';
            fs2 <= '0';
            fs3 <= '0';
            fs4 <= '0';
            resetFS <= '1';  -- reset the PIPO register
            led <= (others => '0'); -- turn off all LEDs
        
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    resetFS <= '1';
                    fs1 <= '0';
                    fs2 <= '0';
                    fs3 <= '0';
                    fs4 <= '0';
                    ts <= '0';
                    won <= '0';
                    if enable = '1' then
                        state <= CHECK_FS;
                    end if;
                    led <= "1100000000000000";

                when CHECK_FS =>
                    resetFS <= '0';
                    if go = '1' then
                        state <= CHECK_W;
                    elsif false_start = "1111" then
                        ts <= '1';
                        state <= IDLE;
                    else
                        if P1 = '0' then
                            fs1 <= '1';
                        end if;
                        if P2 = '0' then
                            fs2 <= '1';
                        end if;
                        if P3 = '0' then
                            fs3 <= '1';
                        end if;
                        if P4 = '0' then
                            fs4 <= '1';
                        end if;
                    end if;
                    led <= "0000001100000000";

                when CHECK_W =>
                    if (P1 = '0' and false_start(0) = '0') then
                        won <= '1';
                        winner <= "00";
                        state <= IDLE;
                    elsif (P2 = '0' and false_start(1) = '0') then
                        won <= '1';
                        winner <= "01";
                        state <= IDLE;
                    elsif (P3 = '0' and false_start(2) = '0') then
                        won <= '1';
                        winner <= "10";
                        state <= IDLE;
                    elsif (P4 = '0' and false_start(3) = '0') then
                        won <= '1';
                        winner <= "11";
                        state <= IDLE;
                    end if;
                    led <= "0000000000000011";

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end behavioral;