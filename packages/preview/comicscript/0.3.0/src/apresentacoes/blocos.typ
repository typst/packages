// Frequências apenas das caixas visíveis dentro dos quadrinhos.
// Empates têm a mesma largura; cada faixa de frequência reduz mais 1 cm.
#let estilos-internos(tipos) = {
  let frequencias = (:)
  for tipo in tipos {
    frequencias.insert(tipo, frequencias.at(tipo, default: 0) + 1)
  }
  let faixas = ()
  for total in frequencias.values() {
    if not (total in faixas) { faixas.push(total) }
  }
  faixas = faixas.sorted().rev()
  let posicoes = (fala: left, plano: center, composicao: right, nota: right,
    legenda: center, som: right, referencias: left, aviso: center)
  let estilos = (:)
  for (tipo, total) in frequencias {
    estilos.insert(tipo, (
      reducao: faixas.position(f => f == total) * 1cm,
      posicao: posicoes.at(tipo, default: left),
    ))
  }
  estilos
}

#let dispor-bloco(tipo, corpo, estilos: none) = {
  // Relatórios e notas fora dos quadrinhos preservam sua apresentação.
  if estilos == none { return corpo }
  let estilo = estilos.at(tipo, default: (reducao: 0pt, posicao: left))
  layout(tamanho => {
    // Em colunas estreitas, preserva pelo menos 60% da largura para o texto.
    let largura = calc.max(tamanho.width - estilo.reducao, tamanho.width * 0.6)
    align(estilo.posicao, block(width: largura, above: 8pt, below: 8pt)[
      #set align(left)
      #corpo
    ])
  })
}
