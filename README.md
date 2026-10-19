# Prisma em Flow Field (R)

Animação generativa feita só com **R e ggplot2**: linhas de luz fluem da esquerda, convergem num prisma e saem como um espectro de cores, com pulsos de luz correndo pelo caminho inteiro. O resultado é um vídeo em loop contínuo.

> Terceiro projeto de uma série em que exploro o lado menos óbvio de cada linguagem: **Python** (paleta de cores com K-Means), **Julia** (sistema solar 3D com GLMakie) e **R** (este aqui).

## Como funciona

Cada quadro do vídeo é o mesmo gráfico `ggplot2` desenhado com um `tempo` diferente, de 0 a 1:

1. **Geometria:** um triângulo equilátero é o prisma. Os pontos de entrada e saída da luz são o meio das arestas esquerda e direita.
2. **Linhas de entrada:** 90 linhas partem de pontos sorteados na esquerda e convergem no ponto de entrada. Cada uma ganha uma ondulação com `sin()` que vai sumindo perto do prisma, e a fase da onda desliza com o tempo.
3. **Espectro:** 140 raios saem do ponto de saída em ângulos diferentes (`tan()` dá a inclinação), com cores de um degradê (`colorRampPalette`) e uma ondulação que cresce com a distância.
4. **Pulsos de luz:** cada ponto das linhas recebe um valor de luz entre 0 e 1, calculado por um cosseno que depende da posição no caminho e do tempo. Esse valor controla a transparência, e é isso que faz o brilho parecer andar.
5. **Brilho:** cada conjunto de linhas é desenhado duas vezes, uma camada larga e quase transparente por baixo e uma fina e forte por cima.
6. **Loop perfeito:** como `tempo` vai de 0 até um pouco antes de 1 e as ondas completam ciclos inteiros, o último quadro emenda no primeiro.

## Requisitos

- R 4.0 ou superior
- Pacotes:

```r
install.packages(c("ggplot2", "ragg", "av"))
```

## Como rodar

1. Abra o script `prisma_comentado.R` no RStudio.
2. Rode o arquivo inteiro (`Ctrl+Shift+S`).
3. Aguarde. Cada quadro leva alguns segundos, então os 100 quadros podem levar alguns minutos.

Saídas, na pasta de trabalho (`getwd()` mostra qual é):

- `quadros/`: os PNGs de um ciclo (1280x720)
- `prisma_fluindo.mp4`: o vídeo final, 10 segundos

Dica: pra testar rápido, troque `N_QUADROS` por `5` e rode. Quando estiver tudo certo, volte pra `100`.

## Parâmetros para mexer

| Parâmetro | O que faz |
|---|---|
| `N_QUADROS` | Quadros de um ciclo. Mais quadros deixam o movimento mais lento e suave |
| `REPETICOES` | Quantas vezes o ciclo se repete no vídeo (duração = `N_QUADROS` x `REPETICOES` / `FPS`) |
| `FPS` | Quadros por segundo |
| `n_pulsos` | Quantos pulsos de luz ao mesmo tempo ao longo do caminho |
| `raios` | Quantidade de raios do espectro. Mais raios deixam o leque mais contínuo |
| `1:90` em `desenha()` | Quantidade de linhas de entrada |
| `runif(...)` em `gera_linha()` | Intervalos de sorteio: partida, altura e frequência das ondas |
| `paleta` | Cores do espectro |

## Estrutura do código

```text
prisma_comentado.R
├── Pontos do triângulo     (prisma, entrada e saída da luz)
├── Feixe                   (linha branca dentro do prisma)
├── Pulsos                  (função pulso: luz de 0 a 1)
├── gera_linha()            (uma linha de entrada, com onda e sorteios)
├── gera_raio()             (um raio do espectro, com ângulo e cor)
├── desenha(tempo)          (monta o gráfico de um quadro)
└── Laço final              (salva os quadros e junta no vídeo)
```
