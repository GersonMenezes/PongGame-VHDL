library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity formDetails is
	port(
		clk,reset: in STD_LOGIC;
		HPixel, VPixel: in integer range 0 to 1280;
		lim_esq, lim_dir, lim_sup: in integer range 1 to 1280;
		points_player1, points_player2 	: integer range 0 to 80;
		form: out STD_LOGIC
	);
end formDetails; 

architecture arc of formDetails is 

signal 	form_borda, form_c: std_logic;
-- Limites dos pontos mostrados no lado esquerdo
constant lim_dir_points: integer := 100;
constant lim_esq_points: integer := 50;
constant lim_sup_points: integer := 400;
constant lim_inf_points: integer := 500;
constant espessura_points: integer := 20;

begin

FormBordaGen : process (clk, reset) 
begin
	if reset = '1' then
		form_borda <= '0';
	elsif clk'event and clk = '1' then
		if ((lim_esq <= HPixel) and (HPixel <= lim_esq + 2) and (VPixel > lim_sup)) then -- Linhas Verticais
			form_borda <= '1';
		elsif ((lim_dir <= HPixel) and ((HPixel <= (lim_dir + 2)) and (VPixel > lim_sup))) then
			form_borda <= '1';
		elsif (lim_sup - 2 <= VPixel) and (VPixel <= lim_sup) then -- Linha Horizontal
			form_borda <= '1';
		else 
			form_borda <= '0';
		end if;
	end if;
end process FormBordaGen;

formPointNumbers : process (clk, reset) 
begin
	if reset = '1' then
		form_c <= '0';
	elsif clk'event and clk = '1' then 
		
		---------- Number 0 -----------
		if (points_player1 = 0) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif ((lim_esq_points <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 1 -----------
		elsif (points_player1 = 1) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 2 -----------
		elsif (points_player1 = 2) then
			if (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points) <= VPixel) and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif ((lim_esq_points <= HPixel) and (HPixel <= lim_esq_points + espessura_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) and (VPixel <= ((lim_inf_points))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 3 -----------
		elsif (points_player1 = 3) then
			if (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 4 -----------
		elsif (points_player1 = 4) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 5 -----------
		elsif (points_player1 = 5) then
			if (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			elsif (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 6 -----------
		elsif (points_player1 = 6) then
			if (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif ((lim_esq_points <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			elsif (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 7 -----------
		elsif (points_player1 = 7) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 8 -----------
		elsif (points_player1 = 8) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif ((lim_esq_points <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
					---------- Number 9 -----------
		elsif (points_player1 = 9) then
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points) <= HPixel) and (HPixel <= (lim_esq_points + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
					
		---------- Number indefinied -----------
		else 
			if (((lim_dir_points - espessura_points) <= HPixel) and (HPixel <= lim_dir_points) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		end if;
	end if;
end process;

--Se esta na linha e coluna, deve aparecer
form <= form_borda or form_c;

end arc;