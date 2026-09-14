// ══════════════════════════════════════════════════════
// DOCUMENT TEMPLATES / FRONTPAGES
// ══════════════════════════════════════════════════════
//
// Each template takes inputs like `title`, `author` and `supervisor` and
// builds a cover page, an optional outline, then the base styling.
// Cover pages render no logo by default — pass one with
// `logo: image("sdu-logo.png", width: 12em)`.

#import "branding.typ": *
#import "base.typ": base-style

#let _fmt-authors(author) = {
  if type(author) == array { author.join(" · ") }
  else { author }
}

// ── thesis ───────────────────────────────────────────
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
        stack(v(2em), text(size: 15pt, fill: rgb("#444444"), style: "italic")[#smallcaps[#subtitle]])
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
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[LECTURE NOTE],
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
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[EXERCISE],
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
      text(size: 9.5pt, fill: sdu-red, tracking: 2.5pt, weight: "bold")[ASSIGNMENT],
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
// then straight into the body content on the same page.
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
