-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: cuckoo_cam - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cuckoo_cam is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 4
    );
    port (
        clk         : in  std_logic;        -- work on falling edge
        w_en        : in  std_logic;        -- 1-> write to memory enable
        ready       : out std_logic := '0'; -- 1-> memory is ready to write next data
        valid       : out std_logic := '0'; -- 1-> r_addr is valid
        not_found   : out std_logic := '0'; -- 1-> not found data in memory
        destination : out std_logic := '0'; -- 1-> found data in memory B, 0-> ... memory A
        w_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        r_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        r_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end cuckoo_cam;

architecture Behavioral of cuckoo_cam is
    type memory_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memA : memory_array;
    signal memB : memory_array;
    signal memA_empty    : std_logic_vector(0 to 2**ADDR_WIDTH-1) := (others => '1'); 
    signal memB_empty    : std_logic_vector(0 to 2**ADDR_WIDTH-1) := (others => '1'); 
   
    type state_type_w is (s_wait, s_1_start, s_1_cal, s_2_start, s_2_cal, s_a_start, s_a_cal, s_b_start, s_b_cal);
    signal      state_w         : state_type_w := s_wait;
    type state_type_r is (s_wait, s_crc_str, s_crc_cal);
    signal      state_r         : state_type_r := s_wait;
    
    signal      buff_w_data     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal      buff_r_data     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal      w_delta         : std_logic;
    signal      r_delta         : std_logic;
    signal      old_w_data      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal      old_r_data      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   

    signal      crc_wa           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_wa_start     : std_logic := '0';
    signal      crc_wa_finish    : std_logic;
    signal      crc_ra           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_ra_start     : std_logic := '0';
    signal      crc_ra_finish    : std_logic;

    signal      crc_wb           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_wb_start     : std_logic := '0';
    signal      crc_wb_finish    : std_logic;
    signal      crc_rb           : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal      crc_rb_start     : std_logic := '0';
    signal      crc_rb_finish    : std_logic;

begin

    u_crc_wa : entity work.crc2
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => buff_w_data,
        valid_in    => crc_wa_start,
        valid_out   => crc_wa_finish,
        crc_out     => crc_wa
    );

    u_crc_wb : entity work.crc
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => buff_w_data,
        valid_in    => crc_wb_start,
        valid_out   => crc_wb_finish,
        crc_out     => crc_wb
    );

    write_process : process(clk)
    begin
        if falling_edge(clk) then
            case state_w is
                when s_wait     => 
                    ready       <= '1';
                    crc_wa_start <= '0';
                    crc_wb_start <= '0';
                    if w_en = '1' and w_delta = '1' then
                        state_w <= s_1_start;
                    end if;
                when s_1_start   =>
                    ready           <= '0';
                    buff_w_data     <= w_data;
                    old_w_data      <= w_data;
                    crc_wa_start    <= '1';
                    crc_wb_start    <= '0';
                    state_w <= s_1_cal;
                when s_1_cal    =>
                    ready           <= '0';                    
                    if crc_wa_finish = '1' then
                        if memA_empty(to_integer(unsigned(crc_wa))) = '1' or memA(to_integer(unsigned(crc_wa))) = buff_w_data then
                            memA(to_integer(unsigned(crc_wa))) <= buff_w_data;
                            memA_empty(to_integer(unsigned(crc_wa))) <= '0';
                            state_w <= s_wait;
                        else
                            state_w <= s_2_start;
                        end if;
                    end if;    
                when s_2_start   =>
                    ready           <= '0';
                    crc_wa_start    <= '0';
                    crc_wb_start    <= '1';
                    state_w <= s_2_cal;
                when s_2_cal    =>
                    ready           <= '0';                    
                    if crc_wb_finish = '1' then
                        if memB_empty(to_integer(unsigned(crc_wb))) = '1' or memB(to_integer(unsigned(crc_wb))) = buff_w_data then
                            memB(to_integer(unsigned(crc_wb))) <= buff_w_data;
                            memB_empty(to_integer(unsigned(crc_wb))) <= '0';
                            state_w <= s_wait;
                        else
                            buff_w_data <= memA(to_integer(unsigned(crc_wa)));
                            memA(to_integer(unsigned(crc_wa))) <= buff_w_data;
                            state_w <= s_b_start;
                        end if;
                    end if;
                when s_b_start   =>
                    ready           <= '0';
                    crc_wa_start    <= '0';
                    crc_wb_start    <= '1';
                    state_w <= s_b_cal;
                when s_b_cal    =>
                    ready           <= '0';                    
                    if crc_wb_finish = '1' then
                        if memB_empty(to_integer(unsigned(crc_wb))) = '1' or memB(to_integer(unsigned(crc_wb))) = buff_w_data then
                            memB(to_integer(unsigned(crc_wb))) <= buff_w_data;
                            memB_empty(to_integer(unsigned(crc_wb))) <= '0';
                            state_w <= s_wait;
                        else
                            buff_w_data <= memB(to_integer(unsigned(crc_wb)));
                            memB(to_integer(unsigned(crc_wb))) <= buff_w_data;
                            state_w <= s_a_start;
                        end if;
                    end if;
                when s_a_start   =>
                    ready           <= '0';
                    crc_wa_start    <= '1';
                    crc_wb_start    <= '0';
                    state_w <= s_a_cal;
                when s_a_cal    =>
                ready           <= '0';                    
                if crc_wa_finish = '1' then
                    if memA_empty(to_integer(unsigned(crc_wa))) = '1' or memA(to_integer(unsigned(crc_wa))) = buff_w_data then
                        memA(to_integer(unsigned(crc_wa))) <= buff_w_data;
                        memA_empty(to_integer(unsigned(crc_wa))) <= '0';
                        state_w <= s_wait;
                    else
                        buff_w_data <= memA(to_integer(unsigned(crc_wa)));
                        memA(to_integer(unsigned(crc_wa))) <= buff_w_data;
                        state_w <= s_b_start;
                    end if;
                end if;

                when others     =>
                    ready        <= '0';
                    crc_wa_start <= '0';
                    crc_wb_start <= '0';
                    state_w <= s_wait;
         end case;  
        end if;
    end process;


    u_crc_ra : entity work.crc2
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => buff_r_data,
        valid_in    => crc_ra_start,
        valid_out   => crc_ra_finish,
        crc_out     => crc_ra
    );

    u_crc_rb : entity work.crc
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => ADDR_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => buff_r_data,
        valid_in    => crc_rb_start,
        valid_out   => crc_rb_finish,
        crc_out     => crc_rb
    );


    read_process : process(clk)
    begin
        if falling_edge(clk) then
            case state_r is
                when s_wait    => 
                    valid       <= '1';
                    crc_ra_start <= '0';
                    crc_rb_start <= '0';
                    if r_delta = '1' then
                        state_r <= s_crc_str;
                    end if;
                when s_crc_str =>
                    valid       <= '0';
                    crc_ra_start <= '1';
                    crc_rb_start <= '1';
                    buff_r_data  <= r_data;
                    buff_r_data  <= r_data;
                    state_r <= s_crc_cal;
                when s_crc_cal =>
                    valid       <= '0';
                    if crc_ra_finish = '1' and crc_ra_finish = '1' then
                        if memB(to_integer(unsigned(crc_rb))) = buff_r_data then
                            destination <= '1';
                            not_found   <= '0';
                            r_addr <= std_logic_vector(unsigned(crc_rb));
                        elsif memA(to_integer(unsigned(crc_ra))) = buff_r_data then
                            destination <= '0';
                            not_found   <= '0';
                            r_addr <= std_logic_vector(unsigned(crc_rb));
                        else
                            not_found   <= '1';
                        end if;
                    end if;   
                when others    =>
                    valid       <= '0';
                    crc_ra_start <= '0';
                    crc_rb_start <= '0';
                    state_r <= s_wait;
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
