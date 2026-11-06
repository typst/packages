#import "@preview/ctxjs:0.1.1"

#let vegalite-bytecode = read("vegalite.kbc1", encoding: none)
#let ctx-name = "@preview/vegalite"

#{
  _ = ctxjs.create-context(ctx-name)
  _ = ctxjs.load-module-bytecode(ctx-name, vegalite-bytecode)
}

#let render(width: auto, height: auto, zoom: 1, spec) = {
  
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

  let spec2 = spec + (width: calc_width / zoom, height: calc_height / zoom)

  image.decode(ctxjs.call-module-function(
      ctx-name,
      "vegalite",
      "render_vl_helper",
      (spec2,)
    ))
  })
}