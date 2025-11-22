#import "@preview/min-article:0.1.0": article, abstract, abbrev, gloss, appendix, annex, acknowledgments, figure

#show: article.with(  
	title: [Main Title],
	subtitle: "Complementary subtitle, not more than two lines long",
	foreign-title: "Título Principal",
	foreign-subtitle: "Subtítulo complementar, com não mais que duas linhas",
	authors: (
	  ("Main Author", "PhD in Procrastination with a minor in Doing Nothing. Professor at Lazy University."),
	  ("Main Collaborator", "Degree in Doing Nothing and researcher at Lazy University."),
	  ("Collaborator", "Procrastination Student at Lazy University.")
	),
	lang-foreign: "pt",
)

// This command could be anywhere else in the document.
#abstract("main")[
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

  Keywords: article; article example; abstract; ABNT; Brazilian norm.
]

// This command could be anywhere else in the document.
#abstract("foreign")[
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
  
  Palavras-chave: artigo; exemplo de artigo; resumo; ABNT; norma brasileira.
]

#pagebreak()

= Primary section

#lorem(75)

== Secondary section

#lorem(75)

=== Tertiary section

#lorem(75)

==== Quaternary section

#lorem(75)

===== Quinary section

#lorem(75)

#pagebreak()

= Math

#lorem(24)

$ sum_0^10 $

Inline math: $sum_0^10$. #lorem(21)

= Figures

#lorem(24)

#figure(
  kind: "board",
  supplement: "Board",
  caption: "A figure example",
  source: "Author (2025)",
  rect[Let's pretend there is something here]
)

#lorem(24)

= Tables

#lorem(24)

#figure(
  kind: "table",
  supplement: "Table",
  caption: "Example of table inside a figure",
  source: "Author (2025)",
  table(
    columns: 3,
    table.header(
      [Things], [Stuff], [Results],
    ),
    [Some thing], [Some stuff], [Some result],
    [Another thing], [Another stuff], [Another result]
  )
)

#lorem(24)

= Bibliographies

This is a bibliographic citation: @vozes

#rect(stroke: (paint: luma(150), dash: "dashed"))[
  // The bibliography command appears exactly where is written.
  #bibliography("assets/bib.yml")
]

This text is written after the bibliography in the article source code and
appears after it in the result. Refer to `docs/manual.typ` and `docs/example.typ`
to better understand this behavior.

= Glossary and abbreviations

// These "abbrev" and "gloss" commands could be anywhere in the document.

Abbreviations with definitions are automatically included in the glossary:
#abbrev("abnt")[Associação Brasileira de Normas Técnicas][Brazilian association
responsible for technical standardization.]

Abbreviations without definitions are automatically included as well:
#abbrev[idk][I don't know]

Glossary terms are automatically included too:
#gloss[saudade][Brazilian word with no direct translation; represents a
feeling of longing for a known someone or something, and a strong desire to
have this someone or something back.]

As to abbreviations, if the same abbreviation is used again it will be
automatically retrieved: #abbrev[abnt]

// These "appendix" commands could be anywhere else in the document.

#appendix(include("assets/appendix.typ"))

#appendix[
  = Even More Extra Data
  
  #lorem(100)
]

// These "annex" commands could be anywhere else in the document.

#annex(include("assets/annex.typ"))

#annex[
  = Another Important Third-party Document
  
  #lorem(150)
]


// This command could be anywhere else in the document.
#acknowledgments[
   That's all folks! \
   Thank you for your time.
]