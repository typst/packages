// Tabelas conforme IBGE e NBR 14724:2024

/// Configuração de tabelas conforme ABNT/IBGE
/// - Bordas apenas superior, inferior e separando cabeçalho
/// - Legenda na parte superior
/// - Fonte na parte inferior
#let abnt-table-setup() = {
  show figure.where(kind: table): it => {
    set align(center)
    it
  }
}

/// Tabela no padrão IBGE (sem bordas laterais).
/// Formatador de conteúdo — deve ser usada dentro de `container()`.
/// Aceita os mesmos parâmetros de `table()`, mas aplica `stroke: none`
/// automaticamente (padrão IBGE: sem bordas laterais).
///
/// Uso (dentro de um `container`):
/// ```typst
/// #container(legenda: "População", tipo: "tabela", origem: "IBGE (2023)")[
///   #tabela(columns: 2,
///     table.hline(stroke: 1.5pt),
///     [*Região*], [*População*],
///     table.hline(stroke: 0.75pt),
///     [Nordeste], [57M],
///     table.hline(stroke: 1.5pt),
///   )
/// ]
/// ```
#let tabela(..args) = {
  table(stroke: none, ..args)
}

/// Nota de tabela
#let nota-tabela(conteudo) = {
  align(left)[
    #text(size: 10pt)[Nota: #conteudo]
  ]
}
