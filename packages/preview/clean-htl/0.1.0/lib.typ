#let ink = rgb("202a33")
#let accent = rgb("1f628c")
#let rule = rgb("aeb8bf")
#let muted = luma(35%)

#let callout(title: "Hinweis", color: accent, body) = block(
  width: 100%,
  breakable: true,
  above: 0.55em,
  below: 0.55em,
  fill: color.lighten(90%),
  stroke: (left: 2pt + color),
  inset: (left: 3mm, right: 2mm, y: 2mm),
  [
    #text(9pt, weight: "bold", fill: color)[#title]
    #h(1.5mm)
    #body
  ],
)

#let definition(body) = callout(title: "Definition", body)
#let remember(body) = callout(title: "Merksatz", color: rgb("765a30"), body)
#let example(body) = callout(title: "Beispiel", color: rgb("53677a"), body)
#let result(body) = callout(title: "Ergebnis", color: rgb("42634c"), body)
#let note(body) = callout(title: "Notiz", color: accent, body)
#let warning(body) = callout(title: "Achtung", color: rgb("a14f19"), body)
#let question(body) = callout(title: "Frage", color: rgb("664f91"), body)
#let hl(body) = highlight(fill: rgb("ffe58a"), radius: 1pt, body)

#let htl-notes(
  title: "Thema",
  subject: "Fach",
  student: "Name",
  class: "Klasse",
  teacher: none,
  date: datetime.today(),
  body,
) = {
  set document(title: title, author: student)
  set page(
    paper: "a4",
    margin: (top: 30mm, bottom: 17mm, x: 19mm),
    header-ascent: 3mm,
    footer-descent: 8mm,
    header: {
      grid(
        columns: (1fr, auto),
        gutter: 8mm,
        align: bottom,
        [
          #text(15pt, weight: "bold", fill: ink)[#subject]
          #linebreak()
          #text(10pt, fill: muted)[#title]
        ],
        align(right)[
          #text(9pt, weight: "bold", fill: ink)[#class]
          #linebreak()
          #text(9pt, fill: muted)[#date.display("[day].[month].[year]")]
        ],
      )
      v(1.2mm)
      grid(
        columns: (1fr, auto),
        text(9pt, fill: muted)[#student],
        if teacher != none { text(9pt, fill: muted)[#teacher] },
      )
      v(1.4mm)
      line(length: 100%, stroke: 0.9pt + accent)
    },
    footer: context {
      line(length: 100%, stroke: 0.5pt + rule)
      v(1.5mm)
      grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        text(8pt, fill: muted)[#student],
        text(8pt, fill: muted)[#subject],
        text(8pt, fill: muted)[Seite #counter(page).display("1 / 1", both: true)],
      )
    },
  )

  set text(
    lang: "de",
    font: ("Source Sans 3", "Libertinus Serif"),
    size: 10.5pt,
    fill: ink,
  )
  set par(justify: false, leading: 0.68em, spacing: 0.65em)
  set heading(numbering: none)
  set list(indent: 1.15em, body-indent: 0.55em)
  set enum(indent: 1.15em, body-indent: 0.55em)
  set table(stroke: 0.5pt + rule, inset: (x: 2mm, y: 1.5mm))
  show table.cell.where(y: 0): set text(weight: "bold", fill: ink)

  show heading.where(level: 1): it => block(above: 0.8em, below: 0.4em)[
    #text(14pt, weight: "bold", fill: ink)[#it.body]
  ]
  show heading.where(level: 2): it => block(above: 0.7em, below: 0.3em)[
    #text(11.5pt, weight: "bold", fill: ink)[#it.body]
  ]
  show math.equation: set text(font: ("Noto Sans Math", "New Computer Modern Math"))
  show math.equation.where(block: true): it => block(
    width: 100%,
    above: 0.55em,
    below: 0.55em,
    fill: accent.lighten(93%),
    stroke: 0.65pt + rule,
    inset: (x: 3mm, y: 2.5mm),
    radius: 1.5pt,
    align(center, it),
  )

  body
}
