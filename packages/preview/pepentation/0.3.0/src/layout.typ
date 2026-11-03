#import "utils.typ"

/// Font size of the header titles in their unscaled form.
#let header-title-size = 14pt

/// Lower bound for automatic title shrinking in the header.
#let header-min-title-size = 9pt

/// Maximum number of lines a header title may occupy.
#let header-max-title-lines = 2

/// Maximum number of rows the slide tracker may occupy.
#let header-max-tracker-rows = 3

/// Largest share of slides that may be hidden behind a trailing ellipsis.
#let header-hide-limit = 0.25

/// Gap between two neighbouring header columns.
#let header-cell-gutter = 0.3cm

/// Builds text with the properties the header is rendered with.
///
/// The properties have to be spelled out on every call: `set text` inside a
/// `context` block does not apply to `measure` calls made in the same block,
/// and the header is built inside a heading show rule, whose ambient text is
/// bold and larger than the header itself. Measuring against that ambient
/// makes every title look too wide, so the tracker wraps early and the titles
/// shrink further than necessary.
///
/// The text is also set ragged right and without hyphenation, because a header
/// title is a label in a narrow column: justifying it would stretch the gaps and
/// hyphenating it would break the words.
///
/// # Parameters
/// - `size` (length): Font size of the text.
/// - `fill` (color): Fill of the text.
/// - `body` (str or content): The text itself.
///
/// # Returns
/// A content block with the requested text.
#let header-text(size: header-title-size, fill: black, body) = {
  // The header is a list of short labels in narrow columns, so the text is set
  // ragged right and never hyphenated: justification would stretch the gaps and
  // hyphenation would break the words. Measurement runs through here too, which
  // is what keeps `title-height` in step with what is rendered.
  set par(justify: false)
  text(size: size, weight: "regular", fill: fill, hyphenate: false, body)
}

/// Measures the width of every glyph used by the header at a given size.
///
/// The glyphs are passed to `text` as strings on purpose: the same characters
/// written as markup literals measure up to three times too wide, which would
/// make the tracker wrap long before it runs out of room.
///
/// # Parameters
/// - `size` (length): Font size to measure at.
///
/// # Returns
/// A dictionary mapping every tracker glyph to its advance width.
#let glyph-widths(size) = (
  "•": measure(header-text(size: size, "•")).width,
  "●": measure(header-text(size: size, "●")).width,
  "◦": measure(header-text(size: size, "◦")).width,
  "…": measure(header-text(size: size, "…")).width,
)

/// Greedily packs tracker glyphs into rows of at most `available-width`.
///
/// Every glyph is measured individually, because the three tracker glyphs do
/// not necessarily share the same advance width. `reserve` is left free at the
/// end of every row, which guarantees that a trailing `…` fits on the last row.
///
/// # Parameters
/// - `dots` (array): Glyph strings to pack.
/// - `widths` (dictionary): Glyph widths as returned by `glyph-widths`.
/// - `available-width` (length): Width of a single row.
/// - `reserve` (length): Width to keep free at the end of every row.
///
/// # Returns
/// An array of rows, each row being an array of glyphs.
#let pack-rows(dots, widths, available-width, reserve) = {
  let rows = ()
  let row = ()
  let used = reserve
  for dot in dots {
    let width = widths.at(dot, default: available-width)
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
/// Normally there is exactly one glyph per slide, but the height of the header
/// must not grow with the length of a talk. At most `max-rows` rows are drawn:
/// - If everything fits, one glyph per slide is used.
/// - If at most `hide-limit` of the slides do not fit, the rows are filled and
///   a dimmed `…` marks the omitted slides.
/// - Otherwise the slides are grouped into runs of `ceil(n / max-rows)` slides
///   and one glyph is drawn per run: `•` for a run in the past, `●` for the run
///   containing the current slide, `◦` for a run in the future.
///
/// `dots` has to be in presentation order and holds at most one `●`, that is
/// `•* ●? ◦*`. Both compaction steps rely on it: the space reserved for the `…`
/// only covers replacing a `•` with the wider `●`, and a run is in the past
/// exactly when it starts with a `•`.
///
/// # Parameters
/// - `dots` (array): Glyph strings, in presentation order.
/// - `widths` (dictionary): Glyph widths as returned by `glyph-widths`.
/// - `available-width` (length): Width of a single row.
/// - `max-rows` (integer): Maximum number of rows.
/// - `hide-limit` (float): Maximum share of slides hidden behind `…`.
///
/// # Returns
/// An array of rows, each row being an array of glyphs.
#let render-tracker(dots, widths, available-width, max-rows, hide-limit) = {
  if dots.len() == 0 { return () }

  let rows = pack-rows(dots, widths, available-width, 0pt)
  if rows.len() <= max-rows { return rows }

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
    for dot in candidate.last() { used += widths.at(dot) }
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
    if not filled.flatten().contains("●") {
      // The current slide did not fit into the shown part, so the last shown
      // dot takes its place instead of hiding the position altogether.
      let last = filled.last()
      let patched = last.slice(0, last.len() - 1)
      patched.push("●")
      filled = filled.slice(0, filled.len() - 1) + (patched,)
    }
    filled.last().push("…")
    return filled
  }

  // One glyph per run of slides, so that the tracker never needs more rows
  // than allowed, no matter how long the talk is.
  let bucket = calc.max(1, calc.ceil(dots.len() / max-rows))
  let glyphs = ()
  let i = 0
  while i < dots.len() {
    let run = dots.slice(i, calc.min(i + bucket, dots.len()))
    glyphs.push(if run.contains("●") {
      "●"
    } else if run.first() == "•" {
      "•"
    } else {
      "◦"
    })
    i += bucket
  }
  pack-rows(glyphs, widths, available-width, 0pt)
}

/// Returns the height of a block of `lines` lines of text at a given size.
///
/// `build` is the function that renders the text being measured, so that
/// measurement and rendering agree on size, weight, and hyphenation.
#let line-budget(size, lines, build: header-text) = {
  let body = [x]
  for _ in range(1, lines) { body += [#linebreak()y] }
  measure(box(width: 10000cm, build(size: size, body))).height
}

/// Returns the height of a title once it is wrapped into `max-width`.
#let title-height(title, size, max-width, build: header-text) = {
  measure(box(width: max-width, build(size: size)[#title])).height
}

/// Returns the width of a title if it is not wrapped at all.
#let title-width(title, size, build: header-text) = measure(build(size: size)[#title]).width

/// Checks whether a title fits into `max-lines` lines of `max-width`.
///
/// Both the width and the height have to be checked: a title that cannot be
/// broken (a single long word) keeps the height of a single line while it
/// overflows horizontally, and a title that wraps badly can need more lines
/// than its width suggests.
///
/// # Parameters
/// - `title` (str): The title to check.
/// - `size` (length): Font size of the title.
/// - `max-width` (length): Width of a single line.
/// - `max-lines` (integer): Maximum number of lines.
/// - `budget` (length or none, default: `none`): The height that `max-lines`
///   lines of text occupy, if it has already been measured for `size`.
/// - `build` (function): Function that renders the text being measured,
///   `header-text` by default.
///
/// # Returns
/// `true` if the title fits.
#let title-fits(title, size, max-width, max-lines, budget: none, build: header-text) = {
  if title.len() == 0 { return true }
  if title-width(title, size, build: build) > max-width * max-lines { return false }
  let budget = if budget == none { line-budget(size, max-lines, build: build) } else { budget }
  title-height(title, size, max-width, build: build) <= budget
}

/// Returns the largest size at which every title fits into `max-lines` lines.
///
/// # Parameters
/// - `titles` (array): Titles to fit.
/// - `widths` (array): Available width per title.
/// - `max-lines` (integer): Maximum number of lines per title.
/// - `max-size` (length): Largest size to try.
/// - `min-size` (length): Smallest size to try.
///
/// # Returns
/// The fitted size, or `none` if even `min-size` is too large.
#let fit-size(titles, widths, max-lines, max-size, min-size) = {
  let size = max-size
  while size >= min-size {
    // The line budget only depends on the size, so it is measured once per
    // step instead of once per title.
    let budget = line-budget(size, max-lines)
    let fits = true
    for (i, title) in titles.enumerate() {
      if not title-fits(title, size, widths.at(i), max-lines, budget: budget) {
        fits = false
        break
      }
    }
    if fits { return size }
    size -= 0.5pt
  }
  none
}

/// Truncates a title to the longest prefix that still fits, adding `…`.
#let truncate-title(title, size, max-width, max-lines) = {
  let clusters = title.clusters()
  let low = 0
  let high = clusters.len()
  while low < high {
    let mid = calc.ceil((low + high) / 2)
    let candidate = clusters.slice(0, mid).join("", default: "") + "…"
    if title-fits(candidate, size, max-width, max-lines) {
      low = mid
    } else {
      high = mid - 1
    }
  }
  clusters.slice(0, low).join("", default: "") + "…"
}

/// Renders the navigation header with section titles and progress tracker.
///
/// The header displays:
/// - Section titles (from level 1 headings), scaled down uniformly so that all
///   of them fit into the same number of lines, and truncated with `…` if even
///   the smallest size is not enough. Every title and tracker is aligned to the
///   left of its own column, and neighbouring columns are separated by a
///   gutter, so the header reads as one list from the left margin onwards.
/// - Progress indicators showing one glyph per slide:
///   - `•` for completed slides
///   - `●` for the current slide
///   - `◦` for upcoming slides
///   The tracker is measured instead of guessed, and its height is capped, so
///   that it never pushes the slide content down, no matter how long the talk
///   is (see `render-tracker`).
///
/// # Parameters
/// - `theme` (dictionary): Theme configuration containing color settings.
/// - `width` (length): Width available to the header, excluding page margins.
///
/// # Returns
/// A content block containing the rendered header with navigation.
#let create-header(theme, width) = {
  context {
    set text(size: header-title-size, weight: "regular")

    let all-slides = query(selector(heading))
    if all-slides.len() == 0 { return }

    let current-slide-idx = {
      let n = query(selector(heading).before(here())).len()
      if n > 0 { n - 1 } else { 0 }
    }

    let dim-color = theme.sub-text.rgb().transparentize(50%)
    let active-color = theme.sub-text

    let section-title = ""
    let dots = ()
    let is-current-section = false
    let sections = ()

    for (i, slide) in all-slides.enumerate() {
      if slide.level == 1 {
        // A section only exists once it has a title or at least one slide, so
        // that a deck starting with a section does not get an empty cell.
        if section-title != "" or dots.len() > 0 {
          sections.push((
            title: section-title,
            dots: dots,
            current: is-current-section,
          ))
        }
        section-title = utils.heading-title(slide.body)
        dots = ()
        // A section is the current one as soon as it has started: the header is
        // only drawn on slides, so the index of the current slide can never be
        // the index of a section heading itself.
        is-current-section = i <= current-slide-idx
        continue
      }

      dots.push(if i < current-slide-idx { "•" } else if i == current-slide-idx { "●" } else { "◦" })
    }
    if section-title != "" or dots.len() > 0 {
      sections.push((
        title: section-title,
        dots: dots,
        current: is-current-section,
      ))
    }
    if sections.len() == 0 { return }

    let num-sections = sections.len()
    let widths = glyph-widths(header-title-size)
    // The columns share the width evenly, and a gutter keeps neighbouring
    // sections apart instead of letting their titles touch.
    let cell-width = calc.max(
      width - header-cell-gutter * (num-sections - 1),
      num-sections * 1pt,
    ) / num-sections

    let titles = sections.map(s => s.title)
    let title-lines = 1
    let title-size = fit-size(
      titles, range(num-sections).map(_ => cell-width), title-lines,
      header-title-size, header-min-title-size,
    )
    if title-size == none {
      title-lines = header-max-title-lines
      title-size = fit-size(
        titles, range(num-sections).map(_ => cell-width), title-lines,
        header-title-size, header-min-title-size,
      )
    }
    if title-size == none { title-size = header-min-title-size }
    let title-box-height = line-budget(title-size, title-lines)

    let headers = ()
    for section in sections {
      let color = if section.current { active-color } else { dim-color }

      let title = section.title
      if not title-fits(title, title-size, cell-width, title-lines) {
        title = truncate-title(title, title-size, cell-width, title-lines)
      }

      let rows = render-tracker(
        section.dots, widths, cell-width,
        header-max-tracker-rows, header-hide-limit,
      )

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
            align(left + top, header-text(size: title-size, fill: color)[#title]),
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
          ..rows.map(row => align(left, header-text(fill: color)[#row.join()])),
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

/// Font size the primary footer text -- the author names and the title -- starts
/// out at.
#let footer-text-size = 9pt

/// Font size the secondary footer text starts out at: the institute, the date
/// and the page number.
///
/// These labels are supporting ones, so they are set a step below the names and
/// the title and keep the band from reading as one undifferentiated strip.
#let footer-secondary-size = 7.5pt

/// Lower bound for the automatic shrinking of the footer text.
#let footer-min-text-size = 7pt

/// Height reserved for one row of footer text.
///
/// A band of `rows` rows is `footer-band-height(rows)` tall, and the page
/// reserves the same height for the `footer-max-lines` rows a footer is allowed
/// to grow to (see `footer-reserved-height`). One row has to cover one line of
/// text at `text-size`: a `text-size` far above it fails the build instead of
/// drawing outside the band.
#let footer-line-height = 13pt

/// Vertical padding of the footer band, above and below its text.
#let footer-band-padding = 2pt

/// Maximum number of rows the footer band may grow to.
///
/// Nothing is truncated to stay within it: a footer that needs more rows than
/// this fails the build instead, see `footer-layout`. Two rows cover the usual
/// footers -- a couple of author names next to a short institute, or a spelled
/// out institute that wraps beside a single name -- and the page reserves the
/// height of both even for a footer that needs one, which it cannot avoid: a
/// page margin cannot depend on measured text.
#let footer-max-lines = 2

/// Distance between the footer band and the slide content.
#let footer-gap = 4pt

/// Horizontal padding inside a single footer block.
#let footer-cell-padding = 6pt

/// Width shares of the three footer blocks: the names with the institute, the
/// title, and the date with the page number.
///
/// The left block is the widest because it carries two labels and one of them,
/// the institute, is routinely a spelled out name; the title is centred in the
/// middle, so its share only has to hold it; the right block holds the date and
/// the number, which are the shortest labels of the three.
#let footer-block-shares = (0.4, 0.35, 0.25)

/// Returns the width the text of each footer block has.
///
/// A block keeps `footer-cell-padding` free on both sides, so its share of the
/// page is what is left after that. The blocks are measured against these widths
/// and rendered with them, so the row counts a plan reports describe what is
/// actually drawn.
///
/// # Parameters
/// - `page-width` (length): The width of the page.
///
/// # Returns
/// An array of the three text widths, in the order the blocks are drawn in.
#let footer-block-widths(page-width) = {
  let padding = footer-cell-padding
  footer-block-shares.map(share => page-width * share - padding * 2)
}

/// Builds text with the properties the footer is rendered with.
///
/// The size and the weight have to be spelled out on every call, for the same
/// reason as in `header-text`: the footer is rendered with the body text in
/// scope, so every `measure` call in `footer-layout` has to state its own size
/// to agree with what is rendered.
///
/// # Parameters
/// - `size` (length): Font size of the text.
/// - `fill` (color): Fill of the text.
/// - `body` (str or content): The text itself.
///
/// # Returns
/// A content block with the requested text.
#let footer-text(size: footer-text-size, fill: black, body) = {
  // The footer is a strip of short labels, so the text is set ragged right and
  // never hyphenated: justification would stretch the gaps of a name list and
  // hyphenation would break it.
  set par(justify: false)
  text(size: size, weight: "regular", fill: fill, hyphenate: false, body)
}

/// Returns the number of rows a label needs inside a column of `row-width`.
///
/// The label is wrapped the way it is rendered, so the row count follows from
/// measurement instead of from its length.
///
/// # Parameters
/// - `label` (str): The label to measure.
/// - `size` (length): Font size to measure at.
/// - `row-width` (length): Width of a single row.
/// - `max-lines` (integer): Largest row count that is still of interest.
///
/// # Returns
/// The number of rows, `0` for an empty label, or `none` if the label needs
/// more than `max-lines` rows.
#let footer-rows(label, size, row-width, max-lines) = {
  if label.len() == 0 { return 0 }
  // Every candidate is measured against its own row budget: the budget of
  // `max-lines` rows would let a label of two rows pass as one.
  for rows in range(1, max-lines + 1) {
    if title-fits(label, size, row-width, rows, build: footer-text) {
      return rows
    }
  }
  none
}

/// Returns the height of a footer band of `rows` rows.
///
/// The band also has to be tall enough for the text it holds, so
/// `footer-layout` raises this to the measured height of its labels and then
/// checks the result against the reserved height.
///
/// # Parameters
/// - `rows` (integer): Number of rows of the band.
/// - `line-height` (length): Height reserved for a single row.
///
/// # Returns
/// The height of the band.
#let footer-band-height(rows, line-height: footer-line-height) = footer-band-padding * 2 + line-height * rows

/// Returns the height the page has to reserve for the footer.
///
/// The reservation cannot follow the band. A page margin has to be a length, and
/// `set page` rejects a length that depends on measured text, while Typst does
/// not shrink the body area when a footer outgrows its margin either: the footer
/// just overlaps the body, covering slide content instead of pushing it up.
///
/// So the reservation is the height of the tallest band the configuration allows,
/// `max-lines` rows of `line-height`, and the band of a deck whose footer needs
/// fewer rows is that much shorter. The height a band leaves unused shows as
/// empty page background between it and the slide content.
///
/// # Parameters
/// - `footer` (dictionary): Footer configuration dictionary.
///
/// # Returns
/// The reserved height, or `0pt` if the footer is disabled.
#let footer-reserved-height(footer) = {
  if not footer.enable { return 0pt }
  footer-band-height(
    footer.at("max-lines", default: footer-max-lines),
    line-height: footer.at("line-height", default: footer-line-height),
  )
}

/// Decides how the footer looks: at which size each of its labels is set, how
/// many rows the band has, and where the left block splits into its two columns.
///
/// The text is shrunk first, from `text-size` and `secondary-size` down to
/// `min-text-size` in half point steps, and only then wrapped into several rows,
/// so that a long author list gets a slightly smaller font instead of a taller
/// band.
///
/// The left block holds the authors at its left edge and the institute flush
/// right, and both may use up to `max-lines` rows. Which of the two is measured
/// at its natural width is decided by trying both splits, because a spelled out
/// institute is sometimes wider than the whole block: it then takes the width
/// the names leave over and wraps beside them.
///
/// Nothing is truncated. A footer that does not fit into `max-lines` rows even at
/// `min-text-size` fails the build, because both alternatives lose information
/// silently: an ellipsis hides the end of an author list, and a band taller than
/// the reservation covers slide content.
///
/// # Parameters
/// - `footer` (dictionary): Footer configuration with `authors`, `institute`,
///   `title`, `date`, and the `text-size`, `secondary-size`, `min-text-size`,
///   `line-height`, and `max-lines` overrides.
/// - `page-width` (length): The width of the page.
///
/// # Returns
/// A dictionary describing the footer: the `size` of its primary text and the
/// `secondary-size` of the institute, date and page number, the `rows` of its
/// band and its resulting `band-height`, the `names-width`, `institute-width`
/// and `number-width` its columns are split at, and the exact `names`,
/// `institute`, `title`, `date`, and `page` labels that are drawn.
#let footer-layout(footer, page-width) = {
  let size-max = footer.at("text-size", default: footer-text-size)
  let secondary-max = footer.at("secondary-size", default: footer-secondary-size)
  let size-min = footer.at("min-text-size", default: footer-min-text-size)
  let max-lines = footer.at("max-lines", default: footer-max-lines)
  let line-height = footer.at("line-height", default: footer-line-height)
  let padding = footer-cell-padding

  let names = footer.authors.join(", ", default: "")
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
/// The footer displays:
/// - Left block: Authors at its left edge, institute flush right
/// - Center block: Short presentation title
/// - Right block: Date and page number
///
/// How tall the band is, at which size each label is set, and where the left
/// block splits are all decided by `footer-layout`, which measures the labels;
/// this only draws the plan that returns. The band therefore grows with its
/// content instead of clipping it, and how many rows it uses is always known
/// before the page reserves room for it.
///
/// # Parameters
/// - `footer` (dictionary): Footer configuration with `enable`, `title`,
///   `authors`, `institute`, and `date`.
/// - `theme` (dictionary): Theme configuration containing color settings.
/// - `page-width` (length): The width of the page.
///
/// The band is as wide as the page, so it has to be centred by the caller to
/// reach both page edges, which lines it up with the navigation header.
///
/// # Returns
/// A content block containing the rendered footer, or empty content if footer is disabled.
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
