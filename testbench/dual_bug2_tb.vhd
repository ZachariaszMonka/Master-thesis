-------------------------------------------------------------------------------------------------
-- Company: AGH  
-- Engineer: Zachariasz Monka 
-- 
-- Design Name: 
-- Module Name: dual_bug2_tb - Behavioral
-- Project Name: MSc
-- Target Devices: xc7z007sclg400-1 (cora z7)
-- Tool Versions: vivado 2019.2 
-- Description: 
-------------------------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity dual_bug2_tb is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 8
    );
end dual_bug2_tb;

architecture Behavioral of dual_bug2_tb is
    constant    clk_period                  : time  := 10 ns;

    signal      clk             : std_logic;
    signal      w_en            : std_logic;
    signal      w_data          : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      w_addr          : std_logic_vector(ADDR_WIDTH - 1 downto 0); 
    signal      r_data_cam      : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      r_addr_cam      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal      r_data_ram      : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal      r_addr_ram      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    
    signal      ready_to_test   : std_logic := '0';
    signal      updating_data   : std_logic := '0';
    signal      global_error    : std_logic := '0';
    signal      local_error     : std_logic;
    signal      r_addr_ram_2clk : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal      r_addr_ram_1clk : std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin

    clk_generator : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    UUT : entity work.inv_cam
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk        => clk,
        w_en       => w_en,
        w_data     => w_data,
        w_addr     => w_addr,
        r_data     => r_data_cam,
        r_addr     => r_addr_cam
    );

    MEM : entity work.basic_ram
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => DATA_WIDTH
    )
    port map (
        clk     => clk,
        w_en    => w_en,
        w_addr  => w_addr,
        w_data  => w_data,
        r_addr  => r_addr_ram,
        r_data  => r_data_ram
    );

    r_data_cam    <= r_data_ram;


    write_process : process
        variable    write_addr  :  integer;
        variable    write_data  :  integer;
    begin

        --try write with out w_en = 1
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(0, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned((80)mod(2 ** DATA_WIDTH), w_data'length));
        wait for clk_period;

        --try write with out w_en = 1
        w_en    <= '0';
        w_addr  <= std_logic_vector(to_unsigned(1, w_addr'length));
        w_data  <= std_logic_vector(to_unsigned((51)mod(2 ** DATA_WIDTH), w_data'length));
        wait for clk_period;

        for added in 0 to 20 loop 
            --save all cell in memory by number of cell + "added"
            for i in 0 to 2**ADDR_WIDTH - 1 loop
                if  i = 2**ADDR_WIDTH - 1 then
                    write_addr := 2**ADDR_WIDTH - 1;
                else
                    write_addr := (write_addr + 2 ** ADDR_WIDTH / 8 )mod(2 ** ADDR_WIDTH - 1);
                end if;
                write_data := (write_addr + added)mod(2 ** DATA_WIDTH);
                w_en    <= '1';
                w_addr  <= std_logic_vector(to_unsigned(write_addr, w_addr'length));
                w_data  <= std_logic_vector(to_unsigned(write_data, w_data'length));
                wait for clk_period;
                while updating_data = '0' loop
                    wait for clk_period;
                end loop;
            end loop;
        end loop;
        
        
        

        

    end process;

    addr_gen_process : process
        variable    read_addr  :  integer;
        variable    read_data  :  integer;
    begin

        for addr in 0 to 2**ADDR_WIDTH - 1 loop
            r_addr_ram    <= std_logic_vector(to_unsigned(addr , r_addr_ram'length));
            wait for clk_period; 
        end loop;
        
    end process;


    compare_process : process
    begin
        wait for clk_period/2; --compare on rising clock
        r_addr_ram_2clk <= r_addr_ram_1clk; --  +1 clk delay
        r_addr_ram_1clk <= r_addr_ram;      --  +1 clk delay 
        if ready_to_test = '1' then    
            if r_addr_ram_2clk = r_addr_cam then
                local_error  <= '0';
            else
                local_error  <= '1';
                global_error <= '1';
            end if;
        end if;
        wait for clk_period/2;
    end process;

    simulation_process : process
    begin
        ready_to_test <= '0';
        updating_data <= '1';
        wait for 2 ** ADDR_WIDTH *clk_period;

        for i in 200 downto 10 loop
           --updating
            wait for 4*clk_period;
            ready_to_test <= '0';
            updating_data <= '1';
            wait for i*clk_period;

            --testing
            wait for 4*clk_period;
            ready_to_test <= '1';
            updating_data <= '0';
            wait for i*clk_period; 
        end loop;
        
        wait for clk_period*10;
        if global_error = '0' then
            report "Test PASS";
        else
            report "Test FALLED";
        end if;
        wait;
    end process;
    
end Behavioral;
