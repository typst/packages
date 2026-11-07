// Native Typst implementation of the Swiss AI Days 2027 paper format.
// Copyright 2026 Olivier D'Ancona (@ODAncona).
// The original style derives from ICML 2025; see README.md for attribution.
// SPDX-License-Identifier: MIT

// LaTeX uses TeX points (1/72.27 in); Typst uses PostScript points (1/72 in).
#let tpt = 72pt / 72.27
#let ink-blue = rgb(0%, 8%, 45%)
#let statement-kind = "aidays-statement"

/// An unnumbered section, e.g. Limitations or AI Use Statement.
#let unnumbered(title) = heading(level: 1, numbering: none, title)

/// Include acknowledgements at the call site only in the accepted version.
#let acknowledgements(body) = context if state("aidays-accepted", false).get() {
  unnumbered[Acknowledgements]
  body
}

/// Start appendices on a new page; retain all other conference styles.
/// Use columns: 2 for a two-column appendix.
#let appendix(body, columns: 1) = {
  assert(columns in (1, 2), message: "Appendix columns must be 1 or 2.")
  pagebreak(weak: true)
  set page(columns: columns)
  set heading(numbering: "A.1.")
  counter(heading).update(0)
  body
}

/// A ruled algorithm float. Put pseudocode in body with native Typst markup.
#let algorithm(caption, body, placement: auto, scope: "column") = figure(
  block(width: 100%, above: 0pt, below: 0pt, {
    set align(left)
    body
    v(5 * tpt)
    line(length: 100%, stroke: 0.8 * tpt)
  }),
  kind: "algorithm",
  supplement: [Algorithm],
  caption: caption,
  placement: placement,
  scope: scope,
)

#let statement-number(n) = context {
  // Use the target figure's location, even when this is evaluated by a
  // reference in another section. Keep the internal figure counter global.
  let target = query(figure.where(kind: statement-kind)).at(n - 1).location()
  let sections = query(heading.where(level: 1).before(target)).filter(h => h.numbering != none)
  if sections.len() == 0 { [0.#n] } else {
    let section = sections.last()
    let prefix = numbering(
      if section.numbering == "A.1." { "A" } else { "1" },
      counter(heading).at(section.location()).first(),
    )
    let local-number = query(figure.where(kind: statement-kind)
      .after(section.location()).before(target, inclusive: true)).len()
    [#prefix.#local-number]
  }
}

#let statement(name, body, title: none, italic: true) = figure(
  if italic { emph(body) } else { body },
  kind: statement-kind,
  supplement: name,
  caption: if title == none { [] } else { title },
  numbering: statement-number,
)

/// Theorem-like environments share one counter, reset at each numbered section.
#let theorem = statement.with([Theorem])
#let proposition = statement.with([Proposition])
#let lemma = statement.with([Lemma])
#let corollary = statement.with([Corollary])
#let definition = statement.with([Definition], italic: false)
#let assumption = statement.with([Assumption], italic: false)
#let remark = statement.with([Remark], italic: false)
#let proof(body) = block(breakable: true)[_Proof._ #body #h(1fr) $square$]

#let review-ruler = context {
  // The LaTeX style uses a fixed 12-TeX-point ruler, rather than counting
  // paragraph lines. Include figures and whitespace, and continue across pages.
  let start = (counter(page).get().first() - 1) * 55
  for i in range(55) {
    place(top + left, dx: 0.77in - 35 * tpt - 16pt, dy: 1in + i * 12 * tpt,
      box(width: 16pt, align(right, text(
        size: 7 * tpt, fill: luma(70%),
        "0" * calc.max(0, 3 - str(start + i).len()) + str(start + i),
      ))),
    )
  }
}

/// Apply the Swiss AI Days 2027 paper style.
/// - title (content): Full paper title.
/// - short-title (content, str, auto): One-line running title; defaults to title.
/// - authors (array): Dictionaries with name (str), affiliations (array of str),
///   optional equal (bool), email (str), corresponding (bool).
/// - affiliations (dictionary): Affiliation identifiers mapped to content.
/// - accepted (bool): Reveal authors and print the proceedings notice.
/// - abstract (content, none): A single paragraph, normally 4-6 sentences.
/// - keywords (array of str): PDF metadata only.
/// - font (str, array): An installed Times-compatible face; defaults to Times New Roman.
/// - body (content): Paper, statements, bibliography, and optional appendix.
#let aidays(
  title: [Paper Title],
  short-title: auto,
  authors: (),
  affiliations: (:),
  accepted: false,
  abstract: none,
  keywords: (),
  font: "Times New Roman",
  body,
) = {
  assert(type(accepted) == bool, message: "accepted must be true or false.")
  let running-title = if short-title == auto { title } else { short-title }

  // Assign affiliation numbers by first occurrence in the author list.
  let affiliation-order = ()
  for author in authors {
    assert(type(author.name) == str, message: "Author names must be strings.")
    for id in author.at("affiliations", default: ()) {
      assert(id in affiliations, message: "Unknown affiliation: " + id)
      if id not in affiliation-order { affiliation-order.push(id) }
    }
    if author.at("corresponding", default: false) {
      assert("email" in author, message: "A corresponding author needs an email.")
    }
  }
  let corresponding = authors.filter(a => a.at("corresponding", default: false))

  set document(
    title: title,
    author: if accepted { authors.map(a => a.name) } else { ("Anonymous Authors",) },
    keywords: keywords,
    date: none,
  )
  set text(font: font, size: 10 * tpt, lang: "en",
    top-edge: 0.7em, bottom-edge: -0.2em, hyphenate: true)
  // 0.9em text bounds + 2 TeX pt leading = 11 TeX pt baseline distance.
  set par(justify: true, leading: 2 * tpt, spacing: 8 * tpt, first-line-indent: 0pt)
  set page(
    paper: "us-letter",
    // The style's -0.23in oddsidemargin gives a physical 0.77in left margin.
    margin: (left: 0.77in, right: 0.98in, top: 1in, bottom: 1in),
    columns: 2,
    header: context if counter(page).get().first() > 1 {
      set par(justify: false, leading: 0pt)
      let head = text(size: 9 * tpt, weight: "bold", running-title)
      let head-size = measure(box(head))
      assert(head-size.width <= 6.75in and head-size.height <= 10 * tpt,
        message: "Running title is too long; provide a shorter short-title.")
      block(width: 100%, above: 0pt, below: 0pt, align(center, head))
      v(3 * tpt)
      line(length: 100%, stroke: 1 * tpt)
    },
    header-ascent: 10 * tpt,
    footer: context align(center, text(size: 10 * tpt, counter(page).display("1"))),
    footer-descent: 18 * tpt,
    background: if accepted { none } else { review-ruler },
  )
  set columns(gutter: 0.25in)
  set heading(numbering: "1.1.")
  show heading: it => {
    assert(it.level <= 3, message: "Use at most three heading levels.")
    set align(left)
    set par(justify: false)
    set text(size: (if it.level == 1 { 11 } else { 10 }) * tpt,
      weight: if it.level == 3 { "regular" } else { "bold" })
    set block(
      above: (0.14in, 0.12in, 0.10in).at(it.level - 1),
      below: (0.04in, 0.03in, 0.03in).at(it.level - 1),
    )
    if it.level == 3 { smallcaps(it) } else { it }
  }
  set list(indent: 10 * tpt, body-indent: 5 * tpt, spacing: 2 * tpt)
  set enum(indent: 10 * tpt, body-indent: 5 * tpt, spacing: 2 * tpt)
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): set block(above: 7 * tpt, below: 7 * tpt)
  show link: set text(fill: ink-blue)
  show ref: set text(fill: ink-blue)
  show cite: set text(fill: ink-blue)
  set bibliography(style: "aidays.csl", title: [References])
  set cite(style: "aidays.csl")
  show bibliography: set text(size: 10 * tpt)
  set figure(gap: 10 * tpt)
  show figure.caption: it => {
    set text(size: 9 * tpt)
    set par(justify: false, leading: 2 * tpt)
    let prefix = [#emph[#it.supplement #it.counter.display(it.numbering).] ]
    let caption = prefix + it.body
    layout(size => if measure(caption).width < size.width {
      align(center, caption)
    } else { align(left, caption) })
  }
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): it => {
    set figure(gap: 5 * tpt)
    set figure.caption(position: top)
    show figure.caption: cap => block(width: 100%, above: 0pt, below: 0pt, {
      set align(left)
      set text(size: 10 * tpt)
      set par(justify: false, spacing: 0pt)
      stack(dir: ttb, spacing: 3 * tpt,
        line(length: 100%, stroke: 0.8 * tpt),
        strong[#cap.supplement #context cap.counter.display(cap.numbering) #cap.body],
        line(length: 100%, stroke: 0.4 * tpt),
      )
    })
    it
  }
  show figure.where(kind: statement-kind): it => block(width: 100%, breakable: true, {
    set align(left)
    strong[
      #it.supplement #context it.counter.display(it.numbering)#if it.caption.body != [] [ (#it.caption.body)].
    ]
    h(0.3em)
    it.body
  })
  set footnote.entry(
    separator: line(length: 0.8in, stroke: 0.4 * tpt),
    clearance: 9 * tpt, gap: 6.65 * tpt, indent: 0pt,
  )
  show footnote.entry: set text(size: 9 * tpt)
  show footnote.entry: set par(leading: 1.9 * tpt, spacing: 4 * tpt)

  state("aidays-accepted", false).update(accepted)

  // A page-level float lets the title span both columns without breaking
  // column footnotes, wide floats, or subsequent page breaks.
  place(top + center, float: true, scope: "parent", clearance: 0.3in,
    block(width: 100%, {
      set par(justify: false, leading: 5.4 * tpt, spacing: 0pt)
      line(length: 100%, stroke: 1 * tpt)
      v(0.25in)
      align(center, text(size: 14 * tpt, weight: "bold", title))
      v(0.22in)
      line(length: 100%, stroke: 1 * tpt)
      v(0.3in)
      align(center, {
        set par(leading: 3 * tpt)
        if accepted and authors.len() > 0 {
          authors.map(a => box[
            #strong(a.name)#super(typographic: false, [
              #if a.at("equal", default: false) [\*#h(1pt)]#for id in a.at("affiliations", default: ()) {
                [#(affiliation-order.position(x => x == id) + 1)#h(1pt)]
              }
            ])
          ]).join(h(0.6em))
        } else if not accepted {
          strong[Anonymous Authors] + super[1]
        }
      })
    }),
  )

  // An unnumbered footnote reserves real space in the first column. Reset
  // afterwards so the first ordinary footnote is numbered 1.
  footnote(numbering: _ => "", {
    if accepted {
      if authors.any(a => a.at("equal", default: false)) { super[\*]; [Equal contribution. ] }
      for (i, id) in affiliation-order.enumerate() {
        super(str(i + 1)); affiliations.at(id); [. ]
      }
      if corresponding.len() > 0 {
        [Correspondence to: ]
        corresponding.map(a => [#a.name \<#link("mailto:" + a.email, a.email)\>]).join([, ])
        [.]
      }
    } else {
      super[1]
      [Anonymous Institution, Anonymous City, Anonymous Region, Anonymous Country.
      Correspondence to: Anonymous Author \<anon.email\@domain.com\>.]
    }
    parbreak()
    if accepted {
      [_Proceedings of the Fifth Swiss AI Days_, Geneva, GE, Yverdon-les-Bains,
      VD, & Fribourg, FR, Switzerland: PMLR 342, 2027.
      Copyright 2027 by the author(s).]
    } else {
      [Preliminary work. Under review by the Swiss AI Center and HES-SO AI Days
      (Swiss AI Days). Do not distribute.]
    }
  })
  counter(footnote).update(0)
  if abstract != none {
    block(above: 0pt, below: 0.22in, {
      stack(dir: ttb, spacing: 6 * tpt,
        align(center, text(size: 11 * tpt, weight: "bold", [Abstract])),
        pad(x: 0.25in, abstract),
      )
    })
  }
  body
}
