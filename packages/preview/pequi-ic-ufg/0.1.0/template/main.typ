#import "@preview/pequi-ic-ufg:0.1.0": *
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages
#show: codly.lang-set_(languages: codly-languages)
#show raw.where(block: true): codly.new

#show: report.with(
  title: "Modelo de Relatório Final de IC - UFG",
  authors: (
    (name: "Autor(a) A", email: "estudante@discente.ufg.br", affiliation: "Unidade Acadêmica", role: "Estudante"),
    (name: "Autor(a) B", email: "orientador@ufg.br", affiliation: "Unidade Acadêmica", role: "Orientador(a)"),
    (name: "Autor(a) C", email: "coorientador@ufg.br", affiliation: "Unidade Acadêmica", role: "Co-orientador(a)"),
  ),
)

= Resumo
#lorem(60)

= Apresentação <apresentacao>
#lorem(65)
@BocchiMVY19
#lorem(25)

= Metodologia <metodologia>
#lorem(40)
#figure(
  image("images/graphic.png", width: 50%),
  caption: [Dados interessantes]
) <Fig1>
#lorem(40)
@Fig1 tem dados interessantes.

= Resultados e discussão <resultados>
#lorem(70)
Como dito na @metodologia, existem dados interessantes.

== Trabalhos futuros
#lorem(40)

= Conclusão ou Considerações finais <conclusao>
#lorem(20)

#pagebreak()

// full: true para mostrar também as referências que não estão sendo usadas
#bibliography("references/references.bib", title: "Referências Bibliográficas", style: "references/sbc.csl", full: true)

#pagebreak()

= Certificados
#align(center)[
  #image("images/certificate.png", width: 80%)
]

#pagebreak()

// Remove underline
#show underline: it => {it.body}
#show: appendix

= Textos
== #link(<apendice>)[Lorem Ipsum]
#include "appendix/app1.typ"

= Códigos
== #link(<apendice>)[Olá, mundo!]
#include "appendix/app2.typ"
