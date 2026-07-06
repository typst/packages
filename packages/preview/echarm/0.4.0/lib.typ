#import "internal.typ" as _internal
#import _internal.ctxjs.value as value
#import "theme.typ" as theme
#import "language.typ" as language

#let render(width: auto, height: auto, zoom: 1.0, alt: none, options: (:), theme: none, language: none) = {
  layout(size => {
    let calc_height = height
    let calc_width = width
    if type(calc_height) == ratio {
      calc_height = size.height * calc_height
    } else if type(calc_height) == relative {
      calc_height = size.height * calc_height.ratio + calc_height.length
    } else if calc_height == auto {
      calc_height = size.height
    }
    if type(calc_width) == ratio {
      calc_width = size.width * calc_width
    } else if type(calc_width) == relative {
      calc_width = size.width * calc_width.ratio + calc_width.length
    } else if calc_width == auto {
      calc_width = size.width
    }
    calc_height = (calc_height).pt()
    calc_width = (calc_width).pt()

    let current-context = _internal.ctxjs-context
    let (current-context, value) = _internal.ctxjs.ctx.call-module-function(
      current-context,
      "echarm",
      "render",
      calc_width / zoom,
      calc_height / zoom,
      options,
      theme,
      language,
    )

    image(
      bytes(value),
      width: width,
      height: height,
      format: "svg",
      fit: "cover",
      alt: alt,
    )
  })
}
