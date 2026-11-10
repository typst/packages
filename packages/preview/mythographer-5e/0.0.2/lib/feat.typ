#import "config.typ"
#import "core.typ"
#import "utils.typ"

#import "external.typ"

#let dnd-feat(config: (:), body) = core.fn-wrapper(self => context {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set heading(outlined: false, numbering: none)

  show heading.where(level: 1): it => {
    set text(
      weight: self.feat.headers.level-1.weight,
      font: self.feat.headers.level-1.font,
      size: self.feat.headers.level-1.size,
      fill: self.feat.headers.level-1.fill,
    )

    stack(
      spacing: 3pt,
      utils.call-if-fn(self.feat.headers.level-1.style, [#it.body]),
      line(
        stroke: (
          paint: self.feat.line.fill,
          thickness: 1.2pt,
        ),
        length: 100%,
      ),
    )
  }

  show heading.where(level: 2): it => {
    set text(
      weight: self.feat.headers.level-2.weight,
      font: self.feat.headers.level-2.font,
      size: self.feat.headers.level-2.size,
      fill: self.feat.headers.level-2.fill,
    )
    utils.call-if-fn(self.feat.headers.level-2.style, [#external.transl("prerequisite"): #it.body])
    linebreak()
  }

  set text(
    font: self.feat.body.font,
    size: self.feat.body.size,
    fill: self.feat.body.fill,
  )

  body
})
