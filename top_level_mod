library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity top_level_mod is
    Port ( rst          : in STD_LOGIC;  
           clk          : in STD_LOGIC;  
           row_in       : inout STD_LOGIC_VECTOR(3 downto 0); 
           col_out      : out STD_LOGIC_VECTOR(3 downto 0); 
           lock_en      : out STD_LOGIC; 
           buzzer_out   : out STD_LOGIC; 
           led_status   : out STD_LOGIC_VECTOR(1 downto 0); 
           
           -- Pinos físicos do Display LCD (Substituindo o antigo lcd_status)
           lcd_rs       : out STD_LOGIC;
           lcd_rw       : out STD_LOGIC;
           lcd_e        : out STD_LOGIC;
           lcd_data     : out STD_LOGIC_VECTOR(7 downto 0)
         );
end top_level_mod;

architecture Structural of top_level_mod is

    signal key_valid_raw   : STD_LOGIC; 
    signal key_code_wire   : STD_LOGIC_VECTOR(3 downto 0);

    -- Sinais do Edge Detector (Detector de Borda)
    signal key_valid_last  : STD_LOGIC := '0';
    signal key_valid_pulse : STD_LOGIC;
    
    -- Sinal interno para conectar a FSM ao Controlador do LCD
    signal lcd_status_wire : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- 1. Força os Resistores Internos (Pull-ups da placa física)
    PU_ROW3: PULLUP port map (O => row_in(3));
    PU_ROW2: PULLUP port map (O => row_in(2));
    PU_ROW1: PULLUP port map (O => row_in(1));
    PU_ROW0: PULLUP port map (O => row_in(0));

    -- 2. Scanner do Teclado
    U1_KEYPAD: entity work.Keypad_Scanner
        port map (
            clk       => clk,      
            rst       => rst,
            row_in    => row_in,   
            col_out   => col_out,  
            key_valid => key_valid_raw, 
            key_code  => key_code_wire   
        );

    -- 3. DETECTOR DE BORDA 
    process(clk)
    begin
        if rising_edge(clk) then
            key_valid_last <= key_valid_raw;
        end if;
    end process;
    
    key_valid_pulse <= '1' when (key_valid_raw = '1' and key_valid_last = '0') else '0';

    -- 4. Máquina de Estados
    U2_FSM: entity work.FSM_Controller
        port map (
            clk          => clk,     
            rst          => rst,
            key_valid    => key_valid_pulse, 
            key_code     => key_code_wire,         
            lock_en      => lock_en,
            led_status   => led_status,
            buzzer_out   => buzzer_out,
            lcd_status   => lcd_status_wire -- Agora conectado ao sinal interno
        );

    -- 5. Controlador do Display LCD
    U3_LCD: entity work.LCD_Controller
        port map (
            clk        => clk,
            rst        => rst,
            lcd_status => lcd_status_wire, -- Recebe o status da FSM
            lcd_rs     => lcd_rs,
            lcd_rw     => lcd_rw,
            lcd_e      => lcd_e,
            lcd_data   => lcd_data
        );

end Structural;
