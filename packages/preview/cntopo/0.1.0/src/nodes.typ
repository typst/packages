#import "util.typ": *
#import "misc.typ": *
#import "node-class.typ": *
#import "node-detail.typ": *
#import "node-shape.typ": *

/// Node
///
/// ```example
/// #cetz.canvas({
///   node((0,0), (2,2), class: "l3-switch")
/// })
/// ```
#let node(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Icon outer stroke
  ///
  /// If @node.stroke-inner and/or @node.fill-inner are set to `auto`, then this will apply to them as well.
  /// ```example
  /// #cetz.canvas({
  ///   node((0,0), class: "router", stroke: red)
  ///   node((2,0), class: "router", stroke: red, stroke-inner: black, fill-inner: black)
  /// })
  /// ```
  /// -> stroke
  stroke: stroke-def,
  /// Icon main fill
  /// ```example
  /// #cetz.canvas({
  ///   node(fill: red, class: "router")
  /// })
  /// ```
  /// -> paint
  fill: fill-def,
  /// Icon inner stroke
  /// ```example
  /// #cetz.canvas({
  ///   node(stroke-inner: red, class: "router")
  /// })
  /// ```
  /// -> stroke | auto
  stroke-inner: auto,
  /// Icon inner fill
  /// ```example
  /// #cetz.canvas({
  ///   node(fill-inner: red, class: "router")
  /// })
  /// ```
  /// -> paint | auto
  fill-inner: auto,
  /// If the icon should be flat or 3d
  /// ```example
  /// #cetz.canvas({
  ///   node((0,0), flat: true, class: "router")
  ///   node((2,0), flat: false, class: "router")
  /// })
  /// ```
  /// -> bool
  flat: true,
  /// Label
  /// ```example
  /// #cetz.canvas({
  ///   node(label: "R1", class: "router")
  /// })
  /// ```
  /// -> str | content | none
  label: none,
  /// Label position
  /// ```example
  /// #cetz.canvas({
  ///   node(label: "R2", label-pos: top, class: "router")
  /// })
  /// ```
  /// -> alignment
  label-pos: bottom,
  /// Secondary node icon / text
  /// ```example
  /// #cetz.canvas({
  ///   node((0,0), detail: "secure", class: "router")
  ///   node((2,0), detail: [R3], flat: false, class: "router")
  /// })
  /// ```
  /// -> "secure" | "cloud" | content | none
  detail: none,
  /// Main node icon
  /// ```example
  /// #cetz.canvas({
  ///   node(class: polygon.regular(size: 20pt, vertices: 6))
  ///   node((2,0), class: "hub", flat: false)
  /// })
  /// ```
  /// -> "router" | "switch" | "hub" | "fe-hub" | "l3-switch" | "ap" | "dual-ap" | "mesh-ap" | content | none
  class: none,
  /// Node shape
  /// ```example
  /// #cetz.canvas({
  ///   node(shape: "firewall")
  ///   node((2, 0), class: "dual-ap", shape: auto)
  /// })
  /// ```
  /// -> "circle" | "hex" | "square" | "rect" | "bridge" | "firewall" | auto
  shape: auto,
  /// Node radius.
  ///
  /// Only works on the shapes `square` or `rect`
  /// ```example
  /// #cetz.canvas({
  ///   node(shape: "square", radius: 20%, class: "router")
  /// })
  /// ```
  /// -> int | float | relative | auto
  radius: auto,
  /// If the wireless antennas should be added
  /// ```example
  /// #cetz.canvas({
  ///   node(wireless: true, class: "router")
  /// })
  /// ```
  /// -> bool
  wireless: false,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, 1))
  let (stroke-i, fill-i) = resolve-style(
    stroke,
    fill,
    stroke-inner,
    fill-inner,
  )
  let radius = if radius == auto {
    if class == "router" { 0% } else { 5% }
  } else { radius }

  let shape = if shape == auto {
    if type(class) != str or class not in node-classes { "circle" } else if (
      "bridge" in class
    ) {
      "bridge"
    } else if (
      class == "router"
    ) {
      if detail == "wavelength" { "hex" } else { "circle" }
    } else if class.ends-with("ap") {
      "rect"
    } else { "square" }
  } else { shape }

  let is-circle = shape == "hex" or shape == "circle"
  let (sx-i, sy-i) = if detail != none and flat {
    (
      if class == "switch"
        or (
          type(class) == str
            and (class.ends-with("hub") or class.ends-with("ap"))
        ) {
        sx
      } else { sx * 3 / 4 },
      sy * 3 / 4,
    )
  } else {
    (sx, sy)
  }
  let off-i = if detail != none and flat { sy / 6 } else { 0 }

  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    if wireless {
      let hs = (
        sy
          * (
            if flat {
              if shape == "square" or shape == "firewall" { .5 } else if (
                shape == "circle"
              ) {
                .25
              } else { .1 }
            } else { 0 }
          )
      )
      if is-circle {
        antennas((0, hs), (sx, sy), stroke: stroke-to-paint(stroke))
      } else {
        antennas(
          (if flat { 0 } else { sx * 1 / 4 }, hs),
          (sx, sy),
          stroke: stroke-to-paint(stroke),
          spacing: sx,
        )
      }
    }

    let eval-shape = s => if type(s) == function {
      shape(sx, sy, radius, stroke, fill, flat)
    } else if (type(s) == str and s in node-shapes) {
      node-shapes.at(s)(sx, sy, radius, stroke, fill, flat)
    } else { s }

    let eval-class-detail = (c, is-class) => {
      let size = eval-c => if not is-class {
        (
          sx * .2,
          sy * .2,
        )
      } else if not eval-c {
        (
          sx-i * .75,
          sy-i * .75,
        )
      } else {
        (
          sx-i,
          sy-i,
        )
      }
      let eval-class = cc => node-classes.at(cc)(
        ..size(true),
        stroke-i,
        fill-i,
      )
      let eval-details = cc => node-details.at(cc)(
        ..size(false),
        fill,
        fill-i,
      )

      if type(c) == str and is-class and c in node-classes {
        eval-class(c)
      } else if type(c) == str and is-class and c in node-details {
        eval-details(c)
      } else if type(c) == str and not is-class and c in node-details {
        eval-details(c)
      } else if type(c) == str and not is-class and c in node-classes {
        eval-class(c)
      } else if c != none {
        cetz.draw.content(
          (0, 0),
          text(fill: fill-i, weight: "bold", c),
        )
      }
    }

    cetz.draw.group({
      // if not flat { to-3d(x, y, is-circle) }
      to-3d(flat, shape, {
        eval-shape(shape)
        if class != none {
          cetz.draw.group({
            cetz.draw.set-origin((0, off-i))
            eval-class-detail(class, true)
          })
        }
      })
    })

    draw-lbl(label, label-pos, sx, sy, flat: flat, is-circle: is-circle)

    if detail != none {
      let pos = if flat {
        (
          0,
          if shape == "rect" { -sy * 3 / 8 } else if shape == "hex" {
            -sy * 9 / 16
          } else { -sy * 11 / 16 },
        )
      } else {
        (
          if is-circle { 0 } else if shape == "rect" or shape == "bridge" {
            -sx / 5
          } else {
            -sx / 4
          },
          if shape == "rect" { -sy / 4 } else if shape == "square" {
            -sy * 11 / 32
          } else { -sy * 3 / 8 },
        )
      }
      cetz.draw.group({
        cetz.draw.set-origin(pos)
        eval-class-detail(detail, false)
      })
    }
  })
}
