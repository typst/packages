// Resumo e Abstract conforme NBR 6028:2021

#import "../core/metadata.typ"
#import "../core/spacing.typ": abnt-leading
#import "../core/page.typ": abre-anverso

/// Cria página de resumo conforme ABNT
/// - titulo: "RESUMO" ou "ABSTRACT"
/// - conteudo: texto do resumo (150-500 palavras para trabalhos acadêmicos)
/// - palavras-chave: lista de palavras-chave (3 a 5); saem separadas por ponto e vírgula
///   e finalizadas por ponto (NBR 6028 4.1.7)
/// - rotulo-palavras-chave: "Palavras-chave" ou "Keywords"
#let abstract-page(
  titulo: "RESUMO",
  conteudo: none,
  palavras-chave: (),
  rotulo-palavras-chave: "Palavras-chave",
) = {
  abre-anverso()

  // Título centralizado, negrito
  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  // Texto do resumo (parágrafo único, espaçamento 1,5: o resumo não é exceção da 14724 5.2)
  set par(
    leading: abnt-leading(1.5),
    first-line-indent: 0pt,
    justify: true,
  )

  conteudo

  v(1.5em)

  // Palavras-chave
  if palavras-chave.len() > 0 {
    set par(first-line-indent: 0pt)
    [*#rotulo-palavras-chave:* #(palavras-chave,).flatten().join("; "). ]
  }

  pagebreak()
}

/// Resumo em português
#let resumo(conteudo, palavras-chave: none) = {
  context {
    let kw = metadata._resolve(palavras-chave, "palavras-chave", fallback: ())
    abstract-page(
      titulo: "RESUMO",
      conteudo: conteudo,
      palavras-chave: kw,
      rotulo-palavras-chave: "Palavras-chave",
    )
  }
}

/// Abstract em inglês
#let resumo-en(conteudo, palavras-chave: none) = {
  context {
    let kw = metadata._resolve(palavras-chave, "palavras-chave-en", fallback: ())
    abstract-page(
      titulo: "ABSTRACT",
      conteudo: conteudo,
      palavras-chave: kw,
      rotulo-palavras-chave: "Keywords",
    )
  }
}

/// Resumo em língua estrangeira (genérico)
#let foreign-abstract(
  titulo: "ABSTRACT",
  conteudo: none,
  palavras-chave: (),
  rotulo-palavras-chave: "Keywords",
) = {
  abstract-page(
    titulo: titulo,
    conteudo: conteudo,
    palavras-chave: palavras-chave,
    rotulo-palavras-chave: rotulo-palavras-chave,
  )
}
