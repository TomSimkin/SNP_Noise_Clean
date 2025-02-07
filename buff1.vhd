library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Buff1 is
    generic (
        COLOR_DEPTH : integer:=6 ;    -- Number of bits
        ROW_WIDTH   : integer:=256    -- Simplified for testing
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        load_en: in  std_logic;
        current_row: in  std_logic_vector((ROW_WIDTH * COLOR_DEPTH) - 1 downto 0);
        low_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0);
        mid_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0);
        hig_row: out std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2*COLOR_DEPTH -1 downto 0)
    );
end Buff1;

architecture Behavioral of Buff1 is
    signal low_r, mid_r, hig_r: std_logic_vector((ROW_WIDTH * COLOR_DEPTH)+ 2*COLOR_DEPTH - 1 downto 0);
begin

    -- Process 1: Propagate rows
    process(clk, rst)
    begin
        if rst = '1' then
            low_r <= (others => '0');
            mid_r <= (others => '0');
            hig_r <= (others => '0');
        elsif (rising_edge(clk) AND load_en='1') then
            hig_r <= mid_r;
            mid_r <= low_r;
            low_r <= (current_row((ROW_WIDTH * COLOR_DEPTH) - 1 downto (ROW_WIDTH * COLOR_DEPTH) - COLOR_DEPTH)
             & current_row &current_row(COLOR_DEPTH - 1 downto 0));
        end if;
    end process;

    low_row <=  low_r;
    mid_row <=  mid_r;
    hig_row <= hig_r;

end Behavioral;

