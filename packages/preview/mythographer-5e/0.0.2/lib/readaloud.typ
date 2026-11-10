#import "config.typ"
#import "core.typ"
#import "utils.typ"

// 03/02/2026 - full rewrite heavily inspired by https://github.com/yanwenywan/typst-packages/blob/master/wenyuan-campaign/0.1.2/campaign.typ

#let dnd-readaloud(config: (:), body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set text(size: self.readaloud.body.size, font: self.readaloud.body.font)

  let corner(alignment, dx-mod: 1, dy-mod: 1) = place(
    alignment,
    dx: dx-mod * (1em + 2pt),
    dy: dy-mod * (1em + 2pt),
    circle(fill: self.readaloud.edge.fill, radius: 2pt),
  )

  block(
    width: 100%,
    inset: 1em,
    fill: self.readaloud.background.fill.transparentize(self.readaloud.background.transparentize),
    above: 1em,
    below: 1em,
    stroke: (
      left: 1.2pt + self.readaloud.edge.fill,
      right: 1.2pt + self.readaloud.edge.fill,
    ),
    breakable: true,
  )[
    #corner(top + left, dx-mod: -1, dy-mod: -1)
    #corner(top + right, dx-mod: 1, dy-mod: -1)

    #body

    #corner(bottom + left, dx-mod: -1, dy-mod: 1)
    #corner(bottom + right, dx-mod: 1, dy-mod: 1)
  ]
})
