library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;


entity FSM is
    generic (
        COLOR_DEPTH : integer:=6;    -- Number of bits per pixel
        ROW_WIDTH   : integer:=256  -- Number of pixels in a row

    );
    port
	 (
       clk: in  std_logic;
       rst: in  std_logic;
       start: in  std_logic;
       done1: out std_logic; 
       write_adr: out std_logic_vector(7 downto 0);--ram
       read_adr: out std_logic_vector(7 downto 0);--rom
       rom_read_en: out std_logic; --when to read
       ram_write_en: out std_logic --when to write
    );
end FSM;

architecture Behavioral of FSM is
   
    -- States for FSM
    type state_type is (IDLE, S0, S1, DONE);
    signal current_state: state_type;
	 
    -- Control signals
    signal write_en, read_en: std_logic; 
    signal write_count, read_count: std_logic_vector(7 downto 0);
    signal d1, d2, d3, d4: std_logic;--delays
    
begin

   write_adr <= write_count;
   read_adr <= read_count;
	
-- Process to control FSM and counters
process(clk, rst)
begin
    if rst = '1' then
        current_state <= IDLE;
        read_count <= (others => '0'); 
        write_count <= (others => '0');
        read_en <= '0';
        write_en <= '0';
        done1 <= '0';
        
        d1 <= '0';
        d2 <= '0';
        d3 <= '0';
        d4 <= '0';
    elsif rising_edge(clk) then
        
        if (read_en = '1') then
            read_count <= read_count + 1;
        end if;

        if (write_en = '1') then
            write_count <= write_count + 1;
        end if;

        -- Pipeline delays
        read_en<=d1;
        d2 <= read_en;
        d3 <= d2;
        d4 <= d3;
        write_en <= d4;
		  
        rom_read_en<='1';
        ram_write_en<='1';
		  
        -- FSM state transitions
        case current_state is
            when IDLE =>
                if start = '1' then
                    current_state <= S0;
                    d1 <= '1';
                    
                end if;
            when S0 =>
                if read_count = 254 then
                    read_en <= '0';
              
                  current_state <=  S1;
                end if;

           when S1 =>
             if write_count = 254 then 
                    write_en <= '0';
                   current_state <= DONE;
              end if;
          
            when DONE =>		
                done1 <= '1';
                d1 <= '0';
                d2 <= '0';
                d3 <= '0';
                d4 <= '0';
                read_en <= '0';
                write_en <= '0';
                read_count <= (others => '0');
                write_count <= (others => '0');
               
            when others =>
                current_state <= IDLE; -- Default state
        end case;
    end if;
end process;



end Behavioral;

