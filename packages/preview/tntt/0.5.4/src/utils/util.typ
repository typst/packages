//! Utility functions for TNTT templates.

/// Get the element at the given position in the array.
///
/// - arr (array): The array to get the element from
/// - pos (int): The position of the element to get, starting from 1
/// -> any
#let array-at(arr, pos) = { arr.at(calc.min(pos, arr.len()) - 1) }

/// Check if a value is not empty (not none, not an empty string, and not an empty array).
///
/// - c (any): The value to check
/// -> bool
#let is-not-empty(c) = c not in (none, "", [])

/// Simple adjustable depth multi-format numbering, the last format will be reused for deeper levels.
///
/// - formats (array): An array of format strings for different levels, the last one will be reused for deeper levels
/// - depth (int): Maximum depth to apply numbering formats, <= 0 means no limit
/// - supplyment (str): A supplyment string to append after each format
/// - numbers: the capturing numbers passed to the numbering function
/// -> numbering
#let multi-numbering(formats: (), depth: 0, supplyment: "", ..numbers) = {
  let fmt-len = formats.len()
  let num-len = numbers.pos().len()

  if fmt-len == 0 or (num-len > depth and depth > 0) { return }

  numbering(formats.at(calc.min(fmt-len, num-len) - 1) + supplyment, ..numbers)
}

/// Page break for two-sided layout
///
/// - twoside (bool, str): Whether to use two-sided layout
/// - args (arguments): The arguments to pass to the pagebreak function
/// -> none
#let twoside-pagebreak(twoside, ..args) = {
  twoside = if twoside in (true, "true") { "no-content" } else { twoside }

  if twoside in (false, "false") { return pagebreak(weak: true, ..args) }

  set page(header: none) if twoside in ("no-header", "no-content", "blank-only")
  set page(numbering: none) if twoside in ("no-numbering", "no-content", "blank-only")

  if twoside == "blank-only" { [#metadata(none) <__tntt:pagebreak-blank-only>] }

  pagebreak(weak: true, to: { "odd" }, ..args)
}

/// Filter out specified fields from an element's fields and return a new dictionary with the remaining fields.
///
/// - el (any): Element to filter fields from
/// - keys (array): The keys of the fields to filter out
/// -> dictionary
#let filtered-fields(el, keys) = el.fields().pairs().filter(p => p.first() not in keys).to-dict()

/// Show figures with grid kind as subfigures of the figures with image kind, with optional numbering formats.
///
/// - figure-numbering (str, none): The numbering format for figures.
/// - subfig-numbering (str, none): The numbering format for subfigures.
/// - extended (bool): Whether to extend the subfigure numbering with the figure numbering.
/// - subfig-outlined (bool): Whether to outline the subfigures.
/// - doc (content): The document content to be displayed with the grid figures.
/// -> content
#let show-grid-figure(figure-numbering, subfig-numbering, extended, subfig-outlined, doc) = {
  assert(figure-numbering != subfig-numbering, message: "figure-numbering and subfig-numbering must be different")
  set figure(numbering: figure-numbering)
  show figure.where(kind: image): it => (
    if it.numbering == figure-numbering { counter(figure.where(kind: grid)).step() } + it
  )
  show figure.where(kind: grid): it => {
    let grid-counter = it.counter.get()
    counter(figure.where(kind: image)).update(0)
    show figure.where(kind: image): set figure(outlined: subfig-outlined)
    show figure.where(kind: image): set figure(numbering: n => subfig-numbering(..grid-counter, n)) if extended
    show figure.where(kind: image): set figure(numbering: subfig-numbering) if not extended
    let rest = filtered-fields(it, ("body", "caption", "numbering", "kind", "counter", "label"))
    figure(it.body, caption: figure.caption(it.caption), numbering: none, kind: "__tntt:resolved-grid", ..rest)
    counter(figure.where(kind: image)).update(grid-counter)
  }
  doc
}

/// Apply compatibility rewrite for refs.
///
/// * Author: An-314
/// * Modified by: chillcicada
///
/// - prefixes (array): An array of prefixes to strip from the ref targets, such as "fig:", "tbl:", etc.
/// - doc (content): The document content to be displayed with the rewritten refs.
/// -> content
#let show-latexref(prefixes, doc) = {
  show ref: it => {
    if it.element != none { return it }
    let target = str(it.target)
    let stripped = for p in prefixes { if target.starts-with(p) { target.slice(p.len()) + break } }
    if stripped == none { return it }
    ref(label(stripped), ..filtered-fields(it, ("target", "element", "citation")))
  }
  doc
}
