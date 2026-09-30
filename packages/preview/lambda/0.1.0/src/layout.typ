// ─── LAYOUT (page, header, footer, headings, columns) ─────────────────────────
#import "theme.typ": default-theme

#let show-layout(
  body,
  theme: default-theme,
  column-count: 2,
  lead-author: "",
  short-title: "",
  foot-info: "",
  institution: "",
  show-header-footer: true,
) = {
  let accent = theme.accent
  let font-sans = theme.font-sans
  let font-serif = theme.font-serif

  set page(
    paper: theme.paper,
    margin: theme.margin,
    numbering: "1",
    header: if show-header-footer {
      [#set text(size: 7pt, font: font-sans, fill: theme.text-muted)
        #grid(
          columns: (1fr, 1fr),
          align(left, lead-author),
          align(right, short-title), ) ]
    } else { none },
    footer: if show-header-footer {
      [#set text(size: 7pt, font: font-sans, fill: theme.text-muted)
        #v(2pt)
        #grid(
          columns: (1fr, auto, 1fr),
          align(left, foot-info),
          align(center, context counter(page).display("1")),
          align(right, institution), ) ]
    } else { none }, )

  set text(size: theme.font-size, font: font-serif, lang: "en")
  set par(justify: true, leading: 0.65em)

  set heading(numbering: "1")

  show heading.where(level: 1): it => {
    v(1.2em, weak: true)
    if it.numbering == none {
      text(fill: accent, weight: "bold", size: 11pt, font: font-sans, it.body)
    } else {
      text(fill: accent, weight: "bold", size: 11pt, font: font-sans,
        counter(heading).display("1") + ". " + it.body)
    }
    v(0.4em, weak: true)
  }

  show heading.where(level: 2): it => {
    v(0.8em, weak: true)
    if it.numbering == none {
      text(weight: "bold", size: 10pt, font: font-sans, it.body)
    } else {
      text(weight: "bold", size: 10pt, font: font-sans,
        counter(heading).display("1.1") + ". " + it.body)
    }
    v(0.3em, weak: true)
  }

  show heading.where(level: 3): it => {
    v(0.6em, weak: true)
    if it.numbering == none {
      text(weight: "bold", style: "italic", size: 9.5pt, font: font-sans, it.body)
    } else {
      text(weight: "bold", style: "italic", size: 9.5pt, font: font-sans,
        counter(heading).display("1.1.1") + ". " + it.body)
    }
    v(0.2em, weak: true)
  }

  show outline: it => {
    set text(font: font-sans, fill: accent, size: 9pt)
    it
  }

  // ── Outline entry styling ──
  show outline.entry.where(level: 1): it => [
    #link(
      it.element.location(),
      it.indented(
        strong(text(fill: black)[#it.prefix()]),
        [#strong(text(fill: accent)[#it.body()])
          #h(1fr)
          #sym.wj
          #strong(text(fill: black)[#it.page()])], ), )]

  show outline.entry.where(level: 2): it => [
    #link(it.element.location(),
      it.indented(
        text(fill: black)[#it.prefix()],
        [#text(fill: accent)[#it.body()]
          #box(width: 1fr, it.fill)
          #sym.wj
          #text(fill: black)[#it.page()]], ), )]

  show outline.entry.where(level: 3): it => [
    #link(
      it.element.location(),
      it.indented(
        [], [#box(width: 100%)[
            #text(size: 7pt, fill: accent, hyphenate: false)[#it.body()]]], ), )]

  set figure(gap: 0.5em)

  show figure.caption: it => {
    set text(size: 8pt, font: font-sans)
    align(center, {
      text(weight: "bold", it.supplement + " " + it.counter.display() + ". ")
      it.body
    })
  }

  set table(stroke: none, inset: 5pt)
  show table.cell.where(y: 0): set text(weight: "bold", font: font-sans)

  set math.equation(numbering: "(1)")
  show link: set text(fill: accent)

  if column-count == 2 {
    columns(2, gutter: 15pt, body)
  } else {
    body
  }
}
