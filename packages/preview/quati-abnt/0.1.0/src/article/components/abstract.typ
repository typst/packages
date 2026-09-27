// # Abstract. Resumo.

#import "../../common/components/abstract.typ": include_abstract
#import "../../common/style/style.typ": leading_for_common_text

#let include_abstracts = (
  abstracts: (
    (
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
    ),
  ),
) => {
  for abstract in abstracts {
    include_abstract(..abstract)
    v(leading_for_common_text * 2)
  }
}
