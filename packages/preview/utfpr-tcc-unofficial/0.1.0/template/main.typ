#import "@preview/utfpr-tcc-unofficial:0.1.0": * 

#show: template.with(  
  title: [
    O título deve ser claro e preciso: subtítulo (se houver) deve ser precedido de dois pontos confirmando sua vinculação ao título
  ],
  title-foreign: [
    Título traduzido título traduzido
  ],

  lang: "pt",
  lang-foreign: "en",
  
  author: [NOME COMPLETO E POR EXTENSO DO(A) AUTOR(A)],
  city: [CIDADE],
  year: [ANO DA ENTREGA],

  description: [
      Trabalho de conclusão de curso de graduação/Dissertação/Tese apresentada como requisito para obtenção do título de Bacharel/Licenciado/Tecnólogo/Mestre/Doutor em Nome do Curso/Programa da Universidade Tecnológica Federal do Paraná (UTFPR).
    
      Orientador(a): Nome completo e por extenso.

      Coorientador(a): Nome completo e por extenso.
    ],

  keywords: ([palavra 1], [palavra 2], [palavra 3], [palavra 4]),
  keywords-foreign: ([word 1], [word 2], [word 3], [word 4]),

// ↓↓↓ ELEMENTOS OPCIONAIS ↓↓↓ //
  outline-figure: true,
  outline-table: true,
  abbreviations: (
    [ABNT], [Associação Brasileira de Normas Técnicas],
    [Coef.], [Coeficiente], 
    [IBGE], [Instituto Brasileiro de Geografia e Estatística],
    [NBR], [Normas Brasileiras], 
    [UTFPR], [Universidade Tecnológica Federal do Paraná],
  ),
  symbols: (
    [Ca], [Cálcio],
    [Mg], [Magnésio], 
    [T], [Temperatura],
    [V], [Voluma], 
    [P], [Pressão],
  ),
// ↑↑↑ ELEMENTOS OPCIONAIS ↑↑↑ //
)

#abstract[
  O resumo deve ressaltar de forma sucinta o conteúdo do trabalho, incluindo justificativa, objetivos, metodologia, resultados e conclusão. Deve ser redigido em um único parágrafo, contendo de 150 até 500 palavras.Evitar incluir citações, fórmulas, equações e símbolos no resumo. As palavras-chave e as _keywords_ são grafadas em inicial minúscula quando nãoforem nome próprio ou nome científico e separados por ponto e vírgula.
]

#abstract-foreign[
  Seguir o mesmo padrão do resumo, com a tradução do texto do resumo e referência, se houver, para a língua estrangeira.
]

// ↓↓↓ ELEMENTOS OPCIONAIS ↓↓↓ //
#dedication[
  Dedico este trabalho à minha família, pelos momentos de ausência.
]

#acknowledgments[
  Certamente estes parágrafos não irão atender a todas as pessoas que fizeram parte dessa importante fase de minha vida. Portanto, desde já peço desculpas àquelas que não estão presentes entre essas palavras, mas elas podem estar certas que fazem parte do meu pensamento e de minha gratidão.

  Agradeço ao(a) meu(minha) orientador(a) Prof.(a) Dr.(a) Nome Completo, pela sabedoria com que me guiou nesta trajetória.
  Aos meus colegas de sala.

  A Secretaria do Curso, pela cooperação.

  Gostaria de deixar registrado também, o meu reconhecimento à minha família, pois acredito que sem o apoio deles seria muito difícil vencer esse desafio.
]

#epigraph(attribution: [@candido2002formacao])[A biblioteca é um jardim onde as ideias florescem e os frutos são colhidos pela eternidade.]
// ↑↑↑ ELEMENTOS OPCIONAIS ↑↑↑ //

= Introdução

Parte inicial do texto, na qual devem constar o tema e a delimitação do assunto tratado, objetivos da pesquisa e outros elementos necessários para situar o tema do trabalho.

/*
Após o início de uma seção, recomenda-se a inserção de um texto ou, no mínimo, uma nota explicativa sobre a seção iniciada. Evitar colocar outra seção na sequência, por exemplo:

= Introdução
= Contextualização
= Memorial da pesquisa
*/

== Seção secundária (negrito)
#lorem(20)

=== Seção terciária (sem negrito)
#lorem(20)

==== Seção quaternária (sublinhado)
#lorem(20)

===== Seção quinária (itálico)
#lorem(20)



= Desenvolvimento

Parte principal do trabalho, que contém a exposição ordenada e pormenorizada do assunto. É composta de revisão de literatura, dividida em seções e subseções, material e métodos e/ou metodologia e resultados, agora descritos detalhadamente. Cada seção ou subseção deverá ter um título apropriado ao conteúdo.

Deve-se utilizar sempre a terceira pessoa do singular na elaboração do texto, mantendo-se a forma impessoal.

== Ilustrações
São ilustrações: *figuras, quadros, gráficos, fotografias* e diferenciam-se das *tabelas*.
Todas as figuras devem ser referenciadas ou referidas em texto, como feito com a @dimensoes nesse trecho escrito.

#figure(
  image("media/imagem1.png", width: 50%), 
  caption: [As dimensões curriculares de pré-escolar],
  source: [#cite(<azurva2020>, form:"prose")]
)<dimensoes>

A seguir, um modelo de formatação de fotografia:

#figure(
  kind: "photograph",
  image("media/imagem2.png", width: 50%), 
  caption: [Entrada da antiga Biblioteca da UTFPR Campus Ponta Grossa],
  source:[Autoria própria (2014)],
)

A seguir, um modelo de formatação de gráfico:

#figure(
  kind: "graph",
{
  import "@preview/cetz:0.3.2"
  import "@preview/cetz-plot:0.1.1"
  import cetz.draw: *
  import cetz-plot: *
  cetz.canvas({chart.piechart( 
    (17, 12, 25),
    radius: 2.5,
    slice-style: (gray, blue, orange),
    inner-label: (content: "%",))
  })},

caption: [Estatística de empréstimos em janeiro de 2019],
source: [#cite(<utfpr2020>, form: "prose")],
)

A seguir, um modelo de formatação de quadros (prevalecem informações textuais).

#figure(
  kind: "frame",
  table(
    columns: (1fr, 2fr), align: left,
     
    table.cell(align: center)[*Áreas de desenvolvimento*], 
    table.cell(align: center)[*Descrição*], 
    
    [\1. Competências sobre processos], 
    [Conhecimento nos processos de trabalho], 

    [\2. Competências técnicas], 
    [Conhecimento técnico nas tarefas a serem desempenhadas e tecnologias empregadas nestas tarefas], 

    [\3. Competências sobre a organização], 
    [Saber organizar os fluxos de trabalho], 

    [\4. Competências de serviço], 
    [Aliar as competências técnicas com o impacto que estas ações terão para o cliente consumidor], 
    
    [\5. Competências sociais], 
    [Atitudes que sustentam o comportamento do indivíduo: saber comunicar-se e responsabilizar-se pelos seus atos.],
  ), 
  caption: [Áreas de desenvolvimento de competências],
  source: [ #cite(<fleury2018>, form: "prose")],
)

== Tabelas
As tabelas se diferenciam dos quadros por não apresentarem os fechamentos laterais 
#footnote[
  Para as regras gerais de apresentação das tabelas consultar: IBGE (Instituto Brasileiro de Geografia e Estatística). *Normas para Apresentação Tabular.* 3. ed. Rio de Janeiro: IBGE, 1993. Disponível em: #link("http://biblioteca.ibge.gov.br/visualizacao/livros/liv23907.pdf")
].

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr), 

    table.header(
      [Média], 
      table.cell(colspan: 2)[CEFET],
      table.cell(colspan: 2)[BRASIL],
      
      [Curso], 
      [concluintes], 
      [ingressantes], 
      [concluintes], 
      [ingressantes],
    ),
    [Matemática],          [27,8], [22,5], [27,1], [22,4], 
    [Letras],              [32,3], [31,5], [30,9], [26,5], 
    [Geografia],           [38,4], [34,2], [34,6], [29,5], 
    [Ciências Biológicas], [26,4], [23,6], [26,6], [21,9],
  ), 
  caption: [Desempenho dos alunos na prova de conhecimentos específicos],
  note: [As notas (quando houver) deverão ser apresentadas antes da apresentação da fonte.],
  source: [#cite(<inep2016>, form: "prose")],
)

/* ============================ /*
  WORK IN PROGRESS:
    Para tabelas que ocupam mais de uma folha: 
    deve-se repetir a legenda, 
    na primeira parte não apresentar a linha de
    fechamento e inserir as sinalizações: 
    continua, 
    continuação (quando ocupar mais de 2 folhas)
    e conclusão.
*/ ============================ */

== Citações
É fundamental nesta etapa a ética e a honestidade intelectual, atribuindo autoria a quem realmente contribuiu para o desenvolvimento do estudo em questão. 

=== Exemplos:

- Citação direta curta: o autor lembra, contudo, a análise precursora de #cite(<leonardbarton1998>, form: "prose", supplement: [p.~48]) sobre alguns “aspectos limitantes das competências, ou aptidões, essenciais, que as transformam em limitações estratégicas”.

- Citação direta curta: o autor lembra, contudo, a análise precursora sobre alguns #quote(attribution: [@leonardbarton1998])[ aspectos limitantes das competências, ou aptidões, essenciais, que as transformam em limitações estratégicas].

- Citação direta longa (com mais de 3 linhas).

#quote(attribution: [@vonKrogh2001], block: true)[
  O contexto capacitante não significa necessariamente um espaço físico. Em vez disso, combina aspectos de espaço físico (como o projeto de um escritório ou operações de negócios dispersas), espaço virtual (e-mail, Intranets, teleconferências) e espaço mental (experiências, ideias e emoções compartilhadas). Acima de tudo, trata-se de uma rede de interações, determinada pela solicitude e pela confiança dos participantes
]

= Conclusão (ou considerações finais)

Parte final do texto, na qual se apresentam as conclusões do trabalho acadêmico, usualmente denominada Considerações Finais. Pode ser usada outra denominação similar que indique a conclusão do trabalho.

#appendix(include "assets/appendix1.typ", [Roteiro de entrevista])
#appendix(include "assets/appendix2.typ", [Questionário de pesquisa])
#annex(include "assets/annex1.typ", [Lei n. 9.610, de 19 de fevereiro de 1998])

#bibliography("references.bib")
