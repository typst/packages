// Sistema de caixas coloridas (estilo tcolorbox)

/// Constrói o conteúdo do título formatado para caixas e ambientes.
///
/// Retorna `none` se `prefixo` for `none`.
///
/// - prefixo: texto do rótulo (ex: "Teorema", "Definição")
/// - num: número formatado (ou `none` se sem numeração)
/// - titulo: título descritivo (ou `none` se sem título)
#let _build-titulo(prefixo, num, titulo) = {
  if prefixo == none { return none }
  if num != none {
    if titulo != none {
      [*#prefixo #num* --- #titulo]
    } else {
      [*#prefixo #num*]
    }
  } else {
    if titulo != none {
      [*#prefixo* --- #titulo]
    } else {
      [*#prefixo*]
    }
  }
}

#let caixa(
  body,
  titulo: none,
  cor: blue,
  borda: "esquerda",
  espessura: 2pt,
  raio: 0pt,
  preenchimento: auto,
  titulo-fundo: auto,
  titulo-cor: black,
  recuo: 1em,
  largura: 100%,
  quebravel: true,
) = {
  let bg = if preenchimento == auto { cor.lighten(92%) } else { preenchimento }
  let titulo-bg = if titulo-fundo == auto { cor.lighten(80%) } else { titulo-fundo }

  let stroke = if borda == "esquerda" or borda == "left" {
    (left: espessura + cor)
  } else if borda == "topo" or borda == "top" {
    (top: espessura + cor)
  } else if borda == "completa" or borda == "full" {
    espessura + cor
  } else {
    none
  }

  if titulo != none {
    // Caixa com título
    block(
      width: largura,
      breakable: quebravel,
      radius: raio,
      clip: raio > 0pt,
      stroke: stroke,
      {
        // Barra de título
        block(
          width: 100%,
          fill: titulo-bg,
          inset: recuo,
          below: 0pt,
          text(fill: titulo-cor, weight: "bold", titulo)
        )
        // Corpo
        block(
          width: 100%,
          fill: bg,
          inset: recuo,
          above: 0pt,
          body
        )
      }
    )
  } else {
    // Caixa sem título
    block(
      width: largura,
      breakable: quebravel,
      radius: raio,
      stroke: stroke,
      fill: bg,
      inset: recuo,
      body,
    )
  }
}

#let caixa-estilo(
  cor: blue,
  borda: "esquerda",
  espessura: 2pt,
  raio: 0pt,
  preenchimento: auto,
  titulo-fundo: auto,
  titulo-cor: black,
  recuo: 1em,
  largura: 100%,
  quebravel: true,
  prefixo: none,
  contador: none,
  numeracao: "1",
  por-secao: false,
) = {
  let counter-key = contador

  assert(not por-secao or counter-key != none,
    message: "caixa-estilo: por-secao requer contador")

  // Closure auxiliar que renderiza a caixa com o título já resolvido
  let _render(body, t) = caixa(
    body,
    titulo: t,
    cor: cor,
    borda: borda,
    espessura: espessura,
    raio: raio,
    preenchimento: preenchimento,
    titulo-fundo: titulo-fundo,
    titulo-cor: titulo-cor,
    recuo: recuo,
    largura: largura,
    quebravel: quebravel,
  )

  // Retorna uma closure
  (body, titulo: none) => {
    if prefixo != none and counter-key != none {
      counter(counter-key).step()
      context {
        let num = if por-secao {
          let sec = counter(heading).get().first()
          let c = counter(counter-key).at(here()).first()
          [#sec.#c]
        } else {
          numbering(numeracao, ..counter(counter-key).at(here()))
        }
        _render(body, _build-titulo(prefixo, num, titulo))
      }
    } else if prefixo != none {
      _render(body, _build-titulo(prefixo, none, titulo))
    } else {
      _render(body, titulo)
    }
  }
}
