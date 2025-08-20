#import "sym.typ": com-key, mac-key

#let _inset = 4pt
#let _outset = 2pt
#let _radius = 3pt

#let _kbd-stardard-style(sym) = box(rect(
  inset: (x: _inset),
  outset: (top: _outset),
  stroke: rgb("#555"),
  radius: _radius,
  fill: rgb("#eee"),
  text(fill: black, sym),
))

#let _kbd-deep-blue-style(sym) = box(rect(
  inset: (x: _inset),
  outset: (top: _outset),
  stroke: rgb("#2a6596"),
  radius: _radius,
  fill: rgb("#4682b4"),
  smallcaps(text(fill: white, sym)),
))

#let _kbd-type-writer-style(sym) = box(
  rect(inset: (x: _inset), stroke: rgb("#2b2b2b"), radius: 50%, fill: rgb("#333"), smallcaps(text(fill: white, sym))),
)

#let _kbd-style-funcs = (standard: _kbd-stardard-style, deep-blue: _kbd-deep-blue-style, type-writer: _kbd-type-writer-style)

#let kbd-styles = (standard: "standard", deep-blue: "deep-blue", type-writer: "type-writer")

#let kbd-state = state("kbd-style-state", kbd-styles.standard)

/// Set the keyboard style.
/// 
/// #example(```typ
///   #keyle.kbd[A]  // standard style
///   #keyle.kbd-set-style("deep-blue")
///   #keyle.kbd[A]  // deep-blue style
///   #keyle.kbd-set-style(keyle.kbd-styles.standard) // back to standard style
/// ```)
/// 
/// - s (string): The style name. Use `kbd-styles` to get available styles.
#let kbd-set-style(s) = {
  kbd-state.update(s)
}

/// Renders a keyboard key.
/// 
/// #example(```typ
/// #keyle.kbd("Ctrl", "A")
/// ```)
/// 
/// #example(```typ
/// #keyle.kbd("Ctrl", "A", compact: true)
/// ```)
/// 
/// #example(```typ
/// #keyle.kbd("Ctrl", "A", compact: true, delim: "-")
/// ```)
/// 
/// - ..keys (string): The key to render.
/// - compact (bool): If true, the keys will be rendered in a single box.
/// - delim (string): The delimiter to use when rendering in compact mode.
#let kbd(..keys, compact: false, delim: "+") = {
  locate(loc => {
    let style-str = kbd-state.at(loc)
    let style-func = _kbd-style-funcs.at(style-str)
    if compact {
      style-func(keys.pos().join(delim))
    } else {
      keys.pos().map(k => [#style-func(k)]).join([ #box(height: 1.2em, delim) ])
    }
  })
}

#let kbd-example = align(center)[
  #box([
    #kbd[1] #kbd[2] #kbd[3] #kbd[4] #kbd[5] #kbd[6] #kbd[7] #kbd[8] #kbd[9] #kbd[0]\
    #kbd[Q] #kbd[W] #kbd[E] #kbd[R] #kbd[T] #kbd[Y] #kbd[U] #kbd[I] #kbd[O] #kbd[P]\
    #kbd[A] #kbd[S] #kbd[D] #kbd[F] #kbd[G] #kbd[H] #kbd[J] #kbd[K] #kbd[L]\
    #kbd[Z] #kbd[X] #kbd[C] #kbd[V] #kbd[B] #kbd[N] #kbd[M]
  ])
]

#let kbd-mac-example = align(
  center,
)[
  #box(
    [
      #kbd(mac-key.command) #kbd(mac-key.shift) #kbd(mac-key.option) #kbd(mac-key.control) #kbd(mac-key.return) #kbd(mac-key.delete) #kbd(mac-key.forward-delete) #kbd(mac-key.escape) #kbd(mac-key.left) #kbd(mac-key.right) #kbd(mac-key.up) #kbd(mac-key.down) #kbd(mac-key.pageup) #kbd(mac-key.pagedown) #kbd(mac-key.home) #kbd(mac-key.end) #kbd(mac-key.tab-right) #kbd(mac-key.tab-left)
    ],
  )
]

#let kbd-com-example = align(
  center,
)[
  #box(
    [
      #kbd(com-key.control) #kbd(com-key.shift) #kbd(com-key.alt) #kbd(com-key.return) #kbd(com-key.delete) #kbd(com-key.escape) #kbd(com-key.left) #kbd(com-key.right) #kbd(com-key.up) #kbd(com-key.down) #kbd(com-key.pageup) #kbd(com-key.pagedown) #kbd(com-key.home) #kbd(com-key.end) #kbd(com-key.tab)
    ],
  )
]