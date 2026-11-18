// Color palette shared by all trees. `defaults` is the built-in palette;
// `set-colors` pushes a changed palette for the content it wraps; the one
// in use is the last on the stack, read with `palette.get().last()` inside `context`.

#let defaults = (
  border: rgb("#1a2b4c"),
  fill: rgb("#f4f7f9"),
  // nodes the user passed in `marked`
  marked: rgb("#1f6fb2"),
  marked-fill: rgb("#d6e8f7"),
  // nodes that break the rules of their tree type (`show-errors`)
  error: rgb("#c0392b"),
  error-fill: rgb("#fdecea"),
  // priorities in treap nodes (same as the key text for now)
  priority: black,
  // array indices next to heap nodes (same as the balance factors for now)
  index: rgb("#1f6fb2"),
)

// Stack of palettes: `set-colors` pushes one before its content and pops it after.
#let stack = state("sapling-colors", (defaults,))

// The palette in use. Call inside `context`.
#let palette() = stack.get().last()

// Shows `body` with the named colors changed, the others stay as they are.
// Use it as `#show: set-colors.with(error: red)` or `#set-colors(error: red)[...]`.
#let set-colors(body, ..colors) = {
  assert(
    colors.pos().len() == 0,
    message: "sapling: set-colors takes only named colors, e.g. set-colors(error: red)",
  )
  for (name, value) in colors.named() {
    assert(
      name in defaults,
      message: "sapling: unknown color " + repr(name) + ", expected one of " + defaults.keys().join(", "),
    )
    assert(
      type(value) == color,
      message: "sapling: color " + name + " must be a color, got " + repr(value),
    )
  }
  stack.update(s => s + (s.last() + colors.named(),))
  body
  stack.update(s => s.slice(0, -1))
}

// Stroke and fill of a node or cell in palette `c`: errors win over marked nodes.
#let style(c, error: false, marked: false) = {
  if error {
    (1.3pt + c.error, c.error-fill)
  } else if marked {
    (1.3pt + c.marked, c.marked-fill)
  } else {
    (0.7pt + c.border, c.fill)
  }
}
