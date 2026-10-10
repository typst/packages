#let defaults = (
  cover: (
    top: 2cm,
    logo-width: 8cm,
    // "top" puts `kind` above the title.
    // "bottom" puts it below the title.
    kind-pos: "bottom",
    // space between the course, lecturer and student blocks.
    gap: 0.2cm,
    // space above the institution block.
    gap-institution: 1cm,
    // space above and below the logo.
    gap-logo: 0.5cm,
    // number of student columns.
    // auto uses the fewest columns up to 3 that fit the page.
    student-columns: auto,
    // "right" puts the student id beside the name.
    // "below" puts it under the name.
    student-id-pos: "right",
    // text styles of the cover texts below.
    // each takes any `text` argument, `upper` and `underline`.
    title: (size: 18pt, weight: "bold", upper: true),
    kind: (size: 14pt, weight: "bold", upper: true),
    subtitle: (size: 18pt, weight: "bold", upper: true),
    details: (size: 14pt, weight: "bold"),
    label: (:),
    course: (weight: "bold"),
    lecturer-name: (weight: "bold", style: "italic", underline: true),
    student-name: (:),
    // "NIP ..." and "NIM ..." lines.
    id: (:),
    // university, faculty, department, program and year.
    institution: (weight: "bold", upper: true),
    // a function that draws the whole cover from its data.
    render: auto,
  ),
  footer: (
    enabled: true,
    left: none,
    show-page-number: true,
    page-number-align: center,
    // text style of `left`.
    text: (size: 9pt, weight: "bold"),
    // a function that draws the footer from the page number and text.
    render: auto,
  ),
  typography: (
    // auto uses Typst's bundled Libertinus Serif.
    font-family: auto,
    font-size: 12pt,
    caption-size: 10pt,
    caption-gap: 1em,
    table-size: 10pt,
    // a function that draws each caption from its parts.
    caption: auto,
  ),
  paragraph: (
    justify: true,
    indent: 0.63cm,
    leading: 0.575em,
    spacing: 1.15em,
    // space before numbered and bullet markers.
    list-indent: 0cm,
    // width of the marker column.
    // list text starts after it.
    marker-width: 0.75cm,
  ),
  numbering: (
    // page number style before the first chapter.
    front: "i",
    // "body" continues the chapter page numbers in the appendices.
    // "front" continues the front matter page numbers.
    back: "body",
    // "bottom" puts page numbers in the footer.
    // "top" puts chapter and appendix page numbers at the top right,
    // except on pages that open a chapter.
    position: "bottom",
    // chapter number style.
    // "I" gives BAB I, "1" gives BAB 1.
    chapter: "I",
    // appendix number style.
    // "1" gives Lampiran 1, "A" gives Lampiran A.
    appendix: "1",
    // section number style inside a chapter.
    heading: "1.1.",
    // put "Lampiran 1." before each appendix title.
    appendix-prefix: true,
  ),
  outlines: (
    depth: 3,
    toc: true,
    figures: true,
    tables: true,
    codes: true,
    // show DAFTAR LAMPIRAN when there are appendices.
    appendices: true,
    // list each appendix in DAFTAR ISI too.
    // false lists only the LAMPIRAN title.
    toc-appendices: false,
    // text style of chapter rows in DAFTAR ISI.
    h1: (weight: "bold"),
    // text repeated between an entry and its page number.
    // none removes it.
    leader: ".",
  ),
  headings: (
    // affects chapter and front-matter titles.
    h1: (
      size: 12pt,
      above: 24pt,
      below: 18pt,
      pagebreak: true,
      uppercase: true,
    ),
    h2: (size: 12pt, above: 24pt, below: 18pt, indent: 0cm),
    h3: (size: 12pt, above: 14pt, below: 18pt, indent: 0cm),
    h4: (size: 12pt, above: 12pt, below: 18pt, indent: 0cm),
    // numbered appendix titles, on their page and in the lists.
    // 'LAMPIRAN-LAMPIRAN' follows `h1`.
    appendix: (uppercase: false),
  ),
  code: (
    fill: luma(240),
    font: auto,
    size: 10pt,
    zebraw: true,
  ),
)

// fail on any value not listed below.
#let one-of(..values) = (
  check: v => v in values.pos(),
  message: "must be one of " + values.pos().map(repr).join(", "),
)
#let hook = (
  check: v => v == auto or type(v) == function,
  message: "must be auto or a function, e.g. `it => [...]`",
)

// the values each option accepts.
#let rules = (
  "cover.kind-pos": one-of("top", "bottom"),
  "cover.student-id-pos": one-of("right", "below"),
  "cover.student-columns": (
    check: v => v == auto or (type(v) == int and v >= 1),
    message: "must be auto or a whole number of 1 or more, e.g. `2`",
  ),
  "cover.render": hook,
  "footer.render": hook,
  "typography.caption": hook,
  "numbering.back": one-of("body", "front"),
  "numbering.position": one-of("bottom", "top"),
  "code.zebraw": (
    check: v => type(v) in (bool, dictionary),
    message: "must be true, false, or a dictionary of zebraw options, e.g. `(lang: false)`",
  ),
)

// options that take any `text` argument, `upper` and `underline`.
// their keys are not checked, and a user key replaces only that key.
#let text-styles = (
  "cover.title",
  "cover.kind",
  "cover.subtitle",
  "cover.details",
  "cover.label",
  "cover.course",
  "cover.lecturer-name",
  "cover.student-name",
  "cover.id",
  "cover.institution",
  "footer.text",
  "outlines.h1",
)

// margins for `margin: "print"` and `margin: "digital"`.
#let margin-presets = (
  print: (top: 3cm, bottom: 3cm, left: 4cm, right: 3cm),
  digital: 1in,
)

// put the user's options over the defaults, in nested groups too.
// `path` is the option name shown in errors.
#let merge(base, user, path: "") = {
  let out = base
  for (key, value) in user {
    let name = if path == "" { key } else { path + "." + key }
    assert(
      key in base,
      message: "jilid: unknown option `"
        + name
        + "`. Valid options here: "
        + base.keys().map(k => "`" + k + "`").join(", ")
        + ".",
    )
    let default = base.at(key)
    if type(default) == dictionary {
      let example = if name in text-styles { "size" } else {
        default.keys().first()
      }
      assert(
        type(value) == dictionary,
        message: "jilid: option `"
          + name
          + "` expects a dictionary, e.g. `"
          + name
          + ": ("
          + example
          + ": ...)`.",
      )
      out.insert(
        key,
        if name in text-styles { default + value } else {
          merge(default, value, path: name)
        },
      )
    } else {
      if name in rules {
        let rule = rules.at(name)
        assert(
          (rule.check)(value),
          message: "jilid: option `"
            + name
            + "` "
            + rule.message
            + ", not "
            + repr(value)
            + ".",
        )
      }
      out.insert(key, value)
    }
  }
  out
}
