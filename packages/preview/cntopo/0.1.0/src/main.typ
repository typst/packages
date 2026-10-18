#import "util.typ": fill-def, stroke-def
#import "shapes.typ": *
#import "nodes.typ": *
#import "clients.typ": *
#import "misc.typ": *

/// Default node icons
/// -> dict
#let default-nodes = (
  router: node.with(class: "router"),
  wl-router: node.with(class: "router", shape: "hex"),
  switch: node.with(class: "switch"),
  l3-switch: node.with(class: "l3-switch"),
  ap: node.with(class: "ap"),
  dual-ap: node.with(class: "dual-ap"),
  // mesh-ap: node.with(class: "mesh-ap"),
  hub: node.with(class: "hub"),
  fe-hub: node.with(class: "fe-hub"),
)

/// Icon presets
///
/// These shapes will be available from the @icons and @fletcher-shapes functions. A complete showcase of all of the icons can be found at #link(<all-shapes>, "the end of this document")
///
/// -> dict
#let icon-presets = (
  default-nodes
    .pairs()
    .map(((k, v)) => (
      (k, v),
      ("w-" + k, v.with(wireless: true)),

      ("sec-" + k, v.with(detail: "secure")),
      ("w-sec-" + k, v.with(detail: "secure", wireless: true)),

      ("cl-" + k, v.with(detail: "cloud")),
      ("w-cl-" + k, v.with(detail: "cloud", wireless: true)),
    ))
    .join()
    .to-dict()
    + (
      bridge: node.with(shape: "bridge", class: none),
      sec-bridge: node.with(shape: "bridge", class: none, detail: "secure"),
      bridge-ap: node.with(shape: "bridge", class: "ap"),
      firewall: node.with(shape: "firewall", class: none),
      cl-firewall: node.with(shape: "firewall", class: "cloud"),
      sec-firewall: node.with(shape: "firewall", class: "secure"),
      // clients
      monitor: monitor,
      // laptop: laptop,
      server: server,
      // misc
      cloud: cloud,
      lock: lock,
    )
)

/// Applies styling to all of the CeTZ icons
///
/// ```example
/// #let (router, switch, l3-switch, cloud) = icons(
///   stroke: purple,
///   fill: purple.lighten(90%),
///   flat: false
/// )
/// #set text(size: .75em)
/// #canvas({
///   import cetz.draw: *
///   line((2,2), (0,4))
///   line((2,2), (4,4))
///   line((2,2), (0,0))
///   line((2,2), (4,0))
///   router((0,4), detail: [DR])
///   router((4,4), detail: [BDR])
///   router((0,0), detail: [DROTHER])
///   router((4,0), detail: [DROTHER])
///   switch((2,2), detail: "secure")
/// })
/// ```
///
/// -> dict
#let icons(
  /// Icon outer stroke
  /// -> stroke
  stroke: stroke-def,
  /// Icon main fill
  /// -> paint
  fill: fill-def,
  /// Icon inner stroke, defaults to @icons.stroke
  /// -> stroke | auto
  stroke-inner: auto,
  /// Icon inner fill, defaults to paint of @icons.stroke
  /// -> paint | auto
  fill-inner: auto,
  /// If the icon should be flat or 3d
  /// -> bool
  flat: true,
) = (
  icon-presets
    .pairs()
    .map(((k, v)) => (
      k,
      v.with(
        stroke: stroke,
        fill: fill,
        stroke-inner: stroke-inner,
        fill-inner: fill-inner,
        flat: flat,
      ),
    ))
    .to-dict()
)

/// Helper function to convert the CeTZ icons to Fletcher shapes
///
/// ```example
/// #import "@preview/fletcher:0.5.8": diagram, edge, node
///
/// #let i = icons(
///   stroke: purple,
///   fill: purple.lighten(90%),
///   flat: false
/// )
/// #let (router, monitor, switch) = to-fletcher-shapes(i)
/// #let node = node.with(width: 4em, height: 4em)
///
/// #diagram(
///   node((0.5,0.25), [10.0.0.0/24]),
///   node((0,1), shape: monitor.with(label: ".2")),
///   edge(),
///   node((1,2), shape: switch.with(detail: [S1]), name: <s>),
///   edge(),
///   node((0,2), shape: monitor.with(label: ".3")),
///   node((1,1), shape: router.with(label: ".1", detail: [R1])),
///   edge(<s>),
/// )
/// ```
///
/// -> dict
#let to-fletcher-shapes(
  /// CeTZ icons
  /// -> dict
  i,
) = (
  i
    .pairs()
    .map(((k, v)) => (
      k,
      (node, extrude, ..extra) => {
        let (xr, yr) = if k in ratios {
          ratios.at(k)
        } else { (1, 1) }
        let (xs, ys) = node.size.map(i => i / 2 + extrude)
        v(
          (0, 0),
          // node.pos.uv,
          (xr * xs, yr * ys),
          ..extra.named(),
          ..(
            if "override-color" in extra.named()
              and extra.named().override-color {
              (
                stroke: node.stroke,
                fill: node.fill,
                fill-inner: stroke-to-paint(node.stroke),
                stroke-inner: node.stroke,
              )
            } else {
              (:)
            }
          ),
        )
      },
    ))
    .to-dict()
)

/// Shapes to use in Fletcher diagrams.
///
/// ```example
/// #import "@preview/fletcher:0.5.8": diagram, edge, node
///
/// #let node = node.with(width: 4em, height: 4em)
/// #let (router, switch, server) = fletcher-shapes(
///   stroke: green.lighten(20%),
///   fill: green.lighten(90%),
///   stroke-inner: green,
///   fill-inner: green
/// )
///
/// #diagram(
///   node((0.5,0.25), [10.0.0.0/24]),
///   node((0,1), shape: server.with(label: ".2")),
///   edge(),
///   node((1,2), shape: switch, name: <s>),
///   edge(),
///   node((0,2), shape: server.with(label: ".3")),
///   node((1,1), shape: router.with(label: ".1")),
///   edge(<s>),
/// )
/// ```
///
/// -> dict
#let fletcher-shapes(
  /// The same args as in @icons
  /// -> arguments
  ..args,
) = to-fletcher-shapes(icons(..args.named()))
