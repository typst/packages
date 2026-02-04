#import "@preview/ctxjs:0.3.2"
#import ctxjs.load
#import ctxjs.ctx

#let spell-number(
  /// The number
  /// -> int
  number,
  /// The language
  /// -> str
  lang: "en"
) = {
  assert(type(number) == int, message: "number is not an int")

  let code = read("n2w.minified.js")
  let n2w-context = ctx.load-module-js(ctxjs.new-context(), "n2w", code)

  ctx.call-module-function(n2w-context, "n2w", "default", (number, (lang: lang,)))
}
