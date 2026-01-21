/// Default properties for margin notes. These can be overridden per function call, or
/// globally by calling `set-margin-note-defaults`. Available options are:
/// - `margin-right` (length): Size of the right margin
/// - `margin-left` (length): Size of the left margin
/// - `page-width` (length): Width of the page/container. This is automatically
///   inferrable when using `set-page-properties`
/// - `page-offset-x` (length): Horizontal offset of the page/container. This is
///   generally only useful if margin notes are applied inside a box/rect; at the page
///   level this can remain unspecified
/// - `stroke` (paint): Stroke to use for the margin note's border and connecting line
/// - `rect` (function): Function to use for drawing the margin note's border. This
///   function must accept positional `content` and keyword `width` arguments.
/// - `side` (side): Which side of the page to place the margin note on. Must be `left`
///   or `right`
/// - `hidden` (bool): Whether to hide the margin note. This is useful for temporarily
///   disabling margin notes without removing them from the code
#let margin-note-defaults = state(
  "margin-note-defaults",
  (
    margin-right: 0in,
    margin-left: 0in,
    page-width: none,
    page-offset-x: 0in,
    stroke: red,
    rect: rect,
    side: auto,
    hidden: false,
  )
)
#let note-descent = state("note-descent", (:))

#let _run-func-on-first-loc(func, label-name: "loc-tracker") = {
  // Some placements are determined by locations relative to a fixed point. However, typst
  // will automatically re-evaluate that computation several times, since the usage
  // of that computation will change where an element is placed (and therefore update its
  // location, and so on). Get around this with a state that only checks for the first
  // update, then ignores all subsequent updates
  let lbl = label(label-name)
  [#metadata(label-name)#lbl]
  locate(loc => {
    let found-labels = query(selector(lbl).before(loc), loc)
    if found-labels.len() == 0 {
      // Happens when a "show" rule hides a page or there is otherwise no displayed
      // content
      return
    }
    let use-loc = found-labels.last().location()

    func(use-loc)
  })
}

/// Place content at a specific location on the page relative to the top left corner
/// of the page, regardless of margins, current container, etc.
/// -> content
#let absolute-place(dx: 0em, dy: 0em, content) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    place(dx: -pos.x + dx, dy: -pos.y + dy, content)
  })
}

#let _calc-text-resize-ratio(width, spacing, styles) = {
  // Add extra margin to ensure reasonable separation between two adjacent lines
  let size = measure(text[#width], styles).width * 120%
  spacing / size * 100%
}


/// Add a series of evenly spaced x- any y-axis lines to the page.
///
/// - dx (length): Horizontal offset from the top left corner of the page
/// - dy (length): Vertical offset from the top left corner of the page
/// - stroke (paint): Stroke to use for the grid lines. The `paint` of this stroke will
///   determine the text color.
/// - width (length): Total width of the grid
/// - height (length): Total height of the grid
/// - spacing (length, array): Spacing between grid lines. If an array is provided, the
///   values are taken in (x, y) order. Cannot be provided alongside `divisions`.
/// - divisions (int, array): Number of divisions along each axis. If an array is
///   provided, the values are taken in (x, y) order. Cannot be provided alongside
///   `spacing`.
/// - square (bool): Whether to make the grid square. If `true`, and either `divisions`
///   or `spacing` is provided, the smaller of the two values will be used for both axes
///   to ensure each grid cell is square.
/// - relative (bool): If `true` (default), the grid will be placed relative to the
///   current container. If `false`, the grid will be placed relative to the top left
///   corner of the page.
#let rule-grid(
  dx: 0pt,
  dy: 0pt,
  stroke: black,
  width: 100cm,
  height: 100cm,
  spacing: none,
  divisions: none,
  square: false,
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
  if divisions != none and type(divisions) != "array" {
    divisions = (divisions, divisions)
  }
  if spacing != none and type(spacing) != "array" {
    spacing = (spacing, spacing)
  }

  let place-func = if relative {place} else {absolute-place}
  let global-dx = dx
  let global-dy = dy
  let to-int(amt) = int(amt.abs / 1pt)
  let to-pt(amt) = amt * 1pt

  let (divisions, spacing) = (divisions, spacing)

  if divisions != none {
    divisions = divisions.map(to-pt)
    spacing = (width/divisions.at(0), height/divisions.at(1))
    if square {
      spacing = (calc.min(..spacing), calc.min(..spacing))
    }
    spacing = spacing.map(to-pt)
  }
  let (x-spacing, y-spacing) = spacing

  let (width, height, step) = (width, height, x-spacing).map(to-int)
  style(styles => {
    // Assume text width is the limiting factor since a number will often be wider than
    // tall. This works in the majority of cases
    let scale-factor = _calc-text-resize-ratio(width, x-spacing, styles)

    set line(stroke: stroke)
    let dummy-line = line(stroke: stroke)
    set text(size: 1em * scale-factor, fill: dummy-line.stroke.paint)
    locate(loc => {
      for (ii, dx) in range(0, width, step: step).enumerate() {
        place-func(
          dx: global-dx, dy: global-dy,
          line(start: (dx * 1pt, 0pt), end: (dx * 1pt, height * 1pt))
        )
        place-func(
          dx: global-dx + (dx * 1pt), dy: global-dy,
          repr(ii * step)
        )
      }
      let step = to-int(y-spacing)
      for (ii, dy) in range(0, height, step: step).enumerate() {
        place-func(
          dx: global-dx, dy: global-dy,
          line(start: (0pt, dy * 1pt), end: (width * 1pt, dy * 1pt))
          )
        place-func(
          dy: global-dy + dy * 1pt, dx: global-dx,
          repr(ii * step)
        )
      }
    })
  })
}

/// Changes the default properties for margin notes. See documentation on
/// `margin-note-defaults` for available options.
#let set-margin-note-defaults(..defaults) = {
  defaults = defaults.named()
  margin-note-defaults.update(old => {
    if type(old) != "dictionary" {
      panic("margin-note-defaults must be a dictionary")
    }
    if (old + defaults).len() != old.len() {
      let allowed-keys = array(old.keys())
      let violators = array(defaults.keys()).filter(key => key not in allowed-keys)
      panic("margin-note-defaults can only contain the following keys: " + allowed-keys.join(", ") + ". Got: " + violators.join(", "))
    }
    old + defaults
  })
}

#let place-margin-rects(padding: 1%, ..rect-kwargs) = {
  let rect-kwargs = rect-kwargs.named()
  if "height" not in rect-kwargs {
    rect-kwargs.insert("height", 100%)
  }
  locate(loc => {
    let props = margin-note-defaults.at(loc)
    let (page-width, r-width, l-width) = (
      props.page-width,
      props.margin-right,
      props.margin-left,
    )
    let r(w) = rect(width: w, ..rect-kwargs)
    absolute-place(r(l-width - padding))
    absolute-place(dx: page-width + l-width + padding, r(r-width - padding))
  })
}

/// Required for `margin-note` to work, since it informs `drafting` of the page setup.
/// Since margins are not yet automatically identifiable, they must be specified
/// manually.
#let set-page-properties(margin-right: 0pt, margin-left: 0pt, ..kwargs) = {
  let kwargs = kwargs.named()
  layout(layout-size => {
    set-margin-note-defaults(
      margin-right: margin-right,
      margin-left: margin-left,
      page-width: layout-size.width,
      ..kwargs
    )
  })
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

#let _get-page-pct(props) = {
  let page-width = props.page-width
  if page-width == none {
    panic("drafting's default `page-width` must be specified and non-zero before creating a note")
  }
  page-width/100
}

#let _get-descent-at-page(loc, descents-dict: none) = {
  if descents-dict == none {
    descents-dict = note-descent.at(loc)
  }
  let page-cnt = str(counter(page).at(loc).first())
  (page-cnt, descents-dict.at(page-cnt, default: (left: 0pt, right: 0pt)))
}

#let _update-descent(side, dy, anchor-y, note-rect) = {
  style(styles => {
    locate(loc => {
      let height = measure(note-rect, styles).height
      let dy = measure(v(dy + height), styles).height + anchor-y
      note-descent.update(old => {
        let (cnt, props) = _get-descent-at-page(loc, descents-dict: old)

        props.insert(side, calc.max(dy, props.at(side)))
        old.insert(cnt, props)
        old
      })
    })
  })
}

#let _margin-note-right(body, dy, anchor-x, anchor-y, ..props) = {
  props = props.named()
  let pct = _get-page-pct(props)
  let dist-to-margin = 101*pct - anchor-x + props.margin-left
  let text-offset = 0.5em
  let right-width = props.margin-right - 4*pct

  let path-pts = _path-from-diffs(
    // make an upward line before coming back down to go all the way to
    // the top of the lettering
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (dist-to-margin, 0pt),
    (0pt, dy),
    (1*pct + right-width / 2, 0pt)
  )
  dy += text-offset
  let note-rect = props.at("rect")(
    stroke: props.stroke, width: right-width, body
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy, [#note-rect<margin-note>])
  ]
  _update-descent("right", dy, anchor-y, note-rect)
}

#let _margin-note-left(body, dy, anchor-x, anchor-y, ..props) = {
  props = props.named()
  let pct = _get-page-pct(props)
  let dist-to-margin = -anchor-x + 1*pct
  let text-offset = 0.4em
  let box-width = props.margin-left - 4*pct
  let path-pts = _path-from-diffs(
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (-anchor-x + props.margin-left + 1*pct, 0pt),
    (-2*pct, 0pt),
    (0pt, dy),
    (-1*pct - box-width / 2, 0pt),
  )
  dy += text-offset
  let note-rect = props.at("rect")(
    stroke: props.stroke,  width: box-width, body
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy, [#note-rect<margin-note>])
  ]
  _update-descent("left", dy, anchor-y, note-rect)
}

/// Places a boxed note in the left or right page margin.
///
/// - body (content): Margin note contents, usually text
/// - dy (length): Vertical offset from the note's location -- negative values
///   move the note up, positive values move the note down
/// - ..kwargs (dictionary): Additional properties to apply to the note. Accepted values are keys from `margin-note-defaults`.
#let margin-note(body, dy: auto, ..kwargs) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    let properties = margin-note-defaults.at(loc) + kwargs.named()
    let (anchor-x, anchor-y) = (pos.x - properties.page-offset-x, pos.y)
    
    if properties.hidden {
      return
    }

    if properties.side == auto {
      let (r, l) = (properties.margin-right, properties.margin-left)
      properties.side = if calc.max(r, l) == r {right} else {left}
    }

    // `let` assignment allows mutating argument
    let dy = dy
    if dy == auto {
      let (cur-page, descents) = _get-descent-at-page(loc)
      let cur-descent = descents.at(repr(properties.side))
      dy = calc.max(0pt, cur-descent - loc.position().y)
      // Notes at the end of a line misreport their x position, the placed box will wrap
      // onto the next line and invalidate the calculated distance.
      // A hacky fix is to manually replace the x position to an offset of 0.
      let is-end-of-line = calc.abs(
        anchor-x - properties.margin-left - properties.page-width - properties.page-offset-x
      ) < 0.1pt
      if is-end-of-line {
        anchor-x -= properties.page-width
      }
    }

    let margin-func = if properties.side == right {
      _margin-note-right
    } else {
      _margin-note-left
    }
    margin-func(
      body, dy, anchor-x, anchor-y, ..properties
    )
  })
}

/// Place a note inline with the text body.
///
/// - body (content): Margin note contents, usually text
/// - par-break (bool): Whether to break the paragraph after the note, which places
///   the note on its own line.
/// - ..kwargs (dictionary): Additional properties to apply to the note.
///
#let inline-note(body, par-break: true, ..kwargs) = {
  locate(loc => {
    let properties = margin-note-defaults.at(loc) + kwargs.named()
    if properties.hidden {
      return
    }

    let rect-func = properties.at("rect")
    if par-break {
      return [#rect-func(body, stroke: properties.stroke)<inline-note>]
    }
    // else
    let s = none
    let dummy-rect = rect-func(stroke: properties.stroke)[dummy content]
    let default-rect = rect(stroke: properties.stroke)[dummy content]
    if "stroke" in dummy-rect.fields() {
      s = dummy-rect.stroke
    } else {
      s = default-rect.stroke
    }
    let bottom = 0.35em
    let top = 1em
    set text(top-edge: "ascender", bottom-edge: "descender")
    let cap-line = {
      let t = if s.thickness == auto {0pt} else {s.thickness / 2}
      box(height: top, outset: (bottom: bottom + t, top: t), stroke: (left: properties.stroke))
    }
    let new-body = underline(stroke: properties.stroke, [ #body ], offset: bottom)
    if dummy-rect.has("fill") and dummy-rect.fill != auto {
      new-body = highlight(new-body, fill: dummy-rect.fill)
    }
    new-body = [
      #underline([#cap-line#new-body#cap-line], stroke: properties.stroke, offset: -top)
      <inline-note>
    ]
    new-body

  })
}
