#import "par-data.typ": *

/// Internal label for vertical block markers.
#let v-block-label = label("__cdl_v_block_flag__")

/// Internal label for `parize` block markers (used for `parize-block`, `parize-par-above-flag`, `parize-par-below-flag).
#let parize-block-label = label("__cdl_parize_block_flag__")

/// If you do not want certain elements to be processed by `par-indent`, you can use this label to mark them.
#let prevent-recursion-label = label("__cdl_parize_prevent-label__")

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

/// layout constructor
#let func-layout = [#layout(_ => none)].func()

/// Elements that can be block‑level via a `block: true` attribute.
#let block-attributes-elem = (
  math.equation,
  raw,
  quote,
)

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
    // func-layout, // basic elem
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
    + block-attributes-elem
    + if sys.version >= version(0, 14, 0) { (title,) }
)

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
      debug-body,
    )#v-block-label]
}


/// State variable to track nested usage of `par-indent`.
#let nested-state = state("__cdl_nested_state__", false)

/// Tuple of all native block‑level elements (exclude `block`) recognized by Typst.
#let block-level-elem = (
  (
    //
    figure,
    heading,
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
    enum,
    list,
    terms,
  )
    + block-attributes-elem
    + if sys.version >= version(0, 14, 0) { (title,) }
)

/// Selector for block-level elements (exclude `block`)
#let block-level-sel = block-level-elem.map(e => if e in block-attributes-elem { e.where(block: true) } else if e
  == figure {
  e.where(placement: none)
} else {
  selector(e)
})

/// Selector for all block-level elements (exclude `block`)
#let all-block-level-sel = block-level-sel.fold(selector, (acc, sel) => { acc.or(sel) })



/// Verify the arguments
#let verify-args(exclude-elem, include-elem, use-par-leading) = {
  assert(
    type(exclude-elem) == array,
    message: "The type of `exclude-elem` should be an array; but find: " + str(type(exclude-elem)) + ".",
  )
  assert(
    type(include-elem) == array,
    message: "The type of `include-elem` should be an array; but find: " + str(type(include-elem)) + ".",
  )

  let assert-elem(elems, supported-elems) = if type(elems) == array {
    let unsuppted-elem = none
    let result = for e in elems {
      if e not in supported-elems {
        unsuppted-elem = e
        false
        break
      }
    }
    (result == none, unsuppted-elem)
  } else {
    panic("Expected an array; but find: " + str(type(elems)) + ".")
  }

  let _exclude-elem = ()
  let _include-elem = ()
  if include-elem != () {
    assert(
      exclude-elem == (),
      message: "The value of `exclude-elem` should be `()` when `include-elem` is not an empty array.",
    )
    _include-elem = include-elem.map(e => if e == layout {
      func-layout
    } else { e })
    let (is-legal, illegal-e) = assert-elem(_include-elem, block-level-elem + (block,))
    assert(is-legal, message: "The value of `include-elem` contains an unsupported element: " + repr(illegal-e) + ".")
  } else {
    _exclude-elem = exclude-elem.map(e => if e == layout {
      func-layout
    } else { e })
    let (is-legal, illegal-e) = assert-elem(_exclude-elem, block-level-elem + (block,))
    assert(is-legal, message: "The value of `exclude-elem` contains an unsupported element: " + repr(illegal-e) + ".")
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

    if apply-elem == "all" {
      assert(
        block-block-leading == () and text-block-leading == () and block-text-leading == (),
        message: "When `apply-elem` is \"all\", `block-block-leading`, `text-block-leading` or `block-text-leading` should be an empty array.",
      )
      apply-elem = leading-elem
      block-block-leading = ()
      text-block-leading = ()
      block-text-leading = ()
    } else {
      if block-block-leading == "all" {
        block-block-leading = leading-elem
      }
      if text-block-leading == "all" {
        text-block-leading = leading-elem
      }
      if block-text-leading == "all" {
        block-text-leading = leading-elem
      }

      assert(
        type(apply-elem) == array,
        message: "The type of `apply-elem` should be an array; but find: " + str(type(apply-elem)) + ".",
      )

      assert(
        type(block-block-leading) == array,
        message: "The type of `block-block-leading` should be an array; but find: "
          + str(type(block-block-leading))
          + ".",
      )
      assert(
        type(text-block-leading) == array,
        message: "The type of `text-block-leading` should be an array; but find: "
          + str(type(text-block-leading))
          + ".",
      )
      assert(
        type(block-text-leading) == array,
        message: "The value of `block-text-leading` should be an array; but find: "
          + str(repr(block-text-leading))
          + ".",
      )


      // block-text-leading.map(e => if e == layout {
      //   func-layout
      // } else { e })
      // block-block-leading.map(e => if e == layout {
      //   func-layout
      // } else { e })
      // text-block-leading.map(e => if e == layout {
      //   func-layout
      // } else { e })
      // apply-elem.map(e => if e == layout {
      //   func-layout
      // } else { e })
      for (elems, name) in (
        (block-text-leading, "block-text-leading"),
        (block-block-leading, "block-block-leading"),
        (text-block-leading, "text-block-leading"),
        (apply-elem, "apply-elem"),
      ) {
        let (is-legal, illegal-e) = assert-elem(elems, leading-elem)
        assert(
          is-legal,
          message: if illegal-e == auto {
            "The value of " + repr(name) + " should be an array or a string \"all\"; but find: " + repr(elems) + "."
          } else {
            (
              "Find unpported element in "
                + repr(name)
                + ": "
                + repr(illegal-e)
                + "."
                + "\nHint: Wrap them in `parize-block`, and add `block` to "
                + repr(name)
                + "."
            )
          },
        )
      }
      assert(
        parse-par-leading == (:),
        message: "The key value should be: `block-text-leading`, `block-block-leading`, `text-block-leading`, and `apply-elem`; but find: "
          + parse-par-leading.keys().join(", ", last: " and ")
          + ".",
      )
    }
  } else {
    assert(
      type(use-par-leading) == bool,
      message: "The value of `use-par-leading` should be a `bool` or a `dictionary`; but find: "
        + repr(use-par-leading)
        + ".",
    )

    if use-par-leading == true {
      block-text-leading = (list, enum, terms)
    }
  }


  return (
    exclude-elem: _exclude-elem,
    include-elem: _include-elem,
    block-block-elem: block-block-leading,
    text-block-elem: text-block-leading,
    block-text-elem: block-text-leading,
    apply-elem: apply-elem,
  )
}


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
///       - `figure`
///       - `list`, `enum`, `terms`
///       - `heading`, `title`, `outline`, `repeat`
///       - `table`, `columns`
///       - `move`, `rotate`, `scale`, `skew`
///       - `circle`, `ellipse`, `rect`, `square`
///       - `curve`, `image`, `line`, `polygon`
///       - `math.equation`, `raw`, `quote`
///       - `block` (for `parize`'s `parize-block`)
///       - Note that: `block`, `pad`, `grid`, `stack` and `layout` are not supported directly; wrap them in `parize-block`.
///     - `"all"`: applies to all block-level elements listed above
/// -> content: The processed document content.
#let par-indent(doc, exclude-elem: (), include-elem: (), use-par-leading: false) = {
  context {
    if nested-state.get() {
      panic("This method cannot be used in a nested manner.")
    }
  }

  let (exclude-elem, include-elem, block-block-elem, text-block-elem, block-text-elem, apply-elem) = verify-args(
    exclude-elem,
    include-elem,
    use-par-leading,
  )

  let text-block-leading(e) = (
    apply-elem.contains(e) or text-block-elem.contains(e) // or e in (list, enum, terms) native behavior
  )
  let block-block-leading(e) = (
    apply-elem.contains(e) or block-block-elem.contains(e)
  )
  let block-text-leading(e) = (
    apply-elem.contains(e) or block-text-elem.contains(e)
  )

  let verify-parred-elem(e) = if include-elem == () {
    not e in exclude-elem
  } else {
    e in include-elem
  }

  let is-par-type-block(par-type) = (
    par-type in (ParType.block-all, ParType.block-leading, ParType.block-none, ParType.block-indent)
  )

  let none-par-type = (par-type: ParType.native)

  show parbreak: it => {
    it
    par-type-state.update(update-parbreak)
  }

  show block: it => {
    if it.body == auto or it.has("label") and it.label in (v-block-label, prevent-recursion-label) {
      return it
    }
    let is-parize-block = it.has("label") and it.label == parize-block-label
    par-type-state.update(update-dic(dic: none-par-type))

    // paragraph spacing
    if is-parize-block and it.above == auto {
      let is-text-block-leading = text-block-leading(block)
      let is-block-block-leading = block-block-leading(block)
      if is-text-block-leading or is-block-block-leading {
        let (par-type, ..leading-args) = par-type-state.get().data
        if is-text-block-leading {
          if par-type == ParType.default {
            v-block(above: par.leading)
          }
        }
        if is-block-block-leading {
          if is-par-type-block(par-type) {
            let is-tight-list = leading-args.at("tight", default: none) in (none, true)
            if leading-args.at("below", default: none) == auto and is-tight-list {
              v-block(above: par.leading)
            }
          }
        }
      }
    }

    it

    let is-parred-elem = verify-parred-elem(block)

    if is-parize-block and block-text-leading(block) {
      if is-parred-elem {
        par-type-state.update(update-dic(dic: (par-type: ParType.block-all, below: it.below)))
      } else {
        par-type-state.update(update-dic(dic: (par-type: ParType.block-leading, below: it.below)))
      }
    } else {
      if is-parred-elem {
        par-type-state.update(update-dic(dic: (par-type: ParType.block-indent, below: it.below)))
      } else {
        // should need? users may override the element
        par-type-state.update(update-dic(dic: (par-type: ParType.block-none, below: it.below)))
      }
    }
  }

  show selector(list.item).or(enum.item).or(terms.item): it => {
    it
    par-type-state.update(update-item-count)
  }

  show all-block-level-sel: it => {
    if it.has("label") and it.label == prevent-recursion-label {
      return it
    }

    let e = it.func()

    let is-list = e in (list, enum, terms)

    let tight = if is-list {
      if it.tight {
        (tight: it.tight)
      } else {
        (tight: it.tight, count: it.children.len())
      }
    } else {
      (:)
    }

    // paragraph spacing
    context if block.above == auto and (if is-list { it.tight } else { true }) {
      let is-text-block-leading = text-block-leading(e)
      let is-block-block-leading = block-block-leading(e)
      if is-text-block-leading or is-block-block-leading {
        let (par-type, ..leading-args) = par-type-state.get().data
        if is-text-block-leading {
          if par-type == ParType.default {
            v-block(above: par.leading)
          }
        }
        if is-block-block-leading {
          if is-par-type-block(par-type) {
            let is-tight-list = leading-args.at("tight", default: none) in (none, true)
            if leading-args.at("below", default: none) == auto and is-tight-list {
              v-block(above: par.leading)
            }
          }
        }
      }
    }

    if e == figure and it.placement != none {
      par-type-state.update(update-dic(backup: true))
      it
      par-type-state.update(update-dic(backup: auto))
    } else {
      par-type-state.update(update-dic(dic: none-par-type))

      it

      let is-parred-elem = verify-parred-elem(e)
      if block-text-leading(e) {
        if is-parred-elem {
          par-type-state.update(update-dic(dic: (par-type: ParType.block-all, below: block.below) + tight))
        } else {
          par-type-state.update(update-dic(dic: (par-type: ParType.block-leading, below: block.below) + tight))
        }
      } else {
        if is-parred-elem {
          par-type-state.update(update-dic(dic: (par-type: ParType.block-indent, below: block.below) + tight))
        } else {
          // should need? users may override the element
          par-type-state.update(update-dic(dic: (par-type: ParType.block-none, below: block.below) + tight))
        }
      }
    }
  }

  show place: it => {
    par-type-state.update(update-dic(backup: true))
    it
    par-type-state.update(update-dic(backup: auto))
  }

  show par: it => {
    let (amount, all) = it.first-line-indent
    let (par-type, ..leading-args) = par-type-state.get().data

    // paragraph spacing
    let is-block-text-leading = par-type in (ParType.block-all, ParType.block-leading)
    if is-block-text-leading {
      let is-below-auto = leading-args.at("below", default: none) == auto
      let is-tight-list = leading-args.at("tight", default: none) in (none, true)
      if is-below-auto and is-tight-list {
        v-block(below: par.leading)
      }
    }

    // paragraph indentation
    if all {
      if par-type in (ParType.block-all, ParType.block-indent) {
        show pad: set block(
          spacing: auto,
          stroke: none,
          fill: none,
          inset: 0pt,
          outset: 0pt,
          breakable: true,
          height: auto,
          width: auto,
          radius: 0pt,
        )
        let hanging = if text.dir == rtl { (right: it.hanging-indent) } else { (left: it.hanging-indent) }
        let fields = it.fields()
        let body = fields.remove("body")
        set par(..fields)
        // set text(fill: blue) // debug
        [#pad(rest: 0pt, [#h(-it.hanging-indent)#body], ..hanging)#prevent-recursion-label]
      } else {
        it
      }
    } else {
      if par-type in (ParType.parbreak-indented, ParType.non-tight-list-parbreak) {
        let fields = it.fields()
        let body = fields.remove("body")
        // set text(fill: red) // debug
        par(..fields, first-line-indent: (amount: amount, all: true))[#body]
      } else {
        it
      }
    }

    par-type-state.update(update-dic(dic: (par-type: ParType.default)))
  }
  nested-state.update(true)
  doc
  nested-state.update(false)
  par-type-state.update(update-dic(dic: (par-type: ParType.native)))
}
