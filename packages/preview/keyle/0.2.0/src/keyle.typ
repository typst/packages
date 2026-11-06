#import "sym.typ": mac-key, biolinum-key

#let shadow-times = 6

/// Generate examples for the given keyboard rendering function.
/// 
/// - kbd (function): The keyboard rendering function.
/// -> content
#let gen-examples(kbd) = [
#kbd("Ctrl", "A") #h(1em) #kbd("Alt", "P", compact: true)

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
#let theme-func-stardard(sym) = box({
  let text-color = black
  let bg-color = rgb("#eee")
  let stroke-color = rgb("#555")

  let cust-rect = rect.with(
    inset: (x: 3pt),
    stroke: stroke-color + 0.6pt,
    radius: 2pt,
    fill: bg-color,
  )
  let button = cust-rect(
    text(fill: black, sym),
  )
  let shadow = cust-rect(
    fill: stroke-color,
    text(fill: bg-color, sym),
  )
  for n in range(shadow-times) {
    place(dx: 0.2pt * n, dy: 0.2pt * n, shadow)
  }
  button
})

/// Theme function to render keys in a deep blue style.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.deep-blue)
/// #keyle.gen-examples(kbd)
/// ```)
///
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-deep-blue(sym) = box({
  let text-color = white
  let bg-color = rgb("#16456b")
  let stroke-color = rgb("#4682b4")

  let cust-rect = rect.with(
    inset: (x: 3pt),
    stroke: bg-color + 0.6pt,
    radius: 2pt,
    fill: stroke-color,
  )
  let button = cust-rect(
    smallcaps(text(fill: white, sym)),
  )
  let shadow = cust-rect(fill: bg-color, smallcaps(text(fill: bg-color, sym)))
  for n in range(shadow-times) {
    place(dx: 0.2pt * n, dy: 0.2pt * n, shadow)
  }
  button
})

/// Theme function to render keys in a type writer style.
///
/// #example(```typst
/// #let kbd = keyle.config(theme: keyle.themes.type-writer)
/// #keyle.gen-examples(kbd)
/// ```)
///
/// - sym (string): The key symbol to render.
/// -> content
#let theme-func-type-writer(sym) = box({
  let text-color = white
  let bg-color = rgb("#333")
  let stroke-color = rgb("#2b2b2b")

  let cust-rect = rect.with(
    inset: (x: 2pt),
    stroke: bg-color,
    fill: stroke-color,
    radius: 50%,
  )

  let button = cust-rect(
    smallcaps(text(fill: white, sym)),
  )
  let shadow = cust-rect(
    outset: 2.2pt,
    fill: white,
    stroke: stroke-color + 1.2pt,
    smallcaps(text(fill: bg-color, sym)),
  )
  box(
    inset: 2pt,
    {
      place(shadow)
      button
    },
  )

})

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
        context keys.pos().map(k => [#theme(k)]).join(
          box(
            height: measure(theme("A")).height,
            inset: 2pt,
            align(horizon, delim),
          ),
        )
      }
    }
  }
)
