#import "@preview/cetz:0.3.2": draw, coordinate
#import "../util.typ"

/// Draws a group of elements
///
/// #examples.group
/// - body (elements, function): Elements to group
/// - id (str): see #doc-ref("element.elmt")
/// - name (str): The group's name
/// - name-anchor (str): The anchor for the name. \
///     Note: the name will be placed on the *outside* of the group
/// - fill (color): see #doc-ref("element.elmt")
/// - stroke (stroke): see #doc-ref("element.elmt")
/// - padding (float,length,array,dictionary): The inside padding:
///    - float / length: same for all sides
///    - array: either (`<all>`,), (`<vertical>`, `<horizontal>`) or (`<top>`, `<right>`, `<bottom>`, `<left>`)
///    - dictionary: valid keys are "top", "right", "bottom" and "left"
/// - radius (number): The corner radius
#let group(
  body,
  id: "",
  name: none,
  name-anchor: "south",
  fill: none,
  stroke: black + 1pt,
  padding: 0.5em,
  radius: 0.5em
) = {
  let min-x = none
  let max-x = none
  let min-y = none
  let max-y = none

  let pad-top = padding
  let pad-bottom = padding
  let pad-left = padding
  let pad-right = padding

  if type(padding) == array {
    if padding.len() == 0 {
      panic("Padding array must contain at least one value")
    } else if padding.len() == 1 {
      pad-top = padding.first()
      pad-bottom = padding.first()
      pad-left = padding.first()
      pad-right = padding.first()
    } else if padding.len() == 2 {
      pad-top = padding.first()
      pad-bottom = padding.first()
      pad-left = padding.last()
      pad-right = padding.last()
    } else if padding.len() == 4 {
      (pad-top, pad-right, pad-bottom, pad-left) = padding
    }
  } else if type(padding) == dictionary {
    pad-top = padding.at("top", default: 0.5em)
    pad-right = padding.at("right", default: 0.5em)
    pad-bottom = padding.at("bottom", default: 0.5em)
    pad-left = padding.at("left", default: 0.5em)
  }

  draw.hide(draw.group(name: id+"-inner", body))
  draw.rect(
    (rel: (-pad-left, -pad-bottom), to: id+"-inner.south-west"),
    (rel: (pad-right, pad-top), to: id+"-inner.north-east"),
    name: id,
    radius: radius,
    stroke: stroke,
    fill: fill
  )
  if name != none {
    draw.content(
      id + "." + name-anchor,
      anchor: util.opposite-anchor(name-anchor),
      padding: 5pt,
      [*#name*]
    )
  }
  body
}