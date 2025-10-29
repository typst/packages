#import "@preview/ufscholar:0.1.3": *

= Demais Seções (Capítulos)

*Instruções da Coordenação do @pfc:*

Uma prática que contribui para uma fluidez melhor do texto é colocar um parágrafo introdutório no início de cada capítulo, descrevendo os assuntos que serão abordados e a relação com o restante do trabalho. Por exemplo, "A Seção 2.1 apresenta ...", "Or resultados obtidos são analisados na Seção 2.2". Pode-se fazer o mesmo no início de seções maiores, explicando para o leitor, em uma ou duas sentenças o que está por vir no texto e por quê. Outra boa prática é, ao final de cada capítulo, fazer a ligação com o capítulo seguinte.

Figuras, tabelas, quadros e equações devem ser introduzidos e explicados no texto; não se pode simplesmente "jogá-los" no texto, sem referência nem explicação. Por exemplo, escreva: "O circuito projetado é mostrado na Figura 1. O resistor $R_1$ faz o papel de um limitador de corrente, enquanto o capacitor $C_2$ juntamente com o resistor $R_5$ formam um filtro passa-baixa. Este circuito tem a vantagem de ..."

Com relação às equações, não se faz referência a uma equação que ainda não foi apresentada. Por exemplo, não se escreve: "A relação entre a tensão e a corrente de um resistor é dada pela @eq:errado":

$ V = R I. $ <eq:errado>

#noindent[O correto é algo como "A relação entre a tensão e a corrente de um resistor é dada pela Lei de Ohm,]

$ V = R I, $ <eq:correto>

#noindent[na qual $V$ é a tensão aplicada no resistor, $R$ é a resistência e $I$ é a corrente elétrica".]

É importante observar que as equações fazem parte do texto e, assim, frequentemente convém inserir uma vírgula ou ponto ao seu final. Se o parágrafo segue, elimina-se o recuo na próxima linha com o comando `#noindent[...]`. Além disso, se a frase segue, inicia-se a linha com letra minúscula. Veja exemplos na @eq:errado e @eq:correto.

A seguir, encontrase uma equação na linha de texto: $hat(y)(t + k | t) = sum_(i=1)^infinity g_i Delta u(t+k-i | t)$. E eis uma referência cruzada da @fig:elementos-trabalho e da @eq:ex1.
