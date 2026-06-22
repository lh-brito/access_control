library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- NOME ATUALIZADO AQUI
entity tb_access_control is
end tb_access_control;

-- NOME ATUALIZADO AQUI
architecture Behavioral of tb_access_control is

    -- Declaração do módulo principal
    component top_level_mod is
        Port ( rst          : in STD_LOGIC;  
               clk          : in STD_LOGIC;  
               row_in       : inout STD_LOGIC_VECTOR(3 downto 0); 
               col_out      : out STD_LOGIC_VECTOR(3 downto 0); 
               lock_en      : out STD_LOGIC; 
               buzzer_out   : out STD_LOGIC; 
               led_status   : out STD_LOGIC_VECTOR(1 downto 0); 
               
               -- Pinos do LCD
               lcd_rs       : out STD_LOGIC;
               lcd_rw       : out STD_LOGIC;
               lcd_e        : out STD_LOGIC;
               lcd_data     : out STD_LOGIC_VECTOR(7 downto 0)
             );
    end component;

    -- Sinais de ligação
    signal s_rst        : STD_LOGIC := '0';
    signal s_clk        : STD_LOGIC := '0';
    signal s_row_in     : STD_LOGIC_VECTOR(3 downto 0);
    signal s_col_out    : STD_LOGIC_VECTOR(3 downto 0);
    
    signal s_lock_en    : STD_LOGIC;
    signal s_buzzer_out : STD_LOGIC;
    signal s_led_status : STD_LOGIC_VECTOR(1 downto 0);
    
    -- Sinais de ligação do LCD
    signal s_lcd_rs     : STD_LOGIC;
    signal s_lcd_rw     : STD_LOGIC;
    signal s_lcd_e      : STD_LOGIC;
    signal s_lcd_data   : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 10 ns; 

    -- Sinais para emular o teclado
    signal s_target_row  : integer := 0;
    signal s_target_col  : integer := 0;
    signal s_key_pressed : boolean := false;

begin

    UUT: top_level_mod
        port map (
            rst        => s_rst,
            clk        => s_clk,
            row_in     => s_row_in,
            col_out    => s_col_out,
            lock_en    => s_lock_en,
            buzzer_out => s_buzzer_out,
            led_status => s_led_status,
            lcd_rs     => s_lcd_rs,
            lcd_rw     => s_lcd_rw,
            lcd_e      => s_lcd_e,
            lcd_data   => s_lcd_data
        );
        
    clk_process :process
    begin
        s_clk <= '0';
        wait for clk_period/2;  
        s_clk <= '1';
        wait for clk_period/2;  
    end process;

    process(s_col_out, s_key_pressed, s_target_row, s_target_col)
    begin
        s_row_in <= "1111"; 
        if s_key_pressed then
            if s_col_out(s_target_col) = '0' then
                s_row_in(s_target_row) <= '0'; 
            end if;
        end if;
    end process;

    stim_proc: process
    begin
        s_rst <= '1';
        wait for 100 ns; 
        s_rst <= '0';
        wait for 2 ms; 
        
        -- Digita '1' 
        s_target_row <= 0; s_target_col <= 0; s_key_pressed <= true;
        wait for 40 ms; 
        s_key_pressed <= false;
        wait for 40 ms; 

        -- Digita '2' 
        s_target_row <= 0; s_target_col <= 1; s_key_pressed <= true;
        wait for 40 ms; 
        s_key_pressed <= false;
        wait for 40 ms; 

        -- Digita '3' 
        s_target_row <= 0; s_target_col <= 2; s_key_pressed <= true;
        wait for 40 ms; 
        s_key_pressed <= false;
        wait for 40 ms; 

        -- Digita '4' 
        s_target_row <= 1; s_target_col <= 0; s_key_pressed <= true;
        wait for 40 ms; 
        s_key_pressed <= false;
        
        wait for 100 ms; 
        wait;
    end process;

end Behavioral;
