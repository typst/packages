// Listas ordenadas: numeração escolhida na chamada e subitens com a), b), c)

// Profundidade da lista ordenada em curso (1 = primeiro nível)
#let _nivel-enum = state("ferrmat-enum-nivel", 0)

/// Lista ordenada com numeração por nível, sem precisar de `#set enum(...)`.
/// Os itens são escritos com `+` dentro do corpo; um `+` indentado cria o
/// nível seguinte. Padrão: `1.` / `a)` / `i)` / `A.`.
///
/// - `numeracao`: numeração do primeiro nível (padrão do Typst: `"1."`,
///   `"a)"`, `"i."`, `"A."`, ...). `auto` usa `"1."`.
/// - `subitens`: numeração dos níveis internos: uma string (todos os níveis
///   internos iguais) ou um array, um formato por nível (2º, 3º, ...).
///   Padrão: `("a)", "i)", "A.")`.
///
/// Uso local:
/// ```typst
/// #enumeracao[
///   + Primeiro item
///     + subitem a)
///       + subsubitem i)
///   + Segundo item
/// ]
/// ```
///
/// Uso no documento inteiro:
/// ```typst
/// #show: enumeracao
/// ```
#let enumeracao(corpo, numeracao: auto, subitens: ("a)", "i)", "A.")) = {
  let internos = if type(subitens) == str { (subitens,) } else { subitens }
  let formatos = ((if numeracao == auto { "1." } else { numeracao }),) + internos
  show enum: it => {
    _nivel-enum.update(n => n + 1)
    it
    _nivel-enum.update(n => n - 1)
  }
  set enum(numbering: (..n) => context {
    let nivel = _nivel-enum.get()
    numbering(formatos.at(calc.min(nivel, formatos.len()) - 1), ..n)
  })
  corpo
}
