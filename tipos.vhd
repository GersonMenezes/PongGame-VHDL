library ieee; 

USE IEEE.std_logic_1164.all; 
USE IEEE.std_logic_arith.all; 
USE IEEE.std_logic_unsigned.all;

package tipos is
	type ArrayInteger1280 is array (39 downto 0) of integer range 1 to 1280;
	type ArrayInteger1024 is array (39 downto 0) of integer range 1 to 1024;
	
end package;