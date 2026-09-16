// Per-document-type front matter.
//
// `front-matter()` renders the leading material for a document: either the
// compact inline header (report / document / tb-assignment without a cover) or
// the full cover page for the requested document type. The actual cover
// renderers live one per type in lib/pages/cover_*.typ; this module only
// selects and feeds the right one.
//
// The cover modules are imported lazily inside each branch (not at module
// load) because they import the package entrypoint back — a top-level import
// here would create a load-time cyclic import.

#let front-matter(
  doc-type: "report",
  show-cover: true,
  no-decorations: false,

  // Common
  title: none,
  subtitle: none,
  authors: (),
  authors-list: (),
  authors-str: none,
  date: none,
  revision: none,
  logo: none,
  language: "fr",
  sans-font: none,
  fancy-line: false,

  // Report / course
  course-supervisor: none,
  course-name: none,
  semester: none,
  academic-year: none,
  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: none,
  cover-image-kind: auto,
  cover-image-supplement: auto,

  // Thesis / exec-summary
  school: none,
  programme: none,
  major: (),
  thesis-id: none,
  thesis-expert: none,
  thesis-supervisor: none,
  thesis-co-supervisor: none,
  hide-completeness-warning: false,

  // Exec-summary
  summary: none,
  content: none,
  student-picture: none,
  permanent-email: none,
  video-url: none,
  bind: none,
  footer: none,
) = {
  // Supervisors list shared by the thesis and exec-summary covers.
  let supervisors = if thesis-co-supervisor == none {
    (thesis-supervisor,)
  } else {
    (thesis-supervisor, thesis-co-supervisor)
  }

  if not show-cover and not no-decorations and (doc-type == "report" or doc-type == "document" or doc-type == "tb-assignment") {
    // Compact inline header: logo right-aligned on its own row, then title + authors
    if logo != none {
      v(0.3em)
      align(right, box(height: 1.3cm, logo))
      v(1.5em)
    }
    text(font: sans-font, 1.8em, weight: 700, title)
    linebreak()
    v(-0.2em)
    text(1.1em, authors-list.join(", "))
    v(-0.1em)

    // A line to separate the header from the content
    if fancy-line {
      rect(width: 100%, height: 0.6pt, fill: gradient.linear((luma(20), 0%), (luma(20), 80%), (luma(20).transparentize(100%), 100%)), stroke: none)
    } else {
      line(length: 100%, stroke: (paint: luma(20), thickness: 0.6pt))
    }
    v(0.7em)
  } else if (doc-type == "report") {
    import "pages/cover_report.typ": cover_page

    cover_page(
      course-supervisor: course-supervisor,
      course-name: course-name,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      cover-image: cover-image,
      cover-image-height: cover-image-height,
      cover-image-caption: cover-image-caption,
      cover-image-kind: cover-image-kind,
      cover-image-supplement: cover-image-supplement,
      authors: authors,
      date: date,
      logo: logo,
      language: language,
    )
  } else if doc-type == "document" {
    import "pages/cover_document.typ": cover_page

    cover_page(
      font: sans-font,
      title: title,
      subtitle: subtitle,
      authors: authors,
      date: date,
      revision: revision,
      logo: logo,
      language: language,
    )
  } else if doc-type == "thesis" {
    import "pages/cover_bachelor.typ": cover_page

    cover_page(
      supervisors: supervisors,
      expert: thesis-expert,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      school: school,
      programme: programme,
      major: major,
      authors: authors-str,
      thesis-id: thesis-id,
      submission-date: date,
      revision: revision,
      logo: logo,
      language: language,
      hide-completeness-warning: hide-completeness-warning,
    )
  } else if doc-type == "exec-summary" {
    import "pages/cover_exec_summary.typ": cover_page

    cover_page(
      title: title,
      subtitle: subtitle,
      authors: authors-str,
      summary: summary,
      content: content,
      picture: student-picture,
      permanent-email: permanent-email,
      video-url: video-url,
      academic-year: academic-year,
      supervisors: supervisors,
      expert: thesis-expert,
      school: school,
      programme: programme,
      major: major,
      language: language,
      bind: bind,
      footer: footer,
      font: sans-font,
    )
  }
}
