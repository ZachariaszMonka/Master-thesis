-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: basic_ram_without_generic - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity basic_ram_without_generic is
    port (
        clk      : in  std_logic;
        w_en     : in  std_logic;
        w_addr   : in  std_logic_vector(1 downto 0);
        w_data   : in  std_logic_vector(7 downto 0);
        r_addr   : in  std_logic_vector(1 downto 0);
        r_data   : out std_logic_vector(7 downto 0)
    );
end basic_ram_without_generic;

architecture Behavioral of basic_ram_without_generic is
    type memory_array is array (0 to 4) of std_logic_vector(7 downto 0);
    signal mem : memory_array := (others => (others => '0'));
begin
    
    write_process : process(clk)
    begin
        if rising_edge(clk) then
            if w_en = '1' then
                mem(to_integer(unsigned(w_addr))) <= w_data;
            end if;
        end if;
    end process;

    read_process : process(clk)
    begin
        if rising_edge(clk) then
            r_data <= mem(to_integer(unsigned(r_addr)));
        end if;
    end process;
end Behavioral;
