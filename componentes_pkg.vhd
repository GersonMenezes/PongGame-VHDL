library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

package componentes_pkg is

		-- Componentes
		component Divisor_frequencia
			 port (
					 CLK: in STD_LOGIC;
					 COUT: out STD_LOGIC;
					 clk_inimigo: out STD_LOGIC
				 );
		end component; 

		component altclk
			PORT (
				inclk0		: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC 
			);
		END component;
		
    	component ps2_keyboard_to_ascii
		  GENERIC(
				clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
				ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
		  PORT(
				clk        : IN  STD_LOGIC;                     --system clock input
				ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
				ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
				ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
				ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
		END component;
		
		component formElements
			port(
				clk,reset: in STD_LOGIC;
				HPixel, VPixel: in integer range 0 to 1280;
				FORM_HSTART	: in integer range 1 to 1280;
				FORM_HEND	: in integer range 1 to 1280;
				FORM_VSTART : in integer range 1 to 1024;
				FORM_VEND	: in integer range 1 to 1024;
				form: out STD_LOGIC
			);
	 end component;
		
end package;