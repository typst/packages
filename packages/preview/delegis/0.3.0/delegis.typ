// Copyright (c) 2024 WüSpace e. V.
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// sentence number substitution marker
#let s = "XXXXXXSENTENCEXXXNUMBERXXXXXX"

/// Create an unmarkes section, such as a preamble.
/// Usage: `#unnumbered[Preamble]`
#let unnumbered = (it, ..rest) => heading(level: 6, numbering: none, ..rest, it)

/// Manually create a section. Useful when unsupported characters are used in the heading.
/// Usage: `#section[§ 3][Administrator*innen]`
#let section = (number, it, ..rest) => unnumbered(
  {
    number + "\n" + it
  },
  ..rest,
)

/// Division prefixes for different languages.
#let division-prefixes-de = ("Teil", "Kapitel", "Abschnitt", "Unterabschnitt")
#let division-prefixes-en = ("Part", "Chapter", "Division", "Subdivision")

/// Initialize a delegis document.
#let delegis = (
  // Metadata
  title : "Vereinsordnung zur IT-Infrastruktur",
  abbreviation : "ITVO",
  resolution : "3. Beschluss des Vorstands vom 24.01.2024",
  in-effect : "24.01.2024",
  draft : false,
  // Template
  logo : none,
  // Overrides
  size : 11pt,
  font : "Atkinson Hyperlegible",
  lang : "de",
  paper: "a5",
  division-prefixes: none, // use language-specific prefixes by default
  str-draft : "Entwurf",
  str-intro : (resolution, in-effect) => [Mit Beschluss (#resolution) tritt zum #in-effect in Kraft:],
  // Content
  body
) => {
  /// Language-specific division prefixes
  let division-prefixes = if division-prefixes != none {
    division-prefixes
  } else if lang == "en" {
    division-prefixes-en
  } else {
    division-prefixes-de // default to German
  }

  /// Metadata
  set document(title: title + " (" + abbreviation + ")", keywords: (title, abbreviation, resolution, in-effect))

  /// General Formatting
  let bg = if draft {
    rotate(45deg, text(100pt, fill: luma(85%), font: font, str-draft))
  }

  set page(paper: paper, numbering: "1 / 1", background: bg)
  set text(hyphenate: true, lang: lang, size: size, font: font)

  /// Clause Detection
  show regex("§ ([0-9a-zA-Z]+) (.+)$"): it => {
    let (_, number, ..rest) = it.text.split()

    heading(
      level: 6,
      numbering: none,
      {
        "§ " + number + "\n" + rest.join(" ")
      },
    )
  }

  /// Heading Formatting
  set heading(numbering: (..nums) => {
    // Handbuch der Rechtsförmlichkeit, Rn. 379 f.
    // After the final named level, use "X.X.X" for the numbering using the final prefix
    nums = nums.pos()

    let level = nums.len() // level of the heading
    let number = nums.slice(calc.min(
      division-prefixes.len(),
      level,
    ) - 1)

    let prefix = division-prefixes.at(
      calc.min(
        level - 1,
        division-prefixes.len() - 1,
      ),
    )

    let str-number = numbering("1.1", ..number)

    [
      #prefix #str-number:
    ]
  })
  show heading: set align(center)
  show heading: set text(size: size, weight: "regular")

  show heading.where(level: 1): set text(style: "italic")
  show heading.where(level: 2): set text(style: "italic")
  show heading.where(level: 3): set text(style: "italic")
  show heading.where(level: 4): set text(style: "italic")
  show heading.where(level: 5): set text(style: "italic")

  show heading.where(level: 6): set text(weight: "bold")

  // Enumeration numbering
  // 1. -> a) -> aa) -(unofficial)-> (1) -> i. -> i.i. -> ...
  // Handbuch der Rechtsförmlichkeit, Rn. 374
  set enum(
    numbering: (..numbers) => {
      let nums = numbers.pos()
      if (nums.len() == 1) {
        return numbering("1.", ..nums)
      } else if (nums.len() == 2) {
        return numbering("a)", ..nums.slice(1))
      } else if (nums.len() == 3) {
        let letter = numbering("a", ..nums.slice(2))
        return [ #letter#letter) ]
      } else if (nums.len() == 4) {
        return numbering("(1)", ..nums.slice(3))
      } else {
        return numbering("i.", ..nums.slice(4))
      }
    },
    full: true, // get full number arrays passed into the numbering function
  )

  /// Outlines
  show outline.entry: it => {
    show linebreak: it => { } // disable manual line breaks
    show "\n": " " // disable section number line breaks
    it
  }

  set outline(indent: 1cm)
  show outline: it => {
    it
    pagebreak(weak: true)
  }

  /// Sentence Numbering
  show regex(s): it => {
    counter("sentence").step()
    super(strong(counter("sentence").display()))
  }

  show parbreak: it => {
    counter("sentence").update(0)
    it
  }

  /// Title Page
  page(
    numbering: none,
    {
      place(top + right, block(width: 2cm, logo))
      v(1fr)

      show par: set block(spacing: .6em)

      if draft {
        text[#str-draft:]
      } else {
        par(text(str-intro(resolution, in-effect)))
      }

      par(text(2em, strong[#title (#abbreviation)]), leading: 0.6em)

      v(3cm)
    },
  )

  // Metadata once again. Needs to be down here to have the page size set.
  // Can be used with `typst query`, e.g.:
  //
  // `typst query example.typ "<title>" --field value --one` returns `"[title]"`
  [
    #metadata(title)<title>
    #metadata(abbreviation)<abbreviation>
    #metadata(resolution)<resolution>
    #metadata(in-effect)<in-effect>
  ]

  // allow footnotes that don't conflict with sentence numbers
  set footnote(numbering: "[1]")

  /// Content
  body
}
