// Enumeração de listas (alíneas) conforme NBR 6024:2012
//
// Dois esquemas, escolhidos por `enumeracao` em `normas-abnt`:
// - "abnt" (padrão): alíneas `a)`, `b)`, `c)` no primeiro nível; subalíneas
//   com travessão (`–`) nos níveis seguintes (NBR 6024, seções 4 e 5).
// - "latex": `1.`, `a)`, `i)`, `A.` e `A.` repetido do quinto nível em diante,
//   como no `enumerate` do LaTeX (e no Ferrmat).

/// Função de numeração para `set enum(full: true, numbering: ...)`.
#let numeracao-enum(esquema) = if esquema == "latex" {
  (..n) => {
    let niveis = n.pos()
    let formato = ("1.", "a)", "i)", "A.").at(calc.min(niveis.len(), 4) - 1)
    numbering(formato, niveis.last())
  }
} else if esquema == "abnt" {
  (..n) => {
    let niveis = n.pos()
    if niveis.len() == 1 { numbering("a)", niveis.first()) } else { [--] }
  }
} else {
  panic("enumeracao: use \"abnt\" ou \"latex\", recebeu " + repr(esquema))
}
