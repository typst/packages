#import "@preview/showybox:2.0.3": showybox

#let box-colors = (
  default: (stroke: luma(70), fill: white, title: white),
  red: (stroke: rgb(237, 32, 84), fill: rgb(253, 228, 224), title: white),
  green: (stroke: rgb(102, 174, 62), fill: rgb(235, 244, 222), title: white),
  blue: (stroke: rgb(29, 144, 208), fill: rgb(232, 246, 253), title: white),
  purple: (stroke: rgb(137, 89, 168), fill: rgb(230, 217, 243), title: white),
  gray: (stroke: rgb(158, 158, 158), fill: rgb(245, 245, 245), title: white),
  cyan: (stroke: rgb(0, 188, 212), fill: rgb(224, 247, 250), title: white),
  teal: (stroke: rgb(0, 150, 136), fill: rgb(224, 242, 241), title: white),
  indigo: (stroke: rgb(63, 81, 181), fill: rgb(232, 234, 246), title: white),
  gold: (stroke: rgb(212, 175, 55), fill: rgb(255, 247, 207), title: white),
  lavender: (stroke: rgb(150, 123, 182), fill: rgb(238, 230, 250), title: white),
  sand: (stroke: rgb(194, 178, 128), fill: rgb(245, 238, 222), title: white),
)

#let colorbox(
  title: none,
  box-colors: box-colors,
  color: "default",
  radius: 2pt,
  inset: 8pt,
  stroke: 2pt,
  width: auto,
  body,
) = {
  let stroke-color = black
  let fill-color = gray.lighten(50%)
  let title-color = white
  if type(color) == str {
    stroke-color = box-colors.at(color, default:(stroke: black)).stroke
    fill-color = box-colors.at(color, default:(fill: gray.lighten(50%))).fill
  } else if type(color) == dictionary {
    stroke-color = color.at("stroke", default: stroke-color)
    fill-color = color.at("fill", default: fill-color)
    title-color = color.at("text", default: title-color)
  }
  if title != none {
    return showybox(
      title: title,
      breakable: true,
      frame: (
        title-color: stroke-color,
        body-color: fill-color,
        border-color: stroke-color,
        radius: radius,
        thickness: stroke,
        body-inset: (top: inset + 4pt, rest: inset),
      ),
      title-style: (
        color: title-color,
        weight: "bold",
        boxed-style: (
          anchor: (
            x: left,
            y: top,
          ),
          offset: (
            x: -1em,
          ),
          radius: (top-left: radius, bottom-right: radius),
        ),
      ),
      body-style: (
        align: left,
        color: black,
      ),
      width: width,
    )[
      #body
    ]
  } else {
    return showybox(
      breakable: true,
      frame: (
        title-color: stroke-color,
        body-color: fill-color,
        border-color: stroke-color,
        radius: radius,
        thickness: stroke,
        body-inset: inset,
      ),
      title-style: (
        color: title-color,
        weight: "bold",
        boxed-style: (
          anchor: (
            x: left,
            y: top,
          ),
          offset: (
            x: -1em,
          ),
          radius: (radius),
        ),
      ),
      body-style: (
        align: left,
        color: black,
      ),
      width: width,
    )[
      #body
    ]
  }
}

#let colorbox-rounded(
  title: none,
  box-colors: box-colors,
  color: "default",
  radius: 2pt,
  inset: 8pt,
  stroke: 2pt,
  width: auto,
  body,
) = {
  let stroke-color = black
  let fill-color = gray.lighten(50%)
  let title-color = white
  if type(color) == str {
    stroke-color = box-colors.at(color, default:(stroke: black)).stroke
    fill-color = box-colors.at(color, default:(fill: gray.lighten(50%))).fill
  } else if type(color) == dictionary {
    stroke-color = color.at("stroke", default: stroke-color)
    fill-color = color.at("fill", default: fill-color)
    title-color = color.at("text", default: title-color)
  }
  showybox(
    title: title,
    breakable: true,
    frame: (
      title-color: stroke-color,
      body-color: fill-color,
      border-color: stroke-color,
      radius: radius,
      thickness: stroke,
      body-inset: inset,
    ),
    title-style: (
      color: title-color,
      weight: "bold",
      boxed-style: (
        anchor: (
          x: left,
          y: top,
        ),
        offset: (
          x: -1em,
        ),
        radius: (radius),
      ),
    ),
    body-style: (
      align: left,
      color: black,
    ),
    width: width,
  )[
    #body
  ]
}

#let slanted-colorbox(
  title: "Title",
  box-colors: box-colors,
  color: "default",
  radius: 2pt,
  stroke: 2pt,
  inset: 8pt,
  width: auto,
  body,
) = {
  let stroke-color = black
  let fill-color = gray.lighten(50%)
  let title-color = white
  if type(color) == str {
    stroke-color = box-colors.at(color, default:(stroke: black)).stroke
    fill-color = box-colors.at(color, default:(fill: gray.lighten(50%))).fill
  } else if type(color) == dictionary {
    stroke-color = color.at("stroke", default: stroke-color)
    fill-color = color.at("fill", default: fill-color)
    title-color = color.at("text", default: title-color)
  }
  showybox(
    breakable: true,
    frame: (
      body-color: fill-color,
      border-color: stroke-color,
      radius: radius,
      thickness: stroke,
      body-inset: 0pt,
    ),
    width: width,
  )[
    #context {
      let size = measure(title)
      let inset = 8pt
      polygon(
        fill: stroke-color,
        (0pt, 0pt),
        (0pt, size.height + (2 * inset)),
        (size.width * 1.11 + (2 * inset), size.height + (2 * inset)),
        (size.width * 1.11 + (2 * inset) + 6pt, 0cm),
      )
    }
    #place(left + top, dx: 10pt, dy: 7pt)[
      #text(fill: white, weight: "bold")[#title]
    ]
    #block(inset: (top: inset - 10pt, rest: inset))[
      #body
    ]
  ]
}


#let outline-colorbox(
  title: "Title",
  box-colors: box-colors,
  color: "default",
  width: 100%,
  radius: 2pt,
  stroke: 2pt,
  inset: 8pt,
  centering: false,
  body,
) = {
  let stroke-color = black
  let fill-color = gray.lighten(50%)
  let title-color = white
  if type(color) == str {
    stroke-color = box-colors.at(color, default:(stroke: black)).stroke
    fill-color = box-colors.at(color, default:(fill: gray.lighten(50%))).fill
  } else if type(color) == dictionary {
    stroke-color = color.at("stroke", default: stroke-color)
    fill-color = color.at("fill", default: fill-color)
    title-color = color.at("text", default: title-color)
  }
  return showybox(
    title: text(fill: white, weight: "bold")[#title],
    breakable: true,
    frame: (
      title-color: stroke-color,
      body-color: fill-color,
      border-color: stroke-color,
      radius: radius,
      thickness: stroke,
      body-inset: inset,
    ),
    title-style: (
      color: title-color,
      weight: "bold",
      boxed-style: (
        anchor: (
          x: if centering { center } else { left },
          y: horizon,
        ),
        offset: (
          x: if centering { 0em } else { 1em },
        ),
        radius: (radius),
      ),
    ),
    width: width,
  )[
    #body
  ]
}

#let stickybox(rotation: 0deg, width: 100%, fill: rgb(255, 240, 172), tape: true, body) = {
  return rotate(rotation)[
    #block(width: width)[
      #layout(size => {
        let height = measure(image("background.svg", width: size.width)).height
        place(
          bottom + center,
          dy: 0.6 * height,
        )[
          #image("background.svg", width: size.width)
        ]
        box(
          fill: fill,
          width: width,
          inset: (top: if tape { 12pt } else { 8pt }, x: 8pt, bottom: 8pt),
        )[
          #body
          #if tape {
            place(
              top + center,
              dy: -2mm - 12pt,
            )[
              #image(
                "tape.svg",
                width: if type(width) == ratio { calc.clamp(width * 0.35cm / 1cm, 1, 4) * 1cm } else {
                  calc.clamp(width * 0.35 / 1cm, 1, 4) * 1cm
                },
                height: 4mm,
              )
            ]
          }
        ]
      })
    ]
  ]
}
