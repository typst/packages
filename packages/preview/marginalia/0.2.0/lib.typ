
/* Config Setup */

/// #internal[Mostly internal.]
/// The counter used for the note icons.
///
/// If you use @note-numbering without @note-numbering.repeat, it is recommended you reset this occasionally, e.g. per heading or per page.
/// #example(scale-preview: 100%, ```typc notecounter.update(1)```)
/// -> counter
#let notecounter = counter("notecounter")

/// Icons to use for note markers.
///
/// ```typc ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")```
#let note-markers = ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")
/// Icons to use for note markers, alternating filled/outlined.
///
/// ```typc ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")```
#let note-markers-alternating = ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")

/// Format note marker
/// -> content
#let note-numbering(
  /// #example(```typ
  /// #for i in array.range(1,15) [
  ///   #note-numbering(markers: note-markers, i)
  /// ]\
  /// #for i in array.range(1,15) [
  ///   #note-numbering(markers: note-markers-alternating, i)
  /// ]
  /// ```)
  /// -> array(string)
  markers: note-markers-alternating,
  /// Whether to (```typc true```) loop over the icons, or (```typc false```) continue with numbers after icons run out.
  /// #example(```typ
  /// #for i in array.range(1,15) [
  ///   #note-numbering(repeat: true, i)
  /// ]\
  /// #for i in array.range(1,15) [
  ///   #note-numbering(repeat: false, i)
  /// ]
  /// ```)
  /// -> boolean
  repeat: true,
  ..,
  /// -> int
  number,
) = {
  let index = if repeat { calc.rem(number - 1, markers.len()) } else { number - 1 }
  let symbol = if index < markers.len() {
    markers.at(index)
  } else {
    str(index + 1 - markers.len())
    h(1.5pt)
  }
  return text(weight: 900, font: "Inter", size: 5pt, style: "normal", fill: rgb(54%, 72%, 95%), symbol)
}

///#internal()
#let _fill_config(..config) = {
  let config = config.named()
  // default margins a4 are 2.5 cm
  let inner = config.at("inner", default: (far: 5mm, width: 15mm, sep: 5mm))
  let outer = config.at("outer", default: (far: 5mm, width: 15mm, sep: 5mm))
  return (
    inner: (
      far: inner.at("far", default: 5mm),
      width: inner.at("width", default: 15mm),
      sep: inner.at("sep", default: 5mm),
    ),
    outer: (
      far: outer.at("far", default: 5mm),
      width: outer.at("width", default: 15mm),
      sep: outer.at("sep", default: 5mm),
    ),
    top: config.at("top", default: 2.5cm),
    bottom: config.at("bottom", default: 2.5cm),
    book: config.at("book", default: false),
    clearance: config.at("clearance", default: 12pt),
  )
}

#let _config = state("_config", _fill_config())

/// Page setup helper
///
/// This will generate a dictionary ```typc ( margin: .. )``` compatible with the passed config.
/// This can then be spread into the page setup like so:
///```typ
/// #set page( ..page-setup(..config) )```
///
/// Takes the same options as @setup.
/// -> dictionary
#let _page-setup(
  /// Missing entries are filled with package defaults. Note: missing entries are _not_ taken from the current marginalia config, as this would require context.
  /// -> dictionary
  ..config,
) = {
  let config = _fill_config(..config)
  if config.book {
    return (
      margin: (
        inside: config.inner.far + config.inner.width + config.inner.sep,
        outside: config.outer.far + config.outer.width + config.outer.sep,
        top: config.top,
        bottom: config.bottom,
      ),
    )
  } else {
    return (
      margin: (
        left: config.inner.far + config.inner.width + config.inner.sep,
        right: config.outer.far + config.outer.width + config.outer.sep,
        top: config.top,
        bottom: config.bottom,
      ),
    )
  }
}

/// This will update the marginalia config and setup the page with the provided config options.
/// (This means this will insert a pagebreak.)
/// 
/// Use as
/// ```typ
/// #show: marginalia.setup.with(/* options here */)
/// ```
/// 
/// The default values for the margins have been chosen such that they match the default typst margins for a4. It is strongly recommended to change at least one of either `inner` or `outer` to be wide enough to actually contain text.
///
/// #compat((
///   "0.2.0": (
///     [`numberig` has been replaced with @note.numbering/@notefigure.numbering.
///      #ergo[set \````typc numbering: /**/```\` directly on your notes instead of via @setup.\ Use ```typ #let note = note.with(numbering: /**/)``` for consistency.]],
///     [`flush-numbers` has been replaced by @note.flush-numbering.
///      #ergo[set \````typc flush-numbering: true```\` directly on your notes instead of via @setup.\ Use ```typ #let note = note.with(flush-numbering: /**/)``` for consistency.]],
///     [This function does no longer apply the configuration partially, but will reset all unspecified options to the default.
///      Additionally, it replaces the `page-setup()` function that was needed previously and is no longer called `configure()`],
///   ),
/// ))
#let setup(
  /// Inside/left margins.
  ///     - `far`: Distance between edge of page and margin (note) column.
  ///     - `width`: Width of the margin column.
  ///     - `sep`: Distance between margin column and main text column.
  ///
  /// The page inside/left margin should equal `far` + `width` + `sep`.
  ///
  /// If partial dictionary is given, it will be filled up with defaults.
  /// -> dictionary
  inner: (far: 5mm, width: 15mm, sep: 5mm),
  /// Outside/right margins. Analogous to `inner`.
  /// -> dictionary
  outer: (far: 5mm, width: 15mm, sep: 5mm),
  /// Top margin.
  /// -> length
  top: 2.5cm,
  /// Bottom margin.
  /// -> length
  bottom: 2.5cm,
  ///- If ```typc true```, will use inside/outside margins, alternating on each page.
  ///- If ```typc false```, will use left/right margins with all pages the same.
  /// -> boolean
  book: false,
  /// Minimal vertical distance between notes and to wide blocks.
  /// -> length
  clearance: 12pt,
  /// -> content
  body,
) = { }
#let setup(..config, body) = {
  _config.update(_fill_config(..config))
  set page( .._page-setup(..config) )
  body
}

/// #internal[Mostly internal.]
/// Returns a dictionary with the keys `far`, `width`, `sep` containing the respective widths of the
/// left margin on the current page. (On both even and odd pages.)
///
/// Requires context.
/// -> dictionary
#let get-left() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.inner
  } else {
    return config.outer
  }
}

/// #internal[Mostly internal.]
/// Returns a dictionary with the keys `far`, `width`, `sep` containing the respective widths of the
/// right margin on the current page. (On both even and odd pages.)
///
/// Requires context.
/// -> dictionary
#let get-right() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.outer
  } else {
    return config.inner
  }
}


/// #internal[Mostly internal.]
/// Calculates positions for notes.
///
/// Return type is of the form `(<index/id>: offset)`
/// -> dictionary
#let _calculate-offsets(
  /// Of the form
  /// ```typc
  /// (
  ///   height: length, // total page height
  ///   top: length,    // top margin
  ///   bottom: length, // bottom margin
  /// )
  /// ```
  /// -> dictionary
  page,
  /// Of the form `(<index/id>: item)` where items have the form
  /// ```typc
  /// (
  ///   natural: length,    // initial vertical position of item, relative to page
  ///   height: length,     // vertical space needed for item
  ///   clearance: length,  // vertical padding required.
  ///                       // may be collapsed at top & bottom of page, and above separators
  ///   shift: boolean | "ignore" | "avoid", // whether the item may be moved about. `auto` = move only if neccessary
  ///   keep-order: boolean,   // if false, may be reordered. if true, order relative to other `false` items is kept
  /// )
  /// ```
  /// -> dictionary
  items,
  /// -> length
  clearance,
) = {
  // sorting
  let ignore = ()
  let reoderable = ()
  let nonreoderable = ()
  for (key, item) in items.pairs() {
    if item.shift == "ignore" {
      ignore.push(key)
    } else if item.keep-order == false {
      reoderable.push((key, item.natural))
    } else {
      nonreoderable.push((key, item.natural))
    }
  }
  reoderable = reoderable.sorted(key: ((_, pos)) => pos)

  let positions = ()

  let index_r = 0
  let index_n = 0
  while index_r < reoderable.len() and index_n < nonreoderable.len() {
    if reoderable.at(index_r).at(1) <= nonreoderable.at(index_n).at(1) {
      positions.push(reoderable.at(index_r))
      index_r += 1
    } else {
      positions.push(nonreoderable.at(index_n))
      index_n += 1
    }
  }
  while index_n < nonreoderable.len() {
    positions.push(nonreoderable.at(index_n))
    index_n += 1
  }
  while index_r < reoderable.len() {
    positions.push(reoderable.at(index_r))
    index_r += 1
  }

  // shift down
  let cur = page.top
  let empty = 0pt
  let prev-shift-avoid = false
  let positions_d = ()
  for (key, position) in positions {
    let fault = cur - position
    if cur <= position {
      positions_d.push((key, position))
      if items.at(key).shift == false {
        empty = 0pt
      } else {
        empty += position - cur
      }
      cur = position + items.at(key).height + clearance
    } else if items.at(key).shift == "avoid" {
      if fault <= empty {
        if prev-shift-avoid {
          positions_d.push((key, cur))
          cur = cur + items.at(key).height + clearance
        } else {
          // can stay
          positions_d.push((key, position))
          empty -= fault // ?
          cur = position + items.at(key).height + clearance
        }
      } else {
        positions_d.push((key, position + fault - empty))
        cur = position + fault - empty + items.at(key).height + clearance
        empty = 0pt
      }
    } else if items.at(key).shift == false {
      // check if we can swap with previous
      if (
        positions_d.len() > 0
          and fault > empty
          and items.at(positions_d.last().at(0)).shift != false
          and ((not items.at(key).keep-order) or (not items.at(positions_d.last().at(0)).keep-order))
      ) {
        let (prev, _) = positions_d.pop()
        let x = cur
        positions_d.push((key, position))
        empty = 0pt
        cur = calc.max(position + items.at(key).height + clearance, cur)
        positions_d.push((prev, cur))
        cur = cur + items.at(prev).height + clearance
      } else {
        positions_d.push((key, position))
        empty = 0pt
        cur = calc.max(position + items.at(key).height + clearance, cur)
      }
    } else {
      positions_d.push((key, cur))
      empty += 0pt
      // empty = 0pt
      cur = cur + items.at(key).height + clearance
    }
    prev-shift-avoid = items.at(key).shift == "avoid"
  }

  let max = page.height - page.bottom
  let positions = ()
  for (key, position) in positions_d.rev() {
    if max > position + items.at(key).height {
      positions.push((key, position))
      max = position - clearance
    } else if items.at(key).shift == false {
      positions.push((key, position))
      max = calc.min(position - clearance, max)
    } else {
      positions.push((key, max - items.at(key).height))
      max = max - items.at(key).height - clearance
    }
  }

  let result = (:)
  for (key, position) in positions.rev() {
    result.insert(key, position - items.at(key).natural)
  }
  for key in ignore {
    result.insert(key, 0pt)
  }
  result
}

// #let _parent-note = state("_marginalia_parent-note-natural", false)

#let _note_extends_left = state("_note_extends_left", ("1": ()))
#let _note_offset_left(page_num) = {
  let page = (height: page.height, bottom: _config.get().bottom, top: _config.get().top)
  let items = _note_extends_left
    .final()
    .at(page_num, default: ())
    .enumerate()
    .map(((key, item)) => (str(key), item))
    .to-dict()
  _calculate-offsets(page, items, _config.get().clearance)
}

#let _note_extends_right = state("_note_extends_right", ("1": ()))
#let _note_offset_right(page_num) = {
  let page = (height: page.height, bottom: _config.get().bottom, top: _config.get().top)
  let items = _note_extends_right
    .final()
    .at(page_num, default: ())
    .enumerate()
    .map(((key, item)) => (str(key), item))
    .to-dict()
  _calculate-offsets(page, items, _config.get().clearance)
}

// absolute left
/// #internal()
#let _note_left(dy: 0pt, keep-order: false, shift: true, body) = (
  context {
    let dy = dy.to-absolute()
    let anchor = here().position()
    let pagewidth = page.width
    let page = here().page()

    let width = get-left().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height
    let natural_position = anchor.y + dy

    let current = _note_extends_left.get().at(str(page), default: ())
    let index = current.len()

    _note_extends_left.update(old => {
      let oldpage = old.at(str(page), default: ())
      oldpage.push((natural: natural_position, height: height, shift: shift, keep-order: keep-order))
      old.insert(str(page), oldpage)
      old
    })

    let vadjust = dy + _note_offset_left(str(page)).at(str(index), default: 0pt)
    let hadjust = get-left().far - anchor.x
    box(
      place(
        dx: hadjust,
        dy: vadjust,
        notebox,
      ),
    )
  }
)

// absolute right
/// #internal()
#let _note_right(dy: 0pt, keep-order: false, shift: true, body) = (
  context {
    let dy = dy.to-absolute()
    let anchor = here().position()
    let pagewidth = page.width
    let page = here().page()

    let width = get-right().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height
    let natural_position = anchor.y + dy

    let current = _note_extends_right.get().at(str(page), default: ())
    let index = current.len()

    // let in-parent-offset = 0pt
    // let parent = _parent-note.get()
    // if parent {
    //   let parent-pos = current.last().natural
    //   in-parent-offset = natural_position - parent-pos
    //   natural_position = parent-pos
    // }

    _note_extends_right.update(old => {
      let oldpage = old.at(str(page), default: ())
      oldpage.push((natural: natural_position, height: height, shift: shift, keep-order: keep-order))
      old.insert(str(page), oldpage)
      old
    })

    let vadjust = dy + _note_offset_right(str(page)).at(str(index), default: 0pt) // - in-parent-offset
    let hadjust = pagewidth - anchor.x - get-right().far - get-right().width

    // if parent {
    //   box(
    //     width: 0pt,
    //     place(
    //       dx: hadjust,
    //       dy: vadjust,
    //       {
    //         notebox
    //       }
    //     )
    //   )
    // } else {
    box(
      width: 0pt,
      place(
        dx: hadjust,
        dy: vadjust,
        {
          //_parent-note.update(true)
          // [#parent]
          notebox
          //_parent-note.update(false)
        },
      ),
    )
    // }
  }
)

/// Create a marginnote.
/// Will adjust it's position downwards to avoid previously placed notes, and upwards to avoid extending past the bottom margin.
///
/// #compat((
///   "0.2.0": (
///     [`reverse` has been replaced with @note.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]],
///     [`numbered` has been replaced with @note.numbering.
///      #ergo[use \````typc numbering: "none"```\` instead of \````typc numbered: false```\`]],
///   ),
/// ))
#let note(
  /// Function or `numbering`-string to generate the note markers from the `notecounter`.
  /// If none, will not step the @notecounter.
  ///
  /// Examples:
  /// - ```typc (..i) => super(numbering("1", ..i))``` for superscript numbers
  /// - ```typc (..i) => super(numbering("a", ..i))``` for superscript letters
  /// - ```typc marginalia.note-numbering.with(repeat: false, markers: ())``` for small blue numbers
  /// -> none | function | string
  numbering: note-numbering,
  /// Disallow note markers hanging into the whitespace.
  /// -> boolean
  flush-numbering: false,
  /// Which side to place the note.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// -> auto | "outer" | "inner" | "left" | "right"
  side: auto,
  /// Inital vertical offset of the note.
  /// Note may get shifted still to avoid other notes.
  /// -> length
  dy: 0pt,
  /// Whether to align the baselines or not.
  /// - If ```typc false```, the top of the note is aligned with the main-text baseline.
  /// -> boolean
  align-baseline: true,
  /// Notes with ```typc keep-order: true``` are not re-ordered relative to one another.
  ///
  /// // If ```typc auto```, defaults to false unless ```typc numbering``` is ```typc none``.
  /// // -> boolean | auto
  /// -> boolean
  keep-order: false,
  /// Whether the note may get shifted around to avoid other notes.
  /// - ```typc true```: The note may shift to avoid other notes, wide-blocks and the top/bottom margins.
  /// - ```typc false```: The note is placed exactly where it appears, and other notes may shift to avoid it.
  /// - ```typc "avoid"```: The note is only shifted if shifting other notes is not sufficent to avoid a collision.
  /// - ```typc "ignore"```: Like ```typc false```, but other notes do not try to avoid it.
  /// - ```typc auto```: ```typc true``` if numbered, ```typc "avoid"``` otherwise.
  /// -> boolean | auto | "avoid" | "ignore"
  shift: auto,
  /// Will be used to ```typc set``` the text style.
  /// -> dictionary
  text-style: (size: 0.85em, style: "normal", weight: "regular"),
  /// Will be used to ```typc set``` the par style.
  /// -> dictionary
  par-style: (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt),
  /// Will be passed to the `block` containing the note body.
  /// If this is a function, it will be called with "left" or "right" as its argument, and the result is passed to the `block`.
  /// -> dictionary | function
  block-style: (width: 100%),
  /// -> content
  body,
) = {
  // let keep-order = if keep-order == auto { not numbered } else { keep-orders }
  let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }

  if numbering != none { notecounter.step() }

  context {
    let lineheight = if align-baseline { measure(text(..text-style, sym.zws)).height } else { 0pt }
    let dy = dy - lineheight

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }

    assert(side == "left" or side == "right", message: "side must be auto, left, right, outer, or inner.")
    let note-fn = if side == "right" {
      _note_right
    } else {
      _note_left
    }

    let body = if numbering != none {
      if flush-numbering {
        box({
          notecounter.display(numbering)
          h(2pt)
        })
        h(0pt, weak: true)
        body
      } else {
        body
        place(
          top + left,
          dx: -8pt,
          box(
            width: 8pt,
            {
              h(1fr)
              sym.zws
              notecounter.display(numbering)
              h(1fr)
            },
          ),
        )
      }
    } else {
      body
    }

    let block-style = if type(block-style) == function {
      block-style(side)
    } else {
      block-style
    }

    let body = align(
      top,
      block(
        width: 100%,
        ..block-style,
        {
          set text(..text-style)
          set par(..par-style)
          body
        },
      ),
    )

    h(0pt, weak: true)
    box({
      if numbering != none {
        h(1.5pt, weak: true)
        notecounter.display(numbering)
      }
      note-fn(dy: dy, keep-order: keep-order, shift: shift, body)
    })
  }
}

/// Creates a figure in the margin.
///
/// Parameters `numbering`, `side`, `keep-order`, `shift`, `text-style`, `par-style`, and `block-style` work the same as for @note.
/// 
/// N.B. this does not take a `flush-numbering` parameter (like @note.flush-numbering), because it is not easily
/// possible for this package to insert the marker _into_ the caption without adding a newline.
///
/// #compat((
///   "0.2.0": (
///     [`reverse` has been replaced with @notefigure.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]],
///     [`numbered` has been replaced with @notefigure.numbering.
///      #ergo[use \````typc numbering: marginalia.note-numbering```\` instead of \````typc numbered: true```\`]],
///   ),
/// ))
/// -> content
#let notefigure(
  /// Same as @note.numbering, but with different default value.
  /// -> none | function | string
  numbering: none,
  /// Same as @note.side:
  /// Which side to place the note.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// -> auto | "outer" | "inner" | "left" | "right"
  side: auto,
  /// How much to shift the note. ```typc 100%``` corresponds to the height of `content` + `gap` + the first baseline.
  ///
  /// Thus ```typc dy: 0pt - 100%``` aligns the text and caption baselines.
  /// -> relative length
  dy: 0pt - 100%,
  //  Same as @note.keep-order
  /// -> boolean
  keep-order: false,
  // Same as @note.shift.
  /// -> boolean | auto | "avoid" | "ignore"
  shift: auto,
  // Will be used to ```typc set``` the text style.
  /// -> dictionary
  text-style: (size: 0.85em, style: "normal", weight: "regular"),
  /// -> dictionary
  par-style: (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt),
  /// Will be passed to the `block` containing the note body (this contains the entire figure).
  /// If this is a function, it will be called with "left" or "right" as its argument, and the result is passed to the `block`.
  /// -> dictionary | function
  block-style: (width: 100%),
  /// Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> length
  gap: 0.55em,
  /// A label to attach to the figure.
  /// -> none | label
  label: none,
  /// The figure content, e.g.~an image. Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> content
  content,
  /// Pass-through to ```typ #figure()```.
  ///
  /// (E.g. `caption`)
  /// -> arguments
  ..figureargs,
) = (
  context {
    set figure.caption(position: bottom)
    show figure.caption: it => {
      set align(left)
      if numbering != none {
        // // caption `it` seems to be block-level...
        // context if flush-numbering {
        //   notecounter.display(_config.get().numbering)
        //   h(1.5pt)
        // } else {
          place(
            dx: -8pt,
            box(
              width: 8pt,
              context {
                h(1fr)
                sym.zws
                notecounter.display(numbering)
                h(1fr)
              },
            ),
          )
        // }
      }
      it
    }

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }
    let width = if side == "left" {
      get-left().width
    } else {
      get-right().width
    }
    let height = (
      measure(
        width: width,
        {
          set text(..text-style)
          set par(..par-style)
          content
        },
      ).height
        + measure(text(..text-style, v(gap))).height
        + measure(text(..text-style, sym.zws)).height
    )
    if numbering != none {
      h(1.5pt, weak: true)
      notecounter.step()
      context { notecounter.display(numbering) }
    } else {
      h(0pt, weak: true)
    }
    let dy = 0% + 0pt + dy
    let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }
    note(
      numbering: none,
      side: side,
      dy: dy.length + dy.ratio * height,
      align-baseline: false,
      keep-order: keep-order,
      shift: shift,
      text-style: text-style,
      par-style: par-style,
      block-style: block-style,
    )[
      #figure(
        content,
        gap: gap,
        placement: none,
        ..figureargs,
      ) #label
    ]
  }
)

/// Creates a block that extends into the outside/right margin.
///
/// Note: This does not handle page-breaks sensibly.
/// If ```typc config.book = false```, this is not a problem, as then the margins on all pages are the same.
/// However, when using alternating page margins, a multi-page `wideblock` will not work properly.
/// To be able to set this appendix in a many-page wideblock, this code was used:
/// ```typ
/// #show: marginalia.setup.with(..config, book: false)
/// #wideblock(side: "inner")[...]
/// ```
///
/// #compat((
///   "0.2.0": (
///     [`reverse` and `double` have been replaced with @wideblock.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]
///      #ergo[use \````typc side: "both"```\` instead of \````typc double: true```\`]],
///   ),
/// ))
/// -> content
#let wideblock(
  /// Which side to extend into.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// -> auto | "outer" | "inner" | "left" | "right" | "both"
  side: auto,
  /// -> content
  body,
) = (
  context {
    let left-margin = get-left()
    let right-margin = get-right()

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }

    assert(side == "left" or side == "right" or side == "both", message: "side must be auto, both, left, right, outer, or inner.")

    let left = if side == "both" or side == "left" {
      left-margin.width + left-margin.sep
    } else {
      0pt
    }
    let right = if side == "both" or side == "right" {
      right-margin.width + right-margin.sep
    } else {
      0pt
    }

    let position = here().position().y
    let page_num = str(here().page())
    let linewidth = (
      page.width
        - left-margin.far
        - left-margin.width
        - left-margin.sep
        - right-margin.far
        - right-margin.width
        - right-margin.sep
    )
    let height = measure(width: linewidth + left + right, body).height

    if left != 0pt {
      let current = _note_extends_left.get().at(page_num, default: ())
      let index = current.len()
      _note_extends_left.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, shift: false, keep-order: false))
        old.insert(page_num, oldpage)
        old
      })
    }

    if right != 0pt {
      let current = _note_extends_right.get().at(page_num, default: ())
      let index = current.len()
      _note_extends_right.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, shift: false, keep-order: false))
        old.insert(page_num, oldpage)
        old
      })
    }

    pad(left: -left, right: -right, body)
  }
)
