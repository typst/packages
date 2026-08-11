#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-item(config: (:), body) = core.fn-wrapper(self => context {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set heading(outlined: false)

  show heading.where(level: 1): it => {
    set text(
      weight: self.font.item.headers.level-1.weight,
      font: self.font.item.headers.level-1.font,
      size: self.font.item.headers.level-1.size,
      fill: self.fill.item.headers.level-1,
    )
    utils.call-if-fn(self.font.item.headers.level-1.style, [#it.body])
    linebreak()
  }


  show heading.where(level: 2): it => {
    set text(
      weight: self.font.item.headers.level-2.weight,
      font: self.font.item.headers.level-2.font,
      size: self.font.item.headers.level-2.size,
    )
    utils.call-if-fn(self.font.item.headers.level-2.style, [#it.body])
  }

  set text(
    font: self.font.item.font,
    size: self.font.item.size,
  )
  let current = counter(heading).get()
  counter(heading).update(0)
  body
  counter(heading).update(current)
})
