#let chapter-outline-entry(it) = context {
  import "info.typ"

  let typeface = info.font.get()
  let font-family = info.font-family.get()
  // Classify by semantic role, not absolute depth: front/back matter
  // chapters stay at level 1 even when main-matter chapters are level 2.

  let el = it.element

  let is-part = el.supplement == [Parte]
  let is-chapter = el.supplement in ([Capítulo], [Anexo])

  if is-part or is-chapter {
    set block(spacing: if is-part { 1.5em } else { 1.3em })

    set text(
      size: 1.25em,
      weight: if is-part { 700 } else { 600 },
      tracking: 0.025em,
      ..if is-part { (font: typeface.text.font) } else { typeface.display },
    )

    // Keep each entry in native paragraph flow. Grid cells export generic
    // Div groups inside the link instead of a continuous outline entry.
    link(el.location(), it.indented(
      {
        if el.numbering != none {
          if is-part {
            upper(el.supplement)
          } else {
            smallcaps(el.supplement)
          }
          sym.space
        }
        {
          set text(
            number-width: "tabular",
            number-type: "lining",
            stylistic-set: if font-family == "Alegreya" or font-family == "Piazzolla" { 1 } else { () },
          ) if el.supplement != [Anexo]
          it.prefix()
        }
      },
      {
        if is-part {
          upper(it.body())
        } else {
          smallcaps(it.body())
        }
        // Keep the final title word and page number on the same line.
        sym.space.nobreak
        h(1fr)
        box(inset: (left: 0.5em), text(
          it.page(),
          number-width: "tabular",
          number-type: "lining",
          stylistic-set: if font-family == "Alegreya" or font-family == "Piazzolla" { 1 } else { () },
        ))
      },
    ))
  } else {
    set text(
      weight: if el.supplement == [Sección] {
        "semibold"
      } else if el.supplement == [Subsección] {
        "medium"
      } else {
        "regular"
      },
      style: if el.supplement == [Subsubsección] {
        "italic"
      } else {
        "normal"
      },
      ..if el.supplement == [Sección] { typeface.display } else { (font: typeface.text.font) },
    )

    link(el.location(), it.indented(
      text(
        number-width: "tabular",
        number-type: "lining",
        it.prefix(),
      ),
      // Native inline layout keeps the prefix and first body line on the
      // same baseline, independently of the font's metrics.
      it.inner(),
    ))
  }
}

// Parts add one outer level; deeper indentation retains the existing scale.
#let outline-indent(level, chapter-level: 1) = {
  if level <= chapter-level { 0em }
  else if level == chapter-level + 1 { 0.5em }
  else { level * 0.25em }
}

#let general-outline = context {
  import "info.typ"

  let multi-part = info.multi-part.get()

  show outline.entry: chapter-outline-entry

  let target = heading.where(outlined: true)
  let appendices = query(heading.where(level: 1, supplement: [Anexo]))
  if appendices.len() > 0 {
    target = target.before(appendices.first().location(), inclusive: false)
  }

  outline(
    title: [Índice general],
    depth: if multi-part { 5 } else { 4 },
    target: target,
    indent: outline-indent.with(chapter-level: if multi-part { 2 } else { 1 }),
  )
}

// Keep the presence check and construction identical for all figure kinds.
#let kind-outline(title, kind) = context {
  let target = figure.where(kind: kind)
  if counter(target).final().first() != 0 {
    outline(title: title, target: target)
  }
}

#let table-outline = kind-outline([Índice de tablas], table)
#let figure-outline = kind-outline([Índice de figuras], image)
#let listing-outline = kind-outline([Índice de listados], raw)
#let math-outline = kind-outline([Índice de fórmulas], math.equation)

// Genera el índice de anexos si existen.
#let appendix-outline = context {
  show outline.entry: chapter-outline-entry
  let appendices = query(heading.where(level: 1, supplement: [Anexo]))
  if appendices.len() > 0 {
    outline(
      title: [Índice de anexos],
      depth: 4,
      target: heading.where(outlined: true).after(
        appendices.first().location(), inclusive: true,
      ),
      indent: outline-indent,
    )
  }
}

// Genera todos los índices del documento en su respectivo orden,
#let all-outlines(extra: none) = context {
  show outline.entry: set text(number-type: "lining", number-width: "tabular")
  show outline.entry: set block(spacing: 0.75em)
  show outline.entry: set par(leading: 0.65em)

  general-outline
  figure-outline
  table-outline
  math-outline
  listing-outline
  extra
  appendix-outline
}

