#let logo_path = "./res/PKU.svg"
#let logo_str = read(logo_path).replace("920f14", "cccccc")

#let theme(meta) = {
  return (
    title: (
      whole-page: () => {
        return [
          #set page(margin: 0pt, header: none, footer: none)

          // Logo
          #place(
            center + top,
            dx: 40%,
            dy: 10pt,
          )[
            #image.decode(logo_str, width: 100%)
          ]

          // Info panel
          #place(
            bottom + left,
            dx: 0pt,
            dy: -20%,
            rect(fill: rgb("cccccc"), width: 100%, height: 10pt),
          )
          #place(
            bottom + left,
            dx: 24pt,
            dy: -20%,
            text(
              meta.course-name,
              size: 36pt,
              font: ("Source Han Serif SC"),
              baseline: -0.6em,
            ),
          )
          #place(
            bottom + left,
            dx: 24pt,
            dy: -20%,
            box([
              #set text(
                size: 20pt,
                font: ("Source Han Serif SC"),
                baseline: 1em,
              )
              #set align(horizon)
              #meta.author-info
            ]),
          )
          #pagebreak(weak: true)
        ]
      },
      simple: () => {
        return align(
          center + horizon,
          stack(
            dir: ltr,
            spacing: 8pt,
            image.decode(logo_str, width: 30%),
            context line(
              length: 20% * page.width,
              angle: 90deg,
              stroke: (
                thickness: 0.8pt,
                paint: gray.lighten(60%),
              ),
            ),
            align(left)[
              #block[
                #set text(font: (
                  "New Computer Modern",
                  "Source Han Serif SC",
                ))

                #text(size: 28pt, weight: "bold")[
                  #meta.course-name
                ]

                #text(size: 18pt)[
                  #meta.serial-str
                ]

                #text(size: 12pt, font: "STFangsong")[
                  #meta.author-info
                ]
              ]
            ],
          ),
        )
      },
    ),
    page-setting: (
      header: () => {
        set text(size: 10.5pt, font: "Source Han Serif SC")
        block(
          grid(
            columns: (1fr, 1fr),
            align(left + horizon, meta.course-name), align(right + horizon, meta.serial-str),
          ),
        )
        place(line(length: 100%, stroke: 0.5pt), dy: 0.5em)
      },
      footer: () => {
        let cur = context counter(page).get().at(0)
        let tot = context counter(page).final().at(0)
        return align(center)[
          #set text(size: 10.5pt)
          #cur / #tot
        ]
      },
    ),
    fonts: (
      heading: (
        "New Computer Modern",
        "Source Han Serif SC",
      ),
      text: (
        "New Computer Modern",
        "Source Han Serif SC",
      ),
      equation: (
        "New Computer Modern Math",
        "Source Han Serif SC",
      ),
    ),
  )
}