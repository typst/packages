// ── Theme definitions ──────────────────────────────────────────────────────────
#let themes = (
  purple: (bg: rgb("#f2e9f2"), fr: rgb("#74007b")),
  teal:   (bg: rgb("#e9f2f0"), fr: rgb("#007070")),
  brown:  (bg: rgb("#f2efe9"), fr: rgb("#7b5700")),
  red:    (bg: rgb("#f0e5e5"), fr: rgb("#af0101")),
  gray:   (bg: rgb("#f1f1f1"), fr: rgb("#7e7676")),
)

// Internal state to share theme colors with problem/solution functions
#let _theme-state = state("assignment-theme", themes.teal)

// ── Assignment template ────────────────────────────────────────────────────────
// Parameters:
//   author, email, roll   — single-author shorthand (default)
//   num-of-authors        — set > 1 to enable multi-author table layout
//   authors               — array of (name, email, roll) dicts (required when num-of-authors > 1)
//   theme                 — theme name string ("teal", "purple", …) or custom (bg: …, fr: …) dictionary
//   font-size, font-family — document-wide typography overrides
#let assignment(
  title: "Assignment",
  author: "Student Name",
  email: "email@example.com",
  roll: "123456",
  num-of-authors: 1,
  authors: none,
  course: "Course Name",
  date: datetime.today().display(),
  theme: "teal",
  font-size: 11pt,
  font-family: "Linux Libertine",
  body
) = {
  // Resolve theme colors
  let colors = if type(theme) == str { themes.at(theme) } else { theme }
  _theme-state.update(colors)

  // Resolve author list
  let author-list = if authors != none { authors }
    else { ((name: author, email: email, roll: roll),) }

  set document(title: title, author: author-list.map(a => a.name))
  set page(paper: "a4", margin: (x: 1.5cm, y: 2cm))
  set text(font: font-family, size: font-size, lang: "en")
  set par(justify: true, first-line-indent: 0pt)

  if num-of-authors > 1 {
    // ── Multi-author table header ──────────────────────────────────────────
        align(center)[*Course:* #course] 
        v(-0.5cm)
        align(center)[#text(weight: "bold", size: 14pt)[#title]]
        v(-0.4cm)
        align(center)[*Date:* #date]
        v(-0.1cm)
        line(length: 100%, stroke: 1.5pt)
        v(-0.3cm)
    table(
      columns: (1fr,) * num-of-authors,
      align: center + horizon,
      stroke: 0pt,
      inset: 3pt,
      // Author names
      ..author-list.map(a => text(weight: "bold")[#a.name]),
      // Author roll numbers
      ..author-list.map(a => text()[Roll: #a.roll]),
    )
  } else {
    // ── Single-author header ───────────────────────────────────────────────
    let a = author-list.at(0)
    grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      align(left)[
        #text(size: 14pt, weight: "bold")[#a.name] \
        Email: #link("mailto:" + a.email)[#a.email] \
        Roll: #a.roll
      ],
      align(right)[
        #text(size: 14pt, weight: "bold")[#title] \
        Course: #text(size: 11pt)[#course] \
        Date: #date
      ]
    )
  }
  v(0.1cm)
  body
}

// ── Problem box ────────────────────────────────────────────────────────────────
#let problem-counter = counter("problem")
#let problem(title: none, body) = {
  problem-counter.step()
  context {
    let colors = _theme-state.get()
    let p-num = problem-counter.display()
    block(
      width: 100%,  
      fill: colors.bg,
      stroke: (left: 2pt + colors.fr),
      radius: 5pt,
      inset: (top: 0.5em, bottom: 0.5em, left: 1em, right: 1em),
      breakable: true,
      [
        #text(fill: colors.fr, weight: "bold")[Problem #p-num]
        #if title != none [#text(fill: colors.fr)[#title]]
        #parbreak()
        #body
      ]
    )
  }
}

// ── Solution block ─────────────────────────────────────────────────────────────
#let solution(body) = {
  context{
  let colors = _theme-state.get()
  block(
    width: 100%,
    breakable: true,
    inset: (top: 0.5em, bottom: 0.5em, left: 1.5em, right: 1em),
    [
      #text(style: "italic", weight: "bold")[Solution:]
      #parbreak()
      #body
    ]
  )}
  v(0.5cm)
}


