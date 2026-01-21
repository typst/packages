#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-area(config: (:), body) = core.fn-wrapper(self => context {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  let dnd-area-counter = counter("dnd-area")
  let dnd-area-counter1 = counter("dnd-area1")

  dnd-area-counter.step()
  dnd-area-counter1.step()

  set heading(outlined: false, numbering: none)
  show heading.where(level: 1): it => {
    dnd-area-counter.step()
    dnd-area-counter1.update(1)

    set text(
      weight: self.font.area.headers.level-1.weight,
      fill: self.fill.area.text,
      font: self.font.area.font,
      size: self.font.area.headers.level-1.size,
    )


    stack(
      spacing: 3pt,
      [
        #v(-0.5em)#utils.call-if-fn(self.font.area.headers.level-1.style, [#(
            dnd-area-counter.at(it.location()).last()
          ) #it.body])
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
    dnd-area-counter1.step()

    set text(
      weight: self.font.area.headers.level-2.weight,
      font: self.font.area.font,
      size: self.font.area.headers.level-2.size,
      fill: self.fill.area.text,
    )

    [
      #v(-0.5em)#utils.call-if-fn(self.font.area.headers.level-2.style, [#(
          numbering("1.", dnd-area-counter.at(it.location()).last() - 1)
        )#(numbering("a", dnd-area-counter1.at(it.location()).last())) #it.body]) #linebreak()
    ]
  }

  let current = counter(heading).get()
  body
})
