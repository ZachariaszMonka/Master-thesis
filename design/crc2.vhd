-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: crc2 - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package crc2_polynomials_pkg is
    constant MAX_CRC_WIDTH : integer := 16;
    type polynomial_array_t is array (1 to MAX_CRC_WIDTH) of STD_LOGIC_VECTOR(MAX_CRC_WIDTH downto 0);
    constant CRC_POLYNOMIALS : polynomial_array_t := (
        1  => "00000000000000011" , --x + 1
        2  => "00000000000000101" , --x^2 + 1
        3  => "00000000000001101" , --x^3 + x^2 + 1
        4  => "00000000000010011" , --x^4 + x + 1
        5  => "00000000000101001" , --x^5 + x^3 + 1
        6  => "00000000001000011" , --x^6 + x + 1
        7  => "00000000010001001" , --x^7 + x^3 + 1
        8  => "00000000100000111" , --x^8 + x^2 + x + 1
        9  => "00000001000100001" , --x^9 + x^5 + 1
        10 => "00000011000110011" , --x^10 + x^9 + x^5 + x^4 + x + 1
        11 => "00000101000000001" , --x^11 + x^9 + 1
        12 => "00001100000001111" , --x^12 + x^11 + x^3 + x^2 + x + 1
        13 => "00011000000000111" , --x^13 + x^12 + x^2 + x + 1
        14 => "00110000000100011" , --x^14 + x^13 + x^5 + x + 1
        15 => "01000000000000001" , --x^14 + 1
        16 => "10001000000100001"   --x^16 + x^12 + x^5 + 1
    );
end package crc2_polynomials_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.crc2_polynomials_pkg.all;

entity crc2 is
    generic (
        DATA_WIDTH : integer := 8;
        CRC_WIDTH  : integer := 8    -- between 1 and 16
    );
    Port (
        clk        : in  STD_LOGIC;
        data_in    : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        valid_in   : in  STD_LOGIC;
        valid_out  : out STD_LOGIC := '0';
        crc_out    : out STD_LOGIC_VECTOR(CRC_WIDTH-1 downto 0) := (others => '0')
    );
end crc2;

architecture Behavioral of crc2 is
    --assert CRC_WIDTH >= 1 and CRC_WIDTH <= MAX_CRC_WIDTH
    --report "CRC_WIDTH must be in the range from 1 to MAX_CRC_WIDTH
    --severity failure;

    constant POLYNOMIAL_FULL : STD_LOGIC_VECTOR(MAX_CRC_WIDTH downto 0) := CRC_POLYNOMIALS(CRC_WIDTH);
    constant POLYNOMIAL : STD_LOGIC_VECTOR(CRC_WIDTH downto 0) := POLYNOMIAL_FULL(CRC_WIDTH downto 0);
    type state_type is (s_wait, s_run);
    
    signal crc_res    : STD_LOGIC_VECTOR(CRC_WIDTH -1 downto 0);
    signal state      : state_type := s_wait;
    signal cycle      : unsigned(4 downto 0) := (others => '0');   
    signal o_reg      : STD_LOGIC_VECTOR(DATA_WIDTH + CRC_WIDTH -1 downto 0);
    

begin
    process(clk)
        variable xor_mask   : STD_LOGIC_VECTOR(DATA_WIDTH + CRC_WIDTH -1 downto 0);
        variable actial_reg : STD_LOGIC_VECTOR(DATA_WIDTH + CRC_WIDTH -1 downto 0);
    begin
        if rising_edge(clk) then
            case state is
                when s_wait =>    
                    if valid_in = '1' then
                        state     <= s_run; 
                        cycle     <= to_unsigned(DATA_WIDTH + CRC_WIDTH -1, cycle'length);
                        valid_out <= '0';
                        o_reg     <= data_in & (CRC_WIDTH - 1 downto 0 => '0');
                        xor_mask := (others => '0');
                        xor_mask((xor_mask'length -1) downto (xor_mask'length - POLYNOMIAL'length)) := POLYNOMIAL;
                    end if;
                when s_run =>
                    
                  
                    if o_reg(to_integer(cycle)) = '1' then
                        actial_reg := o_reg xor xor_mask;
                        o_reg <= actial_reg;
                    end if;
                    if cycle <= CRC_WIDTH then
                        state <= s_wait;
                        valid_out <= '1';
                        crc_out <= actial_reg(CRC_WIDTH -1 downto 0);
                    end if;
                    
                    cycle <= cycle - to_unsigned(1, cycle'length);       
                    xor_mask := xor_mask srl 1;
                when others =>
                   state <= s_wait;
            end case;     
        end if; -- rising_edge
    end process;

    
end Behavioral;
