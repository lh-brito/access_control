library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity LCD_Controller is
    Port (
        clk        : in  STD_LOGIC; -- 100 MHz
        rst        : in  STD_LOGIC;
        lcd_status : in  STD_LOGIC_VECTOR(2 downto 0); -- Sinais vindos da FSM
        lcd_rs     : out STD_LOGIC;
        lcd_rw     : out STD_LOGIC;
        lcd_e      : out STD_LOGIC;
        lcd_data   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end LCD_Controller;

architecture Behavioral of LCD_Controller is

    -- Temporizações para LCD (Baseadas em clock de 100MHz = 10ns por ciclo)
    constant CLK_FREQ   : integer := 100000000;
    constant DELAY_50MS : integer := 5000000; -- Inicialização
    constant DELAY_2MS  : integer := 200000;  -- Comandos lentos
    constant DELAY_50US : integer := 5000;    -- Comandos rápidos

    type state_type is (POWER_ON, INIT_FUNC, INIT_DISPLAY, INIT_CLEAR, INIT_MODE, 
                        WRITE_LINE1, WRITE_LINE2, IDLE);
    signal state : state_type := POWER_ON;

    signal timer     : integer range 0 to 10000000 := 0;
    signal char_idx  : integer range 0 to 15 := 0;
    signal lcd_e_reg : STD_LOGIC := '0';
    
    -- Definição das Strings (Mensagens de 16 caracteres)
    constant MSG_IDLE_1 : string(1 to 16) := "CONTR. DE ACESSO";
    constant MSG_IDLE_2 : string(1 to 16) := "DIGITE A SENHA: ";
    
    constant MSG_OPEN_1 : string(1 to 16) := "ACESSO LIBERADO ";
    constant MSG_OPEN_2 : string(1 to 16) := "   BEM-VINDO!   ";
    
    constant MSG_ERR_1  : string(1 to 16) := " SENHA INCORRETA";
    constant MSG_ERR_2  : string(1 to 16) := "ACESSO BLOQUEADO";

    signal current_char : character;

begin

    lcd_rw <= '0'; -- Sempre em modo de escrita
    lcd_e  <= lcd_e_reg;

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

                when POWER_ON =>
                    lcd_rs <= '0';
                    if timer < DELAY_50MS then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= INIT_FUNC;
                    end if;

                when INIT_FUNC =>
                    lcd_rs <= '0';
                    lcd_data <= x"38"; -- Function Set: 8-bit, 2 lines, 5x8 font
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_DISPLAY; end if;

                when INIT_DISPLAY =>
                    lcd_data <= x"0C"; -- Display ON, Cursor OFF, Blink OFF
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_CLEAR; end if;

                when INIT_CLEAR =>
                    lcd_data <= x"01"; -- Clear Display
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_2MS then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= INIT_MODE; end if;

                when INIT_MODE =>
                    lcd_data <= x"06"; -- Entry Mode Set: Increment, No Shift
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; char_idx <= 0; state <= WRITE_LINE1; end if;

                when WRITE_LINE1 =>
                    lcd_rs <= '0';
                    lcd_data <= x"80"; -- Força cursor no início da Linha 1
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then 
                        lcd_e_reg <= '0'; 
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= WRITE_LINE2; -- Simplificado para controle contínuo
                    end if;

                when WRITE_LINE2 =>
                    lcd_rs <= '0';
                    lcd_data <= x"C0"; -- Força cursor no início da Linha 2
                    if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                    elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                    else timer <= 0; state <= IDLE; end if;

                when IDLE =>
                    -- Mapeia a string correta com base no status vindo da FSM
                    if lcd_status = "001" then -- Acesso Liberado
                        if char_idx < 16 then
                            lcd_rs <= '1';
                            current_char <= MSG_OPEN_1(char_idx + 1);
                            lcd_data <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                            -- Lógica de strobe do pino E
                            if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                            elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                            else timer <= 0; char_idx <= char_idx + 1; end if;
                        end if;
                    elsif lcd_status = "010" then -- Erro
                        if char_idx < 16 then
                            lcd_rs <= '1';
                            current_char <= MSG_ERR_1(char_idx + 1);
                            lcd_data <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                            if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                            elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                            else timer <= 0; char_idx <= char_idx + 1; end if;
                        end if;
                    else -- Aguardando senha (IDLE)
                        if char_idx < 16 then
                            lcd_rs <= '1';
                            current_char <= MSG_IDLE_1(char_idx + 1);
                            lcd_data <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                            if timer = 0 then lcd_e_reg <= '1'; timer <= timer + 1;
                            elsif timer < DELAY_50US then lcd_e_reg <= '0'; timer <= timer + 1;
                            else timer <= 0; char_idx <= char_idx + 1; end if;
                        end if;
                    end if;

                    -- Se houver mudança de estado global, reinicia a varredura da escrita
                    if timer = 0 and char_idx = 16 then
                        char_idx <= 0;
                        state <= WRITE_LINE1;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
