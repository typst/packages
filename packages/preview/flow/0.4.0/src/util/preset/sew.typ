// Stitching utilities. For use with cetz.
#import "/src/gfx/draw.typ": *

#let steps = duality.values().slice(2).map(accent => (accent: accent))

#let modline(..args, accent: fg, dash: "solid") = line(
  stroke: (paint: accent, dash: dash),
  ..args,
)
#let fold = modline.with(dash: (0.25cm, 0.1cm))
#let stitch = modline.with(dash: ("dot", 0.125cm))

#let hint(start, end, len: [?], anchor: "south") = {
  content(
    (start, 50%, end),
    anchor: anchor,
    padding: 0.75em,
    [#len cm],
  )
  line(
    start,
    end,
    stroke: fg + 1pt,
    mark: (
      start: "|",
      end: "|",
      width: 1em,
    ),
  )
}

#let legend(step-count: steps.len(), diffop: set-origin((4.5, 0))) = {
  for (example, desc) in (
    (
      fold((0, 0.5), (1, 0.5)),
      [folding edge],
    ),
    (
      stitch((0, 0.5), (1, 0.5)),
      [stitch line],
    ),
    (
      none,
      {
        [steps:]
        h(0.5em)
        steps
          .slice(0, step-count)
          .enumerate()
          .map(((i, cfg)) => text(cfg.accent, str(i + 1)))
          .join([ -> ])
      },
    ),
  ) {
    example
    content(
      (1, 0.5),
      desc,
      anchor: "west",
      padding: 0.25,
    )
    diffop
  }
}

