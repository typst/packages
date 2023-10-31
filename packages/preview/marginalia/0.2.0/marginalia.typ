/// Package marginalia: add margin annotations

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
/// - `numbering` (bool): Whether to add a number to the margin note. The number will appear before the note body and on the main text as a superscript.
/// - `numbering-format` (string): The format to use when displaying the note numbers.
/// - `super-numbering-format` (string): The format to use when displaying the note number as a superscript in the main text.
/// - `font-size` (size): The font size to use for the notes body text.
/// - `font-color` (color): The color used for the notes body text.
#let margin-note-defaults = state("margin-note-defaults", (
  margin-right: 0in,
  margin-left: 0in,
  page-width: none,
  page-offset-x: 0in,
  stroke: none,
  rect: rect,
  side: auto,
  hidden: false,
  numbering: true,
  numbering-format: "1.",
  super-numbering-format: "1",
  font-size: 9pt,
  font-color: gray.darken(60%),
))

#let note-descent = state("note-descent", (:))

/// Sets the global margin note defaults.
///
/// - ..defaults (dict): Margin note options. Keys allowed are any of the described in the `margin-note-defaults` dictionary above.
#let set-margin-note-defaults(..defaults) = {
  defaults = defaults.named()
  margin-note-defaults.update(
    old => {
      if type(old) != "dictionary" {
        panic("margin-note-defaults must be a dictionary")
      }
      if (old + defaults).len() != old.len() {
        let allowed-keys = array(old.keys())
        let violators = array(defaults.keys()).filter(key => key not in allowed-keys)
        panic(
          "margin-note-defaults can only contain the following keys: " + allowed-keys.join(", ") + ". Got: " + violators.join(", "),
        )
      }
      old + defaults
    },
  )
}

#let set-page-properties(margin-right: 0pt, margin-left: 0pt, ..kwargs) = {
  let kwargs = kwargs.named()
  layout(layout-size => {
    set-margin-note-defaults(
      margin-right: margin-right,
      margin-left: margin-left,
      page-width: layout-size.width,
      ..kwargs,
    )
  })
}

#let _path-from-diffs(start: (0pt, 0pt), ..diffs) = {
  let diffs = diffs.pos()
  let out-path = (start,)
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
    panic(
      "marginalia's default `page-width` must be specified and non-zero before creating a note",
    )
  }
  page-width / 100
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
  // pct = 1% of the page size
  // anchor-x = position in the page where the note is called (starting position of line)
  // props.margin-left may have to be expressed as % ?
  let pct = _get-page-pct(props)
  let dist-to-margin = (100 * pct) - anchor-x + (props.margin-left) + (2 * pct)
  let text-offset = 0.5em
  let right-width = props.margin-right - 8 * pct

  let path-pts = _path-from-diffs(
    // make an upward line before coming back down to go all the way to
    // the top of the lettering
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (dist-to-margin, 0pt),
    (0pt, dy),
    (1 * pct + right-width / 2, 0pt),
  )
  dy += text-offset
  // let vars = (
  //   ("total-size", 100 * pct),
  //   ("dist-to-margin", dist-to-margin),
  //   ("anchor-x", anchor-x),
  // )
  let note-rect = props.at("rect")(stroke: props.stroke, width: right-width, body)
  // Boxing prevents forced paragraph breaks
  box[
    #set par(justify: false)
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1 * pct, dy: dy, note-rect)
  ]
  _update-descent("right", dy, anchor-y, note-rect)
}

#let _margin-note-left(body, dy, anchor-x, anchor-y, ..props) = {
  props = props.named()
  let pct = _get-page-pct(props)
  let dist-to-margin = -anchor-x
  let text-offset = 0.4em
  let box-width = props.margin-left - 4 * pct
  let path-pts = _path-from-diffs(
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (-anchor-x + props.margin-left + 1 * pct, 0pt),
    (-2 * pct, 0pt),
    (0pt, dy),
    (-1 * pct - box-width / 2, 0pt),
  )
  dy += text-offset
  let note-rect = props.at("rect")(stroke: props.stroke, width: box-width, body)
  // Boxing prevents forced paragraph breaks
  box[
    #set par(justify: false)
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1 * pct, dy: dy, note-rect)
  ]
  _update-descent("left", dy, anchor-y, note-rect)
}

#let note-counter = counter("note-counter")

/// Places a boxed note in the left or right page margin.
///
/// - body (content): Margin note contents, usually text
/// - dy (length): Vertical offset from the note's location -- negative values
///   move the note up, positive values move the note down
/// - ..kwargs (dictionary): Additional properties to apply to the note. Keys allowed are any of the described in the `margin-note-defaults` dictionary above.
#let margin-note(body, dy: auto, ..kwargs) = {
  locate(
    loc => {
      let pos = loc.position()
      let properties = margin-note-defaults.at(loc) + kwargs.named()

      if properties.hidden {
        return
      }

      let (anchor-x, anchor-y) = (pos.x - properties.page-offset-x, pos.y)

      if (properties.numbering) {
        note-counter.step()
        super(note-counter.display(properties.super-numbering-format))
      }

      set text(size: properties.font-size, fill: properties.font-color)

      if properties.side == auto {
        let (r, l) = (properties.margin-right, properties.margin-left)
        properties.side = if calc.max(r, l) == r { right } else { left }
      }

      // `let` assignment allows mutating argument
      let dy = dy
      if dy == auto {
        let (cur-page, descents) = _get-descent-at-page(loc)
        let cur-descent = descents.at(repr(properties.side))
        dy = calc.max(0pt, cur-descent - loc.position().y)
        // Notes at the beginning of a line misreport their y position, since immediately
        // after they are placed, a new line is created which moves the note down.
        // A hacky fix is to subtract a line's worth of space from the y position when
        // detecting a note at the beginning of a line.
        // TODO: When https://github.com/typst/typst/issues/763 is resolved,
        // `get` this value from `par.leading` instead of hardcoding`
        if anchor-x == properties.margin-left {
          dy -= 0.65em
        }
      }

      let new-body = if (properties.numbering) {
        note-counter.display(properties.numbering-format) + " " + body
      } else {
        body
      }

      let margin-func = if (properties.side == right) {
        _margin-note-right
      } else {
        _margin-note-left
      }

      margin-func(new-body, dy, anchor-x, anchor-y, ..properties)
    },
  )
}
