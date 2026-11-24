#import "config.typ": defaults, margin-presets, merge
#import "validate.typ": check-args, people
#import "labels.typ": resolve as resolve-labels
#import "rules/text.typ": para-rules, text-rules
#import "rules/headings.typ": heading-rules
#import "rules/figures.typ": figure-rules
#import "rules/refs.typ": ref-rules
#import "pages/cover.typ": cover-page
#import "pages/footer.typ": page-footer, page-header
#import "matter.typ": flow
#import "utils.typ": plain

/// Formats a report, proposal or thesis for an Indonesian university.
///
/// Use it as a show rule at the top of the file.
/// jilid makes the cover, the front matter, the lists of contents, figures and tables, the chapters, the bibliography and the appendices.
///
/// = Example
///
/// ```
/// #show: jilid.with(
///   title: [Judul Laporan],
///   students: (name: "Nama Mahasiswa", id: "1000000001"),
///   university: "Universitas Negeri",
///   year: "2026",
/// )
///
/// = Pendahuluan
/// ```
///
/// = Options
///
/// Each option group takes a dictionary with only the keys that you change, such as `footer: (left: [Laporan Akhir])`.
/// These are the keys of each group:
///
/// / cover: `top`, `logo-width`, `kind-pos`, `gap`, `gap-institution`, `gap-logo`, `student-columns`, `student-id-pos`, `title`, `kind`, `subtitle`, `details`, `label`, `course`, `lecturer-name`, `student-name`, `id`, `institution`, `institution-order`, `institution-render`, `render`
/// / footer: `enabled`, `left`, `show-page-number`, `page-number-align`, `text`, `render`
/// / typography: `font-family`, `font-size`, `caption-size`, `caption-gap`, `table-size`, `url`, `caption`
/// / paragraph: `justify`, `indent`, `leading`, `spacing`, `list-indent`, `marker-width`
/// / numbering: `front`, `back`, `position`, `chapter`, `appendix`, `heading`, `appendix-prefix`
/// / outlines: `depth`, `toc`, `figures`, `tables`, `codes`, `appendices`, `toc-appendices`, `h1`, `leader`, `align-titles`, `toc-indent`
/// / headings: `h1`, `h2`, `h3`, `h4`, `appendix`
/// / code: `fill`, `font`, `size`, `zebraw`
///
/// The README gives the type, the default value and a description for each key.
///
/// - title (content, str): The document title. If it is not empty, jilid makes a cover.
/// - kind (content, str, none): The document type, such as Laporan Praktikum or Skripsi.
/// - subtitle (content, str): A second title line under the title.
/// - cover-details (array): Extra (label, value) rows under the title, such as `(([Mitra], [Nama Mitra]),)`.
/// - course (content, str): The course name.
/// - lecturers (dictionary, array): One or more lecturers as `(name: .., id: ..)`.
/// - students (dictionary, array): One or more students as `(name: .., id: ..)`.
/// - program (content, str): The study program.
/// - department (content, str): The department.
/// - faculty (content, str): The faculty.
/// - university (content, str): The university.
/// - year (content, str): The year on the cover.
/// - logo (content, none): The logo, such as `image("logo.png")`.
/// - bibliography (content, none): The result of `bibliography(..)`. jilid puts it after the last chapter.
/// - lang (str): The text language. `"id"` and `"en"` are built in.
/// - paper (str): The paper size, such as `"a4"`.
/// - margin (str, length, dictionary): `"digital"` gives 1 inch on all sides. `"print"` gives 4 cm on the left and 3 cm on the other sides. Any page margin value also works.
/// - include-cover (bool, auto): If `auto`, jilid makes a cover when `title` is not empty.
/// - cover (dictionary): The cover layout and text styles.
/// - footer (dictionary): The footer text and page number.
/// - typography (dictionary): The fonts and text sizes.
/// - paragraph (dictionary): The paragraph and list layout.
/// - numbering (dictionary): The number styles for pages, chapters, sections and appendices.
/// - outlines (dictionary): The lists of contents, figures, tables, code and appendices.
/// - headings (dictionary): The heading sizes and space.
/// - code (dictionary): The code block style.
/// - labels (dictionary): Replacements for the words that jilid prints, such as `(figure: "Gbr.")`.
/// - body (content): The document. The show rule gives it to jilid.
/// -> content
#let jilid(
  /// The document title. If it is not empty, jilid makes a cover.
  title: "",
  /// The document type, such as Laporan Praktikum or Skripsi.
  kind: none,
  /// A second title line under the title.
  subtitle: "",
  /// Extra (label, value) rows under the title, such as `(([Mitra], [Nama Mitra]),)`.
  cover-details: (),
  /// The course name.
  course: "",
  /// One or more lecturers as `(name: .., id: ..)`.
  lecturers: (),
  /// One or more students as `(name: .., id: ..)`.
  students: (),
  /// The study program.
  program: "",
  /// The department.
  department: "",
  /// The faculty.
  faculty: "",
  /// The university.
  university: "",
  /// The year on the cover.
  year: "",
  /// The logo, such as `image("logo.png")`.
  logo: none,
  /// The result of `bibliography(..)`. jilid puts it after the last chapter.
  bibliography: none,
  /// The text language. `"id"` and `"en"` are built in.
  lang: "id",
  /// The paper size, such as `"a4"`.
  paper: "a4",
  /// `"digital"`, `"print"` or any page margin value.
  margin: "digital",
  /// If `auto`, jilid makes a cover when `title` is not empty.
  include-cover: auto,
  /// The cover layout and text styles.
  cover: (:),
  /// The footer text and page number.
  footer: (:),
  /// The fonts and text sizes.
  typography: (:),
  /// The paragraph and list layout.
  paragraph: (:),
  /// The number styles for pages, chapters, sections and appendices.
  numbering: (:),
  /// The lists of contents, figures, tables, code and appendices.
  outlines: (:),
  /// The heading sizes and space.
  headings: (:),
  /// The code block style.
  code: (:),
  /// Replacements for the words that jilid prints, such as `(figure: "Gbr.")`.
  labels: (:),
  /// The document. The show rule gives it to jilid.
  body,
) = {
  let cfg = merge(defaults, (
    cover: cover,
    footer: footer,
    typography: typography,
    paragraph: paragraph,
    numbering: numbering,
    outlines: outlines,
    headings: headings,
    code: code,
  ))
  check-args(
    logo: logo,
    bibliography: bibliography,
    cover-details: cover-details,
    margin: margin,
  )
  let students = people(students, "students")
  let lecturers = people(lecturers, "lecturers")

  let cfg = (
    cfg
      + (
        lang: lang,
        t: resolve-labels(labels, lang),
        info: (
          title: title,
          kind: kind,
          subtitle: subtitle,
          cover-details: cover-details,
          course: course,
          lecturers: lecturers,
          students: students,
          program: program,
          department: department,
          faculty: faculty,
          university: university,
          year: year,
          logo: logo,
        ),
      )
  )

  // Turn the student names into plain text for the PDF metadata.
  set document(title: title, author: students.map(s => plain(s.name)))

  set page(numbering: none)
  set page(header: page-header(cfg), footer: page-footer(cfg))
  set page(
    paper: paper,
    margin: if type(margin) == str { margin-presets.at(margin) } else {
      margin
    },
  )

  show: text-rules.with(cfg)
  show: heading-rules.with(cfg)
  show: figure-rules.with(cfg)
  show: ref-rules.with(cfg)

  show: it => {
    let with-cover = if include-cover == auto { title not in ("", none) } else {
      include-cover
    }
    if with-cover { cover-page(cfg) }
    flow(cfg, it)
  }

  show: para-rules.with(cfg)

  body

  if bibliography != none {
    pagebreak(weak: true)
    heading(level: 1, numbering: none)[#cfg.t.bibliography]
    set std.bibliography(title: none)
    bibliography
  }
}
