
/* Config Setup */

/// #internal[Mostly internal.]
/// The counter used for the note icons.
///
/// It is recommended to reset this counter regularly if the default symbols are used,
/// as after ten notes it will start to number them.
///#example(scale-preview: 100%, `notecounter.update(1)`)
/// -> counter
#let notecounter = counter("notecounter")

#let _notenumbering = ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")
#let _notenumbering = ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")

/// #internal[Mostly internal.]
/// Format a counter like the note icons.
/// Default numbering for notes.
///#example(`notecounter.display(as-note)`)
///#example(```
///let i = 1
///while i < 12 {
///  [ #as-note(i) ]
///  i = i + 1
///}
///```)
/// - ..counter (int):
/// -> content
#let as-note(..counter) = { }
#let as-note(.., last) = {
  let symbol = if last > _notenumbering.len() or last <= 0 [ #(last - _notenumbering.len()) ] else {
    _notenumbering.at(last - 1)
  }
  return text(weight: 900, font: "Inter", size: 6pt, style: "normal", fill: rgb(54%, 72%, 95%), symbol)
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
    clearance: config.at("clearance", default: 8pt),
    flush-numbers: config.at("flush-numbers", default: false),
    numbering: config.at("numbering", default: as-note),
  )
}

#let _config = state("_config", _fill_config())

/// This will update the marginalia config with the provided config options.
///
/// The default values for the margins have been chosen such that they match the default typst margins for a4. It is strongly recommended to change at least one of either `inner` or `outer` to be wide enough to actually contain text.
/// - inner (dictionary): Inside/left margins.
///     - `far`: Distance between edge of page and margin (note) column.
///     - `width`: Width of the margin column.
///     - `sep`: Distance between margin column and main text column.
///
///     The page inside/left margin should equal `far` + `width` + `sep`.
///
///     If partial dictionary is given, it will be filled up with defaults.
/// - outer (dictionary): Outside/right margins. Analogous to `inner`.
/// - top (length): Top margin.
/// - bottom (length): Bottom margin.
/// - book (boolean): If ```typc true```, will use inside/outside margins, alternating on each page. If ```typc false```, will use left/right margins with all pages the same.
/// - clearance (length): Minimal vertical distance between notes and to wide blocks.
/// - flush-numbers (boolean): Disallow note icons hanging into the whitespace.
/// - numbering (str, function): Function or `numbering`-string to generate the note markers from the `notecounter`.
#let configure(
  inner: (far: 5mm, width: 15mm, sep: 5mm),
  outer: (far: 5mm, width: 15mm, sep: 5mm),
  top: 2.5cm,
  bottom: 2.5cm,
  book: false,
  clearance: 8pt,
  flush-numbers: false,
  numbering: as-note,
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

/* Page setup helper */

/// This will generate a dictionary ```typc ( margin: .. )``` compatible with the passed config.
/// This can then be spread into the page setup like so:
///```typ
/// #set page( ..page-setup(..config) )```
///
/// Takes the same options as @@configure().
/// - ..config (dictionary): Missing entries are filled with package defaults. Note: missing entries are _not_ taken from the current marginalia config, as this would require context.
/// -> dictionary
#let page-setup(..config) = {
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
  let cur = 0pt
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
      max = note.natural - clearance
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
  let cur = 0pt
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
      max = note.natural - clearance
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
    let lineheight = measure(v(par.leading)).height

    let natural_position = anchor.y + dy - lineheight

    let width = get-left().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height

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
    let lineheight = measure(v(par.leading)).height

    let natural_position = anchor.y + dy - lineheight

    let width = get-right().width
    let notebox = box(width: width, body)
    let height = measure(notebox).height

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
///
/// - numbered (boolean): Whether to put a mark.
/// - reverse (boolean): Whether to put it in the opposite (inner/left) margin.
/// - dy (length): Vertical offset of the note.
/// - body (content):
#let note(numbered: true, reverse: false, dy: 0pt, body) = {
  set text(size: 0.8em, style: "italic", weight: "regular")
  if numbered {
    notecounter.step()
    let body = context if _config.get().flush-numbers {
      notecounter.display(_config.get().numbering)
      h(1.5pt)
      body
    } else {
      set par(spacing: 0.55em, leading: 0.4em)
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
///
/// // - content (content): The figure content, e.g.~an image. Pass-through to ```typ #figure()```, but used to adjust the vertical position.
/// - content (content):
/// - reverse (boolean): Put the notefigure in the opposite margin.
/// - dy (relative length): How much to shift the note. ```typc 100%``` corresponds to the height of `content` + `gap`.
/// - numbered (boolean): Whether to put a mark.
/// - label (none, label): A label to attach to the figure.
/// - caption (none, content): The caption. Pass-through to ```typ #figure()```.
/// - gap (length): Pass-through to ```typ #figure()```, but used to adjust the vertical position.
/// - kind (auto, str, function): Pass-through to ```typ #figure()```.
/// - supplement (none,auto,content,function): Pass-through to ```typ #figure()```.
/// - numbering (none,str,function): Pass-through to ```typ #figure()```.
/// - outlined (boolean): Pass-through to ```typ #figure()```.
/// -> content
#let notefigure(
  content,
  reverse: false,
  dy: 0pt - 100%,
  numbered: false,
  label: none,
  gap: 0.55em,
  caption: none,
  kind: auto,
  supplement: none,
  numbering: "1",
  outlined: true,
) = { }
#let notefigure(
  content,
  reverse: false,
  dy: 0pt - 100%,
  numbered: false,
  gap: 0.55em,
  label: none,
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
    let height = measure(width: width, content).height + gap.to-absolute()
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
///
/// - reverse (boolean): Whether to extend into the inside/left margin instead.
/// - double (boolean): Whether to extend into both margins. Cannot be combined with `reverse`.
/// - body (content):
/// -> content
#let wideblock(reverse: false, double: false, body) = (
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
