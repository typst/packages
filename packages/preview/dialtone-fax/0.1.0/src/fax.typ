// dialtone-fax: a page laid out to survive a fax machine.
// Black on white, no shading, a 10 pt floor under text, margins for Letter and A4,
// a cover block and a one-line footer. Nothing here reaches the network.

/// The smallest text size the layout allows, anywhere on the page.
#let size-floor = 10pt

/// Margins per paper. Fax pages are scanned 1728 dots across 215 mm, so text is kept well inside the edge.
#let margins = (
  "us-letter": (x: 0.75in, top: 0.75in, bottom: 0.9in),
  "a4": (x: 20mm, top: 20mm, bottom: 23mm),
)

#let _field(label, value) = (
  text(weight: "bold", upper(label)),
  if value == none { [] } else if type(value) == content { value } else { [#value] },
)

/// The cover block: to, from, date, pages and subject, framed by solid black rules.
#let cover-block(
  to: none,
  to-fax: none,
  from: none,
  from-fax: none,
  subject: none,
  pages: auto,
  date: auto,
  title: "Fax",
) = {
  let shown-pages = if pages == auto {
    context counter(page).final().first()
  } else { pages }
  assert(
    type(date) != datetime or date.year() != none,
    message: "dialtone-fax: date must be a datetime with a date part, a string, content or auto",
  )
  let shown-date = if date == auto {
    datetime.today().display("[year]-[month]-[day]")
  } else if type(date) == datetime {
    date.display("[year]-[month]-[day]")
  } else { date }
  block(width: 100%, breakable: false, {
    text(size: 28pt, weight: "bold", upper(title))
    v(4pt)
    line(length: 100%, stroke: 2pt + black)
    v(2pt)
    grid(
      columns: (auto, 1fr, auto, 1fr),
      column-gutter: 10pt,
      row-gutter: 9pt,
      .._field("To", to), .._field("Fax", to-fax),
      .._field("From", from), .._field("Fax", from-fax),
      .._field("Date", shown-date), .._field("Pages", shown-pages),
    )
    v(2pt)
    if subject != none {
      grid(columns: (auto, 1fr), column-gutter: 10pt, .._field("Subject", subject))
      v(2pt)
    }
    line(length: 100%, stroke: 2pt + black)
  })
}

/// Lay out a whole document for fax.
///
/// - paper: "us-letter" or "a4".
/// - body-size: the body text size. Must be at least `size-floor`.
/// - font: a font name or a list, tried in order. Liberation Sans ships with most Linux systems;
///   Typst falls back to its own fonts when none of them is installed.
/// - cover: true puts the cover block at the top of page 1; "page" gives it a page of its own; false leaves it out.
/// - footer-link: false drops the faxforagents.com link from the footer and keeps the page count.
#let fax(
  to: none,
  to-fax: none,
  from: none,
  from-fax: none,
  subject: none,
  pages: auto,
  date: auto,
  title: "Fax",
  paper: "us-letter",
  body-size: 12pt,
  font: ("Liberation Sans", "DejaVu Sans", "Noto Sans"),
  cover: true,
  footer-link: true,
  body,
) = {
  assert(cover in (true, false, "page"), message: "dialtone-fax: cover must be true, false or \"page\", got " + repr(cover))
  assert(paper in margins, message: "dialtone-fax: paper must be \"us-letter\" or \"a4\", got " + repr(paper))
  assert(
    type(body-size) == length and body-size.em == 0,
    message: "dialtone-fax: body-size must be an absolute length such as 12pt",
  )
  assert(
    body-size.abs >= size-floor,
    message: "dialtone-fax: body-size " + repr(body-size) + " is below the floor of " + repr(size-floor),
  )

  set document(title: if subject == none { title } else { subject })
  set page(
    paper: paper,
    margin: margins.at(paper),
    fill: white,
    footer: context {
      set text(size: size-floor)
      line(length: 100%, stroke: 0.75pt + black)
      v(-4pt)
      grid(
        columns: (1fr, auto),
        [Page #counter(page).display() of #counter(page).final().first()],
        if footer-link [Laid out for fax with #link("https://faxforagents.com")[faxforagents.com]],
      )
    },
  )
  set text(font: font, size: body-size, fill: black, lang: "en", hyphenate: false)
  set par(justify: false, leading: 0.7em, spacing: 1.1em)

  // No grey, no colour, no shading: a fax page is 1-bit, so a tint either vanishes or turns to dots.
  // These are defaults. A fill passed directly to an element still applies, so leave fills out.
  set table(fill: none, stroke: 0.75pt + black)
  set rect(fill: none, stroke: 0.75pt + black)
  set block(fill: none)
  set box(fill: none)
  set highlight(fill: none)
  set line(stroke: 0.75pt + black)
  show link: underline
  show heading: set text(fill: black, weight: "bold")
  show heading.where(level: 1): set text(size: 1.4 * body-size.abs)
  show heading.where(level: 2): set text(size: 1.2 * body-size.abs)

  // The floor and black ink hold for every piece of text, including footnotes, sub- and superscripts,
  // and any later set rule.
  show text: it => context {
    set text(fill: black)
    if text.size < size-floor { set text(size: size-floor); it } else { it }
  }
  // Sub- and superscripts keep the full text size and are only raised or lowered: Typst scales them after
  // show rules run, so a smaller size, even one passed directly, would slip under the floor.
  show super: it => if it.size == 1em and it.typographic == false { it } else { super(size: 1em, typographic: false, it.body) }
  show sub: it => if it.size == 1em and it.typographic == false { it } else { sub(size: 1em, typographic: false, it.body) }
  show footnote.entry: set text(size: size-floor)
  set footnote.entry(separator: line(length: 30%, stroke: 0.75pt + black))

  if cover == true or cover == "page" {
    cover-block(to: to, to-fax: to-fax, from: from, from-fax: from-fax, subject: subject, pages: pages, date: date, title: title)
    if cover == "page" { pagebreak() } else { v(14pt) }
  }
  body
}
