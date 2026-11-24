// Transparency statement on the use of GenAI.
//
// Text taken verbatim from the LaTeX repository:
//   src/transparency-statement-en.tex
//   src/transparantieverklaring-nl.tex
// which are themselves transcribed from the KU Leuven source document
//   GenAI_Transparency Statement Students_AY2627.docx
//
// When KU Leuven revises that document, update BOTH LaTeX files and this one,
// and bump `academic-year` below.
//
// Filling it in: change `tick: ("thesis", "used")` etc. on the template call,
// or edit the `checked` arguments here. A ticked box is an X, as in the LaTeX
// version (\tvBox -> \tvTick).

#let strings = (
  en: (
    title: "Transparency statement on the use of GenAI for KU Leuven students",
    running: "Transparency statement",
    toc: "Transparency statement on GenAI use",
    principles: "kuleuven.be/english/genai/principles",
    bullets: (
      "Complete the transparency statement based on the Code of Conduct for GenAI use by students and the principles and guidelines (LINK) for GenAI use at KU Leuven.",
      "BOLDSpecific instructions from your teaching staff or faculty take precedenceBOLD over the university-wide code of conduct and guidelines.",
      "By completing this document, you acknowledge that you have read the code of conduct and guidelines and have used them to fill in this transparency statement.",
      "Below, you indicate yes/no for each type of GenAI use. In the bottom row of the table, specify any GenAI use that does not fall under the other categories (or is a combination of them).",
      "Where the code of conduct states that you do not need to cite a particular type of GenAI use, this refers to citations within your work itself. However, you must of course still mention the relevant GenAI use in this transparency statement.",
    ),
    student-name: "Student name:",
    student-number: "Student number:",
    indicate-kind: "Please indicate with “X” whether it relates to a course assignment or to your Bachelor's or Master's thesis:",
    course-assignment-pre: "This form is related to a ",
    course-assignment-bold: "course assignment",
    course-name: "Course name:",
    course-number: "Course number:",
    thesis-line-pre: "This form is related to my ",
    bachelor: "Bachelor's",
    or-word: " or ",
    master-thesis: "Master's thesis",
    thesis-title: "Thesis title:",
    supervisor: "Supervisor:",
    daily-supervisor: "Daily supervisor:",
    indicate: "Please indicate with “X”:",
    not-used-bold: "I did not use",
    not-used-rest: " any GenAI assistance tool.",
    used-bold: "I did use",
    used-rest: " GenAI assistance. In this case ",
    used-bold2: "specify which tools",
    used-rest2: " (e.g. Microsoft Copilot, ChatGPT, …) and describe your usage where necessary:",
    col1: "GenAI assistance used as/for:",
    col2: "Yes/No",
    col3: "Name of the GenAI tool(s) used.",
    col3-note: "If helpful, also describe in which way you were using GenAI related to what is specified in the code of conduct and guidelines.",
    yes: "Yes",
    no: "No",
    categories: (
      ("As a search engine to get information on a topic or to search for existing research on the topic", none),
      ("For generating new (research) ideas", none),
      ("For literature search", "finding sources"),
      ("As a language assistant for reviewing or improving texts I wrote myself", none),
      ("For translation aid to improve texts I wrote myself or to better understand text from others", none),
      ("As a paraphrasing tool", "rewriting words within a sentence"),
      ("For generating programming code", none),
      ("For generating synthetic data", none),
      ("For generating visuals, video or audio", none),
      ("For generating blocks of text", "other than the allowed use without referencing mentioned above"),
      ("Other use", "this may also include a combination of types of use mentioned above"),
    ),
  ),
  nl: (
    title: "Transparantieverklaring voor het gebruik van GenAI door KU Leuven-studenten",
    running: "Transparantieverklaring",
    toc: "Transparantieverklaring GenAI-gebruik",
    principles: "kuleuven.be/genai",
    bullets: (
      "Vul de transparantieverklaring in aan de hand van de Gedragscode voor GenAI-gebruik door studenten en de principes en richtlijnen (LINK) voor GenAI-gebruik aan KU Leuven.",
      "BOLDSpecifieke instructies van je docent of faculteit hebben voorrangBOLD op de universiteitsbrede gedragscode en richtlijnen.",
      "Door het invullen van dit document erken je de gedragscode en richtlijnen te hebben gelezen en te hebben gebruikt voor het invullen van deze transparantieverklaring.",
      "Je vinkt hieronder voor elk type gebruik ja/neen aan. In de onderste rij van de tabel vul je het GenAI-gebruik in dat niet onder de overige categorieën valt (of er een combinatie van is).",
      "Waar de gedragscode stelt dat je niet hoeft te verwijzen naar een bepaald type GenAI-gebruik, heeft dit betrekking op verwijzingen in je werk zelf. Het betrokken GenAI-gebruik vermeld je uiteraard wel in deze transparantieverklaring.",
    ),
    student-name: "Naam student:",
    student-number: "Studentennummer:",
    indicate-kind: "Geef aan met “X” of het om een opdracht of bachelor-/masterproef gaat:",
    course-assignment-pre: "Deze verklaring hoort bij een ",
    course-assignment-bold: "opdracht",
    course-name: "Naam opleidingsonderdeel:",
    course-number: "Vakcode:",
    thesis-line-pre: "Deze verklaring hoort bij mijn ",
    bachelor: "bachelorproef",
    or-word: " of ",
    master-thesis: "masterproef",
    thesis-title: "Titel proef:",
    supervisor: "Promotor:",
    daily-supervisor: "Dagelijkse begeleider:",
    indicate: "Geef aan met “X”:",
    not-used-bold: "Ik heb geen GenAI-tool gebruikt.",
    not-used-rest: "",
    used-bold: "Ik heb een GenAI-tool gebruikt.",
    used-rest: " In dit geval, geef aan ",
    used-bold2: "welke tool(s)",
    used-rest2: " (bijv. Copilot, ChatGPT, …) en omschrijf waar nodig je gebruik:",
    col1: "GenAI-tool gebruikt als/voor:",
    col2: "Ja/Neen",
    col3: "Naam van de gebruikte GenAI-tool.",
    col3-note: "Indien nodig, omschrijf hoe je GenAI gebruikte; gebruik hiervoor de gedragscode en richtlijnen.",
    yes: "Ja",
    no: "Neen",
    categories: (
      ("Als een zoekmachine om informatie te vinden over een topic of om hierover bestaand onderzoek te vinden", none),
      ("Voor het genereren van nieuwe (onderzoeks)ideeën", none),
      ("Voor literatuuronderzoek", "opzoeken bronnen"),
      ("Als taalhulp voor het nakijken of verbeteren van zelfgeschreven teksten", none),
      ("Als vertaalhulp om teksten te verbeteren die je zelf schreef of om teksten van anderen beter te begrijpen", none),
      ("Als parafraseertool", "herformuleren van woorden uit een zin"),
      ("Voor het genereren van programmeercode", none),
      ("Voor het genereren van synthetische data", none),
      ("Voor het genereren van beeldmateriaal, video of audio", none),
      ("Voor het genereren van tekstblokken", none),
      ("Overig gebruik", "het kan ook gaan om een combinatie van bovenstaande vormen"),
    ),
  ),
)

// --- helpers, mirroring \tvBox, \tvTick and \tvBlank -----------------------

#let tv-box(checked: false) = box(
  width: 1.05em,
  height: 0.8em,
  baseline: 0.08em,
  stroke: 0.6pt,
  align(center + horizon, if checked { text(size: 0.85em)[X] } else { [] }),
)

#let tv-blank(value: none) = box(
  width: 1fr,
  baseline: 0.15em,
  if value == none {
    line(length: 100%, stroke: 0.6pt)
  } else {
    stack(spacing: 0.15em, value, line(length: 100%, stroke: 0.6pt))
  },
)

#let field(label, value: none, label-width: 32%) = block(
  above: 0pt,
  below: 0.55em,
  grid(
    columns: (label-width, 1fr),
    align: (left + bottom, bottom),
    strong(label), tv-blank(value: value),
  ),
)

// "BOLD...BOLD" marks the bold run inside a bullet; "LINK" is the principles
// URL. Keeping the bullets as plain strings makes them diffable against the
// .tex sources.
#let render-bullet(s, principles) = {
  let parts = s.split("BOLD")
  let out = []
  let i = 0
  for part in parts {
    let piece = if part.contains("LINK") {
      let seg = part.split("LINK")
      seg.at(0) + raw(principles) + seg.at(1)
    } else { part }
    out = out + (if calc.odd(i) { strong(piece) } else { piece })
    i += 1
  }
  out
}

#let year-range(academic-year) = {
  if type(academic-year) == array {
    [#academic-year.at(0)#sym.dash.en#academic-year.at(1)]
  } else {
    [#academic-year#sym.dash.en#(academic-year + 1)]
  }
}

/// Insert the transparency statement.
///
/// `ticks` is a dictionary of boxes to tick, any of:
///   "course-assignment", "bachelor", "master-thesis", "not-used", "used"
/// `answers` fills the rules: student-name, student-number, course-name,
///   course-number, thesis-title, supervisor, daily-supervisor
/// `uses` maps a category index (0-10) to "yes" or "no".
/// -> content
#let insert-transparency-statement(
  academic-year: 2026,
  lang: "en",
  ticks: (),
  answers: (:),
  uses: (:),
) = {
  let s = strings.at(if lang == "nl" { "nl" } else { "en" })
  let head = {
    set text(size: 0.9em)
    smallcaps(s.running)
    line(length: 100%, stroke: 0.6pt)
  }

  set page(header: context {
    if calc.even(counter(page).get().at(0)) {
      align(left, head)
    } else {
      align(right, head)
    }
  })

  // kulemt uses \chapter*{long} + \addcontentsline{toc}{chapter}{short}.
  // Typst has no short-title mechanism, so the long title appears in both.
  heading(
    level: 1,
    numbering: none,
    outlined: true,
  )[#s.title (#(if lang == "nl" { "academiejaar" } else { "academic year" }) #year-range(academic-year))]

  set par(justify: true)

  list(..s.bullets.map(b => render-bullet(b, s.principles)))

  v(0.8em)
  field(s.student-name, value: answers.at("student-name", default: none))
  field(s.student-number, value: answers.at("student-number", default: none))

  v(0.4em)
  strong(s.indicate-kind)
  block(above: 0.7em, below: 0.7em)[
    #tv-box(checked: "course-assignment" in ticks)
    #s.course-assignment-pre#strong(s.course-assignment-bold).
  ]

  field(s.course-name, value: answers.at("course-name", default: none))
  field(s.course-number, value: answers.at("course-number", default: none))

  v(0.4em)
  block(below: 0.7em)[
    #s.thesis-line-pre#tv-box(checked: "bachelor" in ticks) #strong(s.bachelor)#s.or-word#tv-box(checked: "master-thesis" in ticks) #strong(s.master-thesis).
  ]

  field(s.thesis-title, value: answers.at("thesis-title", default: none))
  field(s.supervisor, value: answers.at("supervisor", default: none))
  field(s.daily-supervisor, value: answers.at("daily-supervisor", default: none))

  v(0.6em)
  strong(s.indicate)
  block(above: 0.7em, below: 0.5em)[
    #tv-box(checked: "not-used" in ticks) #strong(s.not-used-bold)#s.not-used-rest
  ]
  block(below: 0.9em)[
    #tv-box(checked: "used" in ticks) #strong(s.used-bold)#s.used-rest#strong(s.used-bold2)#s.used-rest2
  ]

  let yes-no(i) = {
    set par(leading: 0.9em, justify: false)
    let a = uses.at(str(i), default: none)
    [#tv-box(checked: a == "yes") #s.yes #linebreak() #tv-box(checked: a == "no") #s.no]
  }

  let cell(entry) = {
    set par(justify: false)
    entry.at(0)
    if entry.at(1) != none {
      linebreak()
      emph("(" + entry.at(1) + ")")
    }
  }

  let rows = ()
  let i = 0
  for entry in s.categories {
    rows.push(cell(entry))
    rows.push(yes-no(i))
    rows.push([])
    i += 1
  }

  table(
    columns: (1fr, 4.6em, 0.82fr),
    align: left + top,
    inset: 6pt,
    stroke: 0.6pt,
    table.header(
      strong(s.col1),
      strong(s.col2),
      {
        strong(s.col3)
        parbreak()
        set text(size: 0.85em, weight: "regular")
        s.col3-note
      },
    ),
    ..rows
  )
}
