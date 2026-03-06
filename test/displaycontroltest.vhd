library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity displayControl is
    port (
        clk : in std_logic;
        reset : in std_logic;

        hello, enable, go, won : in std_logic; -- input signals from the CUs
        winner : in std_logic_vector(1 downto 0); -- winner signal from the assistant CU
        false_start : in std_logic_vector(3 downto 0); -- vector from the PIPO register

        d1, d2, d3, d4 : out std_logic_vector(6 downto 0) -- outputs to the 7-segment displays
    );
end displayControl;

architecture behavioral of displayControl is

    type state_type is (IDLE, HELLO_STATE, WAITING, FALSE_STARTS, WINNERS);
    signal state : state_type := IDLE;

begin

    process(clk, reset)
    begin

        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then

            case state is

                when IDLE => 
                    d1 <= "1111001"; -- I
                    d2 <= "1000000"; -- D
                    d3 <= "1000111"; -- L
                    d4 <= "0000110"; -- E

                    if hello = '1' then
                        state <= HELLO_STATE;
                    end if;

                -- device turned on, game not started
                when HELLO_STATE =>
                    d1 <= "0001011"; -- "h"
                    d2 <= "0000100"; -- "e"
                    d3 <= "1001001"; -- "ll"
                    d4 <= "0100011"; -- "o"

                    -- when start = 1, hello is turned to 0
                    if hello = '0' then
                        state <= WAITING;
                    end if;

                -- game started, waiting for players
                when WAITING => 
                    d1 <= "0111110"; -- "-"
                    d2 <= "0111110"; -- "-"
                    d3 <= "0111110"; -- "-"
                    d4 <= "0111110"; -- "-"

                    if enable = '1' then
                        state <= FALSE_STARTS;
                    end if;
                    
                -- traffic lights on, displaying false starts
                when FALSE_STARTS =>
                    if false_start(0) = '1' then
                        d1 <= "0001110"; -- F
                    else d1 <= "0111111"; -- "-"
                    end if;
                    if false_start(1) = '1' then
                        d2 <= "0001110"; -- F
                    else d2 <= "0111111"; -- "-"
                    end if;
                    if false_start(2) = '1' then
                        d3 <= "0001110"; -- F
                    else d3 <= "0111111"; -- "-"
                    end if;
                    if false_start(3) = '1' then
                        d4 <= "0001110"; -- F
                    else d4 <= "0111111"; -- "-"
                    end if;
                    if go = '1' then
                        state <= WINNERS;
                    end if;

                when WINNERS =>
                    if won = '1' then
                        case winner is
                            when "00" =>
                                d1 <= "1111001"; -- 1

                            when "01" =>
                                d2 <= "0100100"; -- 2

                            when "10" =>
                                d3 <= "0110000"; -- 3
                            
                            when "11" =>
                                d4 <= "0011001"; -- 4
                            
                            when others =>
                                d1 <= "1111111"; -- all segments off
                                d2 <= "1111111"; -- all segments off
                                d3 <= "1111111"; -- all segments off
                                d4 <= "1111111"; -- all segments off
                        end case;
                    else
                        state <= FALSE_STARTS;
                    end if;

                    -- when restarting the game, go back to idle (and hello)
                    if hello = '1' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
                
            end case;
        end if;
    end process;

end behavioral;
