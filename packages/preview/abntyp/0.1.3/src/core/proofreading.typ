// Sinais e simbolos de revisao conforme NBR 6025:2002
// Revisao de originais e provas - Sinais convencionais

/// Simbolos de correcao de texto conforme NBR 6025

/// Marca texto para supressao (deletar)
/// Exemplo: #suprimir[texto a remover]
#let suprimir(body) = {
  strike(body)
}

/// Marca texto para insercao
/// Mostra onde inserir novo conteudo
#let inserir(body) = {
  text(fill: blue)[$arrow.b$#body]
}

/// Marca texto para substituicao
/// Parametros:
/// - old: texto original (sera riscado)
/// - new: texto novo (em destaque)
#let replace-text(old, new) = {
  [#strike(old)#text(fill: blue, super[#new])]
}

/// Marca texto para transposicao
/// Indica que elementos devem trocar de posicao
#let transpose(a, b) = {
  text(fill: rgb("#8B4513"))[$arrow.l.r$#a #sym.bar.v #b]
}

/// Indica que espaco deve ser unido (remover espaco)
#let join-space() = {
  text(fill: red)[$frown$]
}

/// Indica que deve separar (adicionar espaco)
#let separate() = {
  text(fill: red, sym.hash)
}

/// Referencia ao original - indica salto de trecho
#let see-original() = {
  text(fill: purple, [(v.o.)])
}

/// Indica duvida - revisor deve consultar autor
#let duvida() = {
  text(fill: orange, weight: "bold", [?])
}

/// Correcao indevida - manter texto original
/// Equivale ao "stet" em ingles
#let keep-original(body) = {
  underline(stroke: (dash: "dotted"), body) + text(fill: green, size: 8pt, [ (vale)])
}

// === Codigos de correcao tipologica ===

/// Marca texto para italico
#let mark-italic(body) = {
  underline(body) + text(fill: gray, size: 8pt, [ (it.)])
}

/// Marca texto para negrito
#let mark-bold(body) = {
  underline(stroke: 2pt, body) + text(fill: gray, size: 8pt, [ (ng)])
}

/// Marca texto para normal (remover italico/negrito)
#let mark-normal(body) = {
  body + text(fill: gray, size: 8pt, [ (rd)])
}

/// Marca texto para caixa alta (maiusculas)
#let mark-uppercase(body) = {
  body + text(fill: gray, size: 8pt, [ (CA)])
}

/// Marca texto para caixa baixa (minusculas)
#let mark-lowercase(body) = {
  body + text(fill: gray, size: 8pt, [ (Cb)])
}

/// Marca texto para versal-versalete
#let mark-smallcaps(body) = {
  body + text(fill: gray, size: 8pt, [ (Vv)])
}

// === Marcacoes de paragrafo ===

/// Indica abertura de novo paragrafo
#let new-paragraph() = {
  text(fill: red, [#sym.chevron.r#sym.chevron.r])
}

/// Indica centralizacao
#let center-text() = {
  text(fill: blue, [#sym.arrow.l #sym.arrow.r])
}

/// Indica alinhamento a esquerda
#let align-left() = {
  text(fill: blue, sym.tack.l)
}

/// Indica alinhamento a direita
#let align-right() = {
  text(fill: blue, sym.tack.r)
}

// === Comentarios de revisao ===

/// Adiciona comentario de revisao na margem
/// Parametros:
/// - body: texto principal
/// - note: comentario do revisor
#let review-note(body, note) = {
  body + text(fill: red, size: 8pt, super[[#note]])
}

/// Adiciona comentario inline
#let inline-comment(comment) = {
  text(fill: rgb("#666666"), size: 9pt, style: "italic", [[#comment]])
}

// === Marcadores de revisao visual ===

/// Destaca texto que precisa de atencao
#let attention(body) = {
  highlight(fill: yellow, body)
}

/// Destaca texto aprovado
#let approved(body) = {
  highlight(fill: rgb("#90EE90"), body)
}

/// Destaca texto com problema
#let problem(body) = {
  highlight(fill: rgb("#FFB6C1"), body)
}

// === Ambiente de revisao ===

/// Aplica estilo de documento em revisao
/// Adiciona margens para anotacoes e numeracao de linhas
#let review-mode(body) = {
  set page(
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 4cm, // Margem maior para anotacoes
    ),
  )
  set par(
    leading: 2em, // Espaco maior entre linhas para anotacoes
  )
  body
}

/// Cria caixa de anotacao na margem
/// Para uso com place() em posicao absoluta
#let margin-note(note) = {
  place(
    right,
    dx: 3.5cm,
    box(
      width: 3cm,
      stroke: 0.5pt + gray,
      inset: 4pt,
      radius: 2pt,
      text(size: 8pt, fill: rgb("#333333"), note),
    ),
  )
}

// === Controle de alteracoes ===

/// Marca texto adicionado (para controle de versoes)
#let added(body) = {
  text(fill: rgb("#006400"), body)
}

/// Marca texto removido (para controle de versoes)
#let removed(body) = {
  text(fill: rgb("#8B0000"), strike(body))
}

/// Marca texto modificado (para controle de versoes)
#let modified(body) = {
  text(fill: rgb("#0000CD"), body)
}

// === Legenda de simbolos ===

/// Gera legenda explicativa dos simbolos de revisao
#let review-legend() = {
  set text(size: 10pt)
  set par(first-line-indent: 0pt)

  text(weight: "bold", [Legenda de Simbolos de Revisao (NBR 6025:2002)])

  v(0.5em)

  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    inset: 4pt,

    [*Simbolo*], [*Significado*],

    suprimir[texto], [Suprimir texto],
    inserir[novo], [Inserir texto],
    join-space(), [Unir (remover espaco)],
    separate(), [Separar (adicionar espaco)],
    see-original(), [Ver original (texto omitido)],
    duvida(), [Duvida - consultar autor],
    keep-original[texto], [Manter original (correcao indevida)],

    mark-italic[texto], [Alterar para italico],
    mark-bold[texto], [Alterar para negrito],
    mark-normal[texto], [Alterar para normal],
    mark-uppercase[texto], [Caixa alta (maiusculas)],
    mark-lowercase[texto], [Caixa baixa (minusculas)],
    mark-smallcaps[texto], [Versal versalete],

    new-paragraph(), [Abrir paragrafo],
    center-text(), [Centralizar],
    align-left(), [Alinhar a esquerda],
    align-right(), [Alinhar a direita],

    attention[texto], [Atencao necessaria],
    approved[texto], [Aprovado],
    problem[texto], [Problema identificado],

    added[texto], [Texto adicionado],
    removed[texto], [Texto removido],
    modified[texto], [Texto modificado],
  )
}
