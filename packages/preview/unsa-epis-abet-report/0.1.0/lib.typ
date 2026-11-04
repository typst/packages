// =============================================================================
// unsa-epis-abet-report: UNSA EPIS ABET-compliant laboratory report template
// =============================================================================

/// Internal state to share the active primary color with helper components
#let _primary-color-state = state(
  "unsa-epis-abet-primary-color",
  rgb("#C8310E"),
)

// -----------------------------------------------------------------------------
// Utility Functions
// -----------------------------------------------------------------------------

/// Builds styled content with font size, weight, alignment, and color.
///
/// - content (content, str): The text or content to style.
/// - weight (str): Font weight (e.g., "regular", "bold").
/// - size (length): Font size.
/// - align-to (alignment, none): Optional alignment.
/// - color (color): Text fill color.
/// -> content
#let font-build(
  content,
  weight: "regular",
  size: 10pt,
  align-to: none,
  color: black,
) = {
  set text(size: size, weight: weight, fill: color)
  if align-to != none {
    align(align-to)[#content]
  } else {
    content
  }
}

/// Extracts uppercase letters from a string as an abbreviation.
///
/// - w (str): Input string.
/// -> str
#let abbreviate-by-caps(w) = {
  let chars = w.clusters()
  let caps = chars.filter(c => c == upper(c) and c != lower(c))
  caps.join("")
}

/// Abbreviates a full name in the format "FirstSurname, FirstName".
///
/// - name (str): Full name string.
/// -> str
#let abbreviate-full-name(name) = {
  let parts = name.split(" ")
  if parts.len() >= 3 {
    parts.at(0) + ", " + parts.at(2)
  } else {
    name
  }
}

/// Safely extracts plain text representation from content, strings, dates, or other values.
///
/// Useful for PDF document metadata (title, author) and formatting where plain string is required.
///
/// - val (any): The value to convert to a plain string.
/// -> str
#let to-plain-string(val) = {
  if val == none {
    ""
  } else if type(val) == str {
    val
  } else if type(val) == int or type(val) == float {
    str(val)
  } else if type(val) == datetime {
    val.display("[day]/[month]/[year]")
  } else if type(val) == content {
    if val.has("text") {
      val.text
    } else if val.has("children") {
      val.children.map(to-plain-string).join("")
    } else if val.has("body") {
      to-plain-string(val.body)
    } else if val.has("child") {
      to-plain-string(val.child)
    } else if val.func() == [ ].func() {
      " "
    } else {
      ""
    }
  } else if type(val) == array {
    val.map(to-plain-string).join(", ")
  } else if type(val) == dictionary {
    if "name" in val {
      to-plain-string(val.name)
    } else {
      ""
    }
  } else {
    repr(val)
  }
}

// -----------------------------------------------------------------------------
// Helper Components
// -----------------------------------------------------------------------------

/// Internal helper to split content into sections at level-1 headings
#let _split-heading-sections(body) = {
  if type(body) != content or not body.has("children") {
    return (body,)
  }

  let is-ignorable(c) = {
    if type(c) == content {
      if c.func() == [ ].func() or c.func() == parbreak {
        return true
      }
    }
    return false
  }

  let h1-count = body
    .children
    .filter(c => c.func() == heading and c.depth == 1)
    .len()
  if h1-count <= 1 {
    return (body,)
  }

  let cells = ()
  let current-cell = ()
  for child in body.children {
    if child.func() == heading and child.depth == 1 {
      if current-cell.any(c => not is-ignorable(c)) {
        cells.push(current-cell.join())
      }
      current-cell = ()
    }
    current-cell.push(child)
  }
  if current-cell.any(c => not is-ignorable(c)) {
    cells.push(current-cell.join())
  }
  cells
}

/// Renders the ABET "SOLUCIÓN Y RESULTADOS" container section.
///
/// In the official ABET format, sections such as Solución de Ejercicios,
/// Solución del Cuestionario, and Conclusiones are rendered as individual,
/// bordered cells/rows inside the main table.
///
/// This function supports:
/// 1. Named parameters:
///    `#results-section(ejercicios: [...], cuestionario: [...], conclusiones: [...])`
/// 2. Chained positional content blocks:
///    `#results-section[...][...][...]`
/// 3. Passing an array of cells:
///    `#results-section(cells: (...))`
/// 4. Passing a single block with `= ` headings (automatically split into cells).
///
/// - title (str, content): Section header title.
/// - fill (color, auto): Header background color (defaults to package primary color).
/// - stroke (stroke, length): Border stroke.
/// - inset (length, dictionary): Cell padding.
/// - ejercicios (content, none): Optional cell content for exercises/problems section.
/// - cuestionario (content, none): Optional cell content for questionnaire section.
/// - conclusiones (content, none): Optional cell content for conclusions section.
/// - cells (array, none): Optional explicit list of cell contents.
/// - ..args: Positional content block(s) representing table cells.
/// -> content
#let results-section(
  title: "SOLUCIÓN Y RESULTADOS",
  fill: auto,
  stroke: 0.5pt,
  inset: 1em,
  ejercicios: none,
  cuestionario: none,
  conclusiones: none,
  cells: (),
  ..args,
) = context {
  let active-fill = if fill == auto {
    _primary-color-state.get()
  } else if type(fill) == str {
    rgb(fill)
  } else {
    fill
  }

  let table-cells = ()
  if ejercicios != none {
    table-cells.push(ejercicios)
  }
  if cuestionario != none {
    table-cells.push(cuestionario)
  }
  if conclusiones != none {
    table-cells.push(conclusiones)
  }
  if type(cells) == array {
    table-cells += cells
  } else if cells != none {
    table-cells.push(cells)
  }

  let pos = args.pos()
  if pos.len() == 1 and type(pos.at(0)) == array {
    table-cells += pos.at(0)
  } else if pos.len() == 1 and table-cells.len() == 0 {
    table-cells += _split-heading-sections(pos.at(0))
  } else {
    table-cells += pos
  }

  table(
    stroke: stroke,
    inset: inset,
    columns: 1fr,
    table.cell(
      fill: active-fill,
      inset: 0.5em,
      align: center + horizon,
      text(weight: "bold", size: 11pt, fill: white)[#title],
    ),
    ..table-cells,
  )
}

/// Renders the ABET "RETROALIMENTACIÓN GENERAL" box for instructor comments.
///
/// - title (str, content): Box header title.
/// - height (length): Height allocated for comments when empty.
/// - fill (color, auto): Header background color (defaults to package primary color).
/// - stroke (stroke): Border stroke.
/// - inset (length, dictionary): Content padding.
/// - content (content, none): Optional instructor feedback content.
/// - ..args: Optional trailing content.
/// -> content
#let feedback-box(
  title: "RETROALIMENTACIÓN GENERAL",
  height: 6em,
  fill: auto,
  stroke: black + 1pt,
  inset: 0.5em,
  content: none,
  ..args,
) = context {
  let active-fill = if fill == auto {
    _primary-color-state.get()
  } else if type(fill) == str {
    rgb(fill)
  } else {
    fill
  }

  let body = if content != none {
    content
  } else if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    block(height: height, width: 100%)[]
  }

  grid(
    align: left + horizon,
    stroke: stroke,
    inset: inset,
    columns: 1fr,
    grid.cell(
      fill: active-fill,
      align: center + horizon,
      text(weight: "bold", size: 11pt, fill: white)[#title],
    ),
    body,
  )
}

/// Renders the ABET "REFERENCIAS Y BIBLIOGRAFÍA" container box.
///
/// - title (str, content): Box header title.
/// - fill (color, auto): Header background color (defaults to package primary color).
/// - stroke (stroke): Border stroke.
/// - inset (length, dictionary): Content padding.
/// - ..args: Trailing bibliography content.
/// -> content
#let bibliography-box(
  title: "REFERENCIAS Y BIBLIOGRAFÍA",
  fill: auto,
  stroke: black + 1pt,
  inset: 0.5em,
  ..args,
) = context {
  let active-fill = if fill == auto {
    _primary-color-state.get()
  } else if type(fill) == str {
    rgb(fill)
  } else {
    fill
  }

  let body = if args.pos().len() > 0 {
    set bibliography(title: none)
    args.pos().at(0)
  } else {
    []
  }

  grid(
    align: left + horizon,
    stroke: stroke,
    inset: inset,
    columns: 1fr,
    grid.cell(
      fill: active-fill,
      align: center + horizon,
      text(weight: "bold", size: 11pt, fill: white)[#title],
    ),
    body,
  )
}

// -----------------------------------------------------------------------------
// Core Show Rule Template
// -----------------------------------------------------------------------------

/// The main UNSA EPIS ABET laboratory report show rule template function.
///
/// - title (str, content): Title of the laboratory practice.
/// - lab-number (str, int, content): Number of the practice.
/// - course (str, content): Course or subject name.
/// - semester (str): Academic semester code (e.g., "A", "B", "2026-A").
/// - academic-year (str, int, auto): Academic year. When `auto`, derived from date.
/// - date (datetime, str, none, auto): Presentation date. When `auto`, calls `datetime.today()`.
/// - date-format (str): Date display format. Defaults to `"[day]/[month]/[year]"`.
/// - time (str, none, auto): Presentation time (e.g. "14:00"). If `none`, renders "—".
/// - authors (array, dictionary, str): Author or list of authors (str or dictionary with name/code/email).
/// - instructor (str, content): Instructor / professor name.
/// - institution (dictionary, str, content): Institution details (university, faculty, school).
/// - doc-code (str): Document code according to university format standards.
/// - approval-date (str): Approval date of the format template.
/// - logo-left (content, str, none, auto): Left logo image. Defaults to EPIS logo.
/// - logo-right (content, str, none, auto): Right logo image. Defaults to ABET logo.
/// - primary-color (color, str): Theme primary accent color.
/// - font (str, array): Font family name or fallback list.
/// - paper (str): Page paper size (defaults to "a4").
/// - lang (str): Document language code (defaults to "es").
/// - main-title (str, content): Main document heading text.
/// - header-border-color (color, str): Border color for running header table.
/// - code-bg-color (color, str): Background color for code blocks.
/// - margin (dictionary, auto): Page margins. Defaults to official ABET template margins.
/// - ..args: Receives document body when invoked as a show rule or direct function.
/// -> content
#let unsa-epis-abet-report(
  title: "Título de la Práctica",
  lab-number: "1",
  course: "Laboratorio de Computación",
  semester: "A",
  academic-year: auto,
  date: auto,
  date-format: "[day]/[month]/[year]",
  time: auto,
  authors: (),
  instructor: "Nombre del Docente",
  institution: (
    university: "UNIVERSIDAD NACIONAL DE SAN AGUSTÍN",
    faculty: "FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS",
    school: "ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS",
  ),
  doc-code: "GUIA-PRLE-001",
  approval-date: "2022/03/01",
  logo-left: auto,
  logo-right: auto,
  primary-color: rgb("#C8310E"),
  font: ("Lato", "Liberation Sans", "DejaVu Sans"),
  paper: "a4",
  lang: "es",
  main-title: "INFORME DE LABORATORIO",
  header-border-color: rgb("#808080"),
  code-bg-color: rgb("#F1F3F4"),
  margin: auto,
  ..args,
) = {
  let apply(body) = {
    // 1. Resolve colors
    let active-primary = if type(primary-color) == str {
      rgb(primary-color)
    } else {
      primary-color
    }

    let active-header-border = if type(header-border-color) == str {
      rgb(header-border-color)
    } else {
      header-border-color
    }

    let active-code-bg = if type(code-bg-color) == str {
      rgb(code-bg-color)
    } else {
      code-bg-color
    }

    // Update shared state for helper components
    _primary-color-state.update(active-primary)

    // 2. Resolve datetime & academic year
    let formatted-date = if date == auto {
      datetime.today().display(date-format)
    } else if type(date) == datetime {
      date.display(date-format)
    } else if type(date) == str or type(date) == content {
      date
    } else if date == none {
      "—"
    } else {
      to-plain-string(date)
    }

    let formatted-time = if time == auto {
      let cli-time = sys.inputs.at(
        "hora",
        default: sys.inputs.at(
          "time",
          default: sys.inputs.at("compilation-time", default: none),
        ),
      )
      if cli-time != none {
        cli-time
      } else if type(date) == datetime and date.hour() != none {
        date.display("[hour]:[minute]")
      } else {
        "—"
      }
    } else if time == none {
      "—"
    } else if type(time) == datetime {
      if time.hour() != none {
        time.display("[hour]:[minute]")
      } else {
        "—"
      }
    } else if type(time) == str or type(time) == content {
      time
    } else {
      to-plain-string(time)
    }

    let resolved-academic-year = if academic-year == auto {
      if type(date) == datetime {
        str(date.year())
      } else {
        str(datetime.today().year())
      }
    } else if academic-year == none {
      "—"
    } else if type(academic-year) == str or type(academic-year) == content {
      academic-year
    } else if type(academic-year) == int {
      str(academic-year)
    } else {
      to-plain-string(academic-year)
    }

    // 3. Resolve authors list
    let authors-list = if type(authors) == array {
      authors
    } else if authors != none {
      (authors,)
    } else {
      ()
    }

    let render-author(a) = {
      if a == none {
        "—"
      } else if type(a) == str or type(a) == content {
        a
      } else if type(a) == dictionary {
        let name = a.at("name", default: "")
        let extras = ()
        if "code" in a and a.code != none {
          let code-str = if type(a.code) == str { a.code } else {
            to-plain-string(a.code)
          }
          if code-str.trim() != "" {
            extras.push(code-str)
          }
        }
        if "email" in a and a.email != none {
          let email-str = if type(a.email) == str { a.email } else {
            to-plain-string(a.email)
          }
          if email-str.trim() != "" {
            extras.push(email-str)
          }
        }
        if extras.len() > 0 {
          [#name (#extras.join(", "))]
        } else {
          [#name]
        }
      } else {
        to-plain-string(a)
      }
    }

    // Authors metadata for document PDF properties
    let doc-authors = authors-list
      .map(a => {
        if type(a) == str {
          a
        } else if type(a) == dictionary {
          to-plain-string(a.at("name", default: ""))
        } else {
          to-plain-string(a)
        }
      })
      .filter(a => a.trim() != "")

    // Document title metadata
    let doc-title = if title != none {
      let main-str = to-plain-string(main-title)
      let title-str = to-plain-string(title)
      if title-str != "" {
        main-str + " - " + title-str
      } else {
        main-str
      }
    } else {
      to-plain-string(main-title)
    }

    // 4. Resolve institution text
    let inst-content = if type(institution) == dictionary [
      #institution.at(
        "university",
        default: "UNIVERSIDAD NACIONAL DE SAN AGUSTÍN",
      ) \
      #institution.at(
        "faculty",
        default: "FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS",
      ) \
      #institution.at(
        "school",
        default: "ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS",
      )
    ] else if type(institution) == str or type(institution) == content [
      #institution
    ] else [
      UNIVERSIDAD NACIONAL DE SAN AGUSTÍN \
      FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS \
      ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS
    ]

    // 5. Resolve logos
    let resolved-logo-left = if logo-left == auto {
      image("assets/epis.png", width: 95%)
    } else if type(logo-left) == str {
      image(logo-left, width: 95%)
    } else if logo-left == none {
      []
    } else {
      logo-left
    }

    let resolved-logo-right = if logo-right == auto {
      image("assets/abet.png", width: 97%)
    } else if type(logo-right) == str {
      image(logo-right, width: 97%)
    } else if logo-right == none {
      []
    } else {
      logo-right
    }

    // 6. Running Page Header Table
    let page-header = block(
      width: 100%,
      inset: (bottom: 1em),
    )[
      #table(
        align: center + horizon,
        stroke: 0.5pt + active-header-border,
        columns: (1fr, 2fr, 1fr),
        align(horizon)[#resolved-logo-left],
        text(size: 7.5pt, weight: "bold", fill: black)[#inst-content],
        align(horizon)[#resolved-logo-right],
        table.cell(colspan: 3)[
          #text(size: 7pt, weight: "bold")[Formato: ]
          #text(
            size: 7pt,
          )[Guía de Práctica de Laboratorio / Talleres / Centros de Simulación]
        ],
        text(size: 7pt, weight: "bold")[Aprobación: #approval-date],
        text(size: 7pt, weight: "bold")[Código: #doc-code],
        table.cell(align: right + horizon)[
          #context text(
            size: 7pt,
            weight: "bold",
          )[Página: #counter(page).display("1")]
        ],
      )
    ]

    // 7. ABET Front Matter Table ("Información Básica")
    let front-matter-table = table(
      align: left + horizon,
      stroke: black + 0.5pt,
      inset: 0.5em,
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      table.cell(
        colspan: 6,
        fill: active-primary,
        align: center + horizon,
        text(weight: "bold", size: 11pt, fill: white)[INFORMACIÓN BÁSICA],
      ),
      [*Asignatura:*], table.cell(colspan: 5, [#course]),
      [*Título de la práctica:*], table.cell(colspan: 5, [#title]),
      [*Número de la práctica:*], [#lab-number],
      [*Año lectivo:*], [#resolved-academic-year],
      [*Nro. semestre:*], [#semester],
      [*Fecha de presentación:*], [#formatted-date],
      [*Hora de presentación:*], table.cell(colspan: 3, [#formatted-time]),
      table.cell(
        colspan: 4,
        [
          *Integrante(s):*
          #set list(marker: "-")
          #if authors-list.len() > 0 {
            for a in authors-list [
              - #render-author(a)
            ]
          } else [
            - —
          ]
        ],
      ),
      [*NOTA:*], [Nota colocada por el docente],
      table.cell(
        colspan: 6,
        [
          *Docente:*\
          #instructor
        ],
      ),
    )

    // 8. Margins
    let resolved-margin = if margin == auto {
      (
        top: 6cm,
        bottom: 2.54cm,
        left: 1.9cm,
        right: 1.9cm,
      )
    } else {
      margin
    }

    // 9. Document Properties & Rules
    set document(
      title: doc-title,
      author: doc-authors,
    )

    set text(
      font: font,
      lang: lang,
      size: 10pt,
    )

    set page(
      paper: paper,
      margin: resolved-margin,
      header: page-header,
      header-ascent: 5%,
    )

    // Code block styling
    show raw.where(block: true): it => block(
      fill: active-code-bg,
      width: 100%,
      inset: 1.2em,
      radius: 6pt,
      breakable: true,
      text(fill: rgb("#303030"), it),
    )

    show raw.where(block: false): box.with(
      fill: active-code-bg,
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
    )

    // Figure styling
    show figure: set block(breakable: true)

    // Link styling
    show link: it => underline(text(fill: rgb("#0056b3"), style: "italic", it))

    // Heading styles according to official template
    set heading(numbering: "1.")
    show heading.where(level: 1): it => block(
      width: 100%,
      above: 1.2em,
      below: 1em,
    )[
      #set align(left)
      #set text(weight: "bold", size: 12pt)
      #smallcaps(it)
    ]
    show heading.where(level: 2): it => block(above: 1em, below: 0.8em)[
      #set align(left)
      #set text(weight: "bold", size: 11pt)
      #it
    ]
    show heading.where(level: 3): it => block(above: 1em, below: 0.8em)[
      #set align(left)
      #set text(weight: "bold", size: 10pt)
      #it
    ]

    // Paragraph justification
    set par(justify: true)

    // Document Heading & Front Matter
    align(center)[#text(size: 13pt, weight: "bold", fill: black)[#main-title]]
    v(0.5em)

    block(width: 100%)[
      #set text(size: 8.5pt, hyphenate: false)
      #set par(justify: false)
      #front-matter-table
    ]

    v(1em)

    // Document Body
    body
  }

  // Support both `#show: unsa-epis-abet-report.with(...)` and direct `#unsa-epis-abet-report(...)[ body ]`
  if args.pos().len() > 0 {
    apply(args.pos().at(0))
  } else {
    apply
  }
}

// Backwards-compatible aliases
#let abet-report = unsa-epis-abet-report
