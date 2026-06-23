library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity LCD_Controller is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        lcd_status : in  STD_LOGIC_VECTOR(2 downto 0);
        lcd_rs     : out STD_LOGIC;
        lcd_rw     : out STD_LOGIC;
        lcd_e      : out STD_LOGIC;
        lcd_data   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end LCD_Controller;

architecture Behavioral of LCD_Controller is
    -- Temporizações baseadas em 100MHz
    constant DELAY_50MS : integer := 5000000;
    constant DELAY_2MS  : integer := 200000;
    constant DELAY_50US : integer := 5000;
    constant PULSE_1US  : integer := 100;

    type state_type is (POWER_ON, INIT_FUNC, INIT_DISPLAY, INIT_CLEAR, INIT_MODE,
                        SET_LINE1, PRINT_LINE1, SET_LINE2, PRINT_LINE2, DELAY_FRAME);
    signal state : state_type := POWER_ON;

    signal timer     : integer range 0 to 5000000 := 0;
    signal char_idx  : integer range 0 to 15 := 0;
    signal lcd_e_reg : STD_LOGIC := '0';

    -- Sinais dinâmicos para as mensagens
    signal msg1, msg2 : string(1 to 16);

    -- Dicionário de Mensagens
    constant IDLE_1 : string(1 to 16) := "CONTR. DE ACESSO";
    constant IDLE_2 : string(1 to 16) := "DIGITE A SENHA: ";
    
    constant OPEN_1 : string(1 to 16) := "ACESSO LIBERADO ";
    constant OPEN_2 : string(1 to 16) := "   BEM-VINDO!   ";
    
    constant ERR_1  : string(1 to 16) := " SENHA INCORRETA";
    constant ERR_2  : string(1 to 16) := "ACESSO BLOQUEADO";

    signal current_char : character;
begin
    lcd_rw <= '0';
    lcd_e  <= lcd_e_reg;

    -- Lógica Combinacional: Escolhe a mensagem baseada no status da FSM
    process(lcd_status)
    begin
        if lcd_status = "001" then
            msg1 <= OPEN_1; msg2 <= OPEN_2;
        elsif lcd_status = "010" then
            msg1 <= ERR_1;  msg2 <= ERR_2;
        else
            msg1 <= IDLE_1; msg2 <= IDLE_2;
        end if;
    end process;

    -- Máquina de Estados de Escrita no LCD
    process(clk, rst)
    begin
        if rst = '1' then
            state <= POWER_ON;
            timer <= 0;
            char_idx <= 0;
            lcd_rs <= '0';
            lcd_e_reg <= '0';
            lcd_data <= x"00";
        elsif rising_edge(clk) then
            case state is
                
                -- SEQUÊNCIA DE INICIALIZAÇÃO
                when POWER_ON =>
                    lcd_rs <= '0';
                    if timer < DELAY_50MS then timer <= timer + 1;
                    else timer <= 0; state <= INIT_FUNC; end if;

                when INIT_FUNC =>
                    lcd_rs <= '0'; lcd_data <= x"38";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_DISPLAY; end if;

                when INIT_DISPLAY =>
                    lcd_rs <= '0'; lcd_data <= x"0C";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_CLEAR; end if;

                when INIT_CLEAR =>
                    lcd_rs <= '0'; lcd_data <= x"01";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_2MS then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_MODE; end if;

                when INIT_MODE =>
                    lcd_rs <= '0'; lcd_data <= x"06";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= SET_LINE1; end if;

                -- SEQUÊNCIA DE IMPRESSÃO DAS LINHAS
                when SET_LINE1 =>
                    lcd_rs <= '0'; lcd_data <= x"80";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; char_idx <= 0; state <= PRINT_LINE1; end if;

                when PRINT_LINE1 =>
                    lcd_rs <= '1';
                    current_char <= msg1(char_idx + 1);
                    lcd_data <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else
                        timer <= 0;
                        if char_idx = 15 then
                            char_idx <= 0; state <= SET_LINE2;
                        else
                            char_idx <= char_idx + 1;
                        end if;
                    end if;

                when SET_LINE2 =>
                    lcd_rs <= '0'; lcd_data <= x"C0";
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; char_idx <= 0; state <= PRINT_LINE2; end if;

                when PRINT_LINE2 =>
                    lcd_rs <= '1';
                    current_char <= msg2(char_idx + 1);
                    lcd_data <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                    if timer < PULSE_1US then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else
                        timer <= 0;
                        if char_idx = 15 then
                            char_idx <= 0; state <= DELAY_FRAME;
                        else
                            char_idx <= char_idx + 1;
                        end if;
                    end if;

                -- PAUSA PARA EVITAR GLITCHES NO DISPLAY
                when DELAY_FRAME =>
                    lcd_rs <= '0'; lcd_data <= x"00"; lcd_e_reg <= '0';
                    if timer < DELAY_2MS then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= SET_LINE1;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
