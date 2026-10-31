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
  if type(author) == array { author.join(", ", last: " & ") }
  else { author }
}

#let _fmt-lines(names) = {
  if type(names) == array { names.join(linebreak()) }
  else { names }
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
  date: none,
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
        stack(v(0.4em), text(size: 14pt, fill: rgb("#777777"))[#smallcaps[#_fmt-lines(department)]])
      },
      v(6em),
      if date != none { text(size: 12pt, fill: rgb("#888888"))[#date] },
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
  date: none,
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
      if date != none { text(size: 11pt, fill: rgb("#888888"))[#date] },
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
  subtitle: none,
  author: default-author,
  supervisor: none,
  course: default-course,
  date: none,
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
      if date != none { text(size: 11pt, fill: rgb("#888888"))[#date] },
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
  subtitle: none,
  author: default-author,
  supervisor: none,
  course: default-course,
  date: none,
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
      v(1.8em),
      if date != none { text(size: 11pt, fill: rgb("#888888"))[#date] },
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
  date: none,
  group: none,
  supervisor: none,
  university: sdu-university,
  logo: none,
  abstract: none,
  keywords: none,
  outline: true,
  outline-depth: none,
  info-width: 60%,
  author-dots: false,
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
        if author-dots {
          align(center, text(weight: "bold", size: 11pt,
            author-arr.map(a => a.at("name", default: "")).join(" · ")))
        } else { stack(spacing: 1.5em,
          ..row-starts.map(i => {
            let row = author-arr.slice(i, calc.min(i + per-row, author-arr.len()))
            align(center,
              box(width: (100% * row.len() / per-row),
                grid(columns: (1fr,) * row.len(), column-gutter: 2em,
                  ..row.map(render-author))
              )
            )
          })
        ) }
      },
      v(1.5em),
      std.block(
        width: info-width,
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
          if date != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Date:*], text()[#date])
          },
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

// ── basic ────────────────────────────────────────────
// Minimal: title, subtitle, authors and date above the body on the
// first page. No cover page, info box or logo.
#let basic(
  title: default-title,
  subtitle: none,
  author: default-author,
  date: none,
  outline: false,
  outline-depth: none,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  show: base-style
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  align(center, {
    set par(justify: false, leading: 0.6em)
    set text(hyphenate: false)
    text(size: 22pt, weight: "bold")[#title]
    if subtitle != none {
      v(0.6em)
      text(size: 14pt, fill: rgb("#444444"), style: "italic")[#subtitle]
    }
    if author != none {
      v(1.2em)
      text(size: 12pt)[#_fmt-authors(author)]
    }
    if date != none {
      v(0.4em)
      text(size: 10pt, fill: rgb("#888888"))[#date]
    }
    v(0.8em)
    line(length: 100%, stroke: 0.5pt + sdu-red)
    v(1em)
  })
  if outline { std.outline(depth: outline-depth) }
  body
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
  date: none,
  logo: none,
  course: none,
  group: none,
  info-width: 70%,
  ..args,
) = {
  let body = args.pos().at(0, default: [])
  // Apply base styling up front so the `set page` inside base-style
  // doesn't force a page break between the title card and the body.
  show: base-style
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 3cm, bottom: 3cm))
  let muted = rgb("#666666")
  let rule = rgb("#bbbbbb")
  let as-array(x) = if type(x) == array { x } else { (x,) }
  let label(t) = text(size: 8pt, fill: muted, tracking: 1.2pt, weight: "bold", upper(t))
  let field(name, value) = stack(spacing: 0.6em, label(name), value)
  align(center, {
    set par(justify: false, leading: 0.6em)
    set text(hyphenate: false)
    text(size: 22pt, weight: "bold")[#title]
    if subtitle != none {
      v(0.6em)
      text(size: 14pt, fill: rgb("#444444"), style: "italic")[#subtitle]
    }
    if course != none {
      v(0.8em)
      text(size: 12pt, fill: muted)[#course]
    }
    if author != none {
      v(2em)
      let names = as-array(author)
      grid(columns: names.len(), column-gutter: 2.5em,
        ..names.map(n => text(size: 12pt, weight: "bold")[#n]))
    }
    if group != none {
      v(0.6em)
      text(size: 10pt, fill: muted, style: "italic")[Group: #group]
    }
    v(1em)
    let fields = (
      if supervisor != none {
        let sup = as-array(supervisor)
        field(if sup.len() > 1 [Supervisors #v(0.5em)] else [Supervisor #v(0.5em)], sup.join(linebreak()))
      },
      if date != none { field[Date #v(0.5em)][#date] },
      if institution != none { field[Institution #v(0.5em)][#institution] },
    ).filter(f => f != none)
    std.block(
      width: info-width,
      stroke: (top: 0.5pt + rule, bottom: 0.5pt + rule),
      inset: (y: 1.1em),
      align(center, grid(columns: (auto,) * fields.len(), column-gutter: 3em, align: center + top,
        ..fields.map(f => text(size: 10pt, f))))
    )
    if logo != none { v(1.8em); logo }
    v(1cm)
  })
  body
}

// ── exam ─────────────────────────────────────────────
#let exam(
  title: default-title,
  subtitle: none,
  author: default-author,
  course: default-course,
  date: none,
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
          if date != none {
            grid(columns: (4cm, 1fr),
              text(fill: rgb("#777777"))[*Date:*], text()[#date])
          },
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
