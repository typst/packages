// =====================================================================================================================
// Modelo de trabalho acadêmico nas normas da ABNT (NBR 14724:2024), com o pacote abntly.
//
// Como usar este arquivo:
//   1. Preencha os dados do trabalho em `config-info`, logo abaixo.
//   2. Percorra os elementos na ordem em que aparecem. Cada um está marcado como [OBRIGATÓRIO] ou [OPCIONAL],
//      com a seção da norma que trata dele.
//   3. Os elementos opcionais que você não usar podem ser apagados. Os blocos que começam com `//` estão
//      desativados: para ativar um bloco, apague o `//` do início de cada linha dele.
//   4. Substitua o texto das seções pelo seu. O texto deste modelo explica o formato de cada elemento e pode ser
//      consultado enquanto você escreve.
//
// O manual do pacote descreve cada função e o que a norma pede de cada elemento:
// https://github.com/lucaslrodri/abntly
// =====================================================================================================================
#import "@preview/abntly:0.1.1": *

// --- Configuração do trabalho ---------------------------------------------------------------------------------------
// A função `abntly` aplica a formatação da ABNT a todo o documento: página A4, margens, fontes, espaçamentos,
// numeração das páginas e das seções, ilustrações, citações e referências.
#show: abntly.with(
  // Dados do trabalho, usados na capa, na folha de rosto, na folha de aprovação e na ficha catalográfica.
  info: config-info(
    title: [Título do trabalho],                         // [OBRIGATÓRIO]
    subtitle: [subtítulo, se houver],                    // [OPCIONAL] impresso depois de dois-pontos
    author: "Nome do Autor",                             // [OBRIGATÓRIO] ou (name: "Nome do", surname: "Autor")
    advisor: "Prof. Dr. Nome do Orientador",             // [OBRIGATÓRIO] orientadora: (name: "...", gender: "f")
    // co-advisor: "Profa. Dra. Nome da Coorientadora",  // [OPCIONAL]
    institution: [Universidade do Brasil],
    program: [Programa de Pós-Graduação em Engenharia],
    // area: [Sistemas de energia],                      // [OPCIONAL] área de concentração
    location: [Rio Branco],                              // [OBRIGATÓRIO] cidade da instituição
    year: 2026,                                          // [OBRIGATÓRIO] ano de depósito; `auto` usa o ano atual
    work-type: "dissertation",                           // "tcc", "dissertation", "thesis", ...
    // version: [Versão corrigida],                      // [OPCIONAL] impressa abaixo do título
    // volume: 1,                                        // [OPCIONAL] trabalhos com mais de um volume
    // logo: image("marca.svg", width: 2cm),             // [OPCIONAL] marca da instituição, no topo da capa
  ),
  // As opções abaixo estão com o valor padrão. Apague o `//` da linha para alterar uma delas.
  // lang: "en",                     // idioma do trabalho: "pt" (padrão) ou "en"
  // two-sided: true,                // impressão em frente e verso: margens espelhadas, seções em página ímpar
  // hyperlink: black,               // cor dos links; use `black` para imprimir e `none` para remover os links
  // citation-system: "num",         // sistema de chamada: "alf" (autor-data, padrão), "num", "overcite" ou "ieee"
  // equation-numbering: "(1)",      // numeração das equações: "(1.1)" (por seção primária, padrão) ou "(1)"
  // table-font-size: 1em,           // tamanho do texto das tabelas: `10em / 12` (padrão) ou `1em`
)

// O que não é opção da função principal é alterado com regras `set` e `show`, depois da chamada acima:
// #set text(size: 11pt)                        // tamanho do texto; os demais tamanhos são proporcionais
// #show heading.where(level: 1): upper         // títulos das seções primárias em maiúsculas, como no sumário

// =====================================================================================================================
// ELEMENTOS PRÉ-TEXTUAIS (NBR 14724:2024, seção 4.2.1), na ordem da norma
// =====================================================================================================================

// --- Capa [OBRIGATÓRIO] (seção 4.1.1) -------------------------------------------------------------------------------
// Instituição, autor, título, subtítulo, local e ano, a partir dos dados acima.
#cover()

// --- Folha de rosto [OBRIGATÓRIO] (seção 4.2.1.1) -------------------------------------------------------------------
// O conteúdo é a natureza do trabalho: tipo, objetivo e instituição a que é submetido.
#title-page[
  Dissertação apresentada ao Programa de Pós-Graduação em Engenharia da Universidade do Brasil, como requisito
  parcial para a obtenção do título de Mestre em Engenharia.
]

// --- Ficha catalográfica [OBRIGATÓRIO] (seção 4.2.1.1.2) ------------------------------------------------------------
// Fica no verso da folha de rosto. A ficha gerada é provisória; a definitiva é emitida pela biblioteca:
// #catalog-card(card: image("ficha.pdf", width: 13.5cm))
#catalog-card()

// --- Errata [OPCIONAL] (seção 4.2.1.2) ------------------------------------------------------------------------------
// #errata[
//   AUTOR, Nome do. *Título do trabalho*: subtítulo. 2026. 120 f. Dissertação (Mestrado) -- Universidade do Brasil,
//   Rio Branco, 2026.
//
//   #align(center, table(columns: 4, align: left, stroke: 0.4pt,
//     table.header([*Folha*], [*Linha*], [*Onde se lê*], [*Leia-se*]),
//     [16], [10], [auto-clavado], [autoclavado],
//   ))
// ]

// --- Folha de aprovação [OBRIGATÓRIO] (seção 4.2.1.3) ---------------------------------------------------------------
// Antes da defesa, a folha é provisória (com carimbo e sem data). Depois da aprovação, informe
// `date: [30 de setembro de 2026]` e `draft: false`.
#approval-page(
  (title: [Prof. Dr.], name: [Nome do Orientador], role: [Orientador], institution: [Universidade do Brasil]),
  (title: [Profa. Dra.], name: [Nome da Convidada], role: [Convidada], institution: [Outra Universidade]),
  (title: [Prof. Dr.], name: [Nome do Convidado], role: [Convidado], institution: [Instituto de Pesquisa]),
)

// --- Dedicatória [OPCIONAL] (seção 4.2.1.4) -------------------------------------------------------------------------
// #dedication[
//   Este trabalho é dedicado aos meus pais, \
//   que me ensinaram a ler.
// ]

// --- Agradecimentos [OPCIONAL] (seção 4.2.1.5) ----------------------------------------------------------------------
// #acknowledgments[
//   Agradeço ao meu orientador, pela leitura atenta de cada versão deste trabalho.
//
//   Agradeço aos colegas do laboratório e à minha família, pelo apoio.
// ]

// --- Epígrafe [OPCIONAL] (seção 4.2.1.6) ----------------------------------------------------------------------------
// #epigraph[
//   _“Texto da epígrafe.”_ \
//   (Autor da epígrafe)
// ]

// --- Resumo na língua vernácula [OBRIGATÓRIO] (seção 4.2.1.7; NBR 6028:2021) ----------------------------------------
// Um único parágrafo, de 150 a 500 palavras, seguido das palavras-chave. A ABNT não fixa quantas são: a NBR 6028:2021
// só diz como grafá-las (o exemplo dela tem cinco); o "de três a cinco" é regra da instituição ou do periódico.
#abstract[
  O resumo apresenta, em um único parágrafo, o objetivo, o método, os resultados e as conclusões do trabalho. A
  NBR 6028:2021 recomenda de 150 a 500 palavras para os trabalhos acadêmicos e o uso do verbo na terceira pessoa.
  As palavras-chave são informadas logo abaixo do texto, uma em cada par de colchetes, com iniciais minúsculas,
  exceto os nomes próprios.

  #keywords[trabalhos acadêmicos][normalização][ABNT][Typst]
]

// --- Resumo em língua estrangeira [OBRIGATÓRIO] (seção 4.2.1.8) -----------------------------------------------------
// `lang` define o título ("Abstract"), o rótulo das palavras-chave e a hifenização.
#abstract(lang: "en")[
  The abstract presents, in a single paragraph, the aim, the method, the results and the conclusions of the work.
  It is the translation of the abstract in the language of the work, followed by its keywords.

  #keywords[academic works][standardization][ABNT][Typst]
]

// --- Listas [OPCIONAL] (seções 4.2.1.9 a 4.2.1.12) ------------------------------------------------------------------
// A norma recomenda uma lista para cada tipo de ilustração. Apague as listas que o trabalho não usar.
#list-of-figures()
#list-of-frames()
#list-of-tables()

// Lista de abreviaturas e siglas. Com a chave (`key`), a sigla é citada no texto como `@abnt`: a primeira menção
// escreve o nome completo e a sigla; as seguintes, só a sigla.
#list-of-acronyms(
  (key: "abnt", short: "ABNT", long: [Associação Brasileira de Normas Técnicas]),
  (key: "ibge", short: "IBGE", long: [Instituto Brasileiro de Geografia e Estatística]),
)

// Lista de símbolos, na ordem em que aparecem no texto.
// #list-of-symbols(
//   ($a$, [Primeiro cateto]),
//   ($c$, [Hipotenusa]),
// )

// --- Sumário [OBRIGATÓRIO] (seção 4.2.1.13; NBR 6027:2012) ----------------------------------------------------------
#outline()

// =====================================================================================================================
// ELEMENTOS TEXTUAIS [OBRIGATÓRIO] (seção 4.2.2): introdução, desenvolvimento e conclusão
// =====================================================================================================================
// A numeração das páginas aparece a partir da primeira seção primária numerada. Os títulos das seções são escritos
// com `=` (primária), `==` (secundária), até `=====` (quinária).

= Introdução

Este modelo mostra a estrutura de um trabalho acadêmico formatado conforme as normas da @abnt e explica o formato
de cada elemento. Substitua este texto pelo texto do seu trabalho. A introdução apresenta o tema, os objetivos e
as razões da elaboração do trabalho.

O texto é composto em tamanho 12, com espaçamento de 1,5 entre as linhas, e cada parágrafo começa com um recuo na
primeira linha. Nada disso precisa ser configurado: basta escrever os parágrafos, separados por uma linha em
branco.

= Desenvolvimento

O desenvolvimento detalha a pesquisa ou o estudo realizado. A norma não define os títulos das seções: eles ficam a
critério do autor. As seções a seguir mostram como escrever cada elemento do texto.

== Seções e alíneas

Cada seção primária começa em uma página nova. Os títulos são numerados automaticamente, até a seção quinária.
Os assuntos de uma seção que não têm título próprio são divididos em alíneas, escritas com `+`:
+ o texto que antecede as alíneas termina em dois-pontos;
+ cada alínea começa por letra minúscula e termina em ponto e vírgula:
  - as subalíneas são escritas com `-`, dentro de uma alínea;
  - a alínea que antecede as subalíneas termina em dois-pontos;
+ a última alínea termina em ponto final.

== Citações e notas

As obras citadas são registradas no arquivo `refs.bib` e citadas pela chave. A chamada entre parênteses é escrita
como `@luck2010` e produz @luck2010; com a página, @luck2010[p. 12]. Quando o autor faz parte da frase, usa-se a
forma #cite(<tavares1953>, form: "prose"). A citação direta de até três linhas fica no texto, entre aspas. A
citação direta com mais de três linhas é destacada, com recuo de 4 cm, letra menor e espaço simples:

#quote(block: true)[
  Texto de uma citação direta com mais de três linhas. A citação é destacada do parágrafo, sem aspas, e a
  indicação da fonte, com a página, vem no fim do texto @abnt2024[p. 9].
]

As notas de rodapé são escritas com `#footnote[...]`.#footnote[As notas são numeradas ao longo de cada seção
  primária e ficam separadas do texto por um filete de 5 cm.]

== Ilustrações

Toda ilustração tem, acima dela, a palavra designativa, o número e o título; abaixo, a fonte, que é obrigatória
mesmo quando a ilustração é do próprio autor, e, se houver, a legenda e as notas. A #auto-ref(<fig-exemplo>) mostra
uma figura. No lugar do retângulo, use `image("arquivo.png", width: 8cm)`.

#figure(caption: [Título da figura])[
  #rect(width: 8cm, height: 3cm, fill: luma(220))
  #source()                                  // "Fonte: Elaboração própria."; ou #source[IBGE (2025).]
  // #legend[Barras: número de trabalhos.]   // [OPCIONAL]
  // #note[Dados coletados em 2025.]         // [OPCIONAL]
] <fig-exemplo>

O quadro apresenta informações textuais, em linhas fechadas, como o @qua-exemplo[Quadro].

#frame(caption: [Tipos de trabalho acadêmico])[
  #table(columns: 2,
    [*Tipo*], [*Grau*],
    [Trabalho de conclusão de curso], [Graduação],
    [Dissertação], [Mestrado],
    [Tese], [Doutorado])
  #source()
] <qua-exemplo>

== Tabelas

A tabela apresenta dados numéricos e segue as normas de apresentação tabular do @ibge: traços horizontais no
topo, abaixo do cabeçalho e no fim, sem traços nas laterais. Dentro da função `fitted`, a tabela com cabeçalho
(`table.header`) recebe os traços automaticamente, como a @tab-exemplo[Tabela]. Uma tabela que não cabe na página
continua na página seguinte, com o cabeçalho repetido. Fora da função `fitted`, uma tabela em um `figure` comum
recebe os mesmos traços escrita com `ibge-table`, no lugar de `table`; o título e a fonte ficam na largura do texto.

#fitted(label: <tab-exemplo>, caption: [Trabalhos defendidos, por tipo -- Universidade do Brasil -- 2024-2025])[
  #table(columns: (5cm, 2.5cm, 2.5cm), align: (left, right, right),
    table.header([Tipo], [2024], [2025]),
    [Dissertações], [86], [94],
    [Teses #call(1)], [34], [41])
  #source()
  #note(call: 1)[Inclui as teses defendidas em cotutela.]   // nota específica, ligada à chamada da célula
]

== Equações e remissões

Uma equação destacada é numerada quando tem um rótulo:
$ a^2 + b^2 = c^2 $ <eq-pitagoras>

#no-indent[em que $c$ é a hipotenusa. O texto que continua uma equação depois de uma linha em branco começa sem o
  recuo da primeira linha com `no-indent`.]

A remissão `@eq-pitagoras` produz o número, como em @eq-pitagoras. Para as figuras, as tabelas e as seções, a
remissão pode levar a palavra (`@fig-exemplo[Figura]`) ou encontrá-la sozinha, com `#auto-ref(<fig-exemplo>)`.

// Elementos que as normas não definem, descritos no manual:
// #algorithm(caption: [Título do algoritmo])[...]          // código ou pseudocódigo, com título e fonte
// #subfigures(figure(...), <a>, figure(...), <b>, caption: [Título])   // figura com partes (a), (b)
// #sideways[...]                                            // figura ou tabela deitada, em página própria
// #part[Título da parte]                                    // página de abertura de uma parte

= Conclusão

A conclusão retoma os objetivos do trabalho e apresenta os resultados alcançados.

// =====================================================================================================================
// ELEMENTOS PÓS-TEXTUAIS (seção 4.2.3), na ordem da norma
// =====================================================================================================================

// --- Referências [OBRIGATÓRIO] (seção 4.2.3.1; NBR 6023:2025) -------------------------------------------------------
// A lista contém as obras de `refs.bib` citadas no texto, em ordem alfabética.
#bibliography("refs.bib")

// --- Glossário [OPCIONAL] (seção 4.2.3.2) ---------------------------------------------------------------------------
// #glossary(
//   ("mancha gráfica", [área da página delimitada pelas margens, onde o texto é impresso]),
//   ("Typst", [sistema de composição tipográfica por marcação]),
// )

// --- Apêndices [OPCIONAL] (seção 4.2.3.3) ---------------------------------------------------------------------------
// Textos elaborados pelo autor. Depois da regra, cada título primário é um apêndice: "APÊNDICE A — Título".
// #show: appendix
//
// = Título do primeiro apêndice
//
// Texto do apêndice.

// --- Anexos [OPCIONAL] (seção 4.2.3.4) ------------------------------------------------------------------------------
// Textos não elaborados pelo autor. Depois da regra, cada título primário é um anexo: "ANEXO A — Título".
// #show: annex
//
// = Título do primeiro anexo
//
// Texto do anexo.

// --- Índice [OPCIONAL] (seção 4.2.3.5; NBR 6034:2004) ---------------------------------------------------------------
// As entradas e as páginas são informadas pelo autor, com o trabalho pronto.
// #index(
//   (term: "Ilustração", pages: (5, "6-7"), sub: ((term: "quadro", pages: 6),)),
//   (term: "Figura", see: "Ilustração"),
//   ("Tabela", 7),
// )
