library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity crc_tb is
    generic (
        DATA_WIDTH : integer := 8;
        CRC_WIDTH  : integer := 8    -- betwen 1 nad 16
    );
end crc_tb;

architecture Behavioral of crc_tb is
    constant   clk_period   : time  := 10 ns;
    signal     clk          : std_logic;
    signal     data_in      : std_logic_vector(DATA_WIDTH -1 downto 0);
    signal     valid_in     : std_logic := '0';
    signal     valid_out    : std_logic;
    signal     crc_out      : std_logic_vector(CRC_WIDTH -1 downto 0);


begin

    clk_generator : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;


    UUT : entity work.crc
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        CRC_WIDTH  => CRC_WIDTH
    )
    port map(
        clk         => clk,
        data_in     => data_in,
        valid_in    => valid_in,
        valid_out   => valid_out,
        crc_out     => crc_out
    );


    sim : process
    begin
        data_in <= std_logic_vector(to_unsigned(6, data_in'length));
        wait for 16*clk_period;
        data_in <= "111011000";
        wait for 16*clk_period;
        valid_in <= '1';
        wait for clk_period;
    end process;


end Behavioral;
