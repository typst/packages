// Tabelas conforme IBGE e NBR 14724:2024

/// Configuração de tabelas conforme ABNT/IBGE
/// - Bordas apenas superior, inferior e separando cabeçalho
/// - Legenda na parte superior
/// - Fonte na parte inferior
#let abnt-table-setup(body) = {
  show figure.where(kind: table): it => {
    set align(center)
    it
  }
  body
}

// Numera as chamadas de `tabela()`: o rodapé "continua/continuação/conclusão" acha o
// início e o fim da sua tabela pelos marcadores com esse número.
#let _tabela-n = counter("abnt-tabela")

/// Tabela no padrão IBGE (sem bordas laterais).
/// Formatador de conteúdo — deve ser usada dentro de `container()`.
/// Aceita os mesmos parâmetros de `table()`, mas aplica `stroke: none`
/// automaticamente (padrão IBGE: sem bordas laterais).
///
/// - moldura: se `true` (padrão), desenha os três traços horizontais da IBGE 4.3.1
///   (topo, entre o cabeçalho e o corpo, e rodapé) e faz da primeira linha o cabeçalho,
///   que se repete em cada página. Se você já passar `table.hline`, a moldura não é
///   aplicada (vale o que você desenhou).
/// - continuacao: se `true` (padrão), uma tabela que passa de uma página recebe, abaixo
///   do corpo e à direita, "(continua)" na primeira página, "(continuação)" nas
///   intermediárias e "(conclusão)" na última (IBGE 8.3); com a moldura, o traço de
///   fecho só vem na última. Tabela de uma página não recebe palavra. Não vale se você
///   passar `table.footer`. Com `table.hline` seus, o último, se vier depois de todas as
///   linhas, é o traço de fecho e também só sai na última página.
///
/// Uso (dentro de um `container`):
/// ```typst
/// #container(legenda: "População", tipo: "tabela", fonte: "IBGE (2023)")[
///   #tabela(columns: 2,
///     [*Região*], [*População*],
///     [Nordeste], [57M],
///   )
/// ]
/// ```
#let tabela(moldura: true, continuacao: true, ..args) = {
  let itens = args.pos()
  let colunas = args.named().at("columns", default: 1)
  let ncols = if type(colunas) == int { colunas } else if type(colunas) == array { colunas.len() } else { 1 }
  let é(i, f) = type(i) == content and i.func() == f

  let com-rodape = continuacao and not itens.any(i => é(i, table.footer))
  let fecho = moldura and not itens.any(i => é(i, table.hline))

  // Traço de fecho: o da moldura, ou o último `table.hline` do usuário (depois de todas
  // as linhas), que sai do corpo para o rodapé e só aparece na última página
  let traco-final = if fecho { 1.5pt } else { none }
  if com-rodape and not fecho and itens.len() > 0 and é(itens.last(), table.hline) {
    traco-final = itens.last().at("stroke", default: auto)
    itens = itens.slice(0, -1)
  }

  let corpo = itens
  if fecho {
    // Cabeçalho: o `table.header` que vier, ou as células da primeira linha
    let cabecalho = itens.position(i => é(i, table.header))
    if cabecalho == none {
      let usado = 0
      for (k, i) in itens.enumerate() {
        usado += if type(i) == content { i.at("colspan", default: 1) } else { 1 }
        if usado >= ncols {
          itens = (table.header(..itens.slice(0, k + 1)), ..itens.slice(k + 1))
          cabecalho = 0
          break
        }
      }
    }
    corpo = (
      (table.hline(stroke: 1.5pt),)
        + if cabecalho != none {
          itens.slice(0, cabecalho + 1) + (table.hline(stroke: 0.75pt),) + itens.slice(cabecalho + 1)
        } else { itens }
        // com o rodapé abaixo, o traço de fecho é desenhado por ele, só na última página
        + if com-rodape { () } else { (table.hline(stroke: 1.5pt),) }
    )
  }

  if not com-rodape {
    return table(stroke: none, ..args.named(), ..corpo)
  }

  context {
    let n = _tabela-n.get().first()
    _tabela-n.step()
    let inicio = label("abnt-tab-ini-" + str(n))
    let fim = label("abnt-tab-fim-" + str(n))
    [#metadata(n) #inicio]
    table(
      stroke: none,
      ..args.named(),
      ..corpo,
      table.footer(repeat: true, table.cell(colspan: ncols, inset: 0pt, align: right, context {
        let primeira = query(inicio).first().location().page()
        let ultima = query(fim).first().location().page()
        let aqui = here().page()
        let palavra = if primeira == ultima { none }
          else if aqui == primeira { "(continua)" }
          else if aqui == ultima { "(conclusão)" }
          else { "(continuação)" }
        stack(
          if traco-final != none and aqui == ultima { line(length: 100%, stroke: traco-final) },
          if palavra != none { align(right, text(size: 10pt, palavra)) },
        )
      })),
    )
    [#metadata(n) #fim]
  }
}

/// Sinais convencionais da tabela (IBGE 4.8.1). Devolve o texto do sinal.
/// - tipo: `"zero"` (`-`, zero não resultante de arredondamento), `"nao-se-aplica"` (`..`),
///   `"nao-disponivel"` (`...`), `"omitido"` (`X`, omitido para evitar a individualização
///   da informação), `"arredondado-positivo"` (`0`, `0,0`, `0,00`: zero resultante do
///   arredondamento de um valor positivo) e `"arredondado-negativo"` (`-0`, `-0,0`, `-0,00`).
/// - casas: casas decimais do dado, para os dois últimos tipos (`0`, `1` ou `2`).
///
/// Uso: `#sinal-convencional("nao-disponivel")` dentro de uma célula; explique os sinais
/// usados na nota geral com `nota-sinais`.
#let sinal-convencional(tipo, casas: 0) = {
  let zero = if casas > 0 { "0," + "0" * casas } else { "0" }
  if tipo == "zero" { "-" }
  else if tipo == "nao-se-aplica" { ".." }
  else if tipo == "nao-disponivel" { "..." }
  else if tipo == "omitido" { "X" }
  else if tipo == "arredondado-positivo" { zero }
  else if tipo == "arredondado-negativo" { "-" + zero }
  else {
    panic(
      "sinal-convencional(): tipo desconhecido (\"" + str(tipo) + "\"). Use \"zero\", \"nao-se-aplica\", "
        + "\"nao-disponivel\", \"omitido\", \"arredondado-positivo\" ou \"arredondado-negativo\".",
    )
  }
}

/// Texto da nota geral que explica os sinais convencionais usados (IBGE 4.8.2).
/// Passe os tipos de `sinal-convencional` presentes na tabela, por exemplo
/// `#container(..., nota: nota-sinais("zero", "nao-disponivel"))[...]`.
#let nota-sinais(..tipos) = {
  let significado = (
    "zero": "dado numérico igual a zero não resultante de arredondamento",
    "nao-se-aplica": "não se aplica dado numérico",
    "nao-disponivel": "dado numérico não disponível",
    "omitido": "dado numérico omitido a fim de evitar a individualização da informação",
    "arredondado-positivo": "dado numérico igual a zero resultante de arredondamento de um dado numérico originalmente positivo",
    "arredondado-negativo": "dado numérico igual a zero resultante de arredondamento de um dado numérico originalmente negativo",
  )
  let sinais = (
    "arredondado-positivo": "0, 0,0 ou 0,00",
    "arredondado-negativo": "-0, -0,0 ou -0,00",
  )
  [Sinais convencionais utilizados: #tipos.pos().map(t => {
    [#(sinais.at(t, default: sinal-convencional(t))): #significado.at(t)]
  }).join("; ").]
}

/// Nota de tabela
#let nota-tabela(conteudo) = {
  align(left)[
    #text(size: 10pt)[Nota: #conteudo]
  ]
}
