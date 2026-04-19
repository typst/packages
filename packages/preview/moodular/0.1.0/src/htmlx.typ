#import "libs.typ": bullseye.html

/// A thin wrapper around Typst's `html.elem` that collects all named arguments into the `attrs`
/// parameter. For example, these two are equivalent:
///
/// ```typc
/// html.elem("div", attrs: (class: "x"))[body]
/// htmlx.elem("div", class: "x")[body]
/// ```
///
/// -> content
#let elem(
  /// -> any
  ..args,
) = {
  let (args, attrs) = (args.pos(), args.named())
  html.elem(..args, attrs: attrs)
}

/// A thin wrapper for creating div html elements. In other words, these two are equivalent:
///
/// ```typc
/// htmlx.elem("div", class: "x")[body]
/// htmlx.div(class: "x")[body]
/// ```
///
/// -> content
#let div = elem.with("div")

/// A thin wrapper for creating img html elements, making the required `src` attribute positional.
/// In other words, these two are equivalent:
///
/// ```typc
/// htmlx.elem("img", src: "example.png", alt: "Example")
/// htmlx.img("example.png", alt: "Example")
/// ```
///
/// -> content
#let img(src, ..args) = elem("img", src: src, ..args)
