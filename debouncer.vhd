library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  port (
    clock : in std_logic;
    reset : in std_logic;

    bouncy    : in std_logic; -- input to debounce

    -- pulse : out std_logic; -- debounced pulse output
    debounced : out std_logic -- debounced level output
  );

end;

architecture behavioral of debouncer is

  signal counter : unsigned (11 downto 0) := (others => '1'); -- keeps track the time interval in which the signal is stable
  signal candidate_value : std_logic; -- keeps track of the candidate stable value
  signal stable_value : std_logic; -- keeps track of the current stable value
  signal delayed_stable_value : std_logic; -- delayed version of stable value to generate output

begin

  process (clock, reset) begin

    -- reset -> reset counter, stable and candidate value
    if reset = '1' then
      counter         <= (others => '1');
      candidate_value <= '0';
      stable_value    <= '0';
    
    elsif rising_edge(clock) then
      -- check whether the signal is stable
      if bouncy = candidate_value then
        -- stable signal -> check for how long
        if counter = 0 then
          stable_value <= candidate_value;
        else
          -- decrement the counter
          counter <= counter - 1;
        end if;
      else
        -- unstable signal -> update the candidate value and reset the counter
        candidate_value <= bouncy;
        counter         <= (others => '1');
      end if;
    end if;
  end process;

  -- process that creates a delayed version of the stable signal
  process (clock, reset) begin
    if reset = '1' then
      -- assignment of reset value
      delayed_stable_value <= '0';
    elsif rising_edge(clock) then
      -- value assignment to each clock cycle
      delayed_stable_value <= stable_value;
    end if;
  end process;

  -- debounced level output: is high until it transitions back to 0
  debounced <= stable_value;

  -- debounced pulse output: only goes high when the stable value transitions from 0 to 1
  -- pulse <= '1' when stable_value = '1' and delayed_stable_value = '0' else '0';

end behavioral;