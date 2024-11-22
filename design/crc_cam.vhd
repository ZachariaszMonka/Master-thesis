-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: crc_cam - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity crc_cam is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 2
    );
    port (
        clk       : in  std_logic;
        w_en      : in  std_logic;
        ready     : out std_logic := '0';
        valid     : out std_logic := '0';
        not_found : out std_logic := '0';
        w_data    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        r_addr    : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        r_data    : in  std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end crc_cam;

architecture Behavioral of crc_cam is
    type memory_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : memory_array;
   
    type state_type is (s_wait, s_crc_str, s_crc_cal, s_data_op);
    signal      state_w         : state_type := s_wait;
    signal      state_r         : state_type := s_wait;
    signal      old_w_data      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal      old_r_data      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal      w_delta         : std_logic;
    signal      r_delta         : std_logic;
    signal      crc_w           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_w_start     : std_logic := '0';
    signal      crc_w_finish    : std_logic;
    signal      crc_r           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_r_start     : std_logic := '0';
    signal      crc_r_finish    : std_logic;

begin

    u_crc_w : entity work.crc
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => w_data,
        valid_in    => crc_w_start,
        valid_out   => crc_w_finish,
        crc_out     => crc_w
    );

    u_crc_r : entity work.crc
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => r_data,
        valid_in    => crc_r_start,
        valid_out   => crc_r_finish,
        crc_out     => crc_r
    );

    read_process : process(clk)
    begin
        if falling_edge(clk) then
            case state_r is
                when s_wait    => 
                    valid       <= '1';
                    crc_r_start <= '0';
                    if r_delta = '1' then
                        state_r <= s_crc_str;
                    end if;
                when s_crc_str =>
                    valid       <= '0';
                    crc_r_start <= '1';
                    old_r_data  <= r_data;
                    state_r <= s_crc_cal;
                when s_crc_cal =>
                    valid       <= '0';
                    crc_r_start <= '1';
                    if crc_r_finish = '1' then
                        state_r <= s_data_op;
                    end if;
                when s_data_op =>
                    valid       <= '0';
                    crc_r_start <= '0';
                    if mem(to_integer(unsigned(crc_r))) = r_data then
                        r_addr <= crc_r;
                        not_found <= '0';
                    else
                        r_addr <= (others => '1'); 
                        not_found <= '1';
                    end if;
                    state_r <= s_wait;
                when others    =>
                    valid       <= '0';
                    crc_r_start <= '0';
                    state_r <= s_wait;
         end case;  
        end if;
    end process;

    write_process : process(clk)
    begin
        if falling_edge(clk) then
            case state_w is
                when s_wait    => 
                    ready       <= '1';
                    crc_w_start <= '0';
                    if w_en = '1' and w_delta = '1' then
                        state_w <= s_crc_str;
                    end if;
                when s_crc_str =>
                    ready       <= '0';
                    crc_w_start <= '1';
                    old_w_data  <= w_data;
                    state_w <= s_crc_cal;
                when s_crc_cal =>
                    ready       <= '0';
                    crc_w_start <= '1';
                    if crc_w_finish = '1' then
                        state_w <= s_data_op;
                    end if;
                when s_data_op =>
                    ready       <= '0';
                    crc_w_start <= '0';
                    mem(to_integer(unsigned(crc_w))) <= w_data;
                    state_w <= s_wait;
                when others    =>
                    ready       <= '0';
                    crc_w_start <= '0';
                    state_w <= s_wait;
         end case;  
        end if;
    end process;

    delta : process(clk)
    begin
        if old_w_data = w_data then
            w_delta <= '0';
        else 
            w_delta <= '1';
        end if;
        if old_r_data = r_data then
            r_delta <= '0';
        else 
            r_delta <= '1';
        end if;
    end process;
    
end Behavioral;
