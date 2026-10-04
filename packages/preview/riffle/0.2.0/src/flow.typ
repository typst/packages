// The public flow functions.

#import "content.typ": _join, _split-units
#import "geometry.typ": _calc-content-dims, _ends-block, _get-fli, _get-padding, _page-block, _page-split
#import "footnotes.typ": _fn-area, _fn-rewrite-all, _fn-scan

#let _no-indent(cont) = {
  set par(first-line-indent: 0em)
  cont
}

#let _rebuild-columns(fields, body) = {
  let count = if "count" in fields { fields.remove("count") } else { 2 }
  if count == 2 { columns(count, body, ..fields) } else {
    body
  }
}

/// Reflows `content` into (a)symmetric one- or two-column pages when it begins partway down an (a)symmetric page, without starting a new page.
///
/// The current page's margin are converted to the given margin for the reflowed region.
///
/// Footnotes are pulled out of the flow and laid out manually at the bottom of the output block, so their entries match the reflowed content instead of the page width; their numbering and `ref`s to them are preserved.
///
/// It is a `context` function, and it inspects the current page geometry and position itself.
///
/// The function cannot be nested, and `state` updates inside `content` are not supported: `content` is laid out repeatedly while the amount that fits is determined, so any state written inside it would be applied more than once. Counters that Typst resolves after layout (including manual `counter(...).update(...)` / `.step()`) are unaffected.
///
/// == Example
/// ```typ
/// #import "@preview/riffle:0.2.0": margin-reflow
///
/// #lorem(60) // occupies the top of the current asymmetric page
///
/// #margin-reflow(
///   columns: (count: 2, gutter: 14pt),
///   footnote-style: (size: 9pt),
/// )[
///   #lorem(20)#footnote[some footnote]
///
///   #lorem(40)
/// ],
/// ```
/// -> content
#let margin-reflow(
  /// The content to reflow. Paragraph breaks are honored.
  ///
  /// Example: a long sequence of paragraphs.
  /// -> content
  content,
  /// Named arguments forwarded to the column layout. Only `count` (int, default `2`) and `gutter` (length, default `4%`, relative to the reflow width) are meaningful.
  ///
  /// Example: `(count: 2, gutter: 14pt)`.
  /// -> dictionary
  columns: (count: 1, gutter: 4%),
  /// - The asymmetric (horizontal) margin to switch to, given as a page-margin dictionary such as `(inside: 1cm, outside: 3cm)` or `(left: 1cm, right: 3cm)`.
  /// - A plain length is also accepted and yields equal left/right margins. The top and bottom margins are always taken from the current page and thus ignored in this dictionary.
  /// - A string value of "symmetric" indicating symmetric margin with inside & outside set to the minimal of both.
  /// - You may also use `auto` (default value) to inherit the current margin.
  ///
  /// Example: `(inside: 2cm, outside: 4cm)`.
  /// -> auto | length | dictionary | "symmetric"
  margin: auto,
  /// Styling for the manually laid-out footnote entries.
  /// - `none` (default): use inherited defaults.
  /// - `dictionary`: used as `show footnote.entry: set text(...)` configuration (keys such as `size`, `fill`, `size`, `leading`, and of `text`'s arguments).
  /// - `function`: directly applied to the footnote body.
  ///
  /// Example: `(size: 9pt)`.
  /// -> none | dictionary | function
  footnote-style: none,
  /// Whether to set the page margin staring from the second page (or the first one if it is on the start of a page) or not.
  /// - `true` (default): use scpoced `set page(...)`, resulting in trailing pagebreak while simplifies the reflow by far.
  /// - `false`: use no `set page(...)` and reflow *every* page. May be slow in first compilation.
  ///
  /// Example: `false`.
  /// -> bool
  set-page-margin: true,
) = context {
  // check use condition
  assert(type(page.height) == length and type(page.width) == length, message: "page dimension cannot be auto")
  if type(page.margin) == dictionary {
    if "inside" in page.margin {
      assert("outside" in page.margin, message: "page margin should have both inside & outside or none")
    } else if "left" in page.margin {
      assert("right" in page.margin, message: "page margin should have both left & right or none")
    }
  }

  // check arguments
  assert(type(columns) == dictionary, message: "columns should be a dictionary")
  let column-params = columns
  if "count" not in column-params { column-params.insert("count", 1) }
  assert(column-params.count == 1 or set-page-margin, message: "cannot use set-page-margin == false when # columns > 1")
  let fn-entry = (
    gap: footnote.entry.gap,
    indent: footnote.entry.indent,
    clearance: footnote.entry.clearance,
    separator: footnote.entry.separator,
  )
  if footnote-style == none {
    fn-entry += (style: (:))
  } else if type(footnote-style) == dictionary or type(footnote-style) == function {
    fn-entry += (style: footnote-style)
  } else {
    panic("footnote-style is of unexptected type")
  }

  // get page dim
  let dims = (width: page.width, height: page.height)
  let pos = here().position()
  let (current-y, target-margin, pad-required, width) = _calc-content-dims(margin)
  let at-top = pos.y > 0pt and pos.y <= current-y.top + 1pt

  // special case 1: at top & set page
  if at-top and set-page-margin {
    return {
      set page(margin: target-margin)
      _rebuild-columns(column-params, content)
    }
  }

  // define split page function
  let split-one-page(units-ori, avail-y, pn, fn-base) = {
    let fns = _fn-scan(units-ori, fn-base)
    let units-rw = _fn-rewrite-all(units-ori, fns)
    let reserve = 0pt
    let limit = none
    let included = 0
    let j = 0
    // find suitable footnote(s)
    while j < fns.notes.len() {
      let gu = fns.unit-of-note.at(j)
      if gu >= units-ori.len() { break }
      let h = (
        measure(
          _fn-area(fns.notes.slice(0, j + 1), entry: fn-entry),
          width: width,
        ).height
          + 0.5pt
      )
      let try = _page-split(column-params, units-rw, width, avail-y - h)
      if h < avail-y and try.consumed >= gu + 1 {
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
    // split page and compose page body with footnote
    let r = _page-split(
      column-params,
      units-rw,
      width,
      avail-y - reserve,
      max-units: limit,
    )
    let body = r.chunks
    let consumed = r.consumed
    body = _get-padding(pad-required, pn)(_page-block(
      column-params,
      body,
      width,
      avail-y,
      area: area,
      reserve: reserve,
    ))
    // remove first line indent if necessary and return
    let (amt, all) = _get-fli()
    if (
      not set-page-margin
        and (
          consumed > 0
            and units-ori.len() > consumed
            and not _ends-block(units-ori.at(consumed - 1))
            and all
            and amt != 0pt
        )
    ) {
      units-ori = (h(-amt),) + units-ori.slice(consumed)
    } else {
      units-ori = units-ori.slice(consumed)
    }
    return (body, units-ori, included)
  }

  // start reflow for first page
  let ori-units = _split-units(content)
  let page-avail = dims.height - current-y.bottom - pos.y
  let page-num = here().page()
  let footnote-base = counter(footnote).get().first()
  let (page-body, left-units, footnote-included) = split-one-page(ori-units, page-avail, page-num, footnote-base)

  // special case 2: set page
  if set-page-margin {
    return {
      page-body
      if left-units.len() > 0 {
        set page(margin: target-margin)
        _rebuild-columns(column-params, _join(left-units))
      }
    }
  }

  // otherwise, reflow middle pages
  let _get-page-parts(p) = if "children" in p.body.body.fields() and p.body.body.children.len() > 2 {
    (p.body.body.children.at(0), p.body.body.children.slice(2).join())
  } else {
    (p.body.body, [])
  }
  let (page-main, page-footer) = _get-page-parts(page-body)
  let page-y = measure(page-main, width: width).height + measure(page-footer, width: width).height
  while page-y >= page-avail - (1em + par.leading).to-absolute() {
    page-body // print current page
    page-num += 1 // increase page number
    footnote-base += footnote-included
    page-avail = dims.height - current-y.top - current-y.bottom
    (page-body, left-units, footnote-included) = split-one-page(left-units, page-avail, page-num, footnote-base)
    (page-main, page-footer) = _get-page-parts(page-body)
    page-y = measure(page-main, width: width).height + measure(page-footer, width: width).height
  }

  // reflow last page
  let (last-main, last-footer) = _get-page-parts(page-body)
  let last-page-setting = page-body.fields()
  let _ = last-page-setting.remove("body")
  pad(..last-page-setting, last-main) // print last main text
  if last-footer != [] {
    figure(
      caption: none,
      gap: 0pt,
      kind: "footnote",
      numbering: none,
      placement: bottom,
      scope: "parent",
      supplement: none,
      outlined: false,
      align(start, last-footer),
    )
  }
}
