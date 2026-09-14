// Resumo e Abstract conforme NBR 6028:2021

/// Cria página de resumo conforme ABNT
/// - titulo: "RESUMO" ou "ABSTRACT"
/// - conteudo: texto do resumo (150-500 palavras para trabalhos acadêmicos)
/// - palavras-chave: lista de palavras-chave (3 a 5)
/// - rotulo-palavras-chave: "Palavras-chave" ou "Keywords"
#let abstract-page(
  titulo: "RESUMO",
  conteudo: none,
  palavras-chave: (),
  rotulo-palavras-chave: "Palavras-chave",
) = {
  // Título centralizado, negrito
  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  // Texto do resumo (parágrafo único, espaçamento simples entre linhas)
  set par(
    leading: 1.5em * 0.65,
    first-line-indent: 0pt,
    justify: true,
  )

  conteudo

  v(1.5em)

  // Palavras-chave
  if palavras-chave.len() > 0 {
    set par(first-line-indent: 0pt)
    [*#rotulo-palavras-chave:* #palavras-chave.join(". "). ]
  }

  pagebreak()
}

/// Resumo em português
#let resumo(conteudo, palavras-chave: ()) = {
  abstract-page(
    titulo: "RESUMO",
    conteudo: conteudo,
    palavras-chave: palavras-chave,
    rotulo-palavras-chave: "Palavras-chave",
  )
}

/// Abstract em inglês
#let resumo-en(conteudo, palavras-chave: ()) = {
  abstract-page(
    titulo: "ABSTRACT",
    conteudo: conteudo,
    palavras-chave: palavras-chave,
    rotulo-palavras-chave: "Keywords",
  )
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
