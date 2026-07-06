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
    first_name: [Alice],
    middle_name: [de Exemplo],
    last_name: [Almeida],
    gender: "f",
    curriculum: [
      Universidade de Exemplo, Mestre em Preenchimento de Espaços.
      E-mail: #link("mailto:alice@email.com").
    ],
  ),
  (
    first_name: [Eduardo],
    middle_name: none,
    last_name: [Exemplo],
    gender: "m",
    curriculum: [
      Universidade de Exemplo, Bacharel em Completude de Texto.
      E-mail: #link("mailto:eduardo@email.com").
    ],
  ),
)
