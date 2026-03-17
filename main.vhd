library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    port (
        clock : in std_logic;
        switches : in std_logic_vector(15 downto 0); -- switches inputs
        btnC, btnL, btnU, btnR, btnD : in std_logic; -- individual button inputs

        CA : out std_logic_vector(6 downto 0); -- cathodes
        AN : out std_logic_vector(3 downto 0); -- anodes
        led : out std_logic_vector(15 downto 0) -- LED outputs
    );
end main;

architecture structural of main is

    signal reset, start : std_logic; -- global reset signal + start signal
    signal buttons : std_logic_vector(4 downto 0); -- button inputs
    signal P1, P2, P3, P4 : std_logic; -- (debounced) button inputs

    signal hello, enable, go, ts, won : std_logic; -- control signals between the CUs
    signal winner : std_logic_vector(1 downto 0); -- winner of the game

    signal fs1, fs2, fs3, fs4 : std_logic; -- false start signals to the PIPO register
    signal resetFS : std_logic; -- reset signal to the PIPO register
    signal false_start : std_logic_vector(3 downto 0); -- vector of false start signals from the PIPO register

    constant timerSize : natural := 27; -- number of bits of the timer counter
    signal resetT, enableT, endT : std_logic; -- timer control signals
    signal resetB, enableB, endB : std_logic; -- blink control signals
    

    signal d1, d2, d3, d4 : std_logic_vector(6 downto 0); -- outputs to the 7-segment displays

begin

    reset <= switches(0); -- using the first switch as a reset signal
    start <= switches(15); -- using the last switch as a start signal

    -- assigning buttons
    buttons(0) <= btnU;
    buttons(1) <= btnL;
    buttons(2) <= btnD;
    buttons(3) <= btnR;
    buttons(4) <= btnC;

    -- debouncers
    player1 : entity work.debouncer
        port map (
            clock => clock,
            reset => reset,
            bouncy => buttons(0),
            debounced => P1
        );
    
    player2 : entity work.debouncer
        port map (
            clock => clock,
            reset => reset,
            bouncy => buttons(1),
            debounced => P2
        );
    
    player3 : entity work.debouncer
        port map (
            clock => clock,
            reset => reset,
            bouncy => buttons(2),
            debounced => P3
        );
        
    player4 : entity work.debouncer
        port map (
            clock => clock,
            reset => reset,
            bouncy => buttons(3),
            debounced => P4
        );
    
    -- control units
    elisa : entity work.elisaCU
        port map (
            clk => clock,
            reset => reset,

            start => start,
            enable => enable,
            go => go,
            P1 => P1,
            P2 => P2,
            P3 => P3,
            P4 => P4,
            false_start => false_start,

            won => won,
            ts => ts,
            winner => winner,
            fs1 => fs1,
            fs2 => fs2,
            fs3 => fs3,
            fs4 => fs4,
            resetFS => resetFS
        );
    
    giovanni : entity work.giovanniCU
        port map (
            clk => clock,
            reset => reset,

            P1 => P1,
            P2 => P2,
            P3 => P3,
            P4 => P4,
            start => start,
            led => led,

            endT => endT,
            enableT => enableT,
            resetT => resetT,
            endB => endB,
            enableB => enableB,
            resetB => resetB,

            won => won,
            ts => ts,
            winner => winner,
            hello => hello,
            enable => enable,
            go => go
        );
    
    -- display control and 7-segment display
    display : entity work.displayControl
        port map (
            clk => clock,
            reset => reset,

            hello => hello,
            enable => enable,
            go => go,
            won => won,
            winner => winner,
            false_start => false_start,

            d1 => d1,
            d2 => d2,
            d3 => d3,
            d4 => d4
        );
    
    display7seg : entity work.sevenSegment
        port map (
            clock => clock,
            reset => reset,

            d1 => d1,
            d2 => d2,
            d3 => d3,
            d4 => d4,

            CA => CA,
            AN => AN
        );
    
    -- PIPO register to store false start signals
    FSregister : entity work.FSregister
        port map (
            clock => clock,
            reset => reset,

            fs1 => fs1,
            fs2 => fs2,
            fs3 => fs3,
            fs4 => fs4,
            resetFS => resetFS,

            false_start => false_start
        );
    
    -- light timer randomizer (enable a periodic counter (max 1s) when start = 1 and end it when and = 1, then use that time as traffic light signals)

    -- timer process to generate endT after ~1s
    timer : process(clock, reset)
        variable count : unsigned(timerSize-1 downto 0) := (others => '1');
    begin

        -- asynchronous global reset
        if reset = '1' then
            count := (others => '1');
            endT <= '0';

        elsif rising_edge(clock) then

            -- synchronous local reset 
            if resetT = '1' then
                count := (others => '1');
                endT <= '0';
            
            -- if no resets, check if enabled
            elsif enableT = '1' then
                
                -- if count finished, send signal and reset timer
                if count = 0 then
                    endT <= '1';
                    count := (others => '1');
                -- else count down
                else
                    count := count - 1;
                    endT <= '0';
                end if;
            
            -- if not enabled, timer sure hasn't finished
            else
                endT <= '0';
            end if;
        end if;
    end process;

    -- timer process to make festive LEDs blink
    blink : process(clock, reset)
        variable count : unsigned(25 downto 0) := (others => '1');
    begin

        -- asynchronous global reset
        if reset = '1' then
            count := (others => '1');
            blink <= '0';

        elsif rising_edge(clock) then

            -- synchronous local reset 
            if resetB = '1' then
                count := (others => '1');
                endB <= '0';
            
            -- if no resets, check if enabled
            elsif enableB = '1' then
                
                -- if count finished, send signal and reset timer
                if count = 0 then
                    endB <= '1';
                    count := (others => '1');
                -- else count down
                else
                    count := count - 1;
                    endB <= '0';
                end if;
            
            -- if not enabled, timer sure hasn't finished
            else
                endT <= '0';
            end if;
        end if;
    end process;


end structural;