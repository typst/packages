#import "titlepage.typ": *
#import "abstract.typ": *
#import "@preview/hydra:0.6.1": hydra
#import "@preview/linguify:0.4.2": *

#let in-outline = state("in-outline", false)
#let lang-database = state("linguify-db", none)

#let faculties = (
    pl: (
      "kneis": ("Kolegium Nauk Ekonomicznych", "i Społecznych w Płocku"),
      "wains": ("Wydział Administracji i Nauk Społecznych",),
      "warch": ("Wydział Architektury",),
      "wbmip": ("Wydział Budownictwa, Mechaniki", "i Petrochemii w Płocku"),
      "wch": ("Wydział Chemiczny",),
      "we": ("Wydział Elektryczny",),
      "weiti": ("Wydział Elektroniki", "i Technik Informacyjnych"),
      "wf": ("Wydział Fizyki",),
      "wgik": ("Wydział Geodezji i Kartografii",),
      "wichip": ("Wydział Inżynierii Chemicznej i Procesowej",),
      "wil": ("Wydział Inżynierii Lądowej",),
      "wim": ("Wydział Inżynierii Materiałowej",),
      "wis": ("Wydział Inżynierii Środowiska",),
      "wmeil": ("Wydział Mechaniczny", "Energetyki i Lotnictwa"),
      "wmini": ("Wydział Matematyki", "i Nauk Informacyjnych"),
      "wmchtr": ("Wydział Mechatroniki",),
      "wmt": ("Wydział Mechaniczny Technologiczny",),
      "wsimr": ("Wydział Samochodów", "i Maszyn Roboczych"),
      "wt": ("Wydział Transportu",),
      "wz": ("Wydział Zarządzania",),
    ),
    en: (
      "kneis": ("College of Economics and Social Sciences (Plock)",),
      "wains": ("Faculty of Administration and Social Sciences",),
      "warch": ("Faculty of Architecture",),
      "wbmip": ("Faculty of Civil Engineering,", "Mechanics and Petrochemistry (Plock)",),
      "wch": ("Faculty of Chemistry",),
      "we": ("Faculty of Electrical Engineering",),
      "weiti": ("Faculty of", "Electronics and Information Technology",),
      "wf": ("Faculty of Physics",),
      "wgik": ("Faculty of Geodesy and Cartography",),
      "wichip": ("Faculty of Chemical and Process Engineering",),
      "wil": ("Faculty of Civil Engineering",),
      "wim": ("Faculty of Materials Science and Engineering",),
      "wis": ("Faculty of Environmental Engineering",),
      "wmeil": ("Faculty of Power and Aeronautical Engineering",),
      "wmini": ("Faculty of Mathematics and Information Science",),
      "wmchtr": ("Faculty of Mechatronics",),
      "wmt": ("Faculty of Mechanical and Industrial Engineering",),
      "wsimr": ("Faculty of", "Automotive and Construction Machinery Engineering",),
      "wt": ("Faculty of Transport",),
      "wz": ("Faculty of Management",),
    ),
)

#let wut-thesis(
  /// Languages of the thesis.
  lang: (
    /// Language in which you studied, influences the language of the titlepage.
    studies: "pl",
    /// Language in which your thesis is written, influences the rest of the text (i.e.
    /// abstracts order, captions/references supplements, hyphenation etc).
    thesis: "pl",
  ),
  /// Information used to typeset the titlepage. If you don't want to create a titlepage
  //  then set this value to `none`.
  titlepage-info: (
    /// Type of the thesis, allowed values are `engineer`, `bachelor`, `master`.
    thesis-type: "engineer",
    /// Program (pol. kierunek).
    program: "The Program",
    /// Specialisation (pol. specjalizacja).
    specialisation: "Specialisation",
    /// Supervisor (pol. promotor).
    supervisor: "Your Supervisor",
    /// Advisor (pol. promotor pomocniczy/konsultacje). This will be typeset as
    //  `consultation`/`konsultacje`.
    advisor: "Your Advisor",
    /// For a full list of possible faculties see the `faculties` dictionary.
    faculty: "weiti",
    /// Institute (pol. instytut).
    institute: "Institute of Magic and Occultism",
    /// Student ID number.
    index-number: "",
    /// Date of the creation of the thesis.
    date: datetime.today(),
  ),
  /// Author of the thesis.
  author: "The Author",
  /// Title of the thesis.
  title: (
    en: "Title",
    pl: "Tytuł",
  ),
  /// Abstract of the thesis.
  abstract: (
    en: [English Abstract],
    pl: [Polskie Streszczenie],
  ),
  /// Keywords of the thesis.
  keywords: (
    en: ("keyword1",),
    pl: ("słowo kluczowe1",),
  ),
  /// The `draft` variable is used to change the coloring of links, show TODOs (both in the
  /// thesis and TODO outline), and DRAFT in the header and the title. It should be set to
  /// `true` until the final version is handed in.
  draft: true,
  /// The `in-print` variable is used to generate a PDF file for physical printing (it adds
  /// bigger margins on the binding part of the page, changes the numbering placement, and
  /// turns off coloring of links). It should be set to `false` unless you want to create a
  /// version of the PDF file for physical print, in which case, set it to `true`. *Please
  /// set this variable to' false' to prepare a PDF file for the final hand-in (uploading it
  /// to APD/OneDrive).*
  in-print: false,
  body,
) = {
  assert(faculties.pl.keys() == faculties.en.keys(), message: "Faculties sanity check")
  assert(
    not (draft and in-print),
    message: "If in-print is true, draft should be false.",
  )
  assert(
    lang.keys() == ("studies", "thesis"),
    message: "You need to provide the language(s) of both your studies and your thesis",
  )
  for lang_ in lang.values() {
    assert(lang_ in ("en", "pl"), message: "Supported languages are pl or en")
  }

  let linguify-database = toml("lang.toml")
  lang-database.update(linguify-database)

  let draft-string = ""
  if draft {
    draft-string = "DRAFT - "
  }

  // global text settings
  set text(
    lang: lang.thesis,
    weight: "regular",
    font: "New Computer Modern",
    size: 11pt,
  )
  let thesis-title = title.at(lang.thesis)
  show figure.caption: set text(size: 10pt)
  set text(ligatures: false)
  show footnote: set text(size: 9pt)
  show raw: set block(breakable: false)

  // set the line spacing (pl. interlinia)
  set par(leading: .8em, first-line-indent: 0.5cm, justify: true)
  set document(author: author, title: draft-string + thesis-title)

  let printing-offset = if in-print { 5mm } else { 0mm }

  set page(
    numbering: "1", // this is necessary for the glossary
    margin: (
      inside: 25mm + printing-offset, // binding correction of 5mm
      rest: 25mm,
    ),
    binding: left,
    header: [
      // temporary header for the titlepage, abstracts and the outline
      #set text(8pt)
      #if draft {
        box(outset: 3pt, fill: red, text(fill: black, weight: "black")[DRAFT])
      }
    ],
    footer: none, // temporary footer for the titlepage, abstracts and the outline
  )

  if titlepage-info != none {
    titlepage(
      titlepage-info,
      author,
      thesis-title,
      lang.studies,
      linguify-database,
      in-print,
      faculties.at(lang.studies),
    )
    pagebreak(weak: true)
  }

  let abstract-order = if lang.thesis == "pl" { ("pl", "en") } else { ("en", "pl") }
  for lang_ in abstract-order {
    abstract-page(
      title.at(lang_),
      abstract.at(lang_),
      keywords.at(lang_),
      lang_,
      linguify-database,
    )
  }

  // Table of contents.
  {
    show outline.entry.where(level: 1): it => {
      v(1em, weak: true)
      strong(it)
    }
    outline(indent: 2em, depth: 3, target: (
      selector(heading).before(<appendix_cutoff_label>)
    ).or(heading.where(body: [TODOs])))
  }
  pagebreak(weak: true, to: if in-print { "odd" } else { none })


  set page(
    header: context {
      let page = counter(page).get().first()
      let title = emph(hydra(1))
      let stroke = if measure(title).width > measure([1]).width { .3pt + black } else {
        none
      }
      block(width: 100%, outset: 4pt, stroke: (bottom: stroke), {
        let alignment = if in-print { if calc.odd(page) { right } else { left } } else {
          center
        }
        set align(alignment)
        if draft [
          #place(left, box(outset: 3pt, fill: red, text(
            fill: black,
            weight: "black",
            size: 8pt,
          )[DRAFT]))
        ]
        title
      })
    },
    footer: context {
      let page = counter(page).get().first()
      if in-print {
        align(if calc.odd(page) { right } else { left })[#page]
      } else {
        align(center)[#page]
      }
    },
  )
  counter(page).update(1)

  // set equation and heading numbering
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")


  // Set font size
  show heading.where(level: 3): set text(size: 1.05em)
  show heading.where(level: 4): set text(size: 1.0em)
  show figure: set text(size: 0.9em)

  // Set spacings
  show figure: it => [#v(1em) #it #v(1em)]

  show heading.where(level: 1): set block(above: 1.95em, below: 1em)
  show heading.where(level: 2): set block(above: 1.85em, below: 1em)
  show heading.where(level: 3): set block(above: 1.75em, below: 1em)
  show heading.where(level: 4): set block(above: 1.55em, below: 1em)


  // Pagebreak after level 1 headings, excluding outlines
  show outline: set heading(outlined: true)
  show outline: it => {
    state("in-outline").update(true)
    it
    state("in-outline").update(false)
  }

  show heading.where(level: 1): set heading(supplement: linguify(
    "chapter",
    from: linguify-database,
    lang: lang.thesis,
  ))
  show heading.where(level: 1): it => {
    if not state("in-outline", false).get() {
      pagebreak(weak: true)
    }
    it
  }

  // Set captions of tables, listings and algorithm on the top
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure.caption(position: top)

  // Table stroke
  set table(stroke: 0.5pt + black)
  show figure.caption: it => {
    align(
      box(align(
        [#text(
            weight: "bold",
          )[#it.supplement~#context it.counter.display(it.numbering).~]#it.body],
        left,
      )),
      center,
    )
  }

  // Fix `Appendix Appendix A` references
  show ref: it => {
    let el = it.element
    if (
      el != none
        and el.func() == heading
        and (el.supplement == [Appendix] or el.supplement == [Załącznik])
    ) {
      // Override appendix references.
      link(el.location(), numbering(el.numbering, ..counter(heading).at(el.location())))
    } else {
      // Other references as usual.
      it
    }
  }

  // Color links and references for the final document
  show link: it => {
    if not in-print and type(it.dest) == str {
      // Style links to strings blue
      text(fill: if draft {blue} else {rgb("#0099A1").saturate(150%)}, it)
    } else {
      // Return other links as usual
      it
    }
  }
  show ref: set text(fill: rgb("#823C84").saturate(150%)) if not in-print
  show cite: set text(fill: rgb("#D58A16").saturate(150%)) if not in-print


  // Draft Settings
  show cite: set text(fill: orange) if draft
  show ref: set text(fill: fuchsia) if draft

  body
}

#let figure-outline() = {
  context {
    outline(
      title: linguify("figure-outline", from: lang-database.get()),
      target: figure.where(kind: image),
    )
  }
}

#let table-outline() = {
  context {
    outline(
      title: linguify("table-outline", from: lang-database.get()),
      target: figure.where(kind: table),
    )
  }
}
