Library IEEE;
use IEEE.std_logic_1164.all;

 entity Divisor_frequencia is
	 port (
		 CLK: in STD_LOGIC;
		 COUT: out STD_LOGIC;
		 clk_inimigo: out STD_LOGIC
		 );
 end Divisor_frequencia; 

 architecture arc_Divider of Divisor_frequencia is 

 constant TIMECONST 	: integer 	:= 	50000;
 signal TIMECONST2 : integer 	:= 	1000000;

 signal count0: integer range 0 to 500000 := 0;
 signal count1: integer range 0 to 100000000 := 0;

 signal D,clk_inimigo_temp: STD_LOGIC := '0';

 begin 	
	 process (CLK,D,clk_inimigo_temp)
	 begin
	 if (CLK'event and CLK = '1') then
		 count0 <= count0 + 1;
		 count1 <= count1 + 1;
		 -- Clock de saida COUT, que ativa os movimentos
	 	 if (count0 = TIMECONST) then
		 	count0 <= 0;
		 	D <= not D;
		 end if;
		 -- sempre que contar ate 100000 aumenta o psrand
	 	 if (count1 = TIMECONST2) then
		 	count1 <= 0;
			clk_inimigo_temp <= not clk_inimigo_temp;
		 end if;
	 end if;

  COUT <= D;
  clk_inimigo <= clk_inimigo_temp;
 end process;

 end arc_Divider;