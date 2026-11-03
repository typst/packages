#import "cetz.typ": *

/// Draw a label with optional arrows inside an annotated image.
///
/// - body (str, content): What is written in the label.
/// - position (coordinate): Where to place the label to the origin of the
///   annotated image.
/// - anchor (str): Which part of the label sits on `position`. Defaults to "center".
/// - frame (none, str): Border around the label: `none`, `"rect"` or `"circle"`.
/// - fill (none, color): Fill of the frame.
/// - stroke (none, stroke): Stroke of the frame.
/// - padding (number, dictionary): Spacing between the text and the frame.
/// - to (none, coordinate, array): If given, an arrow is drawn from the label.
///   border to this position. Pass an array of coordinates to draw several arrows
///   from the same label.
/// - mark (none, dictionary): Mark (arrow tip) styling for the arrows, passed
///   through to CeTZ's `line` `mark` option.
/// - arrow-stroke (auto, none, stroke): Stroke of the arrow. `auto` reuses `stroke`.
/// - name (none, str): Optional cetz name for the produced group.
#let label(
  body,
  position,
  anchor: "center",
  frame: "circle",
  fill: white,
  stroke: black + 1pt,
  padding: 0.2em,
  to: none,
  mark: none,
  arrow-stroke: auto,
  name: none,
) = {
  import cetz.draw: content, group, line

  let arrow-stroke = if arrow-stroke == auto { stroke } else { arrow-stroke }

  group(
    name: name,
    {
      content(
        position,
        body,
        anchor: anchor,
        frame: frame,
        fill: fill,
        stroke: stroke,
        padding: padding,
        name: "label",
      )

      // A single coordinate like (3, 4) is itself an array, so treat `to` as a
      // list of targets only when its first element is again a coordinate
      // (array / named string / dictionary).
      let targets = if to == none {
        ()
      } else if type(to) == array and to.len() > 0 and type(to.first()) in (array, str, dictionary) {
        to
      } else {
        (to,)
      }

      for target in targets {
        line("label", target, mark: mark, stroke: arrow-stroke)
      }
    },
  )
}
