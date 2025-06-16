#let __renderer = plugin("renderer.wasm")

#let __render(
  svg-height,
  svg-width,
  blur,
  color,
  rect-height,
  rect-width,
  x-offset,
  y-offset,
  radius,
) = {
  assert(type(svg-height) == type(0pt), message: "svg-height must be of type: Length")
  assert(type(svg-width) == type(0pt), message: "svg-width must be of type: Length")
  assert(type(blur) == type(0pt), message: "blur must be of type: Length")
  assert(type(color) == type(rgb(0, 0, 0)), message: "color must be of type: Color")
  assert(type(rect-height) == type(0pt), message: "rect-height must be of type: Length")
  assert(type(rect-width) == type(0pt), message: "rect-width must be of type: Length")
  assert(type(x-offset) == type(0pt), message: "x-offset must be of type: Length")
  assert(type(y-offset) == type(0pt), message: "y-offset must be of type: Length")
  assert(type(radius) == type(0pt), message: "radius must be of type: Length")

  let svg-height = bytes(str(svg-height.pt()))
  let svg-width = bytes(str(svg-width.pt()))
  let blur = bytes(str(blur.pt() / 2.5))
  let color = bytes(color.rgb().to-hex())
  let rect-height = bytes(str(rect-height.pt()))
  let rect-width = bytes(str(rect-width.pt()))
  let x-offset = bytes(str(x-offset.pt()))
  let y-offset = bytes(str(y-offset.pt()))
  let radius = bytes(str(radius.pt()))

  let buffer = __renderer.render(svg-height, svg-width, blur, color, rect-height, rect-width, x-offset, y-offset, radius)

  image.decode(buffer, format: "svg", alt: "shadow")
}

#let shadowed(
  blur: 8pt,
  radius: 0pt,
  color: rgb(89, 85, 101, 30%),
  inset: 0pt,
  fill: white,
  body,
) = layout(size => [
  #let dims = measure[
    #block(breakable: false)[
      #block(radius: radius, inset: blur)[
        #block(inset: inset)[
          #body
        ]
      ]
    ]
  ]

  #let width = calc.min(size.width, dims.width)

  #let height = measure[
    #block(breakable: false)[
      #block(radius: radius, inset: blur, width: width)[
        #block(inset: inset)[
          #body
        ]
      ]
    ]
  ].height

  #block()[
    #place[
      #__render(
        height, // svg-height
        width, // svg-width
        blur, // blur
        color, // color
        height - blur * 2, // rect-height
        width - blur * 2, // rect-width
        blur, // x-offset
        blur, // y-offset
        radius, // radius
      )
    ]

    #block(inset: blur, breakable: false)[
      #block(radius: radius, inset: inset, fill: fill)[
        #body
      ]
    ]
  ]
])
