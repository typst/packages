// =============================================================================
// src/layout.typ: Main template orchestrator (unsa-epis-abet-report)
// =============================================================================

#import "state.typ": _primary-color-state
#import "utils.typ": (
  normalize-authors, normalize-color, resolve-academic-year, resolve-date,
  resolve-time, to-plain-string,
)
#import "components/header.typ": render-page-header
#import "components/front-matter.typ": render-front-matter
#import "styles.typ": apply-base-styles

#let _default-margins = (
  top: 6cm,
  bottom: 2.54cm,
  left: 1.9cm,
  right: 1.9cm,
)

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
/// - assets-dir (str): Relative directory path for default logo assets.
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
  assets-dir: "../../assets",
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
    // 1. Normalize colors
    let active-primary = normalize-color(primary-color)
    let active-header-border = normalize-color(header-border-color)
    let active-code-bg = normalize-color(code-bg-color)

    // Update shared state for helper components
    _primary-color-state.update(active-primary)

    // 2. Resolve datetime & academic year
    let formatted-date = resolve-date(date, date-format)
    let formatted-time = resolve-time(time, date)
    let resolved-academic-year = resolve-academic-year(academic-year, date)

    // 3. Resolve authors list & document metadata
    let authors-list = normalize-authors(authors)

    let doc-authors = authors-list
      .map(to-plain-string)
      .map(s => s.trim())
      .filter(s => s != "")

    let main-str = to-plain-string(main-title).trim()
    let title-str = to-plain-string(title).trim()
    let doc-title = if title-str != "" {
      main-str + " - " + title-str
    } else {
      main-str
    }

    // 4. Page Header
    let page-header = render-page-header(
      institution: institution,
      doc-code: doc-code,
      approval-date: approval-date,
      logo-left: logo-left,
      logo-right: logo-right,
      assets-dir: assets-dir,
      header-border-color: active-header-border,
    )

    // 5. Margins
    let resolved-margin = if margin == auto {
      _default-margins
    } else if type(margin) == dictionary {
      _default-margins + margin
    } else {
      margin
    }

    // 6. Document Properties & Page setup
    set document(
      title: doc-title,
      author: doc-authors,
    )

    set page(
      paper: paper,
      margin: resolved-margin,
      header: page-header,
      header-ascent: 5%,
    )

    // 7. Apply styles and render front matter + body
    apply-base-styles(
      font: font,
      lang: lang,
      code-bg: active-code-bg,
      [
        #render-front-matter(
          title: title,
          lab-number: lab-number,
          course: course,
          semester: semester,
          academic-year: resolved-academic-year,
          date: formatted-date,
          time: formatted-time,
          authors: authors-list,
          instructor: instructor,
          primary-color: active-primary,
          main-title: main-title,
        )
        #body
      ],
    )
  }

  // Support both `#show: unsa-epis-abet-report.with(...)` and direct `#unsa-epis-abet-report(...)[ body ]`
  if args.pos().len() > 0 {
    apply(args.pos().at(0))
  } else {
    apply
  }
}

// Backwards-compatible alias
#let abet-report = unsa-epis-abet-report
