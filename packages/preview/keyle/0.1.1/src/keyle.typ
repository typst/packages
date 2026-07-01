#import "sym.typ": mac-key, biolinum-key

#let _inset = 4pt
#let _outset = 2pt
#let _radius = 3pt

#let gen-examples(kbd) = [
  #kbd("Ctrl", "Alt", "A") #h(2em)
  #kbd("Ctrl", "Shift", "A", compact: true) #h(2em)
  #kbd("Home") #kbd("End") #kbd("Ins") #kbd("Del")
]

/// Theme function to render keys in a standard style.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.standard)
/// #keyle.gen-examples(kbd)
/// ```)
/// 
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-stardard(sym) = box(
  rect(
    inset: (x: _inset),
    outset: (top: _outset),
    stroke: rgb("#555"),
    radius: _radius,
    fill: rgb("#eee"),
    text(fill: black, sym),
  ),
)

/// Theme function to render keys in a deep blue style.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.deep-blue)
/// #keyle.gen-examples(kbd)
/// ```)
/// 
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-deep-blue(sym) = box(
  rect(
    inset: (x: _inset),
    outset: (top: _outset),
    stroke: rgb("#2a6596"),
    radius: _radius,
    fill: rgb("#4682b4"),
    smallcaps(text(fill: white, sym)),
  ),
)

/// Theme function to render keys in a type writer style.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.type-writer)
/// #keyle.gen-examples(kbd)
/// ```)
/// 
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-type-writer(sym) = box(
  rect(inset: (x: _inset), stroke: rgb("#2b2b2b"), radius: 50%, fill: rgb("#333"), smallcaps(text(fill: white, sym))),
)

/// Theme function to render keys in a Linux Biolinum Keyboard style.
///
/// You need to have the font installed on your system.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.biolinum, delim: keyle.biolinum-key.delim_plus)
/// #keyle.gen-examples(kbd)
/// ```)
/// 
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-biolinum(sym) = text(
  fill: black,
  font: ("Linux Biolinum Keyboard"),
  size: 1.4em,
  sym,
)

#let themes = (
  standard: theme-func-stardard,
  deep-blue: theme-func-deep-blue,
  type-writer: theme-func-type-writer,
  biolinum: theme-func-biolinum,
)

/// Config function to generate keyboard rendering helper function.
///
/// - theme (function): The theme function to use.
/// - compact (bool): Whether to render keys in a compact format.
/// - delim (string): The delimiter to use when rendering keys in compact format.
/// -> function
#let config(
  theme: themes.standard,
  compact: false,
  delim: "+",
) = (
  (..keys, compact: compact, delim: delim) => {
    if compact {
      theme(keys.pos().join(delim))
    } else {
      if delim == biolinum-key.delim_plus or delim == biolinum-key.delim_minus {
        keys.pos().map(k => [#theme(k)]).join(theme(delim))
      } else {
        keys.pos().map(k => [#theme(k)]).join([ #box(height: 1.2em, delim) ])
      }
    }
  }
)
