// bizuario.typ — template e componentes para bizuários em Typst
// Licença sugerida: MIT

#let ink = rgb("172033")
#let muted = rgb("5f6b7a")
#let paper = rgb("f7f8fb")
#let line = rgb("d9deea")
#let blue = rgb("2363a8")
#let blue-soft = rgb("eaf3ff")
#let green = rgb("21856a")
#let green-soft = rgb("e9f8f2")
#let orange = rgb("c87516")
#let orange-soft = rgb("fff4e3")
#let red = rgb("bd4655")
#let red-soft = rgb("fff0f2")

#let _tone(tone) = {
  if tone == "info" { (blue, blue-soft) }
  else if tone == "success" { (green, green-soft) }
  else if tone == "warning" { (orange, orange-soft) }
  else if tone == "danger" { (red, red-soft) }
  else { (ink, white) }
}

#let _label(label-text, fill: blue) = box(
  fill: fill,
  inset: (x: 5pt, y: 2pt),
  radius: 3pt,
  text(size: 7.5pt, weight: "bold", fill: white, upper(label-text)),
)

#let _rule() = line(length: 100%, stroke: 0.6pt + line)

// Use as: #show: bizuario.with(title: "...", subtitle: "...")
#let bizuario(title: "Bizuário", subtitle: none, author: none, body) = {
  set page(
    paper: "a4",
    margin: (top: 18mm, bottom: 16mm, left: 15mm, right: 15mm),
    fill: paper,
    numbering: "1",
    header: grid(
      columns: (1fr, auto),
      align: (left, right),
      [#text(size: 8pt, weight: "bold", fill: blue)[BIZUÁRIO]],
      [#text(size: 8pt, fill: muted)[#if author != none [#author]]],
    ),
    footer: grid(
      columns: (1fr, auto),
      [#text(size: 7.5pt, fill: muted)[Material de revisão rápida]],
      [#context text(size: 7.5pt, fill: muted)[Página #counter(page).display()]],
    ),
  )
  set text(font: ("Liberation Sans", "Noto Sans"), size: 9.2pt, fill: ink)
  set par(justify: true, leading: 0.9em, spacing: 0.45em)
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    set text(size: 16pt, weight: "bold", fill: blue)
    block(above: 11pt, below: 5pt)[#it.body]
  }
  show heading.where(level: 2): it => {
    set text(size: 11pt, weight: "bold", fill: ink)
    block(above: 7pt, below: 3pt)[#it.body]
  }
  show link: set text(fill: blue)

  block(
    fill: white,
    radius: 8pt,
    inset: (x: 13pt, y: 12pt),
    stroke: 1pt + line,
    below: 10pt,
  )[
    #_label("revisão rápida") \
    #v(5pt)
    #text(size: 23pt, weight: "bold", fill: ink)[#title]
    #if subtitle != none [#v(2pt) #text(size: 10pt, fill: muted)[#subtitle]]
  ]
  body
}

#let b-card(title: none, tone: "neutral", body) = {
  let (accent, tint) = _tone(tone)
  block(
    fill: white,
    radius: 5pt,
    inset: (x: 9pt, y: 8pt),
    stroke: 0.7pt + line,
    width: 100%,
    above: 4pt,
    below: 5pt,
  )[
    #if title != none [#text(weight: "bold", fill: accent)[#title] #v(3pt)]
    #body
  ]
}

#let b-alert(title: "Atenção", tone: "warning", body) = {
  let (accent, tint) = _tone(tone)
  block(
    fill: tint,
    radius: 5pt,
    inset: (x: 9pt, y: 8pt),
    stroke: 0.8pt + accent,
    width: 100%,
    above: 5pt,
    below: 6pt,
  )[
    #text(weight: "bold", fill: accent)[#title] #v(2pt) #body
  ]
}

#let b-definition(term, body) = b-card(title: term, tone: "info")[#body]

#let b-mnemonic(label, mnemonic, explanation: none) = {
  block(
    fill: blue-soft,
    radius: 5pt,
    inset: (x: 9pt, y: 8pt),
    width: 100%,
    above: 5pt,
    below: 6pt,
  )[
    #text(size: 8pt, weight: "bold", fill: blue)[#upper(label)] \
    #v(2pt)
    #text(size: 14pt, weight: "bold", fill: ink)[#mnemonic]
    #if explanation != none [#v(2pt) #text(size: 8.5pt, fill: muted)[#explanation]]
  ]
}

#let b-compare(left-title, left-body, right-title, right-body) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 7pt,
    b-card(title: left-title, tone: "success")[#left-body],
    b-card(title: right-title, tone: "danger")[#right-body],
  )
}

#let b-table(headers, rows, widths: auto) = {
  table(
    columns: widths,
    inset: 5pt,
    stroke: 0.5pt + line,
    fill: (x, y) => if y == 0 { blue } else if calc.odd(y) { white } else { rgb("f1f4f9") },
    align: left,
    table.header(..headers.map(h => text(weight: "bold", fill: white)[#h])),
    ..rows.map(row => row.map(cell => [#cell])).flatten(),
  )
}

#let b-checklist(items) = {
  set par(spacing: 0.18em)
  for item in items {
    [#text(fill: green, weight: "bold")[✓] #item #linebreak()]
  }
}

#let b-columns(left, right, gutter: 9pt) = grid(columns: (1fr, 1fr), gutter: gutter, left, right)

#let b-pagebreak() = pagebreak()

#let b-small(content) = text(size: 8pt, fill: muted)[#content]


// Componentes para disciplinas exatas

// Exibe uma fórmula em destaque. O argumento formula deve ser conteúdo matemático,
// por exemplo: $ a^2 + b^2 = c^2 $.
#let b-formula(title: "Fórmula", formula, note: none, tone: "info") = {
  let (accent, tint) = _tone(tone)
  block(
    fill: tint,
    radius: 5pt,
    inset: (x: 10pt, y: 9pt),
    stroke: 0.8pt + accent,
    width: 100%,
    above: 5pt,
    below: 6pt,
  )[
    #text(size: 8pt, weight: "bold", fill: accent)[#upper(title)]
    #v(5pt)
    #align(center)[#text(size: 14pt)[#formula]]
    #if note != none [#v(4pt) #text(size: 8.5pt, fill: muted)[#note]]
  ]
}

// Destaca a resposta final de um cálculo ou exercício.
#let b-result(label: "Resultado", value, condition: none) = {
  block(
    fill: green-soft,
    radius: 5pt,
    inset: (x: 10pt, y: 8pt),
    stroke: 1pt + green,
    width: 100%,
    above: 5pt,
    below: 6pt,
  )[
    #text(size: 8pt, weight: "bold", fill: green)[#upper(label)]
    #v(3pt)
    #align(center)[#text(size: 15pt, weight: "bold", fill: ink)[#value]]
    #if condition != none [#v(3pt) #align(center)[#text(size: 8pt, fill: muted)[#condition]]]
  ]
}

// Lista numerada para uma resolução curta e ordenada.
#let b-steps(steps, title: "Resolução") = {
  b-card(title: title, tone: "info")[
    #set par(spacing: 0.25em)
    #enum(..steps)
  ]
}

// Compara grandezas ou unidades em um cartão compacto.
#let b-unit(symbol, name, relation: none, example: none) = {
  b-card(title: symbol, tone: "success")[
    #text(weight: "bold")[#name]
    #if relation != none [#v(2pt) #text(fill: muted)[#relation]]
    #if example != none [#v(2pt) #text(size: 8.5pt, fill: muted)[Ex.: #example]]
  ]
}

// Mostra uma aproximação numérica ou constante útil.
#let b-constant(symbol, value, meaning: none) = {
  block(
    fill: white,
    radius: 5pt,
    inset: (x: 9pt, y: 7pt),
    stroke: 0.7pt + line,
    width: 100%,
    above: 4pt,
    below: 5pt,
  )[
    #grid(columns: (auto, 1fr), gutter: 7pt,
      [#text(size: 13pt, weight: "bold", fill: blue)[#symbol]],
      [#text(weight: "bold")[#value] #if meaning != none [#linebreak() #text(size: 8pt, fill: muted)[#meaning]]],
    )
  ]
}

// Caixa para hipótese, domínio ou condição de validade.
#let b-condition(title: "Condição", body) = b-alert(title: title, tone: "warning")[#body]

// Atalho para separar duas grandezas, fórmulas ou casos em colunas.
#let b-formula-pair(left, right, gutter: 7pt) = grid(
  columns: (1fr, 1fr),
  gutter: gutter,
  b-card(tone: "info")[#align(center)[#left]],
  b-card(tone: "info")[#align(center)[#right]],
)
