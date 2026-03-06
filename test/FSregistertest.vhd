library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSregister is
    port (
        clock : in std_logic;
        reset : in std_logic;

        fs1, fs2, fs3, fs4 : in std_logic; -- set signals for the false start of each player
        resetFS : in std_logic; -- signal to initialize the register

        false_start : out std_logic_vector(3 downto 0) -- output vector of false start signals
    );
end FSregister;

architecture behavioral of FSregister is
    signal reg : std_logic_vector(3 downto 0); -- internal register to store the false start signals
    begin

    process (clock, reset)
    begin
        -- asynchronous global reset
        if reset = '1' then
            reg <= ( others => '0' ); -- initialize the register to 0
        elsif rising_edge(clock) then

            -- synchronous local reset
            if resetFS = '1' then
                reg <= ( others => '0' ); -- reset the register to 0
            else

                -- if no reset, set values
                if fs1 = '1' then
                    reg(0) <= '1'; -- set the first bit if player 1 false starts
                end if;
                if fs2 = '1' then
                    reg(1) <= '1'; -- set the second bit if player 2 false starts
                end if;
                if fs3 = '1' then
                    reg(2) <= '1'; -- set the third bit if player 3 false starts
                end if;
                if fs4 = '1' then
                    reg(3) <= '1'; -- set the fourth bit if player 4 false starts
                end if;
            end if;
        end if;
    end process;

    false_start <= reg; -- output the current state of the register

end behavioral;