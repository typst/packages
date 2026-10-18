#import "utils.typ"

/// Font size of header titles.
///
/// Titles are never shrunk to fit their columns: one that does not fit wraps
/// into `header-max-title-lines` lines and is then truncated.
#let header-title-size = 9pt

/// Maximum number of lines a header title may occupy.
#let header-max-title-lines = 2

/// Maximum number of rows the slide tracker may occupy.
#let header-max-tracker-rows = 3

/// Largest share of slides that may be hidden behind a trailing ellipsis.
#let header-hide-limit = 0.25

/// Gap between two neighbouring header columns.
#let header-cell-gutter = 0.3cm

/// Builds text with the properties the header is rendered and measured with.
///
/// The size and fill are stated on every call so that measurement agrees with
/// what is drawn; the text is ragged right and never hyphenated.
///
/// = Parameters
/// - `size` (length): Font size of the text.
/// - `fill` (color): Fill of the text.
/// - `body` (str or content): The text itself.
///
/// = Returns
/// A content block with the requested text.
#let header-text(size: header-title-size, fill: black, body) = {
  // The header is a list of short labels in narrow columns, so the text is set
  // ragged right and never hyphenated: justification would stretch the gaps and
  // hyphenation would break the words. Measurement runs through here too, which
  // is what keeps `title-height` in step with what is rendered.
  set par(justify: false)
  text(size: size, weight: "regular", fill: fill, hyphenate: false, body)
}

/// Renders one tracker row, linking each glyph to the slide it stands for.
///
/// A glyph without a location is drawn plain: the collapsed glyphs of an
/// overflowing tracker represent runs of slides rather than one each, so they
/// carry no target.
///
/// = Parameters
/// - `row` (array): Dot records, as returned by `render-tracker`.
/// - `color` (color): Fill of the glyphs.
///
/// = Returns
/// The rendered row.
#let tracker-row(row, color) = {
  // One `header-text` call for the whole row. Every call carries its own `set
  // par` scope, so calling it once per glyph would render each on its own line.
  header-text(fill: color)[
    #row.fold([], (acc, dot) => {
      acc + (if dot.location == none { [#dot.glyph] } else { link(dot.location)[#dot.glyph] })
    })
  ]
}

/// Measures the advance width of every tracker glyph at a given size.
///
/// = Parameters
/// - `size` (length): Font size to measure at.
///
/// = Returns
/// A dictionary mapping every tracker glyph to its advance width.
#let glyph-widths(size) = (
  "•": measure(header-text(size: size, "•")).width,
  "●": measure(header-text(size: size, "●")).width,
  "◦": measure(header-text(size: size, "◦")).width,
  "…": measure(header-text(size: size, "…")).width,
)

/// Greedily packs tracker glyphs into rows of at most `available-width`.
///
/// `reserve` is left free at the end of every row, so a trailing `…` always
/// fits on the last row.
///
/// = Parameters
/// - `dots` (array): Dot records to pack, each with a `glyph` and a `location`.
/// - `widths` (dictionary): Glyph widths as returned by `glyph-widths`.
/// - `available-width` (length): Width of a single row.
/// - `reserve` (length): Width to keep free at the end of every row.
///
/// = Returns
/// An array of rows, each being an array of dot records.
#let pack-rows(dots, widths, available-width, reserve) = {
  let rows = ()
  let row = ()
  let used = reserve
  for dot in dots {
    let width = widths.at(dot.glyph, default: available-width)
    if row.len() > 0 and used + width > available-width {
      rows.push(row)
      row = ()
      used = reserve
    }
    row.push(dot)
    used += width
  }
  if row.len() > 0 { rows.push(row) }
  rows
}

/// Builds the slide tracker of a single header cell.
///
/// Normally there is one glyph per slide. To keep the header height bounded, at
/// most `max-rows` rows are drawn: if at most `hide-limit` of the slides do not
/// fit, a dimmed `…` marks the omitted ones; otherwise the slides are grouped
/// into equal runs with one glyph per run.
///
/// `dots` is in presentation order and holds at most one `●`.
///
/// = Parameters
/// - `dots` (array): Dot records with a `glyph` and a `location`, in
///   presentation order.
/// - `widths` (dictionary): Glyph widths as returned by `glyph-widths`.
/// - `available-width` (length): Width of a single row.
/// - `max-rows` (integer): Maximum number of rows.
/// - `hide-limit` (float): Maximum share of slides hidden behind `…`.
///
/// = Returns
/// An array of rows, each being an array of dot records. Only the plain
/// one-glyph-per-slide rows keep their `location`; the collapsed glyphs of an
/// overflowing tracker are returned without one.
#let render-tracker(dots, widths, available-width, max-rows, hide-limit) = {
  if dots.len() == 0 { return () }

  let rows = pack-rows(dots, widths, available-width, 0pt)
  if rows.len() <= max-rows { return rows }

  // From here on the tracker collapses glyphs, so a glyph no longer stands for
  // a single slide. Dropping the targets draws those glyphs plain.
  let dots = dots.map(d => (glyph: d.glyph, location: none))

  // Fill `max-rows` rows, leaving room on the last one for a trailing ellipsis
  // and for the slightly wider marker of the current slide.
  let ellipsis = widths.at("…")
  let marker = widths.at("●") - widths.at("•")
  let keep = 0
  for row in rows.slice(0, max-rows) { keep += row.len() }
  let filled = ()
  while keep > 0 {
    let candidate = pack-rows(dots.slice(0, keep), widths, available-width, 0pt)
    if candidate.len() > max-rows { break }
    let used = 0pt
    for dot in candidate.last() { used += widths.at(dot.glyph) }
    if used + ellipsis + marker <= available-width {
      filled = candidate
      break
    }
    keep -= 1
  }

  let shown = 0
  for row in filled { shown += row.len() }
  let hidden = dots.len() - shown
  if shown > 0 and hidden <= dots.len() * hide-limit {
    if not filled.flatten().any(d => d.glyph == "●") {
      // The current slide did not fit into the shown part, so the last shown
      // dot takes its place instead of hiding the position altogether.
      let last = filled.last()
      let patched = last.slice(0, last.len() - 1)
      patched.push((glyph: "●", location: none))
      filled = filled.slice(0, filled.len() - 1) + (patched,)
    }
    filled.last().push((glyph: "…", location: none))
    return filled
  }

  // One glyph per run of slides, so that the tracker never needs more rows
  // than allowed, no matter how long the talk is.
  let bucket = calc.max(1, calc.ceil(dots.len() / max-rows))
  let glyphs = ()
  let i = 0
  while i < dots.len() {
    let run = dots.slice(i, calc.min(i + bucket, dots.len()))
    glyphs.push((glyph: if run.any(d => d.glyph == "●") {
      "●"
    } else if run.first().glyph == "•" {
      "•"
    } else {
      "◦"
    }, location: none))
    i += bucket
  }
  pack-rows(glyphs, widths, available-width, 0pt)
}

/// Returns the height of a text block of `lines` lines at a given size.
///
/// `build` renders the measured text, so measurement and rendering agree.
///
/// = Parameters
/// - `size` (length): Font size to measure at.
/// - `lines` (integer): Number of lines.
/// - `build` (function, default: `header-text`): Renders the measured text.
///
/// = Returns
/// The height of the block.
#let line-budget(size, lines, build: header-text) = {
  let body = [x]
  for _ in range(1, lines) { body += [#linebreak()y] }
  measure(box(width: 10000cm, build(size: size, body))).height
}

/// Returns the height of a title wrapped into `max-width`.
///
/// = Parameters
/// - `title` (str): The title to measure.
/// - `size` (length): Font size of the title.
/// - `max-width` (length): Maximum width of a line.
/// - `build` (function, default: `header-text`): Renders the measured text.
///
/// = Returns
/// The height of the wrapped title.
#let title-height(title, size, max-width, build: header-text) = {
  measure(box(width: max-width, build(size: size)[#title])).height
}

/// Returns the width of `title` when it is not wrapped.
///
/// = Parameters
/// - `title` (str): The title to measure.
/// - `size` (length): Font size of the title.
/// - `build` (function, default: `header-text`): Renders the measured text.
///
/// = Returns
/// The width of the title.
#let title-width(title, size, build: header-text) = measure(build(size: size)[#title]).width

/// Checks whether a title fits into `max-lines` lines of `max-width`.
///
/// = Parameters
/// - `title` (str): The title to check.
/// - `size` (length): Font size of the title.
/// - `max-width` (length): Width of a single line.
/// - `max-lines` (integer): Maximum number of lines.
/// - `budget` (length or none, default: `none`): The height of `max-lines`
///   lines, if already measured.
/// - `build` (function, default: `header-text`): Renders the measured text.
///
/// = Returns
/// `true` if the title fits.
#let title-fits(title, size, max-width, max-lines, budget: none, build: header-text) = {
  if title.len() == 0 { return true }
  if title-width(title, size, build: build) > max-width * max-lines { return false }
  let budget = if budget == none { line-budget(size, max-lines, build: build) } else { budget }
  title-height(title, size, max-width, build: build) <= budget
}

/// Returns the number of lines the tallest of `titles` needs at a given size.
///
/// The result is the maximum over all titles, and never more than `max-lines`.
///
/// = Parameters
/// - `titles` (array): Titles to fit.
/// - `size` (length): Font size to measure at.
/// - `max-width` (length): Width of a single line.
/// - `max-lines` (integer): Largest row count of interest.
/// - `build` (function, default: `header-text`): Renders the measured text.
///
/// = Returns
/// The number of lines, between `1` and `max-lines`.
#let title-rows(titles, size, max-width, max-lines, build: header-text) = {
  let rows = max-lines
  for lines in range(1, max-lines + 1) {
    // Every candidate is measured against its own row budget: the budget of
    // `max-lines` lines would let a title of two rows pass as one.
    let fits = true
    for title in titles {
      if not title-fits(title, size, max-width, lines, build: build) {
        fits = false
        break
      }
    }
    if fits { return lines }
  }
  rows
}

/// Truncates a title to the longest prefix that still fits, adding `…`.
///
/// = Parameters
/// - `title` (str): The title to truncate.
/// - `size` (length): Font size of the title.
/// - `max-width` (length): Width of a single line.
/// - `max-lines` (integer): Maximum number of lines.
///
/// = Returns
/// The truncated title.
#let truncate-title(title, size, max-width, max-lines) = {
  let clusters = title.clusters()
  let low = 0
  let high = clusters.len()
  while low < high {
    let mid = calc.ceil((low + high) / 2)
    let candidate = utils.join-or-empty(clusters.slice(0, mid), "") + "…"
    if title-fits(candidate, size, max-width, max-lines) {
      low = mid
    } else {
      high = mid - 1
    }
  }
  utils.join-or-empty(clusters.slice(0, low), "") + "…"
}

/// Returns the dimmed color the navigation header draws non-current sections in.
///
/// = Parameters
/// - `theme` (dictionary): A resolved theme.
///
/// = Returns
/// The dimmed header text color.
#let header-dim-color(theme) = theme.sub-text.rgb().transparentize(50%)

/// Renders the navigation header: one title column per section, plus a progress
/// tracker.
///
/// Titles are set at `header-title-size`, aligned left in their columns, and
/// only the current section is highlighted; the others are dimmed with
/// `header-dim-color`. Each title links to the first slide of its section. The
/// tracker's height is bounded (see `render-tracker`), and it is optional.
///
/// = Parameters
/// - `theme` (dictionary): Theme configuration.
/// - `width` (length): Width available to the header, excluding page margins.
/// - `tracker` (boolean, default: `true`): Whether to draw the progress dots.
///
/// = Returns
/// The rendered header.
#let create-header(theme, width, tracker: true) = {
  context {
    set text(size: header-title-size, weight: "regular")

    // A document-wide `show link: underline` wraps every link, the section
    // titles included. Drawing the links plain keeps the header's appearance
    // unchanged: unwrapping the underline leaves the link, and its click
    // target, in place. Scoped to the header, so other links keep their styling.
    show underline: it => it.body

    let all-slides = query(selector(heading))
    if all-slides.len() == 0 { return }

    let current-slide-idx = {
      let n = query(selector(heading).before(here())).len()
      if n > 0 { n - 1 } else { 0 }
    }

    let dim-color = header-dim-color(theme)
    let active-color = theme.sub-text

    let section-title = ""
    // The location of the heading that opened the section being collected, so
    // that the section title can link back to the start of its slides.
    let section-location = none
    let dots = ()
    // Index of the heading that opened the section being collected, so that the
    // section can be matched against the current slide once it is closed.
    let section-start = 0
    let sections = ()

    for (i, slide) in all-slides.enumerate() {
      if slide.level == 1 {
        // A section only exists once it has a title or at least one slide, so
        // that a deck starting with a section does not get an empty cell.
        if section-title != "" or dots.len() > 0 {
          sections.push((
            title: section-title,
            dots: dots,
            location: section-location,
            // `i` is the heading that closes this section, so the section owns
            // the slides in `section-start..i`. Only the one holding the current
            // slide is highlighted: highlighting a section as soon as it starts
            // would keep every section before it lit up as well.
            current: section-start <= current-slide-idx and current-slide-idx < i,
          ))
        }
        section-title = utils.heading-title(slide.body)
        section-location = slide.location()
        section-start = i
        dots = ()
        continue
      }

      dots.push((
        glyph: if i < current-slide-idx { "•" } else if i == current-slide-idx { "●" } else { "◦" },
        location: slide.location(),
      ))
    }
    if section-title != "" or dots.len() > 0 {
      sections.push((
        title: section-title,
        dots: dots,
        location: section-location,
        current: section-start <= current-slide-idx,
      ))
    }
    if sections.len() == 0 { return }

    let num-sections = sections.len()
    // Only the tracker measures glyphs, so there is nothing to measure without
    // it.
    let widths = if tracker { glyph-widths(header-title-size) }
    // The columns share the width evenly, and a gutter keeps neighbouring
    // sections apart instead of letting their titles touch.
    let cell-width = calc.max(
      width - header-cell-gutter * (num-sections - 1),
      num-sections * 1pt,
    ) / num-sections

    let titles = sections.map(s => s.title)
    let title-size = header-title-size
    // The titles keep one size, so the shared title box is as tall as the
    // tallest of them needs and no taller: a deck whose titles all fit on one
    // line keeps a one-line header instead of reserving room for two.
    let title-lines = title-rows(titles, title-size, cell-width, header-max-title-lines)
    let title-box-height = line-budget(title-size, title-lines)

    let headers = ()
    for section in sections {
      let color = if section.current { active-color } else { dim-color }

      let title = section.title
      if not title-fits(title, title-size, cell-width, title-lines) {
        title = truncate-title(title, title-size, cell-width, title-lines)
      }

      // The title jumps back to the first slide of its section. A link to a
      // location looks like plain text by default, so the header keeps its
      // appearance and only gains the click target.
      let title-label = header-text(size: title-size, fill: color)[#title]
      if section.location != none {
        title-label = link(section.location, title-label)
      }

      // No tracker means no rows, which is what an empty `render-tracker` result
      // already spreads to.
      let rows = if tracker {
        render-tracker(
          section.dots, widths, cell-width,
          header-max-tracker-rows, header-hide-limit,
        )
      } else {
        ()
      }

      // A section without a title gets no title box at all, instead of a blank
      // line above its dots. Cells with a title keep the shared box height, so
      // their trackers stay aligned with the ones next to them.
      let title-box = if section.title == "" {
        ()
      } else {
        (
          box(
            width: 100%,
            height: title-box-height,
            // Top, not the default middle: a one-line title would otherwise
            // float inside the fixed-height box and lift its tracker away from
            // the trackers of the neighbouring cells.
            align(left + top, title-label),
          ),
          v(0.2em),
        )
      }

      headers.push(box(
        width: 100%,
        outset: (top: 0.1cm, bottom: 0.1cm),
      )[
        #grid(
          columns: 1,
          v(0.1em),
          ..title-box,
          ..rows.map(row => align(left, tracker-row(row, color))),
        )
      ])
    }

    grid(
      // The exact `cell-width` the titles were fitted and the rows were packed
      // for, not `1fr`: proportional tracks only ever approximate that division,
      // and the layout is only as good as the agreement between what is measured
      // and what is rendered.
      columns: range(num-sections).map(_ => cell-width),
      gutter: header-cell-gutter,
      ..headers,
    )
  }
}

/// Font size of the primary footer text: the author names and the title.
#let footer-text-size = 9pt

/// Font size of the secondary footer text: the institute, date and page number.
#let footer-secondary-size = 7.5pt

/// Lower bound for the automatic shrinking of the footer text.
#let footer-min-text-size = 7pt

/// Height reserved for one row of footer text.
///
/// A band of `rows` rows is `footer-band-height(rows)` tall.
#let footer-line-height = 13pt

/// Vertical padding of the footer band, above and below its text.
#let footer-band-padding = 2pt

/// Maximum number of rows the footer band may grow to.
///
/// A footer that needs more rows fails the build rather than truncating (see
/// `footer-layout`).
#let footer-max-lines = 2

/// Distance between the footer band and the slide content.
#let footer-gap = 4pt

/// Horizontal padding inside a single footer block.
#let footer-cell-padding = 6pt

/// Width shares of the three footer blocks: names with institute, title, and
/// date with page number.
#let footer-block-shares = (0.4, 0.35, 0.25)

/// Returns the text width of each footer block.
///
/// Each block keeps `footer-cell-padding` free on both sides.
///
/// = Parameters
/// - `page-width` (length): The width of the page.
///
/// = Returns
/// The three text widths, in the order the blocks are drawn.
#let footer-block-widths(page-width) = {
  let padding = footer-cell-padding
  footer-block-shares.map(share => page-width * share - padding * 2)
}

/// Builds text with the properties the footer is rendered and measured with.
///
/// = Parameters
/// - `size` (length): Font size of the text.
/// - `fill` (color): Fill of the text.
/// - `body` (str or content): The text itself.
///
/// = Returns
/// A content block with the requested text.
#let footer-text(size: footer-text-size, fill: black, body) = {
  set par(justify: false)
  text(size: size, weight: "regular", fill: fill, hyphenate: false, body)
}

/// Returns the number of rows a label needs inside a column of `row-width`.
///
/// = Parameters
/// - `label` (str): The label to measure.
/// - `size` (length): Font size to measure at.
/// - `row-width` (length): Width of a single row.
/// - `max-lines` (integer): Largest row count of interest.
///
/// = Returns
/// The number of rows, `0` for an empty label, or `none` if it needs more than
/// `max-lines` rows.
#let footer-rows(label, size, row-width, max-lines) = {
  if label.len() == 0 { return 0 }
  for rows in range(1, max-lines + 1) {
    if title-fits(label, size, row-width, rows, build: footer-text) {
      return rows
    }
  }
  none
}

/// Returns the height of a footer band of `rows` rows.
///
/// = Parameters
/// - `rows` (integer): Number of rows in the band.
/// - `line-height` (length, default: `footer-line-height`): Height of one row.
///
/// = Returns
/// The height of the band.
#let footer-band-height(rows, line-height: footer-line-height) = footer-band-padding * 2 + line-height * rows

/// Returns the height the page has to reserve for the footer.
///
/// The reservation is the height of the tallest allowed band (`max-lines` rows),
/// not of the band a particular deck needs, because a page margin cannot depend
/// on measured text.
///
/// = Parameters
/// - `footer` (dictionary): Footer configuration.
///
/// = Returns
/// The reserved height, or `0pt` if the footer is disabled.
#let footer-reserved-height(footer) = {
  if not footer.enable { return 0pt }
  footer-band-height(
    footer.at("max-lines", default: footer-max-lines),
    line-height: footer.at("line-height", default: footer-line-height),
  )
}

/// Decides the footer's appearance: the size of each label, the number of rows,
/// and where the left block splits into its two columns.
///
/// Text is shrunk from `text-size` and `secondary-size` down to `min-text-size`
/// in half-point steps, and only then wrapped, so a long label gets a smaller
/// font before a taller band. A footer that does not fit into `max-lines` rows
/// even at `min-text-size` fails the build; nothing is truncated.
///
/// = Parameters
/// - `footer` (dictionary): Footer configuration.
/// - `page-width` (length): The width of the page.
///
/// = Returns
/// A dictionary describing the footer: the primary and secondary `size`, the
/// `rows` and `band-height`, the column widths, and the exact labels to draw.
#let footer-layout(footer, page-width) = {
  let size-max = footer.at("text-size", default: footer-text-size)
  let secondary-max = footer.at("secondary-size", default: footer-secondary-size)
  let size-min = footer.at("min-text-size", default: footer-min-text-size)
  let max-lines = footer.at("max-lines", default: footer-max-lines)
  let line-height = footer.at("line-height", default: footer-line-height)
  let padding = footer-cell-padding

  let names = utils.join-or-empty(footer.authors, ", ")
  let institute = if footer.institute == none { "" } else { utils.plain-text(footer.institute) }
  let title = utils.plain-text(footer.title)
  let date = if footer.date == none { "" } else { utils.plain-text(footer.date) }
  let page-num = counter(page).display("1/1", both: true)

  // The width each block has for its text, and the width the blocks are rendered
  // with, so that the row counts below describe what is actually drawn.
  let widths = footer-block-widths(page-width)
  let block-width = widths.at(0)

  // Every block answers with the number of rows it needs and the height of its
  // text, which is what the band is made tall enough for. A block that does not
  // fit into `max-lines` rows answers with `none` for its rows.
  let empty = (rows: 0, height: 0pt)

  // The widths of the three blocks including the padding they keep on both
  // sides, which is what they are rendered as. They add up to the page width, so
  // the band is split into them without a gutter between them.
  let blocks = widths.map(w => w + padding * 2)

  // The two columns of the left block, in the order they are laid out in. The
  // widths always add up to `block-width` minus the gutter between them, so the
  // rendered grid is exactly as wide as the text was measured against.
  let split = names-width => (
    names-width: names-width,
    institute-width: block-width - padding - names-width,
  )

  let left-block = (size, secondary) => {
    if names.len() == 0 and institute.len() == 0 { return empty }
    if institute.len() == 0 {
      return (
        rows: footer-rows(names, size, block-width - padding, max-lines),
        height: title-height(names, size, block-width - padding, build: footer-text),
      )
    }
    if names.len() == 0 {
      return (
        rows: footer-rows(institute, secondary, block-width - padding, max-lines),
        height: title-height(institute, secondary, block-width - padding, build: footer-text),
        names-width: 0pt,
        institute-width: block-width - padding,
      )
    }
    // Two ways to divide the block: the institute at its own width and the
    // names in what is left, or the names at their own width and an institute
    // that wraps in what is left. Both are measured, because which one needs
    // fewer rows depends on the labels: a short institute next to a long author
    // list wants the first, a spelled out institute next to a single name wants
    // the second.
    let candidates = (
      split(calc.min(
        block-width - padding - title-width(institute, secondary, build: footer-text),
        block-width - padding,
      )),
      split(calc.min(title-width(names, size, build: footer-text), block-width - padding)),
    )
    let fits = candidate => {
      let names-rows = footer-rows(names, size, candidate.names-width, max-lines)
      let inst-rows = footer-rows(institute, secondary, candidate.institute-width, max-lines)
      if names-rows == none or inst-rows == none { return none }
      (
        rows: calc.max(names-rows, inst-rows),
        height: calc.max(
          title-height(names, size, candidate.names-width, build: footer-text),
          title-height(institute, secondary, candidate.institute-width, build: footer-text),
        ),
        ..candidate,
      )
    }
    let best = none
    for candidate in candidates {
      let measured = fits(candidate)
      if measured != none and (best == none or measured.rows < best.rows) { best = measured }
    }
    if best == none { return (rows: none, height: 0pt) }
    best
  }

  let title-block = size => (
    rows: footer-rows(title, size, widths.at(1), max-lines),
    height: title-height(title, size, widths.at(1), build: footer-text),
  )

  // The page number keeps a column of its own in the right block, so the date may
  // wrap but never into the number, and the two share the row they are fitted on.
  let right-block = secondary => {
    let right-width = widths.at(2)
    let num-rows = footer-rows(page-num, secondary, right-width, max-lines)
    let num-height = title-height(page-num, secondary, right-width, build: footer-text)
    if date.len() == 0 { return (rows: num-rows, height: num-height) }
    if num-rows == none { return (rows: none, height: 0pt) }
    let num-width = title-width(page-num, secondary, build: footer-text)
    let date-rows = footer-rows(date, secondary, right-width - num-width - padding, max-lines)
    if date-rows == none { return (rows: none, height: 0pt) }
    (
      rows: calc.max(date-rows, num-rows),
      height: calc.max(
        title-height(date, secondary, right-width - num-width - padding, build: footer-text),
        num-height,
      ),
    )
  }

  let size = size-max
  let secondary = calc.max(secondary-max, size-min)
  while size >= size-min {
    let left = left-block(size, secondary)
    let middle = title-block(size)
    let right = right-block(secondary)
    if left.rows != none and middle.rows != none and right.rows != none { break }
    // Both tiers shrink together, so the secondary labels keep their step below
    // the primary ones for as long as the shrinking goes on, down to the same
    // floor.
    size -= 0.5pt
    secondary = calc.max(secondary - 0.5pt, size-min)
  }

  // Measured again at the smallest size for the message alone, so that it reports
  // what the footer would need if the shrinking had not run out.
  let floor = calc.max(size, size-min)
  let floor-secondary = calc.max(secondary, size-min)
  let needed = rows => if rows == none { max-lines + 1 } else { rows }
  let names-needed = needed(left-block(floor, floor-secondary).rows)
  let title-needed = needed(title-block(floor).rows)
  let date-needed = needed(right-block(floor-secondary).rows)
  assert(
    calc.max(names-needed, title-needed, date-needed) <= max-lines,
    message: "pepentation: the footer needs "
      + str(calc.max(names-needed, title-needed, date-needed))
      + " rows at " + repr(size-min)
      + ", but footer.max-lines is " + str(max-lines)
      + " (authors " + str(names-needed)
      + ", title " + str(title-needed)
      + ", date " + str(date-needed) + ")."
      + " Shorten the labels, lower footer.min-text-size, or raise"
      + " footer.max-lines -- every row reserves " + repr(line-height)
      + " of slide height.",
  )

  let left = left-block(size, secondary)
  let middle = title-block(size)
  let right = right-block(secondary)
  // An empty footer still gets a band of its own, the way the filled one has.
  let rows = calc.max(left.rows, middle.rows, right.rows, 1)
  let band-height = calc.max(
    footer-band-height(rows, line-height: line-height),
    footer-band-padding * 2 + calc.max(left.height, middle.height, right.height),
  )
  let reserved = footer-band-height(max-lines, line-height: line-height)
  assert(
    band-height <= reserved,
    message: "pepentation: the footer band is " + repr(band-height)
      + " tall, while the page reserves " + repr(reserved)
      + " for it, so it would cover slide content instead of pushing it up."
      + " Raise footer.line-height or footer.max-lines.",
  )

  (
    size: size,
    secondary-size: secondary,
    rows: rows,
    band-height: band-height,
    // The widths the labels were fitted against, so that the renderer splits the
    // blocks into exactly those columns.
    block-widths: widths,
    block-bounds: blocks,
    names-width: left.at("names-width", default: block-width - padding),
    institute-width: left.at("institute-width", default: 0pt),
    number-width: title-width(page-num, secondary, build: footer-text),
    names: names,
    institute: institute,
    title: title,
    date: date,
    page: page-num,
  )
}

/// Renders the presentation footer as a band of three blocks.
///
/// The left block holds the authors and institute, the centre the title, and the
/// right the date and page number. The band's size and row count come from
/// `footer-layout`; it is as wide as the page, so the caller centres it to reach
/// both page edges.
///
/// = Parameters
/// - `footer` (dictionary): Footer configuration.
/// - `theme` (dictionary): Theme configuration.
/// - `page-width` (length): The width of the page.
///
/// = Returns
/// The rendered footer, or nothing if the footer is disabled.
#let create-footer(footer, theme, page-width) = {
  if not footer.enable { return }

  context {
    let plan = footer-layout(footer, page-width)
    let size = plan.size
    let small = plan.secondary-size
    let fill = theme.sub-text
    let padding = footer-cell-padding
    // The blocks are split into the exact widths `footer-layout` fitted their
    // labels against, not into `1fr` and `auto` tracks: proportional tracks only
    // ever approximate that division, and the row counts the plan is built from
    // would then disagree with what is rendered.
    let widths = plan.block-widths

    // The left block is always two columns, the institute at the right edge of
    // it. A column of zero width holds an empty label, which draws nothing, so
    // the two cases of a missing institute or a missing author list need no
    // branch of their own.
    let c-authors = if plan.names.len() == 0 and plan.institute.len() == 0 {
      []
    } else {
      grid(
        columns: (plan.names-width, plan.institute-width),
        column-gutter: padding,
        align: (left + horizon, right + horizon),
        footer-text(size: size, fill: fill, plan.names),
        footer-text(size: small, fill: fill, plan.institute),
      )
    }

    let c-title = footer-text(size: size, fill: fill, plan.title)

    let c-date = grid(
      columns: (widths.at(2) - plan.number-width - padding, plan.number-width),
      column-gutter: padding,
      align: (left + horizon, right + horizon),
      footer-text(size: small, fill: fill, plan.date),
      footer-text(size: small, fill: fill, plan.page),
    )

    // The band is as wide as the whole page and is centred by the caller, so it
    // reaches the page edges the way the navigation header does. Its layout height
    // is the height of its rows alone, so a band shorter than the reservation
    // leaves the rest of the reserved margin empty instead of pulling the slide
    // content down.
    box(width: page-width, grid(
      columns: plan.block-bounds,
      column-gutter: 0pt,
      box(
        width: 100%, height: plan.band-height, fill: theme.primary,
        inset: (x: padding),
        align(left + horizon, c-authors),
      ),
      box(
        width: 100%, height: plan.band-height, fill: theme.secondary,
        inset: (x: padding),
        align(center + horizon, c-title),
      ),
      box(
        width: 100%, height: plan.band-height, fill: theme.primary,
        inset: (x: padding),
        align(right + horizon, c-date),
      ),
    ))
  }
}
