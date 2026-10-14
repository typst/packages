// Seções e subseções conforme NBR 6024:2012

#import "../core/lists.typ": numeracao-enum
#import "../core/sorting.typ": sort-key

/// Aplica formatação de headings ABNT
#let with-abnt-headings(body) = {
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 3): it => {
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 4): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 5): it => {
    v(1.5em)
    text(weight: "regular", style: "italic", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  body
}

/// Configuração de títulos de seção conforme ABNT
/// - Seção primária: MAIÚSCULAS, negrito
/// - Seção secundária: MAIÚSCULAS, sem negrito
/// - Seção terciária: Minúsculas, negrito
/// - Seção quaternária: Minúsculas, sem negrito
/// - Seção quinária: Minúsculas, itálico
/// Uso: `#show: abnt-heading-setup` (equivale a `with-abnt-headings`)
#let abnt-heading-setup(body) = with-abnt-headings(body)

/// Título sem numeração — para Referências, Glossário, Apêndices etc.
/// Aparece no sumário. Nível padrão: 1 (seção primária).
/// Exemplo: #titulo-sem-num[REFERÊNCIAS]  ou  #titulo-sem-num("REFERÊNCIAS")
/// `@rótulo` produz "Seção Título" (link); vale com `normas-abnt` e os templates
/// (regra `show ref` em `with-abnt-setup`).
#let titulo-sem-num(titulo, nivel: 1) = {
  heading(level: nivel, numbering: none, supplement: [Seção #titulo], upper(titulo))
}

// Alias de retrocompatibilidade
#let secao = titulo-sem-num

/// Apêndice ABNT — material elaborado pelo próprio autor.
/// Cria heading nível 1 sem numeração automática; a letra é fornecida pelo autor (A, B, C...).
/// Aparece no sumário. `@rótulo` produz "Apêndice A" (link); vale com `normas-abnt`
/// e os templates (regra `show ref` em `with-abnt-setup`).
/// Exemplo: #apendice("A", "Questionário aplicado") <apendice-a>
#let apendice(letra, titulo) = {
  heading(level: 1, numbering: none, supplement: "Apêndice " + upper(letra))[APÊNDICE #upper(letra) -- #upper(titulo)]
}

/// Anexo ABNT — material NÃO elaborado pelo autor.
/// Cria heading nível 1 sem numeração automática; a letra é fornecida pelo autor (A, B, C...).
/// Aparece no sumário. `@rótulo` produz "Anexo A" (link); vale com `normas-abnt`
/// e os templates (regra `show ref` em `with-abnt-setup`).
/// Exemplo: #anexo("A", "Norma NBR 14724") <anexo-a>
#let anexo(letra, titulo) = {
  heading(level: 1, numbering: none, supplement: "Anexo " + upper(letra))[ANEXO #upper(letra) -- #upper(titulo)]
}

/// Glossário ABNT — lista de termos técnicos em ordem alfabética (pós-textual).
/// Imprime o título "GLOSSÁRIO" (sem indicativo numérico, em caixa alta, que
/// aparece no sumário) e lista cada par em ordem alfabética. Não precisa de
/// `#titulo-sem-num` antes — a função já cria o título.
/// Para o template de projeto use `glossario-projeto`; para livro, `book-glossary`.
/// - itens: dicionário termo -> definição
/// - quebra: se true (padrão), a página seguinte começa depois do glossário (quebra fraca:
///   não deixa página em branco no fim). Dentro de `columns`/`block` o Typst não aceita quebra
///   de página: use `quebra: false`.
/// Exemplo: #glossario(("Algoritmo": "Sequência finita de instruções."))
#let glossario(itens, quebra: true) = {
  titulo-sem-num[GLOSSÁRIO]

  set par(first-line-indent: 0pt)

  for (termo, definicao) in itens.pairs().sorted(key: p => sort-key(p.at(0))) {
    [*#termo:* #definicao]
    linebreak()
    v(0.5em)
  }

  if quebra { pagebreak(weak: true) }
}

/// Título de elemento pré-textual (não aparece no sumário)
#let pretextual-title(titulo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, upper(titulo))
  ]
  v(1.5em)
}

/// Alíneas (NBR 6024): itens `+` numerados a), b), c); listas aninhadas
/// saem com travessão (subalíneas).
/// Já é o padrão de `normas-abnt`; use esta função para forçar o formato
/// em um trecho (ex.: documento sem `normas-abnt`, ou com `enumeracao: "latex"`).
#let alineas(body) = {
  set enum(full: true, numbering: numeracao-enum("abnt"))
  body
}

/// Subalíneas (NBR 6024): itens `-` com travessão.
#let subalineas(body) = {
  set list(marker: [--])
  body
}

/// Parte de um documento (como em livros): "Parte 1: Título", numerada
/// automaticamente, em página própria. Aparece no sumário e pode ser
/// referenciada com `@rótulo`, que produz "Parte 1".
///
/// Uso:
/// ```typst
/// #parte[Fundamentos] <parte:fundamentos>
/// = Primeiro capítulo
/// ...
/// Veja a @parte:fundamentos.
/// ```
/// A formatação (página própria, centralizada) vem de `with-abnt-setup`,
/// que `normas-abnt`, `relatorio`, `livro` e `artigo` já aplicam.
#let parte(titulo) = figure(
  [],
  kind: "parte",
  supplement: [Parte],
  numbering: "1",
  caption: titulo,
  gap: 0pt,
)
