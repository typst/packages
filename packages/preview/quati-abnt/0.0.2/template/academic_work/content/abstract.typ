// # Abstract. Resumo.
// NBR 14724:2024 4.2.1.7, NBR 14724:2024 4.2.1.8

#import "../packages.typ": glossarium, quati-abnt.academic_work.pages.include_abstract_page

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
      Este exemplo apresenta o uso do `quati-abnt`, modelo de artigo segundo as @nbr:pl da @abnt.
      Esse modelo é desenvolvido para a ferramenta Typst.
    ],
  )
}

#let first_abstract_in_secondary_language = {
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
        This exemple presents the use of the `quati-abnt`, a paper template according to the #glossarium.gls("nbr", plural: true, display: "Brazilian Norms") from the #glossarium.gls("abnt", display: "Brazilian Association of Technical Norms (ABNT)").
        This template is developed for the Typst tool.
      ]
    ],
  )
}

// Include in this list all abstracts in the order they should appear.
#let abstracts = (
  abstract_in_main_language,
  first_abstract_in_secondary_language,
)

#for abstract in abstracts {
  include_abstract_page(
    body: abstract.body,
    keywords_title: abstract.keywords_title,
    keywords: abstract.keywords,
    title: abstract.title,
  )
}
