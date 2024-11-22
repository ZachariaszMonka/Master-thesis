-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: inv_cam_tb - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity inv_cam_tb is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 6
    );
end inv_cam_tb;

architecture Behavioral of inv_cam_tb is
    constant    clk_period                  : time  := 10 ns;

    signal      clk          : std_logic;
    signal      w_en         : std_logic;
    signal      w_data       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      w_addr       : std_logic_vector(ADDR_WIDTH - 1 downto 0); 
    signal      r_data       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      r_addr       : std_logic_vector(ADDR_WIDTH - 1 downto 0);

    type memory_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem_tb : memory_array := (others => (others => '0'));

begin

    clk_generator : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    UUT : entity work.inv_cam
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk        => clk,
        w_en       => w_en,
        w_data     => w_data,
        w_addr     => w_addr,
        r_data     => r_data,
        r_addr     => r_addr
    );
    
    write_process : process
        variable    write_addr  :  integer;
        variable    write_data  :  integer;
    begin

        --try write without w_en = 1
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(0, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned((80)mod(2 ** DATA_WIDTH), w_data'length));
        wait for clk_period;

        --try write without w_en = 1
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(1, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned((51)mod(2 ** DATA_WIDTH), w_data'length));
        wait for clk_period;

        --save all cell in memory by (number of cell + 10)
        for i in 0 to 2**ADDR_WIDTH - 1 loop
            if  i = 2**ADDR_WIDTH - 1 then
                write_addr := 2**ADDR_WIDTH - 1;
            else
                write_addr := (write_addr + 2 ** ADDR_WIDTH / 8 )mod(2 ** ADDR_WIDTH - 1);
            end if;
            write_data := (write_addr + 10)mod(2 ** DATA_WIDTH);
            w_en    <= '1';
            w_addr  <= std_logic_vector(to_unsigned(write_addr, w_addr'length));
            w_data  <= std_logic_vector(to_unsigned(write_data, w_data'length));
            mem_tb(write_addr) <= std_logic_vector(to_unsigned(write_data, w_data'length));
            wait for clk_period;             
        end loop;

    end process;

    read_process : process
        variable    read_addr  :  integer;
        variable    read_data  :  integer;
    begin

        r_data    <= mem_tb(5);
        wait for clk_period; 

        r_data    <= mem_tb(6);
        wait for clk_period; 

        r_data    <= mem_tb(8);
        wait for clk_period; 

        r_data    <= mem_tb(10);
        wait for clk_period; 

        r_data    <= mem_tb(0);
        wait for clk_period; 
        
    end process;


end Behavioral;
