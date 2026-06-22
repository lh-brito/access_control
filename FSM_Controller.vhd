library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity FSM_Controller is
    Port ( 
        clk          : in STD_LOGIC;  
        rst          : in STD_LOGIC;  
        key_valid    : in STD_LOGIC;  
        key_code     : in STD_LOGIC_VECTOR(3 downto 0); 
        lock_en      : out STD_LOGIC; 
        led_status   : out STD_LOGIC_VECTOR(1 downto 0); 
        buzzer_out   : out STD_LOGIC;
        lcd_status   : out STD_LOGIC_VECTOR(2 downto 0) 
    );
end FSM_Controller;

architecture Behavioral of FSM_Controller is

    type state_type is (
        IDLE,           
        READING,        
        CHECKING,       
        UNLOCKED,       
        ERROR_STATE,    
        CONFIG_WAIT,    
        CONFIG_NEW      
    );
    signal current_state, next_state : state_type := IDLE;

    type password_array is array (0 to 3) of STD_LOGIC_VECTOR(3 downto 0);
    signal saved_password : password_array := ("0001", "0010", "0011", "0100");
    signal input_buffer   : password_array := (others => "0000");
    
    signal digit_count : integer range 0 to 4 := 0;
    signal timer_count : unsigned(31 downto 0) := (others => '0');
    
    constant TEMPO_ABERTO : unsigned(31 downto 0) := to_unsigned(500000000, 32); 
    constant TEMPO_ERRO   : unsigned(31 downto 0) := to_unsigned(300000000, 32); 

    constant KEY_A_CONFIG : STD_LOGIC_VECTOR(3 downto 0) := "1010"; 
    constant KEY_C_CLEAR  : STD_LOGIC_VECTOR(3 downto 0) := "1100"; 
    constant KEY_D_LOCK   : STD_LOGIC_VECTOR(3 downto 0) := "1101"; 

begin

    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            digit_count <= 0;
            timer_count <= (others => '0');
            saved_password <= ("0001", "0010", "0011", "0100"); 
            
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            if key_valid = '1' then
                if current_state = IDLE or current_state = READING or 
                   current_state = CONFIG_WAIT or current_state = CONFIG_NEW then
                    
                    if key_code = KEY_C_CLEAR then
                        digit_count <= 0; 
                    elsif digit_count < 4 then
                        input_buffer(0) <= input_buffer(1);
                        input_buffer(1) <= input_buffer(2);
                        input_buffer(2) <= input_buffer(3);
                        input_buffer(3) <= key_code;
                        digit_count <= digit_count + 1;
                    end if;
                end if;
            end if;

            if current_state = CONFIG_NEW and digit_count = 4 then
                saved_password <= input_buffer; 
                digit_count <= 0;
            end if;

            if current_state = UNLOCKED or current_state = ERROR_STATE then
                timer_count <= timer_count + 1;
            else
                timer_count <= (others => '0');
            end if;
            
            if current_state = UNLOCKED or current_state = ERROR_STATE or key_code = KEY_D_LOCK then
                 digit_count <= 0;
            end if;
            
        end if;
    end process;

    process(current_state, digit_count, timer_count, key_valid, key_code, input_buffer, saved_password)
    begin
        next_state <= current_state; 

        case current_state is
            when IDLE =>
                if key_valid = '1' then
                    if key_code = KEY_A_CONFIG then
                        next_state <= CONFIG_WAIT;
                    elsif key_code /= KEY_C_CLEAR and key_code /= KEY_D_LOCK then
                        next_state <= READING;
                    end if;
                end if;

            when READING =>
                if key_valid = '1' and key_code = KEY_C_CLEAR then
                    next_state <= IDLE;
                elsif digit_count = 4 then
                    next_state <= CHECKING;
                end if;

            when CHECKING =>
                if input_buffer = saved_password then
                    next_state <= UNLOCKED;
                else
                    next_state <= ERROR_STATE;
                end if;

            when UNLOCKED =>
                if timer_count >= TEMPO_ABERTO or (key_valid = '1' and key_code = KEY_D_LOCK) then
                    next_state <= IDLE;
                end if;

            when ERROR_STATE =>
                if timer_count >= TEMPO_ERRO then
                    next_state <= IDLE;
                end if;

            when CONFIG_WAIT =>
                if key_valid = '1' and key_code = KEY_C_CLEAR then
                    next_state <= IDLE;
                elsif digit_count = 4 then
                    if input_buffer = saved_password then
                        next_state <= CONFIG_NEW;
                    else
                        next_state <= ERROR_STATE;
                    end if;
                end if;

            when CONFIG_NEW =>
                if key_valid = '1' and key_code = KEY_C_CLEAR then
                    next_state <= IDLE;
                elsif digit_count = 4 then
                    next_state <= IDLE; 
                end if;

        end case;
    end process;

    process(current_state, timer_count)
    begin
        lock_en    <= '0';
        buzzer_out <= '0';
        led_status <= "00"; 
        lcd_status <= "000"; 

        case current_state is
            when IDLE | READING =>
                led_status <= "01"; 
                lcd_status <= "000"; 

            when CHECKING =>
                led_status <= "01"; 
                lcd_status <= "000";

            when UNLOCKED =>
                led_status <= "10"; 
                lock_en    <= '1';  
                lcd_status <= "001"; 
                
                if timer_count < to_unsigned(50000000, 32) then 
                    buzzer_out <= '1';
                end if;

            when ERROR_STATE =>
                lcd_status <= "010"; 
                if timer_count(25) = '1' then
                    led_status <= "01"; 
                    buzzer_out <= '1';
                else
                    led_status <= "00";
                    buzzer_out <= '0';
                end if;

            when CONFIG_WAIT =>
                led_status <= "11"; 
                lcd_status <= "011"; 

            when CONFIG_NEW =>
                led_status <= "11"; 
                lcd_status <= "100"; 

        end case;
    end process;

end Behavioral;
