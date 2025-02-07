library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplevel is
    generic (
        COLOR_DEPTH : integer:=6 ;    -- Number of bits per pixel
        ROW_WIDTH   : integer:=256 -- Number of pixels in a row
    
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        start: in  std_logic;
        done: out std_logic
    );
end toplevel;

architecture Behavioral of toplevel is
    signal low_row_r, mid_row_r, hig_row_r: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2 * COLOR_DEPTH - 1 downto 0); --1548
    signal low_row_g, mid_row_g, hig_row_g: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2 * COLOR_DEPTH - 1 downto 0);
    signal low_row_b, mid_row_b, hig_row_b: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) + 2 * COLOR_DEPTH - 1 downto 0);
    signal current_row_r,current_row_g,current_row_b: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) - 1 downto 0);
    signal row_out_r,row_out_g,row_out_b: std_logic_vector((ROW_WIDTH * COLOR_DEPTH) - 1 downto 0);
    signal read_adr, write_adr: std_logic_vector(7 downto 0);
    signal ram_write_en,rom_read_en: std_logic;
  

begin

-- Instantiate FSM
fsm_inst: entity work.FSM
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        clk => clk,
        rst => rst,
        start => start,
        done1 => done,
        write_adr => write_adr,
        read_adr => read_adr,
       rom_read_en=>rom_read_en,
       ram_write_en=>ram_write_en
             );

-- Instantiate Buffer
buff1_inst_b: entity work.Buff1
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        clk => clk,
        rst => rst,
        load_en => rom_read_en,
        current_row => current_row_b,
        low_row => low_row_b,
        mid_row => mid_row_b,
        hig_row => hig_row_b
    );

buff1_inst_r: entity work.Buff1
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        clk => clk,
        rst => rst,
        load_en => rom_read_en,
        current_row => current_row_r,
        low_row => low_row_r,
        mid_row => mid_row_r,
        hig_row => hig_row_r
    );



buff1_inst_g: entity work.Buff1
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        clk => clk,
        rst => rst,
        load_en => rom_read_en,
        current_row => current_row_g,
        low_row => low_row_g,
        mid_row => mid_row_g,
        hig_row => hig_row_g
    );


-- Instantiate Median Filter
med_inst_r: entity work.Med
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        low_row => low_row_r,
        mid_row => mid_row_r,
        hig_row => hig_row_r,
        row_out => row_out_r
    );


med_inst_g: entity work.Med
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        low_row => low_row_g,
        mid_row => mid_row_g,
        hig_row => hig_row_g,
        row_out => row_out_g
    );



med_inst_b: entity work.Med
    generic map (
        COLOR_DEPTH => COLOR_DEPTH,
        ROW_WIDTH   => ROW_WIDTH
    )
    port map (
        low_row => low_row_b,
        mid_row => mid_row_b,
        hig_row => hig_row_b,
        row_out => row_out_b
    );

-- Instantiate ROM and RAM
rom_inst_r: entity work.rom_1536_256
    generic map (
        ROM_INIT_FILE => "r1.mif"
    )
    port map (
        aclr => rst,
        address => read_adr,
        clock => clk,
        q => current_row_r
    );



rom_inst_g: entity work.rom_1536_256
    generic map (
        ROM_INIT_FILE => "g1.mif"
    )
    port map (
        aclr => rst,
        address => read_adr,
        clock => clk,
        q => current_row_g
    );


rom_inst_b: entity work.rom_1536_256
    generic map (
        ROM_INIT_FILE => "b1.mif"
    )
    port map (
        aclr => rst,
        address => read_adr,
        clock => clk,
        q => current_row_b
    );


ram_inst_r: entity work.ram_1536_256

    generic map (
        inst_name => "RRAM"
    )
    
    port map (
        aclr => rst,
        address => write_adr,
        clock => clk,
        data => row_out_r,
        wren => ram_write_en,
        q => open

    );


ram_inst_g: entity work.ram_1536_256

    generic map (
        inst_name => "GRAM"
    )
    
    port map (
        aclr => rst,
        address => write_adr,
        clock => clk,
        data => row_out_g,
        wren => ram_write_en,
        q => open

    );


ram_inst_b: entity work.ram_1536_256

    generic map (
        inst_name => "BRAM"
    )
    
    port map (
        aclr => rst,
        address => write_adr,
        clock => clk,
        data => row_out_b,
        wren => ram_write_en,
        q => open

    );

end Behavioral;

