#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-comment(config: (:), title, body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  block(
    fill: self.commentbox.background.fill,
    inset: 3pt,
    outset: 5pt,
    width: 100%,
  )[
    #set text(
      font: self.commentbox.title.font,
      size: self.commentbox.title.size,
      weight: self.commentbox.title.weight,
      fill: self.commentbox.title.fill,
    )
    #utils.call-if-fn(self.commentbox.title.style, [#title])
    #set text(
      font: self.commentbox.body.font,
      size: self.commentbox.body.size,
      weight: self.commentbox.body.weight,
      fill: self.commentbox.body.fill,
    )
    #v(-5pt)
    #body
  ]
})
