// Wrappers em português para configuração de página do Typst
// Traduz nomes de parâmetros de page(), pagebreak() e margin

// ---------------------------------------------------------------------------
// Utilitário interno: traduz chaves de margem PT → EN
// ---------------------------------------------------------------------------

#let _traduzir-margem(m) = {
  if type(m) == dictionary {
    let resultado = (:)
    for (chave, valor) in m {
      let en = if chave == "superior" { "top" }
        else if chave == "inferior" { "bottom" }
        else if chave == "esquerda" { "left" }
        else if chave == "direita" { "right" }
        else if chave == "interna" { "inside" }
        else if chave == "externa" { "outside" }
        else if chave == "resto" { "rest" }
        else if chave in ("x", "y", "top", "bottom", "left", "right", "inside", "outside", "rest") { chave }
        else { panic("margem: chave desconhecida '" + chave + "'. Use: superior, inferior, esquerda, direita, interna, externa, resto, x, y") }
      resultado.insert(en, valor)
    }
    resultado
  } else {
    m // valor único (length, auto, etc.)
  }
}

// ---------------------------------------------------------------------------
// configurar-pagina — show-rule para configurar a página
// ---------------------------------------------------------------------------

/// Configura a página do documento com parâmetros em português.
/// Uso: `#show: configurar-pagina.with(papel: "a4", margem: (superior: 3cm, inferior: 2cm))`
#let configurar-pagina(
  papel: auto,
  largura: auto,
  altura: auto,
  margem: auto,
  paisagem: auto,
  colunas: auto,
  preenchimento: auto,
  numeracao: auto,
  alinhamento-numero: auto,
  cabecalho: auto,
  rodape: auto,
  pre-cabecalho: auto,
  pre-rodape: auto,
  encadernacao: auto,
  plano-de-fundo: auto,
  primeiro-plano: auto,
  corpo,
) = {
  let args = (:)
  if papel != auto { args.insert("paper", papel) }
  if largura != auto { args.insert("width", largura) }
  if altura != auto { args.insert("height", altura) }
  if margem != auto { args.insert("margin", _traduzir-margem(margem)) }
  if paisagem != auto { args.insert("flipped", paisagem) }
  if colunas != auto { args.insert("columns", colunas) }
  if preenchimento != auto { args.insert("fill", preenchimento) }
  if numeracao != auto { args.insert("numbering", numeracao) }
  if alinhamento-numero != auto { args.insert("number-align", alinhamento-numero) }
  if cabecalho != auto { args.insert("header", cabecalho) }
  if rodape != auto { args.insert("footer", rodape) }
  if pre-cabecalho != auto { args.insert("header-ascent", pre-cabecalho) }
  if pre-rodape != auto { args.insert("footer-descent", pre-rodape) }
  if encadernacao != auto { args.insert("binding", encadernacao) }
  if plano-de-fundo != auto { args.insert("background", plano-de-fundo) }
  if primeiro-plano != auto { args.insert("foreground", primeiro-plano) }
  set page(..args)
  corpo
}

// ---------------------------------------------------------------------------
// margem — helper para construir dicionário de margens em português
// ---------------------------------------------------------------------------

/// Constrói um dicionário de margens com chaves em português.
/// Uso: `margem(superior: 3cm, inferior: 2cm, esquerda: 3cm, direita: 2cm)`
#let margem(
  superior: auto,
  inferior: auto,
  esquerda: auto,
  direita: auto,
  interna: auto,
  externa: auto,
  resto: auto,
  x: auto,
  y: auto,
) = {
  let resultado = (:)
  if superior != auto { resultado.insert("top", superior) }
  if inferior != auto { resultado.insert("bottom", inferior) }
  if esquerda != auto { resultado.insert("left", esquerda) }
  if direita != auto { resultado.insert("right", direita) }
  if interna != auto { resultado.insert("inside", interna) }
  if externa != auto { resultado.insert("outside", externa) }
  if resto != auto { resultado.insert("rest", resto) }
  if x != auto { resultado.insert("x", x) }
  if y != auto { resultado.insert("y", y) }
  resultado
}

// ---------------------------------------------------------------------------
// quebra-pagina — wrapper para pagebreak()
// ---------------------------------------------------------------------------

/// Insere uma quebra de página.
/// - `fraco`: se `true`, só quebra se não estiver já no topo da página
/// - `para`: `"impar"` ou `"par"` para pular até página ímpar/par
#let quebra-pagina(fraco: false, para: none) = {
  if para != none {
    assert(para in ("impar", "par"),
      message: "quebra-pagina: 'para' deve ser \"impar\" ou \"par\", recebeu " + repr(para))
    let val = if para == "impar" { "odd" } else { "even" }
    pagebreak(weak: fraco, to: val)
  } else {
    pagebreak(weak: fraco)
  }
}

// ---------------------------------------------------------------------------
// numeracao-pagina — exibe o número da página atual
// ---------------------------------------------------------------------------

/// Exibe o número da página atual.
/// - `formato`: formato de numeração (`"1"` arábico, `"i"` romano minúsculo, `"I"` romano maiúsculo)
/// - `peso`: peso da fonte (ex: `"bold"`)
#let numeracao-pagina(formato: "1", peso: auto) = {
  context {
    let num = counter(page).display(formato)
    if peso != auto {
      text(weight: peso, num)
    } else {
      num
    }
  }
}

// ---------------------------------------------------------------------------
// marca-secao — marca corrente de seção (running header/titleps)
// ---------------------------------------------------------------------------

/// Retorna o título da seção mais recente no nível dado.
/// Para uso dentro de `cabecalho()` ou `rodape()`.
/// - `nivel`: nível do heading a buscar
/// - `caixa`: `"alta"` (upper), `"baixa"` (lower), `none`
/// - `peso`: peso da fonte
/// - `estilo`: `"italic"`, `"normal"`
/// - `com-numero`: incluir número da seção
/// - `separador`: espaço entre número e título
#let marca-secao(
  nivel: 1,
  caixa: none,
  peso: auto,
  estilo: auto,
  com-numero: false,
  separador: h(0.5em),
) = {
  context {
    let found = query(heading.where(level: nivel).before(here()))
    if found.len() == 0 { return }
    let hdg = found.last()

    let corpo = hdg.body
    if caixa == "alta" { corpo = upper(corpo) }
    else if caixa == "baixa" { corpo = lower(corpo) }

    let resultado = if com-numero and hdg.numbering != none {
      let nums = counter(heading).at(hdg.location())
      let num-str = numbering(hdg.numbering, ..nums)
      [#num-str#separador#corpo]
    } else {
      corpo
    }

    if peso != auto { resultado = text(weight: peso, resultado) }
    if estilo == "italic" { resultado = emph(resultado) }

    resultado
  }
}

// ---------------------------------------------------------------------------
// Utilitário interno: renderiza grid de 3 colunas para header/footer
// ---------------------------------------------------------------------------

#let _render-hf(esquerda, centro, direita, tamanho, fonte) = {
  set text(size: tamanho)
  if fonte != auto { set text(font: fonte) }
  grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    if esquerda != none { esquerda } else { [] },
    if centro != none { centro } else { [] },
    if direita != none { direita } else { [] },
  )
}

// ---------------------------------------------------------------------------
// Utilitário interno: despacho par/ímpar para header/footer
// ---------------------------------------------------------------------------

#let _dispatch-hf(esquerda, centro, direita, impar, par, render) = {
  let simple-mode = impar == auto and par == auto
  if simple-mode {
    render(esquerda, centro, direita)
  } else {
    context {
      let pg = counter(page).get().first()
      let is-odd = calc.odd(pg)
      if is-odd and impar != auto {
        let cfg = impar
        render(
          cfg.at("esquerda", default: none),
          cfg.at("centro", default: none),
          cfg.at("direita", default: none),
        )
      } else if not is-odd and par != auto {
        let cfg = par
        render(
          cfg.at("esquerda", default: none),
          cfg.at("centro", default: none),
          cfg.at("direita", default: none),
        )
      } else {
        render(esquerda, centro, direita)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// cabecalho — gera conteúdo de header (fancyhdr)
// ---------------------------------------------------------------------------

/// Gera conteúdo para o cabeçalho da página.
/// Modo simples: `cabecalho(esquerda: [...], direita: numeracao-pagina())`
/// Modo par/ímpar: `cabecalho(impar: (direita: marca-secao()), par: (esquerda: [Título]))`
/// - `linha`: espessura da linha separadora abaixo do cabeçalho
#let cabecalho(
  esquerda: none,
  centro: none,
  direita: none,
  impar: auto,
  par: auto,
  linha: 0pt,
  cor-linha: black,
  distancia-linha: 0.3em,
  tamanho: 10pt,
  fonte: auto,
) = {
  let render(esq, cen, dir) = {
    let content = _render-hf(esq, cen, dir, tamanho, fonte)
    if linha > 0pt {
      content
      v(distancia-linha)
      line(length: 100%, stroke: linha + cor-linha)
    } else {
      content
    }
  }
  _dispatch-hf(esquerda, centro, direita, impar, par, render)
}

// ---------------------------------------------------------------------------
// rodape — gera conteúdo de footer (fancyhdr)
// ---------------------------------------------------------------------------

/// Gera conteúdo para o rodapé da página.
/// Mesma API que `cabecalho()`, mas a linha separadora fica *acima* do conteúdo.
#let rodape(
  esquerda: none,
  centro: none,
  direita: none,
  impar: auto,
  par: auto,
  linha: 0pt,
  cor-linha: black,
  distancia-linha: 0.3em,
  tamanho: 10pt,
  fonte: auto,
) = {
  let render(esq, cen, dir) = {
    if linha > 0pt {
      line(length: 100%, stroke: linha + cor-linha)
      v(distancia-linha)
    }
    _render-hf(esq, cen, dir, tamanho, fonte)
  }
  _dispatch-hf(esquerda, centro, direita, impar, par, render)
}

// ---------------------------------------------------------------------------
// estilo-pagina — show-rule que aplica cabeçalho + rodapé + numeração
// ---------------------------------------------------------------------------

/// Atalho que aplica cabeçalho, rodapé e numeração de página de uma vez.
/// Uso: `#show: estilo-pagina.with(cabecalho: cabecalho(...), rodape: rodape(...))`
/// Campos `auto` são omitidos (não sobrescrevem configurações existentes).
#let estilo-pagina(
  cabecalho: auto,
  rodape: auto,
  numeracao: auto,
  posicao-numero: auto,
  corpo,
) = {
  let args = (:)
  if cabecalho != auto { args.insert("header", cabecalho) }
  if rodape != auto { args.insert("footer", rodape) }
  if numeracao != auto { args.insert("numbering", numeracao) }
  if posicao-numero != auto { args.insert("number-align", posicao-numero) }
  set page(..args)
  corpo
}
