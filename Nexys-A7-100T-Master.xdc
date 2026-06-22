## Arquivo de Restrições (Constraints) - Projeto Controle de Acesso
## Placa: Nexys A7-100T

## ------------------------------------------------------------------------
## 1. Sinal de Clock Nativo (100 MHz)
## ------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## ------------------------------------------------------------------------
## 2. Botão de Reset (Botão Central - BTNC)
## ------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { rst }]; 

## ------------------------------------------------------------------------
## 3. Saídas Visuais, Sonoras e Potência (Mapeadas para a Porta Pmod JD - Protoboard)
## ------------------------------------------------------------------------
# Pino 1 do Pmod JD (Cabo para o IN do Módulo Relé)
set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { lock_en }];        

# Pino 2 do Pmod JD (Cabo para o positivo do Buzzer)
set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { buzzer_out }];    

# Pino 3 do Pmod JD (Cabo para o Anodo do LED Vermelho)
set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { led_status[0] }]; 

# Pino 4 do Pmod JD (Cabo para o Anodo do LED Verde)
set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { led_status[1] }];

## ------------------------------------------------------------------------
## 4. Teclado Matricial 4x4 (Conectado na Porta Pmod JA)
## ------------------------------------------------------------------------
# COLUNAS (Pinos de saída da FPGA varrendo o GND - Pinos 1 a 4 do Pmod JA)
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { col_out[3] }]; 
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { col_out[2] }]; 
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { col_out[1] }]; 
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { col_out[0] }]; 

# LINHAS (Pinos de entrada da FPGA - Pinos 7 a 10 do Pmod JA)
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { row_in[3] }]; 
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { row_in[2] }]; 
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { row_in[1] }]; 
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { row_in[0] }];

## ------------------------------------------------------------------------
## 5. Display LCD 16x2 (Controle no Pmod JB e Dados no Pmod JC)
## ------------------------------------------------------------------------
# Sinais de Controle (Pmod JB - Pinos 1 a 3)
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }]; # Pino JB1
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { lcd_rw }]; # Pino JB2
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { lcd_e  }]; # Pino JB3

# Barramento de Dados de 8-bits (Pmod JC Inteiro)
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[0] }]; # Pino JC1
set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[1] }]; # Pino JC2
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[2] }]; # Pino JC3
set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[3] }]; # Pino JC4
set_property -dict { PACKAGE_PIN E7    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[4] }]; # Pino JC7
set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[5] }]; # Pino JC8
set_property -dict { PACKAGE_PIN J4    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[6] }]; # Pino JC9
set_property -dict { PACKAGE_PIN E6    IOSTANDARD LVCMOS33 } [get_ports { lcd_data[7] }]; # Pino JC10
