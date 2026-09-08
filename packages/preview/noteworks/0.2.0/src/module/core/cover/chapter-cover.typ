#import "../../../core/setup.typ": nw-config, nw-theme

#let chapter-cover(
  number: "",
  title: "",
  summary: none,
) = {
  page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    header: none,
    footer: none,
  )[
    #std.metadata((title: title, summary: summary)) <chapter-cover>
    #context {
      let theme = nw-theme()
      let c = nw-config()

      [
        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(2cm)

        #if number != "" {
          text(
            font: c.title-font,
            size: 22pt,
            fill: theme.text-accent,
            tracking: 2pt,
          )[#number]
        }

        #v(0.5em)

        #text(
          font: c.title-font,
          size: 40pt,
          weight: "bold",
          fill: theme.text-heading,
        )[
          #title
        ]

        #v(1cm)

        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(2cm)

        #if summary != none {
          block(width: 100%)[
            #text(
              font: c.font,
              fill: theme.text-main,
              size: 14pt,
              style: "italic",
              weight: "regular",
            )[
              #summary
            ]
          ]
        }

        #v(1fr)
      ]
    }
  ]
  counter(page).step()
}
