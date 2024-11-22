-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: crc_cam_tb - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity crc_cam_tb is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 6
    );
end crc_cam_tb;

architecture Behavioral of crc_cam_tb is
    constant    clk_period                  : time  := 10 ns;

    signal      clk          : std_logic := '1';
    signal      w_en         : std_logic := '0';
    signal      ready        : std_logic;
    signal      valid        : std_logic;
    signal      w_data       : std_logic_vector(DATA_WIDTH - 1 downto 0); 
    signal      r_addr       : std_logic_vector(ADDR_WIDTH - 1 downto 0); 
    signal      r_data       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      not_found    : std_logic;

begin

    clk_generator : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    UUT : entity work.crc_cam
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk       => clk,
        w_en      => w_en,
        ready     => ready,
        valid     => valid,
        w_data    => w_data,
        r_addr    => r_addr,
        r_data    => r_data,
        not_found => not_found
    );
    
    write_process : process
    begin
        wait for 10*clk_period; 
        
        w_en      <= '1';
        w_data    <= std_logic_vector(to_unsigned(1, r_data'length));
        wait for 20*clk_period; 

        w_data    <= std_logic_vector(to_unsigned(2, r_data'length));
        wait for 20*clk_period; 

        w_data    <= std_logic_vector(to_unsigned(3, r_data'length));
        wait for 20*clk_period; 

        w_data    <= std_logic_vector(to_unsigned(51, r_data'length));
        wait for 20*clk_period; 

        w_data    <= std_logic_vector(to_unsigned(0, r_data'length));
        wait for 20*clk_period; 
        w_en      <= '0';

        w_data    <= std_logic_vector(to_unsigned(33, r_data'length));
        wait for 20*clk_period; 
    end process;

    read_process : process
    begin
        wait for 30*clk_period; 
        
        r_data    <= std_logic_vector(to_unsigned(1, r_data'length));
        wait for 20*clk_period; 

        r_data    <= std_logic_vector(to_unsigned(2, r_data'length));
        wait for 20*clk_period; 

        r_data    <= std_logic_vector(to_unsigned(3, r_data'length));
        wait for 20*clk_period; 

        r_data    <= std_logic_vector(to_unsigned(51, r_data'length));
        wait for 20*clk_period; 

        r_data    <= std_logic_vector(to_unsigned(0, r_data'length));
        wait for 20*clk_period; 
        
    end process;


end Behavioral;
