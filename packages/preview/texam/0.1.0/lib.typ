// texam — Standalone exam page-layout template
// Provides cover page, header/footer, name box, draft page, and a
// #show: texam.with(...) template function. No exercise-bank dependency.

// =============================================================================
// State
// =============================================================================

// Collects (label, points) from every #exam-question call; read via .final()
#let _question-registry = state("texam-question-registry", ())

#let exam-state = state("exam-state", (
  school-name: "Collège",
  course-code: "",
  show-header-on-first-page: false,
  title: "Épreuve de mathématiques",
  date: "",
  teacher: "",
  teacher-initials: "",
  duration: "",
  allowed-materials: "Aucun",
  extras: ((label: "PNF", points: 2),),
  show-corrections: false,
  correction-box-label: "Correction",
  correction-box-fill: rgb("#e8f5e9"),
  correction-box-stroke: 0.8pt + rgb("#4a7c59"),
  correction-box-radius: 3pt,
  correction-box-inset: 8pt,
  correction-box-label-color: rgb("#2e5a3a"),
  instructions: [
    - Il sera tenu compte de la présentation ainsi que de l'utilisation correcte des notations mathématiques et du français (PNF).
    - Tous les calculs et raisonnements doivent figurer sur la feuille, une réponse non justifiée ne sera pas prise en considération.
    - Écrire au crayon ou au stylo bleu/noir uniquement. Sauf indication contraire, on travaille dans $RR$.
  ],
  // Localizable labels
  question-label: "Question",
  point-label: "point",
  points-label: "points",
  name-label: "Nom, prénom :",
  group-label: "Groupe :",
  page-label: "Page",
  of-label: "sur",
  end-label: "Fin de l'évaluation",
  brouillon-label: "BROUILLON",
  brouillon-instruction: "Rendre le brouillon avec le travail, aucune autre feuille de brouillon n'est autorisée",
  correction-label: "Corrigé",
  // Info table labels
  date-label: "Date :",
  course-label: "Cours :",
  teacher-label: "Enseignant :",
  duration-label: "Temps à disposition :",
  materials-label: "Matériel autorisé :",
  pages-label: "Nombre de pages :",
  instructions-label: "Consignes générales :",
  // Evaluation table labels
  eval-question-label: "Question",
  eval-points-label: "Points",
  eval-obtained-label: "Points obtenus",
  eval-total-label: "Total",
))

// =============================================================================
// Setup
// =============================================================================

#let exam-setup(
  school-name: none,
  course-code: none,
  show-header-on-first-page: none,
  title: none,
  date: none,
  teacher: none,
  teacher-initials: none,
  duration: none,
  allowed-materials: none,
  extras: none,
  show-corrections: none,
  correction-box-label: none,
  correction-box-fill: none,
  correction-box-stroke: none,
  correction-box-radius: none,
  correction-box-inset: none,
  correction-box-label-color: none,
  instructions: none,
  // label overrides
  question-label: none,
  point-label: none,
  points-label: none,
  name-label: none,
  group-label: none,
  page-label: none,
  of-label: none,
  end-label: none,
  brouillon-label: none,
  brouillon-instruction: none,
  correction-label: none,
  date-label: none,
  course-label: none,
  teacher-label: none,
  duration-label: none,
  materials-label: none,
  pages-label: none,
  instructions-label: none,
  eval-question-label: none,
  eval-points-label: none,
  eval-obtained-label: none,
  eval-total-label: none,
) = {
  exam-state.update(s => {
    let n = s
    if school-name != none { n.school-name = school-name }
    if course-code != none { n.course-code = course-code }
    if show-header-on-first-page != none { n.show-header-on-first-page = show-header-on-first-page }
    if title != none { n.title = title }
    if date != none { n.date = date }
    if teacher != none { n.teacher = teacher }
    if teacher-initials != none { n.teacher-initials = teacher-initials }
    if duration != none { n.duration = duration }
    if allowed-materials != none { n.allowed-materials = allowed-materials }
    if extras != none { n.extras = extras }
    if show-corrections != none { n.show-corrections = show-corrections }
    if correction-box-label != none { n.correction-box-label = correction-box-label }
    if correction-box-fill != none { n.correction-box-fill = correction-box-fill }
    if correction-box-stroke != none { n.correction-box-stroke = correction-box-stroke }
    if correction-box-radius != none { n.correction-box-radius = correction-box-radius }
    if correction-box-inset != none { n.correction-box-inset = correction-box-inset }
    if correction-box-label-color != none { n.correction-box-label-color = correction-box-label-color }
    if instructions != none { n.instructions = instructions }
    if question-label != none { n.question-label = question-label }
    if point-label != none { n.point-label = point-label }
    if points-label != none { n.points-label = points-label }
    if name-label != none { n.name-label = name-label }
    if group-label != none { n.group-label = group-label }
    if page-label != none { n.page-label = page-label }
    if of-label != none { n.of-label = of-label }
    if end-label != none { n.end-label = end-label }
    if brouillon-label != none { n.brouillon-label = brouillon-label }
    if brouillon-instruction != none { n.brouillon-instruction = brouillon-instruction }
    if correction-label != none { n.correction-label = correction-label }
    if date-label != none { n.date-label = date-label }
    if course-label != none { n.course-label = course-label }
    if teacher-label != none { n.teacher-label = teacher-label }
    if duration-label != none { n.duration-label = duration-label }
    if materials-label != none { n.materials-label = materials-label }
    if pages-label != none { n.pages-label = pages-label }
    if instructions-label != none { n.instructions-label = instructions-label }
    if eval-question-label != none { n.eval-question-label = eval-question-label }
    if eval-points-label != none { n.eval-points-label = eval-points-label }
    if eval-obtained-label != none { n.eval-obtained-label = eval-obtained-label }
    if eval-total-label != none { n.eval-total-label = eval-total-label }
    n
  })
}

// =============================================================================
// Header and Footer
// =============================================================================

#let exam-header() = context {
  let s = exam-state.get()
  let current = counter(page).at(here()).first()
  if current > 1 or s.show-header-on-first-page {
    grid(
      columns: (1fr, auto),
      align: (left + top, right + top),
      [#s.school-name],
      [#s.course-code],
    )
    line(length: 100%, stroke: 0.8pt + luma(60))
  }
}

#let exam-footer() = context {
  let s = exam-state.get()
  let current = counter(page).at(here()).first()
  let total = counter(page).final().first()
  align(right)[#s.page-label #current #s.of-label #total]
}

// =============================================================================
// Page Setup
// =============================================================================

#let exam-page-setup(
  margin-top: 2.1cm,
  margin-bottom: 2.3cm,
  margin-left: 2.3cm,
  margin-right: 2.3cm,
) = {
  set page(
    margin: (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right),
    header: exam-header(),
    footer: exam-footer(),
  )
}

// =============================================================================
// Name/Group Box
// =============================================================================

#let exam-name-box(
  stroke: 0.8pt + luma(40),
  radius: 10pt,
  inset-x: 12pt,
  inset-y: 14pt,
  group-width: 2.5cm,
) = context {
  let s = exam-state.get()
  box(
    width: 100%,
    stroke: stroke,
    radius: radius,
    inset: (x: inset-x, y: inset-y),
    grid(
      columns: (auto, 1fr, auto, group-width),
      column-gutter: 4pt,
      align: left + bottom,
      [#s.name-label], box(width: 100%)[#repeat[. ]],
      [#s.group-label], box(width: 100%)[#repeat[. ]],
    )
  )
}

// =============================================================================
// Info Table
// =============================================================================

#let exam-info-table(
  date: "",
  course: "",
  teacher: "",
  duration: "",
  allowed-materials: "Aucun",
  instructions: none,
) = context {
  let s = exam-state.get()
  let total-pages = counter(page).final().first()
  let _instructions = if instructions != none { instructions } else { s.instructions }

  table(
    stroke: none,
    columns: (auto, 1fr),
    gutter: 10pt,
    align: (left + top, left + top),
    row-gutter: 7pt,
    [*#s.date-label*], [#date],
    [*#s.course-label*], [#course],
    [*#s.teacher-label*], [#teacher],
    [*#s.duration-label*], [#duration],
    [*#s.materials-label*], [#allowed-materials],
    [*#s.pages-label*], [#total-pages],
    [*#s.instructions-label*], _instructions,
  )
}

// =============================================================================
// Evaluation Table
// Takes explicit question data — no registry dependency.
// questions: array of dicts with keys `label` (str) and `points` (int)
// =============================================================================

#let exam-evaluation-table(
  questions: auto,
  extras: auto,
) = context {
  let s = exam-state.get()
  let qs = if questions == auto { _question-registry.final() } else { questions }
  let _extras = if extras == auto { s.extras } else { extras }
  let total = qs.fold(0, (acc, q) => acc + q.points) + _extras.fold(0, (acc, e) => acc + e.points)

  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    stroke: 0.7pt + luma(40),
    inset: 8pt,
    table.header(
      [*#s.eval-question-label*], [*#s.eval-points-label*], [*#s.eval-obtained-label*],
    ),
    ..qs.map(q => (q.label, str(q.points), [])).flatten(),
    .._extras.map(e => ([#e.label], [#str(e.points)], [])).flatten(),
    [*#s.eval-total-label*], [*#total*], [],
  )
}

// =============================================================================
// Note Box
// =============================================================================

#let exam-note-box(
  width: 3.5cm,
  height: 2cm,
  stroke: 1pt + luma(20),
  radius: 6pt,
  label: "Note :",
) = {
  box(
    width: width,
    height: height,
    stroke: stroke,
    radius: radius,
    inset: 6pt,
    align(left + horizon)[#text(size: 12pt)[#label]]
  )
}

// =============================================================================
// Question Display
// =============================================================================

#let exam-question(number, points, body) = {
  _question-registry.update(qs => qs + ((label: str(number), points: int(points)),))
  context {
    let s = exam-state.get()
    let pts-label = if points == 1 { s.point-label } else { s.points-label }
    v(0pt, weak: true)
    [#text(weight: "bold")[#s.question-label #number.] #[[#points #pts-label]]]
    v(0.2em)
    set par(first-line-indent: 0pt)
    body
    v(0.8em, weak: true)
  }
}

// =============================================================================
// Correction Box
// Only rendered when show-corrections: true (set via exam-setup or texam).
// Styled identically to exercise-bank's exam-solution-box for consistency.
// =============================================================================

#let exam-correction-box(body) = context {
  let s = exam-state.get()
  if s.show-corrections {
    v(s.correction-box-inset / 2)
    block(
      width: 100%,
      inset: s.correction-box-inset,
      fill: s.correction-box-fill,
      stroke: s.correction-box-stroke,
      radius: s.correction-box-radius,
    )[
      #text(weight: "bold", fill: s.correction-box-label-color)[#s.correction-box-label :]
      #v(4pt)
      #body
    ]
    v(s.correction-box-inset / 2, weak: true)
  }
}

// =============================================================================
// Title Block
// =============================================================================

#let exam-title(
  school-name: none,
  title: none,
  title-size: 20pt,
) = context {
  let s = exam-state.get()
  let school = if school-name != none { school-name } else { s.school-name }
  let _title = if title != none { title } else { s.title }

  align(center)[
    #text(weight: "bold")[#school]
    #v(0.15em)
    #text(size: title-size, weight: "bold")[#_title]
  ]
}

// =============================================================================
// Brouillon Page
// =============================================================================

#let _generate-brouillon-code(prefix) = {
  let d = datetime.today()
  let seed = d.day() * 1327 + d.month() * 4973 + d.year() * 7
  let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
  let c1 = chars.at(calc.rem(seed, chars.len()))
  let c2 = chars.at(calc.rem(int(seed / 31) + 13, chars.len()))
  let c3 = chars.at(calc.rem(int(seed / 97) + 7, chars.len()))
  prefix + c1 + c2 + c3
}

#let exam-brouillon-page(
  code: auto,
) = context {
  let s = exam-state.get()
  let _code = if code == auto {
    _generate-brouillon-code(s.course-code)
  } else {
    code
  }

  pagebreak(to: "odd")

  align(right)[
    #text(weight: "bold")[#s.brouillon-label]
    #if _code != none {
      h(1em)
      box(stroke: 0.8pt + luma(30), inset: 3pt)[#_code]
    }
  ]
  v(0.8em)
  grid(
    columns: (auto, 1fr, auto, 1fr, auto, 1fr),
    column-gutter: 6pt,
    align: left + bottom,
    [Nom :], box(width: 100%)[#repeat[.]],
    [Prénom :], box(width: 100%)[#repeat[.]],
    [Groupe :], box(width: 100%)[#repeat[.]],
  )
  v(0.6em)
  box(
    width: 100%,
    stroke: 0.8pt + luma(30),
    inset: 8pt,
    text(style: "italic")[#s.brouillon-instruction],
  )
}

// =============================================================================
// End Page
// =============================================================================

#let exam-end-page() = context {
  let s = exam-state.get()
  v(1fr)
  align(center + bottom)[#text(weight: "bold")[#s.end-label]]
}

// =============================================================================
// Cover Page
// questions: array of (label: str, points: int) — built by the caller from
//            the exercise registry or passed manually.
// =============================================================================

#let exam-cover-page(
  title: auto,
  date: auto,
  course: auto,
  teacher: auto,
  duration: auto,
  allowed-materials: auto,
  instructions: auto,
  questions: auto,
  extras: auto,
) = context {
  let s = exam-state.get()

  let _title    = if title == auto { s.title } else { title }
  let _date     = if date == auto { s.date } else { date }
  let _course   = if course == auto { s.course-code } else { course }
  let _teacher  = if teacher == auto { s.teacher } else { teacher }
  let _duration = if duration == auto { s.duration } else { duration }
  let _allowed  = if allowed-materials == auto { s.allowed-materials } else { allowed-materials }
  let _instr    = if instructions == auto { s.instructions } else { instructions }
  let _qs       = if questions == auto { _question-registry.final() } else { questions }
  let _extras   = if extras == auto { s.extras } else { extras }

  exam-title(title: _title)
  v(0.8em)
  exam-name-box()
  v(1em)

  grid(
    columns: (auto, 1fr),
    column-gutter: 1.5em,
    row-gutter: 1em,
    align: (left + top, left + top),
    [*#s.date-label*], [#_date],
    [*#s.course-label*], [#_course],
    [*#s.teacher-label*], [#_teacher],
    [*#s.duration-label*], [#_duration],
    [*#s.materials-label*], [#_allowed],
    [*#s.pages-label*], [#counter(page).final().first()],
    [*#s.instructions-label*], _instr,
  )

  v(0.6em)

  grid(
    columns: (auto, 1fr),
    column-gutter: 1.5em,
    align: (left + top, left + top),
    [*Évaluation :*], grid(
      columns: (auto, auto),
      column-gutter: 2cm,
      align: horizon,
      exam-evaluation-table(questions: _qs, extras: _extras),
      exam-note-box(),
    ),
  )
}

// =============================================================================
// Correction Cover
// =============================================================================

#let exam-correction-cover(
  title: auto,
  date: auto,
  course: auto,
  questions: auto,
  extras: auto,
) = context {
  let s = exam-state.get()

  let _title   = if title == auto { s.title } else { title }
  let _date    = if date == auto { s.date } else { date }
  let _course  = if course == auto { s.course-code } else { course }
  let _qs      = if questions == auto { _question-registry.final() } else { questions }
  let _extras  = if extras == auto { s.extras } else { extras }

  let questions-total = _qs.fold(0, (acc, q) => acc + q.points)
  let extras-total    = _extras.fold(0, (acc, e) => acc + e.points)
  let grand-total     = questions-total + extras-total

  let extras-str = if _extras.len() == 0 {
    ""
  } else {
    " + " + _extras.map(e => str(e.points) + " " + e.label).join(" + ") + " = " + str(grand-total)
  }

  align(center)[
    #text(size: 14pt, weight: "bold")[#s.correction-label - #_title]
    #v(0.3em)
    #text(size: 11pt)[#_course - #_date]
    #v(0.3em)
    #text(size: 10pt)[Total : #questions-total points#extras-str points]
  ]

  v(1em)
  line(length: 100%, stroke: 0.5pt)
  v(0.5em)
}

// =============================================================================
// Template Function
// Main entry point: #show: texam.with(...).
// The body contains the exam questions. The cover page is generated from the
// `questions` parameter — no exercise registry required.
// =============================================================================

#let texam(
  school: "",
  course-code: "",
  title: "Épreuve de mathématiques",
  date: none,
  teacher: none,
  teacher-initials: none,
  duration: "75 minutes",
  allowed-materials: "Aucun",
  instructions: none,
  pnf-points: 2,
  // questions for the evaluation table: auto (default) collects them from #exam-question calls.
  // Override with an explicit array only if not using #exam-question.
  questions: auto,
  // Extra rows after questions in the evaluation table (e.g. PNF, Présentation...).
  // Default: one PNF row worth 2 points. Pass () to remove, or customize freely.
  extras: ((label: "PNF", points: 2),),
  show-corrections: false,
  brouillon: true,
  brouillon-code: auto,
  show-header-on-first-page: false,
  margin: (top: 2.1cm, bottom: 2.3cm, left: 2.3cm, right: 2.3cm),
  body,
) = {
  // Normalize explicit questions array (plain ints → labelled dicts); pass through auto.
  let qs = if questions == auto {
    auto
  } else {
    questions.enumerate().map(((i, q)) => {
      if type(q) == int or type(q) == float {
        (label: str(i + 1), points: int(q))
      } else {
        q
      }
    })
  }

  exam-setup(
    school-name: school,
    course-code: course-code,
    title: title,
    date: if date != none { date } else { "" },
    teacher: if teacher != none { teacher } else { "" },
    teacher-initials: if teacher-initials != none { teacher-initials } else { "" },
    duration: duration,
    allowed-materials: allowed-materials,
    instructions: instructions,
    extras: extras,
    show-corrections: show-corrections,
    show-header-on-first-page: show-header-on-first-page,
  )

  set page(
    margin: margin,
    header: exam-header(),
    footer: exam-footer(),
  )

  exam-cover-page(questions: qs, extras: extras)
  pagebreak()
  body
  if brouillon {
    exam-brouillon-page(code: brouillon-code)
    pagebreak()
  }
  exam-end-page()
}
