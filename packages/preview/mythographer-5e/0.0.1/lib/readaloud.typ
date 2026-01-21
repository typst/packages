#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-readaloud(config: (:), body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set text(size: 0.82em, font: self.font.readaloud.font)

  stack(spacing: -2pt)[
    #grid(columns: 3)[
      #circle(fill: self.fill.readaloud.edges, radius: 2pt)
    ][
      #h(1fr)
    ][
      #circle(fill: self.fill.readaloud.edges, radius: 2pt)
    ]
  ][
    #h(2pt)
    #box(
      width: 1fr,
      stroke: (
        left: 1.2pt + self.fill.readaloud.edges,
        right: 1.2pt + self.fill.readaloud.edges,
      ),
      fill: self.fill.readaloud.background.transparentize(self.fill.readaloud.transparentize),
      inset: 8pt,
      [
        #body
      ],
    )
    #h(2pt)

  ][
    #v(-1fr)
    #grid(columns: 3)[
      #circle(fill: self.fill.readaloud.edges, radius: 2pt)
    ][
      #h(1fr)
    ][
      #circle(fill: self.fill.readaloud.edges, radius: 2pt)
    ]
  ]
})
