// # Abstract. Resumo.
// NBR 14724:2024 4.2.1.7, NBR 14724:2024 4.2.1.8

#import "../style/style.typ": leading_for_common_text

#let include_abstract = (
  keywords_title: { "Palavras-chave" },
  keywords: {
    (
      "primeira palavra-chave",
      "segunda palavra-chave",
      "terceira palavra-chave",
    )
  },
  title: { "Resumo" },
  body: { "Conteúdo do resumo." },
) => {
  [
    #heading(
      numbering: none,
      outlined: false,
    )[
      #title
    ]

    #align(left)[
      #body
      #v(leading_for_common_text)

      // NBR 6028:2021
      // Keywords are preceded by a title and colon.
      // Keywords are separated by semicolons and end with a period.
      // Keywords are not capitalized.
      #par(
        first-line-indent: 0cm,
      )[
        #text(weight: "bold")[#keywords_title:]
        #keywords.join("; ").
      ]
    ]
  ]
}
