// Figuras, quadros, tabelas e ilustrações conforme NBR 14724:2024 e IBGE

/// Configuração de figuras conforme ABNT
/// - Legenda na parte superior: tipo, número, traço, título
/// - Fonte na parte inferior
/// - Centralizadas
#let abnt-figure-setup() = {
  show figure: it => {
    set align(center)
    it
  }

  show figure.caption: it => {
    set text(size: 10pt)
    it
  }
}

/// Container genérico para elementos com título, numeração e fonte (ABNT).
/// É a única forma de criar um `figure()` no ABNTyp.
/// O `suplemento` é inferido automaticamente a partir do `tipo`:
/// - `"imagem"` → "Figura" (padrão)
/// - `"tabela"` → "Tabela"
/// - `"quadro"` → "Quadro"
///
/// Uso:
/// ```typst
/// #container(legenda: "Meu título", origem: "O autor")[
///   #imagem("foto.png")
/// ]
/// ```
#let container(
  body,
  legenda: none,
  origem: none,
  nota: none,
  tipo: "imagem",
  suplemento: auto,
  ..args,
) = {
  // Traduz strings em português para os tipos nativos do Typst.
  // Backward-compat: aceita também os tipos nativos `image` e `table`
  // (usados antes da renomeação para "imagem"/"tabela"), de modo que
  // código existente com `tipo: image` ou `tipo: table` continue funcionando.
  let resolved-kind = if tipo == "imagem" or tipo == image { image }
    else if tipo == "tabela" or tipo == table { table }
    else { tipo }

  let supp = if suplemento != auto { suplemento }
    else if resolved-kind == image { "Figura" }
    else if resolved-kind == table { "Tabela" }
    else if resolved-kind == "quadro" { "Quadro" }
    else { "Figura" }

  figure(
    body,
    caption: if legenda != none { legenda },
    kind: resolved-kind,
    supplement: supp,
    ..args,
  )

  if origem != none {
    align(center)[
      #text(size: 10pt)[Fonte: #origem]
    ]
  }

  if nota != none {
    align(left)[
      #text(size: 10pt)[Nota: #nota]
    ]
  }
}

/// Wrapper para `image()` em português.
///
/// Parâmetros nomeados:
/// - largura: largura (auto, relativa ou fração)
/// - altura: altura (auto, relativa ou fração)
/// - ajuste: modo de ajuste ("cobrir", "conter", "esticar")
/// - alternativo: texto alternativo para acessibilidade
/// - pagina: página do PDF a extrair (auto = primeira)
/// - formato: formato da imagem (auto ou string)
/// - escala: escala de renderização (auto ou string)
/// - icc: perfil de cor ICC (auto, string ou bytes)
/// - ..outros: parâmetros adicionais repassados a `image()`
///
/// Uso (dentro de um `container`):
/// ```typst
/// #container(legenda: "Logo", origem: "O autor")[
///   #imagem("logo.png", largura: 80%)
/// ]
/// ```
#let imagem(
  caminho,
  largura: auto,
  altura: auto,
  ajuste: "cobrir",
  alternativo: none,
  pagina: auto,
  formato: auto,
  escala: auto,
  icc: auto,
  ..outros,
) = {
  // Traduz valores de ajuste para o Typst
  let resolved-fit = if ajuste == "cobrir" { "cover" }
    else if ajuste == "conter" { "contain" }
    else if ajuste == "esticar" { "stretch" }
    else { ajuste }

  image(
    caminho,
    width: largura,
    height: altura,
    fit: resolved-fit,
    alt: alternativo,
    page: pagina,
    format: formato,
    scaling: escala,
    icc: icc,
    ..outros,
  )
}

/// Quadro: tabela textual com bordas fechadas (conforme IBGE).
/// Aceita os mesmos parâmetros de `table()`.
///
/// Uso (dentro de um `container`):
/// ```typst
/// #container(legenda: "Glossário", tipo: "quadro", origem: "O autor")[
///   #quadro(columns: 2,
///     [*Termo*], [*Definição*],
///     [Algoritmo], [Sequência finita de instruções],
///   )
/// ]
/// ```
#let quadro(..args) = {
  table(..args)
}

/// Fonte da figura (para usar avulso abaixo de um elemento)
#let fonte(conteudo) = {
  align(center)[
    #text(size: 10pt)[Fonte: #conteudo]
  ]
}

/// Nota da figura (para usar avulso abaixo de um elemento)
#let nota-figura(conteudo) = {
  align(left)[
    #text(size: 10pt)[Nota: #conteudo]
  ]
}
