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
          fill: self.sidebar.edge.fill,
          (0em, 0em),
          (1em, 0em),
          (1em, -0.5em),
        )
      ][
        #h(1fr)
      ][
        #polygon(
          fill: self.sidebar.edge.fill,
          (0em, 0em),
          (-1em, 0em),
          (-1em, -0.5em),
        )
      ]
    ][
      #box(
        width: 1fr,
        fill: self.sidebar.background.fill,
        stroke: (
          top: 0.65pt + self.sidebar.edge.fill,
          bottom: 0.65pt + self.sidebar.edge.fill,
        ),
        inset: (
          top: 5pt,
          bottom: 5pt,
          left: 8pt,
          right: 8pt,
        ),
      )[
        #text(
          size: self.sidebar.title.size,
          font: self.sidebar.title.font,
          weight: self.sidebar.title.weight,
          fill: self.sidebar.title.fill,
          utils.call-if-fn(self.sidebar.title.style, [#title]),
        )
        #v(-5pt)
        #set text(
          size: self.sidebar.body.size,
          font: self.sidebar.body.font,
          weight: "regular",
          fill: self.sidebar.body.fill,
        )
        #body
      ]
    ][
      #grid(columns: 3)[
        #polygon(
          fill: self.sidebar.edge.fill,
          (0em, 0em),
          (1em, 0em),
          (1em, 0.5em),
        )
      ][
        #h(1fr)
      ][
        #polygon(
          fill: self.sidebar.edge.fill,
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
