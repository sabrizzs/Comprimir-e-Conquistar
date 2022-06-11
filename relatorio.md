# Relatório do EP2 de MAC0210 (Laboratório de Métodos Numéricos)
#### Prof. Ernesto G. Birgin - Junho de 2022

##### Alunas: Luísa Menezes da Costa - nºUSP 12676491 | Sabrina Araújo da Silva - nºUSP 12566182

## compress

~~~matlab
compress(originalImg, k)
~~~
A função *compress* recebe uma imagem em .png e uma constante $k$. A imagem é transformada em uma matriz *originalImg* de dimensões $linhas\times colunas\times 3$. Após a leitura da imagem, o número de linhas/colunas da matriz é armazenado em *p*. Utilizando a fórmula dada[^1], calculamos o novo lado $n$ da imagem a ser comprimida. Depois, criamos uma matriz nula *img* $n\times n\times 3$, em que serão adicionados elementos da matriz *originalImg* na nova matriz nula *img* conforme a seguinte fórmula:

$$
(x_i,y_j, :)=((x-1)(k+1)+1, (y-1)(k+1)+1, :)
$$

**Legenda:**

$(x_i,y_j, :)$: coordenadas do elemento de abscissa $x_i$ e ordenada $y_j$ da matriz *img* no RGB

$(x,y, :)$: coordenadas do elemento de abscissa $x$ e ordenada $y$ da matriz *originalImg* no RGB

$k$: número de linhas/colunas retiradas da matriz *originalImg* (taxa de compressão)

Após a atualização da matriz *img* com os valores adequados, o programa lê os valores de *img* com tamanho de 8 bits (o que garante a cor em imagens coloridas) e transforma a matriz em uma imagem comprimida.

## decompress

~~~matlab
 decompress(compressedImg, method, k, h)
~~~
### Descompressão da imagem

A função *decompress* recebe uma imagem em .png, uma constante *method*, $k$ e $h$. A imagem é transformada em uma matriz *compressedImg* de dimensões $linhas\times colunas\times 3$. Após a leitura da imagem, o número de linhas/colunas da matriz é armazenado em *p*. Utilizando a fórmula dada[^1], calculamos o novo lado $p$ da imagem a ser descomprimida. Depois, criamos uma matriz de valor $-1$[^2] *img* de dimensões $n\times n\times 3$, em que serão adicionados elementos da matriz *compressedImg* com elementos de *compressedImg* na nova matriz *img*, sendo que entre cada linha/coluna de *img* irá existir uma linha/coluna composta exclusivamente de valor $-1$ (exceto antes das linhas/colunas de índice $1$ e depois das linhas/colunas de índice $n$), conforme a seguinte fórmula:

$$
((x-1)(k+1)+1, (y-1)(k+1)+1, :)=(x_i,y_j, :)
$$

**Legenda:**

$(x_i,y_j, :)$: coordenadas do elemento de abscissa $x_i$ e ordenada $y_j$ da matriz *compressedImg* no RGB

$(x,y, :)$: coordenadas do elemento de abscissa $x$ e ordenada $y$ da matriz *img* no RGB

$k$: número de linhas/colunas de valor $-1$ adicionadas entre cada linha/coluna de *compressedImg* (taxa de descompressão)

Após a atualização da matriz *img* com os valores adequados, o programa lê os valores de *img* com tamanho de 8 bits (o que garante a cor em imagens coloridas) e transforma a matriz em uma imagem descomprimida.

###  Interpolação Bilinear Por Partes

Se method == "bilinear", o método selecionado para interpolação será o bilinear. Para cada ponto $(x,y)$ a ser interpolado na matriz *img*, devemos calcular o valor $f(x, y) \approx p_{ij}(x, y) = a_0 + a_1(x − x_i) + a_2(y − y_j) + a_3(x − x_i)(y − y_j)$, de acordo com o seguinte sistema linear:

$$
F = H \times A
$$

$$
\begin{bmatrix} 
   f(x_i,y_j) \\
   f(x_i,y_{j+1}) \\
   f(x_{i+1},y_j) \\
   f(x_{i+1},y_{j+1})
\end{bmatrix} =
\begin{bmatrix}
   1\ 0\ 0\ 0 \\
   1\ 0\ h\ 0 \\
   1\ h\ 0\ 0 \\
   1\ h\ h\ h^2
\end{bmatrix}
\begin{bmatrix}
   a_0 \\
   a_1 \\
   a_2 \\
   a_3
 \end{bmatrix}
$$

A matriz F representa os pontos nas diagonais do ponto $(x,y)$ que receberá o valor interpolado. A matriz H é definida pelo $h$ inserido pelo usuário. A matriz A representa os valores a serem encontrados e utilizados no polinômio interpolador. Esse processo será feito simultaneamente para cada ponto $(x,y)$ do RGB; portanto, as matrizes $F$ e $A$ terão dimensões $4\times 1\times 3$.

###  Interpolação Bicubica

Se *method == "bicubica"*, o método selecionado será o bicúbico. Inicializamos a matriz H, em que: 

$$ 
H =
\begin{bmatrix}
   1\ 0\ 0\ 0 \\
   1\ h\ h^2\ h^3 \\
   0\ 1\ 0\ 0 \\
   0\ 1\ 2h\ 3h^2
\end{bmatrix}
$$

Após isso, temos a variável HT = inversa da transposta de H e guardamos a inversa de H na própria variável H. Para cada ponto de *img*, inicializamos a matriz nula F de dimensões $4\times 4\times 3$ para guardamos as derivadas primeiras e a derivada mista para cada ponto de *img*.

Para calcular as derivadas, utilizamos as funções auxiliares *dx* e *dy* para as derivadas primeiras, e *dxdy* para a derivada mista. As funções auxiliares calculam as derivadas para os casos gerais e os de borda ($x=1$ ou $x=p$) e recebem como parâmetros:

* *img*: matriz em que os pontos serão interpoladas
* $x$: coordenada do eixo das abscissas de *img* na iteração atual
* $y$: coordenada do eixo das ordenadas de *img* na iteração atual
* $h$: tamanho do lado do quadrado interpolar (conforme especificado no enunciado)
* $p$: tamanho do lado de *img*

Após isso, efetuamos a operação A = H $\times$ F $\times$ HT, em que A representa a matriz que guarda os índices do polinômio interpolador bicúbico. Após descobrirmos os índices necessários, interpolamos cada ponto do quadrado cujo valor é $-1$ e atualizamos na matrix *img*.

## calculateError

~~~matlab
 calculateError(originalImg, decompressedImg)
~~~

A função *calculateError* lê as 6 matrizes correspondentes aos RGBs de *originalImg* e *decompressedImg* e calcula o erro, por meio da norma 2, entre a imagem original e a imagem que passou pelos processos de compressão, descompressão e interpolação. Para tanto, as matrizes originais, do tipo *uint8*, foram transformadas em tipo *double* (tipo suportado pela função embutida *norm* do Octave), sem alterações nos valores das matrizes.

## O Zoológico

Aqui usamos uma função $ f:\mathbb{R}^2 \to \mathbb{R}^3  $ de classe $ C^2 $ para gerar uma imagem grande em RGB.

* **Funciona bem para imagens preto e branco? Funciona bem para imagens coloridas?** A olho nu, a diferença entre a imagem original e a interpolada é quase imperceptível, tanto para imagens preto e branco quanto para imagens coloridas. Logo, para imagens geradas por funções do tipo $ f:\mathbb{R}^2 \to \mathbb{R}^3  $ de classe $ C^2 $, o código funciona bem.
* **Funciona bem para todas as funções de classe $C^2$?** Sim.
* **E para funções que não são de classe $C^2$?** Sim.
* **Como o valor de $h$ muda a interpolação?** A olho nu, o valor de $h$ não parece ter efeito na interpolação da imagem. Para melhor analisá-lo, é preciso analisar o erro.
* **Como se comporta o erro?** Para $h \in \mathbb{N}=1, 2, 3...$, temos que há um erro mínimo, o qual está, geralmente, vinculado a um $h$ baixo (ex.: *"c2.png"* com  $k=1$, $h=3$ e método bilinear ou *"c2.png"* com $k=1$, $h=2$ e método bicúbico). Além disso, valor do erro diminui até chegar em $h_{min}$ e volta a crescer após passsar por $h_{min}$.

### Teste 1 (função do enunciado do EP2).

$$ f(x, y) = (sen(x),\frac{sen(y) + sen(x)}{2} , sen(x)) $$

### Original
![pdf1](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf.png)

### *compress com método bilinear*
![pdf2](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_compressed.png)

### *decompress com h= 1, método bilinear*
![pdf3](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_decompressed.png)

### *decompress com h = 5, método bilinear*
![pdf4](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_h5_decompressed.png)

### *decompress com h = 1, método bicúbico*
![pdf5](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_bicubica_decompressed.png)

### *decompress com h = 2, método bicúbico*
![pdf6](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_bicubica_h2_decompressed.png)

### *decompress com h = 5, método bicúbico*
![pdf7](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_bicubica_h5_decompressed.png)

### Teste 2 (função C^1)

$$ f(x,y) = (\frac{256x}{280}, \frac{256y}{280}, \frac{256x}{280}) $$

### Original
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c1.png)

### *compress com método bilinear*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_compressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c1_compressed.png)

### *decompress com h= 1, método bilinear*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_decompressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c1_decompressed.png)

### *decompress com h = 1, método bicúbico*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_bicubica_decompressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c1_bicubica_decompressed.png)

### Teste 3 (função C^2)

$$ f(x,y) = (\frac{y^5*\sin{xk}}{x^3+xy^2} , \frac{y^5*\sin{xk}}{x^3+xy^2} , \frac{x^5*\sin{yk}}{x^3+xy^2})

em que $k=2.069\times 10^{-8}$.

### Original ("c2.png")
![c2](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2.png)

### *compress* com k=1
![c21](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_compress_k1.png)

### *decompress* com k=1, método bilinear e h=1
![c22](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bl_k1_h1.png)

### *decompress* com k=1, método bilinear e h=3
![c23](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bl_k1_h3.png)

### *decompress* com k=1, método bilinear e h=7
![c24](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bl_k1_h7.png)

### *decompress* com k=1, método bicúbico e h=1
![c25](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bc_k1_h1.png)

### *decompress* com k=1, método bicúbico e h=2
![c26](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bc_k1_h2.png)

### *decompress* com k=1, método bicúbico e h=3
![c27](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/c2_decompress_bc_k1_h3.png)

### *calculateError*

**Para o método bilinear (k=1):**

* h = 1 &rarr; Erro = 0.0081111
* h = 3 &rarr; Erro = 0.0027650
* h = 5 &rarr; Erro = 0.0053125
* h = 7 &rarr; Erro = 0.0063754

**Para o método bicúbico (k=1):**

* h = 1 &rarr; Erro = 0.0081553
* h = 2 &rarr; Erro = 0.0010551
* h = 3 &rarr; Erro = 0.007891
* h = 5 &rarr; Erro = 0.020304

### Teste 4 (função de imagem em preto e branco).

$$ f(x, y) = (sen(2.069\times 10^{-3}x) , sen(2.069\times 10^{-3}x) , sen(2.069\times 10^{-3}x)) $$

### Original
![https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf.png](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb.png)

### *compress com método bilinear*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_compressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_compressed.png)

### *decompress com h= 1, método bilinear*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_decompressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_decompressed.png)

### *decompress com h = 1, método bicúbico*
![(https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/pdf_bicubica_decompressed.png)](https://github.com/clair-de-lume/mac210-ep2/blob/main/zoologico/peb_bicubica_decompressed.png)

## Considere uma imagem de tamanho $p^2$. Comprima-a com k = 7. Para obter a descompressão, podemos rodar decompress com k = 7. Experimente alternativamente usar decompress três vezes com k = 1 nas três. Compare os resultados. Escreva no relatório suas conclusões.

### *compress* com k = 7
![ce1](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/experimentos/compressed_e1.png)

### *decompress* uma vez com k = 7, método bilinear e h = 2
![de1](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/experimentos/decompressed_e1.png)

### *decompress* três vezes com k = 1, método bilinear e h = 2
![de2](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/experimentos/decompressed_e2.png)

### *decompress* uma vezes com k = 7, método bicúbico e h = 2
![de1bc](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/experimentos/d_ex1_bc.png)

### *decompress* três vezes com k = 1, método bicúbico e h = 2
![de2bc](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/experimentos/d_ex2_bc.png)

## A Selva

Aqui usamos uma imagem real (foto ou desenho) para testar o método de compressão (comprimir, descomprimir e calcular o erro).

* Funciona bem para imagens preto e branco?
* **Funciona bem para imagens coloridas?** O método bilinear com os valores ótimos de $k$ e $h$ produz imagens semelhantes à original, mas levemente quadriculadas. Similarmente, o método bicúbico também produz imagens parecida com a original, porém menos nítidas ("borradas").
* **Como o valor de $h$ muda a interpolação?** Para a maioria dos casos, quanto maior o valor de $h$, melhor fica a qualidade da imagem interpolada, principalmente se ela tiver sido comprimida e descomprimida com valores mais elevados de $k$.  
* **Como se comporta o erro?** Para $h \in \mathbb{N}=1, 2, 3...$, temos que há um erro mínimo, o qual pode estar em um $h$ baixo (ex.: *"hanako.jpg"* com  $k=1$, $h=1$ e método bicúbico) ou em um valor de $h$ mais elevado (ex.: *"hanako.jpg"* com $k=5$, $h=7$ e método bilinear). Para ambos os casos, o valor do erro diminui até chegar em $h_{min}$ e volta a crescer após passsar por $h_{min}$.
* 
## Teste para "sailor.png" (dimensões: 250x250)

### Original

![sailor](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor.png)

### *compress* com k = 1
![sailor1](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor1.png)

### *compress* com k = 5
![sailor5](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor5.png)

### *compress* com k = 10
![sailor10](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor10.png)

### *decompress* com k = 1, método bilinear e h = 1
![d_hanako1](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor/d_sailor1.png)

### *decompress* com k = 5, método bilinear e h = 1
![d_hanako5](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor/d_sailor5.png)

### *decompress* com k = 10, método bilinear e h = 1
![d_hanako15](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/sailor/d_sailor15.png)

### *calculateError*

A imagem *"sailor.png"* tem dimensões $250\times 250$ e após comprimida e descomprimida com $k=1$, fica com dimensões $249\times 249$. Isso acontece pois, para $p=250$ e $k=1$, o $n$ calculado será $125.5$, ou seja, não inteiro. Logo, esse valor de $n$ faz com que a imagem descomprimida tenha dimensões diferentes da imagem original. 

A função *calculateError* só consegue calcular o erro entre matrizes de mesma dimensão. Assim, é impossível calcular o erro para *"sailor.png"* com $k=1$.

## Teste para "hanako.jpg" (dimensões: 433x433)

### Original

![hanako](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/hanako.jpg)

### *compress* com k = 5
![hanako5](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/c_hanako5.png)

### *compress* com k = 15
![hanako15](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/c_hanako15.png)

### *compress* com k = 35
![hanako35](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/c_hanako35.png)

### *decompress* com k = 5, método bilinear e h = 1
![hanako5](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/d_hanako5.png)

### *decompress* com k = 15, método bilinear e h = 1
![hanako15](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/d_hanako15.png)

### *decompress* com k = 35, método bilinear e h = 1
![hanako35](https://github.com/clair-de-lume/mac210-ep2/blob/main/imagens/hanako/d_hanako35.png)

### *calculateError*

**Para o método bilinear (k=1):**

* h = 1 &rarr; Erro = 0.027129
* h = 2 &rarr; Erro = 0.013400 (mais próxima à original)
* h = 3 &rarr; Erro = 0.014682
* h = 4 &rarr; Erro = 0.016445
* h = 5 &rarr; Erro = 0.018047
* h = 6 &rarr; Erro = 0.019360

**Para o método bicúbico (k=1):**

* h = 1 &rarr; Erro = 0.060446 (mais próxima à imagem original)
* h = 2 &rarr; Erro = 0.015471
* h = 3 &rarr; Erro = 0.027059
* h = 4 &rarr; Erro = 0.044575

**Para o método bilinear (k=5):**

* h = 1 &rarr; Erro = 0.2727
* h = 2 &rarr; Erro = 0.1201
* h = 3 &rarr; Erro = 0.069187
* h = 6 &rarr; Erro = 0.034401
* h = 7 &rarr; Erro = 0.033610 (mais próxima à original)
* h = 8 &rarr; Erro = 0.033981
* h = 10 &rarr; Erro = 0.036429

**Para o método bicúbico (k=5):**

* h = 1 &rarr; Erro = 0.6270
* h = 2 &rarr; Erro = 0.4830
* h = 3 &rarr; Erro = 0.3619
* h = 6 &rarr; Erro = 0.2697 (mais próxima à original)
* h = 7 &rarr; Erro = 0.4080
* h = 8 &rarr; Erro = 0.4941

[^1]: $p=n+(n-1)k$
[^2]: Os valores da matriz são todos iguais a $-1$ para facilitar o processo de interpolação: o sistema RGB é representado por números de 0 até 255; logo, os pontos a serem interpolados não podem estar nesse intervalo para evitar interpolações desnecessárias.
