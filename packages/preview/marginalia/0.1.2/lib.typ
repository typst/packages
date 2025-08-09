
/* Config Setup */

/// #internal[Mostly internal.]
/// The counter used for the note icons.
///
/// If you use @note-numbering without @note-numbering.repeat, it is reccommended you reset this occasionally, e.g. per heading or per page.
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
  number
) = {
  let index = if repeat { calc.rem(number - 1, markers.len()) } else { number - 1 }
  let symbol = if index < markers.len() { markers.at(index) } else { str(index + 1 - markers.len()) }
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
    flush-numbers: config.at("flush-numbers", default: false),
    numbering: config.at("numbering", default: note-numbering),
  )
}

#let _config = state("_config", _fill_config())

/// This will update the marginalia config with the provided config options.
///
/// The default values for the margins have been chosen such that they match the default typst margins for a4. It is strongly recommended to change at least one of either `inner` or `outer` to be wide enough to actually contain text.
#let configure(
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
  /// If ```typc true```, will use inside/outside margins, alternating on each page. If ```typc false```, will use left/right margins with all pages the same.
  /// -> boolean
  book: false,
  /// Minimal vertical distance between notes and to wide blocks.
  /// -> length
  clearance: 8pt,
  /// Disallow note icons hanging into the whitespace.
  /// -> boolean
  flush-numbers: false,
  /// Function or `numbering`-string to generate the note markers from the `notecounter`.
  /// -> function | string
  numbering: note-numbering,
) = { }
#let configure(..config) = (
  context {
    _config.update(old => {
      if type(old) != dictionary {
        panic("marginalia _config should always be a dictionary")
      }
      _fill_config(..old, ..config)
    })
  }
)

/// Page setup helper
///
/// This will generate a dictionary ```typc ( margin: .. )``` compatible with the passed config.
/// This can then be spread into the page setup like so:
///```typ
/// #set page( ..page-setup(..config) )```
///
/// Takes the same options as @configure.
/// -> dictionary
#let page-setup(
  /// Missing entries are filled with package defaults. Note: missing entries are _not_ taken from the current marginalia config, as this would require context.
  /// -> dictionary
  ..config
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


#let _note_extends_left = state("_note_extends_left", ("1": ()))
#let _note_offset_left(page_num) = {
  let clearance = _config.get().clearance
  let extends = _note_extends_left.final().at(page_num, default: ())
  let offsets_down = ()
  let cur = _config.get().top
  for note in extends {
    // 8pt spacing between nodes
    if cur <= note.natural {
      offsets_down.push(0pt)
      cur = note.natural + note.height + clearance
    } else if note.fix {
      offsets_down.push(0pt)
      cur = note.natural + note.height + clearance
    } else {
      offsets_down.push(cur - note.natural)
      cur = cur + note.height + clearance
    }
  }

  let offsets_final_rev = ()
  let max = page.height - _config.get().bottom
  for (index, note) in extends.enumerate().rev() {
    if max >= note.natural + offsets_down.at(index) + note.height {
      offsets_final_rev.push(offsets_down.at(index))
      max = note.natural + offsets_down.at(index) - clearance
    } else if note.fix {
      offsets_final_rev.push(0pt)
      max = calc.min(note.natural - clearance, max)
    } else {
      offsets_final_rev.push(max - note.natural - note.height)
      max = max - note.height - clearance
    }
  }

  offsets_final_rev.rev()
}

#let _note_extends_right = state("_note_extends_right", ("1": ()))
#let _note_offset_right(page_num) = {
  let clearance = _config.get().clearance
  let extends = _note_extends_right.final().at(page_num, default: ())
  let offsets_down = ()
  let cur = _config.get().top
  for note in extends {
    // 8pt spacing between nodes
    if cur <= note.natural {
      offsets_down.push(0pt)
      cur = note.natural + note.height + clearance
    } else if note.fix {
      offsets_down.push(0pt)
      cur = note.natural + note.height + clearance
    } else {
      offsets_down.push(cur - note.natural)
      cur = cur + note.height + clearance
    }
  }

  let offsets_final_rev = ()
  let max = page.height - _config.get().bottom
  for (index, note) in extends.enumerate().rev() {
    if max >= note.natural + offsets_down.at(index) + note.height {
      offsets_final_rev.push(offsets_down.at(index))
      max = note.natural + offsets_down.at(index) - clearance
    } else if note.fix {
      offsets_final_rev.push(0pt)
      max = calc.min(note.natural - clearance, max)
    } else {
      offsets_final_rev.push(max - note.natural - note.height)
      max = max - note.height - clearance
    }
  }

  offsets_final_rev.rev()
}

// absolute left
/// #internal()
#let _note_left(dy: 0pt, body) = (
  context {
    let dy = dy.to-absolute()
    let anchor = here().position()
    let pagewidth = page.width
    let page = here().page()

    let width = get-left().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height

    let lineheight = measure([X]).height
    lineheight = calc.min(lineheight, height)
    let natural_position = anchor.y + dy - lineheight

    let current = _note_extends_left.get().at(str(page), default: ())
    let index = current.len()

    _note_extends_left.update(old => {
      let oldpage = old.at(str(page), default: ())
      oldpage.push((natural: natural_position, height: height, fix: false))
      old.insert(str(page), oldpage)
      old
    })

    let vadjust = dy - lineheight + _note_offset_left(str(page)).at(index, default: 0pt)
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
#let _note_right(dy: 0pt, body) = (
  context {
    let dy = dy.to-absolute()
    let anchor = here().position()
    let pagewidth = page.width
    let page = here().page()

    let width = get-right().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height

    let lineheight = measure([X]).height
    lineheight = calc.min(lineheight, height)
    let natural_position = anchor.y + dy - lineheight

    let current = _note_extends_right.get().at(str(page), default: ())
    let index = current.len()

    _note_extends_right.update(old => {
      let oldpage = old.at(str(page), default: ())
      oldpage.push((natural: natural_position, height: height, fix: false))
      old.insert(str(page), oldpage)
      old
    })

    let vadjust = dy - lineheight + _note_offset_right(str(page)).at(index, default: 0pt)
    let hadjust = pagewidth - anchor.x - get-right().far - get-right().width
    box(
      width: 0pt,
      place(
        dx: hadjust,
        dy: vadjust,
        notebox,
      ),
    )
  }
)

/// Create a marginnote.
/// Will adjust it's position downwards to avoid previously placed notes, and upwards to avoid extending past the bottom margin.
#let note(
  /// Whether to put a mark.
  /// -> boolean
  numbered: true,
  /// Whether to put it in the opposite (inner/left) margin.
  /// -> boolean
  reverse: false,
  /// Inital vertical offset of the note.
  /// Note may get shifted still to avoid other notes.
  /// -> length
  dy: 0pt,
  /// -> content
  body
) = {
  set text(size: 7.5pt, style: "normal", weight: "regular")
  if numbered {
    notecounter.step()
    let body = context if _config.get().flush-numbers {
      set par(spacing: 0.8em, leading: 0.4em, hanging-indent: 0pt)
      notecounter.display(_config.get().numbering)
      h(1.5pt)
      body
    } else {
      set par(spacing: 0.8em, leading: 0.4em, hanging-indent: 0pt)
      box(
        width: 0pt,
        {
          h(-8pt)
          h(1fr)
          notecounter.display(_config.get().numbering)
          h(1fr)
        },
      )
      h(0pt, weak: true)
      body
    }
    h(0pt, weak: true)
    box(context {
      h(1.5pt, weak: true)
      notecounter.display(_config.get().numbering)
      if _config.get().book and calc.even(here().page()) {
        if reverse {
          _note_right(dy: dy, body)
        } else {
          _note_left(dy: dy, body)
        }
      } else {
        if reverse {
          _note_left(dy: dy, body)
        } else {
          _note_right(dy: dy, body)
        }
      }
    })
  } else {
    h(0pt, weak: true)
    let body = {
      set par(spacing: 0.8em, leading: 0.4em, hanging-indent: 0pt)
      body
    }
    box(context {
      if reverse or (_config.get().book and calc.even(here().page())) {
        _note_left(dy: dy, body)
      } else {
        _note_right(dy: dy, body)
      }
    })
  }
}

/// Creates a figure in the margin.
/// -> content
#let notefigure(
  /// The figure content, e.g.~an image. Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> content
  content,
  /// Put the notefigure in the opposite margin.
  /// -> boolean
  reverse: false,
  /// How much to shift the note. ```typc 100%``` corresponds to the height of `content` + `gap`.
  /// -> relative length
  dy: 0pt - 100%,
  /// Whether to put a mark.
  /// -> boolean
  numbered: false,
  /// Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> length
  gap: 0.55em,
  /// A label to attach to the figure.
  /// -> none | label
  label: none,
  /// Pass-through to ```typ #figure()```.
  /// -> arguments
  ..figureargs,
) = (
  context {
    set figure.caption(position: bottom)
    show figure.caption: it => {
      set align(left)
      if numbered {
        context if _config.get().flush-numbers {
          notecounter.display(_config.get().numbering)
          h(1.5pt)
        } else {
          box(
            width: 0pt,
            {
              h(-8pt)
              h(1fr)
              notecounter.display(_config.get().numbering)
              h(1fr)
            },
          )
          h(0pt, weak: true)
        }
      }
      it
    }
    let width = if reverse or (_config.get().book and calc.even(here().page())) {
      get-left().width
    } else {
      get-right().width
    }
    let height = measure(width: width, content).height + measure(text(size: 7.5pt, v(gap))).height
    if numbered {
      h(1.5pt, weak: true)
      notecounter.display(_config.get().numbering)
    } else {
      h(0pt, weak: true)
    }
    let dy = 0% + 0pt + dy
    note(
      reverse: reverse,
      dy: dy.length + dy.ratio * height,
      numbered: false,
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
///```typst
///#configure(..config, book: false)
///#set page(..page-setup(..config, book: false))
///#wideblock(reverse: true)[...]
///```
/// -> content
#let wideblock(
  /// Whether to extend into the inside/left margin instead.
  /// -> boolean
  reverse: false,
  /// Whether to extend into both margins. Cannot be combined with `reverse`.
  /// -> boolean
  double: false,
  /// -> content
  body
) = (
  context {
    if double and reverse {
      panic("Cannot be both reverse and double wide.")
    }

    let oddpage = calc.odd(here().page())
    let config = _config.get()

    let left = if not (config.book) or oddpage {
      if double or reverse {
        config.inner.width + config.inner.sep
      } else {
        0pt
      }
    } else {
      if reverse {
        0pt
      } else {
        config.outer.width + config.outer.sep
      }
    }

    let right = if not (config.book) or oddpage {
      if reverse {
        0pt
      } else {
        config.outer.width + config.outer.sep
      }
    } else {
      if double or reverse {
        config.inner.width + config.inner.sep
      } else {
        0pt
      }
    }

    let position = here().position().y
    let page_num = str(here().page())
    let left-margin = get-left()
    let right-margin = get-right()
    let linewidth = page.width - left-margin.far - left-margin.width - left-margin.sep - right-margin.far - right-margin.width - right-margin.sep
    let height = measure(width: linewidth + left + right, body).height

    if left != 0pt {
      let current = _note_extends_left.get().at(page_num, default: ())
      let index = current.len()
      _note_extends_left.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, fix: true))
        old.insert(page_num, oldpage)
        old
      })
    }

    if right != 0pt {
      let current = _note_extends_right.get().at(page_num, default: ())
      let index = current.len()
      _note_extends_right.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, fix: true))
        old.insert(page_num, oldpage)
        old
      })
    }

    pad(left: -left, right: -right, body)
  }
)
