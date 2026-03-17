library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenSegment is
    port (
        clock : in std_logic;
        reset : in std_logic;

        d1, d2, d3, d4 : in std_logic_vector(6 downto 0); -- inputs from the display control

        CA     : out std_logic_vector(6 downto 0); -- cathodes
        AN     : out std_logic_vector(3 downto 0) -- anodes
    );
end sevenSegment;

architecture behavioral of sevenSegment is

    signal flick_counter : unsigned(17 downto 0); -- counter to switch between display
    signal cathodes : std_logic_vector(6 downto 0); -- cathodes
    signal anodes : std_logic_vector(3 downto 0);

begin

    -- counter process to switch between displays
    process (clock, reset)
    begin
        if reset = '1' then
            flick_counter <= ( others => '0' );
        elsif rising_edge(clock) then
            flick_counter <= flick_counter + 1;
        end if;
    end process;

    -- selecting the anode of the display to be lit
     with flick_counter(17 downto 16) select
        anodes <=
            "1110" when "00",
            "1101" when "01",
            "1011" when "10",
            "0111" when "11",
            "1111" when others; -- all anodes off when not selected
    
    -- connecting anodes to output
    AN <= "1111" when reset = '1' else anodes;

    -- selecting the input to display on the chosen anode
    with flick_counter(17 downto 16) select
        cathodes <=
            d1 when "11",
            d2 when "10",
            d3 when "01",
            d4 when "00",
            "1111111" when others; -- all cathodes off when not selected
    
    -- connecting the cathodes to the output
    CA <= "1111111" when reset = '1' else cathodes;

end behavioral;