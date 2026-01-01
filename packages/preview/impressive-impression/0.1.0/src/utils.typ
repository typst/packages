/// Makes content square by clipping it
#let crop-square = (c) => context {
  let dims = measure(c)

  layout(size => {
    let min_size = calc.min(dims.width, dims.height)

    let width-source-trimmed = min_size / dims.width
    let height-source-trimmed = min_size / dims.height

    let top = (100% - (height-source-trimmed * 100%)) / 2
    let bottom = top
    let left = (100% - (width-source-trimmed * 100%)) / 2
    let right = left

    let width-rel-trimmed = 100.0% - left - right
    let height-rel-trimmed = 100.0% - top - bottom

    // Aspect ratio h/w of the layout (available space)
    let aspect-height-layout = size.height / size.width
    // Aspect ratio h/w of the trimmed image
    let aspect-height-trimmed = height-source-trimmed / width-source-trimmed

    let width-final-trimmed = none
    let height-final-trimmed = none

    // Compute final size of trimmed image
    // by expanding along dimension that first hits the layout constraints
    if aspect-height-layout >= aspect-height-trimmed {
      // Expand width of image
      width-final-trimmed = size.width
      height-final-trimmed = aspect-height-trimmed * width-final-trimmed
    } else {
      // Expand height of image
      height-final-trimmed = size.height
      width-final-trimmed = size.height / aspect-height-trimmed
    }

    // Compute the hypothetical size of the image without trimming
    let width-final-untrimmed = width-final-trimmed / float(width-rel-trimmed)
    let height-final-untrimmed = height-final-trimmed / float(height-rel-trimmed)

    box(
      clip: true,
      inset: (
          top: -(top * height-final-untrimmed),
          bottom: -(bottom * height-final-untrimmed),
          left: -(left * width-final-untrimmed),
          right: -(right * width-final-untrimmed)
        ),
      c,
    )
  })
}

/// Crops an image to a square with rounded corners and a stroke
/// If radius is ≥ 50%, it will be a circle
#let crop-image(
  image: image,
  size: auto,
  radius: none,
  stroke: none,
) = {
  let squared-image = crop-square(image)
  box(squared-image, radius: radius, clip: true, width: size, stroke: stroke)
}

/// Colorizes an SVG using crude regex replacement.
/// Initial code taken from https://github.com/typst/typst/issues/1939#issuecomment-1680154871
#let colorize-svg-string(
  /// The SVG string to colorize
  /// -> string
  svg,
  /// The color to use for the fill
  /// -> color
  color,
  /// Additional arguments for the image function
  /// -> arguments
  ..image-args
) = {
  let select = regex("fill=\"([^\"]*)\"")
  if svg.contains(select) {
    // Just replace
    svg = svg.replace(select, "fill=\""+color.to-hex()+"\"")
  } else {
    // Explicitly state color
    svg = svg.replace("<svg ", "<svg fill=\""+color.to-hex()+"\" ")
  }

  return image(bytes(svg), format: "svg", ..image-args)
}
