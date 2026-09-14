
/*
Helper methods for fixing and enhancing enum and list functionality.
*/

/// Fixes the indentation issue for the first line of a paragraph.
///
/// -> any
#let fix-first-line = context {
  if par.first-line-indent.all and par.first-line-indent.amount != 0 {
    h(-par.first-line-indent.amount)
  }
}

/// Calculates the spacing between elements based on the current context.
///
/// - it: The enum or list object.
/// -> length
#let get_spacing = it => {
  if it.spacing == auto {
    if it.tight { par.leading } else { par.spacing }
  } else {
    it.spacing
  }
}

/// Determines if the given item is a "same-level" list.
///
/// - it: The item to check.
/// -> bool
#let is_same_level = it => {
  return (
    (
      it.func() == [].func() and it.children.len() > 0 and it.children.first().func() in (list.item, enum.item)
    )
      or it.func() in (list.item, enum.item)
  )
}

/// Pushes an element to the end of an array.
///
/// - e: The element to push.
/// - it: The array to modify.
/// -> array
#let push(e) = it => {
  it.push(e)
  it
}

/// Removes the last element from an array.
///
/// - it: The array to modify.
/// -> array
#let pop = it => {
  if it.len() == 0 { return it }
  return it.slice(0, -1)
}

/// State variable to mark whether indentation is applied.
#let suojing = state("_suojing", false)

/// State variable to record the preceding numbers or symbols of "same-level" lists.
#let parent-number-box = state("_parent-number-box", ())

/// State variable to record the parent-level numbering of `enum`.
#let curr-parent-level = state("_enum-level", ())

/// State variable to record the nesting level of `list`.
#let list-level = state("_list-level", 0)

/// State variable to record the nesting level for items.
#let item-level = state("_item-level", ())

/// State variable to record the `numbering` and `full` parameters of the current `enum`.
#let enum-numbering = state("_enum-numbering", (numbering: "1.1.1.", full: false))

/// State variable to record the maximum width of the current `enum` list.
#let label-width-enum = state("_label-width-enum", ())

/// State variable to record the maximum width of the current `list` list.
#let label-width-list = state("_label-width-list", ())

/// State variable to record the maximum width of the current `enum` and `list` lists.
#let label-width-el = state("_label-width-el", ())

/// Unique identifier for enumerated lists.
#let enum-ID = "_cdl_enum"

/// Determines the numbering kind from a character.
///
/// - c: The character to check.
/// -> string
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let numbering-kind-from-char(c) = {
  let numberings = (
    "1",
    "a",
    "A",
    "i",
    "I",
    "α",
    "Α",
    "*",
    "א",
    "一",
    "壹",
    "あ",
    "い",
    "ア",
    "イ",
    "ㄱ",
    "가",
    "\u{0661}",
    "\u{06F1}",
    "\u{0967}",
    "\u{09E7}",
    "\u{0995}",
    "①",
    "⓵",
  )
  if c in numberings { c }
}

/// Parses a numbering pattern string into its components.
///
/// - pattern: The numbering pattern string.
/// -> dictionary
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let numbering-pattern-from-str(pattern) = {
  let pieces = ()
  let handled = 0

  for (i, c) in pattern.codepoints().enumerate() {
    let kind = numbering-kind-from-char(c)
    if kind == none { continue }
    let prefix = pattern.slice(handled, i)
    pieces.push((prefix, kind))
    handled = c.len() + i
  }

  let suffix = pattern.slice(handled)
  if pieces.len() == 0 {
    panic("invalid numbering pattern")
  }
  (pieces: pieces, suffix: suffix, trimmed: false)
}

/// Applies the numbering pattern to the k-th level with the given number.
///
/// - numbering: The numbering pattern.
/// - k: The level index.
/// - number: The number to format.
/// -> string
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let apply-numbering-kth(numbering, k, number) = {
  let fmt = ""
  let self = numbering-pattern-from-str(numbering)
  if self.pieces.len() > 0 {
    let (prefix, _) = self.pieces.first()
    fmt += prefix
    let (_, kind) = if k < self.pieces.len() {
      self.pieces.at(k)
    } else {
      self.pieces.last()
    }
    fmt += std.numbering(kind, number)
  }
  fmt += self.suffix
  fmt
}


/// Parses named arguments with support for level-based value selection.
///
/// - args: Named arguments to parse.
/// - level: The current nesting level for value selection.
/// -> arguments
#let parse-args(..args, level: 0) = {
  let dic = for (k, v) in args.named() {
    if type(v) == array {
      let value = v.at(level, default: v.last())
      if value != auto {
        (str(k): value)
      }
    } else {
      if v != auto {
        (str(k): v)
      }
    }
  }
  return arguments(..dic)
}

/// Retrieves a value from an array based on the current nesting level.
///
/// - value: The value or array of values.
/// - level: The current nesting level.
/// -> any
#let get_depth-value(value, level) = {
  if type(value) == array {
    if value.len() == 0 {
      return value
    } else {
      return value.at(level, default: value.last())
    }
  } else {
    return value
  }
}

/// Parses a length value with support for nested level-based selection.
///
/// - complex-len: The length value or array of values to parse.
/// - level: The current nesting level.
/// - max-width: The maximum width of the current list label.
/// - it: The type of the current list (`enum` or `list`).
/// - absolute-level: Whether to use absolute nesting levels.
/// - default: The default value if `auto` is specified.
/// -> length
#let parse-len(complex-len, level, max-width, it, absolute-level, default) = {
  if complex-len == auto {
    return default
  } else {
    let temp-len = if type(complex-len) == function {
      complex-len(
        level + 1,
        (
          get: l => {
            let label-w = if absolute-level {
              label-width-el.get()
            } else {
              if it == enum { label-width-enum.get() } else if it == list { label-width-list.get() }
            }
            if l - 1 in range(label-w.len()) {
              label-w.at(l - 1)
            } else {
              max-width
            }
          },
          current: max-width,
        ),
        (
          get: l => if absolute-level { item-level.get().at(l - 1, default: it) } else { it },
          current: it,
        ),
      )
    } else { complex-len }
    let len = get_depth-value(temp-len, level)
    if len == auto {
      return default
    } else {
      return len
    }
  }
}

/// Parses and calculates indentation and spacing values.
///
/// Parameters
/// - it: The item object.
/// - level: The nesting level of the item.
/// - max-width: The maximum width available for the item.
/// - absolute-level: If `true`, uses absolute nesting levels.
/// - indent: The base indentation (default: auto).
/// - body-indent: The body indentation (default: auto).
/// - label-indent: The label indentation (default: auto).
/// - is-full-width: Whether the item should take full width (default: true).
/// - item-spacing: Spacing between items (default: auto).
/// - enum-spacing: Spacing around enumeration (default: auto).
/// - enum-margin: Margin for enumeration (default: auto).
/// - hanging-type: The type of hanging indentation (default: "classic").
/// - hanging-indent: Hanging indentation (default: auto).
/// - line-indent: Line indentation (default: auto).
///
/// -> A tuple containing calculated values for indentation, spacing, and margins.
#let parse(
  it,
  level,
  max-width,
  absolute-level,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-type: "classic", // paragraph
  hanging-indent: auto,
  line-indent: auto,
) = {
  let curr-indent = parse-len(indent, level, max-width, it, absolute-level, it.indent)

  let curr-body-indent = parse-len(body-indent, level, max-width, it, absolute-level, it.body-indent)

  let curr-label-indent = parse-len(label-indent, level, max-width, it, absolute-level, 0em)

  let _hanging-indent = if item-level.get().len() == 0 {
    par.hanging-indent
  } else {
    state("_parent-hanging-indent", 0em).get()
  }

  let _line-indent = if item-level.get().len() == 0 {
    par.first-line-indent.amount
  } else {
    state("_parent-line-indent", 0em).get()
  }


  let curr-hanging-indent = parse-len(hanging-indent, level, max-width, it, absolute-level, _hanging-indent)

  let curr-line-indent = parse-len(line-indent, level, max-width, it, absolute-level, _line-indent)

  let enum-width = {
    if is-full-width {
      100%
    } else {
      if enum-margin != auto {
        let _enum-margin = get_depth-value(enum-margin, level)
        if _enum-margin == auto {
          auto
        } else if type(_enum-margin) in (length, relative, ratio) {
          100% - _enum-margin
        } else {
          panic("invalid arguments: enum-margin should be a length")
        }
      } else {
        auto
      }
    }
  }

  let spacing = get_spacing(it)

  let (enum-above-spacing, enum-below-spacing) = {
    let (default-above, default-below) = (if it.tight { par.leading } else { par.spacing }, par.spacing)
    if enum-spacing == auto {
      (default-above, default-below)
    } else {
      let _enum-spacing = get_depth-value(enum-spacing, level)
      if _enum-spacing == auto {
        (default-above, default-below)
      } else {
        let _type = type(_enum-spacing)
        if _type in (length, relative, ratio) {
          (_enum-spacing, _enum-spacing)
        } else if _type == dictionary {
          // 这里可以处理更仔细些
          let (above, below) = _enum-spacing
          (if above == auto { default-above } else { above }, if below == auto { default-below } else { below })
        } else {
          panic("invalid arguments")
        }
      }
    }
  }

  let curr-item-spacing = {
    if item-spacing == auto {
      spacing
    } else {
      let _item-spacing = get_depth-value(item-spacing, level)
      if _item-spacing == auto {
        spacing
      } else {
        _item-spacing
      }
    }
  }

  return (
    curr-indent,
    curr-body-indent,
    curr-label-indent,
    curr-hanging-indent,
    curr-line-indent,
    enum-width,
    enum-above-spacing,
    enum-below-spacing,
    curr-item-spacing,
  )
}


/// Enhances the `enum` function with additional formatting options.
///
/// - it: The enum object to fix.
/// - indent: The indent for each item.
/// - body-indent: The spacing between the marker and the body.
/// - label-indent: The indent for the label.
/// - is-full-width: If `true`, sets the item width to 100%.
/// - item-spacing: The spacing between items.
/// - enum-spacing: The spacing around the enum.
/// - enum-margin: The margin around the enum.
/// - hanging-type: The type of hanging indent ("classic" or "paragraph").
/// - hanging-indent: The hanging indent value.
/// - line-indent: The first line indent value.
/// - absolute-level: If `true`, uses absolute nesting levels.
/// - args: Additional named arguments for text formatting.
/// -> any
#let fix-enum(
  it,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-type: "classic", // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  ..args,
) = context {
  item-level.update(push(enum))
  enum-numbering.update((numbering: it.numbering, full: it.full))
  let cur = 0
  let numbers = ()
  for i in range(it.children.len()) {
    let child = it.children.at(i)
    if child.has("number") and child.number != none {
      numbers.push(child.number)
      cur = child.number
    } else {
      cur += 1
      numbers.push(cur)
    }
  }
  let parent-level = curr-parent-level.get()

  let level = if absolute-level { item-level.get().len() } else { parent-level.len() }
  // [#args]
  let custom-text(body) = text(..parse-args(..args, level: level), align(it.number-align, body))

  let resolved(number) = if number != none {
    if it.full {
      custom-text(numbering(it.numbering, ..parent-level, number))
    } else {
      if type(it.numbering) == str {
        custom-text([#apply-numbering-kth(
            it.numbering,
            parent-level.len(),
            number,
          )#sym.space.nobreak#h(-measure(sym.space.nobreak).width)])
      } else {
        custom-text(numbering(it.numbering, number))
      }
    }
  }

  let max-width = calc.max(..numbers.map(number => measure(resolved(number)).width))

  label-width-enum.update(push(max-width))
  label-width-el.update(push(max-width))

  if item-level.get().len() == 0 {
    state("_parent-hanging-indent", 0em).update(par.hanging-indent)
    state("_parent-line-indent", 0em).update(par.first-line-indent.amount)
  }

  let (
    curr-indent,
    curr-body-indent,
    curr-label-indent,
    curr-hanging-indent,
    curr-line-indent,
    enum-width,
    enum-above-spacing,
    enum-below-spacing,
    curr-item-spacing,
  ) = parse(
    it,
    level,
    max-width,
    absolute-level,
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: hanging-type,
    hanging-indent: hanging-indent,
    line-indent: line-indent,
  )


  set par(hanging-indent: curr-hanging-indent, first-line-indent: (amount: curr-line-indent, all: true)) if (
    hanging-type == "classic"
  )
  set par(hanging-indent: -max-width - curr-body-indent + curr-hanging-indent, first-line-indent: (
    amount: -max-width - curr-body-indent + curr-line-indent,
    all: true,
  )) if hanging-type == "paragraph"

  let width = max-width + curr-indent + curr-body-indent
  let inset = if text.dir == rtl { (right: width) } else { (left: width) }


  for i in range(numbers.len()) {
    let child = it.children.at(i)
    let child-number = if it.reversed {
      numbers.at(numbers.len() - i - 1)
    } else {
      numbers.at(i)
    }
    // if it.full {
    //   curr-parent-level.update(it => it + (child-number,))
    // }

    curr-parent-level.update(push(child-number))

    let block-wrap = if i == 0 {
      if i == numbers.len() - 1 {
        // last and first
        block.with(
          inset: inset,
          below: enum-below-spacing,
          above: enum-above-spacing,
          width: enum-width,
          // stroke: 1pt + red,
        )
      } else {
        // first but not last
        block.with(
          inset: inset,
          below: curr-item-spacing,
          above: enum-above-spacing,
          width: enum-width,
          // stroke: 1pt + red,
        )
      }
    } else if i == numbers.len() - 1 {
      // last but not first
      block.with(
        inset: inset,
        below: enum-below-spacing,
        above: curr-item-spacing,
        width: enum-width,
        // stroke: 1pt + blue,
      )
    } else {
      block.with(inset: inset, below: curr-item-spacing, above: curr-item-spacing, width: enum-width)
    }
    let number-body = [#h(-max-width - curr-body-indent)#h(curr-label-indent)#box(
        resolved(child-number),
        width: max-width,
      )#h(curr-body-indent)] //|#(level+1)|
    let content-body = [
      #block-wrap[

        #fix-first-line#number-body#child.body
      ]
    ]

    // 显示内容
    if is_same_level(child.body) {
      suojing.update(true)
      parent-number-box.update(it => it + ((body: number-body, width: width),))
      block-wrap[
        #child.body
      ]
    } else {
      suojing.update(false)
      if suojing.get() {
        if i == 0 {
          let dx = {
            let pp = parent-number-box.get()
            for i in range(pp.len() - 1) {
              [#h(-pp.at(i + 1).width)]
            }
            [#h(-width)]
          }

          let parent-box = {
            let pp = parent-number-box.get()
            for i in range(pp.len() - 1) {
              [#pp.at(i).body]
              [#h(pp.at(i + 1).width)]
            }
            [#pp.at(pp.len() - 1, default: (body: none)).body]
            [#h(width)]
          }
          block-wrap[

            #fix-first-line#dx#parent-box#number-body#child.body
          ]
          parent-number-box.update(())
        } else {
          content-body
        }
      } else {
        content-body
      }
    }
    curr-parent-level.update(pop)
  }
  label-width-enum.update(pop)
  label-width-el.update(pop)
  item-level.update(pop)
}

/// Enhances the `list` function with additional formatting options.
///
/// - it (): The enum object to fix.
/// - indent: The indent for each item.
/// - body-indent: The spacing between the marker and the body.
/// - label-indent: The indent for the label.
/// - is-full-width: If `true`, sets the item width to 100%.
/// - item-spacing: The spacing between items.
/// - enum-spacing: The spacing around the enum.
/// - enum-margin: The margin around the enum.
/// - hanging-type: The type of hanging indent ("classic" or "paragraph").
/// - hanging-indent: The hanging indent value.
/// - line-indent: The first line indent value.
/// - absolute-level: If `true`, uses absolute nesting levels.
/// - args: Additional named arguments for text formatting.
/// -> any
#let fix-list(
  it,
  indent: auto,
  label-indent: 0em,
  body-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-type: "classic", // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  ..args,
) = context {
  item-level.update(push(list))
  list-level.update(it => it + 1)

  let level = if absolute-level { item-level.get().len() } else { list-level.get() }

  let custom-text = text.with(..parse-args(..args, level: level))

  let spacing = get_spacing(it)
  let marker-level = list-level.get()
  let marker = {
    if type(it.marker) == array {
      if it.marker.len() == 0 {
        it.marker
      } else {
        it.marker.at(calc.rem(marker-level, it.marker.len()))
      }
    } else {
      it.marker
    }
  }


  let max-width = if type(marker) == function {
    // form: level => n => value
    let temp = marker(marker-level + 1)
    if type(temp) == function {
      calc.max(..for n in range(it.children.len()) { (measure(custom-text(temp(n))).width,) })
    } else if type(temp) == array {
      calc.max(..temp.map(child => measure(custom-text(child)).width))
    } else {
      measure(custom-text(temp)).width
    }
  } else {
    measure(custom-text(marker)).width
  }

  label-width-list.update(push(max-width))
  label-width-el.update(push(max-width))

  if item-level.get().len() == 0 {
    state("_parent-hanging-indent", 0em).update(par.hanging-indent)
    state("_parent-line-indent", 0em).update(par.first-line-indent.amount)
  }

  let (
    curr-indent,
    curr-body-indent,
    curr-label-indent,
    curr-hanging-indent,
    curr-line-indent,
    enum-width,
    enum-above-spacing,
    enum-below-spacing,
    curr-item-spacing,
  ) = parse(
    it,
    level,
    max-width,
    absolute-level,
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: hanging-type,
    hanging-indent: hanging-indent,
    line-indent: line-indent,
  )


  set par(hanging-indent: curr-hanging-indent, first-line-indent: (amount: curr-line-indent, all: true)) if (
    hanging-type == "classic"
  )
  set par(hanging-indent: -max-width - curr-body-indent + curr-hanging-indent, first-line-indent: (
    amount: -max-width - curr-body-indent + curr-line-indent,
    all: true,
  )) if hanging-type == "paragraph"

  let width = max-width + curr-indent + curr-body-indent
  let inset = if text.dir == rtl { (right: width) } else { (left: width) }

  let len = it.children.len()

  let marker-display = n => {
    if type(marker) == function {
      let temp = marker(marker-level + 1)
      if type(temp) == function {
        // form: n => value
        return custom-text(temp(n))
      } else if type(temp) == array {
        if temp.len() != 0 {
          return custom-text(temp.at(n, default: temp.last()))
        } else {
          return custom-text(temp)
        }
      } else {
        return custom-text(temp)
      }
    } else {
      return custom-text(marker)
    }
  }

  for i in range(len) {
    let child = it.children.at(i)
    // curr-parent-level.update(it => it + (i,))

    let block-wrap = if i == 0 {
      if i == len - 1 {
        // last and first
        block.with(
          inset: inset,
          below: enum-below-spacing,
          above: enum-above-spacing,
          width: enum-width,
          // stroke: 1pt + red,
        )
      } else {
        // first but not last
        block.with(
          inset: inset,
          below: curr-item-spacing,
          above: enum-above-spacing,
          width: enum-width,
          // stroke: 1pt + red,
        )
      }
    } else if i == len - 1 {
      // last but not first
      block.with(
        inset: inset,
        below: enum-below-spacing,
        above: curr-item-spacing,
        width: enum-width,
        // stroke: 1pt + blue,
      )
    } else {
      block.with(inset: inset, below: curr-item-spacing, above: curr-item-spacing, width: enum-width)
    }

    let number-body = [#h(-width + curr-indent)#h(curr-label-indent)#box(marker-display(i), width: max-width)#h(
        curr-body-indent,
      )]
    let content-body = [
      #block-wrap[

        #fix-first-line#number-body#child.body
      ]
    ]

    if is_same_level(child.body) {
      suojing.update(true)
      parent-number-box.update(it => it + ((body: number-body, width: width),))
      block-wrap[

        #child.body
      ]
    } else {
      suojing.update(false)
      if suojing.get() {
        if i == 0 {
          let dx = {
            let pp = parent-number-box.get()
            for i in range(pp.len() - 1) {
              [#h(-pp.at(i + 1).width)]
            }
            [#h(-width)]
          }

          let parent-box = {
            let pp = parent-number-box.get()
            for i in range(pp.len() - 1) {
              [#pp.at(i).body]
              [#h(pp.at(i + 1).width)]
            }
            [#pp.at(pp.len() - 1, default: (body: none)).body]
            [#h(width)]
          }
          block-wrap[

            #fix-first-line#dx#parent-box#number-body#child.body
          ]
          parent-number-box.update(())
        } else {
          content-body
        }
      } else {
        content-body
      }
    }
    // curr-parent-level.update(slice)
  }
  label-width-list.update(pop)
  label-width-el.update(pop)
  list-level.update(it => it - 1)
  item-level.update(pop)
}

