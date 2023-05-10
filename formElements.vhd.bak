library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity formElements is
	port(
		clk,reset: in STD_LOGIC;
		HPixel, VPixel: in integer range 0 to 1280;
		FORM_HSTART	: in integer range 1 to 1280;
		FORM_HEND	: in integer range 1 to 1280;
		FORM_VSTART : in integer range 1 to 1024;
		FORM_VEND	: in integer range 1 to 1024;
		form: out STD_LOGIC
	);
end formElements; 

architecture arc of formElements is 

--constant HTOTAL 			: integer := 1688; -- Para que essas constantes?
--constant HSYNC 			: integer := 112;
--constant HBACK_PORCH		: integer := 248;
--constant HACTIVE 			: integer := 1280;
--constant HFRONT_PORCH 	: integer := 48;
--
--constant VTOTAL 			: integer := 1066;
--constant VSYNC 			: integer := 3;
--constant VBACK_PORCH		: integer := 38;
--constant VACTIVE			: integer := 1024;
--constant VFRONT_PORCH 	: integer := 1;

signal 	form_h, form_v: std_logic;

begin

FormHGen : process (clk, reset)
begin
	if reset = '1' then
		form_h <= '0';
	elsif clk'event and clk = '1' then
		if (FORM_HSTART <= HPixel) and (HPixel <= FORM_HEND) then
			form_h <= '1';
		else 
			form_h <= '0';
		end if;
	end if;
end process formHGen;

formVGen : process (clk, reset)
begin
	if reset = '1' then
		form_v <= '0';
	elsif clk'event and clk = '1' then
		if (FORM_VSTART <= VPixel) and (VPixel <= FORM_VEND) then
			form_v <= '1';
		else
			form_v <= '0';
		end if;
	end if;
end process;

--Se esta na linha e coluna, deve aparecer
form <= form_h and form_v;

end arc;