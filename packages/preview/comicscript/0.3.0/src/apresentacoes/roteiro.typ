#import "editorial.typ": apresentar-notas, apresentar-avisos
#import "blocos.typ": estilos-internos, dispor-bloco
#import "../validacao.typ": avisos-quadro

#let campo(rotulo, corpo) = {
  block(above: 0pt, below: 0pt, inset: (top: 4pt, bottom: 4pt))[
    #block(sticky: true, above: 0pt, below: 0pt, inset: (bottom: 5pt))[
      #text(size: 8pt, weight: "bold", tracking: 0.06em, fill: rgb("52656a"), upper(rotulo))
    ]
    #corpo
  ]
}

#let apresentar-texto(item, estilos: none) = {
  let rotulo = if item.tipo == "fala" {
    upper(item.personagem) + if item.modo == "normal" { "" } else { " · " + item.modo }
  } else if item.tipo == "legenda" { "LEGENDA" } else { "SOM" }
  dispor-bloco(item.tipo, estilos: estilos, block(width: 100%, breakable: true, inset: (x: 12pt, y: 9pt),
    above: 6pt, below: 6pt, radius: 5pt, stroke: 1pt + rgb("315663"))[
    #block(sticky: true, above: 0pt, below: 0pt, inset: (bottom: 6pt))[
      #text(size: 9pt, weight: "bold", fill: rgb("315663"), rotulo)
    ]
    #item.corpo
  ])
}

#let apresentar-roteiro(paginas, editorial: false, producao: false, estados-notas: (), limite-palavras: 60) = {
  set par(first-line-indent: 0pt, justify: false, leading: 0.7em, spacing: 0.8em)
  set heading(numbering: none)
  let estados = if producao { ("aberta", "resolvida") } else { estados-notas }
  let selecionar-notas(notas) = if producao {
    notas.filter(n => n.categoria in ("composicao", "continuidade", "referencia", "tecnica"))
  } else { notas }
  let notas-visiveis(notas) = selecionar-notas(notas).filter(n => n.estado in estados)
  let tipos = ()
  for pagina in paginas {
    for linha in pagina.linhas {
      for quadro in linha.quadros {
        for tipo in ("plano", "composicao") {
          if quadro.at(tipo) != none { tipos.push(tipo) }
        }
        for item in quadro.textos { tipos.push(item.tipo) }
        if quadro.referencias.len() > 0 { tipos.push("referencias") }
        if editorial or producao { tipos += ("nota",) * notas-visiveis(quadro.notas).len() }
        if editorial { tipos += ("aviso",) * avisos-quadro(quadro, limite-palavras: limite-palavras).len() }
      }
    }
  }
  let estilos = estilos-internos(tipos)
  for (pi, pagina) in paginas.enumerate() {
    if pi > 0 { pagebreak(weak: true) }
    heading(level: 1)[
      #if pagina.titulo != none [
        #block(above: 0pt, below: 0pt, inset: (bottom: 10pt))[
          #text(size: 22pt, weight: "bold", fill: rgb("C98F54"))[PÁGINA #pagina.numero]
          #if producao [#h(8pt)#text(size: 9pt, fill: rgb("315663"))[PRODUÇÃO]]
        ]
        #text(size: 22pt, weight: "bold", pagina.titulo)
      ] else [
        #text(size: 22pt, weight: "bold", fill: rgb("C98F54"))[PÁGINA #pagina.numero]
        #if producao [#h(8pt)#text(size: 9pt, fill: rgb("315663"))[PRODUÇÃO]]
      ]
    ]
    block(width: 100%, height: 1.5pt, radius: 0.75pt, fill: rgb("315663"), above: 10pt, below: 16pt)
    if editorial {
      if pagina.estado != none or pagina.objetivo != none {
        block(width: 100%, breakable: true, radius: 5pt, fill: luma(96%), stroke: 1pt + rgb("52656a"),
          inset: 12pt, above: 0pt, below: 12pt)[
          #if pagina.estado != none {
            block(above: 0pt, below: 0pt, inset: (bottom: 6pt))[
              #text(size: 8pt, weight: "bold", fill: rgb("52656a"))[ESTADO]
              #h(6pt)#text(size: 10pt, pagina.estado)
            ]
          }
          #if pagina.objetivo != none { campo("Objetivo da página", pagina.objetivo) }
        ]
      }
    }
    if editorial or producao { apresentar-notas(selecionar-notas(pagina.notas), estados: estados) }
    for (li, linha) in pagina.linhas.enumerate() {
      if (editorial or producao) and notas-visiveis(linha.notas).len() > 0 {
        block(sticky: true, above: 12pt, below: 6pt)[
          #text(size: 9pt, weight: "bold", fill: rgb("52656a"))[Notas da linha #(li + 1)]
        ]
        apresentar-notas(selecionar-notas(linha.notas), estados: estados)
      }
      let soma-pesos = linha.quadros.map(q => q.peso).sum()
      for (qi, quadro) in linha.quadros.enumerate() {
        let corpo = [
          #block(width: 100%, sticky: true, above: 0pt, below: 8pt,
            inset: (x: 10pt, y: 9pt), radius: 5pt, fill: rgb("315663"), stroke: 1pt + rgb("243f49"))[
            #text(size: 11pt, weight: "bold", fill: white)[
              LINHA #(li + 1) · QUADRINHO #(qi + 1) · #(calc.round(100 * quadro.peso / soma-pesos, digits: 1))% DA LINHA#if linha.peso != 1 or quadro.peso != 1 [ · PESO L/Q: #linha.peso/#quadro.peso]
            ]
          ]
          #if editorial or producao {
            let ids = ()
            if linha.id != none { ids.push("linha: " + linha.id) }
            if quadro.id != none { ids.push("quadro: " + quadro.id) }
            if ids.len() > 0 {
              block(sticky: true, above: 0pt, below: 6pt)[#text(size: 8pt, fill: luma(40%))[ID #ids.join(" · ")]]
            }
          }
          #campo("Descrição visual", quadro.visual)
          #for (tipo, rotulo) in (("plano", "Plano"), ("composicao", "Composição")) {
            if quadro.at(tipo) != none {
              dispor-bloco(tipo, estilos: estilos,
                block(width: 100%, radius: 5pt, fill: luma(97%), stroke: 1pt + rgb("52656a"),
                  inset: (x: 10pt, y: 4pt), above: 8pt, below: 8pt)[
                  #campo(rotulo, quadro.at(tipo))
                ])
            }
          }
          #for item in quadro.textos { apresentar-texto(item, estilos: estilos) }
          #if quadro.referencias.len() > 0 {
            dispor-bloco("referencias", estilos: estilos,
              block(width: 100%, radius: 5pt, stroke: 1pt + rgb("52656a"), inset: (x: 10pt, y: 4pt), above: 8pt, below: 8pt)[
                #campo("Referências", [#for ref in quadro.referencias { block(above: 3pt, below: 3pt, ref) }])
              ])
          }
          #if editorial {
            apresentar-avisos(quadro, limite-palavras: limite-palavras, estilos: estilos)
          }
          #if editorial or producao {
            apresentar-notas(selecionar-notas(quadro.notas), estados: estados, estilos: estilos)
          }
        ]
        // Mantém um quadro curto inteiro; um quadro maior que a área útil pode fluir.
        layout(tamanho => {
          let moldura = block.with(width: 100%, inset: 10pt, radius: 5pt,
            stroke: 1.5pt + rgb("252525"), above: 8pt, below: 10pt)
          let altura = measure(moldura(breakable: false, corpo), width: tamanho.width).height
          moldura(breakable: altura > tamanho.height, corpo)
        })
      }
    }
  }
}
