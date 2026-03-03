// Utilities for defining icons and other graphics.

#import "../palette.typ": *
#import "../util/small.typ": *
#import "maybe-stub.typ": cetz
#import "draw.typ"

// just an alias so we can use `figure` as arg below
#let _figure = figure

#let round-stroke(paint: fg) = (
  cap: "round",
  join: "round",
  paint: paint,
  thickness: 0.1em,
)

#let canvas(body, length: 1em, figure: true, caption: none, ..args) = {
  // most canvasses (canvae? what's the plural) are for showing data or to illustrate something in-body
  // in which case it makes sense to center + index them
  // if the user doesn't desire that, they can set `figure: false`
  show: maybe-do(figure, _figure.with(caption: caption))

  cetz.canvas(..args, length: length, {
    import draw: *

    set-style(stroke: round-stroke())

    body
  })
}

#let diagram(
  /// Key is the name used for a node,
  /// value is a dictionary with the keys:
  /// - `pos`: where to place the node
  /// - (optional) `display`: what content to show at `pos`
  ///   - Defaults to the node name
  /// - (optional) `accent`: what color outgoing edges should have
  ///   - Defaults to the foreground color of the current theme
  ///   - Also determines the color of the `name` if `display` is not used
  /// - (optional) `frame`: what to use as hitbox for incoming and outgoing edges
  ///   - Defaults to "rect"
  ///   - Can be one of none, "rect" or "circle"
  ///
  /// If the value doesn't contain the `pos` key,
  /// it is assumed to be directly the position as coordinate or cetz position.
  ///
  /// The node names directly map to cetz names.
  nodes: (:),
  /// Key is the name of the node used as source,
  /// value is the target coordinate or node name.
  /// Use the `br` function in `gfx.draw`
  /// if you want to target more than node and/or
  /// don't take the direct path.
  edges: (:),
  /// Body to render before the diagram.
  prelude: none,
  /// Body to render after the diagram.
  ..args,
) = {
  let cmds = {
    import draw: *

    prelude

    for (name, cfg) in nodes {
      let cfg = if (
        type(cfg) == dictionary and "pos" in cfg
      ) {
        cfg
      } else {
        (pos: cfg)
      }

      cfg.accent = cfg.at("accent", default: fg)
      let display = cfg.at("display", default: text(fill: cfg.accent, name))

      content(
        cfg.pos,
        display,
        padding: 0.5em,
        frame: cfg.at("frame", default: "rect"),
        stroke: none,
        name: name,
      )

      nodes.at(name) = cfg
    }

    for (from, to) in edges {
      let source-cfg = nodes.at(from)
      trans(from, styled(
        stroke: round-stroke(paint: source-cfg.accent),
        fill: source-cfg.accent,
        to,
      ))
    }

    args.pos().at(0, default: none)
  }

  align(center, canvas(cmds, ..args.named()))
}
