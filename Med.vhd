library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Med is
    generic (
       COLOR_DEPTH : integer:=6;    -- Number of bits
        ROW_WIDTH   : integer :=256
    );
    port (
        low_row, mid_row, hig_row : in std_logic_vector((COLOR_DEPTH * ROW_WIDTH) +2*COLOR_DEPTH -1 downto 0);
        row_out : out std_logic_vector((COLOR_DEPTH * ROW_WIDTH) - 1 downto 0)
    );
end entity Med;

architecture Behavioral of Med is

    type pixel_array is array (0 to ROW_WIDTH + 1) of std_logic_vector(COLOR_DEPTH - 1 downto 0);

    signal low_array, mid_array, up_array : pixel_array;
    signal coulm_mom : pixel_array;
    signal row_mom : pixel_array;

   function median_func(a, b, c : std_logic_vector) return std_logic_vector is
    variable temp : std_logic_vector(5 downto 0);
    variable x, y, z : std_logic_vector(5 downto 0);
begin
    x := a;
    y := b;
    z := c;

    if x > y then
        temp := x;
        x := y;
        y := temp;
    end if;
    if y > z then
        temp := y;
        y := z;
        z := temp;
    end if;
    if x > y then
        temp := x;
        x := y;
        y := temp;
    end if;

    return y;
end function median_func;

begin


    process(low_row, mid_row, hig_row)
    begin

        for i in 0 to ROW_WIDTH + 1 loop
            low_array(i) <= low_row((i + 1) * COLOR_DEPTH - 1 downto i * COLOR_DEPTH);
            mid_array(i) <= mid_row((i + 1) * COLOR_DEPTH - 1 downto i * COLOR_DEPTH);
            up_array(i) <= hig_row((i + 1) * COLOR_DEPTH - 1 downto i * COLOR_DEPTH); 
        end loop;

    end process;

    process(low_array, mid_array, up_array)
    begin

        for i in 0 to ROW_WIDTH + 1 loop
            coulm_mom(i) <= median_func(low_array(i), mid_array(i), up_array(i)); 
        end loop;

    end process;

 process(coulm_mom)
    begin

        for i in 1 to ROW_WIDTH loop
            row_mom(i) <= median_func(coulm_mom(i-1), coulm_mom(i), coulm_mom(i+1));
        end loop;

    end process;

    process(row_mom)
    begin
        for i in 1 to ROW_WIDTH loop
            row_out(i * COLOR_DEPTH - 1 downto (i - 1) * COLOR_DEPTH) <= row_mom(i);
        end loop;

    end process;

end Behavioral;

