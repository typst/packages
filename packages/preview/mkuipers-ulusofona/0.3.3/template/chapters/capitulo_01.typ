#import "@preview/mkuipers-ulusofona:0.3.3": *

#chapter("Introdução", l: "intro")

#guidance[
Neste capítulo pretende-se que seja descrito o enquadramento prático e a envolvente do problema em análise por formulação detalhada do #emph[case study] a abordar no TFC.

Deverá ser demonstrado, de forma clara, que o problema em estudo resulta de circunstância reais e a solução a desenvolver representa um passo no sentido da solução desse mesmo problema

Valorizam-se os trabalhos cujo enquadramento seja fundamentado cientificamente ou suportado por terceiros. No presente contexto, entenda-se ‘terceiros' como elementos externos ao desenvolvimento da solução, podendo incluir, sem se limitar, possíveis utilizadores da solução a desenvolver, eventuais clientes duma versão comercial da solução.
]

== Enquadramento

#guidance[
_Exemplo de citação: este trabalho enquadra-se no regulamento do TFC @DEISI24, na Universidade Lusófona @ULHT21 e no departamento @DEISI24b; ver também @TaWe20. Apague esta nota._

Serve para situar o tema no contexto mais amplo, mostrando sua relevância na área de estudo. Apresentação de cada um dos conceitos (o que é) em torno dos quais o trabalho versa, incluindo referências bibliográficas relevantes.
]

== Motivação e Identificação do Problema
#guidance[
Explicar as motivações que levam a propor o presente trabalho, evidenciando por que o tema é importante ou interessante, podendo incluir motivações pessoais ou sociais para a pesquisa. Definir o problema que que se pretende resolver ou explorar.
]

== Objetivos
#guidance[
Apresentar os principais objetivos, tanto os gerais quanto os específicos, que guiam o trabalho.
]

== Estrutura do Documento
#guidance[
Apresenta uma visão geral da organização do documento, listando o que se fala em cada capítulo. No presente relatório está organizado da seguinte forma:

- No @pertinencia é apresentada a análise da viabilidade e pertinência do trabalho desenvolvido.

- Na Secção ...

- ...

- No Anexo ...

O @tab-entregas é indicativo de entregáveis para cada momento de avaliação, assumindo abordagem sequencial do desenvolvimento de TFC. Podendo ser adoptadas outras abordagens metodológicas (e.g.: metodologias ágeis), serão aceites outras organizações de entregas. Deve-se, no entanto, observar duas condições: (i) a 1ª entrega deverá manter os conteúdos indicados no quadro, por forma a permitir ao júri avaliar a pertinência do tema e a taxa de esforço esperada; (ii) a organização de conteúdos em cada entrega deve ter atenção aos critérios de avaliação de modo a garantir a uniformidade da avaliação
]

#figure(
  align(center)[#set text(size: 7pt, hyphenate: false)
  #set par(justify: false)
  #table(
    columns: (10.59%, 10.47%, 10.59%, 10.57%, 10.53%, 9.99%, 8.32%, 10.72%, 9.17%, 9.06%),
    align: (auto,auto,center,center,center,center,center,center,center,center,),
    table.header(table.cell(align: center)[#strong[Avaliação];], table.cell(align: center)[#strong[Tipo];], table.cell(align: center)[#strong[1. Introdução];], table.cell(align: center)[#strong[2. Pertinência e Viabilidade];], table.cell(align: center)[#strong[3.Especificação e Modelação];], table.cell(align: center)[#strong[4. Solução Desenvolvida];#footnote[Sempre que aplicável, inclui código funcional, a disponibilizar em repositório #emph[Git];];], table.cell(align: center)[#strong[5. Testes e Validação];], table.cell(align: center)[#strong[6.Método e Planeamento];], table.cell(align: center)[#strong[7.Resultados];], table.cell(align: center)[#strong[8.Conclusão];],),
    table.hline(),
    [#strong[1ª entrega Intercalar];], [Qualitativa;

    Júri cego

    ], table.cell(align: center)[Incluir], table.cell(align: center)[Incluir], table.cell(align: center)[incluir], table.cell(align: center)[incluir], table.cell(align: center)[N/A], table.cell(align: center)[Inicial], table.cell(align: center)[N/D], table.cell(align: center)[N/D],
    [#strong[2ª Entrega Intercalar];], [Qualitativa;

    Júri cego

    ], table.cell(align: center)[revisto], table.cell(align: center)[revisto], table.cell(align: center)[revisto], table.cell(align: center)[revisto], table.cell(align: center)[Incluir], table.cell(align: center)[revisto], table.cell(align: center)[N/D], table.cell(align: center)[N/D],
    [#strong[Final];#footnote[O relatório final deverá incluir todos os conteúdos desenvolvidos ao longo do TFC];], [Quantitativa;

    Presencial

    ], table.cell(align: center)[Final], table.cell(align: center)[Final], table.cell(align: center)[Final], table.cell(align: center)[Solução Proposta], table.cell(align: center)[Final], table.cell(align: center)[Final#footnote[Para a entrega final sugere-se a inclusão, em anexo, de todo os planos de trabalho anteriores com apreciação de progresso e avaliação das dificuldades encontradas na elaboração e cumprimento do planeamento];], table.cell(align: center)[Incluir], table.cell(align: center)[Incluir],
  )]
  , kind: table,
  caption: [Quadro de conteúdos por entrega.],
  ) <tab-entregas>
