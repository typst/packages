#import "../validacao.typ": texto-simples

// A geometria depende somente dos pesos; as descrições nunca redimensionam células.
#let medidas-esquema(pagina, largura, altura, sarjeta: 3mm) = {
  let altura-util = altura - (pagina.linhas.len() - 1) * sarjeta
  assert(altura-util > 0pt, message: "Altura do esquema insuficiente para as sarjetas.")
  let peso-total = pagina.linhas.map(l => l.peso).sum()
  pagina.linhas.map(linha => {
    let largura-util = largura - (linha.quadros.len() - 1) * sarjeta
    assert(largura-util > 0pt, message: "Largura do esquema insuficiente para as sarjetas.")
    let pesos = linha.quadros.map(q => q.peso).sum()
    (altura: altura-util * linha.peso / peso-total,
      larguras: linha.quadros.map(q => largura-util * q.peso / pesos))
  })
}

#let resumo-visual(quadro) = {
  let palavras = texto-simples(quadro.visual).split(regex("\\s+")).filter(p => p != "")
  palavras.slice(0, calc.min(8, palavras.len())).join(" ", default: "") + if palavras.len() > 8 { "…" } else { "" }
}

#let apresentar-esquema(paginas, largura: 140mm, altura: 180mm, resumos: true) = {
  assert(type(largura) == length and largura > 0pt and type(altura) == length and altura > 0pt,
    message: "Dimensões do esquema devem ser comprimentos positivos, como 140mm e 180mm.")
  assert(type(resumos) == bool, message: "resumos-esquema deve ser true ou false.")
  set par(first-line-indent: 0pt, justify: false, leading: 0.6em)
  for (pi, pagina) in paginas.enumerate() {
    if pi > 0 { pagebreak(weak: true) }
    let medidas = medidas-esquema(pagina, largura, altura)
    block(width: 100%, breakable: false, above: 0pt, below: 0pt)[
      #block(inset: (bottom: 10pt), above: 0pt, below: 0pt)[
        #text(size: 22pt, weight: "bold", fill: rgb("C98F54"))[PÁGINA #pagina.numero]
        #h(8pt)#text(size: 9pt, fill: rgb("315663"))[ESQUEMA]
      ]
      #block(inset: (bottom: 16pt), above: 0pt, below: 0pt)[
        #text(size: 20pt, weight: "bold", if pagina.titulo != none { pagina.titulo } else { [Página #pagina.numero] })
      ]
      #align(center)[
        #box(width: largura, height: altura)[
          #grid(
            columns: (largura,), rows: medidas.map(m => m.altura), row-gutter: 3mm,
            ..pagina.linhas.enumerate().map(((li, linha)) => {
              let m = medidas.at(li)
              grid(columns: m.larguras, rows: (m.altura,), column-gutter: 3mm,
                ..linha.quadros.enumerate().map(((qi, quadro)) => {
                  let w = m.larguras.at(qi)
                  box(width: w, height: m.altura, radius: 5pt, clip: true, fill: luma(97%), stroke: 1.5pt + rgb("252525"))[
                    #if w > 28pt and m.altura > 24pt {
                      align(center + horizon, pad(6pt)[
                        #text(size: 10pt, weight: "bold")[L#(li + 1) · Q#(qi + 1)]
                        #if resumos and w > 70pt and m.altura > 65pt {
                          block(above: 8pt, below: 0pt)[#text(size: 9pt, resumo-visual(quadro))]
                        }
                      ])
                    }
                  ]
                })
              )
            })
          )
        ]
      ]
      #block(above: 14pt, below: 0pt)[
        #text(size: 9pt, fill: luma(35%))[
          Esquema de composição · proporções definidas pelos pesos das linhas e dos quadros.
        ]
      ]
    ]
  }
}
