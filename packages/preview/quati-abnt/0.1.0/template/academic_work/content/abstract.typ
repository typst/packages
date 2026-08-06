// # Abstract. Resumo.
// NBR 14724:2024 4.2.1.7, NBR 14724:2024 4.2.1.8

#import "../packages.typ": glossarium, quati-abnt.academic_work.pages.include_abstract_page


// ## Abstract in main language. Resumo em língua principal.
#let abstract_in_main_language = {
  (
    keywords_title: "Palavras-chave",
    keywords: (
      "modelo",
      "trabalho acadêmico",
      "ABNT",
      "Typst",
    ),
    title: "Resumo",
    body: [
      Este exemplo apresenta o uso do `quati-abnt`, modelo de artigo para o Typst segundo as @nbr:pl da @abnt.
    ],
  )
}


// ## Abstract in foreign language. Resumo em língua estrangeira.
#let first_abstract_in_foreign_language = {
  (
    keywords_title: "Keywords",
    keywords: (
      "template",
      "academic work",
      "ABNT",
      "Typst",
    ),
    title: "Abstract",
    body: [
      #text(
        lang: "en",
        region: "us",
      )[
        This exemple presents the use of the `quati-abnt`, a paper template for Typst according to the #glossarium.gls("nbr", plural: true, display: "Brazilian Norms (NBRs)") from the #glossarium.gls("abnt", display: "Brazilian Association of Technical Norms (ABNT)").
      ]
    ],
  )
}


// ## Lista de resumos.
// Include in this list all abstracts in the order they should appear.
// Inclua nessa lista todos os resumos da ordem em que eles devem aparecer.
#let abstracts = (
  abstract_in_main_language,
  first_abstract_in_foreign_language,
)


// ## Display. Exibição.
#for abstract in abstracts {
  include_abstract_page(
    body: abstract.body,
    keywords_title: abstract.keywords_title,
    keywords: abstract.keywords,
    title: abstract.title,
  )
}
