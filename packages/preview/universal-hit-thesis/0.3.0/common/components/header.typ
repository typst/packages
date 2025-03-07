#import "../theme/type.typ": 字体, 字号
#import "../config/constants.typ": page-margins, distance-to-the-edges
#import "../utils/states.typ": default-header-text-state

#let use-hit-header(header-text: none, content) = context {
  let default-header-text = default-header-text-state.get()

  let internal-header-text = if header-text == none {
    default-header-text
  } else {
    header-text
  }

  let header-body = [
    #set align(center)
    #text(font: 字体.宋体, size: 字号.小五)[
      #block(below: 2.2pt + 2.5pt)[
        #internal-header-text
      ]
    ]
    #line(length: 100%, stroke: 2.2pt)
    #v(2.2pt, weak: true)
    #line(length: 100%, stroke: 0.6pt)
  ]

  context {
    let header-body-size = measure(header-body)
    let header-ascent = page-margins.top - distance-to-the-edges.header - header-body-size.height
    set page(
      header: {
        [
          #header-body
        ]
      },
      header-ascent: 6.7pt,
      // header-ascent: header-ascent,
    )
    content
  }
}