#import "@preview/mkuipers-ulusofona:0.1.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#chapter("Resultados e Análise")

Este capítulo mostra como incluir fórmulas, imagens, tabelas e diagramas de blocos
num relatório baseado neste template.

== Fórmulas

A energia cinética de um corpo de massa $m$ e velocidade $v$ é dada por:

$ E_c = 1/2 m v^2 $ <eq-kinetic>

Isolando $v$ na @eq-kinetic, obtém-se a velocidade em função da energia:

$ v = sqrt(2 E_c / m) $ <eq-velocidade>

Os valores calculados com a @eq-velocidade são apresentados na @tab-resultados.

== Imagens

#lorem(20)

#figure(
  image("./images/lisbon.jpg", width: 40%),
  caption: [Ilustração de Lisboa utilizada como imagem de exemplo.],
) <fig-exemplo>

A @fig-exemplo ilustra a inclusão de uma imagem com legenda.

== Tabelas <sec-tabela>

#lorem(20)

#figure(
  table(
    columns: (auto, auto, auto, auto),
    inset: 8pt,
    align: horizon,
    [*Ensaio*], [*Massa (kg)*], [*Velocidade (m/s)*], [*Energia (J)*],
    [1], [0.500], [2.10], [1.10],
    [2], [0.500], [3.05], [2.33],
    [3], [0.750], [2.40], [2.16],
  ),
  caption: [Resultados obtidos para os três ensaios, calculados com a @eq-kinetic.],
) <tab-resultados>

A @tab-resultados resume os valores medidos e calculados.

== Diagramas de Blocos

#lorem(15)

#figure(
  diagram(
    node-stroke: 0.6pt,
    node-corner-radius: 3pt,
    spacing: 2.5em,
    node((0,0), [Sensor], shape: fletcher.shapes.rect),
    edge("->"),
    node((1,0), [Microcontrolador], shape: fletcher.shapes.rect),
    edge("->"),
    node((2,0), [Atuador], shape: fletcher.shapes.rect),
    edge((1,0), (1,1), "->"),
    node((1,1), [Registo de Dados], shape: fletcher.shapes.rect),
  ),
  caption: [Diagrama de blocos do sistema de aquisição de dados.],
) <fig-diagrama>

A @fig-diagrama mostra a arquitetura do sistema utilizado para a recolha dos
dados apresentados na @tab-resultados. Diagramas como este são desenhados com
o pacote #link("https://typst.app/universe/package/fletcher")[`fletcher`],
obtido automaticamente da Typst Universe na primeira compilação (é necessária
ligação à internet nessa altura).
