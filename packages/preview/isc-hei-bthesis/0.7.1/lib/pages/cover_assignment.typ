// Rendering logic for the TB assignment sheet and its addendum.
// Called from src/tb_assignment.typ via the exported tb-assignment-page() function from lib/pages/cover_assignment.typ.
// P.-A. Mudry March, 2026

#import "../includes.typ" as inc

// Various project types
#let project-types = (exploratory: "exploratory", implementation: "implementation")

// Usage: hes(), industry("Acme Corp"), school("EPFL")
#let hes() = (type: "hes", label: none)
#let industry(name) = (type: "industry", label: name)
#let school(name)  = (type: "institution", label: name)

// ── Translations ───────────────────────────────────────────────────────
#let _i18n = (
  fr: (
    study-program: "Filière",
    academic-year: "Année académique",
    tb-number: "Référence du travail",
    mandator: "Mandant",
    expert: "Expert·e",
    location: "Lieu d'exécution",
    industry: "Industrie",
    institution: "Établissement partenaire",
    confidential: "Travail confidentiel",
    professor: "Professeur·e",
    co-supervisor: "Co-superviseur·e",
    yes: "oui",
    no: "non",
    date-version: "Date du document | version",
    title: "Titre",
    description: "Description",
    objectives: "Objectifs",
    signature: "Signature",
    deadlines: "Délais",
    responsible: "Responsable orientation | filière",
    student: "Étudiant·e",
    theme-attribution: "Attribution du thème",
    start-work: "Début du travail de bachelor",
    report-submission: "Remise du rapport final",
    oral-defense: "Défense orale",
    exhibitions: "Expositions des posters",
    pitch: "Pitch",
    document-title: "Donnée du travail de bachelor",
    addendum-title: "Addendum — Donnée du travail de bachelor",
    project-type: "Type de projet",
    exploratory: "Exploratoire",
    implementation: "Implémentation",
    data-dep: "Dépendances aux données",
    data-1: "Aucune donnée",
    data-2: "Données collectées, nettoyées et prêtes à l'emploi",
    data-3: "Données collectées, nettoyage nécessaire",
    data-4: "Données non collectées mais disponibles en ligne",
    data-5: "Données non collectées et dépendantes d'acteurs externes",
    data-placeholder: "Veuillez inclure une explication de l'effort nécessaire pour collecter et nettoyer les données. Pour le niveau 5, ajoutez un plan de secours.",
    material-dep: "Dépendances matérielles",
    material-1: "Aucun matériel spécifique nécessaire",
    material-2: "Matériel directement accessible sur place",
    material-3: "Matériel non directement accessible et devant être acquis",
    material-placeholder: "Veuillez indiquer quel matériel est nécessaire",
    material-cost: "Coût estimé",
    material-procedure: "Procédure d'achat et plan de secours",
    extra-info: "Informations complémentaires",
    extra-info-placeholder: "Si vous avez des informations supplémentaires à transmettre à l'équipe d'harmonisation.",
  ),
  en: (
    study-program: "Study programme",
    academic-year: "Academic year",
    tb-number: "Thesis reference",
    mandator: "Principal",
    expert: "Expert",
    location: "Place of execution",
    industry: "Industry",
    institution: "Partner institution",
    confidential: "Confidential work",
    professor: "Professor",
    co-supervisor: "Co-supervisor",
    yes: "yes",
    no: "no",
    date-version: "Date | version",
    title: "Title",
    description: "Description",
    objectives: "Objectives",
    signature: "Signature",
    deadlines: "Deadlines",
    responsible: "Head of programme | orientation",
    student: "Student",
    theme-attribution: "Theme attribution",
    start-work: "Start of bachelor thesis",
    report-submission: "Final report submission",
    oral-defense: "Oral defence",
    exhibitions: "Poster exhibitions",
    pitch: "Pitch challenge",
    document-title: "Bachelor thesis description",
    addendum-title: "Addendum — Bachelor thesis description",
    project-type: "Project type",
    exploratory: "Exploratory",
    implementation: "Implementation",
    data-dep: "Data dependencies",
    data-1: "No data",
    data-2: "Data collected, cleaned and ready to be used",
    data-3: "Data collected, cleaning needed",
    data-4: "Data not collected but available online",
    data-5: "Data not collected and dependent on external actors",
    data-placeholder: "Please include an explanation of the effort needed to collect the data and clean it. For level 5, add a presentation of the backup plan.",
    material-dep: "Material dependencies",
    material-1: "No specific material needed",
    material-2: "Material is readily accessible on-site",
    material-3: "Material is not readily accessible and needs to be acquired",
    material-placeholder: "Please mention what material/hardware is needed",
    material-cost: "Estimated cost",
    material-procedure: "Acquiring procedure and backup plan",
    extra-info: "Extra information",
    extra-info-placeholder: "If you have any more information about the project that you'd like to transmit to the harmonization team.",
  ),
  de: (
    study-program: "Studiengang",
    academic-year: "Akademisches Jahr",
    tb-number: "BA Nr.",
    mandator: "Auftraggeber",
    expert: "Expert·in",
    location: "Durchführungsort",
    industry: "Industrie",
    institution: "Partnerinstitution",
    confidential: "Vertrauliche Arbeit",
    professor: "Professor·in",
    co-supervisor: "Ko-Betreuer·in",
    yes: "ja",
    no: "nein",
    date-version: "Datum und Version",
    title: "Titel",
    description: "Beschreibung",
    objectives: "Ziele",
    signature: "Unterschrift",
    deadlines: "Fristen",
    responsible: "Verantwortliche·r Studiengang | Vertiefung",
    student: "Student·in",
    theme-attribution: "Themenzuweisung",
    start-work: "Beginn der Bachelorarbeit",
    report-submission: "Abgabe des Schlussberichts",
    oral-defense: "Mündliche Verteidigung",
    exhibitions: "Ausstellungen",
    pitch: "Pitch challenge",
    document-title: "Daten der Bachelorarbeit",
    addendum-title: "Addendum — Daten der Bachelorarbeit",
    project-type: "Projekttyp",
    exploratory: "Explorativ",
    implementation: "Implementierung",
    data-dep: "Datenabhängigkeiten",
    data-1: "Keine Daten",
    data-2: "Daten erhoben, bereinigt und einsatzbereit",
    data-3: "Daten erhoben, Bereinigung erforderlich",
    data-4: "Daten nicht erhoben, aber online verfügbar",
    data-5: "Daten nicht erhoben und von externen Akteuren abhängig",
    data-placeholder: "Bitte erläutern Sie den Aufwand für die Datenerhebung und -bereinigung. Für Stufe 5 fügen Sie einen Notfallplan bei.",
    material-dep: "Materialabhängigkeiten",
    material-1: "Kein spezifisches Material erforderlich",
    material-2: "Material vor Ort leicht zugänglich",
    material-3: "Material nicht leicht zugänglich und muss beschafft werden",
    material-placeholder: "Bitte geben Sie an, welches Material/Hardware benötigt wird.",
    material-cost: "Geschätzte Kosten",
    material-procedure: "Beschaffungsverfahren und Notfallplan",
    extra-info: "Zusätzliche Informationen",
    extra-info-placeholder: "Falls Sie weitere Informationen zum Projekt an das Harmonisierungsteam weitergeben möchten.",
  ),
)

// Helper to get translated document title
#let get-document-title(lang) = _i18n.at(lang, default: _i18n.fr).at("document-title")

#let tb-assignment-page(
  // Identity
  student:         "Prénom Nom",
  id:              "ISC-ID-xx-x",
  supervisor:      "Prof. Dr ...",
  co-supervisor:   none,
  expert:          "Dr ...",
  study-program: "ISC",
  academic-year: "20xx-xx",

  // Either hes(), industry("Acme Corp"), or school("EPFL")
  mandator: hes(),

  // Either hes(), industry("Acme Corp"), or school("EPFL")
  site: hes(),

  // Confidentiality
  confidential: false,

  // Content[
  title:       [Donnée du travail de bachelor],
  description: [Description du travail de bachelor.],
  objectives-content: [Objectifs du travail de bachelor.],

  // Dates (datetime objects for locale formatting)
  date-attribution:  none,
  date-start:        none,
  date-submission:   none,
  date-submission-time:  "12:00",     // time string appended after the date
  date-defense:      [Semaines xx et xx],        // free text
  date-exhibition-hei:     none,
  date-exhibition-hei-suffix: "HEI",
  date-exhibition-monthey: none,
  date-exhibition-monthey-suffix: "Monthey",

  // Addendum
  project-type:         "exploratory",
  data-dep:             1,
  data-explanation:     none,
  material-dep:         1,
  material-explanation: none,
  material-cost:        none,
  material-procedure:   none,
  extra-info:           none,

  // Document metadata
  doc-version: none,
  language: "fr",
) = {

  // ── Date formatter ─────────────────────────────────────────────────────
  let _langs = json("../../i18n.json")
  let _fmt = _langs.at(language, default: _langs.fr).at("date-format")
  let _fmtdate(d) = if d == none { "–" } else { inc.custom-date-format(d, pattern: _fmt, lang: language) }
  let _t = _i18n.at(language, default: _i18n.fr)

  // ── Style constants ────────────────────────────────────────────────────
  let _fill   = luma(235)
  let _ci     = (x: 6pt, y: 5pt)
  let _purple = inc.hei-purple
  let _stroke = 0.5pt + luma(160)

  let _lbl(body, ..args) = table.cell(
    fill: _fill, inset: _ci,
    text(weight: "bold", size: 9pt, body),
    ..args
  )

  let _val(body, ..args) = table.cell(
    inset: _ci,
    text(size: 9pt, body),
    ..args
  )

  let _checkbox(checked) = box(
    baseline: 18%,
    rect(
      width: 9pt, height: 9pt, radius: 1pt,
      fill: if checked { _purple } else { white },
      stroke: 0.5pt + if checked { _purple } else { luma(140) },
      if checked { place(center + horizon, text(white, size: 7pt)[✓]) }
    )
  )

  let _radio(n, selected) = {
    for i in range(1, n + 1) {
      box(
        baseline: 18%,
        circle(
          radius: 4.5pt,
          fill: if i == selected { _purple } else { white },
          stroke: 0.5pt + if i == selected { _purple } else { luma(140) },
        )
      )
      h(4pt)
      text(size: 9pt, str(i))
      h(12pt)
    }
  }

  let _resolve(val, default-industry, default-institution) = {
    let industry-label = if val.type == "industry" and val.label != none { val.label } else { default-industry }
    let institution-label = if val.type == "institution" and val.label != none { val.label } else { default-institution }
    (type: val.type, industry-label: industry-label, institution-label: institution-label)
  }

  let _m = _resolve(mandator, _t.industry, _t.institution)
  let _l = _resolve(site, _t.industry, _t.institution)

  place(
    top + right,
    dx: 0mm,
    dy: 1mm,
    text(size: 8pt, fill: luma(120))[FO 1.2.02.07.FB \ che/13.03.2024],
  )

  // Table 1 — informations générales
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: _stroke,

    _lbl[#_t.study-program], _lbl[#_t.academic-year], _lbl[#_t.tb-number],
    _val[#study-program], _val[#academic-year], _val[#id],

    _lbl[#_t.mandator], _lbl[#_t.expert], _lbl[#_t.location],
    table.cell(fill: white, inset: _ci)[
      #set text(size: 9pt)
      #_checkbox(_m.type == "hes") HES---SO Valais-Wallis \
      #_checkbox(_m.type == "industry") #_m.industry-label \
      #_checkbox(_m.type == "institution") #_m.institution-label
    ],
    _val[#expert],
    table.cell(fill: white, inset: _ci)[
      #set text(size: 9pt)
      #_checkbox(_l.type == "hes") HES---SO Valais-Wallis \
      #_checkbox(_l.type == "industry") #_l.industry-label \
      #_checkbox(_l.type == "institution") #_l.institution-label
    ],

    _lbl[#_t.confidential], _lbl[#_t.professor], _lbl[#_t.co-supervisor],
    table.cell(fill: white, inset: _ci)[
      #set text(size: 9pt)
      #_checkbox(confidential) #_t.yes #h(1em)
      #_checkbox(not confidential) #_t.no
    ],
    _val(align: horizon)[#supervisor],
    _val(align: horizon)[#{ if co-supervisor != none { co-supervisor } else { sym.dash.em } }],

    // Row 7 — Date et version (single row: label col 1, values cols 2-3)
    _lbl[#_t.date-version],
    table.cell(fill: white, inset: _ci, colspan: 2)[
      #set text(size: 9pt)
      #_fmtdate(datetime.today()) - v#doc-version
    ],
  )

  v(0.6em)

  // Table 2 — titre, description, objectifs (flexible height)
  block(width: 100%, height: 1fr,
    table(
      columns: (auto, 1fr),
      rows: (auto, 1fr, 1fr),
      stroke: _stroke,
      _lbl[#_t.title],       _val[#text(size: 11pt, weight: "semibold", title)],
      _lbl[#_t.description], _val[#description],
      _lbl[#_t.objectives],   _val[#objectives-content],
    )
  )

  v(0.6em)

  // Table 3 — signatures + délais
  table(
    columns: (1fr, 1fr, 2fr),
    stroke: _stroke,
    table.cell(colspan: 2, fill: _fill, inset: _ci)[#text(weight: "bold", size: 9pt)[#_t.signature]],
    table.cell(fill: _fill, inset: _ci, align: horizon)[#text(weight: "bold", size: 9pt)[#_t.deadlines]],

    table.cell(fill: white, inset: _ci, align: top)[
      #set text(size: 8pt)
      #_t.responsible
      #v(2em)
    ],

    table.cell(fill: white, inset: _ci, align: top)[
      #set text(size: 8pt)
      #_t.student
      #v(2em)
    ],

    table.cell(fill: white, inset: _ci, align: horizon)[
      #set text(size: 9pt)
      #_t.theme-attribution : #h(1fr) *#_fmtdate(date-attribution)* \
      #_t.start-work : #h(1fr) *#_fmtdate(date-start)* \
      #_t.report-submission : #h(1fr) *#{ _fmtdate(date-submission) + " " + if date-submission-time != none [#date-submission-time] else [] }* \
      #_t.oral-defense : #h(1fr) *#date-defense* \
      #_t.exhibitions : #h(1fr) *#{ _fmtdate(date-exhibition-hei) + " - " + date-exhibition-hei-suffix }* \
      #_t.pitch : #h(1fr) *#{ _fmtdate(date-exhibition-monthey) + " - " + date-exhibition-monthey-suffix }*
    ],
  )

  // ── PAGE 2 : Addendum ─────────────────────────────────────────────────
  pagebreak()

  block(fill: none, inset: (x: 0pt, bottom: 0.5em, top: 0pt),
    text(size: 1.5em * 1.5, weight: 700)[#_t.addendum-title]
  )

  // Inner legend tables: light grey row separators (top + bottom), no side borders
  let _legend-stroke = (left: none, right: none, top: 0.3pt + luma(210), bottom: 0.3pt + luma(210))

  block(width: 100%, height: 1fr,
  table(
    columns: (auto, 1fr),
    rows: (auto, auto, auto, 1fr),
    align: (left + horizon, left + horizon),
    stroke: _stroke,

    // ── Type de projet ───────────────────────────────────────────────────
    _lbl[#_t.project-type],
    _val[
      #_checkbox(project-type == "exploratory") #_t.exploratory #h(2.5em)
      #_checkbox(project-type == "implementation") #_t.implementation
    ],

    // ── Data dependencies ────────────────────────────────────────────────
    table.cell(fill: _fill, inset: _ci, align: left + top)[#text(weight: "bold", size: 9pt)[#_t.data-dep]],
    table.cell(fill: white, inset: _ci, align: left + top)[
      #set text(size: 9pt)
      #_radio(5, data-dep)
      #v(0.3em)
      #table(
        columns: (auto, 1fr),
        stroke: _legend-stroke,
        inset: (x: 6pt, y: 4pt),
        align: (center, left),
        text(size: 9pt, weight: "bold")[1], text(size: 9pt)[#_t.data-1],
        text(size: 9pt, weight: "bold")[2], text(size: 9pt)[#_t.data-2],
        text(size: 9pt, weight: "bold")[3], text(size: 9pt)[#_t.data-3],
        text(size: 9pt, weight: "bold")[4], text(size: 9pt)[#_t.data-4],
        text(size: 9pt, weight: "bold")[5], text(size: 9pt)[#_t.data-5],
      )
      #if data-dep >= 3 {
        v(0.4em)
        if data-explanation != none {
          data-explanation
        } else {
          text(style: "italic", size: 9pt)[#_t.data-placeholder]
        }
      }
    ],

    // ── Material dependencies ────────────────────────────────────────────
    table.cell(fill: _fill, inset: _ci, align: left + top)[#text(weight: "bold", size: 9pt)[#_t.material-dep]],
    table.cell(fill: white, inset: _ci, align: left + top)[
      #set text(size: 9pt)
      #_radio(3, material-dep)
      #v(0.3em)
      #table(
        columns: (auto, 1fr),
        stroke: _legend-stroke,
        inset: (x: 6pt, y: 4pt),
        align: (center, left),
        text(size: 9pt, weight: "bold")[1], text(size: 9pt)[#_t.material-1],
        text(size: 9pt, weight: "bold")[2], text(size: 9pt)[#_t.material-2],
        text(size: 9pt, weight: "bold")[3], text(size: 9pt)[#_t.material-3],
      )
      #if material-dep >= 2 {
        v(0.4em)
        text(weight: "bold", size: 9pt)[#_t.material-placeholder]
        v(0.2em)
        if material-explanation == none {
          panic("material-explanation is required when material-dep ≥ 2")
        }
        material-explanation
      }
      #if material-dep >= 3 {
        v(0.4em)
        table(
          columns: (auto, 1fr),
          stroke: (left: none, right: none, top: 0.3pt + luma(210), bottom: 0.3pt + luma(210)),
          inset: (x: 6pt, y: 4pt),
          align: (left + horizon, left + horizon),
          text(size: 9pt, weight: "bold")[#_t.material-cost],
          text(size: 9pt)[#{
            if material-cost == none {
              panic("material-cost is required when material-dep = 3")
            }
            material-cost
          }],
          text(size: 9pt, weight: "bold")[#_t.material-procedure],
          text(size: 9pt)[#{
            if material-procedure == none {
              panic("material-procedure is required when material-dep = 3")
            }
            material-procedure
          }],
        )
      }
    ],

    // ── Extra information ────────────────────────────────────────────────
    table.cell(fill: _fill, inset: _ci, align: left + top)[#text(weight: "bold", size: 9pt)[#_t.extra-info]],
    table.cell(fill: white, inset: _ci, align: left + top)[
      #set text(size: 9pt)
      #if extra-info != none {
        extra-info
      } else {
        text(style: "italic", size: 9pt)[#_t.extra-info-placeholder]
      }
    ],
  ))
}
