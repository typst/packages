// # Pre-textual elements. Elementos pré-textuais.
// NBR 6022:2018 5.1

#import "../data/data.typ": authors, subtitle, title
#import "../packages.typ": (
  glossarium, quati-abnt.article.components.include_abstracts, quati-abnt.article.components.include_opening,
  quati-abnt.common.components.print_title,
)
#import "../util.typ": foreign_text

// ## Title in foreign language. Título em língua estrangeira.
#let title_in_foreign_language = {
  print_title(
    title: {
      foreign_text[Writing guide]
    },
    subtitle: {
      foreign_text[scientific paper]
    },
  )
}

// ## Abstract. Resumo.
#let abstract_in_main_language = {
  (
    keywords_title: "Palavras-chave",
    keywords: (
      "modelo",
      "artigo",
      "ABNT",
      "Typst",
    ),
    title: "Resumo",
    body: [
      Este exemplo apresenta o uso do `quati-abnt`, modelo de artigo para o Typst segundo as @nbr:pl da @abnt.
    ],
  )
}

#let first_abstract_in_secondary_language = {
  (
    keywords_title: "Keywords",
    keywords: (
      "template",
      "paper",
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

// Include in this list all abstracts in the order they should appear.
#let abstracts = (
  abstract_in_main_language,
  first_abstract_in_secondary_language,
)

#include_opening(
  authors: authors,
  subtitle: subtitle,
  title_in_foreign_language: title_in_foreign_language,
  title: title,
)

#include_abstracts(abstracts: abstracts)
