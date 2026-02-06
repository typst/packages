#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-sidebar(config: (:), float: false, to-bottom: false, title, body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  let custom(title, body) = {
    stack(spacing: 0.3pt)[
      #grid(columns: 3)[
        #polygon(
          fill: self.fill.sidebar.edge,
          (0em, 0em),
          (1em, 0em),
          (1em, -0.5em),
        )
      ][
        #h(1fr)
      ][
        #polygon(
          fill: self.fill.sidebar.edge,
          (0em, 0em),
          (-1em, 0em),
          (-1em, -0.5em),
        )
      ]
    ][
      #box(
        width: 1fr,
        fill: self.fill.sidebar.background,
        stroke: (
          top: 0.65pt + self.fill.sidebar.edge,
          bottom: 0.65pt + self.fill.sidebar.edge,
        ),
        inset: (
          top: 5pt,
          bottom: 5pt,
          left: 8pt,
          right: 8pt,
        ),
      )[
        #set text(
          size: self.font.sidebar.title.size,
          font: self.font.sidebar.title.font,
          weight: self.font.sidebar.title.weight,
        )
        #utils.call-if-fn(self.font.sidebar.title.style, [#title])
        #v(-5pt)
        #set text(
          size: self.font.sidebar.size,
          font: self.font.sidebar.font,
          weight: "regular",
        )
        #body
      ]
    ][
      #grid(columns: 3)[
        #polygon(
          fill: self.fill.sidebar.edge,
          (0em, 0em),
          (1em, 0em),
          (1em, 0.5em),
        )
      ][
        #h(1fr)
      ][
        #polygon(
          fill: self.fill.sidebar.edge,
          (0em, 0em),
          (-1em, 0em),
          (-1em, 0.5em),
        )
      ]

    ]
  }

  if float {
    if to-bottom {
      place(bottom, float: true)[#v(1fr)#custom(title, body)]
    } else {
      place(auto, float: true)[#custom(title, body)]
    }
  } else {
    custom(title, body)
  }
})
