#import "validacao.typ": validar, contar-palavras, exigir-nome
#import "apresentacoes/editorial.typ": apresentar-notas, validar-opcoes-editoriais
#import "apresentacoes/roteiro.typ": apresentar-texto

#let cabecalho(titulo) = {
  heading(level: 1, text(size: 20pt, weight: "bold", titulo))
  block(width: 100%, height: 1.5pt, radius: 0.75pt, fill: rgb("315663"), above: 10pt, below: 18pt)
}

#let tabela-relatorio(colunas, rotulos, celulas) = {
  set text(size: 10pt)
  block(width: 100%, radius: 5pt, clip: true, stroke: 1pt + rgb("52656a"), table(columns: colunas, inset: 8pt, stroke: 1pt + rgb("52656a"),
    table.header(..rotulos.map(r => table.cell(fill: rgb("315663"), text(fill: white, weight: "bold", r)))),
    ..celulas))
}

#let mapa-narrativo(paginas) = {
  let paginas = validar(paginas)
  set par(first-line-indent: 0pt, justify: false)
  cabecalho([Mapa narrativo])
  let celulas = ()
  for pagina in paginas {
    let quadros = pagina.linhas.map(l => l.quadros.len()).sum()
    celulas += ([#pagina.numero], [#quadros], [
      #if pagina.titulo != none { block(above: 0pt, below: 6pt, strong(pagina.titulo)) }
      #if pagina.objetivo != none { pagina.objetivo } else { [Objetivo não informado.] }
    ], if pagina.estado != none { pagina.estado } else { [—] })
  }
  tabela-relatorio((14mm, 18mm, 1fr, 24mm), ([Página], [Quadros], [Página e objetivo], [Estado]), celulas)
}

// As notas continuam armazenadas nos elementos; o relatório apenas as percorre.
#let notas-da-pagina(pagina) = {
  let itens = ((local: [Página], notas: pagina.notas),)
  for (li, linha) in pagina.linhas.enumerate() {
    itens.push((local: [Linha #(li + 1)], notas: linha.notas))
    for (qi, quadro) in linha.quadros.enumerate() {
      itens.push((local: [Linha #(li + 1) · Quadrinho #(qi + 1)], notas: quadro.notas))
    }
  }
  itens
}

#let pendencias(paginas) = {
  let paginas = validar(paginas)
  set par(first-line-indent: 0pt, justify: false)
  cabecalho([Pendências editoriais])
  let total = 0
  for pagina in paginas {
    let itens = notas-da-pagina(pagina).filter(i => i.notas.any(n => n.estado == "aberta"))
    if itens.len() > 0 {
      heading(level: 2, [Página #pagina.numero])
      for item in itens {
        block(sticky: true, above: 12pt, below: 8pt)[#text(size: 10pt, weight: "bold", item.local)]
        apresentar-notas(item.notas, estados: ("aberta",))
        total += item.notas.filter(n => n.estado == "aberta").len()
      }
    }
  }
  if total == 0 { [Nenhuma pendência aberta.] }
}

#let dialogos(paginas, personagem: none) = {
  let paginas = validar(paginas)
  if personagem != none { exigir-nome(personagem, "personagem") }
  set par(first-line-indent: 0pt, justify: false)
  cabecalho([Diálogos#if personagem != none [ — #personagem]])
  let total = 0
  for pagina in paginas {
    let iniciou = false
    for (li, linha) in pagina.linhas.enumerate() {
      for (qi, quadro) in linha.quadros.enumerate() {
        let falas = quadro.textos.filter(t => t.tipo == "fala" and (personagem == none or t.personagem == personagem))
        if falas.len() > 0 {
          if not iniciou { heading(level: 2, [Página #pagina.numero]); iniciou = true }
          block(sticky: true, above: 12pt, below: 8pt)[
            #text(size: 9pt, fill: luma(35%))[Linha #(li + 1) · Quadrinho #(qi + 1)]
          ]
          for fala in falas { apresentar-texto(fala) }
          total += falas.len()
        }
      }
    }
  }
  if total == 0 { [Nenhuma fala encontrada.] }
}

#let relatorio-textos(paginas, limite-palavras: 60) = {
  let paginas = validar(paginas)
  validar-opcoes-editoriais((), limite-palavras)
  set par(first-line-indent: 0pt, justify: false)
  cabecalho([Textos por quadrinho])
  block(above: 0pt, below: 14pt)[
    #text(size: 10pt)[
      Contagem dos textos estáticos: falas, legendas e sons.
      #if limite-palavras != none [Limiar de revisão: #limite-palavras palavras.]
    ]
  ]
  let celulas = ()
  for pagina in paginas {
    for (li, linha) in pagina.linhas.enumerate() {
      for (qi, quadro) in linha.quadros.enumerate() {
        let palavras = contar-palavras(quadro)
        let aviso = limite-palavras != none and palavras > limite-palavras
        celulas += ([#pagina.numero], [#(li + 1)], [#(qi + 1)], [#quadro.textos.len()], [#palavras],
          if aviso { text(fill: rgb("9c342c"), weight: "bold", [Revisar]) }
          else if quadro.textos.len() == 0 { [Silencioso] } else { [—] })
      }
    }
  }
  tabela-relatorio((1fr, 1fr, 1.3fr, 1fr, 1.2fr, 1.6fr),
    ([Página], [Linha], [Quadro], [Textos], [Palavras], [Observação]), celulas)
}
