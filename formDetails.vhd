library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity formDetails is
	port(
		clk,reset: in STD_LOGIC;
		HPixel, VPixel: in integer range 0 to 1280;
		lim_esq, lim_dir, lim_sup: in integer range 1 to 1280;
		points_player1, points_player2 	: integer range 0 to 9;
		form: out STD_LOGIC
	);
end formDetails; 

architecture arc of formDetails is 

signal 	form_borda, form_c, form_c2, form_t: std_logic;
constant espessura_points: integer := 20; -- Espessura dos pontos

-- Limites dos pontos mostrados no lado esquerdo, pontos do player1 --
constant lim_dir_points1: integer := 125;
constant lim_esq_points1: integer := 75;
constant lim_sup_points: integer := 400;
constant lim_inf_points: integer := 500;

-- Limites dos pontos mostrados no lado direito, pontos do player2, altura superior e inferior é a mesma do player1 --
constant lim_dir_points2: integer := 1230;
constant lim_esq_points2: integer := 1180;

-- Parâmetros para Título do Jogo
constant largura_letra		: integer := 50;
constant altura_letra		: integer := 100;
constant stroke_thickness	: integer := 10;
constant title_Hstart		: integer := 50;
constant title_Vstart		: integer := 25;
constant space_size			: integer := 15;
constant title_Vend		   : integer := title_Vstart + altura_letra;
constant next_character			: integer := space_size + largura_letra;
constant character_Hmiddle	: integer := ((2*title_Vstart) + altura_letra)/2;
constant title_Vmiddle : integer := (((2*title_Hstart) + largura_letra)/2) - (stroke_thickness/2);

begin

-- Este processo forma as bordas do jogo
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

-- Este processos forma os números de pontos
formPointNumbers : process (clk, reset) 
begin
	if reset = '1' then
		form_c <= '0';
	elsif clk'event and clk = '1' then 
		
		---------- Number 0 -----------
		if (points_player1 = 0) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif ((lim_esq_points1 <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 1 -----------
		elsif (points_player1 = 1) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 2 -----------
		elsif (points_player1 = 2) then
			if (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points) <= VPixel) and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif ((lim_esq_points1 <= HPixel) and (HPixel <= lim_esq_points1 + espessura_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) and (VPixel <= ((lim_inf_points))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 3 -----------
		elsif (points_player1 = 3) then
			if (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 4 -----------
		elsif (points_player1 = 4) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 5 -----------
		elsif (points_player1 = 5) then
			if (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			elsif (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 6 -----------
		elsif (points_player1 = 6) then
			if (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif ((lim_esq_points1 <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			elsif (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
		---------- Number 7 -----------
		elsif (points_player1 = 7) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			else
				form_c <= '0';
			end if;
		
		---------- Number 8 -----------
		elsif (points_player1 = 8) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif ((lim_esq_points1 <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
			
					---------- Number 9 -----------
		elsif (points_player1 = 9) then
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		else 
			if (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			else
				if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c <= '1';
				elsif ((lim_esq_points1 <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
							and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
						form_c <= '1';
				elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c <= '1';
				elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
						and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
					form_c <= '1';
				else
					form_c <= '0';
				end if;
			end if;
		end if;
			
				---------- Number 0 Player 2 -----------
		if (points_player2 = 0) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c2 <= '1';
			elsif ((lim_esq_points2 <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
		---------- Number 1 Player 2 -----------
		elsif (points_player2 = 1) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
		
		---------- Number 2 -----------
		elsif (points_player2 = 2) then
			if (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c2 <= '1';
			elsif (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points) <= VPixel) and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif ((lim_esq_points2 <= HPixel) and (HPixel <= lim_esq_points2 + espessura_points) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) and (VPixel <= ((lim_inf_points))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
		---------- Number 3 Player 2 -----------
		elsif (points_player2 = 3) then
			if (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c2 <= '1';
			elsif (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
		
		---------- Number 4 Player 2 -----------
		elsif (points_player2 = 4) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
		---------- Number 5 Player 2 -----------
		elsif (points_player2 = 5) then
			if (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			elsif (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
		---------- Number 6 Player 2 -----------
		elsif (points_player2 = 6) then
			if (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c2 <= '1';
			elsif ((lim_esq_points2 <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			elsif (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel)) and (VPixel <= lim_inf_points)) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
		---------- Number 7 Player 2 -----------
		elsif (points_player2 = 7) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
		
		---------- Number 8 Player 2 -----------
		elsif (points_player2 = 8) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c2 <= '1';
			elsif ((lim_esq_points2 <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
					form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
			
			---------- Number 9 Player 2 -----------
		elsif (points_player2 = 9) then
			if (((lim_dir_points2 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points2) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
						and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
					form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= lim_dir_points2) 
					and (((lim_sup_points + (2*espessura_points)) <= VPixel) 
					and (VPixel <= ((lim_sup_points + (3*espessura_points)))))) then
				form_c2 <= '1';
			elsif (((lim_esq_points2) <= HPixel) and (HPixel <= (lim_esq_points2 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= (lim_inf_points - (2*espessura_points))))) then
				form_c2 <= '1';
			else
				form_c2 <= '0';
			end if;
					
		---------- Number indefinied Player 2  -----------
		else 
			if (((lim_dir_points1 - espessura_points) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif ((lim_esq_points1 <= HPixel) and (HPixel <= (lim_esq_points1 + espessura_points)) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_inf_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and ((lim_sup_points <= VPixel) and (VPixel <= lim_sup_points + espessura_points))) then
				form_c <= '1';
			elsif (((lim_esq_points1) <= HPixel) and (HPixel <= lim_dir_points1) 
					and (((lim_sup_points + (4*espessura_points)) <= VPixel) and (VPixel <= (lim_inf_points)))) then
				form_c <= '1';
			else
				form_c <= '0';
			end if;
		end if;
	end if;
end process;


FormLetreiro : process (clk, reset) 
begin
	if reset = '1' then
		form_t <= '0';
	else
		------- Letra P ---------
		if ((title_Hstart <= HPixel) and (HPixel <= (title_Hstart + stroke_thickness)) 
			and ( title_Vstart <= VPixel) and (VPixel <= title_Vend)) then
			form_t <= '1';
		elsif ((title_Hstart <= HPixel) and (HPixel <= (title_Hstart + largura_letra)) 
			and ( title_Vstart <= VPixel) and (VPixel <= (title_Vstart + stroke_thickness))) then
			form_t <= '1';
		elsif (((title_Hstart + (largura_letra - stroke_thickness)) <= HPixel) and (HPixel <= (title_Hstart + (largura_letra))) 
			and ( title_Vstart <= VPixel) and (VPixel <= (title_Vmiddle))) then
			form_t <= '1';
		elsif ((title_Hstart <= HPixel) and (HPixel <= (title_Hstart + largura_letra)) 
			and ( title_Vmiddle <= VPixel) and (VPixel <= (title_Vmiddle + stroke_thickness))) then
			form_t <= '1';
		
		------- Letra O ---------
		elsif (((title_Hstart + next_character) <= HPixel) and ((HPixel) <=  (title_Hstart + next_character + (stroke_thickness))) 
			and ( title_Vstart <= VPixel) and (VPixel <= title_Vend)) then
			form_t <= '1';
		elsif ((title_Hstart  + next_character <= HPixel) and (HPixel <= (title_Hstart + next_character + largura_letra)) 
			and ( title_Vstart <= VPixel) and (VPixel <= (title_Vstart + stroke_thickness))) then
			form_t <= '1';
		elsif ((((title_Hstart + next_character +(largura_letra - stroke_thickness)) <= HPixel)) and (HPixel <=  title_Hstart + next_character + largura_letra) 
			and ((title_Vstart <= VPixel) and (VPixel <= title_Vend))) then
			form_t <= '1';
		elsif ((title_Hstart  + next_character <= HPixel) and (HPixel <= (title_Hstart  + next_character + largura_letra)) 
			and ( (title_Vend - stroke_thickness)  <= VPixel) and (VPixel <= (title_Vend))) then
			form_t <= '1';
			
					------- Letra N ---------
		elsif (((title_Hstart + (2*next_character)) <= HPixel) and ((HPixel) <=  (title_Hstart + (2*next_character) + (stroke_thickness))) 
			and ( title_Vstart <= VPixel) and (VPixel <= title_Vend)) then
			form_t <= '1';
		elsif ((((title_Hstart  + (2*next_character)) - 4) <= HPixel) and (HPixel <= (title_Hstart + (2*next_character) + largura_letra)) 
			and ( title_Vstart <= VPixel) and (VPixel <= (title_Vstart + stroke_thickness))) then
			form_t <= '1';
		elsif ((((title_Hstart + (2*next_character) +(largura_letra - stroke_thickness)) <= HPixel)) and (HPixel <=  title_Hstart + (2*next_character) + largura_letra) 
			and ((title_Vstart <= VPixel) and (VPixel <= title_Vend))) then
			form_t <= '1';
			
								------- Letra G ---------
		elsif (((title_Hstart + (3*next_character)) <= HPixel) and ((HPixel) <=  (title_Hstart + (3*next_character) + (stroke_thickness))) 
			and ( title_Vstart <= VPixel) and (VPixel <= title_Vend)) then
			form_t <= '1';
		elsif ((title_Hstart  + (3*next_character) <= HPixel) and (HPixel <= (title_Hstart + (3*next_character) + largura_letra)) 
			and ( title_Vstart <= VPixel) and (VPixel <= (title_Vstart + stroke_thickness))) then
			form_t <= '1';
		elsif ((((title_Hstart + (3*next_character) +(largura_letra - stroke_thickness)) <= HPixel)) and (HPixel <=  title_Hstart + (3*next_character) + largura_letra) 
			and ((title_Vmiddle <= VPixel) and (VPixel <= title_Vend))) then
			form_t <= '1';
		elsif ((title_Hstart + 30 + (3*next_character) <= HPixel) and (HPixel <= (title_Hstart  + (3*next_character) + largura_letra)) 
			and (title_Vmiddle <= VPixel) and (VPixel <= (title_Vmiddle + stroke_thickness))) then
			form_t <= '1';	
		elsif ((title_Hstart  + (3*next_character) <= HPixel) and (HPixel <= (title_Hstart  + (3*next_character) + largura_letra)) 
			and ((title_Vend - stroke_thickness)  <= VPixel) and (VPixel <= (title_Vend))) then
			form_t <= '1';
			
			
		else
			form_t <= '0';
		end if;
	end if;
end process FormLetreiro;
-- Se esta na linha e coluna, deve aparecer
form <= form_borda or form_c or form_c2 or form_t;

end arc;