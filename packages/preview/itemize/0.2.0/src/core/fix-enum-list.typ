
#import "../lib/checklist.typ": character-symbol, default-format-map, default-symbol-map, small-text
#import "../util/numbering.typ": *

#import "../util/identifier.typ": *
#import "../util/level-state.typ": *
#import "../lib/prevent-label.typ": *
#import "../lib/block-elem-rebuild.typ": *
#import "../lib/item-rebuild.typ": *
#import "../util/basic-tool.typ": *

/*
Helper methods for fixing and enhancing enum and list functionality.
*/

/// Pre-processes formatted content and returns the rebuilt element body.
///
/// - body: The formatted content to be processed.
/// -> The rebuilt content after processing.
#let pre_parse-formatted-body(body) = {
  return rebuild-elem(body).body
}

#let pre_parse-formatted-body(body) = {
  return rebuild-elem(body).body
}



/// Parses a length value with support for nested level-based selection.
///
/// Parameters:
/// - `complex-len`: The length value or array of values to parse.
/// - `max-width`: Maximum width of the current list label.
/// - `it`: Type of the current list (`enum` or `list`).
/// - `absolute-level`: Whether to use absolute nesting levels.
/// - `default`: Default value if `auto` is specified.
/// - `level`: Current nesting level.
/// - `abs-level`: Absolute nesting level.
///
/// Returns:
/// The parsed length value.
#let parse-len(complex-len, max-width, it, absolute-level, default, level, abs-level) = n => {
  if complex-len == auto {
    return default
  } else {
    let increment = abs-level - level
    // complex-len: it => value; it => array
    let label-w = if absolute-level {
      label-width-el.get()
    } else {
      if it.func() == enum { label-width-enum.get() } else if it.func() == list { label-width-list.get() }
    }
    if type(complex-len) == function {
      let temp-len = complex-len(
        (
          level: level + 1,
          n: n + 1,
          n-last: it.children.len(),
          label-width: (
            get: l => {
              label-w.at(l - 1 + increment, default: max-width)
            },
            current: max-width,
          ),
          e: (
            get: l => if absolute-level {
              get_type-enum-or-list(item-level.get().at(l - 1 + increment, default: it))
            } else { it },
            current: it,
          ),
        ),
      )
      return get_value-by-n(temp-len, auto, default)(n)
    } else {
      // complex-len: array; value
      return get_value-by-n(get_depth-value(complex-len, level), auto, default)(n)
    }
  }
}

/// Parses and calculates layout parameters for enum/list items.
///
/// Parameters:
/// - `it`: The item context object.
/// - `curr-level`: Current nesting level.
/// - `abs-level`: Absolute nesting level.
/// - `max-width`: Maximum label width.
/// - `absolute-level`: If true, uses absolute nesting levels.
/// - `indent`: Base indentation (default: auto).
/// - `body-indent`: Body indentation (default: auto).
/// - `label-indent`: Label indentation (default: auto).
/// - `is-full-width`: Whether item takes full width (default: true).
/// - `item-spacing`: Spacing between items (default: auto).
/// - `enum-spacing`: Spacing around enumeration (default: auto).
/// - `enum-margin`: Margin for enumeration (default: auto).
/// - `hanging-indent`: Hanging indentation (default: auto).
/// - `line-indent`: Line indentation (default: auto).
///
/// Returns:
/// A tuple containing calculated layout parameters:
/// - Current indentation values
/// - Enum width function
/// - Spacing values
#let parse(
  it,
  curr-level,
  abs-level,
  max-width,
  absolute-level,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
) = {
  let curr-indent = parse-len(indent, max-width, it, absolute-level, it.indent, curr-level, abs-level)

  let curr-body-indent = parse-len(body-indent, max-width, it, absolute-level, it.body-indent, curr-level, abs-level)

  let curr-label-indent = parse-len(label-indent, max-width, it, absolute-level, 0em, curr-level, abs-level)


  let (_hanging-indent, _line-indent) = if curr-level == 0 {
    (par.hanging-indent, par.first-line-indent.amount)
  } else {
    state("_parent-hanging-indent_and_line-indent", ((0em, 0em),)).get().last()
  }


  let curr-hanging-indent = parse-len(
    hanging-indent,
    max-width,
    it,
    absolute-level,
    _hanging-indent,
    curr-level,
    abs-level,
  )

  let curr-line-indent = parse-len(line-indent, max-width, it, absolute-level, _line-indent, curr-level, abs-level)

  let enum-width = {
    if is-full-width == true {
      n => 100%
    } else {
      let margin-f = parse-general-func-with-level-n(enum-margin, auto, auto, n-last: it.children.len())(curr-level)
      n => {
        let margin = margin-f(n)
        if margin == auto {
          auto
        } else if type(margin) in (length, relative, ratio) {
          100% - margin
        } else if margin != none {
          panic("Invalid arguments: enum-margin should be a length.")
        } // none
      }
    }
  }

  let spacing = if it.spacing == auto {
    if it.tight { par.leading } else { par.spacing }
  } else {
    it.spacing
  }


  let (enum-above-spacing, enum-below-spacing) = {
    // will be uniform in the next version of `itemize`
    let (default-above, default-below) = if sys.version >= version(0, 14, 0) {
      // typst >= 0.14
      (spacing, par.spacing)
    } else {
      (if it.tight { par.leading } else { par.spacing }, par.spacing)
    }

    if enum-spacing == auto {
      (default-above, default-below)
    } else {
      let _enum-spacing = get_depth-value(enum-spacing, curr-level)
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
        } else if _enum-spacing != none {
          panic("Invalid arguments.")
        } else {
          (none, none)
        }
      }
    }
  }

  let curr-item-spacing = parse-general-func-with-level-n(item-spacing, auto, spacing, n-last: it.children.len())(
    curr-level,
  )


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




/// Generates a layout block based on the given parameters.
///
/// Parameters:
/// - `n`: Index of the current item.
/// - `len`: Total length of the list.
/// - `inset`: Inner padding of the block.
/// - `enum-below-spacing`: Spacing below the last item.
/// - `enum-above-spacing`: Spacing above the first item.
/// - `curr-item-spacing`: Spacing between current items.
/// - `enum-width`: Width of the block.
/// - `args`: Additional optional parameters.
///
/// Returns:
/// A configured layout block based on the parameters.
#let get_layout-block(n, len, inset, enum-below-spacing, enum-above-spacing, curr-item-spacing, enum-width, ..args) = {
  if n == 0 {
    if n == len - 1 {
      // last and first
      block.with(
        ..default-block-args,
        inset: inset,
        below: enum-below-spacing,
        above: enum-above-spacing,
        width: enum-width,
        ..args,
        // stroke: 1pt + red,
      )
    } else {
      // first but not last
      block.with(
        ..default-block-args,
        inset: inset,
        below: curr-item-spacing,
        above: enum-above-spacing,
        width: enum-width,
        ..args,
        // stroke: 1pt + red,
      )
    }
  } else if n == len - 1 {
    // last but not first
    block.with(
      ..default-block-args,
      inset: inset,
      below: enum-below-spacing,
      above: curr-item-spacing,
      width: enum-width,
      ..args,
      // stroke: 1pt + blue,
    )
  } else {
    block.with(
      ..default-block-args,
      inset: inset,
      below: curr-item-spacing,
      above: curr-item-spacing,
      width: enum-width,
      breakable: true,
      ..args,
    )
  }
}

/// Gets the left indent value for block-level elements.
///
/// Parameters:
///   - `curr-text-size`: Current text size.
///   - `format-args`: Formatting arguments, which may contain an `inset` field.
///
/// Returns:
///   - The calculated left indent value (as a length unit), or `0pt` if no indent is specified.
#let get-block-left-inset(curr-text-size, format-args) = {
  if format-args != none {
    let inset = format-args.at("inset", default: none)
    if inset != none {
      let left-inset = _get_left_inset(inset)
      get_abs-len(curr-text-size, left-inset)
    } else {
      0pt
    }
  } else {
    0pt
  }
}


/// Displays a label with proper layout and spacing.
///
/// Parameters:
/// - `label-box`: The content of the label box.
/// - `label-inset`: The inset (padding) of the label.
/// - `inner-inset`: The inner inset (padding) of the label.
/// - `same-line-style`: Whether to keep the label on the same line.
/// - `label-height`: The height of the label.
/// - `curr-baseline`: The current baseline position.
///
/// Returns:
/// current label
#let display-label(label-box, label-inset, inner-inset, same-line-style, label-height, curr-baseline) = {
  let pp = parent-number-box.get()
  if pp == () {
    return [#h(-inner-inset)#label-box(baseline: curr-baseline)#h(inner-inset)#h(0em, weak: true)]
  }
  let item-inset = parent-item-inset.get()

  let arr-inset = ()
  let count = 0
  if item-inset != () {
    // 需要的是第2项
    for i in range(1, pp.len()) {
      let p-item-inset = pp.at(i).item-inset

      let cur-len = p-item-inset.len()
      if cur-len == count {
        arr-inset.push(0em)
        continue
      } else {
        let inset = 0em
        for k in range(count, cur-len) { inset += p-item-inset.at(k) }
        arr-inset.push(inset)
      }
      count = cur-len
    }
  }
  // handle the final item
  let final-len = item-inset.len()
  if count != final-len {
    // let remain = final-len - count
    // [#remain]
    let inset = 0em
    for k in range(count, final-len) { inset += item-inset.at(k) }
    arr-inset.push(inset)
  } else {
    arr-inset.push(0em)
  }

  let dx = {
    let l-inset = -label-inset - inner-inset
    for index in range(pp.len() - 1) {
      l-inset += -pp.at(index + 1).label-inset //- f-inset.at(index + 1)
    }
    l-inset += -arr-inset.sum(default: 0pt)
    [#h(l-inset)]
  }

  let parent-box = {
    for index in range(pp.len()) {
      let p-label = pp.at(index)
      // for `layout`
      if type(p-label.body) == content {
        [#p-label.body]
      } else {
        let height = p-label.label-height
        let p-baseline = get-basline-with-style(same-line-style, height, label-height, curr-baseline)
        [#(p-label.body)(baseline: p-baseline)]
      }
      // if f-inset != () { h(f-inset.at(index + 1, default: outer-inset)) }
      [#h(pp.at(index + 1, default: (label-inset: label-inset)).label-inset)]
      if item-inset != () [#h(arr-inset.at(index))]
    }
  }
  [#dx#parent-box#label-box(baseline: curr-baseline)#h(inner-inset)#h(0em, weak: true)]
}


/// Creates a formatted box to wrap content and adjust styles based on parameters.
///
/// Parameters:
/// - `body`: The content to be formatted.
/// - `width`: The width of the box, defaults to `auto`.
/// - `format-args`: Additional formatting parameters, defaults to an empty dictionary `(:)`.
///
/// Returns:
/// The formatted content or the original content if no formatting parameters are provided.
#let make-format-box(body, width: auto, format-args: (:)) = {
  if format-args not in (none, (:)) {
    block.with(..default-block-args, width: width, ..format-args)(
      body,
    )
  } else {
    body
  }
}

/// Creates a labeled box for items in an enumerated list.
///
/// Parameters:
/// - `body`: The main content of the box.
/// - `width`: The width of the box.
/// - `curr-baseline`: The current baseline position.
/// - `pre-inset`: Optional leading padding (default: none).
/// - `body-inset`: Optional body padding (default: none).
/// - `label-align`: Label alignment (default: right).
/// - `baseline`: Optional baseline position (default: none).
/// - `alone`: Whether to use standalone (default: true).
#let label-box(
  body,
  width,
  curr-baseline,
  pre-inset: none,
  body-inset: none,
  label-align: right,
  baseline: 0pt,
  alone: true,
) = [#pre-inset#box(
    align(label-align, body),
    width: width,
    ..default-box-args,
    baseline: if alone { curr-baseline } else { baseline },
  )#body-inset#h(0em, weak: true)]


/// Fixes and formats enum with customizable styling and layout.
///
/// Parameters
/// - `it`: The enum to be formatted.
/// - `elem`: The type of element to format ("list", "enum", or "both").
/// - `indent`: The indentation for the enum items.
/// - `label-indent`: The indentation for the labels (markers).
/// - `body-indent`: The indentation for the body content.
/// - `is-full-width`: Whether the enum should span the full width.
/// - `item-spacing`: The spacing between enum items.
/// - `enum-spacing`: The spacing for enum items.
/// - `enum-margin`: The margin for enum items.
/// - `hanging-type`: The type of hanging indent ("classic" or "paragraph").
/// - `hanging-indent`: The hanging indentation.
/// - `line-indent`: The line indentation.
/// - `absolute-level`: Whether to use absolute levels for indentation.
/// - `auto-base-level`: Whether to auto-detect the base level.
/// - `label-width`: The width of the labels.
/// - `body-format`: The formatting for the body content.
/// - `label-format`: The formatting for the labels.
/// - `item-format`: The formatting for the items.
/// - `checklist`: Whether to enable checklist mode.
/// - `label-align`: The alignment for the labels.
/// - `label-baseline`: The baseline for the labels.
/// - `func-list`: The function for list formatting.
/// - `func-enum`: The function for enum formatting.
/// - `curr-level`: The current level of nesting.
/// - `curr-enum-level`: The current enum level.
/// - `curr-list-level`: The current list level.
/// - `enum-config`: Configuration for enum.
/// - `list-config`: Configuration for list.
/// - `args`: Allows passing any named arguments of `text` to format the text style of `label`.
///
/// Returns
/// A formatted enum with the specified styling and layout.
#let fix-enum(
  it,
  elem: "enum",
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
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  item-format: none, /*new ver0.2.0*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0: length*/
  checklist: false, /*new ver0.2.0, for list*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  curr-level: 0,
  curr-enum-level: 0,
  curr-list-level: 0,
  enum-config: (:), /** config enum only */
  list-config: (:), /** config list only */
  ..args,
) = {
  item-level.update(push("enum"))
  enum-numbering.update((
    numbering: it.numbering,
    full: it.full,
    auto-base-level: auto-base-level,
    curr-enum-level: curr-enum-level,
  ))
  enum-level.update(it => it + 1)

  context {
    // levels
    let abs-level = item-level.get().len() - 1
    let abs-enum-level = enum-level.get() - 1
    // let it-level = if auto-base-level { curr-level } else { abs-level }
    let it-enum-level = if auto-base-level { curr-enum-level } else { abs-enum-level }
    let level = if absolute-level { abs-level } else { abs-enum-level }
    let rel-level = if absolute-level { curr-level } else { curr-enum-level }

    // format enum function
    let enum-config-args = parse-elem-args(elem-args: enum-config)


    // format function
    let curr-item-format = {
      let item-format-f = parse-item-format(item-format, rel-level, n-last: it.children.len())
      let item-format-f-e = parse-item-format(enum-config-args.item-format, curr-enum-level, n-last: it.children.len())
      for (k, f) in item-format-f {
        (str(k): n => body => f(n)((item-format-f-e.at(str(k)))(n)(body)))
      }
    }

    let (curr-body-border, curr-body-style) = {
      let (border-f, style-f) = parse-body-format(body-format, rel-level, n-last: it.children.len())
      let (border-f-e, style-f-e) = parse-body-format(
        enum-config-args.body-format,
        curr-enum-level,
        n-last: it.children.len(),
      )
      (
        for (k, value) in border-f {
          (str(k): n => value(n) + (border-f-e.at(str(k)))(n))
        },
        n => style-f(n) + style-f-e(n),
      )
    }

    let curr-label-format = {
      let label-format-f = parse-format-func(label-format, n-last: it.children.len())(rel-level)
      let label-format-f-e = parse-format-func(enum-config-args.label-format, n-last: it.children.len())(
        curr-enum-level,
      )
      n => body => label-format-f(n)(label-format-f-e(n)(body))
    }

    // for the next show-raw
    let all-args = (
      elem: elem,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      is-full-width: is-full-width,
      item-spacing: item-spacing,
      enum-spacing: enum-spacing,
      enum-margin: enum-margin,
      hanging-type: hanging-type, // paragraph
      hanging-indent: hanging-indent,
      line-indent: line-indent,
      absolute-level: absolute-level,
      auto-base-level: auto-base-level, /*new ver0.2.0*/
      label-width: label-width, /*new ver0.2.0*/
      body-format: body-format, /*new ver0.2.0*/
      label-format: label-format, /*new ver0.2.0*/
      item-format: item-format, /*new ver0.2.0*/
      label-align: label-align, /*new ver0.2.0*/
      label-baseline: label-baseline, /*new ver0.2.0*/
      checklist: checklist, /*new ver0.2.0*/
      func-enum: func-enum,
      func-list: func-list,
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level + 1,
      curr-list-level: curr-list-level,
    )
    let next-show = body => {
      if elem == "both" {
        show enum: func-enum.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
        )
        body
      } else {
        show enum: func-enum.with(
          ..all-args,
          ..args,
        )
        body
      }
    }

    let is-formatted-item = (
      item-format not in (none, (), auto, (:)) or enum-config-args.item-format not in (none, (), auto, (:))
    )

    let parse-formatted-body = if is-formatted-item {
      pre_parse-formatted-body
    } else {
      native-content
    }

    // enum's number (label)
    let numbers = ()
    let cur = if it.start == auto { 0 } else { it.start - 1 }
    // set enum(start: cur + 1)
    for i in range(it.children.len()) {
      let child = it.children.at(i)
      if child.has("number") and child.number not in (none, auto) {
        // typst 0.14
        numbers.push(child.number)
        cur = child.number
      } else {
        cur += 1
        numbers.push(cur)
      }
    }

    if curr-level == 0 and elem != "list" {
      state("_default-text-style", (default-text-args,)).update(push(get_current-text-args(text)))
      state("_parent-hanging-indent_and_line-indent", ((0em, 0em),)).update(push(
        (par.hanging-indent, par.first-line-indent.amount),
      ))
    }

    let default-text-level0 = if curr-level == 0 {
      get_current-text-args(text)
    } else {
      state("_default-text-style", (default-text-args,)).get().last()
    }

    /*
    feat: custom label (enum's number)
    */
    let text-args = {
      let curr-text-args = parse-args(..args, rel-level, n-last: it.children.len())
      let elem-text-args = parse-args(..enum-config-args.text-args, curr-enum-level, n-last: it.children.len())
      n => curr-text-args(n) + elem-text-args(n)
    }
    let custom-text = n => body => {
      set text(..default-text-level0, ..text-args(n), overhang: false)
      if is-formatted-item {
        show: show-label-text-style
        curr-label-format(n)([#body#label-number-ID-label])
      } else {
        curr-label-format(n)(body)
      }
    }


    let resolved(number) = if number != none {
      if it.full {
        if auto-base-level {
          // use `curr-base-parent-level` to void "layout did not converge within 5 attempts"
          numbering(it.numbering, ..curr-base-parent-level.get(), number)
        } else {
          numbering(it.numbering, ..curr-parent-level.get(), number)
        }
      } else {
        if type(it.numbering) == str {
          apply-numbering-kth(
            it.numbering,
            it-enum-level,
            number,
          )
        } else {
          numbering(it.numbering, number)
        }
      }
    }
    let styled-numbers = {
      for i in range(numbers.len()) {
        (custom-text(i)((resolved(numbers.at(i)))),)
      }
    }

    let numbers-width = styled-numbers.map(number => measure(number).width)

    let number-max-width = calc.max(..numbers-width)

    /*feat: the style of indent label*/
    let curr-label-width = {
      if enum-config-args.label-width != none {
        parse-label-width(
          enum-config-args.label-width,
          number-max-width,
          curr-enum-level,
          labels-width: numbers-width,
          n-last: it.children.len(),
        )
      } else { parse-label-width(label-width, number-max-width, rel-level, n-last: it.children.len()) }
    }

    // box(stroke: 1pt + yellow, inset: 1pt)[|#context lw.max-width-label.get()| width: #max-width]

    /*
    need to update
    */
    label-width-enum.update(push(number-max-width))
    label-width-el.update(push(number-max-width))


    let (
      indent-f,
      body-indent-f,
      label-indent-f,
      hanging-indent-f,
      line-indent-f,
      enum-width-f,
      enum-above-spacing-f,
      enum-below-spacing-f,
      item-spacing-f,
    ) = parse(
      it,
      curr-level,
      level,
      number-max-width, /*ver0.1.x might change in the future*/
      absolute-level,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      is-full-width: is-full-width,
      item-spacing: item-spacing,
      enum-spacing: enum-spacing,
      enum-margin: enum-margin,
      hanging-indent: hanging-indent,
      line-indent: line-indent,
    )

    let (
      indent-f-e,
      body-indent-f-e,
      label-indent-f-e,
      hanging-indent-f-e,
      line-indent-f-e,
      enum-width-f-e,
      enum-above-spacing-f-e,
      enum-below-spacing-f-e,
      item-spacing-f-e,
    ) = parse(
      it,
      curr-enum-level,
      it-enum-level,
      number-max-width, /*ver0.1.x might change in the future*/
      false,
      indent: enum-config-args.indent,
      body-indent: enum-config-args.body-indent,
      label-indent: enum-config-args.label-indent,
      is-full-width: enum-config-args.is-full-width,
      item-spacing: enum-config-args.item-spacing,
      enum-spacing: enum-config-args.enum-spacing,
      enum-margin: enum-config-args.enum-margin,
      hanging-indent: enum-config-args.hanging-indent,
      line-indent: enum-config-args.line-indent,
    )

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
    ) = (
      n => get_none-value(indent-f(n), indent-f-e(n)),
      n => get_none-value(body-indent-f(n), body-indent-f-e(n)),
      n => get_none-value(label-indent-f(n), label-indent-f-e(n)),
      n => get_none-value(hanging-indent-f(n), hanging-indent-f-e(n)),
      n => get_none-value(line-indent-f(n), line-indent-f-e(n)),
      n => get_none-value(enum-width-f(n), enum-width-f-e(n)),
      get_none-value(enum-above-spacing-f, enum-above-spacing-f-e),
      get_none-value(enum-below-spacing-f, enum-below-spacing-f-e),
      n => get_none-value(item-spacing-f(n), item-spacing-f-e(n)),
    )


    if not auto-base-level {
      curr-base-parent-level.update(())
    }

    let curr-label-align = parse-general-args-with-level-n(
      label-align,
      rel-level,
      enum-config-args.label-align,
      curr-enum-level,
      it.number-align,
      n-last: it.children.len(),
    )

    let curr-label-baseline = parse-general-args-with-level-n(
      label-baseline,
      rel-level,
      enum-config-args.label-baseline,
      curr-enum-level,
      0pt,
      n-last: it.children.len(),
    )


    let len = numbers.len()

    // each item
    let body = for i in range(len) {
      let child = it.children.at(i)
      let index = if it.reversed { len - i - 1 } else { i }

      let child-number = numbers.at(index)
      let curr-width = numbers-width.at(index)

      let styled-child-number = styled-numbers.at(index)

      // update: parent-level
      curr-parent-level.update(push(child-number))

      if auto-base-level {
        curr-base-parent-level.update(push(child-number))
      }


      let (amount, style) = curr-label-width(i)

      let max-width = if amount == auto { curr-width } else { amount }
      let width = (max-width + curr-indent(i) + curr-body-indent(i)).to-absolute()


      /* enum'number (label) */
      let number-width = if style == "native" {
        number-max-width
      } else if amount != auto {
        if style == "default" {
          if curr-width <= amount.to-absolute() { amount } else { curr-width }
        } else if style == "constant" {
          amount
        } else if style == "auto" {
          curr-width
        }
      } else { max-width }

      let curr-text-style = (curr-body-style)(i)

      let curr-text-size = {
        if curr-text-style != none {
          let size = curr-text-style.at("size", default: none)
          if size != none {
            (size: size)
          }
        }
        (:)
      }


      let outer-left-inset = get-block-left-inset(curr-text-size, (curr-body-border.outer)(i))

      let outer = (curr-body-border.outer)(i)

      let outer-inset = if outer != none {
        outer.remove("inset", default: (:))
      } else {
        0pt
      }
      let outer-inset-without-left = parse-inset-without-left(outer-inset)

      // in fact, rtl is not supported yet.
      let inset = if text.dir == rtl { (right: width) } else {
        (left: width + outer-left-inset) + outer-inset-without-left
      }


      // display content
      let layout-block = get_layout-block(
        i,
        len,
        inset,
        enum-below-spacing,
        enum-above-spacing,
        curr-item-spacing(i),
        enum-width(i),
        ..outer,
      )

      let inner-box = make-format-box.with(width: enum-width(i), format-args: (curr-body-border.inner)(i))

      // the item's content to display
      let item-content(body, number-body: none) = (curr-item-format.outer)(i)(layout-block(
        (curr-item-format.inner)(i)(inner-box(
          if number-body == none {
            [#next-show(show-text((curr-body-style)(i), body))]
          } else {
            [

              #fix-first-line#number-body#h(0em, weak: true)#next-show(show-text((curr-body-style)(i), body))
            ]
          },
        )),
      ))


      /*label baseline*/
      let (curr-baseline, same-line-style, base-align, is-alone, label-height) = parse-baseline(
        curr-label-baseline(i),
        styled-child-number,
        curr-text-style,
      )

      let pre-inset = h(
        -max-width.to-absolute() - curr-body-indent(i).to-absolute() + curr-label-indent(i).to-absolute(),
      )
      let body-inset = h(curr-body-indent(i).to-absolute())
      let box-width = number-width.to-absolute()

      /* current label */
      let number-box(baseline: 0pt, alone: true) = label-box(
        styled-child-number,
        box-width,
        curr-baseline,
        pre-inset: pre-inset,
        body-inset: body-inset,
        label-align: curr-label-align(i),
        alone: alone,
        baseline: baseline,
      )

      let inner-left-inset = get-block-left-inset(curr-text-size, (curr-body-border.inner)(i))

      let label-inset = (
        width + get-block-left-inset(curr-text-size, (curr-body-border.whole)(i)) + outer-left-inset
      )

      /* hanging-indent, first-line-indent */
      set par(
        hanging-indent: curr-hanging-indent(i).to-absolute(),
        first-line-indent: (amount: curr-line-indent(i).to-absolute(), all: true),
      ) if hanging-type == "classic"

      set par(
        hanging-indent: (-max-width - curr-body-indent(i) + curr-hanging-indent(i) - inner-left-inset).to-absolute(),
        first-line-indent: (
          amount: (-max-width - curr-body-indent(i) + curr-line-indent(i) - inner-left-inset).to-absolute(),
          all: true,
        ),
      ) if hanging-type == "paragraph"

      // all the number
      let the-number = if i == 0 {
        display-label(
          number-box,
          label-inset,
          inner-left-inset,
          same-line-style,
          label-height,
          curr-baseline,
        )
      } else {
        [#h(-inner-left-inset)#number-box(baseline: curr-baseline)#h(inner-left-inset)#h(0em, weak: true)]
      }

      // parse body (in order to determine how to display label)
      let new-body = rebuild_block-level-elem(
        parse-formatted-body(child.body),
        the-number,
        alignment: base-align,
        auto-margin: enum-width(i) == auto,
        text-size: curr-text-size,
      )

      // record the left inset of the current block-level elems
      parent-item-inset.update(push(inner-left-inset))

      // [#repr(new-body)]
      if new-body.inline == none {
        // hold on displaying number
        let item-inset = parent-item-inset.get()
        parent-number-box.update(push((
          body: number-box.with(alone: is-alone),
          label-inset: label-inset,
          label-height: label-height,
          item-inset: item-inset,
        )))
        item-content(new-body.body)
        // [||||#parent-item-inset.get()!!!]
      } else {
        parent-number-box.update(())
        parent-item-inset.update(())
        if new-body.inline == true {
          item-content(new-body.body, number-body: the-number)
        } else {
          item-content(new-body.body)
        }
      }

      curr-parent-level.update(pop)

      if auto-base-level {
        curr-base-parent-level.update(pop)
      }
    }

    let whole-block = make-format-box.with(format-args: (curr-body-border.whole)(0))
    // body
    (curr-item-format.whole)(0)(whole-block(body))
  }

  label-width-enum.update(pop)
  label-width-el.update(pop)
  item-level.update(pop)
  enum-level.update(it => it - 1)


  if curr-level == 0 and elem != "list" {
    state("_default-text-style", (default-text-args,)).update(pop)
    state("_parent-hanging-indent_and_line-indent").update(pop)
  }
}



/// Retrieves the marker text from the given body.
///
/// Parameters
/// - `body`: The input body to extract the marker text from.
///
/// Returns
/// The extracted marker text as a string, or `none` if no valid marker text is found.
#let get_marker-text(body) = {
  if body == [ ] {
    " "
  } else if body == ["] {
    "\""
  } else if body == ['] {
    "'"
  } else if body.has("text") {
    body.text
  } else {
    none
  }
}

/// Retrieves the description marker from a given body if it matches the expected metadata and list-ID kind.
///
/// Parameters
/// - `body`: The body to check for the description marker.
///
/// Returns
/// The description marker if found, otherwise `none`.
#let get_desc-marker(body) = {
  if body.func() == metadata and type(body.value) == dictionary and body.value.at("kind", default: none) == list-ID {
    return body.value.body
  } else {
    return none
  }
}

/// Fixes and formats a list with customizable styling and layout.
///
/// Parameters
/// - `it`: The list to be formatted.
/// - `elem`: The type of element to format ("list", "enum", or "both").
/// - `indent`: The indentation for the list items.
/// - `label-indent`: The indentation for the labels (markers).
/// - `body-indent`: The indentation for the body content.
/// - `is-full-width`: Whether the list should span the full width.
/// - `item-spacing`: The spacing between list items.
/// - `enum-spacing`: The spacing for list items.
/// - `enum-margin`: The margin for list items.
/// - `hanging-type`: The type of hanging indent ("classic" or "paragraph").
/// - `hanging-indent`: The hanging indentation.
/// - `line-indent`: The line indentation.
/// - `absolute-level`: Whether to use absolute levels for indentation.
/// - `auto-base-level`: Whether to auto-detect the base level.
/// - `label-width`: The width of the labels.
/// - `body-format`: The formatting for the body content.
/// - `label-format`: The formatting for the labels.
/// - `item-format`: The formatting for the items.
/// - `checklist`: Whether to enable checklist mode.
/// - `label-align`: The alignment for the labels.
/// - `label-baseline`: The baseline for the labels.
/// - `func-list`: The function for list formatting.
/// - `func-enum`: The function for enum formatting.
/// - `curr-level`: The current level of nesting.
/// - `curr-enum-level`: The current enum level.
/// - `curr-list-level`: The current list level.
/// - `enum-config`: Configuration for enum.
/// - `list-config`: Configuration for lists.
/// - `args`: Allows passing any named arguments of `text` to format the text style of `label`.
///
/// Returns
/// A formatted list with the specified styling and layout.
#let fix-list(
  it,
  elem: "list",
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
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  item-format: none, /*new ver0.2.0*/
  checklist: false, /*new ver0.2.0, for list*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  curr-level: 0,
  curr-enum-level: 0,
  curr-list-level: 0,
  enum-config: (:), /** config enum only */
  list-config: (:), /** config list only */
  ..args,
) = {
  item-level.update(push("list"))
  list-level.update(it => it + 1)


  context {
    // levels
    let abs-level = item-level.get().len() - 1
    let abs-list-level = list-level.get() - 1
    // let it-level = if auto-base-level { curr-level } else { abs-level }
    let it-list-level = if auto-base-level { curr-list-level } else { abs-list-level }
    let level = if absolute-level { abs-level } else { abs-list-level }
    let rel-level = if absolute-level { curr-level } else { curr-list-level }

    // format enum function
    let list-config-args = parse-elem-args(elem-args: list-config)

    // format function
    let curr-item-format = {
      let item-format-f = parse-item-format(item-format, rel-level, n-last: it.children.len())
      let item-format-f-e = parse-item-format(list-config-args.item-format, curr-list-level, n-last: it.children.len())
      for (k, f) in item-format-f {
        (str(k): n => body => f(n)((item-format-f-e.at(str(k)))(n)(body)))
      }
    }

    let (curr-body-border, curr-body-style) = {
      let (border-f, style-f) = parse-body-format(body-format, rel-level, n-last: it.children.len())
      let (border-f-e, style-f-e) = parse-body-format(
        list-config-args.body-format,
        curr-list-level,
        n-last: it.children.len(),
      )
      (
        for (k, value) in border-f {
          (str(k): n => value(n) + (border-f-e.at(str(k)))(n))
        },
        n => style-f(n) + style-f-e(n),
      )
    }

    let curr-label-format = {
      let label-format-f = parse-format-func(label-format, n-last: it.children.len())(rel-level)
      let label-format-f-e = parse-format-func(list-config-args.label-format, n-last: it.children.len())(
        curr-list-level,
      )
      n => body => label-format-f(n)(label-format-f-e(n)(body))
    }

    // for the next show-raw
    let all-args = (
      elem: elem,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      is-full-width: is-full-width,
      item-spacing: item-spacing,
      enum-spacing: enum-spacing,
      enum-margin: enum-margin,
      hanging-type: hanging-type, // paragraph
      hanging-indent: hanging-indent,
      line-indent: line-indent,
      absolute-level: absolute-level,
      auto-base-level: auto-base-level, /*new ver0.2.0*/
      label-width: label-width, /*new ver0.2.0*/
      body-format: body-format, /*new ver0.2.0*/
      label-format: label-format, /*new ver0.2.0*/
      item-format: item-format, /*new ver0.2.0*/
      label-align: label-align, /*new ver0.2.0*/
      label-baseline: label-baseline, /*new ver0.2.0*/
      checklist: checklist, /*new ver0.2.0*/
      func-enum: func-enum,
      func-list: func-list,
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level,
      curr-list-level: curr-list-level + 1,
    )
    let next-show = body => {
      if elem == "both" {
        show enum: func-enum.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
        )
        body
      } else {
        show list: func-list.with(
          ..all-args,
          ..args,
        )
        body
      }
    }

    let is-formatted-item = (
      item-format not in (none, (), auto, (:)) or list-config-args.item-format not in (none, (), auto, (:))
    )

    let parse-formatted-body = if is-formatted-item {
      pre_parse-formatted-body
    } else {
      native-content
    }


    if curr-level == 0 and elem != "enum" {
      state("_default-text-style", (default-text-args,)).update(push(get_current-text-args(text)))
      state("_parent-hanging-indent_and_line-indent", ((0em, 0em),)).update(push(
        (par.hanging-indent, par.first-line-indent.amount),
      ))
    }

    let default-text-level0 = if curr-level == 0 {
      get_current-text-args(text)
    } else {
      state("_default-text-style", (default-text-args,)).get().last()
    }

    /*
    feat: custom label (list's marker)
    */
    let text-args = {
      let curr-text-args = parse-args(..args, rel-level, n-last: it.children.len())
      let elem-text-args = parse-args(..list-config-args.text-args, curr-list-level, n-last: it.children.len())
      n => curr-text-args(n) + elem-text-args(n)
    }
    let custom-text = n => body => {
      set text(..default-text-level0, ..text-args(n), overhang: false)
      if item-format not in (none, (), auto, (:)) {
        show: show-label-text-style
        curr-label-format(n)([#body#label-number-ID-label])
      } else {
        curr-label-format(n)(body)
      }
    }

    /*
    feat: description-list (like terms)
    */
    let desc-marker = ()
    let checklist-body = ()

    let setting = setting-checklist.get()
    let curr-checklist = get_depth-value(checklist, rel-level) or get_depth-value(setting.enable, curr-list-level) // for setting, use `curr-list-level`

    let fill-check
    let radius-check
    let solid-check
    let symbol-map = (:)
    let format-map = (:)
    let symbol-list
    let enable-character
    let checklist-label-baseline = none
    if curr-checklist {
      // since checklist works only for list, here, the level uses the `curr-list-level`
      fill-check = get_depth-value(setting.checklist-fill, curr-list-level)
      radius-check = get_depth-value(setting.checklist-radius, curr-list-level)
      solid-check = get_depth-value(setting.checklist-solid, curr-list-level)
      let checklist-map = get_depth-value(setting.checklist-map, curr-list-level)
      checklist-label-baseline = get_depth-value(setting.label-baseline, curr-list-level)
      let _temp-symbol-map
      if type(checklist-map) == function {
        _temp-symbol-map = checklist-map(
          (fill: fill-check, radius: radius-check, solid: solid-check),
        )
      } else if type(checklist-map) == dictionary {
        _temp-symbol-map = checklist-map
      }
      if type(_temp-symbol-map) == dictionary {
        symbol-map = for (k, v) in _temp-symbol-map { (str(k): small-text(v)) }
      }

      enable-character = get_depth-value(setting.enable-character, curr-list-level)
      let extras = get_depth-value(setting.extras, curr-list-level)
      symbol-list = (
        default-symbol-map(fill: fill-check, radius: radius-check, solid: solid-check, extras: extras) + symbol-map
      )
      let enable-format = get_depth-value(setting.enable-format, curr-list-level)
      if enable-format {
        let checklist-format-map = get_depth-value(setting.checklist-format-map, curr-list-level)
        format-map = default-format-map + checklist-format-map
      }
    }
    for child in it.children {
      let body = child.body
      if body.func() == func-styled {
        /// should be considered (due to the bug of native item and list)
        /// see the following code
        /// ```typ
        /// #set text(size: 2em, fill: red)
        /// -  #text(size: 2em)[[A] 1]
        /// - [A]
        /// - 22222
        /// - ffff
        /// ```
        body = child.body.child
      }
      if body.func() == func-seq and body.children.len() > 0 {
        // checklist
        let children = body.children
        if curr-checklist {
          // A checklist item has at least 4 children: `[`, marker, `]`, content
          if (
            children.len() < 3 or not (children.at(0) == [#"["] and children.at(2) == [#"]"])
          ) {
            desc-marker.push(get_desc-marker(children.at(0)))
            checklist-body.push(false)
          } else {
            let marker-text = get_marker-text(children.at(1))

            if marker-text != none {
              let marker-symbol = symbol-list.at(marker-text, default: none)
              if marker-symbol != none {
                desc-marker.push(marker-symbol)
                let format = format-map.at(marker-text, default: none)
                if format == none {
                  checklist-body.push(true)
                } else {
                  checklist-body.push(format)
                }
              } else {
                if enable-character {
                  desc-marker.push(character-symbol(
                    symbol: marker-text,
                    fill: fill-check,
                    radius: radius-check,
                    solid: solid-check,
                  ))
                  let format = format-map.at(marker-text, default: none)
                  if format == none {
                    checklist-body.push(true)
                  } else {
                    checklist-body.push(format)
                  }
                } else {
                  desc-marker.push(none)
                  checklist-body.push(false)
                }
              }
            } else {
              desc-marker.push(none)
              checklist-body.push(false)
            }
          }
        } else {
          desc-marker.push(get_desc-marker(children.at(0)))
        }
      } else {
        desc-marker.push(get_desc-marker(body))
        if curr-checklist {
          checklist-body.push(false)
        }
      }
    }


    let marker-level = it-list-level
    let marker = {
      if type(it.marker) == array {
        if it.marker == () {
          it.marker
        } else {
          it.marker.at(calc.rem(marker-level, it.marker.len()))
        }
      } else {
        it.marker
      }
    }

    let marker-display = n => {
      let desc = desc-marker.at(n, default: none)
      if desc != none {
        return desc
      }
      if type(marker) == function {
        let temp = marker(marker-level)
        if type(temp) == function {
          // form: n => value
          return temp(n)
        } else if type(temp) == array {
          return get_array-value(temp, n)
        } else {
          return temp
        }
      } else {
        return marker
      }
    }

    let styled-markers = {
      for i in range(it.children.len()) {
        (custom-text(i)((marker-display(i))),)
      }
    }

    let markers-width = styled-markers.map(number => measure(number).width)

    let marker-max-width = calc.max(..markers-width)

    /*feat: the style of indent label*/
    let curr-label-width = {
      if list-config-args.label-width != none {
        parse-label-width(
          list-config-args.label-width,
          marker-max-width,
          curr-enum-level,
          labels-width: markers-width,
          n-last: it.children.len(),
        )
      } else { parse-label-width(label-width, marker-max-width, rel-level, n-last: it.children.len()) }
    }

    /*
    need to update !!!!!!!!!!!!!!!!!!!
    */
    label-width-list.update(push(marker-max-width))
    label-width-el.update(push(marker-max-width))


    /* spacings */
    let (
      indent-f,
      body-indent-f,
      label-indent-f,
      hanging-indent-f,
      line-indent-f,
      enum-width-f,
      enum-above-spacing-f,
      enum-below-spacing-f,
      item-spacing-f,
    ) = parse(
      it,
      rel-level,
      level,
      marker-max-width, /*ver0.1.x*/
      absolute-level,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      is-full-width: is-full-width,
      item-spacing: item-spacing,
      enum-spacing: enum-spacing,
      enum-margin: enum-margin,
      hanging-indent: hanging-indent,
      line-indent: line-indent,
    )

    let (
      indent-f-e,
      body-indent-f-e,
      label-indent-f-e,
      hanging-indent-f-e,
      line-indent-f-e,
      enum-width-f-e,
      enum-above-spacing-f-e,
      enum-below-spacing-f-e,
      item-spacing-f-e,
    ) = parse(
      it,
      curr-list-level,
      it-list-level,
      marker-max-width, /*ver0.1.x*/
      false,
      indent: list-config-args.indent,
      body-indent: list-config-args.body-indent,
      label-indent: list-config-args.label-indent,
      is-full-width: list-config-args.is-full-width,
      item-spacing: list-config-args.item-spacing,
      enum-spacing: list-config-args.enum-spacing,
      enum-margin: list-config-args.enum-margin,
      hanging-indent: list-config-args.hanging-indent,
      line-indent: list-config-args.line-indent,
    )

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
    ) = (
      n => get_none-value(indent-f(n), indent-f-e(n)),
      n => get_none-value(body-indent-f(n), body-indent-f-e(n)),
      n => get_none-value(label-indent-f(n), label-indent-f-e(n)),
      n => get_none-value(hanging-indent-f(n), hanging-indent-f-e(n)),
      n => get_none-value(line-indent-f(n), line-indent-f-e(n)),
      n => get_none-value(enum-width-f(n), enum-width-f-e(n)),
      get_none-value(enum-above-spacing-f, enum-above-spacing-f-e),
      get_none-value(enum-below-spacing-f, enum-below-spacing-f-e),
      n => get_none-value(item-spacing-f(n), item-spacing-f-e(n)),
    )


    let len = it.children.len()

    // label-align
    let curr-label-align = parse-general-args-with-level-n(
      label-align,
      rel-level,
      list-config-args.label-align,
      curr-list-level,
      right,
      n-last: it.children.len(),
    )
    // label-baseline
    let curr-label-baseline = parse-general-args-with-level-n(
      label-baseline,
      rel-level,
      list-config-args.label-baseline,
      curr-list-level,
      0pt,
      n-last: it.children.len(),
    )

    let body = for i in range(len) {
      let child = it.children.at(i)
      let curr-marker = styled-markers.at(i)
      let curr-width = markers-width.at(i)

      let (amount, style) = curr-label-width(i)

      let max-width = if amount == auto { curr-width } else { amount }
      let width = (max-width + curr-indent(i) + curr-body-indent(i)).to-absolute()

      /* list'marker (label) */
      let marker-width = if style == "native" {
        marker-max-width
      } else if amount != auto {
        if style == "default" {
          if curr-width <= amount.to-absolute() { amount } else { curr-width }
        } else if style == "constant" {
          amount
        } else if style == "auto" {
          curr-width //- body-indent
        }
      } else { max-width }

      let curr-text-style = (curr-body-style)(i)

      let curr-text-size = {
        if curr-text-style != none {
          let size = curr-text-style.at("size", default: none)
          if size != none {
            (size: size)
          }
        }
        (:)
      }

      let outer-left-inset = get-block-left-inset(curr-text-size, (curr-body-border.outer)(i))

      let outer = (curr-body-border.outer)(i)

      let outer-inset = if outer != none {
        outer.remove("inset", default: (:))
      } else {
        0pt
      }
      let outer-inset-without-left = parse-inset-without-left(outer-inset)

      // in fact, ltl is not supported yet.
      let inset = if text.dir == rtl { (right: width) } else {
        (left: width + outer-left-inset) + outer-inset-without-left
      }

      // display content
      let layout-block = get_layout-block(
        i,
        len,
        inset,
        enum-below-spacing,
        enum-above-spacing,
        curr-item-spacing(i),
        enum-width(i),
        ..outer,
      )

      let inner-box = make-format-box.with(width: enum-width(i), format-args: (curr-body-border.inner)(i))

      // the item's content to display
      let item-content(body, number-body: none) = (curr-item-format.outer)(i)(layout-block(
        (curr-item-format.inner)(i)(inner-box(
          if number-body == none {
            show-text((curr-body-style)(i), next-show(body))
          } else {
            [

              #fix-first-line#number-body#h(0em, weak: true)#show-text((curr-body-style)(i), next-show(body))
            ]
          },
        )),
      ))

      let curr-checklist-label-baseline = auto
      // re-parse body to support checklist
      let child-body = if curr-checklist {
        let format = checklist-body.at(i)
        if format != false {
          curr-checklist-label-baseline = checklist-label-baseline
          assert(
            curr-checklist-label-baseline in ("center", "top", "bottom", auto),
            message: "The `baseline` of checklist should be: \"center\", \"top\", \"baseline\", or `auto`",
          )
          let func = child.body.func()
          if func == func-styled {
            if format != true {
              format(func(child.body.child.children.slice(3).sum(default: []), child.body.styles))
            } else {
              func(child.body.child.children.slice(3).sum(default: []), child.body.styles)
            }
          } else {
            if format != true {
              format(child.body.children.slice(3).sum(default: []))
            } else {
              child.body.children.slice(3).sum(default: [])
            }
          }
        } else { child.body }
      } else { child.body }

      /*label baseline*/
      let (curr-baseline, same-line-style, base-align, is-alone, label-height) = parse-baseline(
        if curr-checklist-label-baseline != auto { curr-checklist-label-baseline } else { curr-label-baseline(i) },
        curr-marker,
        curr-text-style,
      )


      let pre-inset = h(
        -max-width.to-absolute() - curr-body-indent(i).to-absolute() + curr-label-indent(i).to-absolute(),
      )
      let body-inset = h(curr-body-indent(i).to-absolute())
      let box-width = marker-width.to-absolute()
      /* current label */
      let marker-box(baseline: 0pt, alone: true) = label-box(
        curr-marker,
        box-width,
        curr-baseline,
        pre-inset: pre-inset,
        body-inset: body-inset,
        label-align: curr-label-align(i),
        alone: alone,
        baseline: baseline,
      )


      let inner-left-inset = get-block-left-inset(curr-text-size, (curr-body-border.inner)(i))

      let label-inset = (
        width + get-block-left-inset(curr-text-size, (curr-body-border.whole)(i)) + outer-left-inset
      )

      /*hanging-indent, first-line-indent*/
      set par(
        hanging-indent: curr-hanging-indent(i).to-absolute(),
        first-line-indent: (amount: curr-line-indent(i).to-absolute(), all: true),
      ) if hanging-type == "classic"

      set par(
        hanging-indent: (-max-width - curr-body-indent(i) + curr-hanging-indent(i) - inner-left-inset).to-absolute(),
        first-line-indent: (
          amount: (-max-width - curr-body-indent(i) + curr-line-indent(i) - inner-left-inset).to-absolute(),
          all: true,
        ),
      ) if hanging-type == "paragraph"

      // all the label

      let the-number = if i == 0 {
        display-label(
          marker-box,
          label-inset,
          inner-left-inset,
          same-line-style,
          label-height,
          curr-baseline,
        )
      } else {
        [#h(-inner-left-inset)#marker-box(baseline: curr-baseline)#h(inner-left-inset)#h(0em, weak: true)]
      }


      // parse body (in order to determine how to display label)
      let new-body = rebuild_block-level-elem(
        parse-formatted-body(child-body),
        the-number,
        alignment: base-align,
        auto-margin: enum-width(i) == auto,
        text-size: curr-text-size,
      )

      // record the left inset of the current block-level elems
      parent-item-inset.update(push(inner-left-inset))
      if new-body.inline == none {
        // hold on displaying marker
        let item-inset = parent-item-inset.get()
        parent-number-box.update(push((
          body: marker-box.with(alone: is-alone),
          label-inset: label-inset,
          label-height: label-height,
          item-inset: item-inset,
        )))

        item-content(new-body.body)
        // [||||#parent-item-inset.get()!!!]
      } else {
        parent-number-box.update(())
        parent-item-inset.update(())
        if new-body.inline == true {
          item-content(new-body.body, number-body: [#the-number])
        } else {
          item-content(new-body.body)
        }
      }
    }
    let whole-block = make-format-box.with(format-args: (curr-body-border.whole)(0))
    // body
    (curr-item-format.whole)(0)(whole-block(body))
  }

  label-width-list.update(pop)
  label-width-el.update(pop)
  list-level.update(it => it - 1)
  item-level.update(pop)


  if curr-level == 0 and elem != "enum" {
    state("_default-text-style", (default-text-args,)).update(pop)
    state("_parent-hanging-indent_and_line-indent").update(pop)
  }
}

