#let box-colors = (
  default: (stroke: luma(70), fill: white, title: white),
  red: (stroke: rgb(237, 32, 84), fill: rgb(253, 228, 224), title: white),
  green: (stroke: rgb(102, 174, 62), fill: rgb(235, 244, 222), title: white),
  blue: (stroke: rgb(29, 144, 208), fill: rgb(232, 246, 253), title: white),
)

#let colorbox(title: none, color: "default", radius: 2pt, width: auto, body) = {
  return block(
    fill: box-colors.at(color).fill,
    stroke: 2pt + box-colors.at(color).stroke,
    radius: radius,
    width: width,
  )[
    #if title != none [
      #block(
        fill: box-colors.at(color).stroke,
        inset: 8pt,
        radius: (top-left: radius, bottom-right: radius),
      )[
        #text(fill: box-colors.at(color).title, weight: "bold")[#title]
      ]
    ]

    #block(
      width: 100%,
      inset: (x: 8pt, bottom: 8pt, top: if title == none { 8pt } else { 0pt }),
    )[
      #body
    ]
  ]
}

#let slanted-colorbox(title: "Title", color: "default", radius: 2pt, width: auto, body) = {
  let slanted-background(color: black, body) = {
    set text(fill: white, weight: "bold")
    style(styles => {
      let size = measure(body, styles)
      let inset = 8pt
      [#block()[
          #polygon(
            fill: color,
            (0pt, 0pt),
            (0pt, size.height + (2 * inset)),
            (size.width + (2 * inset), size.height + (2 * inset)),
            (size.width + (2 * inset) + 6pt, 0cm),
          )
          #place(center + top, dy: size.height, dx: -3pt)[#body]
        ]]
    })
  }

  return block(
    fill: box-colors.at(color).fill,
    stroke: 2pt + box-colors.at(color).stroke,
    radius: radius,
    width: width,
  )[
    #slanted-background(color: box-colors.at(color).stroke)[#title]
    #block(width: 100%, inset: (top: -2pt, x: 10pt, bottom: 10pt))[
      #body
    ]
  ]
}

#let outline-colorbox(
  title: "Title",
  color: "default",
  width: 100%,
  radius: 2pt,
  centering: false,
  body,
) = {
  return block(
    fill: box-colors.at(color).fill,
    stroke: 2pt + box-colors.at(color).stroke,
    radius: radius,
    width: width,
    above: 26pt,
  )[
    #if centering [
      #place(top + center, dy: -12pt)[
        #block(fill: box-colors.at(color).stroke, inset: 8pt, radius: radius)[
          #text(fill: white, weight: "bold")[#title]
        ]
      ]
    ] else [
      #place(top + start, dy: -12pt, dx: 20pt)[
        #block(fill: box-colors.at(color).stroke, inset: 8pt, radius: radius)[
          #text(fill: white, weight: "bold")[#title]
        ]
      ]
    ]

    #block(width: 100%, inset: (top: 20pt, x: 10pt, bottom: 10pt))[
      #body
    ]
  ]
}

#let stickybox(rotation: 0deg, width: 100%, body) = {
  let stickyYellow = rgb(255, 240, 172)

  return rotate(
    rotation,
  )[
    #let shadow = 100%
    #if width != 100% {
      shadow = width
    }
    #place(
      bottom + center,
      dy: if type(width) == ratio { 0.2 * shadow } else { 0.05 * shadow },
    )[
      #image("background.svg", width: shadow - 3mm)
    ]
    #block(
      fill: stickyYellow,
      width: width,
    )[
      #place(
        top + center,
        dy: -2mm,
      )[
        #image(
          "tape.svg",
          width: if type(width) == ratio { calc.clamp(width * 0.35cm / 1cm, 1, 4) * 1cm } else { calc.clamp(width * 0.35 / 1cm, 1, 4) * 1cm },
          height: 4mm,
        )
      ]
      #block(width: 100%, inset: (top: 12pt, x: 8pt, bottom: 8pt))[
        #body
      ]
    ]
  ]
}