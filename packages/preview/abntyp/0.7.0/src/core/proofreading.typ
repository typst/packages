// Sinais e simbolos de revisao conforme NBR 6025:2002
// Revisao de originais e provas - Sinais convencionais
//
// Os sinais da norma (tabelas 1 e 2) sao desenhos manuscritos; aqui eles sao
// redesenhados em tracos vetoriais, na cor de cada funcao (a norma, 3.2, pede
// cor diferente da do texto). Nao foram desenhados: "transpor para varias
// palavras consecutivas" (numeracao), "subscrever" e "sobrescrever caractere",
// "colocar no ponto indicado pela seta", as variacoes da barra de atencao e
// "evitar sequencia de hifens" (alternativa ao sinal de "evitar brancos no
// final de linha"); dos sinais com alternativa so um e implementado, como
// a norma manda ("deve-se optar por um unico sinal").

// === Desenho dos sinais ===

/// Passos de um traco em fracoes de 1em (origem no canto superior esquerdo):
/// ("M", x, y) inicia; ("L", x, y) reta; ("C", x1, y1, x2, y2, x, y) curva; ("Z",) fecha
#let _traco(passos, cor, espessura) = {
  let pt(x, y) = (x * 1em, y * 1em)
  curve(
    stroke: espessura + cor,
    ..passos.map(p => if p.at(0) == "M" {
      curve.move(pt(p.at(1), p.at(2)))
    } else if p.at(0) == "L" {
      curve.line(pt(p.at(1), p.at(2)))
    } else if p.at(0) == "C" {
      curve.cubic(pt(p.at(1), p.at(2)), pt(p.at(3), p.at(4)), pt(p.at(5), p.at(6)))
    } else {
      curve.close()
    }),
  )
}

/// Passos de uma poligonal a partir de pontos (x, y); `fechar` liga o ultimo ao primeiro
#let _poli(..pontos, fechar: false) = {
  let passos = pontos.pos().enumerate().map(((i, p)) => (if i == 0 { "M" } else { "L" }, p.at(0), p.at(1)))
  if fechar { passos + (("Z",),) } else { passos }
}

/// Caixa de 1em de altura com os tracos desenhados dentro dela
#let _sinal(largura, ..tracos, cor: red, espessura: 0.6pt) = box(
  width: largura * 1em,
  height: 1em,
  baseline: 0.15em,
  {
    for t in tracos.pos() {
      place(top + left, _traco(t, cor, espessura))
    }
  },
)

/// Rotulo circulado (codigos tipologicos e "vale", "v.o" da norma)
#let _circulo(cor, corpo) = box(
  stroke: 0.5pt + cor,
  radius: 1em,
  inset: (x: 0.4em),
  outset: (y: 0.15em),
  text(fill: cor, corpo),
)

/// Simbolos de correcao de texto conforme NBR 6025

/// Marca texto para supressao (deletar)
/// Sinal da norma: traco horizontal entre dois tracos verticais (tabela 1, 4.3)
/// Exemplo: #suprimir[texto a remover]
#let suprimir(body) = {
  text(fill: red, sym.bar.v) + strike(stroke: 0.6pt + red, body) + text(fill: red, sym.bar.v)
}

/// Suprimir letras: "x" ou "phi" (a norma pede um unico sinal)
/// - forma: "x" (padrao) ou "fi"
#let suprimir-letras(forma: "x") = {
  text(fill: red, style: "italic", if forma == "fi" { "φ" } else { "x" })
}

/// Suprimir espaco: traco vertical entre dois arcos
#let suprimir-espaco() = _sinal(
  0.55,
  (("M", 0.06, 0.3), ("C", 0.12, 0.0, 0.43, 0.0, 0.49, 0.3)),
  (("M", 0.06, 0.7), ("C", 0.12, 1.0, 0.43, 1.0, 0.49, 0.7)),
  _poli((0.275, 0.12), (0.275, 0.88)),
)

/// Retirar e unir: "x" entre dois arcos
#let retirar-e-unir() = _sinal(
  0.55,
  (("M", 0.06, 0.25), ("C", 0.12, -0.05, 0.43, -0.05, 0.49, 0.25)),
  (("M", 0.06, 0.75), ("C", 0.12, 1.05, 0.43, 1.05, 0.49, 0.75)),
  _poli((0.15, 0.3), (0.4, 0.7)),
  _poli((0.4, 0.3), (0.15, 0.7)),
)

/// Marca texto para insercao
/// Mostra onde inserir novo conteudo (sinal "V", tabela 1)
#let inserir(body) = {
  text(fill: blue)[#_sinal(0.7, _poli((0.05, 0.15), (0.35, 0.9), (0.65, 0.15)), cor: blue)#body]
}

/// Marca texto para substituicao
/// Parametros:
/// - old: texto original (sera riscado)
/// - new: texto novo (em destaque)
#let replace-text(old, new) = {
  [#strike(old)#text(fill: blue, super[#new])]
}

/// Substituir letra: traco inclinado
#let substituir-letra() = _sinal(0.4, _poli((0.1, 0.95), (0.3, 0.05)))

/// Marca texto para transposicao
/// Indica que elementos devem trocar de posicao: o primeiro leva o colchete
/// aberto para cima e o segundo, o aberto para baixo (sinal da tabela 1)
#let transpose(a, b) = {
  let traco = 0.5pt + rgb("#8B4513")
  text(fill: rgb("#8B4513"))[#box(stroke: (left: traco, bottom: traco, right: traco), inset: (x: 1.5pt, bottom: 1.5pt), a)#h(0.3em)#box(stroke: (left: traco, top: traco, right: traco), inset: (x: 1.5pt, top: 1.5pt), b)]
}

/// Sinal de margem de transpor letra, palavra ou trecho (tabela 1)
#let transpor-sinal() = _sinal(
  2.4,
  _poli((0.05, 0.1), (0.05, 0.9), (0.5, 0.9), (0.5, 0.1), (0.95, 0.1), (0.95, 0.9)),
  _poli((1.45, 0.9), (1.45, 0.1), (1.9, 0.1), (1.9, 0.9), (2.35, 0.9), (2.35, 0.0)),
  cor: rgb("#8B4513"),
)

/// Transpor linhas: um "2" e um "5" quadrados (tabela 1)
#let transpor-linhas() = _sinal(
  1.3,
  _poli((0.05, 0.1), (0.5, 0.1), (0.5, 0.5), (0.05, 0.5), (0.05, 0.9), (0.5, 0.9)),
  _poli((1.25, 0.1), (0.8, 0.1), (0.8, 0.5), (1.25, 0.5), (1.25, 0.9), (0.8, 0.9)),
  cor: rgb("#8B4513"),
)

/// Indica que o espaco deve ser unido: sinal de "Unir" da norma (tabela 1),
/// um arco em "S"; o de "Suprimir espaco" e outro (`suprimir-espaco`)
#let join-space() = _sinal(
  0.95,
  (("M", 0.05, 0.55), ("C", 0.15, -0.05, 0.4, -0.05, 0.5, 0.5), ("C", 0.6, 1.05, 0.85, 1.05, 0.95, 0.4)),
)

/// Indica que deve separar (adicionar espaco)
#let separate() = {
  text(fill: red, sym.hash)
}

/// Referencia ao original - indica salto de trecho (sinal "v.o" circulado)
#let see-original() = {
  _circulo(purple)[v.o]
}

/// Indica duvida - revisor deve consultar autor
#let duvida() = {
  text(fill: orange, weight: "bold", [?])
}

/// Correcao indevida - manter texto original
/// Equivale ao "stet" em ingles; sinal da norma: "vale" circulado ou traco tracejado
#let keep-original(body) = {
  underline(stroke: (dash: "dotted"), body) + text(fill: green, size: 8pt, [ #_circulo(green)[vale]])
}

// === Codigos de correcao tipologica ===
// Na norma o codigo vai circulado na margem

/// Alterar tipologia (fonte)
#let mark-typeface(body) = {
  body + text(size: 8pt, [ #_circulo(gray)[fonte]])
}

/// Marca texto para italico
#let mark-italic(body) = {
  underline(body) + text(size: 8pt, [ #_circulo(gray)[it.]])
}

/// Marca texto para negrito
/// - label: "neg" (padrao) ou "bold" (a norma pede um unico sinal)
#let mark-bold(body, label: "neg") = {
  underline(stroke: 2pt, body) + text(size: 8pt, [ #_circulo(gray, label)])
}

/// Marca texto para normal (remover italico/negrito)
/// - label: "red" (padrao) ou "nom" (a norma pede um unico sinal)
#let mark-normal(body, label: "red") = {
  body + text(size: 8pt, [ #_circulo(gray, label)])
}

/// Marca texto para caixa alta (maiúsculas)
#let mark-uppercase(body) = {
  body + text(size: 8pt, [ #_circulo(gray)[CA]])
}

/// Marca texto para caixa baixa (minúsculas)
#let mark-lowercase(body) = {
  body + text(size: 8pt, [ #_circulo(gray)[Cb]])
}

/// Marca texto para caixa alta e baixa
#let mark-titlecase(body) = {
  body + text(size: 8pt, [ #_circulo(gray)[Cab]])
}

/// Marca texto para versal-versalete
#let mark-smallcaps(body) = {
  body + text(size: 8pt, [ #_circulo(gray)[Vv]])
}

// === Marcacoes de paragrafo ===

/// Indica abertura de novo paragrafo (colchete aberto, tabela 2)
#let new-paragraph() = _sinal(0.5, _poli((0.45, 0.1), (0.12, 0.1), (0.12, 0.9), (0.45, 0.9)))

/// Indica centralizacao (par de colchetes, tabela 2)
#let center-text() = _sinal(
  1.5,
  _poli((0.45, 0.1), (0.12, 0.1), (0.12, 0.9), (0.45, 0.9)),
  _poli((1.05, 0.1), (1.38, 0.1), (1.38, 0.9), (1.05, 0.9)),
  cor: blue,
)

/// Indica alinhamento a esquerda
#let align-left() = {
  text(fill: blue, sym.tack.l)
}

/// Indica alinhamento a direita
#let align-right() = {
  text(fill: blue, sym.tack.r)
}

/// Recorrer texto: curva que volta, terminada em seta para a esquerda (tabela 2)
#let recorrer-texto() = _sinal(
  1.2,
  (("M", 0.05, 0.7), ("C", -0.1, 0.45, 0.2, 0.3, 0.4, 0.55), ("C", 0.6, 0.8, 0.95, 0.75, 1.1, 0.45), ("C", 1.15, 0.3, 1.0, 0.25, 0.8, 0.3)),
  _poli((0.95, 0.12), (0.8, 0.3), (0.95, 0.48)),
)

/// Abrir entrelinha: traco terminado em "<" (tabela 2)
#let abrir-entrelinha() = _sinal(
  1.2,
  _poli((0.05, 0.5), (0.85, 0.5)),
  _poli((1.1, 0.2), (0.85, 0.5), (1.1, 0.8)),
)

/// Diminuir entrelinha: seta terminada em "x" (tabela 2)
#let diminuir-entrelinha() = _sinal(
  1.3,
  _poli((0.9, 0.5), (0.1, 0.5)),
  _poli((0.3, 0.25), (0.1, 0.5), (0.3, 0.75)),
  _poli((0.95, 0.25), (1.25, 0.75)),
  _poli((1.25, 0.25), (0.95, 0.75)),
)

/// Evitar brancos entre as linhas do texto: dois ziguezagues (tabela 2)
#let evitar-brancos-entre-linhas() = _sinal(
  0.7,
  _poli((0.25, 0.0), (0.05, 0.33), (0.3, 0.66), (0.1, 1.0)),
  _poli((0.6, 0.0), (0.4, 0.33), (0.65, 0.66), (0.45, 1.0)),
)

/// Evitar sequencia de brancos no final de linha: um ziguezague (tabela 2)
#let evitar-brancos-no-fim-da-linha() = _sinal(
  0.35,
  _poli((0.25, 0.0), (0.05, 0.33), (0.3, 0.66), (0.1, 1.0)),
)

/// Evitar palavra ou trecho repetido em linhas seguidas: retangulo (tabela 2)
#let evitar-palavra-repetida() = _sinal(
  1.2,
  _poli((0.05, 0.2), (1.15, 0.2), (1.15, 0.8), (0.05, 0.8), fechar: true),
)

/// Descondensar texto: traco com dentes (tabela 2)
#let descondensar() = _sinal(
  1.3,
  _poli((0.0, 0.3), (1.25, 0.3)),
  ..range(0, 13).map(i => _poli((0.05 + i * 0.1, 0.3), (0.05 + i * 0.1, 0.85))),
)

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
// EXTENSAO do pacote: marcadores de cor sem sinal correspondente na NBR 6025
// (attention, approved, problem, added, removed, modified)

/// Destaca texto que precisa de atencao (extensao do pacote, fora da NBR 6025)
#let attention(body) = {
  highlight(fill: yellow, body)
}

/// Destaca texto aprovado (extensao do pacote, fora da NBR 6025)
#let approved(body) = {
  highlight(fill: rgb("#90EE90"), body)
}

/// Destaca texto com problema (extensao do pacote, fora da NBR 6025)
#let problem(body) = {
  highlight(fill: rgb("#FFB6C1"), body)
}

// === Ambiente de revisao ===

/// Aplica estilo de documento em revisao
/// Adiciona margens para anotacoes e numeracao de linhas
/// (extensao do pacote: a margem de 4 cm e o espacamento duplo nao vem da norma)
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
// (extensao do pacote, fora da NBR 6025)

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
/// Primeiro os sinais das tabelas 1 e 2 da NBR 6025:2002; no fim, em bloco
/// separado, as extensoes do pacote (marcadores de cor), que nao vem da norma
#let review-legend() = {
  set text(size: 10pt)
  set par(first-line-indent: 0pt)

  text(weight: "bold", [Legenda de Símbolos de Revisão (NBR 6025:2002)])

  v(0.5em)

  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    inset: 4pt,

    [*Símbolo*], [*Significado*],

    table.cell(colspan: 2)[_Tabela 1 - Códigos de correção de texto_],

    join-space(), [Unir],
    [#suprimir-letras() ou #suprimir-letras(forma: "fi")], [Suprimir letras],
    suprimir[texto], [Suprimir palavras ou trecho],
    suprimir-espaco(), [Suprimir espaço],
    separate(), [Separar letras ou palavras],
    retirar-e-unir(), [Retirar e unir],
    inserir[novo], [Inserir],
    [#transpose[uma][outra] #transpor-sinal()], [Transpor letra, palavra ou trecho],
    transpor-linhas(), [Transpor linhas],
    see-original(), [Salto de trecho (ver original)],
    duvida(), [Há dúvida (revisor deve resolver com o autor)],
    substituir-letra(), [Substituir letra],
    keep-original[texto], [Correção indevida (permanece o texto anterior)],

    table.cell(colspan: 2)[_Tabela 2 - Códigos de correção tipológica e visual_],

    new-paragraph(), [Abrir parágrafo],
    recorrer-texto(), [Recorrer texto],
    center-text(), [Centralizar texto],
    align-left(), [Alinhar texto à esquerda],
    align-right(), [Alinhar texto à direita],
    abrir-entrelinha(), [Abrir entrelinha],
    diminuir-entrelinha(), [Diminuir entrelinha],
    mark-typeface[texto], [Alterar tipologia],
    mark-italic[texto], [Alterar para itálico],
    [#mark-bold[texto] ou #mark-bold(label: "bold")[texto]], [Alterar para negrito],
    [#mark-normal[texto] ou #mark-normal(label: "nom")[texto]], [Alterar para estilo normal ou redondo],
    mark-uppercase[texto], [Usar caixa alta],
    mark-lowercase[texto], [Usar caixa baixa],
    mark-titlecase[texto], [Usar caixa alta e baixa],
    mark-smallcaps[texto], [Usar versal versalete],
    evitar-brancos-entre-linhas(), [Evitar brancos entre as linhas do texto],
    evitar-brancos-no-fim-da-linha(), [Evitar sequência de brancos no final de linha],
    evitar-palavra-repetida(), [Evitar palavra ou trecho repetido em linhas seguidas],
    descondensar(), [Descondensar texto],

    table.cell(colspan: 2)[_Extensões do pacote, fora da NBR 6025_],

    attention[texto], [Atenção necessária],
    approved[texto], [Aprovado],
    problem[texto], [Problema identificado],

    added[texto], [Texto adicionado],
    removed[texto], [Texto removido],
    modified[texto], [Texto modificado],
  )
}
