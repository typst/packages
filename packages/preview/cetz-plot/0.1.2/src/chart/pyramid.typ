#import "/src/cetz.typ": draw, styles, palette, coordinate

// Pyramid Chart Label Kind
#let label-kind = (value: "VALUE", percentage: "%", label: "LABEL")

// Pyramid Chart Default Style
#let default-style = (
  stroke: auto,
  fill: auto,
  /// Gap between levels to leave empty.
  /// If `mode` is "AREA-HEIGHT", the value must be a ratio and will be proportional to the height of the first level
  gap: 0,
  /// Pyramid mode defining how to shape each level:
  ///   - "REGULAR": All levels have the same height and make a perfectly triangular pyramid
  ///   - "AREA-HEIGHT": The area of each level is proportional to its value. Only the height is adapted, keeping the pyramid triangular
  ///   - "HEIGHT": The height of each level is proportional to its value. The pyramid is kept as a perfect triangle
  ///   - "WIDTH": The height of each level is fixed, but its width is proportional to the value. The pyramid might not be perfectly triangular
  mode: "REGULAR",
  /// Height of each level
  level-height: 1,
  inner-label: (
    /// Label kind
    /// If set to a function, that function gets called with (value, label) of each item
    content: "LABEL",
    force-inside: false
  ),
  side-label: (
    /// Label kind
    /// If set to a function, that function gets called with (value, label) of each item
    content: none,
    side: "west"
  )
)

#let pyramid-default-style = default-style

/// Draw a pyramid chart
///
/// ```cexample
/// let data = (
///   "transcendence",
///   "self-actualization",
///   "aesthetic",
///   "cognitive",
///   "esteem",
///   "belonging and love",
///   "safety",
///   "physiological"
/// )
/// let colors = (
///   rgb("#FFFFC5"), rgb("#FEB6A5"),
///   rgb("#FFD89F"), rgb("#C6C6C6"),
///   rgb("#D4D1FF"), rgb("#FFB7CD"),
///   rgb("#F7BCFF"), rgb("#BDE0B0"),
/// )
///
/// chart.pyramid(
///   data,
///   level-style: colors,
///   level-height: 0.7)
/// ```
///
/// === Styling
/// *Root* `pyramid` \
/// #show-parameter-block("level-height", ("number"), [
///   Minimum level height.], default: 1)
/// #show-parameter-block("gap", ("number", "ratio"), [
///   Gap between levels to leave empty. If `mode` is "AREA-HEIGHT", the value must be a ratio and will be proportional to the height of the first level.], default: 0)
/// #show-parameter-block("mode", ("string"), [
///   The mode of how to shape each level:
///   - "REGULAR": All levels have the same height and make a perfectly triangular pyramid
///   - "AREA-HEIGHT": The area of each level is proportional to its value. Only the height is adapted, keeping the pyramid triangular
///   - "HEIGHT": The height of each level is proportional to its value. The pyramid is kept as a perfect triangle
///   - "WIDTH": The height of each level is fixed, but its width is proportional to the value. The pyramid might not be perfectly triangular], default: "REGULAR")
/// #show-parameter-block("side-label.content", ("none","string","function"), [
///   Content to display outsides the charts levels, on the side.
///   There are the following predefined values:
///   / LABEL: Display the levels label (see `label-key`)
///   / %: Display the percentage of the items value in relation to the sum of
///     all values, rounded to the next integer
///   / VALUE: Display the levels value
///   If passed a `<function>` of the format `(value, label) => content`,
///   that function gets called with each levels value and label and must return
///   content, that gets displayed.], default: none)
/// #show-parameter-block("side-label.side", ("string"), [
///   The side of the chart on which to place side labels, either "west" or "east"], default: "west")
/// #show-parameter-block("inner-label.content", ("none","string","function"), [
///   Content to display insides the charts levels.
///   See `side-label.content` for the possible values.], default: "LABEL")
/// #show-parameter-block("inner-label.force-inside", ("boolean"), [
///   If false, labels are automatically placed outside their correspoding levels if they don't fit inside. If true, they are always placed inside.], default: false)
///
/// === Anchors
///   The chart places one anchor per item at the center of its level that
///   gets named `"levels.<index>"`, one on the middle of its left side named `"levels.<index>.west"`, and one on the right side named `"levels.<index>.east"`,
///   where index is the index of the level data in `data`.
///
/// - data (array): Array of data items. A data item can be:
///   - A number: A number that is used as the fraction of the level
///   - An array: An array which is read depending on value-key and label-key
///   - A dictionary: A dictionary which is read depending on value-key and label-key
/// - value-key (none,int,string): Key of the "value" of a data item. If for example
///   data items are passed as dictionaries, the value-key is the key of the dictionary to
///   access the items chart value.
/// - label-key (none,int,string): Same as the value-key but for getting an items label content.
/// - level-style (function,array,gradient): Level style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each level the style at the levels
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the the levels
///     index divided by the number of levels as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
#let pyramid(
  data,
  value-key: none,
  label-key: none,
  level-style: palette.red,
  name: none,
  ..style
) = {
  // Prepare data by converting it to tuples of the format
  // (value, label)
  data = data.enumerate().map(((i, item)) => (
    if value-key != none {
      item.at(value-key)
    } else {
      none
    },
    if label-key != none {
      item.at(label-key)
    } else {
      item
    }
  ))

  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx,
      merge: style.named(),
      root: "pyramid",
      base: default-style
    )

    let mode = style.mode
    let gap = style.gap
    
    assert(mode in ("REGULAR", "AREA-HEIGHT", "HEIGHT", "AREA-WIDTH", "WIDTH"),
      message: "Mode must be 'REGULAR', 'AREA-HEIGHT', 'HEIGHT', 'AREA-WIDTH' or 'WIDTH', but is: " + str(mode))
    
    
    if mode == "AREA-HEIGHT" {
      if gap == 0 {
        gap = 0%
      }
      assert(type(gap) == ratio, message: "When mode is set to 'AREA-HEIGHT', gap must be of type ratio, but is: " + str(type(gap)))
    }

    assert(style.side-label.side in ("west", "east"),
      message: "Side label side must either be 'west' or 'east', but is: " + str(style.side-label.side))
    
    let style-at = if type(level-style) == function {
      level-style
    } else if type(level-style) == array {
      i => {
        let s = level-style.at(calc.rem(i, level-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(level-style) == gradient {
      i => (fill: level-style.sample(i / data.len() * 100%))
    }

    let total = data.map(d => d.first()).sum()
    let get-item-label(item, kind) = {
      let (value, label, ..) = item
      if kind == label-kind.value {
        [#value]
      } else if kind == label-kind.percentage {
        if total == none {
          panic("Using percentage label without values")
        }
        [#{calc.round(value / total * 100)}%]
      } else if kind == label-kind.label {
        label
      } else if type(kind) == function {
        (kind)(value, label)
      }
    }

    let rect-overlaps-trapezoid(rect, trapezoid) = {
      let r = rect
      let t = trapezoid
      let side-m = (t.y1 - t.y2) / (t.x1 - t.x2)
      let side-h = t.y1 - side-m * t.x1

      let x-side = (r.y - side-h) / side-m

      return if r.y > t.y1 {
        r.x < t.x1
      } else {
        r.x < x-side
      }
    }

    let total-gaps = style.gap * data.len()
    let total-height = if mode in ("REGULAR", "WIDTH") {
      style.level-height * data.len()
    } else if mode == "HEIGHT" {
      
    }

    total-height += total-gaps

    let base-width = if mode == "REGULAR" {
      2 * total-height / calc.sqrt(3)

    }

    let enum-items = data.enumerate()

    // Array of levels
    // level = (
    //   y,
    //   h,
    //   w-top,
    //   w-bottom,
    //   item
    // )
    let levels = ()

    if mode == "REGULAR" {
      levels = enum-items.map(((i, item)) => (
        i * (style.level-height + style.gap),
        style.level-height,
        auto,
        auto,
        item
      ))
    } else if mode == "WIDTH" {
      let w = 0
      let last-val = 0
      levels = ()
      for (i, item) in enum-items {
        let val = item.first()
        let y = i * (style.level-height + style.gap)
        let h = style.level-height
        let y2 = y + h
        let w1 = w
        let w2 = if i == 0 {
          y2 / calc.sqrt(3)
        } else {
          w * val / last-val
        }
        w = w2
        last-val = val
        levels.push((
          y,
          h,
          w1,
          w2,
          item
        ))
      }
    } else if mode == "HEIGHT" {
      let smallest = calc.min(
        ..data.map(d => d.first())
              .filter(v => v != 0)
      )

      let get-height(value) = {
        return value / smallest * style.level-height
      }

      let y = 0
      for (i, item) in enum-items {
        let h = get-height(item.first())
        levels.push((
          y,
          h,
          auto,
          auto,
          item
        ))
        y += h + style.gap
      }

    } else if mode == "AREA-HEIGHT" {
      let y = 0
      let get-area(y, h) = {
        return h * (2 *y + h) / 2
      }
      let h-for-area(y, area) = {
        /*
        A = (2yh + h²)/2
        2 * A = 2yh + h²
        h² + 2yh - 2A = 0

        h = -y +- sqrt(y² + 2A)
        */

        let delta = calc.sqrt(y * y + 2 * area)
        return delta - y
      }

      let first-val = enum-items.first().last().first()
      let first-area = 1 / calc.sqrt(3)
      let thinnest = 1

      for (i, item) in enum-items {
        let h = if i == 0 {
          1
        } else {
          let area = item.first() / first-val * first-area
          h-for-area(y, area)
        }

        levels.push((
          y,
          h,
          auto,
          auto,
          item
        ))
        thinnest = calc.min(thinnest, h)
        y += h + gap / 100%
      }

      let f = style.level-height / thinnest

      levels = levels.map(((y, h, w1, w2, item)) => (
        y * f,
        h * f,
        w1,
        w2,
        item
      ))
    }

    let anchors = ()
    draw.group(name: "chart", {
      draw.group(name: "levels", {
        for (i, level) in levels.enumerate() {
          let (
            y,
            h,
            width-top,
            width-bottom,
            (value, label)
          ) = level

          let y2 = y + h
          if width-top == auto {
            width-top = y / calc.sqrt(3)
          }
          if width-bottom == auto {
            width-bottom = y2 / calc.sqrt(3)
          }

          let stroke = style-at(i).at("stroke", default: style.stroke)
          let fill = style-at(i).at("fill", default: style.fill)

          let lvl-name = str(i)
          draw.group(name: lvl-name, {
            draw.line(
              (-width-top, -y),
              (width-top, -y),
              (width-bottom, -y2),
              (-width-bottom, -y2),
              close: true,
              fill: fill,
              stroke: stroke
            )
            let my = -(y + y2)/2
            draw.anchor(
              "west",
              (-(width-top + width-bottom)/2, my)
            )
            draw.anchor(
              "east",
              ((width-top + width-bottom)/2, my)
            )
            draw.anchor("center", (0, my))
            draw.anchor("default", (0, my))
          })

          let inner-label = get-item-label(
            (value, label),
            style.inner-label.content
          )

          if inner-label != none {
            let my = if width-top == 0 {
              -y - 2*h/3
            } else {
              -y - h/2
            }
            let m = measure(inner-label)
            let rw = m.width / ctx.length
            let rh = m.height / ctx.length
            let rect = (
              x: -rw / 2,
              y: my + rh / 2,
              w: rw,
              h: rh
            )
            let trapezoid = (
              y1: -y,
              y2: -y2,
              x1: -width-top,
              x2: -width-bottom
            )

            let mid = (0, my)
            if not style.inner-label.force-inside and rect-overlaps-trapezoid(rect, trapezoid) {
              let (anchor, f) = if calc.rem(i, 2) == 0 {
                ("west", 1)
              } else {
                ("east", -1)
              }

              let dy = 0.1 * h
              let pt = (
                rel: (
                  f * ((-my + dy) / calc.sqrt(3) + .5),
                  dy
                ),
                to: mid
              )

              draw.line(mid, pt)
              draw.content(
                pt,
                inner-label,
                anchor: anchor,
                padding: 3pt
              )
            } else {
              draw.content(
                mid,
                inner-label
              )
            }
          }
        }
      })
      if style.side-label.content != none {
        let side = style.side-label.side
        let corner = "levels.north-" + side
        for (i, item) in enum-items {
          let lvl-pt = "levels." + str(i)
          let pos = (lvl-pt, "-|", corner)
          draw.content(
            pos,
            get-item-label(item, style.side-label.content),
            anchor: ("west":"east","east":"west").at(side)
          )
        }
      }
    })
  })
}
