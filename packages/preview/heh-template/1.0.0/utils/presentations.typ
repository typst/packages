#import "/utils/states.typ": (
  group-current-slide, group-slide-count, group-title-state, heh-config,
  slidegroups-count,
)
#import "/components/headers/headers.typ": presentation-header

#import "@preview/polylux:0.4.0": slide

#let slidegroup(title, content) = context {
  let configuration = heh-config.get()
  let subslides = content.children.filter(it => repr(it.func()) == "sequence")
  slidegroups-count.step()
  group-slide-count.update(subslides.len())
  group-title-state.update(title)
  group-current-slide.update(0)

  slide[
    #align(left + horizon, [
      #set page(header: context {
        presentation-header(show-progression: false, show-titles: false)
      })
      #set heading(numbering: "1.")
      #show heading: set text(
        size: 1.5em,
        weight: "bold",
        fill: black,
        top-edge: "cap-height",
      )

      = #title
    ])
  ]

  slide[]

  for subslide in subslides {
    group-current-slide.step()
    subslide
  }
}

