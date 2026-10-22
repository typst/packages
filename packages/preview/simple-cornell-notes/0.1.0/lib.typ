#let cornell-themes = (
  sage: (
    accent: rgb("#315F55"),
    cue-fill: rgb("#F3F7F4"),
    border-color: rgb("#BBCBC2"),
    line-color: rgb("#D0DCD4"),
    text-color: rgb("#26332D"),
    muted-color: rgb("#67716B"),
  ),
  blue: (
    accent: rgb("#315F83"),
    cue-fill: rgb("#F3F6FA"),
    border-color: rgb("#BBCAD7"),
    line-color: rgb("#D2DDE6"),
    text-color: rgb("#26313E"),
    muted-color: rgb("#65717C"),
  ),
  mono: (
    accent: black,
    cue-fill: none,
    border-color: luma(155),
    line-color: luma(205),
    text-color: black,
    muted-color: luma(95),
  ),
)

#let default-labels = (
  title: [Topic],
  course: [Source],
  author: [Name],
  date: [Date],
  cues: [Cues],
  notes: [Notes],
  summary: [Summary],
)

// Accept percentages, fixed lengths, or a combination such as 25% + 5mm.
#let resolve-size(value, available) = {
  if type(value) == length {
    value.to-absolute()
  } else if type(value) == ratio {
    value * available
  } else {
    value.ratio * available + value.length.to-absolute()
  }
}

#let cornell-page(
  title: none,
  course: none,
  author: none, // Optional: the name field only appears when provided
  date: none,
  cues: [],
  notes: [],
  summary: [],
  // Layout
  paper: "a4",
  margin: 8mm,
  cue-width: 28%,
  summary-height: 30mm,
  padding: 2mm,
  // Typography and colors. auto uses the selected theme's value
  font: ("Libertinus Serif", "New Computer Modern"),
  font-size: 11pt,
  theme: "sage",
  accent: auto,
  cue-fill: auto,
  border-color: auto,
  line-color: auto,
  text-color: auto,
  muted-color: auto,
  // Writing guides: "lined", "dotted", "grid", or "none".
  ruling: "lined",
  cue-ruling: auto,
  summary-ruling: auto,
  line-spacing: 7mm,
  line-weight: 0.35pt,
  // Interface text. Partial dictionaries override only the supplied keys.
  labels: (:),
  show-header: true,
  show-page-numbers: false,
  lang: "en",
) = {
  assert(theme in cornell-themes, message: "theme must be \"sage\", \"blue\", or \"mono\".")
  let valid-rulings = ("lined", "dotted", "grid", "none")
  assert(ruling in valid-rulings, message: "ruling must be \"lined\", \"dotted\", \"grid\", or \"none\".")
  assert(cue-ruling == auto or cue-ruling in valid-rulings, message: "cue-ruling must be auto or a valid ruling.")
  assert(
    summary-ruling == auto or summary-ruling in valid-rulings,
    message: "summary-ruling must be auto or a valid ruling.",
  )
  assert(line-spacing > 0pt, message: "line-spacing must be greater than zero.")
  assert(line-weight > 0pt, message: "line-weight must be greater than zero.")
  assert(padding >= 0pt, message: "padding cannot be negative.")
  assert(font-size > 0pt, message: "font-size must be greater than zero.")
  for key in labels.keys() {
    assert(key in default-labels, message: "Unknown label: " + key)
  }

  let palette = cornell-themes.at(theme)
  let accent = if accent == auto { palette.accent } else { accent }
  let cue-fill = if cue-fill == auto { palette.cue-fill } else { cue-fill }
  let border-color = if border-color == auto { palette.border-color } else { border-color }
  let line-color = if line-color == auto { palette.line-color } else { line-color }
  let text-color = if text-color == auto { palette.text-color } else { text-color }
  let muted-color = if muted-color == auto { palette.muted-color } else { muted-color }
  let cue-ruling = if cue-ruling == auto { ruling } else { cue-ruling }
  let summary-ruling = if summary-ruling == auto { ruling } else { summary-ruling }
  let labels = default-labels + labels
  let date = if type(date) == datetime { date.display("[day padding:zero].[month padding:zero].[year]") } else { date }

  set text(font: font, size: font-size, fill: text-color, lang: lang)
  set par(justify: false, leading: 0.65em, spacing: 0.8em)
  set block(above: 0pt, below: 0pt)
  set heading(numbering: none)
  set list(indent: 0.9em, body-indent: 0.5em, spacing: 0.5em)
  set enum(indent: 1.1em, body-indent: 0.5em, spacing: 0.5em)
  show raw: set text(size: 0.82em)
  show raw.where(block: true): set block(above: 0.8em, below: 0.8em)
  show heading: set text(size: 1.05em, weight: "bold", fill: accent)
  show heading: set block(above: 0.8em, below: 0.4em)

  let caption(body, color: muted-color) = text(
    size: 8pt,
    weight: "semibold",
    tracking: 0.65pt,
    fill: color,
    upper(body),
  )

  // Labels and values share one line; long metadata can still wrap.
  let field(label, value, prominent: false) = grid(
    columns: (auto, 1fr),
    column-gutter: 1mm,
    align: left + horizon,
    text(size: 7.5pt, fill: muted-color, label),
    if value == none {
      block(height: 3mm, width: 100%, stroke: (bottom: 0.4pt + border-color))
    } else {
      block(width: 100%, text(
        size: 8.5pt,
        weight: if prominent { "bold" } else { "regular" },
        fill: if prominent { accent } else { text-color },
        value,
      ))
    },
  )

  let header = if show-header {
    grid(
      columns: if author == none { (2fr, 1fr, 28mm) } else { (2fr, 1fr, 1fr, 28mm) },
      column-gutter: 3mm,
      align: left + horizon,
      field(labels.title, title, prominent: true),
      field(labels.course, course),
      ..(if author == none { () } else { (field(labels.author, author),) }),
      field(labels.date, date),
    )
  }

  // These guides are decoration. Text remains in the normal PDF reading order.
  let guides(width, height, style) = {
    let line-spacing = line-spacing.to-absolute()
    let line-weight = line-weight.to-absolute()
    if style != "none" {
      let rows = calc.floor(height / line-spacing)
      let columns = calc.floor(width / line-spacing)
      let guide-stroke = line-weight + line-color
      if style == "dotted" {
        for row in range(1, rows + 1) {
          for column in range(1, columns + 1) {
            place(
              top + left,
              dx: column * line-spacing - 0.55pt,
              dy: row * line-spacing - 0.55pt,
              circle(radius: 0.55pt, fill: line-color, stroke: none),
            )
          }
        }
      } else {
        for row in range(1, rows + 1) {
          place(top + left, dy: row * line-spacing, line(length: width, stroke: guide-stroke))
        }
        if style == "grid" {
          for column in range(1, columns + 1) {
            place(top + left, dx: column * line-spacing, line(end: (0pt, height), stroke: guide-stroke))
          }
        }
      }
    }
  }

  // A measured panel prevents long typed notes from spilling into the summary.
  let panel(width, height, label, body, style, fill: none) = {
    let padding = padding.to-absolute()
    let inner-width = width - 2 * padding
    assert(inner-width > 10mm, message: "The columns are too narrow. Adjust cue-width, margin, or padding.")
    let panel-header = caption(label, color: accent)
    let header-height = measure(panel-header, width: inner-width).height
    let body-height = height - 2 * padding - header-height - 1.5mm
    assert(
      body-height > 8mm,
      message: "Not enough writing space in " + repr(label) + ". Adjust summary-height, margin, or padding.",
    )
    // A constrained measure reports the column width even for overflowing
    // elements. Check code's intrinsic width and explicit element widths too.
    let checked-body = {
      let width-check(it) = context {
        let requested-width = it.at("width", default: auto)
        if requested-width != auto {
          assert(
            resolve-size(requested-width, inner-width) <= inner-width + 0.1pt,
            message: "An element in " + repr(label) + " is too wide. Set its width to 100% or a smaller length.",
          )
        }
        it
      }
      show image: width-check
      show rect: width-check
      show box: width-check
      show block: width-check
      show raw: it => context {
        assert(
          measure(it).width <= inner-width + 0.1pt,
          message: "Code in " + repr(label) + " is too wide. Wrap the long lines or reduce font-size.",
        )
        it
      }
      body
    }
    let body-size = measure(checked-body, width: inner-width)
    assert(
      body-size.height <= body-height + 0.1pt,
      message: "Content in "
        + repr(label)
        + " does not fit on this sheet. Move some content to another cornell-page, reduce font-size, or adjust summary-height/cue-width.",
    )
    block(
      width: width,
      height: height,
      breakable: false,
      fill: fill,
      inset: padding,
      stack(
        dir: ttb,
        spacing: 1.5mm,
        panel-header,
        block(width: inner-width, height: body-height, breakable: false, {
          guides(inner-width, body-height, style)
          checked-body
        }),
      ),
    )
  }

  let footer = if show-page-numbers {
    context align(right, text(size: 8pt, fill: muted-color, counter(page).display("1")))
  } else { none }

  // page() makes every invocation a separate sheet, without manual pagebreaks.
  page(
    paper: paper,
    margin: margin,
    footer: footer,
    footer-descent: 2mm,
    layout(size => {
      // Include the header's gap only when the row is visible.
      let header-height = if show-header { measure(header, width: size.width).height + 2mm } else { 0pt }
      let cue-size = resolve-size(cue-width, size.width)
      let summary-size = resolve-size(summary-height, size.height)
      let notes-size = size.width - cue-size
      let main-height = size.height - header-height - 1mm - summary-size
      assert(
        cue-size > 0pt and notes-size > 0pt,
        message: "cue-width must be between zero and the available page width.",
      )
      assert(
        summary-size > 0pt and main-height > 0pt,
        message: "summary-height or the header is too large for this paper size. Reduce summary-height, shorten the title, or reduce margin.",
      )
      stack(
        dir: ttb,
        spacing: 0pt,
        ..(if show-header { (header, v(2mm)) } else { () }),
        grid(
          columns: (cue-size, notes-size),
          rows: (main-height,),
          inset: 0pt,
          stroke: 0.5pt + border-color,
          panel(cue-size, main-height, labels.cues, cues, cue-ruling, fill: cue-fill),
          panel(notes-size, main-height, labels.notes, notes, ruling),
        ),
        v(1mm),
        block(
          width: size.width,
          height: summary-size,
          breakable: false,
          stroke: 0.5pt + border-color,
          panel(size.width, summary-size, labels.summary, summary, summary-ruling),
        ),
      )
    }),
  )
}
