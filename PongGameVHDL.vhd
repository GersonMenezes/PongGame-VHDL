library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.tipos.all;
use work.componentes_pkg.all;

entity PongGameVHDL is
port (
	reset : in std_logic;
	clk: in std_logic; -- 135 MHz
	clk_27: in std_logic;

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

------------------------
-- Parametros Gerais do Jogo --
------------------------
	signal points_player1, points_player2 	: integer range 0 to 80 := 0;
	signal game_level 	: integer range 1 to 10 := 1;
	signal veloci_bola   : integer range 1 to 10 := 6; 	
------------------------
-- Parametros do bola --
------------------------
	signal bola_HSTART 	: integer range 1 to 1280 := HMIDDLE;
	signal bola_HEND 		: integer range 1 to 1280 := HMIDDLE+10;
	signal bola_VSTART	: integer range 1 to 1024 := VMIDDLE;
	signal bola_VEND		: integer range 1 to 1024 := VMIDDLE+10;
	signal bola_out		: std_LOGIC := '0';
	signal bola_direction: integer range 1 to 10 := 1;	
------------------------
-- Parametros do barra1 --
------------------------
	signal barra1_HSTART 	: integer range 1 to 1280 := 1;
	signal barra1_HEND 		: integer range 1 to 1280 := 11;
	signal barra1_VSTART	   : integer range 1 to 1024 := 500;
	signal barra1_VEND		: integer range 1 to 1024 := 600;
	signal barra1_out			: std_LOGIC := '0'; -- Se '1', posição coincide com pixel da vez na tela e dá imagem
------------------------
-- Parametros do barra2 --
------------------------
	signal barra2_HSTART 	: integer range 1 to 1280 := 1270;
	signal barra2_HEND 		: integer range 1 to 1280 := 1280;
	signal barra2_VSTART	   : integer range 1 to 1024 := 500;
	signal barra2_VEND		: integer range 1 to 1024 := 600;
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
CLKM_MAKING: divisor_frequencia port map(countclk,movclk,clk_pong);

CLKM_M: altclk port map(clk_27,countclk);

teclado : ps2_keyboard_to_ascii port map(clk,ps2_clk,ps2_data,temp_ps2_code_new,temp_ps2_code);

barra_1: formElements port map(countclk, reset, HPixel, VPixel, barra1_hstart, barra1_hend, barra1_vstart, barra1_vend, barra1_out);

barra_2: formElements port map(countclk, reset, HPixel, VPixel, barra2_hstart, barra2_hend, barra2_vstart, barra2_vend, barra2_out);

bola: formElements port map(countclk, reset, HPixel, VPixel, bola_hstart, bola_hend, bola_vstart, bola_vend, bola_out);


HCounter: process (countclk, reset) -- Qual pix será modificado na tela?
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
		barra1_HSTART <= 1;
		barra1_HEND <= 11;
		barra1_VSTART <= 500;
		barra1_VEND <= 600;
	else
		if (clk_pong'event and clk_pong='1') then
			-- MOVIMENTA a barra 1
			if((temp_ps2_code_new = '1' and temp_ps2_code= "1110011") and (barra1_VEND < 1024)) then -- s (down)
				barra1_VEND <= barra1_VEND+2;
  				barra1_VSTART <= barra1_VSTART+2;
			elsif((temp_ps2_code_new = '1' and temp_ps2_code= "1110111") and (barra1_VSTART > 70)) then -- w (up)
				barra1_VEND <= barra1_VEND-2;
  				barra1_VSTART <= barra1_VSTART-2;
			end if;
		end if;
	end if;
end process;

movimenta_barra2: process(clk_pong)
begin
	if reset='1' then
		barra2_HSTART <= 1270;
		barra2_HEND <= 1280;
		barra2_VSTART <= 500;
		barra2_VEND <= 600;
	else
		if (clk_pong'event and clk_pong='1') then
			--Movimenta a barra 2
			if((temp_ps2_code_new = '1' and temp_ps2_code= "1101100") and (barra2_VEND < 1024)) then -- l (down)
				barra2_VEND <= barra2_VEND+2;
  				barra2_VSTART <= barra2_VSTART+2;
			elsif((temp_ps2_code_new = '1' and temp_ps2_code= "1101111") and (barra2_VSTART > 70)) then -- o (up)
				barra2_VEND <= barra2_VEND-2;
  				barra2_VSTART <= barra2_VSTART-2;
			end if;
		end if;
	end if;
end process;

movimenta_bola: process(clk_pong)
begin
	if reset='1' then
		bola_HSTART <= 1;
		bola_HEND <= 11;
		bola_VSTART <= 500;
		bola_VEND <= 510;
	else
		if (clk_pong'event and clk_pong='1') then
			----------------------------------------------------------
			--- Bola indo para à direita, direções 1, 2, 3, 9 e 10 ---
			----------------------------------------------------------
			
			------------- Direção 1 --------------
			if (bola_direction = 1) then -- Direção de 0° ou 360°
				bola_HSTART <= bola_HSTART + veloci_bola;
				bola_HEND <= bola_HEND + veloci_bola;
				if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101100")) then
					bola_direction <= 7;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101111")) then
					bola_direction <= 5;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
					and (bola_VSTART <= barra2_VEND))) then
					bola_direction <= 6;
				elsif(bola_HSTART >= HEND) then -- Jogador 1 fez ponto
					bola_direction <= 1;
					points_player1 <= points_player1 + 1; 
					bola_HSTART <= HMIDDLE-10;
					bola_HEND <= HMIDDLE;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				end if;
			
			------------ Direção 2 --------------
			elsif (bola_direction = 2) then -- Direção de 30°
				bola_HSTART <= bola_HSTART + veloci_bola + 1;
				bola_HEND <= bola_HEND + veloci_bola + 1;
				bola_VSTART <= bola_VSTART - veloci_bola;
				bola_VEND <= bola_VEND - veloci_bola;
				if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101100")) then
					bola_direction <= 6;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101111")) then
					bola_direction <= 4;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
					and (bola_VSTART <= barra2_VEND))) then
					bola_direction <= 5;
				elsif(bola_HSTART >= HEND) then -- Jogador 1 fez ponto
					bola_direction <= 1;
					points_player1 <= points_player1 + 1; 
					bola_HSTART <= HMIDDLE-10;
					bola_HEND <= HMIDDLE;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VSTART >= 70) then -- Bola tocou em cima
					bola_direction <= 10;
				end if;
				
				------------ Direção 3 --------------
			elsif (bola_direction = 3) then -- Direção de 60°
				bola_HSTART <= bola_HSTART + veloci_bola;
				bola_HEND <= bola_HEND + veloci_bola;
				bola_VSTART <= bola_VSTART - veloci_bola - 1;
				bola_VEND <= bola_VEND - veloci_bola - 1;
				if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101100")) then
					bola_direction <= 5;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101111")) then
					bola_direction <= 4;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
					and (bola_VSTART <= barra2_VEND))) then
					bola_direction <= 4;
				elsif(bola_HSTART >= HEND) then -- Jogador 1 fez ponto
					bola_direction <= 1;
					points_player1 <= points_player1 + 1; 
					bola_HSTART <= HMIDDLE-10;
					bola_HEND <= HMIDDLE;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VSTART <= 70) then -- Bola tocou em cima
					bola_direction <= 9;
				end if;
				
			------------ Direção 9 --------------
			elsif (bola_direction = 9) then -- Direção de 300°
				bola_HSTART <= bola_HSTART + veloci_bola;
				bola_HEND <= bola_HEND + veloci_bola;
				bola_VSTART <= bola_VSTART + veloci_bola + 1;
				bola_VEND <= bola_VEND + veloci_bola + 1;
				if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 descendo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101100")) then
					bola_direction <= 8;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 subindo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101111")) then
					bola_direction <= 7;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- l (Barra 2 parada)
					and (bola_VSTART <= barra2_VEND))) then
					bola_direction <= 8;
				elsif(bola_HSTART >= HEND) then -- Jogador 1 fez ponto
					bola_direction <= 1;
					points_player1 <= points_player1 + 1; 
					bola_HSTART <= HMIDDLE-10;
					bola_HEND <= HMIDDLE;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VEND >= VEND) then -- Bola tocou em baixo
					bola_direction <= 3;
				end if;
			
			------------ Direção 10 --------------
			elsif (bola_direction = 10) then -- Direção de 330°
				bola_HSTART <= bola_HSTART + veloci_bola + 1;
				bola_HEND <= bola_HEND + veloci_bola + 1;
				bola_VSTART <= bola_VSTART + veloci_bola;
				bola_VEND <= bola_VEND + veloci_bola;
				if((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 descendo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101100")) then
					bola_direction <= 8;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 subindo)
					and (bola_VSTART <= barra2_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1101111")) then
					bola_direction <= 6;
				elsif((bola_HEND >= barra2_HSTART) and ((bola_VEND >= barra2_VSTART) -- (Barra 2 parada)
					and (bola_VSTART <= barra2_VEND))) then
					bola_direction <= 7;
				elsif(bola_HSTART >= HEND) then -- Jogador 1 fez ponto
					bola_direction <= 1;
					points_player1 <= points_player1 + 1; 
					bola_HSTART <= HMIDDLE-10;
					bola_HEND <= HMIDDLE;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VEND >= VEND) then -- Bola tocou em baixo
					bola_direction <= 2;
				end if;
				
			----------------------------------------------------------
			---- Bola indo para esquerda, direções 4, 5, 6, 7 e 8 ----
			----------------------------------------------------------
			
			------------- Direção 4, 120° --------------
			elsif (bola_direction = 4) then
				bola_HSTART <= bola_HSTART - veloci_bola;
				bola_HEND <= bola_HEND - veloci_bola;
				bola_VSTART <= bola_VSTART - veloci_bola - 1;
				bola_VEND <= bola_VEND - veloci_bola -1;
				if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1110011")) then 
					bola_direction <= 2;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "11110111")) then 
					bola_direction <= 3;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
					and (bola_VSTART <= barra1_VEND))) then 
					bola_direction <= 3;
				elsif(bola_HSTART <= 0) then -- Jogador 2 fez ponto
					bola_direction <= 6;
					points_player2 <= points_player2 + 1; 
					bola_HSTART <= HMIDDLE;
					bola_HEND <= HMIDDLE+10;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VSTART <= 70) then -- Tocou no limite superior
					bola_direction <= 8;
				end if;
				
			------------- Direção 5, 120° --------------
			elsif (bola_direction = 5) then
				bola_HSTART <= bola_HSTART - veloci_bola - 1;
				bola_HEND <= bola_HEND - veloci_bola - 1;
				bola_VSTART <= bola_VSTART - veloci_bola;
				bola_VEND <= bola_VEND - veloci_bola;
				if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1110011")) then 
					bola_direction <= 1;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "11110111")) then 
					bola_direction <= 3;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
					and (bola_VSTART <= barra1_VEND))) then 
					bola_direction <= 2;
				elsif(bola_HSTART <= 0) then -- Jogador 2 fez ponto
					bola_direction <= 6;
					points_player2 <= points_player2 + 1; 
					bola_HSTART <= HMIDDLE;
					bola_HEND <= HMIDDLE+10;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VSTART <= 70) then -- Tocou no limite superior
					bola_direction <= 7;
				end if;
				
			------------- Direção 6, 180° --------------
			elsif (bola_direction = 6) then
				bola_HSTART <= bola_HSTART - veloci_bola ;
				bola_HEND <= bola_HEND - veloci_bola;
				if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1110011")) then 
					bola_direction <= 10;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "11110111")) then 
					bola_direction <= 2;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
					and (bola_VSTART <= barra1_VEND))) then 
					bola_direction <= 1;
				elsif(bola_HSTART <= 0) then -- Jogador 2 fez ponto
					bola_direction <= 6;
					points_player2 <= points_player2 + 1; 
					bola_HSTART <= HMIDDLE;
					bola_HEND <= HMIDDLE+10;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				end if;
				
						------------- Direção 7, 210° --------------
			elsif (bola_direction = 7) then
				bola_HSTART <= bola_HSTART - veloci_bola - 1;
				bola_HEND <= bola_HEND - veloci_bola - 1;
				bola_VSTART <= bola_VSTART + veloci_bola;
				bola_VEND <= bola_VEND + veloci_bola;
				if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1110011")) then 
					bola_direction <= 9;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "11110111")) then 
					bola_direction <= 1;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
					and (bola_VSTART <= barra1_VEND))) then 
					bola_direction <= 10;
				elsif(bola_HSTART <= 0) then -- Jogador 2 fez ponto
					bola_direction <= 6;
					points_player2 <= points_player2 + 1; 
					bola_HSTART <= HMIDDLE;
					bola_HEND <= HMIDDLE+10;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VEND <= VEND) then -- Tocou no limite inferior
					bola_direction <= 5;
				end if;
				
			------------- Direção 8, 240° --------------
			elsif (bola_direction = 8) then
				bola_HSTART <= bola_HSTART - veloci_bola;
				bola_HEND <= bola_HEND - veloci_bola - 1;
				bola_VSTART <= bola_VSTART + veloci_bola + 1;
				bola_VEND <= bola_VEND + veloci_bola + 1;
				if(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 descendo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "1110011")) then 
					bola_direction <= 9;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- barra 1 subindo
					and (bola_VSTART <= barra1_VEND)) and (temp_ps2_code_new = '1' and temp_ps2_code= "11110111")) then 
					bola_direction <= 10;
				elsif(bola_HSTART <= barra1_HEND and ((bola_VEND >= barra1_VSTART) -- Barra 1 parada
					and (bola_VSTART <= barra1_VEND))) then 
					bola_direction <= 9;
				elsif(bola_HSTART <= 0) then -- Jogador 2 fez ponto
					bola_direction <= 6;
					points_player2 <= points_player2 + 1; 
					bola_HSTART <= HMIDDLE;
					bola_HEND <= HMIDDLE+10;
					bola_VSTART <= VMIDDLE;
					bola_VEND <= VMIDDLE+10;
				elsif(bola_VEND <= VEND) then -- Tocou no limite inferior
					bola_direction <= 4;
				end if;
			end if;
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
			VGA_R <= "1111111111";
			VGA_G <= "1111111111";
			VGA_B <= "1111111111";
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