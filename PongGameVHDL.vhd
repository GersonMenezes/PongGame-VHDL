----------------------------------------------------------------------------------------------------------------
-- Pong VHDL
-- Autor: Gerson Leite de Menezes
-- Professor: Rafael Iankowski Soares
-- Esse jogo faz parte de um trabalho final da disciplina de Sistemas Digitais Avançados e visa consolidar
-- através do jogo conhecimentos e técnicas de sistemas digitais aprendido ao longo do semestre letivo. 
-- Para mais detalhes leia o README.md. Para futuras atualizações e mais detalhes entrar no link do 
-- github: https://github.com/GersonMenezes/PongGame-VHDL onde o jogo e o README será atualizado. 
-- Contato: gldmenezes@inf.ufpel.edu.br.
--
-- O trabalho implementa o jogo do PONG. O Pong é um jogo eletrônico clássico de arcade, lançado em 1972 pela Atari.
-- É um jogo de simulação de tênis de mesa, no qual os jogadores movem as paletas para acertar uma bola de volta e 
-- tentam marcar pontos no campo do oponente. O jogo tornou-se um sucesso instantâneo e ajudou a impulsionar o 
-- desenvolvimento de jogos eletrônicos.
-- Esse jogo foi escrito em VHDL e executado no DE2 Board da Altera. 
-- Foi conectado ao dispositivo um monitor através de um cabo VGA e um teclado com conexão PS2.
-----------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.componentes_pkg.all;

entity PongGameVHDL is
port (
	reset : in std_logic;
	clk: in std_logic; -- 135 MHz
	clk_27: in std_logic;
	key0, key1, key2, key3 : in std_logic; -- Pushbutton from DE2 altera FPGA, They are to Player 2 control, 0 to up, 1 to down. More details in README
	VGA_CLK, -- Dot clock to DAC
	VGA_HS, -- Active-Low Horizontal Sync
	VGA_VS, -- Active-Low Vertical Sync
	VGA_BLANK, -- Active-Low DAC blanking control
	VGA_SYNC : out std_logic; -- Active-Low DAC Sync on Green
	VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
	ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
	ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
	ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
	ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) --ASCII value
);
end PongGameVHDL;

architecture rtl of PongGameVHDL is

type ArrayInteger1280 is array (39 downto 0) of integer range 1 to 1280;
type ArrayInteger1024 is array (39 downto 0) of integer range 1 to 1024;

-------------------------
-- Parametros de video --
-------------------------
-- original do barth
constant HTOTAL 			: integer := 1688;	
constant HSYNC 			: integer := 112;	
constant HBACK_PORCH		: integer := 248;	
constant HACTIVE 			: integer := 1280;	-- Porção horizontal usada da tela
constant HFRONT_PORCH 	: integer := 48;	
constant HEND 				: integer := 1280;	
constant HMIDDLE 			: integer := 640; 	-- Meio da tela na horizontal

constant VTOTAL 			: integer := 1066;	
constant VSYNC 			: integer := 3;		
constant VBACK_PORCH		: integer := 38;	
constant VACTIVE			: integer := 1024;	-- Porção vertical usada da tela 
constant VFRONT_PORCH 	: integer := 1;		
constant VEND 				: integer := 1024;	
constant VMIDDLE 			: integer := 512;  	-- Meio da tela na Vertical

-----------------------------------------
----- Parametros Gerais do Jogo ---------
-----------------------------------------
	signal points_player1, points_player2 	: integer range 0 to 9 := 0;
	signal game_level : integer range 1 to 4 := 1; 
	signal veloci_bola   : integer range 1 to 15 := 5; 
	signal veloci_barras : integer range 1 to 15 := 5; 
	signal toques_cont : integer range 0 to 5 := 0; -- Toques seguidos sem gol. Se chegar a 5 sobe o nível de dificuldade
	
	-- Limites do quadro principal do jogo, o limite inferior será o próprio VHEND
	constant lim_esq_pong: integer := 200; 
	constant lim_dir_pong: integer := 1080; 
	constant lim_sup_pong: integer := 150;
	signal bordas_out    : std_LOGIC;
	
------------------------
-- Parametros do bola --
------------------------
	signal bola_HSTART 	: integer range 1 to 1280 := HMIDDLE;
	signal bola_HEND 		: integer range 1 to 1290 := HMIDDLE+10;
	signal bola_VSTART	: integer range 1 to 1034 := VMIDDLE;
	signal bola_VEND		: integer range 1 to 1044 := VMIDDLE+10;
	signal bola_out		: std_LOGIC := '0';
	signal bola_direction: integer range 1 to 10 := 1;	
------------------------
-- Parametros do barra1 --
------------------------
	signal barra1_HSTART 	: integer range 1 to 1280 := 1;
	signal barra1_HEND 		: integer range 1 to 1280 := 11;
	signal barra1_VSTART	   : integer range 1 to 1024 := 500;
	signal barra1_VEND		: integer range 1 to 1024 := 650;
	signal barra1_out			: std_LOGIC := '0'; -- Se '1', posição coincide com pixel da vez na tela e dá imagem
------------------------
-- Parametros do barra2 --
------------------------
	signal barra2_HSTART 	: integer range 1 to 1280 := 1270;
	signal barra2_HEND 		: integer range 1 to 1280 := 1280;
	signal barra2_VSTART	   : integer range 1 to 1024 := 500;
	signal barra2_VEND		: integer range 1 to 1024 := 650;
	signal barra2_out			: std_LOGIC := '0';
			
-- clock de movimento(quadrado e retangulo), aumenta a cada ponto.
	signal movclk, countclk, clk_pong: STD_LOGIC;
-- Horizontal position (0-1667)
	signal HCount : integer range 0 to 1688 := 0;
-- Vertical position (0-1065)
	signal VCount : integer range 0 to 1066 := 0;
-- Flags de sincronizacao do VGA
	signal vga_hblank, vga_hsync, vga_vblank, vga_vsync : std_logic;
-- Variaveis do teclado
	signal temp_ps2_code_new : STD_LOGIC;
	signal temp_ps2_code     : STD_LOGIC_VECTOR(6 DOWNTO 0); 
-- Coordenadas do Pixel da vez para ser atualizado na tela
	signal HPixel, VPixel: integer range 0 to 1280:=0;
	

begin
CLKM_MAKING: divisor_frequencia port map(countclk, movclk, clk_pong);

CLKM_M: altclk port map(clk_27, countclk);

teclado : ps2_keyboard_to_ascii port map(clk,ps2_clk,ps2_data,temp_ps2_code_new,temp_ps2_code);

barra_1: formElements port map(countclk, reset, HPixel, VPixel, barra1_hstart, barra1_hend, barra1_vstart, barra1_vend, barra1_out);

barra_2: formElements port map(countclk, reset, HPixel, VPixel, barra2_hstart, barra2_hend, barra2_vstart, barra2_vend, barra2_out);

bola: formElements port map(countclk, reset, HPixel, VPixel, bola_hstart, bola_hend, bola_vstart, bola_vend, bola_out);

bordas: formDetails port map(countclk, reset, HPixel, VPixel, lim_esq_pong, lim_dir_pong, lim_sup_pong, points_player1, points_player2, bordas_out);

HCounter: process (countclk, reset) -- Qual pix será modificado na tela
begin
	if reset = '1' then
		Hcount <= 0;
		VCount <= 0;
		vga_hsync <= '1';
		vga_vsync <= '1';
	elsif countclk'event and countclk = '1' then
		if Hcount < HTOTAL-1 then
			Hcount <= Hcount+1;
		ELSE
			Hcount <= 0;
			if VCount < Vtotal-1 then
				VCount <= VCount+1;
			else
				VCount <= 0;
			end if;
		end if;
		
		if (Hcount >= HSYNC + HBACK_PORCH) then
			Hpixel <= Hpixel + 1;
		else
			Hpixel <= 0;
		end if;
		
		if (VCount >= VSYNC + VBACK_PORCH) then
			VPixel <= VCount - (VSYNC+VBACK_PORCH);
		else
			Vpixel <= 0;
		end if;
		
		if Hcount = HTOTAL - 1 then
			vga_hsync <= '1';
		elsif Hcount = HSYNC - 1 then
			vga_hsync <= '0';
		end if;
		
		if VCount = VTOTAL - 1 then
			vga_vsync <= '1';
		elsif VCount = VSYNC - 1 then
			vga_vsync <= '0';
		end if;
	end if;
end process;

movimenta_barra1: process(clk_pong)
begin
	if reset='1' then
		barra1_HSTART <= lim_esq_pong;
		barra1_HEND <= lim_esq_pong + 10;
		barra1_VSTART <= 500;
		barra1_VEND <= 650;
	else
		if (clk_pong'event and clk_pong='1') then
			-- MOVIMENTA a barra 1
			if((temp_ps2_code_new = '1' and temp_ps2_code= "1100001") and (barra1_VEND < VEND)) then -- a (down)
				barra1_VEND <= barra1_VEND + veloci_barras;
  				barra1_VSTART <= barra1_VSTART + veloci_barras;
			elsif((temp_ps2_code_new = '1' and temp_ps2_code= "1100100") and (barra1_VSTART > lim_sup_pong)) then -- d (up)
				barra1_VEND <= barra1_VEND - veloci_barras;
  				barra1_VSTART <= barra1_VSTART - veloci_barras;
			end if;
		end if;
	end if;
end process;

movimenta_barra2: process(clk_pong)
begin
	if reset='1' then
		barra2_HSTART <= lim_dir_pong - 10;
		barra2_HEND <= lim_dir_pong;
		barra2_VSTART <= 500;
		barra2_VEND <= 650;
	else
		if (clk_pong'event and clk_pong='1') then
			--Movimenta a barra 2
			if((key2  = '0' or key3 = '0') and (barra2_VEND < VEND)) then -- key2 or key3 (down) (Pushbutton)
				barra2_VEND <= barra2_VEND + veloci_barras;
  				barra2_VSTART <= barra2_VSTART + veloci_barras;
			elsif((key0 = '0' or key1 = '0') and (barra2_VSTART > lim_sup_pong)) then -- key0 or key1 (up) (Pushbutton)
				barra2_VEND <= barra2_VEND - veloci_barras;
  				barra2_VSTART <= barra2_VSTART - veloci_barras;
			end if;
		end if;
	end if;
end process;

game_level_process: process(game_level)
begin
	if (game_level = 1) then
		veloci_bola  <= 5; 
		veloci_barras <= 5; 
	elsif (game_level = 2) then
		veloci_bola  <= 7; 
		veloci_barras <= 7;
	elsif (game_level = 3) then
		veloci_bola  <= 9; 
		veloci_barras <= 9;
	elsif (game_level = 4) then
		veloci_bola  <= 11; 
		veloci_barras <= 11;
	end if;

end process;

movimenta_bola: process(clk_pong)
begin
	if reset='1' then
		bola_HSTART <= 501;
		bola_HEND <= 511;
		bola_VSTART <= 500;
		bola_VEND <= 510;
		bola_direction <= 1;
		points_player1 <= 0;
		points_player2 <= 0;
		game_level <= 1;
	else
		if (clk_pong'event and clk_pong='1') then
			
			if((toques_cont = 5)) then -- Aumenta nível de dificuladade
				if(game_level /= 4) then
					game_level <= game_level + 1;
					toques_cont <= 0;
				end if;
			end if;
			
			if(points_player1 = 10) then -- Jogador venceu
				points_player1 <= 0;
				game_level <= 1;
			elsif(points_player2 = 10) then
				points_player2 <= 0;
				game_level <= 1;
			end if;
			----------------------------------------------------------
			--- Bola indo para à direita, direções 1, 2, 3, 9 e 10 ---
			----------------------------------------------------------
			
			------------- Direção 1 --------------
			case bola_direction is
				when 1 => -- Direção de 0° ou 360°
					bola_HSTART <= bola_HSTART + veloci_bola;
					bola_HEND <= bola_HEND + veloci_bola;
					if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
						and (bola_VSTART <= barra2_VEND)) and (key2 = '0' or key3 = '0')) then
						bola_direction <= 7;
						toques_cont <= toques_cont + 1;
					elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
						and (bola_VSTART <= barra2_VEND)) and (key0 = '0' or key1 = '0')) then
						bola_direction <= 5;
						toques_cont <= toques_cont + 1;
					elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
						and (bola_VSTART <= barra2_VEND))) then
						--bola_direction <= 5;
						bola_direction <= 6;
						toques_cont <= toques_cont + 1;
					elsif(bola_HEND >= lim_dir_pong) then -- Jogador 1 fez ponto
						bola_direction <= 1;
						points_player1 <= points_player1 + 1; 
						bola_HSTART <= HMIDDLE-10;
						bola_HEND <= HMIDDLE;
						bola_VSTART <= VMIDDLE;
						bola_VEND <= VMIDDLE+10;
						toques_cont <= 0;
					end if;
			
			------------ Direção 2 --------------
				when 2 => -- Direção de 30°
					bola_HSTART <= bola_HSTART + veloci_bola + 1;
					bola_HEND <= bola_HEND + veloci_bola  + 1;
					bola_VSTART <= bola_VSTART - veloci_bola;
					bola_VEND <= bola_VEND - veloci_bola;
					if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
						and (bola_VSTART <= barra2_VEND)) and (key2 = '0' or key3 = '0')) then
						bola_direction <= 6;
						toques_cont <= toques_cont + 1;
					elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
						and (bola_VSTART <= barra2_VEND)) and (key0 = '0' or key1 = '0')) then
						bola_direction <= 4;
						toques_cont <= toques_cont + 1;
					elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
						and (bola_VSTART <= barra2_VEND))) then
						bola_direction <= 5;
						toques_cont <= toques_cont + 1;
					elsif(bola_HEND >= lim_dir_pong) then -- Jogador 1 fez ponto
						bola_direction <= 1;
						points_player1 <= points_player1 + 1; 
						bola_HSTART <= HMIDDLE-10;
						bola_HEND <= HMIDDLE;
						bola_VSTART <= VMIDDLE;
						bola_VEND <= VMIDDLE+10;
						toques_cont <= 0;
					elsif(bola_VSTART <= lim_sup_pong) then -- Bola tocou em cima
						bola_direction <= 10;
					end if;
				
				------------ Direção 3 --------------
					when 3 => -- Direção de 60°
						bola_HSTART <= bola_HSTART + veloci_bola;
						bola_HEND <= bola_HEND + veloci_bola;
						bola_VSTART <= bola_VSTART - veloci_bola - 1;
						bola_VEND <= bola_VEND - veloci_bola - 1;
						if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
							and (bola_VSTART <= barra2_VEND)) and (key2 = '0' or key3 = '0')) then
							bola_direction <= 5;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
							and (bola_VSTART <= barra2_VEND)) and (key0 = '0' or key1 = '0')) then
							bola_direction <= 4;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
							and (bola_VSTART <= barra2_VEND))) then
							bola_direction <= 4;
							toques_cont <= toques_cont + 1;
						elsif(bola_HEND >= lim_dir_pong) then -- Jogador 1 fez ponto
							bola_direction <= 1;
							points_player1 <= points_player1 + 1; 
							bola_HSTART <= HMIDDLE-10;
							bola_HEND <= HMIDDLE;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VSTART <= lim_sup_pong) then -- Bola tocou em cima
							bola_direction <= 9;
						end if;
					
			------------ Direção 9 --------------
					when 9 => -- Direção de 300°
						bola_HSTART <= bola_HSTART + veloci_bola;
						bola_HEND <= bola_HEND + veloci_bola;
						bola_VSTART <= bola_VSTART + veloci_bola + 1;
						bola_VEND <= bola_VEND + veloci_bola + 1;
						if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
							and (bola_VSTART <= barra2_VEND)) and (key2 = '0' or key3 = '0')) then
							bola_direction <= 8;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
							and (bola_VSTART <= barra2_VEND)) and (key0 = '0' or key1 = '0')) then
							bola_direction <= 7;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
							and (bola_VSTART <= barra2_VEND))) then
							bola_direction <= 8;
							toques_cont <= toques_cont + 1;
						elsif(bola_HEND >= lim_dir_pong) then -- Jogador 1 fez ponto
							bola_direction <= 1;
							points_player1 <= points_player1 + 1; 
							bola_HSTART <= HMIDDLE-10;
							bola_HEND <= HMIDDLE;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VEND >= VEND) then -- Bola tocou em baixo
							bola_direction <= 3;
						end if;
			
			------------ Direção 10 --------------
					when 10 => -- Direção de 330°
						bola_HSTART <= bola_HSTART + veloci_bola + 1;
						bola_HEND <= bola_HEND + veloci_bola + 1;
						bola_VSTART <= bola_VSTART + veloci_bola;
						bola_VEND <= bola_VEND + veloci_bola;
						if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 descendo)
							and (bola_VSTART <= barra2_VEND)) and (key2 = '0' or key3 = '0')) then
							bola_direction <= 8;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 subindo)
							and (bola_VSTART <= barra2_VEND)) and (key0 = '0' or key1 = '0')) then
							bola_direction <= 6;
							toques_cont <= toques_cont + 1;
						elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 parada)
							and (bola_VSTART <= barra2_VEND))) then
							bola_direction <= 7;
							toques_cont <= toques_cont + 1;
						elsif(bola_HEND >= lim_dir_pong) then -- Jogador 1 fez ponto
							bola_direction <= 1;
							points_player1 <= points_player1 + 1; 
							bola_HSTART <= HMIDDLE-10;
							bola_HEND <= HMIDDLE;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VEND >= VEND) then -- Bola tocou em baixo
							bola_direction <= 2;
						end if;
						
			----------------------------------------------------------
			---- Bola indo para esquerda, direções 4, 5, 6, 7 e 8 ----
			----------------------------------------------------------
			
			------------- Direção 4, 120° --------------
					when 4 =>
						bola_HSTART <= bola_HSTART - veloci_bola;
						bola_HEND <= bola_HEND - veloci_bola;
						bola_VSTART <= bola_VSTART - veloci_bola - 1;
						bola_VEND <= bola_VEND - veloci_bola -1;
						if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100001")) then 
							bola_direction <= 2;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100100")) then 
							bola_direction <= 3;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
							and (bola_VSTART <= barra1_VEND))) then 
							bola_direction <= 3;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= lim_esq_pong) then -- Jogador 2 fez ponto
							bola_direction <= 6;
							points_player2 <= points_player2 + 1; 
							bola_HSTART <= HMIDDLE;
							bola_HEND <= HMIDDLE+10;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VSTART <= lim_sup_pong) then -- Tocou no limite superior
							bola_direction <= 8;
						end if;
				
			------------- Direção 5, 120° --------------
					when 5 =>
						bola_HSTART <= bola_HSTART - veloci_bola - 1;
						bola_HEND <= bola_HEND - veloci_bola - 1;
						bola_VSTART <= bola_VSTART - veloci_bola;
						bola_VEND <= bola_VEND - veloci_bola;
						if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100001")) then 
							bola_direction <= 1;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' 
							and (temp_ps2_code= "1100100"))) then 
							bola_direction <= 3;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
							and (bola_VSTART <= barra1_VEND))) then 
							bola_direction <= 2;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= lim_esq_pong) then -- Jogador 2 fez ponto
							bola_direction <= 6;
							points_player2 <= points_player2 + 1; 
							bola_HSTART <= HMIDDLE;
							bola_HEND <= HMIDDLE+10;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VSTART <= lim_sup_pong) then -- Tocou no limite superior
							bola_direction <= 7;
						end if;
				
			------------- Direção 6, 180° --------------
					when 6 =>
						bola_HSTART <= bola_HSTART - veloci_bola ;
						bola_HEND <= bola_HEND - veloci_bola;
						if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100001")) then 
							bola_direction <= 10;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100100")) then 
							bola_direction <= 2;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
							and (bola_VSTART <= barra1_VEND))) then 
							-- bola_direction <= 2;
							bola_direction <= 1;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= lim_esq_pong) then -- Jogador 2 fez ponto
							bola_direction <= 6;
							points_player2 <= points_player2 + 1; 
							bola_HSTART <= HMIDDLE;
							bola_HEND <= HMIDDLE+10;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						end if;
				
				------------- Direção 7, 210° --------------
					when 7 =>
						bola_HSTART <= bola_HSTART - veloci_bola - 1;
						bola_HEND <= bola_HEND - veloci_bola - 1;
						bola_VSTART <= bola_VSTART + veloci_bola;
						bola_VEND <= bola_VEND + veloci_bola;
						if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100001")) then 
							bola_direction <= 9;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100100")) then 
							bola_direction <= 1;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
							and (bola_VSTART <= barra1_VEND))) then 
							bola_direction <= 10;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= lim_esq_pong) then -- Jogador 2 fez ponto
							bola_direction <= 6;
							points_player2 <= points_player2 + 1; 
							bola_HSTART <= HMIDDLE;
							bola_HEND <= HMIDDLE+10;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VEND >= VEND) then -- Tocou no limite inferior
							bola_direction <= 5;
						end if;
				
			------------- Direção 8, 240° --------------
					when 8 =>
						bola_HSTART <= bola_HSTART - veloci_bola;
						bola_HEND <= bola_HEND - veloci_bola;
						bola_VSTART <= bola_VSTART + veloci_bola + 1;
						bola_VEND <= bola_VEND + veloci_bola + 1;
						if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100001")) then 
							bola_direction <= 9;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
							and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1100100")) then 
							bola_direction <= 10;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
							and (bola_VSTART <= barra1_VEND))) then 
							bola_direction <= 9;
							toques_cont <= toques_cont + 1;
						elsif(bola_HSTART <= lim_esq_pong) then -- Jogador 2 fez ponto
							bola_direction <= 6;
							points_player2 <= points_player2 + 1; 
							bola_HSTART <= HMIDDLE;
							bola_HEND <= HMIDDLE+10;
							bola_VSTART <= VMIDDLE;
							bola_VEND <= VMIDDLE+10;
							toques_cont <= 0;
						elsif(bola_VEND >= VEND) then -- Tocou no limite inferior
							bola_direction <= 4;
						end if;
					when others =>
				end case;
		end if;
	end if;
end process;

VideoOut: process (countclk, reset) -- Pixel por pixel é atualizado na tela
begin
	if reset = '1' then
		VGA_R <= "1111111111";
		VGA_G <= "1111111111";
		VGA_B <= "1111111111";
	elsif countclk'event and countclk = '1' then
	
		if (barra1_out = '1') then
			VGA_R <= "1111111111";
			VGA_G <= "1111111111";
			VGA_B <= "1111111111";
		elsif (barra2_out = '1') then
			VGA_R <= "1111111111";
			VGA_G <= "1111111111";
			VGA_B <= "1111111111";
		elsif (bola_out = '1') then
			if (game_level = 1) then
				VGA_R <= "1111111111";
				VGA_G <= "1111111111";
				VGA_B <= "1111111111";
			elsif (game_level = 2) then
				VGA_R <= "1001010101";
				VGA_G <= "1001001000";
				VGA_B <= "0000010000";
			elsif (game_level = 3) then
				VGA_R <= "1111111111";
				VGA_G <= "0101000000";
				VGA_B <= "0000000000";
			elsif (game_level = 4) then
				VGA_R <= "1111111111";
				VGA_G <= "0000000000";
				VGA_B <= "0000000000";
			end if;
		elsif (bordas_out = '1') then
			VGA_R <= "0000111111";
			VGA_G <= "1111111000";
			VGA_B <= "1110001111";
		else
			VGA_R <= "0000000000";
			VGA_G <= "0000000000";
			VGA_B <= "0000000000";
		end if;
	end if;
end process VideoOut;

VGA_CLK <= countclk;
VGA_HS <= not vga_hsync;
VGA_VS <= vga_vsync;
VGA_SYNC <= '0';
VGA_BLANK <= not (vga_hsync or vga_vsync);

ascii_new <= temp_ps2_code_new;
ascii_code <= temp_ps2_code;

end rtl;