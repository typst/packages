#let defaults = (
  cover: (
    top: 2cm,
    logo-width: 8cm,
    // "top" puts `kind` above the title.
    // "bottom" puts it below the title.
    kind-pos: "bottom",
    // The space between the course, lecturer and student blocks.
    gap: 0.2cm,
    // The space above the institution block.
    gap-institution: 1cm,
    // The space above and below the logo.
    gap-logo: 0.5cm,
    // The number of student columns.
    // auto uses the fewest columns, up to 3, that fit on the page.
    student-columns: auto,
    // "right" puts the student ID beside the name.
    // "below" puts it under the name.
    student-id-pos: "right",
    // The text styles of the cover texts below.
    // Each style takes any `text` argument, plus `upper` and `underline`.
    title: (size: 18pt, weight: "bold", upper: true),
    kind: (size: 14pt, weight: "bold", upper: true),
    subtitle: (size: 18pt, weight: "bold", upper: true),
    details: (size: 14pt, weight: "bold"),
    label: (:),
    course: (weight: "bold"),
    lecturer-name: (:),
    student-name: (:),
    // The "NIP ..." and "NIM ..." lines.
    id: (:),
    // The university, faculty, department, program and year.
    institution: (weight: "bold", upper: true),
    // The institution lines, from top to bottom.
    // If you leave a key out, jilid hides its line.
    institution-order: (
      "university",
      "faculty",
      "department",
      "program",
      "year",
    ),
    // A function that draws the institution block from its lines.
    institution-render: auto,
    // A function that draws the whole cover from its data.
    render: auto,
  ),
  footer: (
    enabled: true,
    left: none,
    show-page-number: true,
    page-number-align: center,
    // The text style of `left`.
    text: (size: 9pt, weight: "bold"),
    // A function that draws the footer from the page number and the text.
    render: auto,
  ),
  typography: (
    font-family: auto,
    font-size: 12pt,
    caption-size: 10pt,
    caption-gap: 1em,
    table-size: 10pt,
    // The text style of web links.
    // `font: auto` uses the code font.
    url: (font: auto, size: 0.85em, fill: blue.darken(20%), underline: true),
    // A function that draws each caption from its parts.
    caption: auto,
  ),
  paragraph: (
    justify: true,
    indent: 0.63cm,
    leading: 0.575em,
    spacing: 1.15em,
    // The space before numbered and bullet markers.
    list-indent: 0cm,
    // The width of the marker column.
    // The list text starts after it.
    marker-width: 0.75cm,
  ),
  numbering: (
    // The page number style before the first chapter, such as "i".
    front: "i",
    // "body" continues the chapter page numbers in the appendices.
    // "front" continues the front matter page numbers.
    back: "body",
    // "bottom" puts page numbers in the footer.
    // "top" puts chapter and appendix page numbers at the top right.
    // A page that opens a chapter keeps its number at the bottom.
    position: "bottom",
    // The chapter number style.
    // "I" gives BAB I, and "1" gives BAB 1.
    chapter: "I",
    // The appendix number style.
    // "1" gives Lampiran 1, and "A" gives Lampiran A.
    appendix: "1",
    // The section number style inside a chapter, such as "1.1.".
    heading: "1.1.",
    // Put "Lampiran 1." before each appendix title.
    appendix-prefix: true,
  ),
  outlines: (
    depth: 3,
    toc: true,
    figures: true,
    tables: true,
    codes: true,
    // Show DAFTAR LAMPIRAN if the document has appendices.
    appendices: true,
    // List each appendix in DAFTAR ISI too.
    // If false, DAFTAR ISI lists only the LAMPIRAN title.
    toc-appendices: false,
    // The text style of chapter rows in DAFTAR ISI.
    h1: (weight: "bold"),
    // The text between an entry and its page number, repeated to fill the line.
    // none removes it.
    leader: ".",
    // Where titles start in Daftar Gambar, Tabel, Kode and Lampiran.
    // "each" starts every title in a list at the same place, after the widest number such as "Gambar 2.10".
    // "shared" uses one place for all of these lists.
    // none puts each title right after its number.
    align-titles: "each",
    // Where titles start in DAFTAR ISI.
    // "title" lines up the chapter titles, and a row below chapter level starts under the title of the level above.
    // A length, such as 1cm, also lines up the chapter titles and moves each lower level by that length.
    // 0cm puts the rows below chapter level at the left.
    // auto puts each title right after its number and uses the Typst default for the rows below.
    toc-indent: "title",
  ),
  headings: (
    // Chapter titles and front matter titles.
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
    // Numbered appendix titles, on their page and in the lists.
    // The LAMPIRAN-LAMPIRAN title follows `h1`.
    appendix: (uppercase: false),
  ),
  code: (
    fill: luma(240),
    font: auto,
    size: 10pt,
    zebraw: true,
  ),
)

// Accept only the values in the list.
// Any other value fails.
#let one-of(..values) = (
  check: v => v in values.pos(),
  message: "must be one of " + values.pos().map(repr).join(", "),
)
#let hook = (
  check: v => v == auto or type(v) == function,
  message: "must be auto or a function, e.g. `it => [...]`",
)

// The values that each option accepts.
#let rules = (
  "cover.kind-pos": one-of("top", "bottom"),
  "cover.student-id-pos": one-of("right", "below"),
  "cover.student-columns": (
    check: v => v == auto or (type(v) == int and v >= 1),
    message: "must be auto or a whole number of 1 or more, e.g. `2`",
  ),
  "cover.render": hook,
  "cover.institution-render": hook,
  "cover.institution-order": (
    check: v => (
      type(v) == array
        and v.all(k => (
          k in ("university", "faculty", "department", "program", "year")
        ))
    ),
    message: "must be a list of \"university\", \"faculty\", \"department\", \"program\" and \"year\", e.g. `(\"university\", \"program\", \"year\")`",
  ),
  "footer.render": hook,
  "typography.caption": hook,
  "numbering.back": one-of("body", "front"),
  "numbering.position": one-of("bottom", "top"),
  "outlines.align-titles": one-of("each", "shared", none),
  "outlines.toc-indent": (
    check: v => v in ("title", auto) or type(v) in (length, relative),
    message: "must be \"title\", auto or a length, e.g. `1cm`",
  ),
  "code.zebraw": (
    check: v => type(v) in (bool, dictionary),
    message: "must be true, false, or a dictionary of zebraw options, e.g. `(lang: false)`",
  ),
)

// Options that take any `text` argument, plus `upper` and `underline`.
// jilid does not check their keys, and a user key replaces only that key.
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
  "typography.url",
  "outlines.h1",
)

// The margins for `margin: "print"` and `margin: "digital"`.
#let margin-presets = (
  print: (top: 3cm, bottom: 3cm, left: 4cm, right: 3cm),
  digital: 1in,
)

// Put the options of the user over the defaults, in nested groups too.
// `path` is the option name that errors show.
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
