// # Article metadata. Metadados para artigo.
// This file contains metadata for an article.
// For the optional fields, you can leave them empty or comment the square brackets.

// Title — required.
// Título — obrigatório.
#let title = {
  [Guia de redação]
}

// Subtitle — optional.
// Subtítulo — opcional.
#let subtitle = {
  [artigo científico]
}


// Authors — required.
// Autores — obrigatório.
#let authors = (
  (
    first_name: [Gabriel],
    middle_name: none,
    last_name: [Malosto],
    gender: "m",
    curriculum: [
      Universidade Federal de Juiz de Fora, Mestrando em Ciência da Computação, PPGCC.
      E-mail: #link("mailto:professional@gabdumal.com").
    ],
  ),
  (
    first_name: [Alice],
    middle_name: [de Exemplo],
    last_name: [Almeida],
    gender: "f",
    curriculum: [
      Universidade de Exemplo, Mestre em Preenchimento de Espaços.
      E-mail: #link("mailto:alice@email.com").
    ],
  ),
)
