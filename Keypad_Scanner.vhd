library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Keypad_Scanner is
    Port (
        clk       : in  STD_LOGIC; 
        rst       : in  STD_LOGIC; 
        row_in    : in  STD_LOGIC_VECTOR(3 downto 0); 
        col_out   : out STD_LOGIC_VECTOR(3 downto 0); 
        key_valid : out STD_LOGIC; 
        key_code  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Keypad_Scanner;

architecture Behavioral of Keypad_Scanner is

    signal row_sync_1 : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    signal row_sync_2 : STD_LOGIC_VECTOR(3 downto 0) := "1111";

    type scan_state_type is (SCANNING, DEBOUNCE_PRESS, OUTPUT_KEY, WAIT_RELEASE, DEBOUNCE_RELEASE);
    signal scan_state : scan_state_type := SCANNING;

    signal clk_div_count : unsigned(16 downto 0) := (others => '0'); 
    signal tick_1ms      : STD_LOGIC := '0';

    signal debounce_cnt  : integer range 0 to 30 := 0; 
    signal col_index     : integer range 0 to 3 := 0;  
    
    signal current_col   : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    signal current_row   : STD_LOGIC_VECTOR(3 downto 0) := "1111";

begin

    col_out <= current_col;

    process(clk, rst)
    begin
        if rst = '1' then
            row_sync_1 <= "1111";
            row_sync_2 <= "1111";
        elsif rising_edge(clk) then
            row_sync_1 <= row_in;
            row_sync_2 <= row_sync_1; 
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if clk_div_count >= 99999 then 
                clk_div_count <= (others => '0');
                tick_1ms <= '1';
            else
                clk_div_count <= clk_div_count + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            scan_state  <= SCANNING;
            col_index   <= 0;
            current_col <= "1110";
            key_valid   <= '0';
            key_code    <= "0000";
            debounce_cnt <= 0;
            
        elsif rising_edge(clk) then
            if tick_1ms = '1' then
                case scan_state is
                    
                    when SCANNING =>
                        key_valid <= '0';
                        
                        if row_sync_2 /= "1111" then
                            current_row <= row_sync_2;
                            scan_state <= DEBOUNCE_PRESS;
                            debounce_cnt <= 0;
                        else
                            if col_index = 3 then
                                col_index <= 0;
                                current_col <= "1110";
                            else
                                col_index <= col_index + 1;
                                current_col <= current_col(2 downto 0) & current_col(3); 
                            end if;
                        end if;

                    when DEBOUNCE_PRESS =>
                        if debounce_cnt >= 20 then
                            if row_sync_2 = current_row then
                                scan_state <= OUTPUT_KEY; 
                            else
                                scan_state <= SCANNING;   
                            end if;
                        else
                            debounce_cnt <= debounce_cnt + 1;
                        end if;

                    when OUTPUT_KEY =>
                        key_valid <= '1'; 
                        
                        if    current_col = "1110" and current_row = "1110" then key_code <= x"1";
                        elsif current_col = "1101" and current_row = "1110" then key_code <= x"2";
                        elsif current_col = "1011" and current_row = "1110" then key_code <= x"3";
                        elsif current_col = "0111" and current_row = "1110" then key_code <= x"A"; 
                        
                        elsif current_col = "1110" and current_row = "1101" then key_code <= x"4";
                        elsif current_col = "1101" and current_row = "1101" then key_code <= x"5";
                        elsif current_col = "1011" and current_row = "1101" then key_code <= x"6";
                        elsif current_col = "0111" and current_row = "1101" then key_code <= x"B";
                        
                        elsif current_col = "1110" and current_row = "1011" then key_code <= x"7";
                        elsif current_col = "1101" and current_row = "1011" then key_code <= x"8";
                        elsif current_col = "1011" and current_row = "1011" then key_code <= x"9";
                        elsif current_col = "0111" and current_row = "1011" then key_code <= x"C"; 
                        
                        elsif current_col = "1110" and current_row = "0111" then key_code <= x"E"; 
                        elsif current_col = "1101" and current_row = "0111" then key_code <= x"0";
                        elsif current_col = "1011" and current_row = "0111" then key_code <= x"F"; 
                        elsif current_col = "0111" and current_row = "0111" then key_code <= x"D"; 
                        end if;
                        
                        scan_state <= WAIT_RELEASE;

                    when WAIT_RELEASE =>
                        key_valid <= '0'; 
                        if row_sync_2 = "1111" then
                            scan_state <= DEBOUNCE_RELEASE;
                            debounce_cnt <= 0;
                        end if;

                    when DEBOUNCE_RELEASE =>
                        if debounce_cnt >= 20 then
                            scan_state <= SCANNING;
                        else
                            debounce_cnt <= debounce_cnt + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
