// Wrappers em português para formatação de seções/headings do Typst
// Equivalente ao titlesec do LaTeX

// ---------------------------------------------------------------------------
// Utilitário interno: merge de dicts (defaults + user overrides)
// ---------------------------------------------------------------------------

#let _merge(defaults, user) = {
  if user == auto { return defaults }
  let result = defaults
  for (key, value) in user { result.insert(key, value) }
  result
}

// ---------------------------------------------------------------------------
// formatar-secao — formata um nível de heading
// ---------------------------------------------------------------------------

/// Formata um heading individual. Para uso com show rules:
/// `#show heading.where(level: 1): formatar-secao.with(peso: "bold", tamanho: 16pt)`
///
/// Formas disponíveis:
/// - `"bloco"`: número + título na mesma linha, bloco separado (padrão)
/// - `"corrido"`: título corre inline com o parágrafo seguinte
/// - `"suspenso"`: número pendurado à esquerda, texto indentado
/// - `"exibicao"`: número em linha separada acima do título
#let formatar-secao(
  it,
  peso: auto,
  estilo: auto,
  tamanho: 12pt,
  fonte: auto,
  cor: auto,
  caixa: none,
  alinhamento: left,
  recuo: 0pt,
  espacamento-antes: 1.5em,
  espacamento-depois: 1.5em,
  quebra-pagina: false,
  mostrar-numero: auto,
  formato-numero: auto,
  separador-numero: h(0.5em),
  largura-numero: 2em,
  forma: "bloco",
  decoracao: none,
) = {
  // Quebra de página antes, se solicitado
  if quebra-pagina { pagebreak(weak: true) }

  // Processar corpo
  let corpo = it.body
  if caixa == "alta" { corpo = upper(corpo) }
  else if caixa == "baixa" { corpo = lower(corpo) }

  // Processar número
  let show-num = if mostrar-numero == auto { it.numbering != none } else { mostrar-numero }
  let num-fmt = if formato-numero == auto { it.numbering } else { formato-numero }

  let numero = if show-num and num-fmt != none {
    let nums = counter(heading).at(it.location())
    numbering(num-fmt, ..nums)
  }

  // Aplicar estilos de texto
  let apply-style(content) = {
    set text(size: tamanho)
    if fonte != auto { set text(font: fonte) }
    if cor != auto { set text(fill: cor) }
    if peso != auto { set text(weight: peso) }
    if estilo == "italic" {
      emph(content)
    } else {
      content
    }
  }

  // Renderizar conforme a forma
  if forma == "bloco" {
    // Número + título na mesma linha, bloco separado
    let titulo = if numero != none {
      [#numero#separador-numero#corpo]
    } else {
      corpo
    }

    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      apply-style(titulo)
      if decoracao != none { decoracao }
    })
    v(espacamento-depois, weak: true)

  } else if forma == "corrido" {
    // Título inline com o parágrafo seguinte (espacamento-depois vira espaço horizontal)
    let titulo = if numero != none {
      [#numero#separador-numero#corpo]
    } else {
      corpo
    }

    v(espacamento-antes, weak: true)
    box(inset: (left: recuo), {
      apply-style(titulo)
      if decoracao != none { decoracao }
    })
    h(espacamento-depois)

  } else if forma == "suspenso" {
    // Número pendurado à esquerda, texto indentado
    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      apply-style({
        if numero != none {
          grid(
            columns: (largura-numero, 1fr),
            column-gutter: 0.3em,
            [#numero], corpo,
          )
        } else {
          corpo
        }
      })
      if decoracao != none { decoracao }
    })
    v(espacamento-depois, weak: true)

  } else if forma == "exibicao" {
    // Número em linha separada acima do título
    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      apply-style({
        if numero != none {
          numero
          linebreak()
        }
        corpo
      })
      if decoracao != none {
        v(0.3em)
        decoracao
      }
    })
    v(espacamento-depois, weak: true)

  } else {
    panic("formatar-secao: forma desconhecida '" + forma + "'. Use: bloco, corrido, suspenso, exibicao")
  }
}

// ---------------------------------------------------------------------------
// formatar-secoes — configura todos os níveis de heading de uma vez
// ---------------------------------------------------------------------------

/// Configura formatação de múltiplos níveis de heading de uma vez.
/// Cada `secao-N` é um dicionário com as mesmas chaves de `formatar-secao()`.
/// Uso: `#show: formatar-secoes.with(secao-1: (peso: "bold", tamanho: 18pt))`
#let formatar-secoes(
  secao-1: auto,
  secao-2: auto,
  secao-3: auto,
  secao-4: auto,
  secao-5: auto,
  numeracao: "1.1",
  corpo,
) = {
  // Defaults sensatos para cada nível
  let defaults-1 = (peso: "bold", tamanho: 16pt, quebra-pagina: true)
  let defaults-2 = (peso: "bold", tamanho: 14pt)
  let defaults-3 = (peso: "bold", tamanho: 12pt)
  let defaults-4 = (tamanho: 12pt)
  let defaults-5 = (estilo: "italic", tamanho: 12pt)

  let cfg-1 = _merge(defaults-1, secao-1)
  let cfg-2 = _merge(defaults-2, secao-2)
  let cfg-3 = _merge(defaults-3, secao-3)
  let cfg-4 = _merge(defaults-4, secao-4)
  let cfg-5 = _merge(defaults-5, secao-5)

  show heading.where(level: 1): it => formatar-secao(it, ..cfg-1)
  show heading.where(level: 2): it => formatar-secao(it, ..cfg-2)
  show heading.where(level: 3): it => formatar-secao(it, ..cfg-3)
  show heading.where(level: 4): it => formatar-secao(it, ..cfg-4)
  show heading.where(level: 5): it => formatar-secao(it, ..cfg-5)

  // set heading(numbering) precisa envolver corpo para não ficar escopado num if
  if numeracao != auto {
    set heading(numbering: numeracao)
    corpo
  } else {
    corpo
  }
}
