// TU Wien institutional blue.
#let tu-blue = rgb("#006699")

// Department forest green (used for citations).
#let forrest-green = rgb(0%, 27%, 13%)

/// Default thesis metadata. Override by spreading:
/// `#let info = (..default-info, title: "My Thesis", author: "Me")`
///
/// - `title` (str): Thesis title.
/// - `author` (str): Author full name.
/// - `student-id` (str): Matriculation number.
/// - `degree` (str): `"Diplomarbeit"`, `"Master"`, or `"Bachelor"`.
/// - `lang` (str): Document language (`"de"` or `"en"`); affects title page labels.
/// - `thesis-type-label` (str or none): Override the computed degree label on the title page; computed from `degree` × `lang` if `none`.
/// - `study-program` (str): Study programme name.
/// - `department` (str): Department name.
/// - `faculty` (str): Faculty name.
/// - `university` (str): University name.
/// - `supervisor` (str): Main supervisor with academic title.
/// - `co-supervisor` (str or none): Co-supervisor; line omitted if `none`.
/// - `cooperation` (str or none): Cooperation institution note; omitted if `none`.
/// - `location` (str): City of submission.
/// - `date` (datetime): Submission date.
#let default-info = (
  title: "Thesis Title",
  author: "Author Name",
  student-id: "00000000",
  degree: "Diplomarbeit",
  lang: "de",
  thesis-type-label: none,
  study-program: "Geodesy and Geoinformation",
  department: "Department of Geodesy and Geoinformation",
  faculty: "Faculty of Mathematics and Geoinformation",
  university: "Technische Universität Wien",
  supervisor: "Supervisor Name",
  co-supervisor: none,
  cooperation: none,
  location: "Wien",
  date: datetime.today(),
)

/// Generate the title page. Call before any other content.
///
/// -> content
#let make-title-page(
  /// Thesis metadata; use `default-info` as base.
  /// -> content
  info,
) = {
  let lang = info.at("lang", default: "de")
  let is-en = lang == "en"

  let degree-label = if info.at("thesis-type-label", default: none) != none {
    info.thesis-type-label
  } else if info.degree == "Master" {
    if is-en { "MASTER'S THESIS" } else { "MASTERARBEIT" }
  } else if info.degree == "Bachelor" {
    if is-en { "BACHELOR'S THESIS" } else { "BACHELORARBEIT" }
  } else {
    "DIPLOMARBEIT"
  }

  let degree-string = if info.degree == "Master" {
    "Master of Science"
  } else if info.degree == "Bachelor" {
    "Bachelor of Science"
  } else {
    "Diplom-Ingenieur/in"
  }

  let date-str = info.date.display("[day].[month].[year]")

  let t = if is-en {
    (
      for-degree: "in partial fulfilment of the requirements for the degree of",
      within: "within the programme",
      submitted: "submitted by",
      student-id: "Student ID",
      conducted: "conducted at the",
      of-faculty: "of the",
      at-uni: "of",
      supervision: "Supervision",
      supervisor: "Supervisor:",
      co-supervisor: "Co-Supervisor:",
      sig-author: "(Signature Author)",
      sig-supervisor: "(Signature Supervisor)",
    )
  } else {
    (
      for-degree: "zur Erlangung des akademischen Grades",
      within: "im Rahmen des Studiums",
      submitted: "eingereicht von",
      student-id: "Matrikelnummer",
      conducted: "ausgeführt am",
      of-faculty: "der",
      at-uni: "der",
      supervision: "Betreuung",
      supervisor: "Betreuer/in:",
      co-supervisor: "Mitwirkung:",
      sig-author: "(Unterschrift Verfasser/in)",
      sig-supervisor: "(Unterschrift Betreuer/in)",
    )
  }

  set page(header: none, footer: none, numbering: none)

  grid(
    columns: (1fr, 1fr),
    image("graphics/tuwien_logo.png", height: 2.5cm),
    align(right, image("graphics/Blue.png", height: 2.5cm)),
  )

  v(2cm)

  align(center)[
    #text(size: 14pt, upper(degree-label))
    #v(1fr)
    #text(size: 20pt, weight: "bold", info.title)
    #v(1fr)
    #text(size: 11pt)[#t.for-degree]
    #v(0.7em)
    #text(size: 14pt, weight: "bold", degree-string)
    #v(0.7em)
    #text(size: 11pt)[#t.within]
    #v(0.7em)
    #text(size: 13pt, weight: "bold", info.study-program)
    #v(0.7em)
    #text(size: 11pt)[#t.submitted]
    #v(0.7em)
    #text(size: 13pt, weight: "bold", info.author)
    #linebreak()
    #text(size: 11pt)[#t.student-id #info.student-id]
  ]

  v(1.5cm)

  [
    #t.conducted #info.department

    #t.of-faculty #info.faculty #t.at-uni #info.university
  ]

  if info.cooperation != none {
    v(0.5em)
    [#info.cooperation]
  }

  v(1cm)

  [#t.supervision

    #t.supervisor #info.supervisor]

  if info.co-supervisor != none {
    [

      #t.co-supervisor #info.co-supervisor]
  }

  v(1.5cm)

  grid(
    columns: (1fr, 5cm, 1cm, 5cm),
    rows: (auto, auto),
    row-gutter: 2pt,
    align(left + bottom)[#info.location, #date-str],
    align(center + bottom, line(length: 100%)),
    [],
    align(center + bottom, line(length: 100%)),

    [],
    align(center, text(size: 9pt)[#t.sig-author]),
    [],
    align(center, text(size: 9pt)[#t.sig-supervisor]),
  )

  pagebreak()
}

/// Generate bilingual declaration of authorship (German + English).
///
/// -> content
#let make-declaration(
  /// Thesis metadata. Needs `location`, `date`, `author`.
  /// -> content
  info,
) = {
  let date-str = info.date.display("[day].[month].[year]")

  set heading(numbering: none, outlined: false)

  [= Erklärung zur Verfassung der Arbeit]

  [Hiermit erkläre ich, dass ich diese Arbeit selbständig verfasst habe, dass
    ich die verwendeten Quellen und Hilfsmittel vollständig angegeben habe und
    dass ich die Stellen der Arbeit -- einschließlich Tabellen, Karten und
    Abbildungen --, die anderen Werken oder dem Internet im Wortlaut oder dem
    Sinn nach entnommen sind, auf jeden Fall unter Angabe der Quelle als
    Entlehnung kenntlich gemacht habe. Ich erkläre weiters, dass ich mich
    generativer KI-Tools lediglich als Hilfsmittel bedient habe. Im Kapitel „AI
    usage" habe ich alle generativen KI-Tools gelistet, die verwendet wurden,
    und angegeben, wo, wie und wann sie verwendet wurden.]

  [= Declaration of Authorship]

  [I hereby declare that I have authored this thesis independently, that I have
    fully cited all sources and resources used, and that I have clearly
    identified as borrowings all parts of the work -- including tables, maps,
    and figures -- that have been taken from other works or the internet,
    whether in wording or in substance, in each case indicating the source. I
    further declare that I have used generative AI tools solely for revising
    text that I have written myself. In the chapter 'AI usage,' I have listed
    all generative AI tools used and specified where, how and when they were
    applied.]

  v(2cm)

  grid(
    columns: (1fr, 5cm),
    align(left + horizon)[#info.location, #date-str],
    align(
      right,
      stack(
        spacing: 2pt,
        line(length: 100%),
        info.author,
        text(size: 9pt)[(Unterschrift Verfasser/in)],
      ),
    ),
  )

  pagebreak()
}

/// Generate abstract pages (English Abstract + German Kurzfassung).
///
/// -> content
#let make-abstract(
  /// English abstract body.
  /// -> content
  en: [],
  /// German Kurzfassung body.
  de: [],
  /// -> content
) = {
  set heading(numbering: none, outlined: false)

  [= Abstract]
  en

  pagebreak()

  [= Kurzfassung]
  de

  pagebreak()
}

/// Generate an optional acknowledgements page.
///
/// -> content
#let make-acknowledgements(
  /// Acknowledgements text.
  /// -> content
  body,
) = {
  set heading(numbering: none, outlined: false)

  [= Acknowledgements]
  body

  pagebreak()
}

/// Main thesis show rule. Apply with `#show: thesis.with(info: info)`.
#let thesis(
  /// Thesis metadata. Use `default-info` as base. Language is read from `info.lang`.
  /// -> dict
  info: default-info,
  /// Equation numbering pattern, e.g. `"(1)"`.
  /// -> str
  eq-numbering: none,
  /// Ordered font fallback list.
  /// -> array
  main-font: (
    "New Computer Modern Sans",
    "Liberation Sans",
    "DejaVu Sans",
    "Latin Modern Sans",
  ),
  /// Paper size string, default `"a4"`.
  /// -> str
  page-paper: "a4",
  /// Margin dict with keys `top`, `bottom`, `left`, `right`.
  /// -> dict
  page-margins: (top: 22mm, bottom: 22mm, left: 24mm, right: 24mm),
  doc,
) = {
  set page(
    paper: page-paper,
    margin: page-margins,
  )

  set text(font: main-font, lang: info.at("lang", default: "de"))
  set heading(numbering: "1.1 ")
  set math.equation(numbering: eq-numbering)

  show heading: set block(below: 1em)
  show heading.where(level: 1, outlined: true): it => {
    set block(below: 2em, above: 4em)
    pagebreak(weak: true)
    it
  }

  show outline.entry.where(level: 1): it => strong(it)
  show outline: it => {
    show heading: set text(fill: black)
    set text(fill: tu-blue)
    it
  }
  show link: set text(fill: tu-blue)
  show cite: set text(fill: forrest-green)

  set enum(spacing: 5pt, indent: 1.5em)
  set list(spacing: 5pt, indent: 1.5em)

  doc
}
