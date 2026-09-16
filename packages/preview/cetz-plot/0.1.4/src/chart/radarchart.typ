#import "/src/cetz.typ": draw, palette, styles

#import "/src/plot.typ"

#let radarchart-default-style = (
  web-style: (
    stroke: black.lighten(40%),
  ),
  web-ticks: 4,
  web-label-offset: 0.4,
  center-pos: (0, 0),
  radius: 2,
)

/// Draw a radar chart (also known as spider chart or web chart). A radar
/// chart is a chart that represents multivariate data in the form of a
/// two-dimensional chart of three or more quantitative variables represented as
/// axes starting from the same point.
///
/// ```cexample
/// chart.radarchart(
///   (
///     [A],
///     [B],
///     [C],
///     [D],
///     [E],
///     [F],
///   ),
///   (0.3, 0.6, 0.3, 0.4, 0.8, 1),
/// )
/// ```
/// === Styling
/// Can be applied with `cetz.draw.set-style(radarchart: (web-ticks: 6))`.
///
/// *Root*: `radarchart`.
/// #show-parameter-block("web-style", "style", default: (stroke: black.lighten(40%)), [
///   Style of the web in the background of the chart.])
/// #show-parameter-block("web-ticks", ("int", "array"), default: 4, [
///   Amount of layers of the web or an array containing the distance of each web layer to draw.])
/// #show-parameter-block("web-label-offset", "float", default: 0.4, [
///   Distance from the end of the web to the label.])
/// #show-parameter-block("center-pos", "float", default: 1, [
///   Coordinate of the center of the chart.])
/// #show-parameter-block("radius", "float", default: 2, [
///   Radius of the radar chart.])
///
/// - labels (array): Array of content. Each entry is the label
///                   of one coordinate axis.
///
///                   *Example*
///                   ```typc
///                   ([A], [B], [C])
///                   ```
/// - data (array): Array of data rows. A row can be of type array of float or
///                 array of array of float. All float values must be within the
///                 the range $0 <= "value" <= "radius"$. Each of the data rows must
///                 contain the same amount of items as `labels`.
///
///                 *Example*
///                 ```typc
///                 ((0.5, 0.3, 0.9), (0.3, 0.5, 0.2))
///                 ```
/// - data-style (function, array): Style per data row. Can be either
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array of style dictionaries: The dictionary at index `i` contains the style for the data row at index `i`.
///   - array of colors: The dictionary at index `i` contains the fill color for the data row at index `i`.
///
#let radarchart(
  labels,
  data,
  data-style: palette.red,
  ..style,
) = {
  assert(type(labels) == array)
  assert(labels.len() >= 3)

  assert(type(data) == array)
  assert(data.len() != 0)
  if type(data.at(0)) != array {
    // only one single data line
    data = (data,)
  }

  // ensure that all data lines have the same amount of coordinates
  let size = labels.len()
  for line in data {
    assert(line.len() == size)
  }

  draw.group(ctx => {
    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "radarchart",
      base: radarchart-default-style,
    )
    draw.set-style(..style)

    let center-pos = style.at("center-pos")
    let radius = style.at("radius")
    let web-ticks = style.at("web-ticks")
    let web-label-offset = style.at("web-label-offset")

    // ensure that no data point overflows out of the chart
    for line in data {
      for value in line {
        assert(0 <= value and value <= radius)
      }
    }

    assert(radius > 0)
    assert(type(web-ticks) in (int, array))
    if type(web-ticks) == int {
      // automatically calculate ticks amount of equidistant ticks
      web-ticks = range(web-ticks).map(i => (i + 1) / web-ticks)
    }

    let angle-step = 360deg / labels.len()

    // draw labels and lines from center to label
    // each of these axis is assigned the label "axis-{i}"
    for (i, label) in labels.enumerate() {
      let axis-name = "axis-" + str(i)
      draw.line(
        center-pos,
        (
          rel: (-angle-step * i + 90deg, radius),
        ),
        name: axis-name,
      )
      draw.content(
        (axis-name + ".start", radius + web-label-offset, axis-name + ".end"),
        label,
      )
    }

    // web drawing logic
    for tick in web-ticks {
      let web-points = ()
      for i in range(labels.len()) {
        web-points.push((
          rel: (-angle-step * i + 90deg, radius * tick),
          to: center-pos,
        ))
      }
      draw.line(..web-points, close: true, ..style.at("web-style"))
    }

    // draw the coordinates of each data line as a polygon
    for (line-index, line) in data.enumerate() {
      let pts = ()
      for (i, value) in line.enumerate() {
        let axis-name = "axis-" + str(i)
        pts.push((axis-name + ".start", radius * value, axis-name + ".end"))
      }

      let polygon-style = (:)
      if type(data-style) == array {
        let s = data-style.at(line-index)
        if type(data-style.at(line-index)) == dictionary {
          // data-style = style dict
          polygon-style = s
        } else {
          // data-style = list of colors -> fill polygon with these colors
          polygon-style = (fill: s)
        }
      } else if type(data-style) == function {
        // data-style = method taking the index as param
        polygon-style = data-style(line-index)
      }
      draw.line(..pts, close: true, ..polygon-style)
    }
  })
}
