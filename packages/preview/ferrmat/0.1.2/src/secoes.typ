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
/// - `"faixa"`: bloco com fundo colorido — ideal para capítulos
/// - `"barra"`: barra vertical colorida à esquerda
/// - `"emblema"`: número em badge colorido à esquerda do título
#let formatar-secao(
  it,
  peso: auto,
  estilo: auto,
  tamanho: 12pt,
  fonte: auto,
  cor: auto,
  // cor separada para o número (usado em "faixa" para criar contraste sutil)
  cor-numero: auto,
  // fundo do bloco ("faixa") ou do badge ("emblema")
  fundo: none,
  // cor e espessura da barra lateral ("barra")
  cor-barra: auto,
  espessura-barra: 4pt,
  // linha horizontal abaixo do heading
  linha-abaixo: false,
  cor-linha: auto,
  espessura-linha: 0.7pt,
  // raio de cantos para faixa/emblema
  raio: 0pt,
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
  if quebra-pagina { pagebreak(weak: true) }

  let corpo = it.body
  if caixa == "alta" { corpo = upper(corpo) }
  else if caixa == "baixa" { corpo = lower(corpo) }

  let show-num = if mostrar-numero == auto { it.numbering != none } else { mostrar-numero }
  let num-fmt = if formato-numero == auto { it.numbering } else { formato-numero }

  let numero = if show-num and num-fmt != none {
    let nums = counter(heading).at(it.location())
    numbering(num-fmt, ..nums)
  }

  // Resolve cores com fallbacks sensatos
  let _cor-barra  = if cor-barra  != auto { cor-barra  } else if cor != auto { cor } else { black }
  let _cor-linha  = if cor-linha  != auto { cor-linha  } else { luma(200) }
  let _cor-numero = if cor-numero != auto { cor-numero } else if cor != auto { cor } else { black }

  let apply-style(content) = {
    set text(size: tamanho)
    if fonte != auto { set text(font: fonte) }
    if cor != auto   { set text(fill: cor)   }
    if peso != auto  { set text(weight: peso) }
    if estilo == "italic" { emph(content) } else { content }
  }

  // =========================================================================

  if forma == "bloco" {
    let titulo = if numero != none { [#numero#separador-numero#corpo] } else { corpo }
    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      apply-style(titulo)
      if decoracao != none { decoracao }
    })
    v(espacamento-depois, weak: true)

  } else if forma == "corrido" {
    let titulo = if numero != none { [#numero#separador-numero#corpo] } else { corpo }
    v(espacamento-antes, weak: true)
    box(inset: (left: recuo), {
      apply-style(titulo)
      if decoracao != none { decoracao }
    })
    h(espacamento-depois)

  } else if forma == "suspenso" {
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
    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      apply-style({
        if numero != none { numero; linebreak() }
        corpo
      })
      if decoracao != none { v(0.3em); decoracao }
    })
    v(espacamento-depois, weak: true)

  } else if forma == "faixa" {
    // Bloco com fundo colorido — estilo web h1/hero
    // cor-numero permite diferenciar o algarismo do texto principal dentro da faixa
    v(espacamento-antes, weak: true)
    block(
      width: 100%,
      fill: if fundo != none { fundo } else { _cor-barra },
      radius: raio,
      inset: (x: 1.4em, y: 0.85em),
      {
        set align(alinhamento)
        set text(size: tamanho)
        if fonte != auto { set text(font: fonte) }
        if peso != auto  { set text(weight: peso) }
        if numero != none {
          text(fill: _cor-numero, size: tamanho * 0.75, numero)
          h(0.65em)
        }
        let body-content = if estilo == "italic" { emph(corpo) } else { corpo }
        if cor != auto { text(fill: cor, body-content) } else { body-content }
      }
    )
    if linha-abaixo {
      v(-0.15em)
      line(length: 100%, stroke: espessura-barra + _cor-linha)
    }
    v(espacamento-depois, weak: true)

  } else if forma == "barra" {
    // Barra vertical colorida à esquerda — estilo web h2/h3
    v(espacamento-antes, weak: true)
    block(
      width: 100%,
      fill: if fundo != none { fundo } else { none },
      stroke: (left: espessura-barra + _cor-barra),
      inset: (left: 1.5em, right: 0pt, top: 0.2em, bottom: 0.2em),
      {
        set align(alinhamento)
        apply-style(if numero != none { [#numero#separador-numero#corpo] } else { corpo })
        if decoracao != none { v(0.2em); decoracao }
      }
    )
    if linha-abaixo {
      line(length: 100%, stroke: espessura-linha + _cor-linha)
    }
    v(espacamento-depois, weak: true)

  } else if forma == "emblema" {
    // Número em badge colorido à esquerda — estilo web h3/h4
    v(espacamento-antes, weak: true)
    block(width: 100%, inset: (left: recuo), {
      set align(alinhamento)
      if numero != none {
        box(
          fill: if fundo != none { fundo } else { _cor-barra },
          inset: (x: 0.42em, y: 0.22em),
          radius: raio,
          text(fill: white, weight: "bold", size: tamanho * 0.82, numero)
        )
        h(0.52em)
      }
      apply-style(corpo)
      if decoracao != none { decoracao }
    })
    v(espacamento-depois, weak: true)

  } else {
    panic("formatar-secao: forma desconhecida '" + forma + "'. Use: bloco, corrido, suspenso, exibicao, faixa, barra, emblema")
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

  if numeracao != auto {
    set heading(numbering: numeracao)
    corpo
  } else {
    corpo
  }
}

// ===========================================================================
// TEMAS WEB — estilos de heading inspirados em design moderno de webpages
// ===========================================================================
//
// Fontes usadas: somente Linux Biolinum (sans) e Linux Libertine (serif),
// embutidas no Typst e sempre disponíveis sem instalação.
//
// Uso: #show: tema-nordico   (ou tema-vinho / tema-bosque)
//      #show: tema-nordico.with(numeracao: "I.1")
// ===========================================================================

// ---------------------------------------------------------------------------
// Tema Nórdico — Navy #1e2540 + Âmbar #e8a020 · Linux Biolinum
// ---------------------------------------------------------------------------
// H1  faixa navy cheia, texto branco caixa alta, número em âmbar escuro
// H2  barra âmbar 5 pt à esquerda, texto navy, fio cinza claro abaixo
// H3  badge âmbar com número branco, título em navy
// H4  texto âmbar escuro, semibold, tamanho reduzido
// H5  itálico, slate médio
// ---------------------------------------------------------------------------

/// Tema de alto contraste com paleta naval e acento âmbar.
/// `#show: tema-nordico` ou `#show: tema-nordico.with(numeracao: "I.1")`
#let tema-nordico(numeracao: "1.1", corpo) = {
  let navy  = rgb("#1e2540")
  let ambar = rgb("#e8a020")
  let slate = rgb("#5a6070")
  let cinza = rgb("#ddddd8")

  show heading.where(level: 1): it => formatar-secao(it,
    forma: "faixa",
    fundo: navy,
    cor: white,
    cor-numero: ambar,
    peso: "bold",
    tamanho: 20pt,
    fonte: "Linux Biolinum",
    caixa: "alta",
    linha-abaixo: true,
    cor-linha: ambar,
    espessura-barra: 3pt,
    espacamento-antes: 2em,
    espacamento-depois: 1.2em,
    quebra-pagina: true,
  )
  show heading.where(level: 2): it => formatar-secao(it,
    forma: "barra",
    cor: navy,
    cor-barra: ambar,
    espessura-barra: 5pt,
    peso: "bold",
    tamanho: 15pt,
    fonte: "Linux Biolinum",
    linha-abaixo: true,
    cor-linha: cinza,
    espacamento-antes: 1.8em,
    espacamento-depois: 0.8em,
  )
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "emblema",
    cor: navy,
    fundo: ambar,
    raio: 2pt,
    peso: "bold",
    tamanho: 13pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1.4em,
    espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "bloco",
    cor: ambar.darken(15%),
    peso: "semibold",
    tamanho: 11.5pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1.2em,
    espacamento-depois: 0.4em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "bloco",
    cor: slate,
    estilo: "italic",
    tamanho: 11pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1em,
    espacamento-depois: 0.3em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// Tema Vinho — Borgonha #7b1d30 + Dourado #b8880a · Linux Libertine
// ---------------------------------------------------------------------------
// H1  faixa borgonha, texto creme, número em dourado pálido
// H2  barra borgonha 6 pt, fundo creme rosado muito sutil, fio bege abaixo
// H3  badge borgonha com número creme, título carvão
// H4  texto borgonha, semibold, small-caps via caixa-alta reduzida
// H5  itálico, carvão médio
// ---------------------------------------------------------------------------

/// Tema elegante com paleta de borgonha e acento dourado, em fonte serifada.
/// `#show: tema-vinho` ou `#show: tema-vinho.with(numeracao: "I.1")`
#let tema-vinho(numeracao: "1.1", corpo) = {
  let borgonha = rgb("#7b1d30")
  let dourado  = rgb("#b8880a")
  let creme    = rgb("#f9f5ef")
  let carvao   = rgb("#282828")
  let bege     = rgb("#d8cfc4")
  let rosado   = rgb("#f5ece8")

  show heading.where(level: 1): it => formatar-secao(it,
    forma: "faixa",
    fundo: borgonha,
    cor: creme,
    cor-numero: dourado,
    peso: "bold",
    tamanho: 22pt,
    fonte: "Linux Libertine",
    quebra-pagina: true,
    espacamento-antes: 2em,
    espacamento-depois: 1.2em,
  )
  show heading.where(level: 2): it => formatar-secao(it,
    forma: "barra",
    cor: borgonha,
    cor-barra: borgonha,
    espessura-barra: 6pt,
    fundo: rosado,
    peso: "bold",
    tamanho: 16pt,
    fonte: "Linux Libertine",
    linha-abaixo: true,
    cor-linha: bege,
    espacamento-antes: 1.8em,
    espacamento-depois: 0.8em,
  )
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "emblema",
    cor: carvao,
    fundo: borgonha,
    raio: 1pt,
    peso: "bold",
    tamanho: 13.5pt,
    fonte: "Linux Libertine",
    espacamento-antes: 1.4em,
    espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "bloco",
    cor: borgonha,
    peso: "semibold",
    tamanho: 12pt,
    fonte: "Linux Libertine",
    caixa: "alta",
    espacamento-antes: 1.2em,
    espacamento-depois: 0.4em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "bloco",
    cor: rgb("#5c4a42"),
    estilo: "italic",
    tamanho: 11.5pt,
    fonte: "Linux Libertine",
    espacamento-antes: 1em,
    espacamento-depois: 0.3em,
  )
  set heading(numbering: numeracao)
  corpo
}

// ---------------------------------------------------------------------------
// Tema Bosque — Verde floresta #1e3d2a + Areia #b89850 · Linux Biolinum
// ---------------------------------------------------------------------------
// H1  faixa verde floresta com cantos arredondados, texto branco quente
// H2  bloco sem barra, linha verde espessa abaixo — contraste pela linha
// H3  badge verde médio com número branco, título quase preto
// H4  texto verde médio, peso regular com tamanho menor
// H5  itálico, verde dessaturado
// ---------------------------------------------------------------------------

/// Tema editorial com paleta de verde floresta e areia quente.
/// `#show: tema-bosque` ou `#show: tema-bosque.with(numeracao: "I.1")`
#let tema-bosque(numeracao: "1.1", corpo) = {
  let floresta = rgb("#1e3d2a")
  let medio    = rgb("#3a6b4e")
  let areia    = rgb("#b89850")
  let quente   = rgb("#f8f4ec")
  let escuro   = rgb("#1a1a1a")
  let musgo    = rgb("#5a7a62")

  show heading.where(level: 1): it => formatar-secao(it,
    forma: "faixa",
    fundo: floresta,
    cor: quente,
    cor-numero: areia,
    peso: "bold",
    tamanho: 20pt,
    fonte: "Linux Biolinum",
    raio: 3pt,
    quebra-pagina: true,
    espacamento-antes: 2em,
    espacamento-depois: 1.2em,
  )
  show heading.where(level: 2): it => formatar-secao(it,
    // "bloco" + decoracao como linha grossa cria contraste limpo sem barra lateral
    forma: "bloco",
    cor: floresta,
    peso: "bold",
    tamanho: 15pt,
    fonte: "Linux Biolinum",
    decoracao: line(length: 100%, stroke: 2pt + floresta),
    espacamento-antes: 1.8em,
    espacamento-depois: 0.8em,
  )
  show heading.where(level: 3): it => formatar-secao(it,
    forma: "emblema",
    cor: escuro,
    fundo: medio,
    raio: 2pt,
    peso: "bold",
    tamanho: 13pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1.4em,
    espacamento-depois: 0.6em,
  )
  show heading.where(level: 4): it => formatar-secao(it,
    forma: "bloco",
    cor: medio,
    peso: "semibold",
    tamanho: 11.5pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1.2em,
    espacamento-depois: 0.4em,
  )
  show heading.where(level: 5): it => formatar-secao(it,
    forma: "bloco",
    cor: musgo,
    estilo: "italic",
    tamanho: 11pt,
    fonte: "Linux Biolinum",
    espacamento-antes: 1em,
    espacamento-depois: 0.3em,
  )
  set heading(numbering: numeracao)
  corpo
}
