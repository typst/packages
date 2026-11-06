#import "@preview/codetastic:0.1.0": qrcode

#let colorbox(title: "title", color: none, radius: 2pt, width: auto, body) = {

  let strokeColor = luma(70)
  let backgroundColor = white

  if color == "red" {
    strokeColor = rgb(237, 32, 84)
    backgroundColor = rgb(253, 228, 224)
  } else if color == "green" {
    strokeColor = rgb(102, 174, 62)
    backgroundColor = rgb(235, 244, 222)
  } else if color == "blue" {
    strokeColor = rgb(29, 144, 208)
    backgroundColor = rgb(232, 246, 253)
  }

  return box(
    fill: backgroundColor,
    stroke: 2pt + strokeColor,
    radius: radius,
    width: width
  )[
    #block(
      fill: strokeColor, 
      inset: 8pt,
      radius: (top-left: radius, bottom-right: radius),
    )[
      #text(fill: white, weight: "bold")[#title]
    ]
    #block(
      width: 100%,
      inset: (x: 8pt, bottom: 8pt)
    )[
      #body
    ]
  ]
}

#let slantedBackground(color: black, body) = {
  set text(fill: white, weight: "bold")
  style(styles => {
    let size = measure(body, styles)
    let inset = 8pt
    [#block()[
      #polygon(
        fill: color,
        (0pt, 0pt),
        (0pt, size.height + (2*inset)),
        (size.width + (2*inset), size.height + (2*inset)),
        (size.width + (2*inset) + 6pt, 0cm)
      )
      #place(center + top, dy: size.height, dx: -3pt)[#body]
    ]]
  })
}

#let slantedColorbox(title: "title", color: none, radius: 0pt, width: auto, body) = {

  let strokeColor = luma(70)
  let backgroundColor = white

  if color == "red" {
    strokeColor = rgb(237, 32, 84)
    backgroundColor = rgb(253, 228, 224)
  } else if color == "green" {
    strokeColor = rgb(102, 174, 62)
    backgroundColor = rgb(235, 244, 222)
  } else if color == "blue" {
    strokeColor = rgb(29, 144, 208)
    backgroundColor = rgb(232, 246, 253)
  }

  return box(
    fill: backgroundColor,
    stroke: 2pt + strokeColor,
    radius: radius,
    width: width
  )[
    #slantedBackground(color: strokeColor)[#title]
    #block(
      width: 100%,
      inset: (top: -2pt, x: 10pt, bottom: 10pt)
    )[
      #body
    ]
  ]
}

#let outlinebox(title: "title",color: none, width: 100%, radius: 2pt, centering: false, body) = {

  let strokeColor = luma(70)

  if color == "red" {
    strokeColor = rgb(237, 32, 84)
  } else if color == "green" {
    strokeColor = rgb(102, 174, 62)
  } else if color == "blue" {
    strokeColor = rgb(29, 144, 208)
  }
  
  return block(
      stroke: 2pt + strokeColor,
      radius: radius,
      width: width,
      above: 26pt,
    )[
      #if centering [
        #place(top + center, dy: -12pt)[
          #block(
            fill: strokeColor,
            inset: 8pt,
            radius: radius,
          )[
            #text(fill: white, weight: "bold")[#title]
          ]
        ]
      ] else [
        #place(top + start, dy: -12pt, dx:20pt)[
          #block(
            fill: strokeColor,
            inset: 8pt,
            radius: radius,
          )[
            #text(fill: white, weight: "bold")[#title]
          ]
        ]
      ]
      
      #block(
        width: 100%,
        inset: (top:20pt, x: 10pt, bottom: 10pt)
      )[
        #body
      ]
    ]
}

#let stickybox(rotation: 0deg, width: 100%, body) = {
  let stickyYellow = rgb(255, 240, 172)
  
  return rotate(rotation)[
    #let shadow = 100%
    #if width != 100% {
      shadow = width
    }
    #place(bottom + center, dy: 0.04*shadow)[
      #image("background.svg",
        width: shadow - 3mm,
      )
    ]
    #block(
      fill: stickyYellow,
      width: width
    )[   
      #place(top + center, dy: -2mm)[
        #image("tape.svg",
          width: calc.clamp(width * 0.35 / 1cm, 1, 4) * 1cm,
          height: 4mm,
        )
      ]
      #block(
        width: 100%,
        inset: (top:12pt, x: 8pt, bottom: 8pt)
      )[
        #body
      ]
    ]
  ]
}

#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #codetastic.qrcode(url, colors: (rgba(255,255,255,0), black))
    #text(size:10pt,[
     #link(url)[#fa-external-link(fill:blue) #text(fill:blue,[#name])]
    ])
  ]
}