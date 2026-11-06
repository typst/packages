#let func-seq = [].func()
#let func-counter-update = [#counter("_cdl").update(0)].func()
#let func-state-update = [#state("_cdl").update(none)].func()
// set text, set align, set par, lower, upper, have others?
#let func-styled = [#text(fill: red, [])].func()
#let func-layout = [#layout(_ => none)].func()
#let func-flush = place.flush().func()

/// All the text-style functions
#let text-style-func = (
  highlight,
  overline,
  smallcaps,
  strike,
  sub,
  super,
  underline,
  strong,
  emph,
)


/// The function of `enum.item`, `list.item`, // enum, list
#let item-func = (enum.item, list.item, enum, list)

/// Checks if the content is blank. (also including `v`.)
#let is_blank-elem(e) = {
  // `pagebreak()` is illegel
  return (
    e in ([ ], parbreak(), colbreak(), none, [])
      or e.func() in (func-counter-update, func-state-update, func-flush, metadata, v)
  )
}

/// Checks if an element is styled.
#let is_styled(e) = {
  return e.func() == func-styled
}

/// Checks if an element has a text style.
#let is_text-styled(e) = {
  return e.func() in text-style-func
}

/// Checks if an element is an item (i.e. constructed by `enum` or `list`).
#let is_item(e) = {
  return e.func() in item-func
}

/// length type (length, relative, ratio)
#let length-type = (length, relative, ratio)
/// length type (length, relative, ratio, fraction)
#let length-type-with-fraction = (length, relative, ratio, fraction)

#let block-level-elem = (
  (
    //
    figure,
    heading,
    //
    table,
    grid,
    block, //
    columns,
    func-layout,
    //
    move,
    pad,
    //
    repeat,
    //
    rotate,
    scale,
    skew,
    stack,
    //
    outline,
    //
    circle,
    ellipse,
    rect,
    square,
    //
    curve,
    image,
    // line, // ???
    // polygon, // ???
    enum, // ????
    list, // ????
  )
    + (raw.where(block: true), quote.where(block: true))
    + if sys.version >= std.version(0, 14, 0) { (title,) }
    + if sys.version >= std.version(0, 15, 0) { (divider,) }
)
