#import "/src/cetz.typ" as cetz: draw, styles, palette, coordinate, util.resolve-number, vector

#import "common.typ": *

#let cycle-basic-default-style = (
  stroke: auto,
  fill: auto,
  steps: (
    stroke: none,
    fill: none,
    radius: 0.2em,
    padding: 0.6em,
    max-width: 5em,
    shape: "rect"
  ),
  arrows: (
    stroke: none,
    fill: "steps",
    thickness: 1em,
    double: false,
    curved: true
  )
)

/// Draw a basic cycle chart, describing cyclic steps
///
/// ```cexample
/// let steps = ([Improvise], [Adapt], [Overcome])
/// let colors = (red, orange, green).map(c => c.lighten(40%))
///
/// smartart.cycle.basic(
///   steps,
///   step-style: colors,
///   steps: (max-width: 5cm)
/// )
/// ```
///
/// === Styling
/// *Root* `cycle-basic` \
/// #show-parameter-block("steps.radius", ("number", "length"), [
///   Corner radius of the steps boxes.], default: 0.2em)
/// #show-parameter-block("steps.padding", ("number", "length"), [
///   Inner padding of the steps boxes.], default: 0.6em)
/// #show-parameter-block("steps.max-width", ("number", "length"), [
///   Maximum width of the steps boxes.], default: 5em)
/// #show-parameter-block("steps.shape", ("str", "none"), [
///   Shape of the steps boxes. One of `"rect"`, `"circle"` or `none`], default: "rect")
/// #show-parameter-block("steps.fill", ("color", "gradient", "pattern", "none"), [
///   Fill color of the steps boxes.], default: none)
/// #show-parameter-block("steps.stroke", ("stroke", "none"), [
///   Stroke color of the steps boxes.], default: none)
/// #show-parameter-block("arrows.thickness", ("number", "length"), [
///   Thickness of arrows.], default: 1em)
/// #show-parameter-block("arrows.double", ("boolean"), [
///   Whether arrows are uni- or bi-directional.], default: false)
/// #show-parameter-block("arrows.curved", ("boolean"), [
///   Whether arrows are curved or straight.], default: false)
/// #show-parameter-block("arrows.fill", ("string", "color", "gradient", "pattern", "none"), [
///   Fill color of the arrows. If set to "steps", the arrows will be filled with a color in between those of the neighboring steps.], default: "steps")
/// #show-parameter-block("arrows.stroke", ("stroke", "none"), [
///   Stroke used for the arrows.], default: none)
/// 
/// - steps (array): Array of steps (`<content>` or `<str>`)
/// - arrow-style (function, array, gradient): Arrow style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each arrow the style at the arrows
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the arrows
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the smartarts style.
/// - step-style (function, array, gradient): Step style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each step the style at the steps
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the steps
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the smartarts style.
/// - equal-width (boolean): If true, all steps will be sized to have the same width
/// - equal-height (boolean): If true, all steps will be sized to have the same height
/// - ccw (boolean): If true, steps are laid out counter-clockwise. If false, they're placed clockwise. The center of the cycle is always placed at (0, 0)
/// - radius (number, length): The radius of the cycle
/// - offset-angle (angle): Offset of the starting angle
#let basic(
  steps,
  arrow-style: auto,
  step-style: palette.red,
  equal-width: false,
  equal-height: false,
  ccw: false,
  radius: 2,
  offset-angle: 0deg,
  name: none,
  ..style
) = {
  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "cycle-basic",
      base: cycle-basic-default-style,
    )

    let n-steps = steps.len()
    let step-style-at = _get-style-at-func(step-style, n-steps)
    let arrow-style-at = _get-style-at-func(arrow-style, n-steps)

    let (
      sizes,
      largest-width,
      highest-height
    ) = _get-steps-sizes(steps, ctx, style, step-style-at)

    let angle-step = 360deg / n-steps
    if not ccw {
      angle-step *= -1
    }

    for (i, step) in steps.enumerate() {
      let angle = angle-step * i + 90deg + offset-angle
      let pos = (angle, radius)

      let step-style = style.steps + step-style-at(i)
      let padding = resolve-number(ctx, step-style.padding)

      let (w, h) = sizes.at(i)
      if equal-width {
        w = largest-width
      }
      if equal-height {
        h = highest-height
      }
      let step-name = "step-" + str(i)

      _draw-step(ctx, step, pos, step-style, step-name, w, h)
    }

    for i in range(n-steps) {
      let angle = angle-step * i + 90deg + offset-angle

      let arrow-style = style.arrows + arrow-style-at(i)
      let arrow-stroke = arrow-style.stroke
      let arrow-fill = arrow-style.fill
      let arrow-thickness = arrow-style.thickness

      if arrow-fill == "steps" {
        let s1 = style.steps + step-style-at(i)
        let s2 = style.steps + step-style-at(i + 1)
        arrow-fill = gradient.linear(s1.fill, s2.fill).sample(50%)
      }

      let start-angle = angle + angle-step * 0.2
      let end-angle = angle + angle-step * 0.8

      let a1 = angle
      let a2 = angle + angle-step / 2
      let a3 = angle + angle-step
      let n(a) = {
        if a < -180deg {
          a += 360deg
        } else if a > 180deg {
          a -= 360deg
        }
        return a
      }
      a1 = n(a1)
      a2 = n(a2)
      a3 = n(a3)
      let pts = (
        (a1, radius),
        (a2, radius),
        (a3, radius),
      )
      if not ccw {
        pts = pts.rev()
      }
      draw.hide(draw.arc-through(
        ..pts,
        name: "arc-" + str(i)
      ))
      draw.intersections(
        "i-" + str(i),
        "step-" + str(i),
        "arc-" + str(i)
      )
      draw.intersections(
        "j-" + str(i),
        "step-" + str(calc.rem(i + 1, n-steps)),
        "arc-" + str(i)
      )

      draw.get-ctx(ctx => {
        let (_, p1) = coordinate.resolve(ctx, "i-" + str(i) + ".0")
        let (_, p2) = coordinate.resolve(ctx, "j-" + str(i) + ".0")
        let start-angle = calc.atan2(p1.at(0), p1.at(1))
        let end-angle = calc.atan2(p2.at(0), p2.at(1))
        if ccw != (start-angle < end-angle) {
          if ccw {
            end-angle += 360deg
          } else {
            end-angle -= 360deg
          }
        }
        let angle-d = end-angle - start-angle

        let prev = "step-" + str(i)
        start-angle += angle-d * 0.1
        end-angle -= angle-d * 0.1
        let arrow-name = "arrow-" + str(i)

        let marks = (end: "straight")
        if arrow-style.double {
          marks.insert("start", "straight")
        }

        let arrow-thickness = arrow-thickness
        if arrow-thickness != none {
          arrow-thickness = resolve-number(ctx, arrow-thickness)
        }

        // Curved
        if arrow-style.curved {
          // Thin arrow
          if arrow-thickness == none {
            draw.arc-through(
              (start-angle, radius),
              ((start-angle + end-angle) / 2, radius),
              (end-angle, radius),
              stroke: arrow-stroke,
              mark: marks,
              name: arrow-name
            )
          
          // Thick arrow
          } else {
            _draw-arc-arrow(
              start-angle,
              end-angle,
              radius,
              arrow-thickness,
              arrow-fill,
              arrow-stroke,
              double: arrow-style.double,
              name: arrow-name
            )
          }
        
        // Straight
        } else {
          let p1 = (start-angle, radius)
          let p2 = (end-angle, radius)
          if arrow-thickness == none {
            draw.line(
              p1, p2,
              stroke: arrow-stroke,
              mark: marks,
              name: arrow-name
            )
          } else {
            _draw-arrow(
              p1, p2,
              arrow-thickness,
              arrow-fill,
              arrow-stroke,
              double: arrow-style.double,
              name: arrow-name
            )
          }
        }
      })
    }
  })
}
