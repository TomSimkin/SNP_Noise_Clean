library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplevel_tb is
end toplevel_tb;

architecture Behavioral of toplevel_tb is

    -- Parameters
    constant COLOR_DEPTH : integer := 6;    -- Number of bits per pixel
    constant ROW_WIDTH   : integer := 256;  -- Number of pixels in a row

    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal start: std_logic := '0';
    signal done: std_logic;

    -- Clock period
    constant clk_period: time := 10 ns;

begin

    -- Instantiate the TopLevel module
    uut: entity work.TopLevel
        generic map (
            COLOR_DEPTH => COLOR_DEPTH,
            ROW_WIDTH   => ROW_WIDTH
        )
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            done  => done
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2; -- Half period
            clk <= '1';
            wait for clk_period / 2; -- Half period
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the system
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        
        -- Start the FSM
        wait for clk_period;
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for `done` signal
        wait until done = '1';

        -- End simulation
        report "Simulation completed successfully" severity note;
        wait;
    end process;

end Behavioral;

