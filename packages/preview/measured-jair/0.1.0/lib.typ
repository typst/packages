// measured-jair — a Typst template for the Journal of Artificial Intelligence Research
//
// Reproduces the layout of `jair.cls` (2025/08/15), the class JAIR adopted for
// volume 83 onward. jair.cls loads `acmart` with [acmlarge, natbib=false,
// screen], and acmart in turn loads *amsart* at 10pt -- not `article` -- so the
// size ladder below is amsart's, which differs from the familiar one at every
// step. All dimensions were read from the class files and then verified by
// measuring the compiled reference PDF character by character.
//
// acmart's dimensions are TeX points (1/72.27in); Typst's `pt` is the big point
// (1/72in). Every copied value is scaled by 72/72.27.
//
// Licensed under the MIT License.

// acmart's faces first, then fallbacks. Typst's compiler embeds Libertinus
// Serif, New Computer Modern (+ Math) and DejaVu Sans Mono but no sans-serif
// at all, so a sans must come from the system or the project; TeX Gyre Heros
// is the last resort because the web app ships the TeX Gyre family. Typst
// warns once per use for every family it cannot find, so the lists are short.
#let _serif = ("Linux Libertine O", "Libertinus Serif")
#let _sans = ("Linux Biolinum O", "Libertinus Sans", "TeX Gyre Heros")
#let _mono = ("Inconsolata", "DejaVu Sans Mono")
#let _math = ("Libertinus Math", "New Computer Modern Math")

// amsart 10pt \@typesizes: (size, baselineskip), in TeX pt.
#let _tex = 72 / 72.27
#let _normalsize = 10pt * _tex // 10/12
#let _small = 9pt * _tex // 9/11
#let _footnotesize = 8pt * _tex // 8/10
#let _scriptsize = 7pt * _tex // 7/8
#let _large = 10.95pt * _tex // 10.95/13 — section headings (jair.cls @secfont)
#let _Large = 12pt * _tex // 12/14     — author names
#let _LARGE = 14.4pt * _tex // 14.4/17  — title

// Typst's `leading` is the gap between lines; LaTeX's \baselineskip is measured
// baseline to baseline. Pinning top-edge/bottom-edge to a 1em box makes the
// conversion exact and independent of which font actually resolves, so the
// baseline grid survives a font substitution on the Typst web app.
#let _lead(baselineskip, size) = baselineskip * _tex - size

#let _cc-badge = box(
  stroke: 0.6pt + rgb("#333"),
  radius: 2pt,
  inset: (x: 3pt, y: 1pt),
  text(size: 6.5pt, weight: "bold", font: _sans)[CC BY],
)

/// booktabs rules, as acmart loads booktabs: \toprule and \bottomrule are
/// 0.08em heavy, \midrule is 0.05em light. Use them inside `table(...)`.
#let toprule = table.hline(stroke: 0.08em)
#let midrule = table.hline(stroke: 0.05em)
#let botrule = table.hline(stroke: 0.08em)

/// The JAIR article template.
///
/// JAIR's own kit states: "Do not include ACM CCS Concepts or Keywords." The
/// `ccs` and `keywords` parameters exist because acmart supports them, but
/// leave them unset for a JAIR submission.
///
/// - title: the article title.
/// - short-title: running-head form of the title (`\title[short]{...}`).
/// - authors: array of dictionaries with `name` and `affiliation`, optionally
///   `email`, `orcid`, `corresponding`, and `contact-affiliation` for the
///   longer form the class prints in the contact footnote.
/// - short-authors: running-head form of the author list.
/// - abstract: printed in \small with no heading, as JAIR does.
/// - track, associate-editor: the JAIR metadata block.
/// - volume, article, pubdate, year, doi: running head/foot and the JAIR
///   reference format string.
/// - received: e.g. "Received 20 February 2007; accepted 5 June 2009".
/// - acknowledgements: unnumbered section before the references.
/// - appendix: content set after the references, with lettered headings.
/// - review: adds line numbers, like `\documentclass[review]{jair}`. The
///   official JAIR example is compiled with this option.
/// - anonymous: strips author identity. JAIR does not use blind review; the
///   switch is for preprints and other venues.
#let jair(
  title: none,
  short-title: none,
  authors: (),
  short-authors: none,
  abstract: none,
  keywords: (),
  ccs: none,
  track: none,
  associate-editor: "Insert JAIR AE Name",
  volume: "1",
  article: "1",
  pubdate: none,
  year: none,
  doi: none,
  received: none,
  acknowledgements: none,
  appendix: none,
  copyright-holder: none,
  review: false,
  anonymous: false,
  bibliography: none,
  body,
) = {
  let journal = "Journal of Artificial Intelligence Research"

  assert(
    type(authors) == array,
    message: "`authors` must be an array of dictionaries, got " + str(type(authors)),
  )
  for a in authors {
    assert(
      type(a) == dictionary and "name" in a and type(a.name) == str,
      message: "each entry of `authors` must be a dictionary with a `name` string, got " + repr(a),
    )
  }
  // 3. a title is needed for the running head and the reference format
  assert(title != none, message: "`title` is required")

  set document(
    title: title,
    author: if anonymous { () } else { authors.map(a => a.name) },
  )

  // acmart builds \shortauthors from the full author names joined by
  // \andify: "A", "A and B", "A, B, and C". The sample overrides it with
  // surnames; pass `short-authors` to do the same.
  let short-auth = if anonymous { "Anonymous" } else if short-authors != none {
    short-authors
  } else {
    let names = authors.map(a => a.name)
    if names.len() == 0 { "" } else if names.len() == 1 { names.first() } else if names.len() == 2 {
      names.join(" and ")
    } else { names.slice(0, -1).join(", ") + ", and " + names.last() }
  }
  let short-tit = if short-title != none { short-title } else { title }

  // acmlarge asks for top=78pt, bottom=114pt (TeX pt) with `includeheadfoot`,
  // so those margins bound header + text + foot and the 13pt head and 14pt
  // headsep come out of the top one. The values below are what that works
  // out to, measured on the reference: head at y=79.1/79.7, first body line
  // 106.93, last 654.72, foot 670.35.
  set page(
    width: 8.5in,
    height: 11in,
    margin: (inside: 80.7pt, outside: 80.7pt, top: 106.9pt, bottom: 138pt),
    binding: left,
    header-ascent: 19.2pt,
    footer-descent: 16.4pt,
    header: context {
      let n = counter(page).get().first()
      if n == 1 { return }
      set text(font: _sans, size: _footnotesize)
      let folio = [#article:#n]
      if calc.odd(n) {
        align(right)[#short-tit#h(1em)#sym.bullet#h(1em)#folio]
      } else if short-auth == "" {
        align(left, folio)
      } else {
        align(left)[#folio#h(1em)#sym.bullet#h(1em)#short-auth]
      }
    },
    footer: context {
      let n = counter(page).get().first()
      let l = text(size: _footnotesize)[
        #journal, Vol. #volume, Article #article.
        #if pubdate != none [Publication date: #pubdate.]
      ]
      if calc.odd(n) { align(right, l) } else { align(left, l) }
    },
  )

  // \documentclass[review] turns on lineno at \scriptsize. A `set` inside an
  // `if` block would only apply within that block, so the switch lives in the
  // argument. The reference prints them at x=54.6 on both odd and even pages.
  set par.line(
    numbering: if review {
      n => context if counter(page).get().first() > 1 {
        text(size: _scriptsize, font: _serif, fill: rgb(255, 0, 0), str(n))
      }
    } else { none },
    number-align: left,
    number-margin: left,
    number-clearance: 19.6pt,
    numbering-scope: "page",
  )

  set text(font: _serif, size: _normalsize, lang: "en", top-edge: 0.75em, bottom-edge: -0.25em)
  // acmart: \parindent 10pt, \parskip 0pt, so paragraph spacing == leading.
  set par(
    justify: true,
    leading: _lead(12pt, _normalsize),
    spacing: _lead(12pt, _normalsize),
    first-line-indent: 10pt * _tex,
  )
  // Typst sets raw at 0.8em; \texttt runs at the surrounding size, so undo it.
  show raw: set text(font: _mono, size: 1.25em)
  show math.equation: set text(font: _math)
  set math.equation(numbering: "(1)")
  // Paragraph spacing equals the leading (about 2pt), and blocks inherit it,
  // so displays and floats need their own. amsart sets \abovedisplayskip =
  // \belowdisplayskip = 0.35\baselineskip plus 0.35\baselineskip (4.2pt) and
  // \intextsep = 12pt plus 6pt minus 4pt. Typst has no glue, so the values
  // below were fitted to a jair.cls document compiled on an unfilled page:
  // ink-to-ink gaps of 6.1-6.8pt around displays, 12.1pt above a figure,
  // 15.8pt from its caption to the next line.
  show math.equation.where(block: true): set block(above: 6.2pt, below: 6.2pt)
  show figure: set block(above: 12pt * _tex, below: 15.4pt)

  // The `screen` option: ACMPurple for internal links and citations,
  // ACMDarkBlue for URLs.
  show link: set text(fill: cmyk(100%, 58%, 0%, 21%))
  show ref: set text(fill: cmyk(55%, 100%, 0%, 15%))
  show cite: set text(fill: cmyk(55%, 100%, 0%, 15%))

  // secnumdepth is 3, so levels 1-3 are numbered. \@seccntformat appends
  // \quad after the number; that quad is added by the show rules below rather
  // than by the numbering itself, so `@label` references stay clean.
  set heading(numbering: "1.1.1")
  show heading.where(level: 4): set heading(numbering: none)
  show heading.where(level: 5): set heading(numbering: none)
  show heading.where(level: 6): set heading(numbering: none)
  show heading: set par(justify: false, first-line-indent: 0pt, leading: _lead(13pt, _large))
  let _number(it) = if it.numbering != none {
    counter(heading).display(it.numbering)
    h(1em)
  }
  // jair.cls overrides \@secfont AND \@subsecfont to the same thing, so levels
  // 1 and 2 share one size, unlike stock acmart. The block spacing is
  // \vskip .75\baselineskip / .25\baselineskip *plus* the interline glue that
  // Typst's edge-to-edge text boxes do not contribute.
  let _section(it) = block(above: 11.3pt, below: 4.7pt, width: 100%, sticky: true, {
    set text(font: _sans, weight: "bold", size: _large)
    _number(it)
    it.body
  })
  show heading.where(level: 1): _section
  show heading.where(level: 2): _section
  // Levels 3 and 4 are run-in in acmart: \@subsubsecfont is \sffamily\itshape
  // and \@parfont is \itshape, both with a dot after and a negative afterskip
  // followed by \hskip 3.5pt. Typst starts a new paragraph after any heading,
  // so the text cannot join the same line; the fonts, the trailing period and
  // the -.5\baselineskip beforeskip are matched, and the difference is stated
  // in the README. Levels 5 and 6 fall back to the level-4 face.
  show heading.where(level: 3): it => block(above: 4.8pt, below: 0pt, sticky: true, {
    set text(font: _sans, style: "italic", weight: "regular", size: _normalsize)
    _number(it)
    it.body
    [.]
  })
  let _paragraph(it) = block(above: 7.9pt, below: 0pt, sticky: true, {
    h(10pt * _tex)
    set text(style: "italic", weight: "regular", size: _normalsize)
    it.body
    [.]
  })
  show heading.where(level: 4): _paragraph
  show heading.where(level: 5): _paragraph
  show heading.where(level: 6): _paragraph

  // \abovecaptionskip 10pt; measured 13.3pt ink-to-ink from a figure to its
  // caption and from a table caption to the rule below it.
  set figure(gap: 13pt)
  show figure.caption: set text(font: _sans, size: _small)
  set figure.caption(separator: [. ])
  show figure.where(kind: image): set figure(supplement: [Fig.])
  show figure.where(kind: table): set figure.caption(position: top)
  // Row pitch of a booktabs table in the reference is 17.3pt at 10pt, which
  // Typst reaches with a 3.6pt vertical inset.
  set table(stroke: none, inset: (x: 5pt, y: 3.6pt))

  // acmart list geometry: \labelsep 4pt, label width 6.5pt.
  // Measured on the reference: marker at margin+20.2, body at margin+30.1.
  // `body-indent` is measured from the end of the marker, hence the smaller
  // value. acmlarge inherits amsart's "(1)" enumerator.
  set list(indent: 20.2pt, body-indent: 6.4pt)
  set enum(indent: 20.2pt, body-indent: 6.4pt, numbering: "(1)")
  set terms(indent: 20.2pt, separator: h(6.4pt))

  show std.bibliography: set heading(numbering: none)
  // Ordinary footnotes use acmart's 4pc rule.
  set footnote.entry(separator: line(length: 48pt * _tex, stroke: 0.4pt), indent: 0pt)
  show footnote.entry: set text(size: _footnotesize)
  show footnote.entry: set par(leading: _lead(10pt, _footnotesize))

  // --- Title block ---------------------------------------------------------
  // LaTeX puts the first baseline \topskip below the text-block top, so the
  // title's larger face starts 3.4pt higher than a 10pt body line would.
  v(-3.4pt)
  block(width: 100%, {
    set par(justify: false, first-line-indent: 0pt, leading: _lead(17pt, _LARGE))
    text(font: _sans, weight: "bold", size: _LARGE, title)
    v(6.3pt)

    // jair.cls \@mkauthors@i: one author per line, NAME in caps, affiliation
    // inline after a comma.
    if anonymous {
      block(spacing: 2pt, text(font: _sans, size: _Large, upper("Anonymous Author(s)")))
    } else {
      for a in authors {
        block(spacing: 2pt, {
          text(font: _sans, size: _Large, upper(a.name))
          if a.at("corresponding", default: false) {
            text(size: 8.8pt, baseline: -2pt, "*")
          }
          if a.at("affiliation", default: none) != none {
            text(font: _sans, size: _Large)[,]
            text(size: _normalsize)[ #a.affiliation]
          }
        })
      }
    }
  })

  v(6.4pt)

  // \@mkabstract sets the abstract in \small with no heading.
  if abstract != none {
    block(width: 100%, {
      set text(size: _small)
      set par(
        leading: _lead(11pt, _small),
        spacing: _lead(11pt, _small),
        first-line-indent: 0pt,
      )
      abstract
    })
  }

  // \@specialsection prints these labels unbolded, unlike the JAIR blocks.
  // JAIR asks authors not to use them at all. The \medskip between the blocks
  // measures 7.1pt ink-to-ink on the reference; 4.2pt of block spacing gives
  // the same on top of the 1em text boxes.
  let _medskip = 4.2pt
  if ccs != none {
    v(_medskip)
    block(text(size: _small)[CCS Concepts: #ccs])
  }
  if keywords.len() > 0 {
    v(_medskip)
    block(text(size: _small)[Additional Key Words and Phrases: #keywords.join(", ")])
  }

  // --- JAIR metadata block, separated by \medskip ---------------------------
  if track != none {
    v(_medskip)
    block(text(size: _small)[*JAIR Track:* #track])
  }
  v(_medskip)
  block(text(size: _small)[*JAIR Associate Editor:* #associate-editor])

  // The first-page footnotes (corresponding author, contact information,
  // license) are attached to the end of this block. As separate calls each
  // would open an empty paragraph and cost a full line above the body.
  let first-page-notes = {
    if not anonymous and authors.any(a => a.at("corresponding", default: false)) {
      footnote(numbering: _ => "")[
        #set text(size: _footnotesize)
        \* Corresponding Author.
      ]
    }
    if not anonymous {
      let contacts = authors.map(a => {
        let orcid = if a.at("orcid", default: none) != none {
          [, #smallcaps("orcid:") #link("https://orcid.org/" + a.orcid)[#a.orcid]]
        }
        let mail = if a.at("email", default: none) != none { [, #a.email] }
        let aff = a.at("contact-affiliation", default: a.at("affiliation", default: none))
        [#a.name#orcid#mail#if aff != none [, #aff]]
      })
      if contacts.len() > 0 {
        footnote(numbering: _ => "")[
          #set text(size: _footnotesize)
          #if contacts.len() > 1 [Authors'] else [Author's] Contact Information:
          #contacts.join("; ").
        ]
      }
    }
    footnote(numbering: _ => "")[
      #set text(size: _footnotesize)
      #_cc-badge
      #h(0.5em)
      #link("https://creativecommons.org/licenses/by/4.0/")[
        This work is licensed under a Creative Commons Attribution International 4.0 License.
      ]
      #linebreak()
      ©#if year != none [ #year]
      #if copyright-holder != none [#copyright-holder.] else [Copyright held by the owner/author(s).]
      #if doi != none [#linebreak() #smallcaps("doi:") #link("https://doi.org/" + doi)[#doi]]
    ]
  }

  v(_medskip)
  block(text(size: _small)[
    *JAIR Reference Format:* \
    #{
      let names = if anonymous { ("Anonymous",) } else { authors.map(a => a.name) }
      let joined = if names.len() == 0 { "" } else if names.len() == 1 {
        names.first()
      } else if names.len() == 2 { names.join(" and ") } else {
        names.slice(0, -1).join(", ") + ", and " + names.last()
      }
      [#joined. #if year != none [#year. ]#title. _#journal _ #volume, Article #article#if pubdate != none [ (#pubdate)], ]
    }
    #context {
      let n = counter(page).final().first()
      [#text(fill: cmyk(55%, 100%, 0%, 15%))[#n] #if n == 1 { "page" } else { "pages" }.]
    }
    #if doi != none [ #smallcaps("doi:") #link("https://doi.org/" + doi)[#doi]]
    #first-page-notes
  ])

  // acmart resets the footnote counter after the topmatter, so the synthetic
  // footnotes above do not renumber the author's first real one.
  counter(footnote).update(0)

  // \@printendtopmatter inserts \par\bigskip before the body, which
  // \addvspace merges with the first heading's own skip. A weak skip of the
  // same size as the heading's `above` collapses with it, so a first heading
  // sits 12.4pt ink-to-ink below the reference-format block, as in the
  // reference, while a body that starts with plain text gets the bigskip.
  v(11.6pt, weak: true)

  body

  if acknowledgements != none {
    heading(numbering: none, outlined: false)[Acknowledgments]
    acknowledgements
  }

  if bibliography != none { bibliography }

  if appendix != none {
    counter(heading).update(0)
    set heading(numbering: "A.1.1")
    appendix
  }

  if received != none {
    v(12pt * _tex)
    block(text(size: _small, received))
  }
}
