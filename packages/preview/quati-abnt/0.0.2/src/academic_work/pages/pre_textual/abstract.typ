// # Abstract. Resumo.
// NBR 14724:2024 4.2.1.7, NBR 14724:2024 4.2.1.8

#import "../../../common/components/abstract.typ": include_abstract
#import "../../components/heading.typ": not_start_on_new_page
#import "../../components/page.typ": consider_only_odd_pages, not_number_page

#let include_abstract_page(
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
) = context {
  not_number_page(
    not_start_on_new_page()[
      #page()[
        #include_abstract(
          body: body,
          keywords_title: keywords_title,
          keywords: keywords,
          title: title,
        )
      ]

      #if not consider_only_odd_pages.get() {
        pagebreak(weak: true, to: "odd")
      }
    ],
  )
}
