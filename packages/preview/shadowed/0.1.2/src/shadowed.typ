#let renderer = plugin("renderer.wasm")

#let render(
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
  assert(type(svg-height) == length, message: "svg-height must be of type: length")
  assert(type(svg-width) == length, message: "svg-width must be of type: length")
  assert(type(blur) == length, message: "blur must be of type: length")
  assert(type(color) == std.color, message: "color must be of type: color")
  assert(type(rect-height) == length, message: "rect-height must be of type: length")
  assert(type(rect-width) == length, message: "rect-width must be of type: length")
  assert(type(x-offset) == length, message: "x-offset must be of type: length")
  assert(type(y-offset) == length, message: "y-offset must be of type: length")
  assert(type(radius) == length, message: "radius must be of type: length")

  let image-height = svg-height
  let image-width = svg-width

  let svg-height = svg-height.pt().to-bytes()
  let svg-width = svg-width.pt().to-bytes()
  let blur = (blur.pt() / 2.5).to-bytes()
  let color = bytes(color.rgb().to-hex())
  let rect-height = rect-height.pt().to-bytes()
  let rect-width = rect-width.pt().to-bytes()
  let x-offset = x-offset.pt().to-bytes()
  let y-offset = y-offset.pt().to-bytes()
  let radius = radius.pt().to-bytes()

  let buffer = renderer.render(
    svg-height,
    svg-width,
    blur,
    color,
    rect-height,
    rect-width,
    x-offset,
    y-offset,
    radius,
  )

  image.decode(buffer, format: "svg", height: image-height, width: image-width, alt: "shadow")
}

/// Apply box shadows to inner content.
///
/// - blur (length): Blur radius of the shadow. Also adds a padding of the same size.
/// - radius (length): Corner radius of block and shadow.
/// - color (color): Color of the shadow.
/// - inset (length): Inset of the block.
/// - fill (color): Color of the block.
/// - body (content): Inner content.
/// -> content
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

  #block(breakable: false)[
    #place[
      #render(
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

    #block(inset: blur)[
      #block(radius: radius, inset: inset, fill: fill)[
        #body
      ]
    ]
  ]
])
