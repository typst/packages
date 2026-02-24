#let renderer = plugin("renderer.wasm")

#let render(
  svg-height,
  svg-width,
  deviation,
  color,
  rect-height,
  rect-width,
  x-offset,
  y-offset,
  radius,
) = {
  assert(type(svg-height) == length, message: "svg-height must be of type: length")
  assert(type(svg-width) == length, message: "svg-width must be of type: length")
  assert(type(deviation) == length, message: "deviation must be of type: length")
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
  let deviation = deviation.pt().to-bytes()
  let color = bytes(color.rgb().to-hex())
  let rect-height = rect-height.pt().to-bytes()
  let rect-width = rect-width.pt().to-bytes()
  let x-offset = x-offset.pt().to-bytes()
  let y-offset = y-offset.pt().to-bytes()
  let radius = radius.pt().to-bytes()

  let buffer = renderer.render(
    svg-height,
    svg-width,
    deviation,
    color,
    rect-height,
    rect-width,
    x-offset,
    y-offset,
    radius,
  )

  if sys.version == version(0, 12, 0) {
    image.decode(buffer, format: "svg", height: image-height, width: image-width, alt: "shadow")
  } else {
    image(buffer, format: "svg", height: image-height, width: image-width, alt: "shadow")
  }
}

/// Apply box shadows to inner content.
///
/// - fill (color): The block's background color.
/// - radius (length): How much to round the block's corners.
/// - inset (length): How much to pad the block's content.
/// - clip (bool): Whether to clip the content inside the block.
/// - shadow (length): Blur radius of the shadow. Also adds a padding of the same size.
/// - color (color): Color of the shadow.
/// - dx (relative): The horizontal displacement of the shadow. Does not alter the block's padding.
/// - dy (relative): The vertical displacement of the shadow. Does not alter the block's padding.
/// - body (content): The contents of the block.
/// -> content
#let shadowed(
  fill: white,
  radius: 0pt,
  inset: 0pt,
  clip: false,
  shadow: 8pt,
  color: rgb(89, 85, 101, 30%),
  dx: 0% + 0pt,
  dy: 0% + 0pt,
  padding: auto,
  body,
) = layout(size => [
  #let (width, height) = measure(width: size.width, height: size.height)[
    #block(inset: shadow, breakable: false)[
      #block(inset: inset)[
        #body
      ]
    ]
  ]

  #block(breakable: false)[
    #place(dx: dx, dy: dy)[
      #render(
        height, // svg-height
        width, // svg-width
        shadow / 2.5, // deviation
        color, // color
        height - shadow * 2, // rect-height
        width - shadow * 2, // rect-width
        shadow, // x-offset
        shadow, // y-offset
        radius, // radius
      )
    ]

    #block(inset: shadow, breakable: false)[
      #block(fill: fill, radius: radius, inset: inset, clip: clip)[
        #body
      ]
    ]
  ]
])
