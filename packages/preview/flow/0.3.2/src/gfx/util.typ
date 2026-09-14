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

#let icon(
  body,
  // if true, render the actual icon itself in bg on a rounded rectangle with the accent.
  // if false, render only the icon itself.
  invert: true,
  // if `invert` is true, the radius of the accent rect
  radius: 0.25,
  // the key under which to look information like accent up from `palette.status`.
  // if neither this nor `accent` is set, default to the fg color.
  key: none,
  // overrides `key` if set. the color to tint the icon in.
  accent: none,
  // If true, returns a `content` that can be directly put into text.
  // If false, returns an array of draw commands that can be used in a cetz canvas.
  contentize: true,
  // If `contentize` is false, put the lower left corner of this icon at this position.
  at: (0, 0),
  name: none,
  // Arguments to forward to `canvas` if `contentize` is true.
  ..args,
) = {
  if cfg.render != "all" { return }
  import draw: *

  let cmds = group(
    ..if name != none {
      (name: name)
    } else {
      (:)
    },
    {
      set-origin(at)

      let accent = if accent != none {
        accent
      } else {
        status.at(key, default: fg)
      }

      let icon-accent = accent
      if invert {
        rect(
          (0, 0),
          (1, 1),
          stroke: none,
          fill: accent,
          radius: radius,
          ..if name != none {
            (name: name)
          } else {
            (:)
          },
        )
        icon-accent = bg
      } else {
        // hacking the boundary box in so the spacing is right
        line((0, 0), (1, 1), stroke: none)
      }

      // intended to be selectively disabled via passing `none` explicitly
      set-style(stroke: (paint: icon-accent), fill: icon-accent)

      // so the user can just draw from 0 to 1 while the padding is outside
      set-origin((0.2, 0.2))
      scale(0.6)
      body()
    },
  )

  if contentize {
    box(
      inset: (
        y: -0.175em,
      ),
      canvas(cmds, figure: false, ..args),
    )
  } else {
    cmds
  }
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
