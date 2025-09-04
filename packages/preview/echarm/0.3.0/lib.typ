#import "@preview/ctxjs:0.3.1"

#let echarm-bytecode = read("echarm.kbc1", encoding: none)

#let echarm-js-module = ctxjs.new-context(
  load: (
    ctxjs.load.load-module-bytecode(echarm-bytecode),
  )
)

#let eval-later(js) = ctxjs.ctx.eval-later(js)

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

    image(
      bytes(
        ctxjs.ctx.call-module-function(
          echarm-js-module,
          "echarm",
          "render",
          (
            calc_width / zoom,
            calc_height / zoom,
            options,
          )
        ),
      ),
      width: width,
      height: height,
      format: "svg",
      fit: "cover"
    )
  })
}