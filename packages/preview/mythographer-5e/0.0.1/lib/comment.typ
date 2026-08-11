#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-comment(config: (:), title, body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  block(
    fill: self.fill.commentbox.fill,
    inset: 3pt,
    outset: 5pt,
    width: 100%,
  )[
    #set text(
      font: self.font.commentbox.title.font,
      size: self.font.commentbox.title.size,
      weight: self.font.commentbox.title.weight,
    )
    #utils.call-if-fn(self.font.commentbox.title.style, [#title])
    #set text(font: self.font.commentbox.font, size: self.font.commentbox.size, weight: self.font.commentbox.weight)
    #v(-5pt)
    #body
  ]
})
