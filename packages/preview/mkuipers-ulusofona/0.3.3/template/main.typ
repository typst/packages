// Example TFC (Trabalho Final de Curso) report, pre-filled with the
// official DEISI guidance text. Text on a grey background is placeholder
// guidance (wrapped in #guidance[...]): replace it with your own content,
// removing the wrapper, and delete the sections that do not apply.
// The last annex (chapters/anexo_exemplos.typ) shows how to write lists,
// figures, tables and references; delete it before submitting.
// Other examples (lab report) are in examples/.
#import "@preview/mkuipers-ulusofona:0.3.3": *

#show: ulthesis.with(
  title: "Título do Trabalho",
  type: "Trabalho Final de Curso",
  subtype: "Relatório Intercalar 1º Semestre",
  date: "Janeiro 2026",
  authors: (
    (name: "Nome do Aluno", number: "p0000", course: "LEI"),
    (name: "Nome do Aluno", number: "p0000", course: "LEI"),
  ),
  supervisors: ("Nome do Orientador", "Nome do Co-orientador"),
  external: "Nome da Entidade Externa",  // Remove if there is no external entity
  lang: "pt",
  toc-depth: 2,
  glossary-data: yaml("glossary.yaml"),
  glossary-unused: true,  // Show every glossary entry; remove to list only the ones used
  acknowledgements: [
    #guidance[Agradecimentos.]
  ],
  abstract-pt: [
    #guidance[
      O resumo tem no máximo uma página. Pode ter como base a descrição da
      proposta de TFC disponível na plataforma.
    ]
  ],
  keywords-pt: ("palavra 1", "palavra 2", "palavra 3"),  // Optional
  abstract-en: [
    #guidance[
      Abstract in English.
    ]
  ],
  keywords-en: ("keyword 1", "keyword 2", "keyword 3"),  // Optional
)

// Chapters
#include("chapters/capitulo_01.typ")
#include("chapters/capitulo_02.typ")
#include("chapters/capitulo_03.typ")
#include("chapters/capitulo_04.typ")
#include("chapters/capitulo_05.typ")
#include("chapters/capitulo_06.typ")
#include("chapters/capitulo_07.typ")
#include("chapters/capitulo_08.typ")

// Aftermatter
#my-bibliography(bibliography("bibliography.yaml"))

#show: appendices.with("Anexo")

#chapter("Guião de Testes")

#guidance[
Incluir aqui o guião detalhado de testes, com descrição de cenários e resultados.
]

#include("chapters/anexo_exemplos.typ")
