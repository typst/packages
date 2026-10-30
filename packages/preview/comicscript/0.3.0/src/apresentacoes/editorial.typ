#import "../validacao.typ": avisos-quadro
#import "blocos.typ": dispor-bloco

#let apresentar-notas(notas, estados: ("aberta", "resolvida", "descartada"), estilos: none) = {
  let notas = notas.filter(n => n.estado in estados)
  if notas.len() == 0 { return }
  // Cor acompanhada de sinal e categoria escrita, inclusive em impressão P&B.
  let paleta = (
    problema: (rgb("9c342c"), "!"),
    ideia: (rgb("366b8a"), "+"),
    alternativa: (rgb("76558a"), "?"),
    continuidade: (rgb("876523"), "="),
    subtexto: (rgb("76558a"), "~"),
    pista: (rgb("366b8a"), "+"),
    referencia: (rgb("52656a"), "*"),
    decisao: (rgb("3b7256"), "+"),
    composicao: (rgb("52656a"), "="),
  )
  for nota in notas {
    let (cor, sinal) = paleta.at(nota.categoria, default: (rgb("52656a"), "•"))
    dispor-bloco("nota", estilos: estilos, block(width: 100%, breakable: true, inset: (x: 10pt, y: 9pt), above: 8pt, below: 6pt,
      radius: 5pt, fill: cor.lighten(94%), stroke: (rest: 1pt + cor, left: 2.5pt + cor))[
      #block(sticky: true, above: 0pt, below: 0pt, inset: (bottom: 6pt))[
        #text(size: 8pt, weight: "bold", fill: cor)[#sinal NOTA · #upper(nota.categoria)]
        #h(1fr)#text(size: 8pt, fill: cor, nota.estado)
        #if nota.autor != none [#text(size: 8pt, fill: cor)[ · #nota.autor]]
      ]
      #text(size: 9.5pt, nota.corpo)
    ])
  }
}

#let apresentar-avisos(quadro, limite-palavras: 60, estilos: none) = {
  for aviso in avisos-quadro(quadro, limite-palavras: limite-palavras) {
    dispor-bloco("aviso", estilos: estilos, block(above: 4pt, below: 4pt)[
      #text(size: 9pt, fill: rgb("9c342c"))[*! Aviso editorial:* #aviso]
    ])
  }
}

#let validar-opcoes-editoriais(estados-notas, limite-palavras) = {
  assert(type(estados-notas) == array and estados-notas.all(e => e in ("aberta", "resolvida", "descartada")),
    message: "estados-notas aceita um array de estados: aberta, resolvida, descartada.")
  assert(limite-palavras == none or (type(limite-palavras) == int and limite-palavras > 0),
    message: "limite-palavras deve ser um inteiro positivo ou none.")
}
