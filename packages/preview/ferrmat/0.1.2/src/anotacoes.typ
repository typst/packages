// Módulo de anotações e notas marginais
// Notas TODO (afazer) + notas marginais explicativas + sistema de cores por autor

// ---------------------------------------------------------------------------
// Estado global: mapa de autores → cores
// ---------------------------------------------------------------------------

#let _anotacoes-autores = state("ferrmat-anotacoes-autores", (:))

// Pool de cores para atribuição automática
#let _pool-cores = (orange, purple, teal, fuchsia, olive, eastern, blue, red)

/// Registra um autor e sua cor associada.
///
/// - nome (str): nome do autor
/// - cor (color): cor associada ao autor
#let registrar-autor(nome, cor) = {
  _anotacoes-autores.update(m => {
    m.insert(nome, cor)
    m
  })
}

/// Registra vários autores de uma vez a partir de um dicionário nome → cor.
///
/// - dict (dictionary): mapeamento de nomes para cores
///   Exemplo: `("Alice": blue, "Ricardo": red, "Carol": green)`
#let registrar-autores(dict) = {
  _anotacoes-autores.update(m => {
    for (nome, cor) in dict {
      m.insert(nome, cor)
    }
    m
  })
}

// ---------------------------------------------------------------------------
// Funções auxiliares internas
// ---------------------------------------------------------------------------

/// Resolve a cor de um autor (registrada ou automática do pool).
/// Se o autor não estiver registrado, atribui uma cor do pool e registra
/// automaticamente para manter consistência em chamadas subsequentes.
/// Deve ser chamada dentro de um bloco `context`.
#let _resolver-cor(autor, cor-manual) = {
  if cor-manual != auto { return cor-manual }
  if autor == none { return orange }

  let mapa = _anotacoes-autores.get()
  if autor in mapa {
    mapa.at(autor)
  } else {
    // Atribuição cíclica do pool baseada na quantidade de autores já registrados
    let idx = mapa.len()
    _pool-cores.at(calc.rem(idx, _pool-cores.len()))
  }
}

/// Extrai o valor de uma margem (esquerda ou direita) a partir de `page.margin`.
#let _extrair-margem(margem, lado) = {
  let chave = if lado == left { "left" } else { "right" }
  if type(margem) == dictionary {
    if chave in margem { margem.at(chave) }
    else if "x" in margem { margem.x }
    else { 2cm }
  } else { margem }
}

/// Normaliza o valor de `lado` aceitando português ou inglês.
#let _normalizar-lado(lado) = {
  if lado == left or lado == right or lado == auto { lado }
  else if lado == "esquerda" { left }
  else if lado == "direita" { right }
  else { lado }  // fallback
}

/// Posiciona conteúdo na margem da página.
/// Deve ser chamada dentro de um bloco `context`.
#let _colocar-na-margem(body, lado, largura-nota, dy) = {
  let lado-norm = _normalizar-lado(lado)

  let margem = page.margin
  let m-esq = _extrair-margem(margem, left)
  let m-dir = _extrair-margem(margem, right)

  // Quando auto, detecta qual margem é maior e usa essa.
  let target = if lado-norm == auto {
    if m-esq > m-dir { left } else { right }
  } else { lado-norm }

  let nota-largura = if largura-nota == auto { 3.2cm } else { largura-nota }

  // Centraliza a nota horizontalmente dentro da margem.
  // place(right) alinha a borda DIREITA do bloco à borda direita do texto,
  // então dx = (margem + largura) / 2 empurra o centro da nota para o centro da margem.
  let m-alvo = if target == right { m-dir } else { m-esq }

  // Mede a altura da nota para centralizar verticalmente com a linha do texto
  let nota-bloco = block(width: nota-largura, body)
  let nota-alt = measure(nota-bloco).height

  place(
    target,
    dx: if target == right { (m-alvo + nota-largura) / 2 } else { -(m-alvo + nota-largura) / 2 },
    dy: dy - nota-alt / 2 + 0.5em - 0.7cm,
    nota-bloco,
  )
}

// ---------------------------------------------------------------------------
// Notas TODO (afazer)
// ---------------------------------------------------------------------------

/// Cria uma nota de pendência (TODO).
///
/// - body (content): texto da pendência
/// - autor (str): nome do autor (usa cor registrada ou automática)
/// - cor (color, auto): cor manual; `auto` usa a cor do autor
/// - em-linha (bool): se `true`, renderiza inline ao invés de na margem
/// - lado (alignment, str, auto): `esquerda`, `direita` ou `auto` (margem externa em frente-e-verso)
/// - destaque (content, none): trecho de texto a destacar com a cor da nota, indicando a que se refere (estilo todonotes)
#let afazer(
  body,
  autor: none,
  cor: auto,
  em-linha: false,
  lado: auto,
  destaque: none,
) = context {
  let cor-final = _resolver-cor(autor, cor)

  // Registra autor não-registrado para manter cor consistente em chamadas futuras
  if cor == auto and autor != none {
    let mapa = _anotacoes-autores.get()
    if autor not in mapa {
      _anotacoes-autores.update(m => { m.insert(autor, cor-final); m })
    }
  }

  // Metadata para coleta na lista de pendências
  [#metadata((texto: body, autor: autor, cor: cor-final, tipo: "afazer")) <_afazer>]

  // Destaque indicando o trecho referido (estilo todonotes)
  if destaque != none {
    highlight(fill: cor-final.lighten(88%), destaque)
  }

  if em-linha {
    // Renderização inline — envolvida em figure para que esconder-tarefas funcione
    [#figure(kind: "_afazer", supplement: none, outlined: false,
      block(
        width: 100%,
        inset: 8pt,
        radius: 3pt,
        stroke: 0.8pt + cor-final,
        fill: cor-final.lighten(85%),
      )[
        #set text(size: 9pt)
        #set par(first-line-indent: 0pt)
        #if autor != none [#text(weight: "bold", fill: cor-final)[#autor:] ]
        #body
      ]
    )]
  } else {
    // Figura invisível para que esconder-tarefas funcione (place não é capturado por show-rules)
    [#figure(kind: "_afazer", supplement: none, outlined: false, none)]
    // Renderização na margem
    _colocar-na-margem(
      block(
        inset: 5pt,
        radius: 2pt,
        stroke: 0.6pt + cor-final,
        fill: cor-final.lighten(88%),
      )[
        #set text(size: 7.5pt)
        #set par(first-line-indent: 0pt, leading: 0.5em)
        #if autor != none [#text(weight: "bold", fill: cor-final)[#autor] \ ]
        #body
      ],
      lado,
      auto,
      0pt,
    )
  }
}

// ---------------------------------------------------------------------------
// Presets de categoria
// ---------------------------------------------------------------------------

/// Nota urgente (vermelho).
#let urgente(body, autor: none, em-linha: false, destaque: none) = afazer(body, autor: autor, cor: red, em-linha: em-linha, destaque: destaque)

/// Nota para revisão (laranja/amarelo).
#let revisar(body, autor: none, em-linha: false, destaque: none) = afazer(body, autor: autor, cor: orange, em-linha: em-linha, destaque: destaque)

/// Nota de melhoria (azul).
#let melhorar(body, autor: none, em-linha: false, destaque: none) = afazer(body, autor: autor, cor: blue, em-linha: em-linha, destaque: destaque)

/// Nota de verificação (verde).
#let verificar(body, autor: none, em-linha: false, destaque: none) = afazer(body, autor: autor, cor: green, em-linha: em-linha, destaque: destaque)

// ---------------------------------------------------------------------------
// Placeholder de figura ausente
// ---------------------------------------------------------------------------

/// Renderiza um placeholder para uma figura que ainda não existe.
///
/// - descricao (content): descrição da figura faltando
/// - largura (length): largura do placeholder
/// - altura (length): altura do placeholder
/// - cor (color): cor de fundo
#let figura-faltando(
  descricao,
  largura: 100%,
  altura: 4cm,
  cor: red.lighten(80%),
) = {
  // Registra como pendência
  [#metadata((texto: descricao, autor: none, cor: red, tipo: "figura-faltando")) <_afazer>]

  // Envolvido em figure para que esconder-tarefas funcione
  [#figure(kind: "_afazer", supplement: none, outlined: false,
    block(
      width: largura,
      height: altura,
      inset: 1em,
      radius: 4pt,
      stroke: (dash: "dashed", paint: red, thickness: 1.5pt),
      fill: cor,
    )[
      #set align(center + horizon)
      #set par(first-line-indent: 0pt)
      #text(size: 20pt)[⚠] \
      #text(size: 10pt, style: "italic")[#descricao]
    ]
  )]
}

// ---------------------------------------------------------------------------
// Notas marginais explicativas (estilo livro de cálculo)
// ---------------------------------------------------------------------------

/// Posiciona uma nota explicativa na margem da página.
///
/// - body (content): texto da nota marginal
/// - lado (alignment, str, auto): `esquerda`, `direita` ou `auto`
/// - largura (length, auto): largura da nota
/// - dy (length): deslocamento vertical
/// - ancora (label, none): label para referência cruzada
/// - borda (stroke, none): borda opcional
/// - cor (color, none): cor de fundo opcional
#let nota-margem(
  body,
  lado: auto,
  largura: auto,
  dy: 0pt,
  ancora: none,
  borda: none,
  cor: none,
) = {
  // Marcador para que esconder-anotacoes possa ocultar notas marginais
  [#figure(kind: "_nota-margem", supplement: none, outlined: false, none)]

  context {
    _colocar-na-margem(
      block(
        inset: if borda != none or cor != none { 4pt } else { 0pt },
        radius: if borda != none or cor != none { 2pt } else { 0pt },
        stroke: borda,
        fill: cor,
      )[
        #set text(size: 8pt)
        #set par(first-line-indent: 0pt, leading: 0.45em, justify: false)
        #body
        #if ancora != none { ancora }
      ],
      lado,
      largura,
      dy,
    )
  }
}

// ---------------------------------------------------------------------------
// Lista de pendências
// ---------------------------------------------------------------------------

/// Gera uma lista de todas as pendências registradas com `afazer()` e `figura-faltando()`.
///
/// - titulo (content): título da seção
#let lista-de-tarefas(titulo: "Lista de Pendências") = context {
  let itens = query(<_afazer>)

  if itens.len() == 0 {
    return [_Nenhuma pendência encontrada._]
  }

  heading(level: 2, numbering: none, titulo)

  set par(first-line-indent: 0pt)

  for item in itens {
    let dados = item.value
    let loc = item.location()
    let pg = counter(page).at(loc).first()
    let cor-item = if type(dados.cor) == color { dados.cor } else { gray }

    block(
      width: 100%,
      inset: (x: 0.5em, y: 0.3em),
      below: 0.4em,
    )[
      #set text(size: 10pt)
      #box(width: 8pt, height: 8pt, fill: cor-item, radius: 1pt)
      #h(0.4em)
      #if dados.autor != none [*#dados.autor* -- ]
      #if dados.tipo == "figura-faltando" [_(Figura faltando)_ ]
      #dados.texto
      #h(1fr)
      #text(fill: gray)[p. #pg]
    ]
  }
}

// ---------------------------------------------------------------------------
// Ocultação global
// ---------------------------------------------------------------------------

/// Show-rule para ocultar todas as notas de pendência (TODOs).
/// Oculta tanto as notas visuais (inline e margem) quanto os metadados.
/// Uso: `#show: esconder-tarefas`
#let esconder-tarefas(body) = {
  show figure.where(kind: "_afazer"): none
  show metadata.where(label: <_afazer>): none
  body
}

/// Show-rule para ocultar todas as anotações (TODOs + notas marginais).
/// Uso: `#show: esconder-anotacoes`
#let esconder-anotacoes(body) = {
  show figure.where(kind: "_afazer"): none
  show figure.where(kind: "_nota-margem"): none
  show metadata.where(label: <_afazer>): none
  body
}
