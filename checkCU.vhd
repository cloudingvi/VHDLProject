library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity checkCU is
    port (
        clk : in std_logic;
        reset : in std_logic;

        start : in std_logic; -- input from switches
        enable, go : in std_logic; -- input signals from the other CU
        P1, P2, P3, P4 : in std_logic; -- button inputs
        false_start : in std_logic_vector(3 downto 0); -- vector from the PIPO register
        
        won, fs : out std_logic; -- output signals to the other CU
        winner : out std_logic_vector(1 downto 0); -- winner signal to the other CU
        fs1, fs2, fs3, fs4 : out std_logic; -- parallel set signals to the PIPO register
        resetFS : out std_logic -- reset signal to the PIPO register
    );
end checkCU;

architecture behavioral of checkCU is

    type state_type is (IDLE, CHECK_FS, CHECK_W, ENDING);
    signal state : state_type := IDLE;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            won <= '0';
            fs <= '0';
            winner <= "00"; -- can be any value, because it's not displayed
            fs1 <= '0';
            fs2 <= '0';
            fs3 <= '0';
            fs4 <= '0';
            resetFS <= '1';
        
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    resetFS <= '1';
                    fs1 <= '0';
                    fs2 <= '0';
                    fs3 <= '0';
                    fs4 <= '0';
                    fs <= '0';
                    won <= '0';
                    if enable = '1' then
                        state <= CHECK_FS;
                    end if;

                when CHECK_FS =>
                    resetFS <= '0';
                    if false_start = "1111" then
                        fs <= '1';
                        state <= ENDING;
                    elsif go = '1' then
                        state <= CHECK_W;
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

                when CHECK_W =>
                    if (P1 = '0' and false_start(0) = '0') then
                        won <= '1';
                        winner <= "00";
                        state <= ENDING;
                    elsif (P2 = '0' and false_start(1) = '0') then
                        won <= '1';
                        winner <= "01";
                        state <= ENDING;
                    elsif (P3 = '0' and false_start(2) = '0') then
                        won <= '1';
                        winner <= "10";
                        state <= ENDING;
                    elsif (P4 = '0' and false_start(3) = '0') then
                        won <= '1';
                        winner <= "11";
                        state <= ENDING;
                    end if;

                when ENDING =>
                    if start = '0' then
                        state <= IDLE;
                    end if;
            
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end behavioral;