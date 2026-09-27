// The public flow functions.

#import "content.typ": split-content, _join
#import "geometry.typ": _page-dimensions, _page-margins, _resolve-margins, _page-split, _page-block, _rebuild-columns, _no-indent, _ends-block, _is-para-break
#import "footnotes.typ": _fn-scan, _fn-rewrite-all, _fn-area

/// Reflows `content` into symmetric two-column pages when it begins partway
/// down an asymmetric page, without starting a new page.
///
/// The current page's asymmetric margins are converted to equal margins for the
/// reflowed region: the columns are widened to the symmetric content width and
/// shifted into the symmetric position, so the text already occupying the top
/// of the page is left untouched and the reflowed part runs flush to the
/// bottom. The remainder of `content` continues on the following pages, whose
/// margins are also switched to the symmetric values.
///
/// Footnotes are pulled out of the flow and laid out manually at the bottom of
/// the output block, so their entries match the widened columns instead of the
/// page width; their numbering and `ref`s to them are preserved. When the
/// content already starts at the top of the page, it is laid out directly in
/// two columns with symmetric margins.
///
/// It is a `context` function, so it inspects the current page geometry and
/// position itself.
///
/// ```typ
/// #import "@preview/margin-reflow:0.1.0": column-flow
///
/// #lorem(60) // occupies the top of the current asymmetric page
///
/// #column-flow(
///   [
///     第一段内容。#footnote[第一条脚注。]
///
///     第二段内容。
///   ],
///   gutter: 14pt,
///   footnote-entry: (indent: 0em, size: 9pt),
/// )
/// ```
/// -> content
#let column-flow(
  /// The content to reflow. Paragraph breaks are honored.
  ///
  /// Example: a sequence of exercise descriptions and bodies joined with
  /// `parbreak()`.
  /// -> content
  content,
  /// Named arguments forwarded to the two-column layout.
  /// Only `count` (int, default `2`) and `gutter` (length, default `4%`,
  /// relative to the reflow width) are meaningful.
  ///
  /// Example: `gutter: 14pt`.
  /// -> arguments
  ..columns-args,
  /// Styling for the manually laid-out footnote entries.
  /// - `none` (default): use Typst's defaults.
  /// - dictionary: used as `footnote.entry` configuration (keys such as
  ///   `indent`, `size`, `leading`, `clearance`, `gap`, `separator`, `style`).
  /// - function: shorthand for `(style: function)`.
  ///
  /// Example: `(indent: 0em, size: 9pt)`.
  /// -> none | dictionary | function
  footnote-entry: none,
) = context {
  let dims = _page-dimensions()
  let pos = here().position()
  let margins = _page-margins(dims)
  let extra = calc.abs(margins.left - margins.right)
  let symmetric = calc.min(margins.left, margins.right)
  let sym-margin = (
    top: margins.top,
    bottom: margins.bottom,
    left: symmetric,
    right: symmetric,
  )
  let params = columns-args.named()
  if "count" not in params { params.insert("count", 2) }
  let fn-entry = if footnote-entry == none {
    (:)
  } else if type(footnote-entry) == dictionary {
    footnote-entry
  } else {
    (style: footnote-entry)
  }
  let at-top = pos.y > 0pt and pos.y <= margins.top + 1pt
  if at-top {
    set page(margin: sym-margin)
    _rebuild-columns(params, content)
  } else {
    let units = split-content(content)
    let width = dims.width - margins.left - margins.right + extra
    let page-avail = dims.height - margins.bottom - pos.y
    let base = counter(footnote).get().first()
    let fns = _fn-scan(units, base)
    let units-rw = _fn-rewrite-all(units, fns)
    let reserve = 0pt
    let limit = none
    let included = 0
    let j = 0
    while j < fns.notes.len() {
      let gu = fns.unit-of-note.at(j)
      if gu >= units.len() { break }
      let h = (
        measure(
          _fn-area(fns.notes.slice(0, j + 1), entry: fn-entry),
          width: width,
        ).height
          + 0.5pt
      )
      let try = _page-split(params, units-rw, width, page-avail - h)
      if h < page-avail and try.consumed >= gu + 1 {
        reserve = h
        included = j + 1
        j += 1
      } else {
        limit = gu
        break
      }
    }
    let area = if included > 0 {
      _fn-area(fns.notes.slice(0, included), entry: fn-entry)
    } else {
      none
    }
    let r = _page-split(
      params,
      units-rw,
      width,
      page-avail - reserve,
      max-units: limit,
    )
    let body = r.chunks
    let consumed = r.consumed
    let piece = _page-block(params, body, width, page-avail, area: area, reserve: reserve)
    let padded = if margins.left > margins.right {
      pad(left: -extra, piece)
    } else {
      piece
    }
    padded
    let leftover = units.slice(consumed)
    let rest-body = if consumed > 0 and leftover.len() > 0 and not _ends-block(units.at(consumed - 1)) {
      let p = 0
      while p < leftover.len() and not _is-para-break(leftover.at(p)) { p += 1 }
      _no-indent(_join(leftover.slice(0, p))) + _join(leftover.slice(p))
    } else {
      _join(leftover)
    }
    // Switch the margins for the following pages without forcing a break: the
    // reflowed block already fills the page, so the remainder flows onto the
    // next page naturally, and nothing is emitted when everything fit.
    set page(margin: sym-margin)
    if leftover.len() > 0 { _rebuild-columns(params, rest-body) }
  }
}

/// Single-column counterpart of `column-flow`. Reflows `content` into a
/// symmetric page when it begins partway down an asymmetric page, without
/// starting a new page: the single column spans the entire symmetric content
/// width, and the remainder continues on the following symmetric pages.
///
/// It reuses `column-flow`'s splitting, page-fitting and footnote machinery:
/// passing `count: 1` already produces one full-width column, and the shared
/// helpers compensate the asymmetric margins the same way. Unlike
/// `column-flow`, the continuing flow is emitted unwrapped, so no `columns`
/// element (and its first-line-indent quirk) is introduced. When the content
/// already starts at the top of the page, it is laid out directly with
/// symmetric margins.
///
/// It is a `context` function, so it inspects the current page geometry and
/// position itself.
///
/// ```typ
/// #import "@preview/margin-reflow:0.1.0": single-flow
///
/// #lorem(60) // occupies the top of the current asymmetric page
///
/// #single-flow(
///   [
///     第一段内容。#footnote[第一条脚注。]
///
///     第二段内容。
///   ],
///   footnote-entry: (indent: 0em, size: 9pt),
/// )
/// ```
/// -> content
#let single-flow(
  /// The content to reflow. Paragraph breaks are honored.
  ///
  /// Example: a long sequence of paragraphs.
  /// -> content
  content,
  /// Styling for the manually laid-out footnote entries, identical to
  /// `column-flow`'s parameter.
  /// - `none` (default): use Typst's defaults.
  /// - dictionary: used as `footnote.entry` configuration.
  /// - function: shorthand for `(style: function)`.
  ///
  /// Example: `(indent: 0em, size: 9pt)`.
  /// -> none | dictionary | function
  footnote-entry: none,
) = context {
  let dims = _page-dimensions()
  let pos = here().position()
  let margins = _page-margins(dims)
  let extra = calc.abs(margins.left - margins.right)
  let symmetric = calc.min(margins.left, margins.right)
  let sym-margin = (
    top: margins.top,
    bottom: margins.bottom,
    left: symmetric,
    right: symmetric,
  )
  // `_page-split` and `_page-block` read the column count from `params`.
  let params = (count: 1)
  let fn-entry = if footnote-entry == none {
    (:)
  } else if type(footnote-entry) == dictionary {
    footnote-entry
  } else {
    (style: footnote-entry)
  }
  let at-top = pos.y > 0pt and pos.y <= margins.top + 1pt
  if at-top {
    set page(margin: sym-margin)
    content
  } else {
    let units = split-content(content)
    // Width of the symmetric page's content area: the asymmetric margins are
    // compensated by `extra`, so the block spans `symmetric` on both sides.
    let width = dims.width - margins.left - margins.right + extra
    let page-avail = dims.height - margins.bottom - pos.y
    let base = counter(footnote).get().first()
    let fns = _fn-scan(units, base)
    let units-rw = _fn-rewrite-all(units, fns)
    let reserve = 0pt
    let limit = none
    let included = 0
    let j = 0
    while j < fns.notes.len() {
      let gu = fns.unit-of-note.at(j)
      if gu >= units.len() { break }
      let h = (
        measure(
          _fn-area(fns.notes.slice(0, j + 1), entry: fn-entry),
          width: width,
        ).height
          + 0.5pt
      )
      let try = _page-split(params, units-rw, width, page-avail - h)
      if h < page-avail and try.consumed >= gu + 1 {
        reserve = h
        included = j + 1
        j += 1
      } else {
        limit = gu
        break
      }
    }
    let area = if included > 0 {
      _fn-area(fns.notes.slice(0, included), entry: fn-entry)
    } else {
      none
    }
    let r = _page-split(
      params,
      units-rw,
      width,
      page-avail - reserve,
      max-units: limit,
    )
    let body = r.chunks
    let consumed = r.consumed
    let piece = _page-block(params, body, width, page-avail, area: area, reserve: reserve)
    let padded = if margins.left > margins.right {
      pad(left: -extra, piece)
    } else {
      piece
    }
    padded
    let leftover = units.slice(consumed)
    let rest-body = if consumed > 0 and leftover.len() > 0 and not _ends-block(units.at(consumed - 1)) {
      let p = 0
      while p < leftover.len() and not _is-para-break(leftover.at(p)) { p += 1 }
      _no-indent(_join(leftover.slice(0, p))) + _join(leftover.slice(p))
    } else {
      _join(leftover)
    }
    // Switch the margins for the following pages without forcing a break: the
    // reflowed block already fills the page, so the remainder flows onto the
    // next page naturally, and nothing is emitted when everything fit.
    set page(margin: sym-margin)
    rest-body
  }
}

/// Reflows `content` into asymmetric margins when it begins partway down a page
/// that currently uses (typically symmetric) margins, without starting a new
/// page. The single column spans the entire asymmetric content area defined by
/// `margin`, and the remainder continues on the following pages, which are also
/// switched to that margin.
///
/// This is the reverse of `single-flow`: it is meant to return to an asymmetric
/// (book-style, wide outer margin) layout after a stretch of content that was
/// set with symmetric margins. Only the horizontal margins are taken from
/// `margin`; the top and bottom margins of the current page are preserved and
/// carried over to the following pages.
///
/// Footnotes are handled like in `column-flow` and `single-flow`. It is a
/// `context` function, so it inspects the current page geometry and position
/// itself.
///
/// ```typ
/// #import "@preview/margin-reflow:0.1.0": asymmetric-flow
///
/// #asymmetric-flow(
///   [
///     第一段内容。#footnote[第一条脚注。]
///
///     第二段内容。
///   ],
///   (inside: 1.75cm, outside: 6.45cm),
///   footnote-entry: (indent: 0em, size: 9pt),
/// )
/// ```
/// -> content
#let asymmetric-flow(
  /// The content to reflow. Paragraph breaks are honored.
  ///
  /// Example: a long sequence of paragraphs.
  /// -> content
  content,
  /// The asymmetric (horizontal) margin to switch to, given as a page-margin
  /// dictionary such as `(inside: 1cm, outside: 3cm)` or
  /// `(left: 1cm, right: 3cm)`. `inside`/`outside` are resolved against the
  /// current page parity, like `page.margin`. A plain length or `auto` is also
  /// accepted and yields equal left/right margins. The top and bottom margins
  /// are always taken from the current page.
  ///
  /// Example: `(inside: 2cm, outside: 4cm)`.
  /// -> auto | length | dictionary
  margin,
  /// Styling for the manually laid-out footnote entries, identical to
  /// `column-flow`'s parameter.
  /// -> none | dictionary | function
  footnote-entry: none,
) = context {
  let dims = _page-dimensions()
  let pos = here().position()
  let current = _page-margins(dims)
  // Only the horizontal margins are taken from `margin`; vertical margins
  // follow the current page so a mid-page switch does not move the baseline
  // grid of the following pages.
  let target-margin = if type(margin) == dictionary {
    let horizontal = (:)
    for key in ("left", "right", "inside", "outside", "x") {
      if key in margin { horizontal.insert(key, margin.at(key)) }
    }
    (top: current.top, bottom: current.bottom) + horizontal
  } else {
    (top: current.top, bottom: current.bottom, x: margin)
  }
  let target = _resolve-margins(target-margin, dims, here().page())
  let params = (count: 1)
  let fn-entry = if footnote-entry == none {
    (:)
  } else if type(footnote-entry) == dictionary {
    footnote-entry
  } else {
    (style: footnote-entry)
  }
  let at-top = pos.y > 0pt and pos.y <= current.top + 1pt
  if at-top {
    set page(margin: target-margin)
    content
  } else {
    let units = split-content(content)
    // The single column spans the whole asymmetric content area.
    let width = dims.width - target.left - target.right
    let page-avail = dims.height - current.bottom - pos.y
    let base = counter(footnote).get().first()
    let fns = _fn-scan(units, base)
    let units-rw = _fn-rewrite-all(units, fns)
    let reserve = 0pt
    let limit = none
    let included = 0
    let j = 0
    while j < fns.notes.len() {
      let gu = fns.unit-of-note.at(j)
      if gu >= units.len() { break }
      let h = (
        measure(
          _fn-area(fns.notes.slice(0, j + 1), entry: fn-entry),
          width: width,
        ).height
          + 0.5pt
      )
      let try = _page-split(params, units-rw, width, page-avail - h)
      if h < page-avail and try.consumed >= gu + 1 {
        reserve = h
        included = j + 1
        j += 1
      } else {
        limit = gu
        break
      }
    }
    let area = if included > 0 {
      _fn-area(fns.notes.slice(0, included), entry: fn-entry)
    } else {
      none
    }
    let r = _page-split(
      params,
      units-rw,
      width,
      page-avail - reserve,
      max-units: limit,
    )
    let body = r.chunks
    let consumed = r.consumed
    let piece = _page-block(params, body, width, page-avail, area: area, reserve: reserve)
    // Shift the block from the current content start to the asymmetric start.
    let shift = target.left - current.left
    let padded = if shift == 0pt { piece } else { pad(left: shift, piece) }
    padded
    let leftover = units.slice(consumed)
    let rest-body = if consumed > 0 and leftover.len() > 0 and not _ends-block(units.at(consumed - 1)) {
      let p = 0
      while p < leftover.len() and not _is-para-break(leftover.at(p)) { p += 1 }
      _no-indent(_join(leftover.slice(0, p))) + _join(leftover.slice(p))
    } else {
      _join(leftover)
    }
    // Switch the margins for the following pages without forcing a break: the
    // reflowed block already fills the page, so the remainder flows onto the
    // next page naturally, and nothing is emitted when everything fit.
    set page(margin: target-margin)
    rest-body
  }
}
