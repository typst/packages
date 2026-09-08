// This package includes 8 document templates for Typst. These templates include "Thesis, Note, Exercise, Assignment, Exam, Project, Submission and Chi" templates.
// Each template takes inputs like "title", "author" and "supervisor" and automatically creates page-setup, frontpage, and outline
// The sdust package also provides several types of blocks, including theorem, definition, and proof blocks, as well as question and answer blocks.
// Cover pages render no university/department logo by default. Pass your own with `logo: image("sdu-logo.png", width: 12em)`.

// ══════════════════════════════════════════════════════
// IMPORTS
// ══════════════════════════════════════════════════════

#import "@preview/wordometer:0.1.5": word-count as _word-count, total-words as totalwords
#let word-count = _word-count
#let total-words = totalwords
#import "@preview/itemize:0.2.0" as itmz

// ══════════════════════════════════════════════════════
// SDU BRANDING
// ══════════════════════════════════════════════════════

// SDU visual identity — primary "SDU red".
#let sdu-red = rgb("#C40418")
#let sdu-university = "University of Southern Denmark"

// Departments of SDU's Faculty of Science — pass one as `department:`.
#let imada   = "Department of Mathematics and Computer Science"
#let bmb     = "Department of Biochemistry and Molecular Biology"
#let biology = "Department of Biology"
#let fkf     = "Department of Physics, Chemistry and Pharmacy"

// The SDU logo is a controlled brand asset and is NOT bundled with this
// package. SDU students: download it from SDUnet and pass it yourself, e.g.
//   #show: thesis.with(logo: image("sdu-logo.png", width: 12em), ...)
// Templates render no logo unless you pass one (`logo: none` by default).

// ══════════════════════════════════════════════════════
// BASE STYLE
// ══════════════════════════════════════════════════════

// Fancy code-block styling (codly) lives in the `utilst` package:
//   #import "@preview/utilst:0.1.0": code-style
//   #show: code-style

#let base-style(body) = {
  show: _word-count
  // Centered "current/total" page number in the footer of every page.
  set page(numbering: "1/1", number-align: center)
  set text(font: "New Computer Modern", size: 12pt)
  set heading(numbering: "1.1")
  set enum(numbering: "1.", full: true)
  show: itmz.default-enum-list.with(indent: auto, item-spacing: auto)
  set math.equation(numbering: none)
  set math.mat(delim: "[", gap: 0.3em)
  // 1.5 line spacing.
  set par(justify: true, leading: 0.65em)
  set image(width: 30em)
  show grid: it => {
    set image(width: auto)
    it
  }
  body
}

#let page-setup(body) = {
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 2cm, bottom: 2cm))
  base-style(body)
}

// ══════════════════════════════════════════════════════
// UTILITIES
// ══════════════════════════════════════════════════════

#let _fmt-authors(author) = {
  if type(author) == array { author.join(" · ") }
  else { author }
}

// custom citations
#let bib = bibliography.with(style: "chicago-author-date")

// end-of-proof tombstone symbol
#let QED = h(1fr) + box(width: 0.6em, height: 0.6em, stroke: 0.8pt + black)

// Internal base for the titled cards below: coloured header bar + tinted body.
#let _titled-card(
  title: none,
  width: 100%,
  header-fill: rgb("#334155"),
  body-fill: rgb("#f8fafc"),
  border: rgb("#d8dde6"),
  body-text-fill: rgb("#1c1e26"),
  body-font: auto,
  body-size: 10.5pt,
  body-leading: 0.65em,
  content,
) = std.block(
  width: width,
  stroke: 0.5pt + border,
  radius: 2pt,
  clip: true,
  {
    if title != none {
      std.block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        fill: header-fill,
        inset: (left: 14pt, right: 14pt, top: 8pt, bottom: 8pt),
        text(fill: white, weight: "bold", size: 10.5pt, title),
      )
    }
    std.block(
      width: 100%,
      above: 0pt,
      below: 0pt,
      fill: body-fill,
      inset: (left: 14pt, right: 14pt, top: 10pt, bottom: 10pt),
      {
        set par(leading: body-leading)
        set text(fill: body-text-fill, size: body-size, ..(if body-font == auto { (:) } else { (font: body-font) }))
        content
      },
    )
  },
)

// gray default block, e.g. #block(title: "Note")[Body text.]
#let block(title: none, width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#6b7280"), body-fill: rgb("#f3f4f6"),
  border: rgb("#d1d5db"), body-text-fill: rgb("#1f2937"),
  content,
)

// blue theorem, e.g. #theorem(title: "Theorem 1")[For all $x$, ...]
#let theorem(title: "Theorem", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#1565c0"), body-fill: rgb("#ecf3fc"),
  border: rgb("#b3cdeb"), body-text-fill: rgb("#0d2e57"),
  content,
)

// purple corollary, e.g. #corollary[Follows directly from Theorem 1.]
#let corollary(title: "Corollary", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#6d28d9"), body-fill: rgb("#f3ecfd"),
  border: rgb("#d8b9f2"), body-text-fill: rgb("#3b1257"),
  content,
)

// green definition, e.g. #definition(title: "Definition (Group)")[A set $G$ with ...]
#let definition(title: "Definition", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#2e7d32"), body-fill: rgb("#ecfdf5"),
  border: rgb("#a7f3d0"), body-text-fill: rgb("#14532d"),
  content,
)

// red example, e.g. #example[Let $x = 2$, then ...]
#let example(title: "Example", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#c62828"), body-fill: rgb("#fdeced"),
  border: rgb("#f2b9bc"), body-text-fill: rgb("#5a1212"),
  content,
)

// white/neutral proof — same shape as example, plain color,
// e.g. #proof[By induction on $n$. ...]
#let proof(title: "Proof", width: 100%, content) = _titled-card(
  title: title, width: width,
  header-fill: rgb("#4b5563"), body-fill: white,
  border: rgb("#d1d5db"), body-text-fill: rgb("#1f2937"),
  [#content],
)

// ═══════════════════════════
// QUESTION AND ANSWERS BLOCKS
// ═══════════════════════════

// prompt block, e.g. #question(title: "Exercise 1")[Solve for $x$.]
#let question(title: none, body) = std.block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  fill: luma(245),
  [
    #if title != none {
      strong(title)
      h(0.5em)
    }
    #body
  ],
)

// indented answer body under a #question, e.g. #answer[$x = 2$.]
#let answer(body) = std.block(
  width: 100%,
  inset: (left: 10pt, right: 10pt, top: 4pt, bottom: 10pt),
  stroke: (left: 1pt + luma(180)),
  body,
)


// ══════════════════
// DOCUMENT TEMPLATES
// ══════════════════

#let default-title  = "Untitled Document"
#let default-course = sdu-university
#let default-author = "Firstname Lastname"
#let default-date   = "16/12/2002"

// ── Thesis ──
#let thesis(
  title: default-title,
  subtitle: none,
  author: default-author,
  supervisor: none,
  department: none,
  programme: none,
  university: sdu-university,
  date: default-date,
  logo: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      if logo != none { stack(v(1.4cm), scale(220%)[#logo], v(2.6cm)) } else { v(1.2cm) },
      text(size: 17pt, fill: rgb("#555555"))[#smallcaps[#university]],
    
      v(0.6em),
      line(length: 60%, stroke: 0.5pt + sdu-red),
      v(2.5cm),
      text(size: 12.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[
        #if programme != none { upper(programme) } else [#smallcaps[THESIS]]
      ],
      v(2.4em),
      text(size: 30pt, weight: "bold")[#title],
      if subtitle != none {
        stack(v(2em), text(size: 15pt, fill: rgb("#444444"), style: "italic")[#smallcaps[subtitle]])
      },
      v(1em),
      line(length: 40%, stroke: 0.5pt + rgb("#aaaaaa")),
      v(10em),
      if supervisor != none {
        stack(
          v(2.5em),
          text(size: 16pt, fill: rgb("#0b0b0b"))[
            *Author*#if type(author) == array and author.len() > 1 [*s*]: \
            #_fmt-authors(author)
          ],
        )
      },

      if supervisor != none {
        stack(
          v(2.5em),
          text(size: 12pt, fill: rgb("#666666"))[
            *Supervisor*#if type(supervisor) == array and supervisor.len() > 1 [*s*]: \
            #_fmt-authors(supervisor)
          ],
        )
      },
      v(1cm),
      if department != none {
        stack(v(0.4em), text(size: 14pt, fill: rgb("#777777"))[#smallcaps[#department]])
      },
      v(6em),
      text(size: 12pt, fill: rgb("#888888"))[#date],
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

// ── note ─────────────────────────────────────────────
#let note(
  title: default-title,
  subtitle: none,
  author: default-author,
  supervisor: none,
  course: default-course,
  date: default-date,
  logo: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      v(1.2cm),
      line(length: 100%, stroke: 3pt + sdu-red),
      v(1.2em),
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[LECTURE NOTES],
      v(2.5cm),
      text(size: 30pt, weight: "bold")[#title],
      if subtitle != none {
        stack(v(1em), text(size: 14pt, fill: rgb("#444444"), style: "italic")[#subtitle])
      },
      v(1.3em),
      line(length: 28%, stroke: 0.5pt + rgb("#bbbbbb")),
      v(0.7em),
      text(size: 14pt, fill: rgb("#444444"))[#course],
      v(1fr),
      text(size: 12pt)[#_fmt-authors(author)],
      if supervisor != none {
        stack(v(0.4em), text(size: 10pt, fill: rgb("#666666"))[
          Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]: #_fmt-authors(supervisor)
        ])
      },
      v(0.3em),
      text(size: 11pt, fill: rgb("#888888"))[#date],
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

// ── exercise ─────────────────────────────────────────
#let exercise(
  title: default-title,
  author: default-author,
  supervisor: none,
  course: default-course,
  date: default-date,
  logo: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      v(1.2cm),
      line(length: 100%, stroke: 3pt + sdu-red),
      v(1.2em),
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[EXERCISES],
      v(2.5cm),
      text(size: 30pt, weight: "bold")[#title],
      v(1.3em),
      line(length: 28%, stroke: 0.5pt + rgb("#bbbbbb")),
      v(0.7em),
      text(size: 14pt, fill: rgb("#444444"))[#course],
      v(1fr),
      text(size: 12pt)[#_fmt-authors(author)],
      if supervisor != none {
        stack(v(0.4em), text(size: 10pt, fill: rgb("#666666"))[
          Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]: #_fmt-authors(supervisor)
        ])
      },
      v(0.3em),
      text(size: 11pt, fill: rgb("#888888"))[#date],
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

// ── assignment ───────────────────────────────────────
#let assignment(
  title: default-title,
  author: default-author,
  supervisor: none,
  course: default-course,
  date: default-date,
  logo: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      v(1.2cm),
      line(length: 100%, stroke: 3pt + sdu-red),
      v(1.2em),
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[ASSIGNMENTS],
      v(2.5cm),
      text(size: 30pt, weight: "bold")[#title],
      v(1.3em),
      line(length: 28%, stroke: 0.5pt + rgb("#bbbbbb")),
      v(0.7em),
      text(size: 14pt, fill: rgb("#444444"))[#course],
      v(1fr),
      text(size: 12pt)[#_fmt-authors(author)],
      if supervisor != none {
        stack(v(0.4em), text(size: 10pt, fill: rgb("#666666"))[
          Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]: #_fmt-authors(supervisor)
        ])
      },
      v(1.8em),
      text(size: 11pt, fill: rgb("#888888"))[#date],
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

// ── project ──────────────────────────────────────────
#let project(
  title: default-title,
  subtitle: none,
  author: default-author,
  course: default-course,
  date: default-date,
  group: none,
  supervisor: none,
  university: sdu-university,
  logo: none,
  abstract: none,
  keywords: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      v(1.5cm),
      text(size: 13pt, fill: rgb("#555555"))[#university],
      v(0.6em),
      line(length: 60%, stroke: 0.5pt + rgb("#aaaaaa")),
      v(3cm),
      text(size: 28pt, weight: "bold")[#title],
      if subtitle != none {
        stack(v(1.5em), text(size: 15pt, fill: rgb("#444444"), style: "italic")[#subtitle])
      },
      v(1em),
      line(length: 40%, stroke: 0.5pt + rgb("#aaaaaa")),
      v(1.3em),
      text(size: 14pt, fill: rgb("#333333"))[#course],
      v(1fr),
      {
        let author-arr = if type(author) == str {
          ((name: author),)
        } else if type(author) == array and author.len() > 0 and type(author.at(0)) == str {
          author.map(n => (name: n))
        } else if type(author) == array {
          author
        } else { ((name: str(author)),) }

        let render-author(a) = align(center, stack(
          spacing: 0.25em,
          text(weight: "bold", size: 11pt)[#a.at("name", default: "")],
          if a.at("email", default: "") != "" {
            text(size: 8.5pt, fill: rgb("#4a90d9"))[#a.at("email", default: "")]
          },
        ))

        let per-row = 3
        let row-starts = range(0, author-arr.len(), step: per-row)
        stack(spacing: 1.5em,
          ..row-starts.map(i => {
            let row = author-arr.slice(i, calc.min(i + per-row, author-arr.len()))
            align(center,
              box(width: (100% * row.len() / per-row),
                grid(columns: (1fr,) * row.len(), column-gutter: 2em,
                  ..row.map(render-author))
              )
            )
          })
        )
      },
      v(1.5em),
      std.block(
        width: 60%,
        stroke: (top: 0.5pt + rgb("#aaaaaa"), bottom: 0.5pt + rgb("#aaaaaa")),
        inset: (top: 1em, bottom: 1em),
        align(left, stack(
          spacing: 0.5em,
          if group != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Group:*], text()[#group])
          },
          if supervisor != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]:*],
              text()[#_fmt-authors(supervisor)])
          },
          grid(columns: (4cm, 1fr),
            text(fill: rgb("#777777"))[*Date:*], text()[#date]),
        ))
      ),
      if abstract != none {
        stack(
          spacing: 0pt,
          v(1.5em),
          std.block(
            width: 80%, stroke: none, inset: (top: 0em, bottom: 0em),
            align(left, stack(
              spacing: 0.5em,
              text(weight: "bold", size: 10pt, fill: rgb("#333333"))[Abstract],
              line(length: 100%, stroke: 0.4pt + rgb("#cccccc")),
              v(0.3em),
              text(size: 9.5pt, fill: rgb("#444444"))[#abstract],
            ))
          ),
        )
      },
      if keywords != none {
        stack(
          spacing: 0pt,
          v(0.8em),
          std.block(
            width: 80%, inset: 0pt,
            align(left, text(size: 9.5pt)[
              #text(weight: "bold", fill: rgb("#333333"))[Keywords: ]
              #text(fill: rgb("#555555"))[
                #if type(keywords) == array { keywords.join(", ") } else { keywords }
              ]
            ])
          ),
        )
      },
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

// ── submission ───────────────────────────────────────
// Like #project, but no frontpage/outline — just the title card,
// then straight into the body content.
#let submission(
  title: default-title,
  subtitle: none,
  author: none,
  supervisor: none,
  institution: sdu-university,
  date: default-date,
  logo: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  // Apply base styling up front so the `set page` inside base-style
  // doesn't force a page break between the title card and the body.
  show: base-style
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center,
    stack(
      spacing: 0pt,
      text(size: 28pt, weight: "bold")[#title],
      if subtitle != none {
        stack(v(1.5em), text(size: 15pt, fill: rgb("#444444"), style: "italic")[#subtitle])
      },
      v(2em),
      std.block(
        width: 70%,
        stroke: (top: 0.5pt + rgb("#aaaaaa"), bottom: 0.5pt + rgb("#aaaaaa")),
        inset: (top: 1em, bottom: 1em),
        align(left, stack(
          spacing: 1.5em,
          if author != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Author#if type(author) == array and author.len() > 1 [s]:*],
              text()[#_fmt-authors(author)])
          },
          if supervisor != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]:*],
              text()[#_fmt-authors(supervisor)])
          },
          grid(columns: (4cm, 1fr),
            text(fill: rgb("#777777"))[*Date:*], text()[#date]),
          grid(columns: (4cm, 1fr),
            text(fill: rgb("#777777"))[*Institution:*], text()[#institution]),
        ))
      ),
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  body
}

// ── exam ─────────────────────────────────────────────
#let exam(
  title: default-title,
  subtitle: none,
  author: default-author,
  course: default-course,
  date: default-date,
  student-id: none,
  username: none,
  student-number: none,
  duration: none,
  allowed-aids: none,
  supervisor: none,
  university: sdu-university,
  logo: none,
  outline: true,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  let author-name = if type(author) == str { author }
    else if type(author) == array and author.len() > 0 {
      if type(author.at(0)) == str { author.at(0) }
      else { author.at(0).at("name", default: "") }
    } else { "" }
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm),
    header: if username != none or student-number != none {
      set text(size: 9pt, fill: rgb("#555555"))
      grid(
        columns: (1fr, 1fr, 1fr),
        align(left)[#author-name],
        align(center)[#if username != none { username }],
        align(right)[#if student-number != none { student-number }],
      )
    },
  )
  align(center,
    stack(
      spacing: 0pt,
      v(1.5cm),
      text(size: 13pt, fill: rgb("#555555"))[#university],
      v(0.6em),
      line(length: 60%, stroke: 0.5pt + rgb("#aaaaaa")),
      v(0.5cm),
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[EXAM],
      v(4.5cm),
      text(size: 28pt, weight: "bold")[#title],
      if subtitle != none {
        stack(v(1.5em), text(size: 15pt, fill: rgb("#444444"), style: "italic")[#subtitle])
      },
      v(1em),
      line(length: 40%, stroke: 0.5pt + rgb("#aaaaaa")),
      v(1.3em),
      text(size: 14pt, fill: rgb("#333333"))[#course],
      v(1fr),
      {
        let author-arr = if type(author) == str {
          ((name: author),)
        } else if type(author) == array and author.len() > 0 and type(author.at(0)) == str {
          author.map(n => (name: n))
        } else if type(author) == array {
          author
        } else { ((name: str(author)),) }

        let render-author(a) = align(center, stack(
          spacing: 0.25em,
          text(weight: "bold", size: 11pt)[#a.at("name", default: "")],
          if a.at("id", default: "") != "" {
            text(size: 9pt, fill: rgb("#555555"))[#a.at("id", default: "")]
          },
        ))

        let per-row = 3
        let row-starts = range(0, author-arr.len(), step: per-row)
        stack(spacing: 1.5em,
          ..row-starts.map(i => {
            let row = author-arr.slice(i, calc.min(i + per-row, author-arr.len()))
            align(center,
              box(width: (100% * row.len() / per-row),
                grid(columns: (1fr,) * row.len(), column-gutter: 2em,
                  ..row.map(render-author))
              )
            )
          })
        )
      },
      v(1.5em),
      std.block(
        width: 60%,
        stroke: (top: 0.5pt + rgb("#aaaaaa"), bottom: 0.5pt + rgb("#aaaaaa")),
        inset: (top: 1em, bottom: 1em),
        align(left, stack(
          spacing: 0.5em,
          if duration != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Duration:*], text()[#duration])
          },
          if allowed-aids != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Allowed aids:*], text()[#allowed-aids])
          },
          if supervisor != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Supervisor#if type(supervisor) == array and supervisor.len() > 1 [s]:*],
              text()[#_fmt-authors(supervisor)])
          },
          grid(columns: (4cm, 1fr),
            text(fill: rgb("#777777"))[*Date:*], text()[#date]),
        ))
      ),
      if logo != none { stack(v(1.8em), logo) },
      v(1cm),
    )
  )
  pagebreak()
  if outline { std.outline(depth: outline-depth); pagebreak() }
  base-style(body)
}

/*
===================================================
TEMPLATES — copy the block you need into a new file
===================================================

── THESIS ──
#import "@preview/sdust:0.1.0": *
#show: thesis.with(
  title:         "Thesis Title",
  subtitle:      "Optional subtitle",          // optional
  author:        "Firstname Lastname",
  supervisor:    "Prof. Firstname Lastname",   // optional, string or array
  department:    imada,                        // optional — imada/bmb/biology/fkf or any string
  programme:     "MSc in Computer Science",    // optional
  date:          "date",
  outline:       true,
  outline-depth: 2,
)

= Introduction
//Content goes here.

── NOTE ──
#import "@preview/sdust:0.1.0": *
#show: note.with(
  title:         "Lecture Notes",
  course:        "DM000 — Course Name",
  author:        "Firstname Lastname",
  date:          "date",
  logo:          none,          // or image("sdu-logo.png", width: 12em)
  outline:       true,          // set false to skip TOC
  outline-depth: 2,             // none = unlimited depth
)

= First Section
Content goes here.

── EXERCISE ──
#import "@preview/sdust:0.1.0": *
#show: exercise.with(
  title:         "Exercises 1",
  course:        "DM000 — Course Name",
  author:        "Firstname Lastname",
  date:          "date",
  outline:       true,
  outline-depth: 2,
)

= Exercise 1
Content goes here.

── ASSIGNMENT ──
#import "@preview/sdust:0.1.0": *
#show: assignment.with(
  title:         "Assignment 1",
  course:        "DM000 — Course Name",
  author:        "Firstname Lastname",
  date:          "date",
  outline:       true,
  outline-depth: 2,
)

= Problem 1
Content goes here.

── EXAM ──
#import "@preview/sdust:0.1.0": *
#show: exam.with(
  title:         "Written Exam",
  subtitle:      "Re-exam",                    // optional
  course:        "DM000 — Course Name",
  author:        "Firstname Lastname",
  date:          "date",
  student-id:    "id",                         // optional
  username:      "username",                   // optional — shown in page header
  student-number: "215751682",                 // optional — shown in page header
  duration:      "4 hours",                    // optional
  allowed-aids:  "All written materials",      // optional
  outline:       false,
)

= Problem 1
Content goes here.

── PROJECT ──
#import "@preview/sdust:0.1.0": *
#show: project.with(
  title:         "Project Title",
  subtitle:      "Optional subtitle",          // optional
  course:        "DM000 — Course Name",
  author:        "Firstname Lastname",         // or array of dicts below
  date:          "date",
  group:         "Group 4",                    // optional
  supervisor:    "Prof. Firstname Lastname",   // optional
  outline:       true,
  outline-depth: 2,
)

= Introduction
Content goes here.

── SUBMISSION ──
#import "@preview/sdust:0.1.0": *
#show: submission.with(
  title:         "Submission Title",
  subtitle:      "Optional subtitle",          // optional
  author:        "Firstname Lastname",         // or array of dicts, see #project
  supervisor:    "Prof. Firstname Lastname",   // optional, string or array
  date:          "date",
)

= Introduction
Content goes here.

── ACM / CHI PAPER ──
For an ACM paper (e.g. CHI: `format: "manuscript"` for review,
`format: "sigconf"` for camera-ready) use faithful-acmart instead:
https://typst.app/universe/package/faithful-acmart

*/
