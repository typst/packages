// Wrappers em português para colunas, quebra de coluna e grade do Typst
// Traduz nomes de parâmetros de columns(), colbreak(), grid() e sub-elementos

// ---------------------------------------------------------------------------
// colunas — wrapper para columns()
// ---------------------------------------------------------------------------

/// Cria um layout de colunas de texto.
/// - `corpo`: conteúdo a ser distribuído nas colunas
/// - `quantidade`: número de colunas (padrão: 2)
/// - `espacamento`: espaçamento entre colunas (gutter)
#let colunas(
  corpo,
  quantidade: 2,
  espacamento: auto,
) = {
  assert(type(quantidade) == int and quantidade >= 1,
    message: "colunas: 'quantidade' deve ser inteiro >= 1, recebeu " + repr(quantidade))
  let args = (:)
  if espacamento != auto { args.insert("gutter", espacamento) }
  columns(quantidade, ..args, corpo)
}

// ---------------------------------------------------------------------------
// quebra-coluna — wrapper para colbreak()
// ---------------------------------------------------------------------------

/// Insere uma quebra de coluna.
/// - `fraco`: se `true`, só quebra se não estiver já no topo da coluna
#let quebra-coluna(fraco: false) = {
  colbreak(weak: fraco)
}

// ---------------------------------------------------------------------------
// grade — wrapper para grid()
// ---------------------------------------------------------------------------

/// Cria um layout de grade (grid) com parâmetros em português.
#let grade(
  ..filhos,
  colunas: auto,
  linhas: auto,
  espacamento: auto,
  espacamento-coluna: auto,
  espacamento-linha: auto,
  alinhamento: auto,
  preenchimento: auto,
  borda: auto,
  recuo: auto,
) = {
  let args = (:)
  if colunas != auto { args.insert("columns", colunas) }
  if linhas != auto { args.insert("rows", linhas) }
  if espacamento != auto { args.insert("gutter", espacamento) }
  if espacamento-coluna != auto { args.insert("column-gutter", espacamento-coluna) }
  if espacamento-linha != auto { args.insert("row-gutter", espacamento-linha) }
  if alinhamento != auto { args.insert("align", alinhamento) }
  if preenchimento != auto { args.insert("fill", preenchimento) }
  if borda != auto { args.insert("stroke", borda) }
  if recuo != auto { args.insert("inset", recuo) }
  grid(..args, ..filhos)
}

// ---------------------------------------------------------------------------
// celula — wrapper para grid.cell()
// ---------------------------------------------------------------------------

/// Cria uma célula de grade com parâmetros em português.
#let celula(
  corpo,
  extensao-coluna: auto,
  extensao-linha: auto,
  alinhamento: auto,
  preenchimento: auto,
  borda: auto,
  recuo: auto,
  quebravel: auto,
  x: auto,
  y: auto,
) = {
  let args = (:)
  if extensao-coluna != auto { args.insert("colspan", extensao-coluna) }
  if extensao-linha != auto { args.insert("rowspan", extensao-linha) }
  if alinhamento != auto { args.insert("align", alinhamento) }
  if preenchimento != auto { args.insert("fill", preenchimento) }
  if borda != auto { args.insert("stroke", borda) }
  if recuo != auto { args.insert("inset", recuo) }
  if quebravel != auto { args.insert("breakable", quebravel) }
  if x != auto { args.insert("x", x) }
  if y != auto { args.insert("y", y) }
  grid.cell(..args, corpo)
}

// ---------------------------------------------------------------------------
// linha-horizontal — wrapper para grid.hline()
// ---------------------------------------------------------------------------

/// Insere uma linha horizontal na grade.
#let linha-horizontal(
  y: auto,
  inicio: auto,
  fim: auto,
  borda: auto,
  posicao: auto,
) = {
  let args = (:)
  if y != auto { args.insert("y", y) }
  if inicio != auto { args.insert("start", inicio) }
  if fim != auto { args.insert("end", fim) }
  if borda != auto { args.insert("stroke", borda) }
  if posicao != auto { args.insert("position", posicao) }
  grid.hline(..args)
}

// ---------------------------------------------------------------------------
// linha-vertical — wrapper para grid.vline()
// ---------------------------------------------------------------------------

/// Insere uma linha vertical na grade.
#let linha-vertical(
  x: auto,
  inicio: auto,
  fim: auto,
  borda: auto,
  posicao: auto,
) = {
  let args = (:)
  if x != auto { args.insert("x", x) }
  if inicio != auto { args.insert("start", inicio) }
  if fim != auto { args.insert("end", fim) }
  if borda != auto { args.insert("stroke", borda) }
  if posicao != auto { args.insert("position", posicao) }
  grid.vline(..args)
}

// ---------------------------------------------------------------------------
// cabecalho-grade — wrapper para grid.header()
// ---------------------------------------------------------------------------

/// Cria um cabeçalho de grade (repete no topo de cada página).
#let cabecalho-grade(
  ..filhos,
  repetir: auto,
  nivel: auto,
) = {
  let args = (:)
  if repetir != auto { args.insert("repeat", repetir) }
  if nivel != auto { args.insert("level", nivel) }
  grid.header(..args, ..filhos)
}

// ---------------------------------------------------------------------------
// rodape-grade — wrapper para grid.footer()
// ---------------------------------------------------------------------------

/// Cria um rodapé de grade (repete no final de cada página).
#let rodape-grade(
  ..filhos,
  repetir: auto,
) = {
  let args = (:)
  if repetir != auto { args.insert("repeat", repetir) }
  grid.footer(..args, ..filhos)
}
