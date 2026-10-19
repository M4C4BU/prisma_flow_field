library(ggplot2)

#Pontos do Triangulo ------------------------------
A <- c(-0.5, -0.45)
B <- c( 0.5, -0.45) 
C <- c( 0.0,  0.42) 
entrada <- (A + C) / 2 # meio da aresta esquerda: onde a luz entra
saida   <- (B + C) / 2 # meio da aresta direita: onde a luz sai

triangulo <- data.frame(x = c(A[1], B[1], C[1], A[1]),
                        y = c(A[2], B[2], C[2], A[2])) #tabela do triangulo (volta no A pra fechar)

#Feixe ------------------------------

feixe <- data.frame(x = c(entrada[1], saida[1]),
                    y = c(entrada[2], saida[2])) #tabela usando os pontos pra criar o feixe

#Pontos das linhas  ------------------------------

ondas <- seq(0, 1, length.out = 120) #120 passos de 0 a 1: e o "quanto do caminho ja andei", usado em todas as linhas

#Pulsos ------------------------------

n_pulsos <- 2 #quantos pulsos de luz cabem no caminho ao mesmo tempo

pulso <- function(s, tempo) {
  ((1 + cos(2 * pi * (n_pulsos * s - tempo))) / 2)^3 #gera pulsos nos intervalos
}

#Linhas de entrada ------------------------------

gera_linha <- function(i, tempo) { # i = numero da linha, tempo = relogio de 0 a 1
  set.seed(i)   #mantem as linhas no mesmo lugar (linha i sorteia sempre os mesmos valores)
  
  # os 5 sorteios
  xlinha <- runif(1, -2.05, -1.55) #x de partida, na esquerda
  ylinha <- runif(1, -0.95, 0.95)  #y de partida, espalhado na altura da tela
  amp    <- runif(1, 0.03, 0.09)   #altura da onda
  frq    <- runif(1, 1.5, 3.5)     #quantas ondas cabem na linha
  fase   <- runif(1, 0, 2 * pi)    #deslocamento da onda pra cada linha ser diferente
  
  #faz a onda deslizar
  x      <- xlinha + (entrada[1] - xlinha) * ondas  #anda reto da partida ate a entrada do prisma
  y_base <- ylinha + (entrada[2] - ylinha) * ondas  #mesma coisa no y: e a reta base
  onda   <- amp * sin(2 * pi * frq * ondas + fase - 2 * pi * tempo) * (1 - ondas) #sobe e desce; o "- tempo" faz deslizar; (1 - ondas) apaga a onda no fim pra chegar certinho no prisma
  
  y <- y_base + onda #reta + onda
  
  data.frame(id = i, x = x, y = y, s = ondas - 1) #s = posicao no caminho (de -1 ate 0, antes do prisma)
}

#Arcoiris ------------------------------

raios   <- 140 #quantos raios coloridos
angulos <- seq(8, -24, length.out = raios) * pi / 180 #do que mais sobe ate o que mais desce, convertido pra radianos
paleta  <- colorRampPalette(c("#ff2a2a", "#ffe11f", "#3dff6a", "#22d6ff", "#b04dff"))(raios) #degrade do vermelho ao roxo, uma cor por raio

gera_raio <- function(i, tempo) {
  x <- saida[1] + (2.05 - saida[1]) * ondas #anda da saida do prisma ate a borda direita
  y <- saida[2] + tan(angulos[i]) * (x - saida[1]) + #tan(angulo) = inclinacao do raio
    0.035 * ondas^1.3 * sin(2 * pi * 2 * ondas + i * 0.12 - 2 * pi * tempo) #ondulacao: comeca em 0 no prisma, cresce ate a borda; i * 0.12 faz raios vizinhos ondularem juntos
  data.frame(id = i, x = x, y = y, cor = paleta[i], s = ondas) #s = posicao no caminho (de 0 ate 1, depois do prisma)
}

#Plotando o Grafico ------------------------------

desenha <- function(tempo) { # cada quadro do video e essa funcao com um tempo diferente
  linhas   <- do.call(rbind, lapply(1:90, gera_linha, tempo = tempo))      #gera as 90 linhas e empilha numa tabela so
  espectro <- do.call(rbind, lapply(1:raios, gera_raio, tempo = tempo))    #gera os raios e empilha
  
  linhas$luz   <- pulso(linhas$s, tempo)    #coluna nova: quanto cada ponto esta aceso (0 a 1)
  espectro$luz <- pulso(espectro$s, tempo)
  
  ggplot() +
    # vidro do prisma (por baixo de tudo)
    geom_polygon(data = triangulo, aes(x, y), fill = "white", alpha = 0.05) +
    
    # linhas de entrada: brilho, depois núcleo (grossa e fraca embaixo, fina e forte em cima)
    geom_path(data = linhas, aes(x, y, group = id), color = "#e8ecff", linewidth = 2.4, alpha = 0.05) +
    geom_path(data = linhas, aes(x, y, group = id, alpha = 0.12 + 0.75 * luz), color = "#e8ecff", linewidth = 0.3) + #alpha depende da luz: onde o pulso passa, brilha
    
    # feixe: brilho, depois núcleo
    geom_path(data = feixe, aes(x, y), color = "white", linewidth = 5, alpha = 0.1) +
    geom_path(data = feixe, aes(x, y), color = "white", linewidth = 1.2) +
    
    # espectro: brilho, depois núcleo
    geom_path(data = espectro, aes(x, y, group = id, color = cor), linewidth = 2.4, alpha = 0.05) +
    geom_path(data = espectro, aes(x, y, group = id, color = cor, alpha = 0.20 + 0.75 * luz), linewidth = 0.35) +
    
    # contorno do prisma (por cima, nítido)
    geom_path(data = triangulo, aes(x, y), color = "white", linewidth = 0.8) +
    
    scale_color_identity() + #usa as cores da coluna "cor" do jeito que estao
    scale_alpha_identity() + #usa o alpha calculado do jeito que esta (sem legenda)
    coord_fixed(xlim = c(-2, 2), ylim = c(-1.125, 1.125)) + #janela 16:9
    theme_void() + #tira eixos e grade
    theme(plot.background = element_rect(fill = "#05060d", color = NA)) #fundo escuro
}

#Gerando os quadros e o video ------------------------------

N_QUADROS  <- 100   # quadros de UM ciclo
REPETICOES <- 3     # 100 quadros x 3 / 30 fps = 10 segundos
FPS        <- 30    # quadros por segundo

dir.create("quadros", showWarnings = FALSE) #pasta onde ficam os PNGs
arquivos <- character(N_QUADROS)            #lista vazia pra guardar o nome de cada quadro

for (k in 1:N_QUADROS) {
  tempo <- (k - 1) / N_QUADROS                        #relogio de 0 ate 0.99 (nunca chega em 1, pra emendar no inicio)
  arquivos[k] <- sprintf("quadros/q_%03d.png", k)     #nome com 3 digitos: q_001, q_002...
  ggsave(arquivos[k], desenha(tempo), width = 1280 / 96, height = 720 / 96,
         dpi = 96, device = ragg::agg_png)            #desenha o quadro e salva em 1280x720
}

av::av_encode_video(rep(arquivos, REPETICOES), framerate = FPS,
                    output = "prisma_fluindo.mp4") #junta os quadros (ciclo repetido 3x) num video