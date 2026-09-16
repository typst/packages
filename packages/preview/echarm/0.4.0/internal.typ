#import "@preview/ctxjs:0.5.0"

#let ctxjs-context = ctxjs.new-context(
  ctxjs.load.load-module-bytecode(
    read("echarm.kbc1", encoding: none),
  ),
)
