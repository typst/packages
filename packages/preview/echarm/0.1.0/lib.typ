#import "@preview/ctxjs:0.1.0"

#let echarts-bytecode = read("echarts.kbc1", encoding: none)
#let echart-helper = read("echarts_helper.js", encoding: none)

#{
  _ = ctxjs.create-context("@preview/echarm")
  _ = ctxjs.eval("@preview/echarm", "function setTimeout(functionRef, delay, ...args) { if(!delay) {functionRef();} }")
  _ = ctxjs.load-module-bytecode("@preview/echarm", echarts-bytecode)
  _ = ctxjs.load-module-js("@preview/echarm", "echarts_helper", echart-helper)
}

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
        "echarts_helper",
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