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

/// use it as `#show: jilid.with(..)`.
/// option groups take only the keys you change, see `src/config.typ`.
#let jilid(
  title: "",
  kind: none,
  subtitle: "",
  // extra (label, value) rows under the title,
  // e.g. `(([Mitra Kolaborator], [Nama Mitra]),)`.
  cover-details: (),
  course: "",
  // one or more `(name: .., id: ..)`.
  lecturers: (),
  // one or more `(name: .., id: ..)`.
  students: (),
  program: "",
  department: "",
  faculty: "",
  university: "",
  year: "",
  // content,
  // e.g. `image("logo.png")`.
  logo: none,
  // the result of `bibliography(..)`, or none.
  bibliography: none,
  lang: "id",
  paper: "a4",
  // "print", "digital" or any `page.margin` value.
  margin: "print",
  // auto shows the cover when `title` is not empty.
  include-cover: auto,
  cover: (:),
  footer: (:),
  typography: (:),
  paragraph: (:),
  numbering: (:),
  outlines: (:),
  headings: (:),
  code: (:),
  // replaces any word jilid prints,
  // e.g. `(figure: "Gbr.")`.
  labels: (:),
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

  // turn names into plain text for the PDF metadata.
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
