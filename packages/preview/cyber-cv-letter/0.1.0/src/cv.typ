#import "theme.typ": fg, muted, resolve-font, resolve-accent, page-geometry, space-header-line, space-section-to-rule, space-paragraph, space-bullet, body-indent, size-header-name, size-body, size-small, size-footer
#import "marks.typ": draw-cursor, draw-rule
#import "fonts.typ": default-font-chrome, default-font-body
#import "icons.typ": icon-path, icon-for-link, icon-kind-for-link
#import "content.typ": flatten-text
#import "ats.typ": set-metadata
#import "entries.typ": section-header-rule, entry-heading-rule, meta-line-rule, note-rule, paragraph-rule, list-rule, skills-item-rule

// `none`-safe flatten-text: identity fields are optional, and Pandoc omits
// an absent field's key entirely rather than passing an empty value.
#let text-of(v) = if v == none { none } else { flatten-text(v) }

// Gap before the cursor mark, em-relative so it scales with local text size
// at each call site (the size-header-name name line, the size-footer footer
// prompt) — sized generously enough that the footer's smaller absolute gap
// doesn't read as cramped.
#let cursor-gap = 0.3em

#let header-block(author, color, font-chrome, font-body, show-icons) = {
  let name-line = {
    set text(..resolve-font(font-chrome, weight: "bold"), size: size-header-name, fill: fg)
    author.name
    h(cursor-gap)
    draw-cursor(color)
  }

  let tagline-line = if author.at("tagline", default: none) != none {
    block(above: 0pt, below: 0pt, {
      set text(..resolve-font(font-body, weight: "regular"), size: size-body, fill: muted)
      author.tagline
    })
  } else { none }

  let contact-parts = ()
  if author.at("email", default: none) != none { contact-parts.push(("email", author.email)) }
  if author.at("location", default: none) != none { contact-parts.push(("location", author.location)) }
  if author.at("phone", default: none) != none { contact-parts.push(("phone", author.phone)) }

  let contact-line = if contact-parts.len() > 0 {
    block(above: 0pt, below: 0pt, {
      set text(..resolve-font(font-chrome, weight: "regular"), size: size-small, fill: fg)
      for (i, part) in contact-parts.enumerate() {
        if i > 0 { [ · ] }
        if show-icons { box(image(icon-path(part.at(0)), height: 9pt, alt: part.at(0)), baseline: 1pt); h(2pt) }
        part.at(1)
      }
    })
  } else { none }

  let links = author.at("links", default: ())
  let links-line = if links.len() > 0 {
    block(above: 0pt, below: 0pt, {
      set text(..resolve-font(font-chrome, weight: "regular"), size: size-small, fill: fg)
      for (i, link) in links.enumerate() {
        if i > 0 { [ · ] }
        if show-icons {
          let url = flatten-text(link)
          box(image(icon-for-link(url), height: 9pt, alt: icon-kind-for-link(url)), baseline: 1pt)
          h(2pt)
        }
        link
      }
    })
  } else { none }

  let lines = (name-line, tagline-line, contact-line, links-line).filter(l => l != none)

  block(above: 0pt, below: 0pt, {
    stack(dir: ttb, spacing: space-header-line, ..lines)
    v(space-section-to-rule)
    draw-rule(color, weight: 1.2pt)
  })
}

#let footer-block(author, font-chrome) = context {
  let prompt-id = if author.at("email", default: none) != none {
    flatten-text(author.email)
  } else {
    lower(flatten-text(author.name)).replace(" ", ".") + "@cyber-cv-letter"
  }
  set text(..resolve-font(font-chrome, weight: "regular"), size: size-footer, fill: muted)
  let prompt = prompt-id + ":~$"
  let page-num = str(counter(page).get().first())
  let total = str(counter(page).final().first())
  grid(
    columns: (1fr, 1fr),
    align(left, { prompt; h(cursor-gap); draw-cursor(muted) }),
    align(right, page-num + " / " + total),
  )
}

#let cv(
  author: (:),
  accent: "red",
  accent-scope: "full",
  paper: "a4",
  show-icons: true,
  show-footer: true,
  show-logos: false,
  show-notes: false,
  keywords: none,
  body,
) = {
  let accent-list = resolve-accent(accent)

  let font-chrome = default-font-chrome
  let font-body = default-font-body

  let geo = page-geometry.at(paper)

  set-metadata(
    name: text-of(author.name),
    tagline: text-of(author.at("tagline", default: none)),
    doc-kind: "CV",
    keywords: if keywords != none { keywords.map(text-of) } else { none },
  )

  set page(
    paper: geo.paper,
    margin: geo.margin,
    footer: if show-footer { footer-block(author, font-chrome) } else { none },
  )
  set text(..resolve-font(font-body, weight: "regular"), size: size-body, fill: fg, lang: "en")
  set par(justify: false, leading: 0.6em, spacing: space-paragraph)
  set heading(numbering: none, outlined: true, bookmarked: true)
  set list(indent: 0pt, body-indent: body-indent, spacing: space-bullet, marker: [•])

  // Emitted before the show rules below, so the chrome-styled identity block
  // is not mistaken for body content by them — in particular by `show par`,
  // whose meta-line/code-line test reads the ambient text style (see
  // entries.typ) and would otherwise see the header's own chrome font.
  header-block(author, accent-list.at(0), font-chrome, font-body, show-icons)

  // Replaces Typst's built-in `raw` defaults, and doubles as the ambient
  // paragraph-rule (entries.typ) reads to detect a code line — both must
  // agree on size-small. Don't add a show-set for headings here — it would
  // land in a section heading's own ambient too, and paragraph-rule would
  // misread it as code.
  show raw: set text(..resolve-font(font-chrome, weight: "regular"), size: size-small, fill: muted)

  show heading.where(level: 1): section-header-rule(accent-list, accent-scope, font-chrome)
  show heading.where(level: 2): entry-heading-rule(accent-list, font-body, font-chrome, show-logos)
  show emph: meta-line-rule(accent-list, font-body, show-logos)
  show quote.where(block: true): note-rule(font-body, show-notes)
  show list: list-rule
  show terms.item: skills-item-rule(accent-list, font-chrome, font-body)
  show par: paragraph-rule(font-chrome)

  body
}
