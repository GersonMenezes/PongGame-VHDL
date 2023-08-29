# Pong VHDL
## Autor: Gerson Leite de Menezes
## Professor: Rafael Iankowski Soares
### Esse jogo faz parte de um trabalho final da disciplina de Sistemas Digitais Avançados e visa implementar no jogo vários conhecimentos acerca de sistemas digitais aprendido ao longo do semestre letivo. Para mais detalhes leia o README.md. Para futuras atualizações e mais detalhes entrar no link do github: https://github.com/GersonMenezes/PongGame-VHDL onde o jogo e o README será atualizado. Contato: gldmenezes@inf.ufpel.edu.br.

O trabalho implementa o jogo do PONG. O Pong é um jogo eletrônico clássico de arcade, lançado em 1972 pela Atari. É um jogo de simulação de tênis de mesa, no qual os jogadores movem as paletas para acertar uma bola de volta e tentam marcar pontos no campo do oponente. O jogo tornou-se um sucesso instantâneo e ajudou a impulsionar o desenvolvimento de jogos eletrônicos.
Esse jogo foi escrito em VHDL e executado no FPGA DE2 da Altera, especificamente o modelo: xxxxxxxxx-xx. Foi conectado ao dispositivo um monitor através de um cabo VGA e um teclado com conexão PS2.

## Dispositivos do jogo:
Para o jogo foi utilizado um placa de circuito impresso da Altera, DE2 Board, que processa o jogo, um monitor com entrada VGA e um teclado com cabeamento PS2.
## Mecânicas do jogo:
As teclas a e d do teclado controlam o movimento da barra 1, "d" para cima e "a" para baixo. Já os botões de Switch Pushbutton da placa foram usados para movimentar a barra 2, key0 e key1 para cima e key2 e key3 para baixo, essa redundância foi necessária porque alguns botões de algumas placas estavam falhando. Cada jogador tem um placar de pontos, quem fizer 9 pontos primeiro ganha e assim começa outro round. Se a bola for rebatida 5 vezes sem que ninguém faça pontos, o nível de dificuldade do jogo aumenta e a bola e as barras ficam mais rápidas. Existem 4 níveis, em cada nível a bola muda de cor, começa branca, depois amarela, laranja e por último vermelha. É possível resetar o jogo ao levantar o toggle switch SW0 e baixá-lo novamente.
## Estados do jogo:
Depois que o jogo começa existem dez estados de máquina possíveis, cada estado representa uma direção que a bola faz. Então são dez direções no total. Pensando num plano cartesiano onde existe um círculo centrado no ponto de origem e fazendo uma volta no sentido anti-horário de 360 graus, cada direção da bola em relação ao eixo das abscissas representa um ângulo*, quando a bola vai para a direita, por exemplo, ela está indo na direção de 0 graus ou 360 graus, para à direita e um pouco para cima 30 graus, para direita e ainda mais para cima 60 graus e assim sucessivamente, para a esquerda 180 graus e assim sucessivamente. A variável bola_direction é do tipo inteiro e seu valor varia entre 1 e 10, cada valor representa uma direção da seguinte maneira:
- 1 representa direção de 0 graus.
- 2 representa direção de 30 graus.
- 3 representa direção de 60 graus.
- 4 representa direção de 120 graus.
- 5 representa direção de 150 graus.
- 6 representa direção de 180 graus.
- 7 representa direção de 210 graus.
- 8 representa direção de 240 graus.
- 9 representa direção de 300 graus.
- 10 representa direção de 330 graus.
Esses estados estão no process movimenta_bola.
*A direção que a bola faz na tela em relação ao eixo das abscissas não é exatamente os graus mencionados acima, eles são mencionados apenas para ilustrar a direção que a bola faz.
## Elementos na tela:
Cada led é atualizado por vez na tela, as variáveis VPixel e HPixel são atualizadas para receber as coordenadas do led que será ativado ou não. Então para gerar um elemento na tela basta verificar se os valores de VPixel e HPixel estão dentro de um intervalo desejado e fazer com que o process VideoOut ative um led com as cores desejadas. Exemplo:
if (barra1_out = '1') then
    VGA_R <= "1111111111";
    VGA_G <= "1111111111";
    VGA_B <= "1111111111";
Nesse caso foi verificado se VPixel estava dentro de um intervalo vertical desejado e HPixel estava dentro de um intervalo horizontal desejado, se sim barra1_out <= '1';. Essa verificação foi feita dentro dos componentes formElements e formDetails que retornam o valor '0' ou '1'.
