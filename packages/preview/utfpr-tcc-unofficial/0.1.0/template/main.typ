#import "@preview/utfpr-tcc-unofficial:0.1.0": * 

// For graph plotting only
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"
#import cetz.draw: *
#import cetz-plot: *

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
    [IBGE], [Instituto Brasileiro de Geografia e Estatística],
    [NBR], [Normas Brasileiras], 
    [UTFPR], [Universidade Tecnológica Federal do Paraná],
  ),
  symbols: (
    [Ca], [Cálcio],
    [Mg], [Magnésio], 
    [T], [Temperatura],
    [V], [Volume], 
    [P], [Pressão],
  ),
// ↑↑↑ ELEMENTOS OPCIONAIS ↑↑↑ //
)

#abstract[
O resumo deve apresentar, de forma clara e objetiva, o conteúdo essencial do trabalho, abordando a justificativa, os objetivos, a metodologia empregada, os principais resultados e as conclusões. Deve ser escrito em um único parágrafo, com extensão entre 150 e 500 palavras, evitando o uso de citações, fórmulas, equações ou símbolos. As palavras-chave e keywords devem ser grafadas com inicial minúscula, exceto em casos de nomes próprios ou científicos.
]

#abstract-foreign[
A versão em língua estrangeira deve seguir o mesmo formato do resumo original, com a tradução fiel do texto e da referência, quando houver.
]

// ↓↓↓ ELEMENTOS OPCIONAIS ↓↓↓ //
#dedication[
  Dedico este trabalho à minha família, pelos momentos de ausência.
]

#acknowledgments[
Reconheço que estas palavras não serão suficientes para mencionar todas as pessoas que contribuíram para esta etapa tão significativa da minha vida. Peço, portanto, desculpas àquelas que não estão citadas diretamente, mas que certamente fazem parte da minha lembrança e da minha gratidão.

Expresso meus agradecimentos ao(à) Prof.(a) Dr.(a) [Nome Completo], meu(minha) orientador(a), pela orientação, paciência e conhecimento compartilhado ao longo deste percurso.

Aos colegas de sala, pela convivência e troca de experiências.

À Secretaria do Curso, pelo apoio e colaboração prestados.

Registro, ainda, meu profundo reconhecimento à minha família, cujo incentivo e compreensão foram fundamentais para que eu pudesse alcançar este objetivo.

//Não devem ser mencionadas empresas ou instituições que não tenham sido citadas no corpo do trabalho.
//Nos casos em que o estudo tenha recebido apoio financeiro da UTFPR ou de outras agências de fomento, como CAPES, CNPq ou Fundação Araucária, o último parágrafo dos Agradecimentos deve conter o nome da instituição financiadora e o número do respectivo auxílio. Esse deve ser o item final dessa seção.

]

#epigraph(attribution: [@candido2002formacao])[A biblioteca é um jardim onde as ideias florescem e os frutos são colhidos pela eternidade.]
// ↑↑↑ ELEMENTOS OPCIONAIS ↑↑↑ //

= Introdução

Introdução do texto, onde devem ser apresentados o tema, a definição dos limites do assunto abordado, os objetivos do estudo e demais informações necessárias para contextualizar o trabalho.

/*
Após o início de uma seção, recomenda-se incluir um texto introdutório ou, pelo menos, uma breve explicação sobre o conteúdo que será abordado. Deve-se evitar inserir outra seção imediatamente em seguida, como no exemplo:

= Introdução
= Contextualização
= Relato da pesquisa
*/

== Seção secundária
#lorem(20)

=== Seção terciária
#lorem(20)

==== Seção quaternária
#lorem(20)

===== Seção quinária
#lorem(20)


= Desenvolvimento

Parte central do trabalho, onde o tema é apresentado de forma organizada e detalhada. Inclui a revisão teórica, estruturada em seções e subseções, a descrição dos materiais e métodos (ou metodologia) utilizados e a exposição dos resultados, descritos de maneira completa. Cada seção ou subseção deve possuir um título coerente com o conteúdo apresentado.

O texto deve ser redigido sempre na terceira pessoa do singular, mantendo um tom impessoal.

== Ilustrações
Consideram-se ilustrações: *figuras*, *quadros*, *gráficos* e *fotografias*, que se diferenciam das *tabelas*.
Todas as figuras precisam ser mencionadas e contextualizadas no texto, como demonstrado na referência à @dimensoes.

#figure(
  image("media/imagem1.png", width: 50%), 
  caption: [As dimensões pedagógicas da educação infantil],
  source: [#cite(<azurva2020>, form:"prose")]
)<dimensoes>

A seguir, vemos um modelo de formatação de fotografia:

#figure(
  kind: "photograph",
  image("media/imagem2.png", width: 50%), 
  caption: [Entrada da UTFPR Campus Ponta Grossa],
  source:[Autoria própria (2025)],
)

A seguir, no @grafico, um modelo de formatação de gráfico:

#let data = (
      (value: 12, label: "Livros"),
      (value: 17, label: "Anais"),
      (value: 25, label: "Periódicos"),  
)

#figure(
  kind: "graph",

  // for more info (https://typst.app/universe/package/cetz-plot/)
  cetz.canvas(chart.piechart(
    data,
    value-key: "value",
    label-key: "label",
    slice-style: (gray, blue, orange),

    stroke: 0em,
    gap: 0.05,
    radius: 3,
    inner-label: (radius:1.5, content: "%"),
    outer-label: (content: none), 
  )),

caption: [Empréstimos feitos em janeiro de 2019 nas bibliotecas da UTFPR],
source: [#cite(<utfpr2020>, form: "prose")],
)<grafico>

A seguir, ilustra-se um modelo de formatação de quadros (prevalecem informações textuais).

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
  caption: [Campos de desenvolvimento de habilidades],
  source: [ Fluery e Fleury (#cite(<fleury2018>, form: "year"))],
)

== Tabelas
As tabelas distinguem-se dos quadros por não possuírem linhas de fechamento nas laterais.
#footnote[
Para orientações gerais sobre a formatação de tabelas, consulte: IBGE (Instituto Brasileiro de Geografia e Estatística). Normas de Apresentação Tabular. 3ª ed. Rio de Janeiro: IBGE, 1993. Disponível em: #link("http://biblioteca.ibge.gov.br/visualizacao/livros/liv23907.pdf")
]

// AVISO: use `#abnt-table()` ao criar tabelas para ter uma melhor experiencia
// Use apenas um header por tabela
#figure(
  abnt-table(
    columns: (2fr, 1fr, 1fr, 1fr, 1fr), 

    table.header(
      [*Média*], 
      table.cell(colspan: 2)[*CEFET*],
      table.cell(colspan: 2)[*BRASIL*],
      
      table.cell(align: left)[Curso], 
      [concluintes], 
      [ingressantes], 
      [concluintes], 
      [ingressantes],
    ),
    
    table.cell(align: left)[Matemática],
    [27,8], [22,5], [27,1], [22,4], 

    table.cell(align: left)[Letras],
    [32,3], [31,5], [30,9], [26,5], 

    table.cell(align: left)[Geografia],
    [38,4], [34,2], [34,6], [29,5], 

    table.cell(align: left)[Ciências Biológicas],
    [26,4], [23,6], [26,6], [21,9],

    table.cell(align: left)[Matemática],
    [27,8], [22,5], [27,1], [22,4], 

    table.cell(align: left)[Letras],
    [32,3], [31,5], [30,9], [26,5], 

    table.cell(align: left)[Geografia],
    [38,4], [34,2], [34,6], [29,5], 

    table.cell(align: left)[Ciências Biológicas],
    [26,4], [23,6], [26,6], [21,9],
  ), 
  caption: [Desempenho de estudantes em conhecimentos específicos],
  note: [As notas (quando existirem) devem ser exibidas antes da indicação da fonte de origem.],
  source: [#cite(<inep2016>, form: "prose")],
)

== Citações
É fundamental nesta etapa a ética e a honestidade intelectual, atribuindo autoria a quem realmente contribuiu para o desenvolvimento do estudo em questão. 

=== Exemplos:

- Citação direta curta: O autor, porém, recorda a análise pioneira de #cite(<leonardbarton1998>, form: "prose", supplement: [p.~48]) sobre alguns #quote[aspectos limitantes das competências, ou aptidões, essenciais, que as transformam em limitações estratégicas].

- Citação direta curta: o autor lembra, contudo, a análise precursora sobre alguns #quote(attribution: [@leonardbarton1998])[ aspectos limitantes das competências, ou aptidões, essenciais, que as transformam em limitações estratégicas].

- Citação direta longa (com mais de 3 linhas).

#quote(attribution: [@vonKrogh2001], block: true)[
  O contexto capacitante não significa necessariamente um espaço físico. Em vez disso, combina aspectos de espaço físico (como o projeto de um escritório ou operações de negócios dispersas), espaço virtual (e-mail, Intranets, teleconferências) e espaço mental (experiências, ideias e emoções compartilhadas). Acima de tudo, trata-se de uma rede de interações, determinada pela solicitude e pela confiança dos participantes
]

= Conclusão (ou considerações finais)

Seção conclusiva do texto, destinada à apresentação dos resultados e reflexões finais do estudo, também comumente intitulada Considerações Finais.



#appendix(include "assets/appendix1.typ", [Roteiro de entrevista])
#appendix(include "assets/appendix2.typ", [Questionário de pesquisa])
#annex(include "assets/annex1.typ", [Lei n. 9.610, de 19 de fevereiro de 1998])

#bibliography("references.bib")
