#import "@preview/ufscholar:0.1.3": *

#let acronyms = (
  (
    key: "abnt",
    short: "ABNT",
    long: "Associação Brasileira de Normas Técnicas",
  ),
  (
    key: "tcc",
    short: "TCC",
    long: "Trabalho de Conclusão de Curso",
    plural: "TCCs",
    longplural: "Trabalhos de Conclusão de Curso",
  ),
  (
    key: "pfc",
    short: "PFC",
    long: "Projeto de Fim de Curso",
  )
)

#let symbols = (
  (
    key: "circum",
    short: $C$,
    long: "Circumferência de um círculo",
  ),
  (
    key: "pi",
    short: $pi$,
    long: "Número pi",
  ),
  (
    key: "radius",
    short: $r$,
    long: "Raio de um círculo",
  ),
  (
    key: "area",
    short: $A$,
    long: "Área de um círculo",
  ),
)

#show: thesis.with(
  title: [Title of the dissertation\ Can be broken into two lines],
  subtitle: "Complementary subtitle, not more than two lines long",
  author: "Author's complete name",

  logo: image("assets/brasao_UFSC_vertical_sigla.svg", width: 5em),
  institution: [
   Federal University of Santa Catarina\
   Technology Center\
   Automation and Systems Engineering\
   Undergraduate Course in Control and Automation engineering
  ],
  contributors: (
   ("Prof. XXXXXX, Dr.", "Advisor", "UFSC/CTC/DAS"),
   ("XXXXXX, Eng.", "Supervisor", "Company/University XXXX"),
   ("Prof. XXXX, Dr.", "Evaluator", "Institution XXXX"),
   ("Prof. XXXX, Dr.", "Board President", "UFSC/CTC/DAS"),
   ("Prof. XXXX, Dr.", "Course Coordinator", none),
  ),
  cont-in-description: (0, 1),
  cont-in-board: (0, 1, 2, 3),

  address: ("Florianópolis", "Santa Catarina", "Brazil"),
  description: [Final report of the subject DAS5511 (Course Final Project) as a Concluding Dissertation of the Undergraduate Course in Control and Automation Engineering of the Federal University of Santa Catarina.],
  evaluation: [This dissertation was evaluated in the context of the subject DAS5511 (Course Final Project) and approved in its final form by the Undergraduate Course in Control and Automation Engineering],

  lang: "pt",
)

#dedicatory[
  This work is dedicated to my classmates and my dear parants.
]

#acknowledgments[
  I would like to express my gratitude to the team of Typst (Martin Haug, Laurenz Mädje, Ana Gelez and all contributors) for developing a modern typesetting system that made this template possible.

  Their work has enabled a streamlined, efficient workflow and laid the foundation upon which this project builds.
]

#epigraph[
  \"Text of the epigraph.\
  Citation related to the theme of the work.\
  It is optional. The epigraph may also appear\
  at the beginning of each section or chapter.\
  It must be prepared in accordance with NBR 10520."\
  (SURNAME of the author of the epigraph, year)
]

#disclaimer(
  place: "<Cidade da assinatura>",
  signer: "<Fulano de Tal>",
  institution: "<Instituição de realização do PFC>",
  date: datetime.today(),
  lang: "en",
)[
  As representative of the \<PFC institution of execution\> in which the present work was carried out, I declare this document to be exempt from any confidential or sensitive content regarding intellectual property, that may keep it from being published by the Federal University of Santa Catarina (UFSC) to the general public, including its online availability in the Institutional Repository of the University Library (BU). Furthermore, I attest knowledge of the obligation by the author, as a student of UFSC, to deposit this document in the said Institutional Repository, for being it a Final Program Dissertation ("_Trabalho de Conclusão de Curso_"), in accordance with the Resolução Normativa n° 126/2019/CUn.
]

#abstract(lang: "en")[
  The abstract must succinctly highlight the content of a text. The order and
  extent of the elements depend on the type of abstract (informative or
  indicative) and the treatment each item receives in the original document.
  Should consist of a sequence of concise sentences in a single paragraph,
  without itemized topics. In technical or scientific documents, the
  informative abstract is recommended. It is advisable to use the verb in the
  third person. Its length is recommended to be 150 to 500 words for academic
  works and technical and/or scientific reports; 100 to 250 words for journal
  articles; or 50 to 100 words for any other documents. Immediately below the
  abstract must appear the keywords, preceded by the phrase Keywords, followed
  by a colon, separated by semicolons, and ending with a period, all lowercase
  except for proper nouns and scientific names.

  *Keywords*: article; article example; abstract; ABNT; Brazilian norm.
]

// This command could be anywhere alse in the document.
#abstract(lang: "pt")[
  O resumo deve ressaltar sucintamente o conteúdo de um texto. A ordem e a
  extensão dos elementos dependem do tipo de resumo (informativo ou indicativo)
  e do tratamento que cada item recebe no documento original. Ele deve ser
  composto por uma sequência de frases concisas em parágrafo único, sem
  enumeração de tópicos. Em documento técnico ou científico, recomenda-se o
  resumo informativo. Convém usar o verbo na terceira pessoa. É recomendado que
  seu tamanho seja 150 a 500 palavras nos trabalhos acadêmicos e relatórios
  técnicos e/ou científicos; 100 a 250 palavras nos artigos de periódicos; ou
  50 a 100 palavras nos demais documentos. Logo abaixo do resumo devem aparecer
  as palavras-chave, antecedidas da expressão Palavras-chave, seguida de
  dois-pontos, separadas entre si por ponto e vírgula e finalizadas por ponto,
  em letras minúsculas exceto substantivos próprios e nomes científicos.

  *Palavras-chave*: artigo; exemplo de artigo; resumo; ABNT; norma brasileira.
]

#list-of-figures()
#list-of-tables()
#list-of-acronyms-and-symbols(acronyms, symbols)
#summary()

#part[Test]
#include "chapters/chapter_1.typ"
#include "chapters/chapter_2.typ"
#include "chapters/chapter_3.typ"
#include "chapters/chapter_4.typ"

#appendix[Descrição 1][
  Textos elaborados pelo autor, a fim de completar a sua argumentação. Deve ser precedido pela palavra APÊNDICE, identificada por letras maiúsculas consecutivas, travessão e pelo respectivo título. Utilizam-se letras maiúsculas dobradas quando esgotadas as letras do alfabeto.

  = Test

  #lorem(80)

  == Test

  #lorem(80)

  === Test

  #lorem(80)

  ==== Test

  #lorem(80)
]

#annex[Descrição 2][
  São documentos não elaborados pelo autor que servem como fundamentação (mapas, leis, estatutos). Deve ser precedido da palavra ANEXO, identificada por letras maiúsculas consecutivas, travessão e pelo respectivo título. Utilizam-se letras maiúsculas dobradas quando esgotadas as letras do alfabeto.

  = Test

  #lorem(100)

  = Test 2

  #lorem(100)

  == 3

  #lorem(100)
]
