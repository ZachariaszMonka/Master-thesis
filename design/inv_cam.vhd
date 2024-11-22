-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: inv_cam - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity inv_cam is
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
end inv_cam;

architecture Behavioral of inv_cam is
    type memory_array is array (0 to 2**DATA_WIDTH-1) of std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      mem              : memory_array := (others => (others => '0'));
    attribute   ram_style        : string;
    attribute   ram_style of mem : signal is "distributed";
    signal      o_r_addr         : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
    
    write_process : process(clk)
    begin
        if falling_edge(clk) then
            if w_en = '1' then
                mem(to_integer(unsigned(w_data))) <= w_addr;
            end if;
        end if;
    end process;

    read_process : process(clk)
    begin
        if falling_edge(clk) then
            o_r_addr <= mem(to_integer(unsigned(r_data)));
        end if;
        if rising_edge(clk) then
            r_addr <= o_r_addr;
        end if;
    end process;
end Behavioral;
