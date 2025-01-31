#import "@preview/ctxjs:0.2.0"

#let echarm-bytecode = read("echarm.kbc1", encoding: none)

#{
  _ = ctxjs.create-context("@preview/echarm")
  _ = ctxjs.load-module-bytecode("@preview/echarm", echarm-bytecode)
}

#let eval-later(js) = ctxjs.eval-later("@preview/echarm", js)

#let render(width: auto, height: auto, zoom: 1, options: (:)) = {
  layout(size => {
    let calc_height = height
    let calc_width = width
    if type(calc_height) == ratio {
      calc_height = size.height * calc_height
    } else if type(calc_height) == relative {
      calc_height = size.height * calc_height.ratio + calc_height.length
    }
    if type(calc_width) == ratio {
      calc_width = size.width * calc_width
    } else if type(calc_width) == relative {
      calc_width = size.width * calc_width.ratio + calc_width.length
    }
    calc_height = (calc_height).pt()
    calc_width = (calc_width).pt()

    image.decode(
      ctxjs.call-module-function(
        "@preview/echarm",
        "echarm",
        "render",
        (
          calc_width / zoom,
          calc_height / zoom,
          options,
        )
      ),
      width: width,
      height: height,
      format: "svg",
      fit: "cover"
    )
  })
}