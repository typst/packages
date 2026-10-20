// Estilização de código (inline + bloco)

#let codigo-inline(
  body,
  fundo: luma(240),
  raio: 2pt,
  recuo: (x: 3pt, y: 1pt),
) = {
  box(fill: fundo, inset: recuo, radius: raio, body)
}

#let codigo-bloco(
  body,
  lang: none,
  titulo: none,
  cor: luma(245),
  borda: (left: 2pt + luma(180)),
  raio: 0pt,
  numerar-linhas: false,
) = {
  let code = if lang != none {
    raw(block: true, lang: lang, body)
  } else {
    raw(block: true, body)
  }

  let code-content = if numerar-linhas {
    // Adicionar números de linha
    set par(leading: 0.55em)
    show raw.line: it => {
      text(fill: luma(160), size: 0.85em, str(it.number))
      h(1.2em)
      it.body
    }
    code
  } else {
    code
  }

  if titulo != none {
    block(
      width: 100%,
      radius: raio,
      stroke: borda,
      clip: raio > 0pt,
      {
        block(
          width: 100%,
          fill: luma(220),
          inset: 0.7em,
          below: 0pt,
          text(size: 0.9em, weight: "bold", titulo)
        )
        block(
          width: 100%,
          fill: cor,
          inset: 1em,
          above: 0pt,
          code-content,
        )
      }
    )
  } else {
    block(
      width: 100%,
      fill: cor,
      radius: raio,
      stroke: borda,
      inset: 1em,
      code-content,
    )
  }
}

#let code(
  body,
  bloco: false,
  lang: none,
  titulo: none,
  numerar-linhas: false,
) = {
  if bloco {
    codigo-bloco(body, lang: lang, titulo: titulo, numerar-linhas: numerar-linhas)
  } else {
    codigo-inline(raw(body))
  }
}
