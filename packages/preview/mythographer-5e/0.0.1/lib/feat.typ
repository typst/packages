#import "config.typ"
#import "core.typ"
#import "utils.typ"

#import "external.typ"

#let dnd-feat(config: (:), body) = core.fn-wrapper(self => context {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set heading(outlined: false)

  show heading.where(level: 1): it => {
    set text(
      weight: self.font.feat.headers.level-1.weight,
      font: self.font.feat.headers.level-1.font,
      size: self.font.feat.headers.level-1.size,
      fill: self.fill.feat.headers.level-1,
    )

    stack(
      spacing: 3pt,
      utils.call-if-fn(self.font.feat.headers.level-1.style, [#it.body]),
      line(
        stroke: (
          paint: self.fill.feat.line,
          thickness: 1.2pt,
        ),
        length: 100%,
      ),
    )
  }

  show heading.where(level: 2): it => {
    set text(
      weight: self.font.feat.headers.level-2.weight,
      font: self.font.feat.headers.level-2.font,
      size: self.font.feat.headers.level-2.size,
      fill: self.fill.feat.headers.level-2,
    )
    utils.call-if-fn(self.font.feat.headers.level-2.style, [#external.transl("prerequisite"): #it.body])
    linebreak()
  }

  set text(font: self.font.feat.font, size: self.font.feat.size)
  let current = counter(heading).get()
  counter(heading).update(0)
  body
  counter(heading).update(current)
})
