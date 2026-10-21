// letter() — reuses cv.typ's header component. No section vocabulary, no
// entry pairing: the body is plain paragraphs, laid out by the ambient
// par(spacing:) set rule with no manual content-tree walk needed.

#import "theme.typ": fg, resolve-font, resolve-accent, page-geometry, space-header-to-section, space-letter-paragraph, mark-gutter, size-body, size-small
#import "marks.typ": draw-chevron
#import "fonts.typ": default-font-chrome, default-font-body
#import "ats.typ": set-metadata
#import "cv.typ": header-block, footer-block, text-of

#let letter(
  author: (:),
  accent: "red",
  accent-scope: "full",
  paper: "a4",
  show-icons: true,
  show-footer: true,
  date: none,
  paragraph-spacing: space-letter-paragraph,
  keywords: none,
  body,
) = {
  assert(date != none, message: "letter() requires date:")

  let accent-list = resolve-accent(accent)
  let font-chrome = default-font-chrome
  let font-body = default-font-body
  let geo = page-geometry.at(paper)

  set-metadata(
    name: text-of(author.name),
    tagline: text-of(author.at("tagline", default: none)),
    doc-kind: "Cover Letter",
    keywords: if keywords != none { keywords.map(text-of) } else { none },
  )

  set page(
    paper: geo.paper,
    margin: geo.margin,
    footer: if show-footer { footer-block(author, font-chrome) } else { none },
  )
  set text(..resolve-font(font-body, weight: "regular"), size: size-body, fill: fg, lang: "en")
  // 0.7em keeps the letter body airier than the CV's 0.6em leading.
  set par(justify: false, leading: 0.7em, spacing: paragraph-spacing)

  header-block(author, accent-list.at(0), font-chrome, font-body, show-icons)

  block(above: space-header-to-section, below: paragraph-spacing, breakable: false, {
    // `horizon` centres the mark against this block — the date line and
    // nothing else — so no measured or hand-tuned vertical offset is needed
    // here or in entries.typ's section header, which uses the same form.
    place(left + horizon, dx: -mark-gutter, draw-chevron(accent-list.at(0)))
    // Same font/weight/size/color as a CV entry's date (entries.typ's
    // entry-heading-rule) — the letter's date plays the same visual role.
    set text(..resolve-font(font-chrome, weight: "regular"), size: size-small, fill: accent-list.at(0))
    date
  })

  body
}
