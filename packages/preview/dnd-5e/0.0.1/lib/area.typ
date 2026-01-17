#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-area(config: (:), body) = core.fn-wrapper(self => context {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set heading(outlined: false, numbering: "1a.")

  show heading.where(level: 1): it => {
    stack(
      spacing: 3pt,
      text(
        weight: self.font.area.headers.level-1.weight,
        fill: self.fill.area.text,
        font: self.font.area.font,
        size: self.font.area.headers.level-1.size,
      )[
        #v(-0.5em)#utils.call-if-fn(self.font.area.headers.level-1.style, [#counter(heading).display() #it.body])
      ],
      line(
        stroke: (
          paint: self.fill.area.line,
          thickness: 1.2pt,
        ),
        length: 100%,
      ),
    )
  }

  show heading.where(level: 2): it => {
    text(
      weight: self.font.area.headers.level-2.weight,
      font: self.font.area.font,
      size: self.font.area.headers.level-2.size,
      fill: self.fill.area.text,
    )[
      #v(-0.5em)#utils.call-if-fn(self.font.area.headers.level-2.style, [#counter(heading).display() #it.body]) #linebreak()
    ]
  }

  let current = counter(heading).get()
  counter(heading).update(0)
  body
  counter(heading).update(current)
})
