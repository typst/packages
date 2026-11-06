#import "../util/func-type.typ": *
#import "../util/identifier.typ": *
#import "../util/level-state.typ": *
#import "../util/basic-tool.typ": *

// 为了item-format属性不影响label的格式化, 需要分析对列表中的所有元素进行重构以区分label和body

/// Rebuilds an element with a body property while preserving its label
///
/// Parameters:
///   - e (element): The element to rebuild
///   - body-func (function): Function to transform the body content
///
/// Returns:
///   A tuple with the rebuilt body and a boolean indicating if it contains items
///
/// Behavior:
///   - Handles special cases for link, align, columns, place, rotate, and scale elements
///   - Preserves the original element's label
#let _rebuild_elem_with_body(e, body-func) = {
  // assert(e.has("body"))

  let func = e.func()
  let field = e.fields()

  let _label = field.remove("label", default: none)
  let _body = field.remove("body")

  let _nbody = body-func(_body)

  // consider different elements
  if func == link {
    return (body: rebuild-label(func(e.dest, _nbody.body), _label), has: _nbody.has)
  } else if func == align {
    let _alignment = field.remove("alignment", default: align.alignment)
    return (body: rebuild-label(func(_alignment, _nbody.body), _label), has: _nbody.has)
  } else if func == columns {
    let _count = field.remove("count", default: columns.count)
    return (body: rebuild-label(func(_count, _nbody.body, ..field), _label), has: _nbody.has)
  } else if func == place {
    let _alignment = field.remove("alignment", default: place.alignment)
    return (body: rebuild-label(func(_alignment, _nbody.body, ..field), _label), has: _nbody.has)
  } else if func == rotate {
    let _angle = field.remove("angle", default: rotate.angle)
    return (body: rebuild-label(func(_angle, _nbody.body, ..field), _label), has: _nbody.has)
  } else if func == scale {
    let _factor = field.remove("factor", default: scale.factor)
    return (body: rebuild-label(func(_factor, _nbody.body, ..field), _label), has: _nbody.has)
  } else {
    return (body: rebuild-label(func(_nbody.body, ..field), _label), has: _nbody.has)
  }
}

/// Rebuilds an element with children property (e.g., tables, grids, stacks)
///
/// Parameters:
///   - e (element): The parent element with children
///   - body-func (function): Function to transform each child
///
/// Returns:
///   A tuple with the rebuilt body and always true (since it's a block-level element)
///
/// Note:
///   - Specifically handles block-level elements
#let _rebuild_elem_with_children(e, body-func) = {
  // assert(e.has("children"))

  // table, grid, stack ....
  let field = e.fields()
  let _body = field.remove("children")
  let _children = _body.map(t => body-func(t).body)
  let _label = field.remove("label", default: none)
  // block-level elem: true
  return (body: rebuild-label(e.func()(.._children, ..field), _label), has: true)
}

/// Rebuilds a styled element while preserving its styles and label
///
/// Parameters:
///   - e (element): The styled element to rebuild
///   - body-func (function): Function to transform the child content
///
/// Returns:
///   A tuple with the rebuilt body and the has-item flag from the child
///
/// Note:
///   - Assumes e.func() == func-styled
#let _rebuild_styled_elem(e, body-func) = {
  // assert(e.func() == func-styled)

  let _label = if e.has("label") { e.label }
  let _nbody = body-func(e.child)
  return (body: rebuild-label(func-styled(_nbody.body, e.styles), _label), has: _nbody.has)
}

/// Rebuilds a layout element (func-layout) with custom processing
///
/// Parameters:
///   - e (element): The layout element to rebuild
///   - body-func (function): Function to transform the layout content
///
/// Returns:
///   A tuple with the rebuilt body and always true (block-level)
///
/// Note:
///   - Assumes e.func() == func-layout
#let _rebuild_layout_elem(e, body-func) = {
  // assert(e.func() == func-layout)

  let field = e.fields()
  let _label = field.remove("label", default: none)
  let new-func = it => {
    let _body = (field.func)(it)
    body-func(_body).body
  }
  // block-level elem: true
  return (body: rebuild-label(layout(new-func), _label), has: true)
}

/// Rebuilds a sequence element (func-seq) with complex child processing
///
/// Parameters:
///   - e (element): The sequence element to rebuild
///   - body-func (function): Function to transform each child
///
/// Returns:
///   A tuple with the rebuilt body and a boolean indicating if it contains items
///
/// Behavior:
///   - Handles nested sequences, styled elements, items, and special cases
///   - Preserves style-body-native-format-label markers
///   - Groups adjacent elements with same has-item flag
#let _rebuild_seq_elem(e, body-func) = {
  // assert(e.func() == func-seq)

  let sub-body = ()
  let has_item = false
  let prev = for child in e.children {
    let _label = get_elem_label(child)
    if _label == style-body-native-format-label {
      // do no need to style
      sub-body.push((body: child, has: true))
    } else {
      // need to style
      if child.func() == func-seq {
        // seq
        let new-child = _rebuild_seq_elem(child, body-func)
        if new-child.has {
          has_item = true
        }
        sub-body.push(new-child)
      } else if is_blank(child) {
        sub-body.push((body: child, has: false))
      } else if child.func() == func-styled {
        // styled
        let new-child = _rebuild_styled_elem(child, body-func)
        if new-child.has {
          has_item = true
        }
        sub-body.push(new-child)
      } else if child.func() in item-func {
        // item
        if sub-body != () {
          let sub-array = _continue-group-by(sub-body, it => it.has)
          let sub-seq = for c in sub-array {
            if c.first().has {
              [#func-seq(c.map(it => it.body))]
            } else {
              // prevent "blank" elem
              [#metadata(none)#func-seq(c.map(it => it.body))#style-body-format-label]
            }
          }
          sub-seq
        }
        has_item = true
        child
        sub-body = ()
      } else if child.has("body") {
        // has body (include: text-styled, exclude: item)
        let new-child = _rebuild_elem_with_body(child, body-func)
        if new-child.has {
          has_item = true
        }
        sub-body.push(new-child)
      } else if child.has("children") {
        // has children
        let new-child = _rebuild_elem_with_children(child, body-func)
        if new-child.has {
          has_item = true
        }
        sub-body.push(new-child)
      } else if child.func() == func-layout {
        // layout
        let new-child = _rebuild_layout_elem(child, body-func)
        if new-child.has {
          has_item = true
        }
        sub-body.push(new-child)
      } else {
        // Special case: only for raw
        if child.func() == raw {
          sub-body.push((body: [#func-seq((child,))#style-body-format-label], has: false))
        } else {
          // others (e.g. context): can not handle
          sub-body.push((body: child, has: false))
        }
      }
    }
  }
  let body = if sub-body != () {
    let sub-array = _continue-group-by(sub-body, it => it.has)
    let sub-seq = for c in sub-array {
      if c.first().has {
        [#func-seq(c.map(it => it.body))]
      } else {
        [#metadata(none)#func-seq(c.map(it => it.body))#style-body-format-label]
      }
    }
    [#prev#sub-seq]
  } else {
    prev
  }
  return (body: body, has: has_item)
}


/// it : the element
/// -> (body, has) , body: the new rebuild element; has: contain item?
/// style-body-native-format-label: (user) do not apply style, style-body-format-label: need to apply style, others: hold-on (i.e. item)
/// Main element rebuilding function with comprehensive type handling
///
/// Parameters:
///   - it (element): The element to rebuild
///
/// Returns:
///   A tuple with the rebuilt body and a boolean indicating if it contains items
///
/// Behavior:
///   - Handles none/blank values
///   - Preserves style-body-native-format-label
///   - Dispatches to specific rebuilders based on element type:
///     - Sequences → _rebuild_seq_elem
///     - Styled → _rebuild_styled_elem
///     - Items → returns directly
///     - Body-having → _rebuild_elem_with_body
///     - Children-having → _rebuild_elem_with_children
///     - Layout → _rebuild_layout_elem
///     - Special cases for text-styled and raw elements
#let rebuild-elem(it) = {
  if it == none {
    return (body: [], has: false)
  }
  if it.has("label") and it.label == style-body-native-format-label {
    return (body: it, has: true)
  }

  if it.func() == func-seq {
    // seq
    return _rebuild_seq_elem(it, rebuild-elem)
  } else if is_blank(it) {
    return (body: it, has: false)
  }
  let func = it.func()
  if func == func-styled {
    // styled
    return _rebuild_styled_elem(it, rebuild-elem)
  } else if func in item-func {
    // item
    return (body: it, has: true)
  } else if it.has("body") {
    // body
    let new-e = _rebuild_elem_with_body(it, rebuild-elem)
    if func in text-style-func {
      // Special case
      if not new-e.has {
        return (
          body: [#func-seq((new-e.body,))#style-body-format-label],
          has: new-e.has,
        )
      }
    }
    return new-e
  } else if it.has("children") {
    // children
    return _rebuild_elem_with_children(it, rebuild-elem)
  } else if func == func-layout {
    // layout
    return _rebuild_layout_elem(it, rebuild-elem)
  }

  // text ... and context (can not handle)
  return (body: [#func-seq((it,))#style-body-format-label], has: false)
}
