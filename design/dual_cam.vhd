-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: dual_cam - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dual_cam is
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
end dual_cam;

architecture Behavioral of dual_cam is
    type memory_cam is array (0 to 2**DATA_WIDTH-1) of std_logic_vector(ADDR_WIDTH-1 downto 0);
    type memory_ram is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal      mem_cam        : memory_cam := (others => (others => '0'));
    signal      mem_ram        : memory_ram := (others => (others => '0'));
    
begin
    
    write_process : process(clk)
        variable    old_cam_data  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        variable    old_ram_addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if w_en = '1' then
                --write new data
                mem_cam(to_integer(unsigned(w_data))) <= w_addr;
                mem_ram(to_integer(unsigned(w_addr))) <= w_data;
                --remove old data
                old_cam_data := mem_ram(to_integer(unsigned(w_addr)));
                mem_cam(to_integer(unsigned(old_cam_data))) <= (others => '1');
                old_ram_addr := mem_cam(to_integer(unsigned(w_data)));
                mem_ram(to_integer(unsigned(old_ram_addr))) <= (others => '1');
            end if;
        end if;
    end process;

    read_process : process(clk)
    begin
        if rising_edge(clk) then
            r_addr <= mem_cam(to_integer(unsigned(r_data)));
        end if;
    end process;
end Behavioral;
