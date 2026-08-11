/// Internal metadata for parbreak tracking.
#let meta-flag = "__cdl_meta_flag__"

/// Internal label for vertical block markers.
#let v-block-label = label("__cdl_v_block_flag__")

/// Internal label for `parize` block markers (used for `parize-block`, `parize-par-above-flag`, `parize-par-below-flag).
#let parize-block-label = label("__cdl_parize_block_flag__")

/// Internal metadata flag for parent paragraph indentation tracking.
#let parent-par-flag = "__cdl-parent_par_flag__"

/// Internal metadata flag for paragraph indentation tracking.
#let par-flag = "__cdl_par_flag__"

/// for prevent recursion.
#let prevent-recursion-flag = "__cdl_prevent-label__"

/// If `context` content is inline-level and appears at a paragraph start, precede it with `#parize-blank`. Typically used as
/// ```typst
/// #block(lorem(2))
/// #parize-blank #context [#text.size]
/// ```
#let parize-blank = h(0pt, weak: true)

/// A marker placed below a paragraph to signal that the following block should be
/// spaced with `par.leading` (no empty line between them).
#let parize-par-below-flag = [#block(below: auto, above: 0pt, width: 0pt, height: 0pt, none)#parize-block-label]

/// A marker placed above a paragraph to signal that the preceding block should be
/// spaced with `par.leading` (no empty line between them).
#let parize-par-above-flag = [#block(below: 0pt, above: auto, width: 0pt, height: 0pt, none)#parize-block-label]

/// Wraps content in a block that is recognized by the `parize` system (for `Paragraph Spacing`). `block`, `pad`, `grid`, `stack` are not supported for `Paragraph Spacing` feature; if yout want, then wrap them in `parize-block`; in addition, add `block` to `apply-elem` (or `block-text-leading`, `block-block-leading` and `text-block-leading`) to enable `Paragraph Spacing` for `parize-block`. Example:
/// ```typst
/// #show: par-indent.with(use-par-leading: (apply-elem: (block, /*other block-level elements*/)))
/// #let pad-wrapper = pad(y: 1em, lorem(2))
/// #lorem(2)
/// #parize-block(width: 100%, [#pad-wrapper])
/// #parize-block(width: 100%, [#pad-wrapper])
/// #lorem(2)
/// ```
/// - body (content): The content to wrap.
/// - ..block-args (any): Additional arguments passed to the underlying `block`.
///
/// -> content
#let parize-block(body, ..block-args) = {
  [#block(..block-args, body)#parize-block-label]
}




/// Get the label of an element if it exists.
///
/// -> label, none
#let get-elem-label(e) = {
  return if e.has("label") { e.label } else { none }
}

/// Rebuild a label for an element.
///
/// -> content
#let rebuild-label(elem, _label) = {
  if _label == none {
    return elem
  } else {
    [#elem#_label]
  }
}

/// sequence constructor
#let func-seq = [].func()

/// counter.update
#let func-counter-update = [#counter("_cdl").update(0)].func()

/// state.update
#let func-state-update = [#state("_cdl").update(none)].func()

/// context constructor
#let func-context = [#context none].func()

/// styled text constructor
#let func-styled = [#text(fill: red, [])].func()

/// layout constructor
#let func-layout = [#layout(_ => none)].func()

/// place.flush
#let func-flush = place.flush().func()

/// Tuple of built‑in text‑style functions (e.g., `highlight`, `strong`).
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

/// Tuple of list‑like elements.
#let item-func = (
  list,
  enum,
  terms,
  enum.item,
  list.item,
  terms.item,
)

/// Tuple of all native block‑level elements recognized by Typst.
///
/// Excludes `block` itself (handled separately) and `v` (vertical spacing).
/// If Typst ≥ 0.14, `title` is also included.
#let block-level-elem = (
  (
    //
    figure,
    heading,
    par,
    //
    table,
    grid,
    //
    // block, //
    //
    align,
    columns,
    func-layout,
    // v,
    //
    move,
    pad,
    // place,
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
    line,
    polygon,
    //
    enum.item,
    list.item,
    terms.item,
    enum,
    list,
    terms,
  )
    + if sys.version >= version(0, 14, 0) { (title,) }
)

/// Elements that can be block‑level via a `block: true` attribute.
#let block-attributes-elem = (
  math.equation,
  raw,
  quote,
)

/// Elements that start a new paragraph in Typst’s native model.
#let no-new-par-elem = (align, par)

/// Block‑level elements that are eligible for `par.leading` spacing.
///
/// Basic elements (`grid`, `stack`, `pad`) are excluded; `block` is only
/// considered when it carries the `parize‑block`.
/// If Typst ≥ 0.14, `title` is also included.
#let leading-elem = (
  (
    //
    figure,
    //
    heading,
    //
    table,
    //
    // grid, // basic elem
    // stack,  // basic elem
    //
    block, // only for parize-block
    //
    columns,
    func-layout,
    //
    move,
    // pad, // basic elem
    //
    repeat,
    //
    rotate,
    scale,
    skew,
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
    line,
    polygon,
    //
    list,
    enum,
    terms,
  )
    + if sys.version >= version(0, 14, 0) { (title,) }
)

/// Shorthand to obtain the constructor function of an element.
#let func(elem) = elem.func()

/// Determines whether an element is a vertical‑block marker.
#let is-par-block(elem) = {
  get-elem-label(elem) == v-block-label
}

/// Determines whether an element is a `parize-block`.
#let is-parize-block(elem) = {
  get-elem-label(elem) == parize-block-label //and func(elem) == block
}

/// Determines whether an element is a blank.
#let is-blank(elem) = {
  let e = func(elem)
  return (
    elem in ([], [ ])
      or e in (func-counter-update, func-state-update, func-flush, v, metadata)
      or is-par-block(elem)
      or (e == block and { if elem.has("body") { elem.body == auto } else { block.body == auto } })
      or (repr(e) == "tag")
  )
}

/// Determines whether an element is a block‑attribute element (`math.equation`, `raw`, `quote`) with its `block` field set to `true`.
#let is-block-attributes-elem(elem) = {
  let e = func(elem)
  let _is-block(f) = if elem.has("block") { elem.block } else { f.block }
  e in block-attributes-elem and _is-block(e)
}

/// Determines whether an element is block-level.
#let is-block(elem) = (
  (func(elem) == block and { if elem.has("body") { elem.body != auto } else { block.body != auto } })
    or func(elem) in block-level-elem
    or is-block-attributes-elem(elem)
)

/// Determines whether an element is `parbreak()`.
#let is-par(elem) = {
  return elem == parbreak()
}

/// Detects whether an element behaves as a block by measuring height change.
///
/// Adds a tiny horizontal glue (0.01 pt) to the element and compares the resulting
/// height with the original. If the height increases, the element likely uses
/// Typst’s block‑level measurement.
#let is-block-using-measure(elem) = {
  return elem != none and measure(box[#elem#h(0.01pt)]).height > measure(box[#elem]).height
}

/// Checks whether a sequence already contains the recursion‑prevention flag.
///
/// Used to avoid infinite loops when processing nested sequences.
#let is-recursion(seq) = {
  if seq.children == () {
    return true
  }
  let last = seq.children.last()
  return (
    last.func() == metadata and last.value == prevent-recursion-flag
  )
}

/// Returns the horizontal glue that should be inserted to achieve (or cancel)
/// paragraph indentation, depending on the current `par.first-line-indent` settings.
#let get-fix-parred(is-parred, is-context: false) = {
  if not is-context {
    context {
      let (unparred, parred) = {
        let indent = par.first-line-indent
        let indent-amount = indent.amount
        if indent.all {
          (h(-indent-amount), none)
        } else {
          (none, h(indent-amount))
        }
      }
      if is-parred { return parred } else { return unparred }
    }
  } else {
    let (unparred, parred) = {
      let indent = par.first-line-indent
      let indent-amount = indent.amount
      if indent.all {
        (h(-indent-amount), none)
      } else {
        (none, h(indent-amount))
      }
    }
    if is-parred { return parred } else { return unparred }
  }
}




/// Applies a processing function to every `sequence` element in the document.
///
/// This is the entry point for the paragraph‑indentation and paragraph‑leading.
///
/// - doc (content): The document to transform.
/// - exclude-elem (array): Block‑level elements to exclude from processing.
/// - include-elem (array): Block‑level elements to include from processing.
/// - process (function): The function that will transform each sequence.
///
/// -> content
#let show-seq(doc, exclude-elem: (), include-elem: (), process: it => it) = {
  show func-seq: seq => {
    if is-recursion(seq) {
      // avoid recursion
      return seq
    } else {
      let (body, ..args) = process(
        seq,
        exclude-elem: exclude-elem,
        include-elem: include-elem,
      )
      return body
    }
  }
  doc
}

/// Type tags used during traversal to classify elements.
#let ElemType = (
  blank: "blank",
  block: "block",
  inline: "inline",
)

/// Scans forward in a child list starting from `index` and returns the type of
/// the next non‑blank element.
///
/// - children (array): The list of child elements.
/// - index (integer): The starting index (0‑based).
/// - only-block (bool): If `true`, only report a block; otherwise
///   report the first non‑blank element (block or inline). Defaults to `false`.
///
/// -> ElemType("blank", "block", "inline")
#let check-next-block-elem(children, index, only-block: false) = {
  // children is an array
  let elem-type = ElemType.blank
  for i in range(index, children.len()) {
    let child = children.at(i)
    if is-par(child) {
      return ElemType.block
    }
    if is-blank(child) {
      continue
    }
    if is-block(child) {
      return ElemType.block
    } else {
      elem-type = ElemType.inline
      if func(child) == func-seq {
        elem-type = check-next-block-elem(child.children, 0)
      } else if func(child) == func-styled {
        if func(child.child) == func-seq {
          // TODO
          elem-type = check-next-block-elem(child.child.children, 0)
        } else {
          // TODO
          elem-type = check-next-block-elem((child.child,), 0)
        }
      } else if func(child) in text-style-func {
        if func(child.body) == func-seq {
          elem-type = check-next-block-elem(child.body.children, 0)
        } else {
          elem-type = check-next-block-elem((child.body,), 0)
        }
      }
      if only-block {
        if elem-type != ElemType.block {
          continue
        } else {
          return elem-type
        }
      } else {
        if elem-type == ElemType.blank {
          continue
        } else {
          return elem-type
        }
      }
    }
  }
  return elem-type
}

/// Looks backward in a list of `ElemType` values and returns the last non‑blank
/// element together with its index.
///
/// - children (array of `ElemType`): The list of type tags.
/// -> (index: integer, elem-type: ElemType)
#let is-next-block(children) = {
  let n = children.len()
  for i in range(n - 1, -1, step: -1) {
    if children.at(i) == ElemType.blank {
      continue
    } else {
      return (index: i, elem-type: children.at(i))
    }
  }
  return (index: 0, elem-type: ElemType.blank)
}

/// Checks whether any of the functions in the given range are block‑using
/// measurement functions (detected via `is‑block‑using‑measure`).
///
/// Used to decide whether a parent styled paragraph may affect indentation.
///
/// - children (array of functions and strings): The list of functions to examine.
/// - start-index (integer): The starting index (inclusive) for the backward search.
/// -> bool
#let is-next-styled-par(children, start-index) = {
  let n = children.len()
  for i in range(n - 1, start-index - 1, step: -1) {
    let f = children.at(i)
    if type(f) == function and is-block-using-measure(f("")) {
      return true
    }
  }
  return false
}




/// Recursively processes a sequence, inserting paragraph‑indentation and spacing
/// markers according to the current `par.first‑line‑indent` settings.
///
/// This is the core transformation that implements the paragraph‑level control.
/// It walks through the sequence’s children, keeps track of block‑level elements,
/// paragraph breaks, and list‑item counters, and inserts the appropriate
/// `metadata` flags and horizontal glues.
///
/// - seq (content): The sequence to process (must be a `func‑seq`).
/// - pre-block (bool): Whether a block‑level element has been seen
///   before the current position. Defaults to `false`.
/// - pre-include-block (bool): Whether the preceding block is included
///   (via `include‑elem` or `exclude‑elem`) for indentation control.
///   Defaults to `false`.
/// - is-par-start (bool): Whether we are at the start of a paragraph
///   (i.e., after a block and before inline content). Defaults to `false`.
/// - is-par-end (bool): Whether we are at the end of a paragraph
///   (i.e., after inline content and before a block or the sequence ends).
///   Defaults to `true`.
/// - exclude-elem (array): Block‑level elements to exclude.
/// - include-elem (array): Block‑level elements to include.
/// - parent-func (array): Stack of parent‑function tags for nested
///   styled‑text detection.
/// - parent-next-block (array): Stack of `ElemType` values from parent
///   contexts.
/// - list-item (3‑tuple): Counters for consecutive `list.item`, `enum.item`, and `terms.item` elements. Defaults to `(0, 0, 0)`.
///
/// -> dictionary
///    (body: content, last-pre-block: bool, last-is-par-start: bool,
///     last-is-par-end: bool, last-list-item: (integer, integer, integer),
///     last-pre-include-block: bool)
#let check-seq(
  seq,
  pre-block: false,
  pre-include-block: false,
  is-par-start: false,
  is-par-end: true,
  exclude-elem: (),
  include-elem: (),
  parent-func: (),
  parent-next-block: (),
  list-item: (0, 0, 0),
) = {
  let pre-block = pre-block
  let pre-include-block = pre-include-block
  let is-par-start = is-par-start
  let is-par-end = is-par-end
  let (first-list, first-enum, first-term) = list-item


  let (_unparred, _parred) = {
    let indent = par.first-line-indent
    let abs-indent = indent.amount.to-absolute()
    if indent.all {
      (h(-abs-indent), none)
    } else {
      (none, h(abs-indent))
    }
  }
  let parent-par-meta = metadata((
    kind: parent-par-flag,
    parred: _parred,
    unparred: _unparred,
  ))
  if func(seq) == func-seq {
    let resolved-seq = ()
    let index = 0
    for child in seq.children {
      index += 1
      if func(child) == func-seq {
        let next-block = check-next-block-elem(seq.children, index)
        let (
          body,
          last-pre-block,
          last-is-par-start,
          last-is-par-end,
          last-list-item,
          last-pre-include-block,
        ) = check-seq(
          child,
          pre-block: pre-block,
          pre-include-block: pre-include-block,
          is-par-start: is-par-start,
          is-par-end: is-par-end,
          exclude-elem: exclude-elem,
          include-elem: include-elem,
          parent-next-block: parent-next-block + (next-block,),
          parent-func: parent-func + ("seq",),
          list-item: (first-list, first-enum, first-term),
        )
        resolved-seq.push(parent-par-meta)
        resolved-seq.push(body)

        pre-block = last-pre-block
        pre-include-block = last-pre-include-block
        is-par-start = last-is-par-start
        is-par-end = last-is-par-end
        (first-list, first-enum, first-term) = last-list-item
        continue
      }
      if func(child) == func-styled {
        let _body = child.child
        let next-block = check-next-block-elem(seq.children, index)
        let (
          body,
          last-pre-block,
          last-is-par-start,
          last-is-par-end,
          last-list-item,
          last-pre-include-block,
        ) = check-seq(
          func-seq((_body,)),
          pre-block: pre-block,
          pre-include-block: pre-include-block,
          is-par-start: is-par-start,
          is-par-end: is-par-end,
          exclude-elem: exclude-elem,
          include-elem: include-elem,
          parent-func: parent-func + (body => func-styled(body, child.styles),),
          parent-next-block: parent-next-block + (next-block,),
          list-item: (first-list, first-enum, first-term),
        )

        pre-block = last-pre-block
        pre-include-block = last-pre-include-block
        is-par-start = last-is-par-start
        is-par-end = last-is-par-end
        (first-list, first-enum, first-term) = last-list-item

        let _label = get-elem-label(child)
        let new-child = rebuild-label(child.func()(body, child.styles), _label)
        resolved-seq.push(parent-par-meta)
        resolved-seq.push(new-child)

        continue
      }
      if func(child) in text-style-func {
        let field = child.fields()
        let _body = field.remove("body")
        let _label = field.remove("label", default: none)
        let next-block = check-next-block-elem(seq.children, index)
        let (
          body,
          last-pre-block,
          last-is-par-start,
          last-is-par-end,
          last-list-item,
          last-pre-include-block,
        ) = check-seq(
          func-seq((_body,)),
          pre-block: pre-block,
          pre-include-block: pre-include-block,
          is-par-start: is-par-start,
          is-par-end: is-par-end,
          exclude-elem: exclude-elem,
          include-elem: include-elem,
          parent-func: parent-func + ("text-style",),
          parent-next-block: parent-next-block + (next-block,),
          list-item: (first-list, first-enum, first-term),
        )

        pre-block = last-pre-block
        pre-include-block = last-pre-include-block
        is-par-start = last-is-par-start
        is-par-end = last-is-par-end
        (first-list, first-enum, first-term) = last-list-item

        let new-child = rebuild-label(child.func()(body, ..field), _label)

        resolved-seq.push(parent-par-meta)
        resolved-seq.push(new-child)

        continue
      }
      if is-blank(child) {
        resolved-seq.push(child)
        continue
      }
      // hide
      if func(child) == hide {
        let _body = child.body
        let _label = get-elem-label(child)
        let next-block = check-next-block-elem(seq.children, index)

        let (
          body,
          last-pre-block,
          last-is-par-start,
          last-is-par-end,
          last-list-item,
          last-pre-include-block,
        ) = check-seq(
          func-seq((_body,)),
          pre-block: pre-block,
          pre-include-block: pre-include-block,
          is-par-start: is-par-start,
          is-par-end: is-par-end,
          exclude-elem: exclude-elem,
          include-elem: include-elem,
          parent-func: parent-func + ("hide",),
          parent-next-block: parent-next-block + (next-block,),
          list-item: (first-list, first-enum, first-term),
        )
        pre-block = last-pre-block
        pre-include-block = last-pre-include-block
        is-par-start = last-is-par-start
        is-par-end = last-is-par-end
        (first-list, first-enum, first-term) = last-list-item
        resolved-seq.push(parent-par-meta)
        resolved-seq.push(rebuild-label(hide(body), _label))
        continue
      }
      // context
      if func(child) == func-context {
        // can not handle
        resolved-seq.push(child)
        pre-block = false
        pre-include-block = false
        is-par-start = false
        is-par-end = false

        (first-list, first-enum, first-term) = (0, 0, 0)
        continue
      }
      if is-block(child) {
        // block
        let child-type = func(child)

        // figure and child.placement != none
        if (
          child-type == figure
            and { if child.has("placement") { child.placement != none } else { figure.placement != none } }
        ) {
          // consider as blank
          resolved-seq.push(child)
          continue
        }


        if child-type == list.item {
          first-list += 1
          first-enum = 0
          first-term = 0
        } else if child-type == enum.item {
          first-list = 0
          first-enum += 1
          first-term = 0
        } else if child-type == terms.item {
          first-list = 0
          first-enum = 0
          first-term += 1
        } else {
          (first-list, first-enum, first-term) = (0, 0, 0)
        }
        if child-type not in no-new-par-elem {
          if not is-par-end {
            if (not child-type in item-func) or first-list == 1 or first-enum == 1 or first-term == 1 {
              resolved-seq.push(metadata((kind: meta-flag, value: "no-par")))
            }
          }
        }
        pre-block = true
        if is-parize-block(child) {
          pre-include-block = true
        } else {
          if include-elem != () {
            if child-type in include-elem and not child-type in no-new-par-elem {
              pre-include-block = true
            } else {
              pre-include-block = false
            }
          } else {
            if child-type in exclude-elem or child-type in no-new-par-elem {
              pre-include-block = false
            } else {
              pre-include-block = true
            }
          }
        }

        is-par-start = false
        is-par-end = false
      } else if is-par(child) {
        if pre-block {
          is-par-start = true
        }
        if not is-par-end {
          is-par-end = true
        }
      } else {
        let curr-next-block = check-next-block-elem(seq.children, index, only-block: true)
        if is-par-start {
          resolved-seq.push(metadata((
            kind: meta-flag,
            value: "par-inline",
          )))
          if pre-include-block {
            let parred = get-fix-parred(true)
            if curr-next-block == ElemType.block {
              resolved-seq.push({
                parred
              })
              // resolved-seq.push([!!])
            } else {
              let _parent-next-block = is-next-block(parent-next-block)
              let parent-next-block-index = _parent-next-block.index
              let is-parent-next-block = _parent-next-block.elem-type
              if is-parent-next-block != ElemType.inline {
                resolved-seq.push({
                  parred
                })
                // resolved-seq.push([!|])
              } else {
                resolved-seq.push({
                  // check the parent function
                  context if is-next-styled-par(parent-func, parent-next-block-index) {
                    parred
                    // [!?]
                  } else {
                    metadata((kind: par-flag, is-parred: true))
                    // [!\*]
                  }
                })
              }
            }
          }
        } else {
          resolved-seq.push(metadata((
            kind: meta-flag,
            value: "no-par-inline",
          )))
          if pre-include-block {
            let unparred = get-fix-parred(false)
            if curr-next-block == ElemType.block {
              resolved-seq.push({
                unparred
              })
              // resolved-seq.push([||])
            } else {
              let _parent-next-block = is-next-block(parent-next-block)
              let parent-next-block-index = _parent-next-block.index
              let is-parent-next-block = _parent-next-block.elem-type
              if is-parent-next-block != ElemType.inline {
                resolved-seq.push({
                  unparred
                })
                // resolved-seq.push([|?])
              } else {
                resolved-seq.push({
                  // check the parent function
                  context if is-next-styled-par(parent-func, parent-next-block-index) {
                    unparred
                    // [|\#]
                  } else {
                    metadata((kind: par-flag, is-parred: false))
                    // [|\*]
                  }
                })
              }
            }
          }
        }
        pre-block = false
        pre-include-block = false
        is-par-start = false
        is-par-end = false

        (first-list, first-enum, first-term) = (0, 0, 0)
      }
      resolved-seq.push(child)
    }
    let _label = get-elem-label(seq)
    resolved-seq.push(metadata(prevent-recursion-flag))
    return (
      body: rebuild-label(func-seq(resolved-seq), _label),
      last-pre-block: pre-block,
      last-pre-include-block: pre-include-block,
      last-is-par-start: is-par-start,
      last-is-par-end: is-par-end,
      last-list-item: (first-list, first-enum, first-term),
    )
  }
}



/// Pre-process block elements to add metadata flags for spacing detection.
///
/// This function wraps block elements with metadata flags that store their
/// `below` and `above` spacing values, enabling subsequent paragraph spacing calculations.
/// - doc (content): The document content to process
/// -> content: The processed document with metadata flags added to block elements
#let pre-process-block(doc) = {
  show block: it => {
    if it.has("label") and (it.label == v-block-label) {
      return it
    }
    metadata((below: it.below, above: it.above, kind: meta-flag))
    it
    metadata((below: it.below, above: it.above, kind: meta-flag))
  }
  doc
}

/// Pre-process list elements (list, enum, terms) to add metadata flags.
///
/// This function wraps list-like elements with metadata flags that store their
/// `tight` property, enabling subsequent paragraph spacing calculations.
/// - doc (content): The document content to process
/// -> content: The processed document with metadata flags added to list elements
#let pre-process-list(doc) = {
  show selector(list).or(selector(enum)).or(selector(terms)): it => {
    metadata((kind: meta-flag, tight: it.tight))
    it
    metadata((kind: meta-flag, tight: it.tight))
  }
  doc
}

/// Combined pre-processing function that applies both block and lists pre-processing.
///
/// This function sequentially applies `pre-process-block` and `pre-process-list`
/// to prepare document elements for paragraph spacing calculations.
/// - doc (content): The document content to process
/// -> content: The fully pre-processed document
#let pre-process(doc) = {
  show: pre-process-block
  show: pre-process-list
  doc
}

/// Create a vertical spacing block with a special label for detection.
///
/// This function creates an invisible block element with the `v-block-label` that can be
/// used to inject vertical spacing (above/below) into the document flow. The block is
/// zero-sized but affects spacing through its `above` and `below` properties.
/// - below (length): Spacing below the block (default: 0pt)
/// - above (length): Spacing above the block (default: 0pt)
/// - debug-body (content): Optional debug content to display (default: none)
/// -> content: A labeled block element that affects vertical spacing
#let v-block(below: 0pt, above: 0pt, debug-body: none) = {
  return [#block(
      above: above,
      below: below,
      height: 0pt,
      width: 0pt,
      // debug-body,
    )#v-block-label]
}


/// Selector for block elements marked with the parize-block-label.
///
/// This selector identifies block elements that have been processed by the parize system
/// and marked with the `parize-block-label`. These blocks are treated specially in
/// paragraph spacing calculations.
#let sel-parize-block = selector(block.where(label: parize-block-label))

/// Create a selector that matches all block-level elements that affect paragraph leading.
///
/// This function builds a composite selector that includes:
/// - Standard block-level elements from `leading-elem`
/// - Math equations, raw blocks, and quotes with `block: true`
/// - Figure elements with `placement: none`
/// - Block elements labeled with `parize-block-label`
/// -> selector: A selector matching all relevant block-level elements for spacing calculations
#let all-leading-elem-sel = {
  let sel = selector
  sel = sel.or(math.equation.where(block: true)).or(raw.where(block: true)).or(quote.where(block: true))
  for e in leading-elem {
    if e == figure {
      e = e.where(placement: none)
    } else if e == block {
      e = e.where(label: parize-block-label)
    }
    sel = sel.or(e)
  }
  sel
}


/// Apply `par.leading` spacing adjustments to block-level elements.
///
/// This function analyzes document structure and injects vertical spacing blocks
/// (`v-block`) where paragraph leading should be applied. It handles three spacing
/// scenarios: block-to-text, text-to-block, and block-to-block relationships.
///
/// - doc (content): The document content to process
/// - apply-elem (array, "all"): Elements to apply spacing to, or "all" for all elements
/// - block-text-elem (array, "all"): Elements that should have spacing below when followed by text
/// - block-block-elem (array, "all"): Elements that should have spacing above when preceded by another block
/// - text-block-elem (array, "all"): Elements that should have spacing above when preceded by text
/// -> content: The document with paragraph leading spacing adjustments applied
#let fix-par-spacing(
  doc,
  apply-elem: (),
  block-text-elem: (),
  block-block-elem: (),
  text-block-elem: (),
) = {
  if apply-elem == () and block-text-elem == () and text-block-elem == () and block-block-elem == () {
    return doc
  }

  let is-all-elems = false
  let is-below-leading = false
  let is-text-block-leading = false
  let is-block-block-leading = false

  let sel-elem = {
    if apply-elem == "all" {
      is-all-elems = true
      is-below-leading = true
      is-block-block-leading = true
      is-text-block-leading = true
      all-leading-elem-sel
    } else {
      if block-text-elem == "all" {
        block-text-elem = ()
        is-below-leading = true
      }
      if block-block-elem == "all" {
        block-block-elem = ()
        is-block-block-leading = true
      }
      if text-block-elem == "all" {
        text-block-elem = ()
        is-text-block-leading = true
      }

      if is-text-block-leading and is-block-block-leading and is-below-leading {
        all-leading-elem-sel
        is-all-elems = true
      } else {
        if is-below-leading or is-text-block-leading or is-block-block-leading {
          all-leading-elem-sel
        } else {
          let all-elems = block-block-elem + block-text-elem + text-block-elem + apply-elem
          let sel = selector
          for e in all-elems {
            if e in block-attributes-elem {
              e = e.where(block: true)
              sel = sel.or(e)
            } else if e in leading-elem {
              if e == figure {
                e = e.where(placement: none)
              } else if e == block {
                e = sel-parize-block
              }
              sel = sel.or(e)
            }
          }
          sel
        }
      }
    }
  }
  // [#sel-elem]
  show sel-elem: it => {
    let e = it.func()
    // block case
    let _is-above-leading = is-all-elems or (e in apply-elem)
    let _is-text-block-leading = _is-above-leading or is-text-block-leading or e in text-block-elem
    let _is-block-block-leading = _is-above-leading or is-block-block-leading or e in block-block-elem
    let _is-below-leading = _is-above-leading or is-below-leading or e in block-text-elem
    let above-leading = if (_is-text-block-leading or _is-block-block-leading) {
      context if (e != block and block.above == auto) or (e == block and it.above == auto) {
        let first-index = if e == block { -2 } else { -1 }
        let before-sel = selector(metadata).before(here())
        let above-par = query(before-sel).filter(it => (
          type(it.value) == dictionary and it.value.at("kind", default: none) == meta-flag
        ))
        let m2 = above-par.at(first-index, default: none)
        if m2 != none {
          // block par
          // block block
          if m2.value.at("value", default: none) == "no-par" {
            let m3 = above-par.at(first-index - 1, default: none)
            if (
              m3 == none
                or (
                  _is-text-block-leading and m3.value.at("value", default: none) in ("no-par-inline", "par-inline")
                )
                or _is-block-block-leading and m3.value.at("below", default: none) == auto
            ) {
              // v-block(above: par.leading, below: 0pt, debug-body: place(dx: -1em)[#text(fill: red)[?]])
              v-block(above: par.leading, below: 0pt)
            } else if m3.value.at("tight", default: none) == true {
              // block list
              let m4 = above-par.at(first-index - 2, default: none)
              if (
                m4 != none
                  and (is-block-block-leading or e in block-block-elem)
                  and m4.value.at("below", default: none) == auto
              ) {
                // v-block(above: par.leading, below: 0pt, debug-body: place(dx: -1em)[#text(fill: red)[??]])
                v-block(above: par.leading, below: 0pt)
              }
            }
          } else if m2.value.at("tight", default: none) == true {
            // list par
            // list block
            let m3 = above-par.at(first-index - 1, default: none)
            if m3 != none and m3.value.at("value", default: none) == "no-par" {
              let m4 = above-par.at(first-index - 2, default: none)
              if (
                m4 == none
                  or (
                    (is-text-block-leading or e in text-block-elem)
                      and m4.value.at("value", default: none) in ("no-par-inline", "par-inline")
                  )
                  or (is-block-block-leading or e in block-block-elem) and m4.value.at("below", default: none) == auto
              ) {
                // v-block(above: par.leading, below: 0pt, debug-body: place(dx: -1em)[#text(fill: red)[?|]])
                v-block(above: par.leading, below: 0pt)
              } else if m4.value.at("tight", default: none) == true {
                // list list
                let m5 = above-par.at(first-index - 3, default: none)
                if (
                  m5 != none
                    and (is-block-block-leading or e in block-block-elem)
                    and m5.value.at("below", default: none) == auto
                ) {
                  // v-block(above: par.leading, below: 0pt, debug-body: place(dx: -1em)[#text(fill: red)[?!]])
                  v-block(above: par.leading, below: 0pt)
                }
              }
            }
          }
        }
      }
    }
    // inline case
    let below-leading = if _is-below-leading {
      context if (e != block and block.below == auto) or (e == block and it.below == auto) {
        // (e != block and block.below == auto) or (e == block and e.below == auto)
        let first-index = if e == block { 1 } else { 0 }
        let after-sel = selector(metadata).after(here())
        let below-par = query(after-sel).filter(it => (
          type(it.value) == dictionary and it.value.at("kind", default: none) == meta-flag
        ))
        let m1 = below-par.at(first-index, default: none)
        if m1 != none {
          if m1.value.at("value", default: none) == "no-par-inline" {
            // block par
            // v-block(below: par.leading, debug-body: place(dx: -1em)[#text(
            //   fill: green,
            // )[!#e]])
            v-block(below: par.leading)
          } else if m1.value.at("tight", default: none) == true {
            // list par
            let m2 = below-par.at(first-index + 1, default: none)
            if m2 == none or m2.value.at("value", default: none) == "no-par-inline" {
              // v-block(below: par.leading, debug-body: place(dx: -1em)[#text(
              //   fill: green,
              // )[!!]])
              v-block(below: par.leading)
            }
          }
        }
      }
    }
    if above-leading != none { [#above-leading#v-block-label] }
    it
    if below-leading != none { [#below-leading#v-block-label] }
  }
  doc
}


/// State variable to track nested usage of par-indent functions.
///
/// This state variable prevents recursive application of paragraph indentation
/// functions, which could cause infinite loops. When set to `true`, it indicates
/// that a par-indent operation is already in progress.
#let nested-state = state("__cdl_nested_state__", false)


/// The `parize` package provides an experimental feature that allows any block-level element in Typst (except `par` and `align`) to be treated as part of a paragraph.
///
/// This method is the primary entry point of the `parize` package. It processes a document
/// to enable paragraph‑level control over block‑element indentation and, optionally,
/// paragraph‑leading spacing between block elements and paragraphs.
///
/// - doc (content): The document content to process.
/// - exclude-elem (array): Block‑level elements to **exclude** from processing (default: `()`).
/// - include-elem (array): Block‑level elements to **include** for processing (default: `()`). If `include-elem` is not empty, `exclude-elem` is ignored.
/// - use-par-leading (dictionary, bool): Controls whether `par.leading` is used for paragraph spacing.
///   - `false` (default): No `par‑leading` spacing is applied.
///   - `true`: Equivalent to `use-par-leading: (block-text-leading: (list, enum, terms))`.
///   - dictionary with the following keys:
///     - `block-text-leading` (array, "all"): specifies which block-level elements to process when there's no empty line between them and the following paragraph
///     - `text-block-leading` (array, "all"): specifies which block-level elements to process when there's no empty line between them and the preceding paragraph
///     - `block-block-leading` (array, "all"): specifies which block-level elements to process when there's no empty line between them and **above** block-level elements (excluding `par`, `align`, `v`)
///     - `apply-elem` (array, "all"): Specifies which block-level elements to process, affecting `block-text-leading`, `text-block-leading`, and `block-block-leading`.
///    - Values for these keys can be:
///     - `array` whose elements are the following block-level elements:
///       - `figure`, `layout`
///       - `list`, `enum`, `terms`
///       - `heading`, `title`, `outline`, `repeat`
///       - `table`, `columns`
///       - `move`, `rotate`, `scale`, `skew`
///       - `circle`, `ellipse`, `rect`, `square`
///       - `curve`, `image`, `line`, `polygon`
///       - `math.equation`, `raw`, `quote`
///       - `block` (for `parize`'s `parize-block`)
///       - Note that: `block`, `pad`, `grid`, `stack` are not supported directly; wrap them in `parize-block`.
///     - `"all"`: applies to all block-level elements listed above
/// -> content: The processed document content.
#let par-indent(doc, exclude-elem: (), include-elem: (), use-par-leading: false) = {
  context {
    if nested-state.get() {
      panic("This method cannot be used in a nested manner.")
    }
  }

  show metadata: it => {
    if type(it.value) == dictionary and it.value.at("kind", default: none) == par-flag {
      context {
        let before-sel = selector(metadata).before(here())
        let above-parent-par = query(before-sel).filter(it => (
          type(it.value) == dictionary and it.value.at("kind", default: none) == parent-par-flag
        ))
        let (unparred, parred) = above-parent-par.at(-1).value
        if it.value.is-parred {
          parred
        } else {
          unparred
        }
      }
    } else {
      it
    }
  }


  let block-text-leading = ()
  let text-block-leading = ()
  let block-block-leading = ()
  let apply-elem = ()

  if type(use-par-leading) == dictionary {
    let parse-par-leading = use-par-leading
    block-text-leading = parse-par-leading.remove("block-text-leading", default: ())
    block-block-leading = parse-par-leading.remove("block-block-leading", default: ())
    text-block-leading = parse-par-leading.remove("text-block-leading", default: ())
    apply-elem = parse-par-leading.remove("apply-elem", default: ())
    let assert-elem(elems) = if type(elems) == array {
      let unsuppted-elem = none
      let result = for e in elems {
        if e not in leading-elem + (math.equation, raw, quote) {
          unsuppted-elem = e
          false
          break
        }
      }
      (result == none, unsuppted-elem)
    } else {
      (elems == "all", auto)
    }
    for (elems, name) in (
      (block-text-leading, "block-text-leading"),
      (block-block-leading, "block-block-leading"),
      (text-block-leading, "text-block-leading"),
      (apply-elem, "apply-elem"),
    ) {
      let (is-legal, illegal-e) = assert-elem(elems)
      assert(
        is-legal,
        message: if illegal-e == auto {
          "The value of " + repr(name) + " should be an array or a string \"all\"; but find: " + repr(elems) + "."
        } else {
          "Find unpported block-level element in " + repr(name) + ": " + repr(illegal-e) + "."
        },
      )
    }
    assert(
      parse-par-leading == (:),
      message: "
          The key value should be: `block-text-leading`, `block-block-leading`, `text-block-leading`, and `apply-elem`; but find: "
        + parse-par-leading.keys().join(", ", last: " and ")
        + ".",
    )
  } else {
    assert(
      type(use-par-leading) == bool,
      message: "The value of `use-par-leading` should be a `bool` or a `dictionary`; but find: "
        + repr(use-par-leading)
        + ".",
    )
  }

  let _exclude-elem
  let _include-elem
  if include-elem != () {
    _exclude-elem = ()
    _include-elem = include-elem.map(e => if e in (list, enum, terms) { e.item } else if e == layout {
      func-layout
    } else { e })
  } else {
    _include-elem = ()
    _exclude-elem = exclude-elem.map(e => if e in (list, enum, terms) { e.item } else if e == layout {
      func-layout
    } else {
      e
    })
  }
  if use-par-leading != false {
    nested-state.update(true)
    if use-par-leading == true {
      block-text-leading = (list, enum, terms)
    }
    show: fix-par-spacing.with(
      block-block-elem: block-block-leading,
      text-block-elem: text-block-leading,
      block-text-elem: block-text-leading,
      apply-elem: apply-elem,
    )
    show: pre-process
    {
      show: show-seq.with(process: check-seq, exclude-elem: _exclude-elem, include-elem: _include-elem)
      doc
    }
    nested-state.update(false)
  } else {
    nested-state.update(true)
    {
      show: show-seq.with(process: check-seq, exclude-elem: _exclude-elem, include-elem: _include-elem)
      doc
    }
    nested-state.update(false)
  }
}


// Debug
// #show metadata: it => if type(it.value) == dictionary and it.value.at("kind", default: none) == "__cdl_meta_flag__" {
//   [#block(stroke: blue, repr(it))#label("__cdl_v_block_flag__")]
// } else { it }
