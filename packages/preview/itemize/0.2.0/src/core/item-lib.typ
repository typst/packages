#import "fix-enum-list.typ" as fel



/// Change the marker of the current item in list to `body`.
///   - body (content): the marker
#let item(body) = {
  if type(body) != content {
    panic("The argument should be a content.")
  } else {
    metadata((kind: fel.list-ID, body: body))
  }
}





/// Returns the relative nesting depth of an item within an enumeration.
///
/// Returns:
///   The nesting level (1-based index) of the current enumeration item
///
/// -> int
#let level() = {
  return fel.enum-level.get()
}

/// Returns the relative nesting depth of an item within a list.
///
/// Returns:
///   The nesting level (1-based index) of the current list item
///
/// -> int
#let list-level() = {
  return fel.list-level.get()
}

/// Returns the level counts of the current enumeration item.
///
/// Returns:
///   An array containing the count at each nesting level for the current item
///
/// > array
#let level-count() = {
  return fel.curr-parent-level.get()
}

/// Reference formatter for enumeration items (supports `@` syntax).
///
/// Usage:
///   Add `#show ref: ref-enum` at document start.
///
/// Returns:
///   Formatted reference content
///
/// Parameters:
///   - it (): The reference target
///   - full (auto,bool): Whether to show full hierarchical numbering.
///     Default: `auto` (inherits from enum context)
///   - numbering (str,function,auto): Numbering pattern or formatter.
///     Default: `auto` (inherits from enum context)
///   - supplement (auto,content): Supplemental content for reference.
///   - no-label-warning (bool): Show warning for missing labels.
///
/// -> content
#let ref-enum(it, full: auto, numbering: auto, supplement: auto, no-label-warning: false) = {
  let el = it.element
  if el != none {
    if el.func() == text or el.func() == enum.item or el.func() == metadata and el.value == fel.enum-label-ID {
      let enum-count = fel.curr-parent-level.at(it.target)
      if enum-count.len() > 0 {
        let supplement-body = if it.supplement == auto {
          if supplement not in (auto, [], none) {
            [#supplement#h(0em, weak: true)~]
          }
        } else {
          [#it.supplement#h(0em, weak: true)~]
        }
        let number-body = if numbering != auto {
          let _full = full
          let _numbering = numbering
          let (numbering, full, auto-base-level, curr-enum-level) = fel.enum-numbering.at(it.target)
          if auto-base-level {
            if (_full == auto and full) or (_full == true) {
              let base-num-count = fel.curr-base-parent-level.at(it.target)
              [#std.numbering(_numbering, ..base-num-count)]
            } else {
              [#fel.apply-numbering-kth(_numbering, curr-enum-level, enum-count.last())]
            }
          } else {
            if (_full == auto and full) or (_full == true) {
              [#std.numbering(_numbering, ..enum-count)]
            } else {
              [#fel.apply-numbering-kth(_numbering, enum-count.len() - 1, enum-count.last())]
            }
          }
          // [#std.numbering(numbering, ..enum-count)]
        } else {
          let _full = full
          let (numbering, full, auto-base-level, curr-enum-level) = fel.enum-numbering.at(it.target)
          if auto-base-level {
            if (_full == auto and full) or (_full == true) {
              let base-num-count = fel.curr-base-parent-level.at(it.target)
              [#std.numbering(numbering, ..base-num-count)]
            } else {
              [#fel.apply-numbering-kth(numbering, curr-enum-level, enum-count.last())]
            }
          } else {
            if (_full == auto and full) or (_full == true) {
              [#std.numbering(numbering, ..enum-count)]
            } else {
              [#fel.apply-numbering-kth(numbering, enum-count.len() - 1, enum-count.last())]
            }
          }
        }
        link(el.location(), [#supplement-body#number-body])
      } else {
        it
      }
    } else {
      it
    }
  } else {
    if no-label-warning [#text(weight: "bold", fill: red)[[???]]] else { it }
  }
}



/// Creates a labeled reference point for enum items.
///
/// Note:
///   - Only works when attached to `text`/`enum.item` elements
///   - Use this when regular `label()` won't work with enum references
/// Returns:
///   Formatted reference content
///
/// Parameters:
///   - name (str, label): Label identifier
///
/// -> content
#let elabel(name) = {
  let _label = fel.get_label(name)
  [#metadata(fel.enum-label-ID)#_label]
}
