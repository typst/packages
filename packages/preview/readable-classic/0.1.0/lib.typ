// Classic, ported from the Google Docs version on readableresume.com.
// The design values come from that file: Georgia, 10.5 pt body at 1.1 line
// spacing, 20 pt name, 11 pt centered headings over a 0.75 pt rule,
// 0.6 in margins on US Letter and 15 mm on A4.

// Docs sets lines 1.1 × Georgia's line height apart. Typst measures a line
// from cap height to baseline, so the leading is what's left over.
#let _leading = 0.55em

// Gaps between blocks. Docs adds "space before" on top of the line height;
// these were tuned against a Docs export of the original at the same scale.
#let _entry-gap = 14.3pt
#let _section-gap = 11.6pt
#let _heading-gap = 5.5pt

#let _filled(value) = value != none and value != "" and value != []

// A contact item becomes a link when it looks like one. Full URLs and
// mailto: are kept as typed; a bare email gets mailto:; a bare domain, with or
// without a path, gets https://. Content passes through untouched.
#let _bare-web-address = regex("^[\\w-]+(\\.[\\w-]+)*\\.[a-z]{2,}(/\\S*)?$")
#let _contact-item(item) = {
  if type(item) != str or item.contains(" ") { return item }
  if item.starts-with("http://") or item.starts-with("https://") {
    link(item, item)
  } else if item.starts-with("mailto:") {
    link(item, item.slice(7))
  } else if item.contains("@") and not item.contains("/") {
    link("mailto:" + item, item)
  } else if item.match(_bare-web-address) != none {
    link("https://" + item, item)
  } else {
    item
  }
}

// Left part, then the right part pushed to the margin. Plain text in reading
// order, no table or columns, so a parser reads "Company Location".
// The right part is boxed so a date range never splits; when the left side is
// too long it drops to the next line, right-aligned, like a tab stop in Docs.
#let _row(left, right) = {
  if _filled(left) { left }
  if _filled(right) [ #h(1fr)#sym.wj#box(right)]
}

// The bullets come in as optional trailing content, so an entry without
// bullets can be written as a plain call. Header and bullets are siblings, not
// nested in one block: Typst 0.12 ignores sticky on a nested block.
#let _entry(rows, bullets) = {
  // The sink would otherwise swallow a misspelled field name without a word
  let unknown = bullets.named().keys()
  assert(unknown.len() == 0, message: "unknown argument: " + unknown.join(", "))
  let body = bullets.pos().join()
  // sticky keeps the header lines on the same page as the first bullet
  block(
    sticky: body != none,
    breakable: false,
    above: _leading,
    below: if body == none { _entry-gap } else { _leading },
    rows.filter(_filled).join(linebreak()),
  )
  if body != none { block(above: _leading, below: _entry-gap, body) }
}

#let _styled(style, value) = if _filled(value) { style(value) }

/// School on the first line, degree and dates in italics on the second.
#let education(school: none, location: none, degree: none, date: none, ..bullets) = _entry(
  (
    _row(_styled(strong, school), location),
    _row(_styled(emph, degree), _styled(emph, date)),
  ),
  bullets,
)

/// Company first, then the job title in italics with the dates.
#let experience(company: none, location: none, title: none, date: none, ..bullets) = _entry(
  (
    _row(_styled(strong, company), location),
    _row(_styled(emph, title), date),
  ),
  bullets,
)

/// Clubs, volunteering and projects: "Name | Role" with the dates on the right.
#let activity(name: none, role: none, date: none, ..bullets) = _entry(
  (
    _row(
      {
        _styled(strong, name)
        if _filled(name) and _filled(role) [ | ]
        _styled(emph, role)
      },
      date,
    ),
  ),
  bullets,
)

/// One bold label per line: `skills((Technical: "Excel, SQL", Languages: "French"))`.
#let skills(lines) = {
  lines.pairs().map(((label, value)) => [*#label:* #value]).join(linebreak())
}

/// Apply with `#show: resume.with(...)`.
#let resume(
  name: "",
  contact: (),
  paper: "us-letter",
  margin: auto,
  font: ("Georgia", "Libertinus Serif"),
  font-size: 10.5pt,
  body,
) = {
  let margin = if margin == auto {
    if paper == "us-letter" { 0.6in } else { 15mm }
  } else { margin }
  let contact = if type(contact) == array { contact } else { (contact,) }
  let name-size = font-size * 20 / 10.5

  set document(title: [#name – Resume], author: if type(name) == str { name } else { () })
  set page(paper: paper, margin: margin)
  set text(font: font, size: font-size, lang: "en", hyphenate: false)
  set par(leading: _leading, spacing: _leading, justify: false)

  // Same hang as the Docs file: dot at 0.1 in, text at 0.25 in.
  set list(
    marker: box(width: 0.15in, align(start)[•]),
    indent: 0.1in,
    body-indent: 0pt,
    spacing: _leading,
  )

  // Docs draws the heading rule as a paragraph border, about 3 pt under the
  // baseline. Headings are typed in any case and set in capitals.
  show heading: it => block(
    above: _section-gap,
    below: _heading-gap,
    width: 100%,
    inset: (bottom: 3.6pt),
    stroke: (bottom: 0.75pt),
    breakable: false,
    sticky: true,
    align(center, text(size: font-size * 11 / 10.5, weight: "bold", upper(it.body))),
  )

  // Docs puts the first baseline one ascent below the margin, Typst one cap
  // height below. The top inset makes up the difference.
  block(
    width: 100%,
    below: 8.7pt,
    inset: (top: 0.25 * name-size),
    align(center, text(size: name-size, weight: "bold", name)),
  )
  block(
    width: 100%,
    below: _section-gap + 2pt,
    align(center, contact.map(_contact-item).join(" | ")),
  )

  body
}
