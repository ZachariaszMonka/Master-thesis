-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: basic_cam - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity basic_cam is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 4
    );
    port ( 
            clk             : in  std_logic; -- comon clock for in and out
            w_en            : in  std_logic; -- '1' write is active
            w_addr          : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
            w_data          : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            r_addr          : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
            r_data          : in  std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end basic_cam;

architecture Behavioral of basic_cam is
    type memory_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal      mem        : memory_array := (others => (others => '0'));
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
        variable   detected_data : std_logic_vector(2 ** ADDR_WIDTH downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            for addr in 0 to 2**ADDR_WIDTH - 1 loop
                if r_data = mem(addr) then
                    detected_data(addr) := '1';
                else
                    detected_data(addr) := '0';
                end if;
            end loop;
           r_addr <= (others => '0');
           for addr in 0 to 2**ADDR_WIDTH - 1 loop
              if detected_data(addr) = '1' then
                  r_addr <= std_logic_vector(to_unsigned(addr, r_addr'length));
              end if;
           end loop;
        end if;
    end process;
end Behavioral;
