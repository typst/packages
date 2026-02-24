#let abstract() = {
  block(
    fill: none,
    stroke: rgb("CCCCCC"),
    inset: 8pt,
    outset: 5pt,
    radius: 10pt,
    [#heading(numbering: none, outlined: false)[Résumé]
      #lorem(70)

      #underline()[*Mots clés*] : #lorem(5)],
  )

  v(2em + 1em)

  block(
    fill: rgb("EEEEEE"),
    stroke: none,
    inset: 8pt,
    outset: 5pt,
    radius: 10pt,
    [#heading(numbering: none, outlined: false)[Abstract]
      #text(
        fill: black,
        lang: "en",
        region: "us",
        // for English: lang: 'en' and region: 'us'
        // For other languages/regions, refer to this page:
        // lang: https://en.wikipedia.org/wiki/ISO_639
        // region: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
      )[
        #lorem(70)

        #underline()[*Keywords*]: #lorem(5)]],
  )
}

