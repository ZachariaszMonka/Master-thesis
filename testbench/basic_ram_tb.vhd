-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: basic_ram_tb - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity basic_ram_tb is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 8
    );
end basic_ram_tb;

architecture Behavioral of basic_ram_tb is
    constant    clk_period                  : time  := 10 ns;

    signal      clk            : std_logic;
    signal      w_en           : std_logic;
    signal      w_addr         : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      w_data         : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal      r_addr         : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      r_data         : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    clk_generator : process
    begin
        wait for clk_period*9/20;       
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period*1/20; 
    end process;
    
    UUT : entity work.basic_ram
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map (
        clk      => clk,
        w_en     => w_en,
        w_addr   => w_addr,
        w_data   => w_data,
        r_addr   => r_addr,
        r_data   => r_data
    );
    
    sim_process : process
    begin
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(0, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(0, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(0, r_addr'length));
        wait for clk_period;
        
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(1, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(2, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(2, r_addr'length));
        wait for clk_period;

        w_en    <= '1';
        w_addr  <= std_logic_vector(to_unsigned(2, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(4, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(0, r_addr'length));
        wait for clk_period;
        
        w_en    <= '1';
        w_addr  <= std_logic_vector(to_unsigned(5, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(3, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(2, r_addr'length));
        wait for clk_period;
        
        w_en    <= '1';
        w_addr  <= std_logic_vector(to_unsigned(8, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(4, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(1, r_addr'length));
        wait for clk_period;
        
        w_en    <= '1';
        w_addr  <= std_logic_vector(to_unsigned(8, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned(4, w_data'length));
        r_addr  <= std_logic_vector(to_unsigned(1, r_addr'length));
        wait for clk_period;

    end process;

end Behavioral;
