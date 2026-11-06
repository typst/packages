
#import "../util/func-type.typ": *
#import "../util/identifier.typ": *
#import "../util/level-state.typ": *
#import "../util/basic-tool.typ": *

/// Default arguments for grid layout
///
/// Properties:
///   - align: auto
///   - column-gutter: ()
///   - fill: none
///   - gutter: ()
///   - inset: (:)
///   - row-gutter: ()
///   - rows: ()
///   - stroke: (:)
///
/// Returns:
///   A dictionary of default grid arguments
#let default-grid-args = (
  align: auto,
  column-gutter: (),
  fill: none,
  gutter: (),
  inset: (:),
  row-gutter: (),
  rows: (),
  stroke: (:),
)



/// Creates a two-column grid with optional auto-margin
///
/// Parameters:
///   - number: The content for the first column
///   - body: The content for the second column
///   - auto-margin (bool): Whether to use auto margin (default: true)
///   - ..args: Additional grid arguments
///
/// Returns:
///   A grid layout with two columns
#let grid2(number, body, auto-margin: true, ..args) = grid(
  ..default-grid-args,
  columns: (auto, if auto-margin { auto } else { 1fr }),
  ..args,
  [#number], [#body],
)

/// Helper function to get the left inset value from a dictionary or length
///
/// Parameters:
///   - inset: The inset value (can be length, relative, ratio, or dictionary)
///
/// Returns:
///   The resolved left inset value
#let _get_left_inset(inset) = {
  let left-inset = 0pt
  if type(inset) in (length, relative, ratio) {
    //(length, relative, ratio)
    left-inset = inset
  } else if type(inset) == dictionary {
    // dictionary (not none)
    let left = inset.at("left", default: none)
    if left == none {
      left = inset.at("x", default: none)
      if left == none {
        left = inset.at("rest", default: none)
        if left == none {
          left = 0pt
        }
        left-inset = left
      } else {
        left-inset = left
      }
    } else {
      left-inset = left
    }
  }
  return left-inset
}

// 元素类型: blank, block-level, inline-level, unknown (styled, text-styled, seq)


/// Horizontal inset context for parent item inset
///
/// Behavior:
///   - Updates parent-item-inset and returns a horizontal space
///
/// Returns:
///   A horizontal space with the current parent item inset
#let h-inset = context {
  parent-item-inset.update(())
  let p-inset = parent-item-inset.get().sum(default: 0pt)
  h(p-inset, weak: true)
}
/// Negative horizontal inset context for parent item inset
///
/// Behavior:
///   - Returns a negative horizontal space based on parent item inset
///
/// Returns:
///   A negative horizontal space with the current parent item inset
#let h-inset-m = context {
  let p-inset = parent-item-inset.get().sum(default: 0pt)
  h(-p-inset)
}

/// Converts an inset length to absolute units based on text size
///
/// Parameters:
///   - text-size: The font size to use for conversion
///   - inset: The inset value to convert
///
/// Returns:
///   The absolute length in points
#let get_abs-len(text-size, inset) = {
  if inset == 0pt or inset == 0% + 0pt {
    return 0pt
  }
  if text-size == 1em {
    return inset
  }
  return measure(show-text(text-size, box(width: inset)[])).width.to-absolute()
}



// for pad, par, block
/// General block-level element rebuilder with inset handling
///
/// Parameters:
///   - e: The element to rebuild
///   - number: The number/content for the first column
///   - left-inset: Left inset value (default: 0pt)
///   - right-inset: Right inset value (default: 0pt)
///   - inset: Total inset value (default: 0pt)
///   - elem-func: The function to apply to the body
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_general-block-level-elem(
  e,
  number,
  left-inset: 0pt,
  right-inset: 0pt,
  inset: 0pt,
  // text-size: (:),
  elem-func,
) = {
  let field = e.fields()

  let _label = field.remove("label", default: none)
  let _body = field.remove("body")
  let _nbody = elem-func(_body, number)

  // TODO 处理格式化问题，让其不影响number

  if _nbody.inline == true {
    return (
      body: {
        let new-body = if e.func() == par {
          if e.has("first-line-indent") {
            [#h(-left-inset - right-inset)#h-inset-m#number#h-inset#_nbody.body]
          } else {
            [#fix-first-line#h-inset-m#number#h-inset#_nbody.body]
          }
        } else {
          [

            #fix-first-line#h(-left-inset)#h-inset-m#number#h(right-inset)#h-inset#_nbody.body
          ]
        }
        rebuild-label(e.func()(new-body, ..field), _label)
      },
      inline: false,
    )
  } else {
    return (
      body: {
        parent-item-inset.update(push(inset))
        rebuild-label(e.func()(_nbody.body, ..field), _label)
      },
      inline: _nbody.inline,
    )
  }
}


/// Rebuilds a pad element with inset handling
///
/// Parameters:
///   - e: The pad element
///   - number: The number/content for the first column
///   - elem-func: The function to apply to the body
///   - text-size: Optional text size for conversion
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_pad-elem(e, number, elem-func, text-size: (:)) = {
  let inset = if e.has("left") {
    e.left
  } else if e.has("x") {
    e.x
  } else if e.has("rest") {
    e.rest
  } else {
    pad.left
  }


  // TODO 处理格式化问题，让其不影响number
  return _rebuild_general-block-level-elem(
    e,
    number,
    left-inset: inset,
    right-inset: inset,
    inset: get_abs-len(text-size, inset),
    elem-func,
    // text-size: text-size,
  )
}

/// Rebuilds a paragraph element with first-line indent handling
///
/// Parameters:
///   - e: The paragraph element
///   - number: The number/content for the first column
///   - elem-func: The function to apply to the body
///   - text-size: Optional text size for conversion
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_par-elem(e, number, elem-func, text-size: (:)) = {
  let left-inset = par.first-line-indent.amount
  let has_first-line-indent = e.has("first-line-indent")
  let indent = if has_first-line-indent {
    e.first-line-indent.amount
  } else {
    par.first-line-indent.amount
  }
  // TODO 处理格式化问题，让其不影响number
  return _rebuild_general-block-level-elem(
    e,
    number,
    inset: get_abs-len(text-size, indent),
    left-inset: indent - left-inset,
    right-inset: left-inset,
    elem-func,
  )
}

/// Rebuilds a block element with inset handling
///
/// Parameters:
///   - e: The block element
///   - number: The number/content for the first column
///   - elem-func: The function to apply to the body
///   - text-size: Optional text size for conversion
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_block-elem(e, number, elem-func, text-size: (:)) = {
  let inset = if e.has("inset") { e.inset } else { block.inset }
  let left-inset = _get_left_inset(inset)
  // TODO 处理格式化问题，让其不影响number
  return _rebuild_general-block-level-elem(
    e,
    number,
    inset: get_abs-len(text-size, left-inset),
    left-inset: left-inset,
    right-inset: left-inset,
    elem-func,
  )
}

/// Rebuilds a repeat element with gap handling
///
/// Parameters:
///   - e: The repeat element
///   - number: The number/content for the first column
///   - elem-func: The function to apply to the body
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_repeat-elem(e, number, elem-func) = {
  let field = e.fields()
  let _body = field.remove("body")
  let _label = field.remove("label", default: none)

  let _nbody = elem-func(_body, number)
  let parse-body = _nbody.body
  let gap = if e.has("gap") { e.gap } else { repeat.gap }
  // bug: the set show can not apply to the first repeated content.
  if _nbody.inline == true {
    return (
      body: {
        rebuild-label(
          [

            #fix-first-line#box()[#h-inset-m#number#h-inset#parse-body]#h(gap)#box(
              width: 1fr,
              repeat(
                parse-body,
                ..field,
              ),
            )
          ],
          _label,
        )
      },
      inline: false,
    )
  } else {
    return (
      body: {
        rebuild-label([#box()[#parse-body]#h(gap)#box(width: 1fr, repeat(parse-body, ..field))], _label)
      },
      inline: _nbody.inline,
    )
  }
}

/// Rebuilds a layout element with number and alignment handling
///
/// Parameters:
///   - e: The layout element to rebuild
///   - number: The number/content for the first column
///   - elem-func: The function to apply to the body
///
/// Returns:
///   A tuple with the rebuilt body and inline flag
#let _rebuild_layout-elem(e, number, elem-func) = {
  let _label = get_elem_label(e)
  let _f = e.fields()
  let new-func = it => {
    let _body = (e.func)(it)
    // 递归
    let _nbody = elem-func(_body, number)
    let parse-body = _nbody.body
    if _nbody.inline == true {
      [

        #fix-first-line#h-inset-m#number#h-inset#parse-body
      ]
    } else if _nbody.inline == false {
      parse-body
    } else {
      // same level: special case should be considered !!!
      let item-inset = parent-item-inset.get()
      parent-number-box.update(push((body: number, item-inset: item-inset)))
      parse-body
    }
  }
  return (
    body: rebuild-label(layout(new-func), _label),
    inline: false,
  )
}


/// Rebuilds a native element with number and alignment handling
///
/// This function processes a native element (`e`) and applies transformations:
/// - Adds numbering (`number`) to the element
/// - Handles vertical alignment (`alignment`)
/// - Controls automatic margins (`auto-margin`)
/// - Preserves existing styles and labels
///
/// Parameters:
///   - e: The native element to rebuild
///   - number: The number/content to prepend
///   - alignment: Vertical alignment (default: `top`)
///   - auto-margin: Whether to use auto margins (default: `true`)
///
/// Returns:
///   A tuple with the rebuilt body and a boolean indicating inline status
#let _rebuild_native-elem(e, number, alignment: top, auto-margin: true) = {
  return (
    body: {
      // TODO: baseline for this case
      // let d = measure(number).height
      // let movable-number = box(move(dy: d * 100%)[#number])
      // [#h(-p-inset)#number#h(p-inset, weak: true)]
      grid2(
        [

          #fix-first-line#h-inset-m#number#h-inset
        ],
        [#e],
        align: (alignment, bottom), // bottom
        auto-margin: auto-margin,
      )
    },
    inline: false,
  )
}



/// Rebuilds a block-level element with number and alignment handling
///
/// This function processes a block-level element (`e`) and applies transformations:
/// - Adds numbering (`number`) to the element
/// - Handles vertical alignment (`alignment`)
/// - Controls automatic margins (`auto-margin`)
/// - Applies text size adjustments (`text-size`)
/// - Preserves existing styles and labels
///
/// Parameters:
///   - e: The block-level element to rebuild
///   - number: The number/content to prepend
///   - alignment: Vertical alignment (default: `top`)
///   - auto-margin: Whether to use auto margins (default: `true`)
///   - text-size: Optional text size adjustments (default: (:))
///
/// Returns:
///   A tuple with the rebuilt body and a boolean indicating inline status
#let rebuild_block-level-elem(e, number, alignment: top, auto-margin: true, text-size: (:)) = {
  if e == none {
    return (body: [], inline: true)
  }
  let func = e.func()

  let _label = get_elem_label(e)
  if func == func-seq {
    let index = -1
    let body = e.children
    for child in body {
      index += 1
      if is_blank(child) {
        // remove parbreak ???
        // for colbreak, native behavior is a bug !!!
        if child == parbreak() {
          body.at(index) = []
        }
        continue
      } else {
        // Special case: only for `raw`
        if child.func() == raw and body.len() == 1 {
          return _rebuild_native-elem(e, number, alignment: alignment, auto-margin: auto-margin)
        }
        // others
        let new-child = rebuild_block-level-elem(
          child,
          number,
          alignment: alignment,
          auto-margin: auto-margin,
          text-size: text-size,
        )

        if new-child.inline == false {
          return (
            body: [#func-seq(body.slice(0, index))#new-child.body#rebuild-label(
                func-seq(body.slice(index + 1, body.len())),
                _label,
              )],
            inline: new-child.inline,
          )
        } else {
          body.at(index) = new-child.body //
          return (body: rebuild-label(func-seq(body), _label), inline: new-child.inline)
        }
      }
    }
    // blank
    return (body: rebuild-label(func-seq(body), _label), inline: true)
  } else if is_item(e) {
    // list, enum
    return (
      body: e,
      inline: none,
    )
  } else if func == block {
    return _rebuild_block-elem(
      e,
      number,
      text-size: text-size,
      rebuild_block-level-elem.with(alignment: alignment, auto-margin: auto-margin, text-size: text-size),
    )
  } else if func == par {
    return _rebuild_par-elem(
      e,
      number,
      text-size: text-size,
      rebuild_block-level-elem.with(alignment: alignment, auto-margin: auto-margin, text-size: text-size),
    )
  } else if func == pad {
    return _rebuild_pad-elem(
      e,
      number,
      rebuild_block-level-elem.with(alignment: alignment, auto-margin: auto-margin, text-size: text-size),
      text-size: text-size,
    )
  } else if (
    func
      in (
        figure,
        heading,
        table,
        grid,
        columns, // ??
        align,
        place,
        move,
        rotate,
        scale,
        skew,
        stack, // ??
        circle,
        ellipse,
        rect,
        square,
        curve,
        image,
        line,
        polygon,
        outline,
        // should need to be handled ???
        terms, // ??
        terms.item, // ??
      )
  ) {
    // 暂时不处理 (native)
    // columns ?
    // TODO align ??
    // TODO stack ??
    return _rebuild_native-elem(e, number, alignment: alignment, auto-margin: auto-margin)
  } else if func in blockable-level-elem {
    // raw and equation
    if e.has("block") and e.block {
      return _rebuild_native-elem(e, number, alignment: alignment, auto-margin: auto-margin)
    } else {
      // inline
      return (body: e, inline: true)
    }
  } else if func == repeat {
    return _rebuild_repeat-elem(
      e,
      number,
      rebuild_block-level-elem.with(alignment: alignment, auto-margin: auto-margin, text-size: text-size),
    )
  } else if func == func-layout {
    return _rebuild_layout-elem(
      e,
      number,
      rebuild_block-level-elem.with(alignment: alignment, auto-margin: auto-margin, text-size: text-size),
    )
  } else if func == v {
    if e.amount == 0pt {
      // ignore
      return (body: [], inline: true)
    }
    // consider as an inline-level elem
    return (body: [#v(e.amount, weak: true)#v(-par.leading)], inline: true)
  } else {
    if is_styled(e) {
      // styled
      let field = e.fields()
      let _body = field.remove("child")
      let _label = field.remove("label", default: none)
      let _nbody = rebuild_block-level-elem(
        _body,
        number,
        alignment: alignment,
        auto-margin: auto-margin,
        text-size: text-size,
      )
      return (body: [#rebuild-label(func-styled(_nbody.body, e.styles), _label)], inline: _nbody.inline)
    } else if is_text-styled(e) {
      let field = e.fields()
      let _body = field.remove("body")
      let _label = field.remove("label", default: none)
      let _nbody = rebuild_block-level-elem(
        _body,
        number,
        alignment: alignment,
        auto-margin: auto-margin,
        text-size: text-size,
      )
      return (body: [#rebuild-label(e.func()(_nbody.body, ..field), _label)], inline: _nbody.inline)
    }

    // blank or inline-level elem
    return (
      body: e,
      inline: true,
    )
  }
}



