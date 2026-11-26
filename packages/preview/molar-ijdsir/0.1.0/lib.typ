// IJDSIR — International Journal of Dental Science and Innovative Research
// Unofficial template reproducing the journal's two fill-in documents:
//   #show: manuscript.with(...)   — manuscript template
//   #covering-letter(...)          — covering letter (+ Annexure-I reviewers)
// Geometry is measured from the journal's manuscript template PDF (all values in pt):
// US Letter, 0.5" margins left/right, columns 259.2 wide / 21.6 gap, Times New Roman 11 pt,
// Word "1.5 lines" spacing = 18.96 pt baseline pitch.

#let journal = "International Journal of Dental Science and Innovative Research (IJDSIR)"
#let red = rgb("#ff0000")
#let green = rgb("#00b050")
#let blue = rgb("#0070c0")
#let purple = rgb("#7030a0")
#let link-blue = rgb("#3333cc")

#let pitch = 18.975pt                // baseline-to-baseline
#let gap = pitch - 1.107 * 11pt      // leading for 11 pt lines (TNR ascender+descender = 1.107em)
#let tnr = ("Times New Roman", "Times")

// Text whose baseline sits exactly at (x, y) on the page.
#let at(x, y, body) = place(top + left, dx: x, dy: y, text(top-edge: "baseline", bottom-edge: "baseline", body))
#let bi(size, fill, body) = text(font: tnr, size: size, weight: "bold", style: "italic", fill: fill, body)
#let dots(x0, x1, y) = place(top + left, dx: x0, dy: y,
  line(length: x1 - x0, stroke: (paint: black, thickness: 3pt, dash: (3pt, 3pt))))

#let manuscript(
  title: [],
  authors: (),          // ((name: "...", aff: 1), ...) — superscript is the author's position
  affiliations: (),     // ("Dept..., College..., City, Country", ...); prefixed by its authors' numbers
  email: none,          // E-Mail Id line under the affiliations
  corresponding: (name: none, address: none, phone: none, email: none),
  conflicts: "Nil",
  abstract: [],
  keywords: (),
  running-author: auto, // page 2+ header; default "<first author>"
  volume: "1", issue: "1", period: "January – February - 2018",
  pages: "01 -03", year: "2017",
  paper: "us-letter",   // the journal's PDF is Letter; "a4" also works
  logo: none,           // journal logo as content, e.g. image("logo.png")
  body,
) = {
  let first = if running-author == auto { authors.at(0, default: (name: "Author")).name } else { running-author }

  set document(title: title, author: authors.map(a => a.name))
  set text(font: tnr, size: 11pt, lang: "en", top-edge: 0.891em, bottom-edge: -0.216em, hyphenate: false,
    kerning: false, ligatures: false) // Word defaults
  // Word-like line breaking: greedy, spaces never shrink
  set par(justify: true, leading: gap, spacing: gap, linebreaks: "simple",
    justification-limits: (spacing: (min: 100%, max: 1000%), tracking: (min: 0pt, max: 0pt)))
  set super(size: 7pt)

  set page(
    paper: paper,
    margin: (left: 36pt, right: 36pt, top: 56.7pt - 9.8pt, bottom: 64pt), // page 2+ body ends at baseline 720.8 (Typst margins cannot vary per page)
    background: context {
      let n = counter(page).get().first()
      if n == 1 {
        // masthead
        for x in (15.4pt, 590.7pt) {
          place(top + left, dx: x, dy: 1.1pt, rect(width: 7.1pt, height: 95.9pt,
            fill: rgb(75, 172, 198), stroke: 0.75pt + rgb(79, 129, 189)))
        }
        place(top + left, dx: 0pt, dy: 97pt, line(length: 607.1pt, stroke: 0.75pt + rgb(49, 132, 155)))
        if logo != none { place(top + left, dx: 36.2pt, dy: 7.2pt, { set image(width: 49.2pt); logo }) }
        at(137.4pt, 56.3pt, text(font: tnr, 12pt, weight: "bold", fill: red)[_International Journal of Dental Science and Innovative Research_ (_IJDSIR_)])
        at(36pt, 68.2pt, bi(10pt, green)[IJDSIR : Dental Publication Hub])
        at(36pt, 81.4pt, bi(10pt, blue)[Available Online at: www.ijdsir.com])
        at(36pt, 94.6pt, bi(10pt, purple)[Volume – #volume, Issue – #issue, #h(2.5pt) #period, Page No. : #h(2.5pt) #pages])
        // footer
        dots(22.5pt, 597.8pt, 755.3pt)
        at(36pt, 771.6pt, bi(10pt, purple)[Corresponding Author: #h(2.5pt) #corresponding.name, ijdsir Volume-#volume Issue-#issue, #h(2.5pt) Page No. #pages])
        at(591.7pt, 749pt, rotate(-90deg, origin: top + left,
          text(font: tnr, 12pt, weight: "bold")[Page #n]))
      } else {
        at(36pt, 30.9pt, bi(10pt, purple)[#first, et al. International Journal of Dental Sciences and Innovative Research (IJDSIR)])
        dots(21.6pt, 596.8pt, 35.5pt)
        dots(8pt, 583.2pt, 734.5pt)
        at(36pt, 749.8pt, text(font: tnr, 9pt, style: "italic", fill: purple)[© *#year IJDSIR, All Rights Reserved*])
        at(597.4pt, 752.4pt, rotate(-90deg, origin: top + left,
          text(font: tnr, 11pt, weight: "bold")[Page#text(22pt, str(n))]))
      }
    },
  )

  // Headings: "1.⇥Introduction", "A.⇥Sub Heading" (tab stop at 0.25"), bold 11 pt, on the line grid
  set heading(numbering: (..n) => {
    let n = n.pos()
    if n.len() == 1 { numbering("1.", ..n) } else { numbering("A.", n.last()) }
  })
  show heading: set text(11pt, weight: "bold")
  show heading: set block(above: gap, below: gap)
  show heading: it => block(if it.numbering == none { it.body } else {
    let num = counter(heading).display(it.numbering)
    num + h(18pt - measure(num).width) + it.body // tab stop at 0.25"
  })

  // Figures: caption below "Fig. 1:"; tables: title above "Table 1:"; horizontal rules only
  set figure.caption(separator: [: ])
  show figure.where(kind: image): set figure(supplement: [Fig.])
  show figure.where(kind: table): set figure.caption(position: top)
  set table(stroke: (x, y) => (top: if y <= 1 { 0.6pt }, bottom: 0.6pt))

  // References (when using #bibliography): NLM/Vancouver list, [1] in text
  set bibliography(title: none, style: "vancouver")
  show cite: it => { show "(": "["; show ")": "]"; it }

  // ---- Title block (page 1, single column) ----
  v(109.5pt - 56.7pt, weak: false)
  align(center, {
    set par(justify: false)
    text(weight: "bold", title)
    parbreak()
    authors.enumerate().map(((k, a)) => [#super[#(k + 1)]#a.name]).join(", ")
    for (n, aff) in affiliations.enumerate() {
      let who = authors.enumerate().filter(((k, a)) => a.aff == n + 1).map(((k, a)) => str(k + 1))
      parbreak()
      [#super[#who.join(", ")] #aff]
    }
    if email != none { parbreak(); [E-Mail Id- #link("mailto:" + email, text(fill: link-blue, email))] }
  })
  {
    let addr = corresponding.address
    par(leading: gap + 0.65pt)[#text(12pt)[*Correspondence Author:* #corresponding.name, ]#addr]
    if corresponding.phone != none { parbreak(); [*Contact No*: #corresponding.phone] }
    if corresponding.email != none { parbreak(); [*E-Mail Id:* #link("mailto:" + corresponding.email, text(fill: link-blue, corresponding.email))] }
    parbreak(); [*Conflicts of Interest:* #conflicts]
  }
  block(above: 0pt, below: 0pt, height: 8.2pt,
    place(top + left, dx: -1.5pt, dy: 7.4pt, rect(width: 543pt, height: 0.4pt, fill: black, stroke: none)))

  // ---- Two-column body ----
  columns(2, gutter: 21.6pt, {
    [*Abstract:*]
    parbreak()
    abstract
    if keywords.len() > 0 { parbreak(); [*Keywords:* #keywords.join(", ")] }
    body
  })
}

// ---------------------------------------------------------------- Covering letter
// Measured from covering-letter.pdf (US Letter). The journal's header uses the AR JULIAN and
// Lucida Calligraphy fonts plus two images; pass them via title-font / contact-font / logo / banner
// (see typst/covering-letter.typ). Without them the header falls back to Times New Roman.
#let navy = rgb("#002060")

// Next line's baseline sits `dy` below the previous line's baseline.
#let ln(dy, prev, size, body, align: left) = block(
  above: dy - 0.216 * prev - 0.891 * size, below: 0pt, width: 100%,
  std.align(align, text(size, body)))
#let or-dots(v, dots) = if v == none { dots } else { v }

#let covering-letter(
  article-type: none,   // "Research Paper", "Review Paper", "Case Report", ...
  submit-to: "Current issue/Special Issue",
  manuscript-title: none,
  research-area: none,
  support: "self / yes (Grant / financial support details)",
  conflicts: none,
  journal-name: none,   // the "Name of Journal...." line
  author: (name: none, institution: none, country: none, contact: none, mobile: none, email: none),
  place: none, date: none,
  reviewers: (),        // up to 3: ((name:, designation:, institution:, area:, contact:, email:), ...)
  logo: none,           // header logo as content, e.g. image("logo.png")
  banner: none,         // "An International Journal House" image under the logo
  title-font: none,     // journal-name font in the header, e.g. "AR JULIAN"
  contact-font: none,   // font of the word "Contact", e.g. "Lucida Calligraphy"
) = {
  let a = (name: none, institution: none, country: none, contact: none, mobile: none, email: none) + author
  set document(title: "Covering Letter")
  set text(font: tnr, size: 12pt, top-edge: 0.891em, bottom-edge: -0.216em, hyphenate: false,
    kerning: false, ligatures: false)
  set par(leading: 13.8pt - 1.107 * 12pt, spacing: 0pt, linebreaks: "simple",
    justification-limits: (spacing: (min: 100%, max: 1000%), tracking: (min: 0pt, max: 0pt)))
  set page(
    paper: "us-letter",
    margin: (left: 47pt, right: 45.9pt, top: 164.5pt - 0.891 * 14pt, bottom: 40pt),
    background: context {
      let n = counter(page).get().first()
      let fill-rect(x, y, w, h, c) = std.place(top + left, dx: x, dy: y, rect(width: w, height: h, fill: c, stroke: none))
      // Word "thick-thin" page border: 3pt black, 0.7pt white gap, 0.7pt black
      std.place(top + left, dx: 25.5pt, dy: 25.5pt, rect(width: 561pt, height: 741pt, stroke: 3pt))
      std.place(top + left, dx: 28.05pt, dy: 28.05pt, rect(width: 555.9pt, height: 735.9pt, stroke: 0.7pt))
      if logo != none { std.place(top + left, dx: 30.5pt, dy: 28.7pt, { set image(width: 66.1pt); logo }) }
      if banner != none { std.place(top + left, dx: 26.1pt, dy: 94.9pt, { set image(width: 143.3pt, height: 12.8pt, fit: "stretch"); banner }) }
      at(64.2pt, 119.88pt, text(font: if title-font == none { tnr } else { title-font },
        weight: if title-font == none { "bold" } else { "regular" }, size: 14pt, fill: red)[International Journal of Dental Science and Innovative Research (IJDSIR)])
      let web(x, body) = at(x, 132.54pt, text(font: tnr, size: 10.02pt, weight: "bold", style: "italic", fill: navy, body))
      web(176.46pt + 12 * 2.505pt)[Website: www.ijdsir.com,]
      at(312.9pt, 132.54pt, text(font: if contact-font == none { tnr } else { contact-font }, size: if contact-font == none { 10.02pt } else { 7.98pt }, weight: if contact-font == none { "bold" } else { "regular" }, style: "italic", fill: navy)[Contact])
      web(345.72pt + 2.505pt)[us: editor\@ijdsir.com]
      fill-rect(47.8pt, if n == 1 { 140.1pt } else { 150.3pt }, 518.4pt, 2.9pt, rgb(75, 172, 198))
      // footer: 3pt + 0.7pt rules in rgb(98,36,35), then the reserved line and page number
      let maroon = rgb(98, 36, 35)
      fill-rect(45.5pt, 735.2pt, 522pt, 3pt, maroon)
      fill-rect(45.5pt, 738.9pt, 522pt, 0.7pt, maroon)
      at(50pt, 751.9pt, bi(12pt, navy)[Covering Letter Reserved by: www.ijdsir.com])
      at(532.4pt, 751.9pt, bi(12pt, black)[Page #n])
    },
  )

  // ---- page 1 ----
  ln(0pt, 0pt, 14pt, align: center, text(fill: rgb("#e36c0a"), weight: "bold", style: "italic",
    underline(stroke: 1.3pt, offset: 2.1pt, evade: false)[COVERING LETTER]))
  ln(21.6pt, 14pt, 11pt)[*To,*]
  ln(18.7pt, 11pt, 11pt)[*The Editor In Chief*]
  ln(18.5pt, 11pt, 11pt)[*Name of Journal*#or-dots(journal-name, "...........................................................")]
  ln(19.7pt, 11pt, 12pt)[*International Journal of Dental Science and Innovative Research (IJDSIR)*]
  ln(18.8pt, 12pt, 11pt)[*Sub: Submission of Manuscript for publication*]
  ln(19.5pt, 11pt, 12pt)[Dear Sir/Madam,]
  ln(25.8pt, 12pt, 12pt, par(justify: true)[I am herewith submitting a manuscript for the publication in your esteemed journal. I hereby declare that this work is genuine and to the best of my knowledge, the contents were not published or sending previously to anywhere else for publications. On behalf of all the contributors, I will act and guarantor and will correspond with the journal from this point onward.])

  block(above: 0.5pt, below: 0pt, {
    set par(leading: 15.85pt - 1.107 * 12pt)
    table(
      columns: (49.7pt, 184.2pt, 283.5pt),
      stroke: 0.5pt,
      inset: (x, _) => (left: if x == 0 { 4.15pt } else { 5.35pt }, right: if x == 0 { 6.55pt } else { 5.35pt },
        top: 0.76pt, bottom: 12.33pt),
      align: (center, left, left),
      table.header([*S.No.*], align(center)[*Information of Articles*], align(center)[*Declaration for Articles*]),
      [1.], par(justify: true)[Type of Article _*such as*_ Research Paper, Review Paper, Analytical Paper…..Etc.], [#article-type],
      [2.], [Submit to], [#submit-to],
      [3.], [Manuscript Title], [#manuscript-title],
      [4.], [Research Area/Field], [#research-area],
      [5.], [Source of Support], [#support],
      [6.], [Conflicts of Interest], [#conflicts],
    )
  })

  ln(17.3pt + 2.6pt, 12pt, 12pt)[We would like to suggest following referees (Potential Reviewers) for the article (*Annexure –I*).]
  ln(19.8pt, 12pt, 12pt)[Thanking you,]
  ln(19.7pt, 12pt, 12pt)[Yours’ sincerely,]
  ln(13.8pt, 12pt, 12pt)[With best regards,]
  ln(14pt, 12pt, 12pt)[*Corresponding Author/ Co-Author*]
  ln(15.8pt, 12pt, 12pt)[*Name:* #or-dots(a.name, "……………………….…………………………….….….")]
  ln(15.8pt, 12pt, 12pt)[#text(11pt)[*Institution/College/Organisation*]:#or-dots(a.institution, "………..…..………………….... ")]
  ln(15.9pt, 12pt, 12pt)[*Country:* #or-dots(a.country, "……………..…. ")*Contact No:*#or-dots(a.contact, "………………………... ")]
  ln(15.9pt, 12pt, 12pt)[*Mobile No:*#or-dots(a.mobile, "……………………….")*E-mail:* #or-dots(a.email, "……………………… ")]
  ln(15.9pt, 12pt, 12pt)[*Place:*#or-dots(place, "…………………………..…")*Date:*#or-dots(date, "…………………...……. ")]

  // ---- page 2: Annexure-I ----
  pagebreak()
  v(14.9pt)
  ln(0pt, 0pt, 14pt, align: center, text(fill: navy, weight: "bold", style: "italic")[Annexure-I])
  ln(28.5pt, 14pt, 14pt, align: center, text(weight: "bold", style: "italic")[List of Potential Reviewers])
  for i in range(3) {
    let r = (name: none, designation: none, institution: none, area: none, contact: none, email: none) + reviewers.at(i, default: (:))
    ln(if i == 0 { 31.5pt } else { 23.8pt }, if i == 0 { 14pt } else { 12pt }, 12pt)[*#(i + 1).*#h(5.3pt)*Name:* #or-dots(r.name, "…………………………………………………… ")]
    ln(23.8pt, 12pt, 12pt)[Designation:#or-dots(r.designation, "………………………………………………… ")]
    ln(18.7pt, 12pt, 12pt)[#text(11pt)[Institution/College/Organisation]:#or-dots(r.institution, "…………………………….")]
    ln(23.9pt, 12pt, 12pt)[Area of specialization/Research:#or-dots(r.area, "……………………………..")]
    ln(28.8pt, 12pt, 12pt)[Contact No:#or-dots(r.contact, "…………………………………………………. ")]
    ln(23.8pt, 12pt, 12pt)[E mail ID:#or-dots(r.email, "…………………………………………………… ")]
  }
  let ul(body) = underline(stroke: 1.15pt, offset: 1.95pt, evade: false, body)
  let mail(m) = link("mailto:" + m, ul(text(fill: rgb("#0000ff"), m)))
  ln(32.5pt, 12pt, 12pt)[*Note:* _*Please provide the following details and send to #mail("editor@ijdsir.com") or #mail("editorijdsir@gmail.com"),*_ #text(fill: rgb("#080808"))[for any further help, please click on] #link("https://www.ijdsir.com/contact-us", ul(text(fill: rgb("#0000ff"))[*contact us*.]))]
}
