
/* Config Setup */

/// -> counter
#let notecounter = counter("marginalia-note")

#let note-markers = ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")

#let note-markers-alternating = ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")

/// -> content
#let note-numbering(
  /// -> array
  markers: note-markers-alternating,
  /// -> bool
  repeat: true,
  /// -> function
  style: text.with(weight: 900, font: "Inter", size: 5pt, style: "normal", fill: rgb(54%, 72%, 95%)),
  /// -> auto | bool
  space: auto,
  ..,
  /// -> int
  i,
) = {
  let index = if repeat and markers.len() > 0 { calc.rem(i - 1, markers.len()) } else { i - 1 }
  let symbol = if index < markers.len() {
    markers.at(index)
    if space == true { h(2pt) }
  } else {
    str(index + 1 - markers.len())
    if space == true or space == auto { h(2pt) }
  }
  style(symbol)
}

#let _fill_config(..config) = {
  let config = config.named()
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

/// -> dictionary
#let _page-setup(
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

#let setup(
  /// -> dictionary
  inner: (far: 5mm, width: 15mm, sep: 5mm),
  /// -> dictionary
  outer: (far: 5mm, width: 15mm, sep: 5mm),
  /// -> length
  top: 2.5cm,
  /// -> length
  bottom: 2.5cm,
  /// -> bool
  book: false,
  /// -> length
  clearance: 12pt,
  /// -> content
  body,
) = {}
#let setup(..config, body) = {
  _config.update(_fill_config(..config))
  set page(.._page-setup(..config))
  show ref: it => {
    if (
      it.has("element")
        and it.element != none
        and it.element.has("children")
        and it.element.children.len() > 1
        and it.element.children.first().func() == metadata
    ) {
      if it.element.children.first().value == "_marginalia_note" {
        h(0pt, weak: true)
        show link: it => {
          show underline: i => i.body
          it
        }
        let dest = query(selector(<_marginalia_note>).after(it.element.location()))
        assert(dest.len() > 0, message: "Could not find referenced note")
        link(dest.first().location(), dest.first().value.anchor)
      } else if it.element.children.first().value == "_marginalia_notefigure" {
        let dest = query(selector(<_marginalia_notefigure_meta>).after(it.element.location()))
        assert(dest.len() > 0, message: "Could not find referenced notefigure")
        if it.has("form") {
          std.ref(dest.first().value.label, form: it.form, supplement: it.supplement)
        } else {
          std.ref(dest.first().value.label, supplement: it.supplement)
        }
      } else {
        it
      }
    } else {
      it
    }
  }
  body
}

/// -> dictionary
#let get-left() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.inner
  } else {
    return config.outer
  }
}

/// -> dictionary
#let get-right() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.outer
  } else {
    return config.inner
  }
}

/// -> content
#let show-frame(
  /// -> color
  stroke: 0.5pt + luma(90%),
  /// -> bool
  header: true,
  /// -> bool
  footer: true,
  /// -> content
  body,
) = {
  set page(background: context {
    let leftm = get-left()
    let rightm = get-right()

    let topm = _config.get().top
    let ascent = page.header-ascent.ratio * topm + page.header-ascent.length
    place(top, dy: topm, line(length: 100%, stroke: stroke))
    if header {
      place(top, dy: topm - ascent, line(length: 100%, stroke: stroke))
    }

    let bottomm = _config.get().bottom
    let descent = page.footer-descent.ratio * bottomm + page.footer-descent.length
    place(bottom, dy: -bottomm, line(length: 100%, stroke: stroke))
    if footer {
      place(bottom, dy: -bottomm + descent, line(length: 100%, stroke: stroke))
    }

    place(dx: leftm.far, rect(width: leftm.width, height: 100%, stroke: (x: stroke)))
    place(dx: leftm.far + leftm.width + leftm.sep, line(length: 100%, stroke: stroke, angle: 90deg))

    place(right, dx: -rightm.far, rect(width: rightm.width, height: 100%, stroke: (x: stroke)))
    place(right, dx: -rightm.far - rightm.width - rightm.sep, line(length: 100%, stroke: stroke, angle: 90deg))
  })

  body
}

/// -> dictionary
#let _calculate-offsets(
  /// -> dictionary
  page,
  /// -> dictionary
  items,
  /// -> length
  clearance,
) = {
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
          positions_d.push((key, position))
          empty -= fault
          cur = position + items.at(key).height + clearance
        }
      } else {
        if prev-shift-avoid {
          positions_d.push((key, cur))
          cur = cur + items.at(key).height + clearance
        } else {
          positions_d.push((key, position + fault - empty))
          cur = position + fault - empty + items.at(key).height + clearance
          empty = 0pt
        }
      }
    } else if items.at(key).shift == false {
      if (
        positions_d.len() > 0
          and fault > empty
          and items.at(positions_d.last().at(0)).shift != false
          and ((not items.at(key).keep-order) or (not items.at(positions_d.last().at(0)).keep-order))
      ) {
        let (prev, _) = positions_d.pop()
        cur -= items.at(prev).height
        positions_d.push((key, position))
        empty = 0pt
        let new_x = calc.max(position + items.at(key).height + clearance, cur)
        cur = new_x
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
      cur = cur + items.at(key).height + clearance
    }
    prev-shift-avoid = items.at(key).shift == "avoid"
  }

  let positions = ()

  let max = if page.height == auto {
    if positions_d.len() > 0 {
      let (key, position) = positions_d.at(-1)
      position + items.at(key).height
    } else { 0pt }
  } else {
    page.height - page.bottom
  }
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
  for (key, position) in positions {
    result.insert(key, position - items.at(key).natural)
  }
  for key in ignore {
    result.insert(key, 0pt)
  }
  result
}


#let _note_extends_left = state("_note_extends_left", (:))

#let _note_extends_right = state("_note_extends_right", (:))

#let place-note(
  /// -> "right" | "left"
  side: "right",
  dy: 0pt,
  keep-order: false,
  shift: true,
  body,
) = (
  context {
    assert(side == "left" or side == "right", message: "side must be left or right.")

    let dy = dy.to-absolute()
    let anchor = here().position()
    let pagewidth = if page.flipped { page.height } else { page.width }
    let page_num = str(anchor.page)

    let width = if side == "right" { get-right().width } else { get-left().width }
    let height = measure(body, width: width).height
    let notebox = box(width: width, height: height, body)
    let natural_position = anchor.y + dy

    let extends = if side == "right" { _note_extends_right } else { _note_extends_left }

    let current = extends.get().at(page_num, default: ())
    let index = current.len()

    extends.update(old => {
      let oldpage = old.at(page_num, default: ())
      oldpage.push((natural: natural_position, height: height, shift: shift, keep-order: keep-order))
      old.insert(page_num, oldpage)
      old
    })

    let offset_page = (
      height: if page.flipped { page.width } else { page.height },
      bottom: _config.get().bottom,
      top: _config.get().top,
    )
    let offset_items = extends
      .final()
      .at(page_num, default: ())
      .enumerate()
      .map(((key, item)) => (str(key), item))
      .to-dict()
    let offset_clearance = _config.get().clearance
    let dbg = _calculate-offsets(offset_page, offset_items, offset_clearance)

    let vadjust = dy + dbg.at(str(index), default: 0pt)


    let hadjust = if side == "right" {
      pagewidth - anchor.x - get-right().far - get-right().width
    } else { get-left().far - anchor.x }


    box(width: 0pt, place(dx: hadjust, dy: vadjust, notebox))
  }
)

#let note(
  /// -> counter | none
  counter: notecounter,
  /// -> none | function | string
  numbering: note-numbering,
  /// -> none | auto | function | string
  anchor-numbering: auto,
  /// -> bool
  link-anchor: true,
  /// -> auto | bool
  flush-numbering: auto,
  /// -> auto | "outer" | "inner" | "left" | "right"
  side: auto,
  /// -> "baseline" | "top" | "bottom"
  alignment: "baseline",
  /// -> length
  dy: 0pt,
  /// -> bool
  keep-order: false,
  /// -> bool | auto | "avoid" | "ignore"
  shift: auto,
  /// -> dictionary
  text-style: (size: 9.35pt, style: "normal", weight: "regular"),
  /// -> dictionary
  par-style: (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt),
  /// -> dictionary | function
  block-style: (width: 100%),
  /// -> content
  body,
) = {
  metadata("_marginalia_note")

  let numbering = if counter == none { none } else { numbering }
  if numbering != none { counter.step() }
  let flush-numbering = if flush-numbering == auto { anchor-numbering != auto } else { flush-numbering }
  let anchor-numbering = if anchor-numbering == auto { numbering } else { anchor-numbering }

  let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }

  let text-style = (size: 9.35pt, style: "normal", weight: "regular", ..text-style)
  let par-style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt, ..par-style)

  context {
    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }

    assert(side == "left" or side == "right", message: "side must be auto, left, right, outer, or inner.")
    let body = if numbering != none {
      let number = {
        if link-anchor {
          show link: it => {
            show underline: i => i.body
            it
          }
          link(here(), counter.display(numbering))
        } else {
          counter.display(numbering)
        }
      }
      if flush-numbering {
        box(number)
        h(0pt, weak: true)
        body
      } else {
        body
        let width = measure({
          set text(..text-style)
          set par(..par-style)
          number
        }).width
        if width < 8pt { width = 8pt }
        place(top + left, dx: -width, box(width: width, {
          h(1fr)
          sym.zws
          number
          h(1fr)
        }))
      }
    } else {
      body
    }

    let block-style = if type(block-style) == function {
      block-style(side)
    } else {
      block-style
    }

    let anchor = if anchor-numbering != none and counter != none {
      counter.display(anchor-numbering)
    } else []

    let body = align(top, block(width: 100%, ..block-style, {
      set text(..text-style)
      set par(..par-style)
      [#metadata((note: true, anchor: anchor))<_marginalia_note>#body]
    }))

    let dy-adjust = if alignment == "baseline" {
      measure(text(..text-style, sym.zws)).height
    } else if alignment == "top" {
      0pt
    } else if alignment == "bottom" {
      let width = if side == "left" {
        get-left().width
      } else {
        get-right().width
      }
      measure(width: width, body).height
    } else {
      panic("Unknown value for alignment")
    }
    let dy = dy - dy-adjust

    h(0pt, weak: true)
    box({
      if anchor-numbering != none {
        if link-anchor {
          show link: it => {
            show underline: i => i.body
            it
          }
          let dest = query(selector(<_marginalia_note>).after(here()))
          if dest.len() > 0 {
            link(dest.first().location(), anchor)
          } else {
            anchor
          }
        } else {
          anchor
        }
      }
      place-note(side: side, dy: dy, keep-order: keep-order, shift: shift, body)
    })
  }
}

#let ref(
  /// -> integer
  offset,
) = context {
  h(0pt, weak: true)
  show link: it => {
    show underline: i => i.body
    it
  }
  assert(offset != 0, message: "marginalia.ref offset must not be 0.")
  if offset > 0 {
    let dest = query(selector(<_marginalia_note>).after(here()))
    assert(dest.len() > offset, message: "Not enough notes after this to reference")
    link(dest.at(offset - 1).location(), dest.at(offset - 1).value.anchor)
  } else {
    let dest = query(selector(<_marginalia_note>).before(here()))
    assert(dest.len() >= -offset, message: "Not enough notes before this to reference")
    link(dest.at(offset).location(), dest.at(offset).value.anchor)
  }
}

/// -> content
#let notefigure(
  /// -> counter | none
  counter: none,
  /// -> none | function | string
  numbering: note-numbering,
  /// -> none | auto | function | string
  anchor-numbering: auto,
  /// -> bool
  link-anchor: true,
  /// -> auto | bool
  flush-numbering: auto,
  /// -> auto | "outer" | "inner" | "left" | "right"
  side: auto,
  /// -> "baseline" | "top" | "bottom" | "caption-top"
  alignment: "baseline",
  /// -> length
  dy: 0pt,
  /// -> bool
  keep-order: false,
  /// -> bool | auto | "avoid" | "ignore"
  shift: auto,
  /// -> dictionary
  text-style: (size: 9.35pt, style: "normal", weight: "regular"),
  /// -> dictionary
  par-style: (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt),
  /// -> dictionary | function
  block-style: (width: 100%),
  /// -> function
  show-caption: (number, caption) => {
    number
    caption.supplement
    [ ]
    caption.counter.display(caption.numbering)
    caption.separator
    caption.body
  },
  /// -> length
  gap: 0.55em,
  /// -> none | label
  note-label: none,
  /// -> content
  content,
  /// -> arguments
  ..figureargs,
) = {
  [#metadata("_marginalia_notefigure")<_marginalia_notefigure>]

  let numbering = if counter == none { none } else { numbering }
  if numbering != none { counter.step() }
  let flush-numbering = if flush-numbering == auto { anchor-numbering != auto } else { flush-numbering }
  let anchor-numbering = if anchor-numbering == auto { numbering } else { anchor-numbering }

  let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }

  let text-style = (size: 9.35pt, style: "normal", weight: "regular", ..text-style)
  let par-style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt, ..par-style)

  context {
    let number = if counter != none and numbering != none {
      if link-anchor {
        show link: it => {
          show underline: i => i.body
          it
        }
        link(here(), counter.display(numbering))
      } else {
        counter.display(numbering)
      }
    } else { none }
    let number-width = if numbering != none and not flush-numbering {
      let width = measure({
        set text(..text-style)
        set par(..par-style)
        number
      }).width
      if width < 8pt { 8pt } else { width }
    } else { 0pt }

    set figure.caption(position: bottom)
    show figure.caption: it => {
      set align(left)
      if numbering != none {
        context if flush-numbering {
          show-caption(
            number,
            it,
          )
        } else {
          show-caption(
            place(
              left,
              dx: -number-width,
              box(width: number-width, {
                h(1fr)
                sym.zws
                number
                h(1fr)
              }),
            ),
            it,
          )
        }
      } else {
        context show-caption(none, it)
      }
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
      measure(width: width, {
        set text(..text-style)
        set par(..par-style)
        content
      }).height
        + measure(text(..text-style, v(gap))).height
    )
    let baseline-height = measure(text(..text-style, sym.zws)).height
    let alignment = alignment
    let dy = dy
    if alignment == "baseline" {
      alignment = "top"
      dy = dy - height - baseline-height
    } else if alignment == "caption-top" {
      alignment = "top"
      dy = dy - height
    }

    let index = query(selector(<_marginalia_notefigure>).before(here())).len()
    let figure-label = std.label("_marginalia_notefigure__" + str(index))

    [#note(
        numbering: none,
        anchor-numbering: anchor-numbering,
        link-anchor: link-anchor,
        counter: counter,
        side: side,
        dy: dy,
        alignment: alignment,
        keep-order: keep-order,
        shift: shift,
        text-style: text-style,
        par-style: par-style,
        block-style: block-style,
        [#figure(
            content,
            gap: gap,
            placement: none,
            ..figureargs,
          )#figure-label],
      )#note-label]
    [#metadata((label: figure-label))<_marginalia_notefigure_meta>]
  }
}

/// -> content
#let wideblock(
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

    assert(
      side == "left" or side == "right" or side == "both",
      message: "side must be auto, both, left, right, outer, or inner.",
    )

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
    let pagewidth = if page.flipped { page.height } else { page.width }
    let linewidth = (
      pagewidth
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



/// -> content
#let header(
  /// -> dictionary
  text-style: (:),
  ..args,
  /// -> array
  even: (),
  /// -> array
  odd: (),
) = context {
  let leftm = get-left()
  let rightm = get-right()
  let is-odd = not _config.get().book or calc.odd(here().page())

  set text(..text-style)

  let pos = args.pos()
  if pos.len() > 0 {
    if pos.len() == 1 {
      pos = (none, none, ..pos)
    } else if pos.len() == 2 {
      pos = (none, ..pos)
    }
    let (inner, center, outer) = pos
    wideblock(side: "both", {
      box(width: leftm.width, if is-odd { inner } else { outer })
      h(leftm.sep)
      box(width: 1fr, center)
      h(rightm.sep)
      box(width: rightm.width, if is-odd { outer } else { inner })
    })
  } else {
    wideblock(side: "both", {
      box(width: leftm.width, if is-odd {
        odd.at(0, default: none)
      } else {
        even.at(0, default: none)
      })
      h(leftm.sep)
      box(width: 1fr, if is-odd {
        odd.at(1, default: none)
      } else {
        even.at(1, default: none)
      })
      h(rightm.sep)
      box(width: rightm.width, if is-odd {
        odd.at(2, default: none)
      } else {
        even.at(2, default: none)
      })
    })
  }
}
