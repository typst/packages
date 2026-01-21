#let pos-tracker = state("pos", none)
#let margin-note-defaults = state(
  "margin-note-defaults", (margin-right: 0in, margin-left: 0in, stroke: red, side: right, page-width: none, text-kwargs: none)
)

#let absolute-place(dx: 0em, dy: 0em, content) = {
  locate(loc => {
    let pos = loc.position()
    if pos-tracker.at(loc) != none {
      pos = pos-tracker.at(loc)
    } else {
      pos = loc.position()
      pos-tracker.update(pos)
    }
    place(dx: -pos.x + dx, dy: -pos.y + dy, content)
  })
  pos-tracker.update(none)
}

#let _calc-text-resize-ratio(width, spacing, styles) = {
  // Add extra digit to ensure reasonable separation between two adjacent lines
  let num-digits = calc.ceil(calc.log(width)) + 1
  // M is conventionally the widest character so it should leave enough space if determining
  // the scale factor
  let dummy-number = "M"
  for ii in range(1, num-digits) {
    dummy-number += "M"
  }
  let max-width = measure(text(dummy-number), styles).width
  spacing/max-width * 100%
}

#let rule-grid(
  color: black,
  width: 100cm,
  height: 100cm,
  spacing: none,
  divisions: none,
  relative: true,
) = {
  // Unfortunately an int cannot be constructed from a length, so get it through a
  // hacky method of converting to a string then an int
  if spacing == none and divisions == none {
    panic("Either `spacing` or `divisions` must be specified")
  }
  if spacing != none and divisions != none {
    panic("Only one of `spacing` or `divisions` can be specified")
  }
  if divisions != none {
    spacing = calc.min(width, height)/divisions
  }
  let to-int(amt) = int(float(repr(amt.abs).slice(0, -2)))
  let x-spacing = spacing
  let y-spacing = spacing
  if type(spacing) == "sequence" {
    x-spacing = spacing.at(0)
    y-spacing = spacing.at(1)
  }
  let width = to-int(width)
  let height = to-int(height)
  
  set text(size: spacing, fill: color)
  set line(stroke: color)
  
  let place-func = if relative {place} else {absolute-place}
  style(styles => {
    // text should fit within a spacing rectangle. For now assume it's good enough
    // to just check against x dimension
    let scale-factor = _calc-text-resize-ratio(width, spacing, styles)
    let scaler = scale.with(x: scale-factor, y: scale-factor, origin: top + left)

    locate(loc => {
      let step = to-int(x-spacing)
      for (ii, dx) in range(0, width, step: step).enumerate() {
        place-func(
          line(start: (dx * 1pt, 0pt), end: (dx * 1pt, height * 1pt))
        )
        place-func(
          dx: dx * 1pt, dy: 1pt,
          scaler(repr(ii * step))
        )
      }
      let step = to-int(y-spacing)
      for (ii, dy) in range(0, height, step: step).enumerate() {
        place-func(line(start: (0pt, dy * 1pt), end: (width * 1pt, dy * 1pt)))
        place-func(
          dy: dy * 1pt + 1pt, dx: 0pt,
          scaler(repr(ii * step))
        )
      }
    })
  })
}

#let set-margin-note-defaults(..defaults) = {
  margin-note-defaults.update(old => {
    for (key, value) in defaults.named().pairs() {
      old.insert(key, value)
    }
    old
  })
}

#let set-page-properties(margin-right: 0pt, margin-left: 0pt, ..kwargs) = {
  let kwargs = kwargs.named()
  // Wrapping in "place" prevents a linebreak from adjusting
  // the content
  place(
    layout(layout-size => {
      let update-dict = (
        margin-right: margin-right, margin-left: margin-left, page-width: layout-size.width,
      )
      for (kw, val) in kwargs.pairs() {
        update-dict.insert(kw, val)
      }
      set-margin-note-defaults(..update-dict)
    })
  )
}

#let margin-lines(stroke: gray + 0.5pt) = {
  locate(loc => {
    let r-margin = margin-note-defaults.at(loc).margin-right
    let l-margin = margin-note-defaults.at(loc).margin-left
    place(dx: -2%, rect(height: 100%, width: 104%, stroke: (left: stroke, right: stroke)))

    // absolute-place(dx: 100% - l-margin, line(end: (0%, 100%)))
  })
}

#let _path-from-diffs(start: (0pt, 0pt), ..diffs) = {
    let diffs = diffs.pos()
    let out-path = (start, )
    let next-pt = start
    for diff in diffs {
      next-pt = (next-pt.at(0) + diff.at(0), next-pt.at(1) + diff.at(1))
      out-path.push(next-pt)
    }
    out-path
}

#let get-page-pct(loc) = {
  let page-width = margin-note-defaults.at(loc).page-width
  if page-width == none {
    panic("drafting's default `page-width` must be specified and non-zero before creating a note")
  }
  page-width/100
}

#let _margin-note-right(body, stroke, dy, anchor-x, width, loc) = {
  let pct = get-page-pct(loc)
  let left-margin = margin-note-defaults.at(loc).margin-left

  let dist-to-margin = 101*pct - anchor-x + left-margin
  let text-offset = 0.5em
  let path-pts = _path-from-diffs(
    // make an upward line before coming back down to go all the way to
    // the top of the lettering
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (dist-to-margin, 0pt),
    (0pt, dy),
    (1*pct, 0pt)
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy + text-offset, rect(stroke: stroke, body, width: width - 4*pct))
  ]
}

#let _margin-note-left(body, stroke, dy, anchor-x, width, loc) = {
  let pct = get-page-pct(loc)
  let dist-to-margin = -anchor-x + 1*pct
  let text-offset = 0.4em
  let box-width = width - 4*pct
  let path-pts = _path-from-diffs(
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (-anchor-x + width + 1*pct, 0pt),
    (-2*pct, 0pt),
    (0pt, dy),
    (-1*pct, 0pt),
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy + text-offset, rect(stroke: stroke, body, width: box-width))
  ]
}


#let margin-note(body, dy: 0pt, ..kwargs) = {
  locate(loc => {
    let anchor-x = loc.position().x
    let properties = margin-note-defaults.at(loc)
    for (kw, val) in kwargs.named().pairs() {
      properties.insert(kw, val)
    }
    
    set text(..properties.text-kwargs) if properties.text-kwargs != none

    if properties.side == right {
      _margin-note-right(body, properties.stroke, dy, anchor-x, properties.margin-right, loc)
    } else {
      _margin-note-left(body, properties.stroke, dy, anchor-x, properties.margin-left, loc)
    }
  })
}
