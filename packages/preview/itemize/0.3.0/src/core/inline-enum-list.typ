#import "../lib/checklist.typ": character-symbol
#import "../util/numbering.typ": *
#import "../util/text-dir.typ": *

#import "../util/identifier.typ": *
#import "../util/level-state.typ": *
#import "../lib/elem-detect-lib.typ": *
#import "../util/parse-args.typ": *

#import "../lib/id-lib.typ": *
#import "../lib/par-lib.typ": *

#import "../lib/baseline-lib.typ": *

#import "../lib/parize-internal.typ": prevent-parize-recursion-label

#import "../foundation/export-lib.typ": *


/// inline layout of enum
#let inline-enum(
  it,
  elem: ElemType.enum,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  whole-spacing: auto, /**new ver0.3.0, whole-spacing is the new name of enum-spacing ????*/
  hanging-type: HangingType.classic, // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0; enhance for ver0.3.0*/
  checklist: false, /*new ver0.2.0, for list*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  curr-level: 0, // internal
  curr-enum-level: 0, // internal
  curr-list-level: 0, // internal
  curr-abs-enum-level: 0, // internal (not for ver0.3.0)
  curr-abs-list-level: 0, // internal (not for ver0.3.0)
  enum-config: (:), /** config enum only */
  list-config: (:), /** config list only */
  description-config: none, /** description style settting, new ver0.3.0 */
  ref-numbering: none, /** new ver0.3.0  */
  supplement: auto, /** new ver0.3.0 for supplement, (prefix, suffix) and function, */
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  // parent number
  base-parent-number: (), /** internal: new ver0.3.0 */
  // parent box info
  parent-box-info: (), /** internal: new ver0.3.0 */
  parent-fields-info: (), /** internal: new ver0.3.0 */
  enum-level-info: (), /** internal: new ver0.3.0 */
  list-level-info: (), /** internal: new ver0.3.0 */
  ..args,
) = {
  if it.has("label") and it.label == prevent-recursion-label or it.children.len() == 0 {
    return it
  }
  item-level.update(push("enum"))
  enum-level.update(it => it + 1)

  auto-id-state.update(auto-record-id)

  {
    // levels
    // let abs-elem-level = item-level.get().len()
    let abs-enum-level = enum-level.get()
    let curr-abs-enum-level = if auto-base-level { 0 } else { get-auto-value(curr-abs-enum-level, abs-enum-level) }
    let it-enum-level = if auto-base-level { curr-enum-level } else { curr-abs-enum-level }
    let rel-level = if absolute-level { curr-level } else { curr-enum-level }

    let curr-enum-level-info = enum-level-info + (curr-level + 1,) // contains info: curr-enum-level
    let by-level(level) = {
      assert(
        level >= 1 and level <= rel-level,
        message: "Invalid level: The level should be in the range of 1 to "
          + if rel-level >= 1 { str(rel-level) } else { "1" }
          + ".\nBut found: "
          + str(level),
      )
      if absolute-level { level } else { enum-level-info.at(level - 1) }
    }

    let parent-elem-args = (
      get: level => parent-fields-info.at(by-level(level) - 1),
      parent: if rel-level == 0 { (:) } else { parent-fields-info.at(by-level(rel-level) - 1) },
    )

    // for the next show-raw
    let all-args = (
      elem: elem,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      item-spacing: item-spacing,
      hanging-type: hanging-type, // paragraph
      hanging-indent: hanging-indent,
      line-indent: line-indent,
      absolute-level: absolute-level,
      auto-base-level: auto-base-level, /*new ver0.2.0*/
      label-width: label-width, /*new ver0.2.0*/
      body-format: body-format, /*new ver0.2.0*/
      label-format: label-format, /*new ver0.2.0*/
      label-align: label-align, /*new ver0.2.0*/
      label-baseline: label-baseline, /*new ver0.2.0*/
      checklist: checklist, /*new ver0.2.0*/
      func-enum: func-enum,
      func-list: func-list,
      ref-numbering: ref-numbering, /*new ver0.3.0*/
      supplement: supplement, /*new ver0.3.0*/
      tight-mode: tight-mode, /** new ver0.3.0 */
      tight-item-mode: tight-item-mode, /** new ver0.3.0 */
      step: step, /** new ver0.3.0 */
      label-inset: label-inset, /** new ver0.3.0 */
      first-line-inset: first-line-inset, /** new ver0.3.0 */
      // description-config: description-config, /** new ver0.3.0 */
      // body-margin: body-margin, /*new new ver0.3.0*/
      whole-spacing: whole-spacing, /*new new ver0.3.0*/
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level + 1,
      curr-list-level: curr-list-level,
      curr-abs-enum-level: curr-abs-enum-level + 1, // TODO: ??????
      curr-abs-list-level: curr-abs-list-level,
      enum-level-info: curr-enum-level-info,
      list-level-info: list-level-info,
    )

    let next-show(
      // parent number
      base-parent-number: (), /** internal: new ver0.3.0 */
      // parent box info
      parent-box-info: (), /** internal: new ver0.3.0 */
      parent-fields-info: (),
    ) = doc => {
      if elem == ElemType.all {
        show enum: func-enum.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        doc
      } else {
        show enum: func-enum.with(
          ..all-args,
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        doc
      }
    }

    // config enum function
    let enum-config-args = parse-elem-args(elem-args: enum-config)

    // config item function
    let item-config-dic = it.children.map(parse-item-func)

    let for-elem = item-config-dic.at(0).at(item-args.for-elem, default: false)
    assert(type(for-elem) == bool, message: "`for-elem` must be a bool;" + "\nbut found: " + repr(for-elem))
    let get-item-config(key, default: none) = {
      let first = item-config-dic.at(0).at(key, default: default)
      if first != default and for-elem {
        return n => first
      } else {
        return n => item-config-dic.at(n).at(key, default: default)
      }
    }

    // The total number of items
    let len = it.children.len()

    // level item
    let item-absolute = n => item-config-dic.at(n).at("absolute", default: false)
    for n in range(len) {
      let absolute = item-absolute(n)
      assert(type(item-absolute(n)) == bool, message: "`absolute` must be a bool;" + "\nbut found: " + repr(absolute))
    }
    let level-item = n => { if item-absolute(n) { curr-level } else { curr-enum-level } }

    // feat (ver0.3.0): The tag of the current item
    let item-tag = n => item-config-dic.at(n).at(item-args.tag, default: none)
    let item-elem-tag = item-config-dic.at(0).at(item-args.elem-tag, default: none)

    let curr-e-field = it.fields()
    _ = curr-e-field.remove("children")
    let curr-e-args = (e: curr-e-field) // curr-field

    // current item's fields
    let args-with-tags = (tag: item-tag, elem-tag: item-elem-tag, n-last: len, ..curr-e-args)
    let args-with-tags-item = (elem-tag: item-elem-tag, n-last: len, ..curr-e-args)

    let _hanging-type = parse-hanging-type(
      rel-level,
      curr-enum-level,
      level-item(0),
      hanging-type,
      enum-config-args.hanging-type,
      item-config-dic.at(0).at(item-args.hanging-type, default: none),
      args-with-tags-item,
    )

    args-with-tags.insert("hanging-type", _hanging-type)
    args-with-tags-item.insert("hanging-type", _hanging-type)

    // enum's number (label)
    let child-numbers = it.children.map(
      child => {
        if child.has("number") and child.number not in (none, auto) { child.number } else { auto }
      },
    )
    // feat: custom step (enhance enum.reverse)
    // Parse step
    let _step = parse-step(
      rel-level,
      curr-enum-level,
      level-item(0),
      step,
      enum-config-args.step,
      item-config-dic.at(0).at(item-args.step, default: none),
      args-with-tags-item,
    )
    let item-skipped = n => item-config-dic.at(n).at(item-args.skipped, default: false)
    for n in range(len) {
      let skipped = item-skipped(n)
      assert(type(skipped) == bool, message: "`skipped` must be a bool;" + "\nbut found: " + repr(skipped))
    }
    // enum'number
    let numbers = get-enum-numbers(
      _step,
      child-numbers,
      item-skipped,
      start: it.start,
      reversed: it.reversed,
      len: len,
    )

    args-with-tags.insert("number", n => numbers.at(n))
    // args-with-tags-item.insert("number", n => numbers.at(n))

    // ref-numbering
    let (_ref-numbering, _full) = parse-ref-numbering(
      ref-numbering,
      enum-config-args.ref-numbering,
      item-config-dic.at(0).at(item-args.ref-numbering, default: none),
    )
    // supplement
    let _supplement = parse-supplement(
      supplement,
      rel-level,
      enum-config-args.supplement,
      curr-enum-level,
      ..args-with-tags,
    )
    // for reference (config)
    enum-numbering.update(push((
      numbering: it.numbering,
      ref-numbering: _ref-numbering,
      full: if _full != auto { _full } else { it.full },
      auto-base-level: auto-base-level,
      curr-enum-level: curr-enum-level,
      supplement-format: _supplement,
      level-item: level-item,
      ..args-with-tags,
    )))

    // label-format
    let (curr-label-border, curr-label-format) = get-label-format(
      label-format,
      enum-config-args.label-format,
      get-item-config(item-args.label-format),
      rel-level,
      curr-enum-level,
      level-item,
      args-with-tags,
      args-with-tags-item,
    )

    // feat: custom label (enum's number)
    let text-args = get-label-text-args(
      rel-level,
      curr-enum-level,
      level-item,
      text-args: args,
      text-args-elem: enum-config-args.text-args,
      text-args-item: get-item-config("text-args"),
      args-with-tags,
      args-with-tags-item,
    )
    let custom-text = n => body => {
      // need all text-args
      set text(..get_current-text-args(text), ..text-args(n), overhang: false)
      curr-label-format(n)(body)
    }
    let resolved(number) = {
      if it.full {
        if auto-base-level {
          std.numbering(it.numbering, ..base-parent-number.map(e => e.number), number)
        } else {
          std.numbering(it.numbering, ..curr-parent-level.get().map(e => e.number), number)
        }
      } else {
        apply-numbering-kth(
          it.numbering,
          it-enum-level,
          number,
        )
      }
    }

    let item-label-body = n => item-config-dic.at(n).at("body", default: none)
    let styled-numbers = numbers
      .enumerate()
      .map(((i, number)) => {
        let curr-item-label-body = item-label-body(i)
        custom-text(i)({
          if curr-item-label-body == none {
            resolved(number)
          } else {
            curr-item-label-body
          }
        })
      })
    let numbers-width = styled-numbers.map(number => measure(number).width)
    let number-max-width = calc.max(..numbers-width)

    // label-width
    let curr-label-width = get-label-width(
      rel-level,
      curr-enum-level,
      level-item,
      label-width,
      enum-config-args.label-width,
      get-item-config(item-args.label-width),
      number-max-width,
      args-with-tags,
      args-with-tags-item,
    )

    // tight mode
    let (curr-tight-mode, curr-tight-item-mode) = get-tight-mode(
      item-config-dic.at(0).at(item-args.tight-mode, default: none),
      item-config-dic.at(0).at(item-args.tight-item-mode, default: none),
      level-item(0),
      enum-config-args.tight-mode,
      enum-config-args.tight-item-mode,
      curr-enum-level,
      tight-mode,
      tight-item-mode,
      rel-level,
      ..args-with-tags-item,
    )

    // h-spacing
    let (
      curr-indent,
      curr-body-indent,
      curr-label-indent,
      curr-label-inset,
      curr-first-line-inset,
      curr-hanging-indent,
      curr-line-indent,
    ) = get-h-spacing(
      rel-level,
      curr-enum-level,
      level-item,
      indent-default: it.indent,
      body-indent-default: it.body-indent,
      indent,
      body-indent,
      label-indent,
      label-inset,
      first-line-inset,
      hanging-indent,
      line-indent,
      enum-config-args.indent,
      enum-config-args.body-indent,
      enum-config-args.label-indent,
      enum-config-args.label-inset,
      enum-config-args.first-line-inset,
      enum-config-args.hanging-indent,
      enum-config-args.line-indent,
      get-item-config(item-args.indent),
      get-item-config(item-args.body-indent),
      get-item-config(item-args.label-indent),
      get-item-config(item-args.label-inset),
      get-item-config(item-args.first-line-inset),
      get-item-config(item-args.hanging-indent),
      get-item-config(item-args.line-indent),
      args-with-tags,
      args-with-tags-item,
    )

    // v-spacing
    let (elem-above-spacing, elem-below-spacing, curr-item-spacing, curr-auto-item-spacing) = get-v-spacing(
      rel-level,
      curr-enum-level,
      level-item,
      item-spacing,
      whole-spacing,
      enum-config-args.item-spacing,
      enum-config-args.whole-spacing,
      get-item-config(item-args.item-spacing),
      get-item-config(item-args.whole-spacing),
      curr-tight-mode,
      curr-tight-item-mode,
      spacing-default: it.spacing,
      tight: it.tight,
      args-with-tags,
      args-with-tags-item,
    )

    // label-align
    let curr-label-align = parse-general-args-with-level-n(
      label-align,
      rel-level,
      enum-config-args.label-align,
      curr-enum-level,
      end, // TODO
      get-item-config(item-args.label-align),
      level-item,
      ..args-with-tags,
    )

    let same-line-next-list-ID = same-line-next-elem-ID(elem)
    let parse-item-body = it.children.map(child => detect-body-type(
      child.body,
      label-value: same-line-next-list-ID,
      elem: elem,
    ))

    // Used to determine whether the `above` and `below` attributes of `item-spacing` are used in the first and last items
    let pre-item-below-spacing = none

    let first-is-holding

    let text-dir = get-text-dir()
    let dir = text-dir.text-start
    let dir-rev = text-dir.text-end

    // format function
    let (curr-body-border, curr-body-style, curr-body-format) = get-body-format(
      body-format,
      enum-config-args.body-format,
      get-item-config(item-args.body-format),
      rel-level,
      curr-enum-level,
      level-item,
      args-with-tags,
      args-with-tags-item,
    )

    // label length info
    let label-length-info = get-label-length-info(
      len,
      numbers-width,
      styled-numbers,
      curr-label-width,
      number-max-width,
      curr-label-border,
      ..args-with-tags-item,
    )

    let item-body = for i in range(len) {
      let child = it.children.at(i)
      let (
        box-width,
        box-height,
        number-width,
        label-border,
        label-border-align,
        label-width-amount,
        label-height-amount,
      ) = label-length-info.at(i)

      let curr-label-width-args = (label-width: (max: number-max-width, current: box-width))

      // h-spacing: label-indent, label-inset, body-indent, indent
      let _label-indent = curr-label-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _label-inset = curr-label-inset(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _body-indent = curr-body-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _indent = curr-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()

      let h-spacing-args = (
        (
          label-indent: _label-indent,
          label-inset: _label-inset,
          body-indent: _body-indent,
          indent: _indent,
          // body-margin: _body-margin,
        )
          + curr-label-width-args
      )

      let curr-text-style = (curr-body-style)(i)

      let (body, inline) = parse-item-body.at(i)

      // flag: show in same-line (like: 1.a.I.)
      let is-holding = inline == InlineType.list // enum or list

      let is-description = inline == InlineType.description

      let is-same-line-next-list = (
        get-the-next-list-flag(child, label-value: same-line-next-list-ID)
          or it.has("label") and it.label == same-line-next-list-ID
      )

      if i == 0 {
        first-is-holding = is-holding
      }

      let pre-label-cell-width = 0pt
      if not is-same-line-next-list {
        for p in parent-fields-info {
          pre-label-cell-width += p.body-indent + p.label-indent + p.label-width.current + p.indent
        }
      }

      let h-label-align = curr-label-align(i)
      assert(
        type(h-label-align) == alignment,
        message: "`label-align` must be a `alignment` value or `auto`. \nBut found: " + repr(h-label-align),
      )

      let label-box-fix-baseline(
        baseline-inset: 0pt,
      ) = label-box-with-baseline(
        {
          show: disable-par
          styled-numbers.at(i)
        },
        indent: _indent + pre-label-cell-width,
        width: box-width,
        height: box-height,
        label-indent: _label-indent,
        label-inset: _label-inset,
        body-inset: _body-indent,
        label-align: h-label-align,
        // baseline info
        baseline-inset: baseline-inset,
        // baseline-at: baseline-at,
        // label-border format
        ..label-border,
        given-width: label-width-amount,
        given-align: label-border-align,
        given-height: label-height-amount,
        // adjust-width: -start-margin-len,
        dir: dir,
        dir-rev: dir-rev,
      )

      // paragraph spacing: hanging-indent, first-line-indent, line-indent
      let _first-line-inset = curr-first-line-inset(i, ..parent-elem-args, ..h-spacing-args).to-absolute()
      let _temp-line-indent = curr-line-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _line-indent = if _temp-line-indent == auto { auto } else { _temp-line-indent.to-absolute() }
      let _temp-hanging-indent = curr-hanging-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _hanging-indent = if _temp-hanging-indent == auto { auto } else { _temp-hanging-indent.to-absolute() }

      let inner-format(body) = (curr-body-format.inner)(i)({
        show-text((curr-body-style)(i), body)
      })

      // v-spacing: item-spacing, whole-spacing: (elem-above-spacing, elem-below-spacing)
      // feat: item-spacing with above and below
      let _item-spacing = curr-item-spacing(i)
      let (is-full-item-spacing, above-spacing, below-spacing, curr-item-below-spacing) = get-item-spacing(
        i,
        len,
        _item-spacing,
        elem-above-spacing.block,
        elem-below-spacing,
        pre-item-below-spacing,
        curr-auto-item-spacing,
      )

      // TODO
      let par-label-cell-width = 0pt
      for p in parent-fields-info {
        par-label-cell-width += (
          p.body-indent + p.label-indent + p.label-width.current + p.indent
        )
      }

      // process paragraph
      let label-cell-width = if _hanging-type == HangingType.classic {
        box-width + _body-indent + _label-indent + if is-holding { _indent }
      } else {
        0pt
      }
      let process-par(
        doc,
        enable-strong-par: false,
        my-first-line-inset: auto,
        enable-process: false,
        label-cell-inset: -label-cell-width - par-label-cell-width + if not is-holding { -_indent },
      ) = process-body-par(
        doc,
        enable-strong-par: enable-strong-par,
        my-first-line-inset: my-first-line-inset,
        label-cell-inset: label-cell-inset,
        enable-process: enable-process,
        line-indent: _line-indent,
        hanging-indent: _hanging-indent,
        // first-line-inset: _first-line-inset,
        start-normal-par: is-holding,
      )

      let label-cell = label-box-fix-baseline()

      let curr-parent-box-info = {
        if is-same-line-next-list {
          parent-box-info + (label-cell,)
        } else {
          if is-holding {
            (label-cell,)
          } else {
            ()
          }
        }
      }

      let enum-item = {
        // update: parent-level
        let child-number = numbers.at(i)
        curr-parent-level.update(push((n: i, number: child-number)))

        if auto-base-level {
          curr-base-parent-level.update(base-parent-number + ((n: i, number: child-number),))
        }

        {
          show: next-show(
            // is-pre-list: is-holding,
            base-parent-number: base-parent-number + ((n: i, number: child-number),),
            parent-box-info: curr-parent-box-info,
            parent-fields-info: parent-fields-info + (h-spacing-args + curr-e-args + (n: i),),
          )
          inner-format(body)
        }
        curr-parent-level.update(pop)
        if auto-base-level {
          curr-base-parent-level.update(pop)
        }
      }

      if i > 0 {
        if is-full-item-spacing {
          hide-line(height: pre-item-below-spacing, below: above-spacing) // , outset: 2pt, stroke: 1pt + text-args(0).fill
        } else {
          hide-line(above: above-spacing, below: 0pt) // , outset: 3pt, stroke: 1pt + text-args(0).fill
        }
      }
      pre-item-below-spacing = curr-item-below-spacing // update

      let outer-format = (curr-body-format.outer)(i)

      {
        if is-holding {
          show: process-par
          outer-format(enum-item)
        } else {
          show: process-par
          let last
          if curr-parent-box-info.len() > 0 {
            if is-same-line-next-list {
              last = curr-parent-box-info.pop()
              curr-parent-box-info.join()
            } else {
              curr-parent-box-info.join()
            }
          }
          outer-format({
            if not is-same-line-next-list { label-cell } else { last }
            h(_first-line-inset)
            h(0pt, weak: true)
            enum-item
          })
        }
      }

      if i == len - 1 {
        if is-full-item-spacing {
          hide-line(above: 0pt, below: curr-item-below-spacing) // , outset: 3pt, stroke: 1pt + text-args(0).fill
        }
      }
    }

    {
      if not first-is-holding {
        show enum.where(label: prevent-recursion-label): set block(
          ..default-block-args,
          above: elem-above-spacing.block,
          below: 0pt,
          // stroke: text-args(0).fill, // debug
          // // inset: 2pt,
        )
        [#enum(
            numbering: (..) => none,
            indent: 0pt,
            body-indent: 0pt,
            spacing: elem-above-spacing.spacing,
            number-align: end,
          )#prevent-recursion-label]
      }
    }

    (curr-body-format.whole)(0)(
      item-body,
    )
    hide-line(
      above: 0pt,
      below: elem-below-spacing,
      // stroke: text-args(0).fill, // debug
      // inset: 1pt, // debug
      // width: 100%, // debug
    )
  }

  item-level.update(pop)
  enum-level.update(it => it - 1)

  enum-numbering.update(pop)

  auto-id-state.update(auto-pop-id)
}

/// inline layout of list
#let inline-list(
  it,
  elem: ElemType.list,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  whole-spacing: auto, /**new ver0.3.0, whole-spacing is the new name of enum-spacing */
  // body-margin: auto, /*new ver0.3.0, dict: (left, right)*/
  hanging-type: HangingType.classic, // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0; enhance for ver0.3.0*/
  checklist: false, /*new ver0.2.0, for list*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  curr-level: 0, // internal
  curr-enum-level: 0, // internal
  curr-list-level: 0, // internal
  curr-abs-enum-level: 0, // internal (not for ver0.3.0)
  curr-abs-list-level: 0, // internal (not for ver0.3.0)
  enum-config: (:), /** config enum only */
  list-config: (:), /** config list only */
  description-config: none, /** description style settting, new ver0.3.0 */
  ref-numbering: none, /** new ver0.3.0  */
  supplement: auto, /** new ver0.3.0 for supplement, (prefix, suffix) and function, */
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  // parent number
  base-parent-number: (), /** internal: new ver0.3.0 */
  // parent box info
  parent-box-info: (), /** internal: new ver0.3.0 */
  parent-fields-info: (), /** internal: new ver0.3.0 */
  enum-level-info: (), /** internal: new ver0.3.0 */
  list-level-info: (), /** internal: new ver0.3.0 */
  ..args,
) = {
  if it.has("label") and it.label == prevent-recursion-label or it.children.len() == 0 {
    return it
  }

  item-level.update(push("list"))
  list-level.update(it => it + 1)

  {
    // levels
    // let abs-elem-level = item-level.get().len()
    let abs-list-level = list-level.get()
    let curr-abs-list-level = if auto-base-level { 0 } else { get-auto-value(curr-abs-list-level, abs-list-level) }
    let it-list-level = if auto-base-level { curr-list-level } else { curr-abs-list-level }
    let rel-level = if absolute-level { curr-level } else { curr-list-level }

    let curr-list-level-info = list-level-info + (curr-level + 1,) // contains info: curr-list-level
    let by-level(level) = {
      assert(
        level >= 1 and level <= rel-level,
        message: "Invalid level: The level should be in the range of 1 to "
          + if rel-level >= 1 { str(rel-level) } else { "1" }
          + ".\nBut found: "
          + str(level),
      )
      if absolute-level { level } else { list-level-info.at(level - 1) }
    }

    let parent-elem-args = (
      get: level => parent-fields-info.at(by-level(level) - 1),
      parent: if rel-level == 0 { (:) } else { parent-fields-info.at(by-level(rel-level) - 1) },
    )

    // for the next show-raw
    let all-args = (
      elem: elem,
      indent: indent,
      body-indent: body-indent,
      label-indent: label-indent,
      item-spacing: item-spacing,
      hanging-type: hanging-type, // paragraph
      hanging-indent: hanging-indent,
      line-indent: line-indent,
      absolute-level: absolute-level,
      auto-base-level: auto-base-level, /*new ver0.2.0*/
      label-width: label-width, /*new ver0.2.0*/
      body-format: body-format, /*new ver0.2.0*/
      label-format: label-format, /*new ver0.2.0*/
      // item-format: item-format, /*new ver0.2.0, not be used for ver0.3.0*/
      label-align: label-align, /*new ver0.2.0*/
      label-baseline: label-baseline, /*new ver0.2.0*/
      checklist: checklist, /*new ver0.2.0*/
      func-enum: func-enum,
      func-list: func-list,
      ref-numbering: ref-numbering, /*new ver0.3.0*/
      supplement: supplement, /*new ver0.3.0*/
      tight-mode: tight-mode, /** new ver0.3.0 */
      tight-item-mode: tight-item-mode, /** new ver0.3.0 */
      step: step, /** new ver0.3.0 */
      label-inset: label-inset, /** new ver0.3.0 */
      first-line-inset: first-line-inset, /** new ver0.3.0 */
      // description-config: description-config, /** new ver0.3.0 */
      // body-margin: body-margin, /*new new ver0.3.0*/
      whole-spacing: whole-spacing, /*new new ver0.3.0*/
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level,
      curr-list-level: curr-list-level + 1,
      curr-abs-enum-level: curr-abs-enum-level,
      curr-abs-list-level: curr-abs-list-level + 1,
      enum-level-info: enum-level-info,
      list-level-info: curr-list-level-info,
    )

    let next-show(
      // parent number
      base-parent-number: (), /** internal: new ver0.3.0 */
      // parent box info
      parent-box-info: (), /** internal: new ver0.3.0 */
      parent-fields-info: (),
    ) = doc => {
      if elem == ElemType.all {
        show enum: func-enum.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        doc
      } else {
        show list: func-list.with(
          ..all-args,
          ..args,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        doc
      }
    }

    // format list function
    let list-config-args = parse-elem-args(elem-args: list-config)

    // config item function
    let item-config-dic = it.children.map(parse-item-func)

    let for-elem = item-config-dic.at(0).at(item-args.for-elem, default: false)
    assert(type(for-elem) == bool, message: "`for-elem` must be a bool;" + "\nbut found: " + repr(for-elem))
    let get-item-config(key, default: none) = {
      let first = item-config-dic.at(0).at(key, default: default)
      if first != default and for-elem {
        return n => first
      } else {
        return n => item-config-dic.at(n).at(key, default: default)
      }
    }

    // The total number of items
    let len = it.children.len()

    // level item
    let item-absolute = n => item-config-dic.at(n).at(item-args.absolute, default: false)
    for n in range(len) {
      let absolute = item-absolute(n)
      assert(
        type(item-absolute(n)) == bool,
        message: "`absolute` must be a bool;" + "\nbut found: " + repr(absolute),
      )
    }
    let level-item = n => { if item-absolute(n) { curr-level } else { curr-enum-level } }

    // feat (ver0.3.0): The tag of the current item
    let item-tag = n => item-config-dic.at(n).at(item-args.tag, default: none)
    let item-elem-tag = item-config-dic.at(0).at(item-args.elem-tag, default: none)

    let curr-e-field = it.fields()
    _ = curr-e-field.remove("children")
    let curr-e-args = (e: curr-e-field) // curr-field

    // current item's fields
    let args-with-tags = (tag: item-tag, elem-tag: item-elem-tag, n-last: len, ..curr-e-args)
    let args-with-tags-item = (elem-tag: item-elem-tag, n-last: len, ..curr-e-args)

    let _hanging-type = parse-hanging-type(
      rel-level,
      curr-list-level,
      level-item(0),
      hanging-type,
      list-config-args.hanging-type,
      item-config-dic.at(0).at(item-args.hanging-type, default: none),
      args-with-tags-item,
    )

    args-with-tags.insert("hanging-type", _hanging-type)
    args-with-tags-item.insert("hanging-type", _hanging-type)

    // label-format
    let (curr-label-border, curr-label-format) = get-label-format(
      label-format,
      list-config-args.label-format,
      get-item-config(item-args.label-format),
      rel-level,
      curr-list-level,
      level-item,
      args-with-tags,
      args-with-tags-item,
    )

    //feat: custom label (list's marker)
    let text-args = get-label-text-args(
      rel-level,
      curr-list-level,
      level-item,
      text-args: args,
      text-args-elem: list-config-args.text-args,
      text-args-item: get-item-config("text-args"),
      args-with-tags,
      args-with-tags-item,
    )
    let custom-text = n => body => {
      // need all text-args
      set text(..get_current-text-args(text), ..text-args(n), overhang: false)
      curr-label-format(n)(body)
    }

    let setting-from-checklist = setting-checklist.get()
    let checklist-info = parse-checklist(
      rel-level,
      curr-list-level,
      checklist,
      setting-from-checklist,
      character-symbol,
    )

    let same-line-next-list-ID = same-line-next-elem-ID(elem)
    // parse each item's body
    let parse-item-body = it.children.map(child => detect-body-type(
      child.body,
      label-value: same-line-next-list-ID,
      elem: elem,
      ..checklist-info,
    ))

    let marker = {
      if type(it.marker) == array {
        if it.marker == () {
          it.marker
        } else {
          it.marker.at(calc.rem(it-list-level, it.marker.len()))
        }
      } else {
        it.marker
      }
    }

    let get-marker = n => {
      //feat: checklist
      let desc-marker = parse-item-body.at(n).at("checklist", default: none)
      if desc-marker != none {
        return desc-marker.checklist-marker
      }
      let desc = item-config-dic.at(n).at("body", default: none)
      if desc != none {
        return desc
      }

      if type(marker) == function {
        let temp = marker(it-list-level)
        if type(temp) == function {
          // form: n => value
          return temp(n)
        } else if type(temp) == array {
          return get-array-value(temp, n)
        } else {
          return temp
        }
      } else {
        return marker
      }
    }

    args-with-tags.insert("marker", get-marker)
    // args-with-tags-item.insert("marker", get-marker)

    let styled-markers = range(len).map(i => custom-text(i)((get-marker(i))))

    let markers-width = styled-markers.map(marker => measure(marker).width)
    let marker-max-width = calc.max(..markers-width)

    // label-width
    let curr-label-width = get-label-width(
      rel-level,
      curr-list-level,
      level-item,
      label-width,
      list-config-args.label-width,
      get-item-config(item-args.label-width),
      marker-max-width,
      args-with-tags,
      args-with-tags-item,
    )

    // tight mode
    let (curr-tight-mode, curr-tight-item-mode) = get-tight-mode(
      item-config-dic.at(0).at(item-args.tight-mode, default: none),
      item-config-dic.at(0).at(item-args.tight-item-mode, default: none),
      level-item(0),
      list-config-args.tight-mode,
      list-config-args.tight-item-mode,
      curr-list-level,
      tight-mode,
      tight-item-mode,
      rel-level,
      ..args-with-tags-item,
    )

    // h-spacing
    let (
      curr-indent,
      curr-body-indent,
      curr-label-indent,
      curr-label-inset,
      curr-first-line-inset,
      curr-hanging-indent,
      curr-line-indent,
    ) = get-h-spacing(
      rel-level,
      curr-list-level,
      level-item,
      indent-default: it.indent,
      body-indent-default: it.body-indent,
      indent,
      body-indent,
      label-indent,
      label-inset,
      first-line-inset,
      hanging-indent,
      line-indent,
      list-config-args.indent,
      list-config-args.body-indent,
      list-config-args.label-indent,
      list-config-args.label-inset,
      list-config-args.first-line-inset,
      list-config-args.hanging-indent,
      list-config-args.line-indent,
      get-item-config(item-args.indent),
      get-item-config(item-args.body-indent),
      get-item-config(item-args.label-indent),
      get-item-config(item-args.label-inset),
      get-item-config(item-args.first-line-inset),
      get-item-config(item-args.hanging-indent),
      get-item-config(item-args.line-indent),
      args-with-tags,
      args-with-tags-item,
    )

    // v-spacing
    let (elem-above-spacing, elem-below-spacing, curr-item-spacing, curr-auto-item-spacing) = get-v-spacing(
      rel-level,
      curr-list-level,
      level-item,
      item-spacing,
      whole-spacing,
      list-config-args.item-spacing,
      list-config-args.whole-spacing,
      get-item-config(item-args.item-spacing),
      get-item-config(item-args.whole-spacing),
      curr-tight-mode,
      curr-tight-item-mode,
      spacing-default: it.spacing,
      tight: it.tight,
      args-with-tags,
      args-with-tags-item,
    )

    // label-align
    let curr-label-align = parse-general-args-with-level-n(
      label-align,
      rel-level,
      list-config-args.label-align,
      curr-list-level,
      end,
      get-item-config(item-args.label-align),
      level-item,
      ..args-with-tags,
    )

    let pre-item-below-spacing = none
    let first-is-holding

    // format function
    let (curr-body-border, curr-body-style, curr-body-format) = get-body-format(
      body-format,
      list-config-args.body-format,
      get-item-config(item-args.body-format),
      rel-level,
      curr-list-level,
      level-item,
      args-with-tags,
      args-with-tags-item,
    )

    // label length info
    let label-length-info = get-label-length-info(
      len,
      markers-width,
      styled-markers,
      curr-label-width,
      marker-max-width,
      curr-label-border,
      ..args-with-tags-item,
    )

    let text-dir = get-text-dir()
    let dir = text-dir.text-start
    let dir-rev = text-dir.text-end

    let item-body = for i in range(len) {
      let child = it.children.at(i)
      let (
        box-width,
        box-height,
        number-width,
        label-border,
        label-border-align,
        label-width-amount,
        label-height-amount,
      ) = label-length-info.at(i)

      let curr-label-width-args = (label-width: (max: marker-max-width, current: box-width))

      // h-spacing: label-indent, label-inset, body-indent, indent
      let _label-indent = curr-label-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _label-inset = curr-label-inset(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _body-indent = curr-body-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()
      let _indent = curr-indent(i, ..curr-label-width-args, ..parent-elem-args).to-absolute()

      let h-spacing-args = (
        (
          label-indent: _label-indent,
          label-inset: _label-inset,
          body-indent: _body-indent,
          indent: _indent,
        )
          + curr-label-width-args
      )

      let curr-text-style = (curr-body-style)(i)

      let (body, inline, ..checklist-item) = parse-item-body.at(i)
      let checklist-format = if checklist-item != (:) {
        let checklist = checklist-item.at("checklist", default: none)
        if checklist != none {
          checklist.checklist-format
        }
      }

      let is-holding = inline == InlineType.list // enum or list

      let is-description = inline == InlineType.description

      let is-same-line-next-list = (
        get-the-next-list-flag(child, label-value: same-line-next-list-ID)
          or it.has("label") and it.label == same-line-next-list-ID
      )

      if i == 0 {
        first-is-holding = is-holding
      }

      let pre-label-cell-width = 0pt
      if not is-same-line-next-list {
        for p in parent-fields-info {
          pre-label-cell-width += p.body-indent + p.label-indent + p.label-width.current + p.indent
        }
      }

      let h-label-align = curr-label-align(i)
      assert(
        type(h-label-align) == alignment,
        message: "`label-align` must be a `alignment` value or `auto`. \nBut found: " + repr(h-label-align),
      )

      let label-box-fix-baseline(
        baseline-inset: 0pt,
      ) = label-box-with-baseline(
        {
          show: disable-par
          styled-markers.at(i)
        },
        indent: _indent + pre-label-cell-width,
        width: box-width,
        height: box-height,
        label-indent: _label-indent,
        label-inset: _label-inset,
        body-inset: _body-indent,
        label-align: h-label-align,
        // baseline info
        baseline-inset: baseline-inset,
        // baseline-at: baseline-at,
        // label-border format
        ..label-border,
        given-width: label-width-amount,
        given-align: label-border-align,
        given-height: label-height-amount,
        // adjust-width: -start-margin-len,
        dir: dir,
        dir-rev: dir-rev,
      )

      // paragraph spacing: hanging-indent, first-line-indent, line-indent
      let _first-line-inset = curr-first-line-inset(i, ..parent-elem-args, ..h-spacing-args).to-absolute()
      let _temp-line-indent = curr-line-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _line-indent = if _temp-line-indent == auto { auto } else { _temp-line-indent.to-absolute() }
      let _temp-hanging-indent = curr-hanging-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _hanging-indent = if _temp-hanging-indent == auto { auto } else { _temp-hanging-indent.to-absolute() }

      let inner-format(body) = (curr-body-format.inner)(i)({
        show-text((curr-body-style)(i), {
          if checklist-format != none {
            checklist-format(body)
          } else {
            body
          }
        })
      })

      // v-spacing: item-spacing, whole-spacing: (elem-above-spacing, elem-below-spacing)
      // feat: item-spacing with above and below
      let _item-spacing = curr-item-spacing(i)
      let (is-full-item-spacing, above-spacing, below-spacing, curr-item-below-spacing) = get-item-spacing(
        i,
        len,
        _item-spacing,
        elem-above-spacing.block,
        elem-below-spacing,
        pre-item-below-spacing,
        curr-auto-item-spacing,
      )

      // TODO
      let par-label-cell-width = 0pt
      for p in parent-fields-info {
        par-label-cell-width += (
          p.body-indent + p.label-indent + p.label-width.current + p.indent
        )
      }

      // process paragraph
      let label-cell-width = if _hanging-type == HangingType.classic {
        box-width + _body-indent + _label-indent + if is-holding { _indent }
      } else {
        0pt
      }
      let process-par(
        doc,
        enable-strong-par: false,
        my-first-line-inset: auto,
        enable-process: false,
        label-cell-inset: -label-cell-width - par-label-cell-width + if not is-holding { -_indent },
      ) = process-body-par(
        doc,
        enable-strong-par: enable-strong-par,
        my-first-line-inset: my-first-line-inset,
        label-cell-inset: label-cell-inset,
        enable-process: enable-process,
        line-indent: _line-indent,
        hanging-indent: _hanging-indent,
        // first-line-inset: _first-line-inset,
        start-normal-par: is-holding,
      )

      let label-cell = label-box-fix-baseline()

      let curr-parent-box-info = {
        if is-same-line-next-list {
          parent-box-info + (label-cell,)
        } else {
          if is-holding {
            (label-cell,)
          } else {
            ()
          }
        }
      }
      let list-item = {
        show: next-show(
          base-parent-number: base-parent-number,
          parent-box-info: curr-parent-box-info,
          parent-fields-info: parent-fields-info + (h-spacing-args + curr-e-args + (n: i),),
        )
        inner-format(body)
      }

      if i > 0 {
        if is-full-item-spacing {
          hide-line(height: pre-item-below-spacing, below: above-spacing)
        } else {
          hide-line(above: above-spacing, below: 0pt)
        }
      }
      pre-item-below-spacing = curr-item-below-spacing // update

      let outer-format = (curr-body-format.outer)(i)

      {
        if is-holding {
          show: process-par
          outer-format(list-item)
        } else {
          show: process-par
          let last
          if curr-parent-box-info.len() > 0 {
            if is-same-line-next-list {
              last = curr-parent-box-info.pop()
              curr-parent-box-info.join()
            } else {
              curr-parent-box-info.join()
            }
          }
          outer-format({
            if not is-same-line-next-list { label-cell } else { last }
            h(_first-line-inset)
            h(0pt, weak: true)
            list-item
          })
        }
      }

      if i == len - 1 {
        if is-full-item-spacing {
          hide-line(above: 0pt, below: curr-item-below-spacing)
        }
      }
    }

    {
      if not first-is-holding {
        show enum.where(label: prevent-recursion-label): set block(
          ..default-block-args,
          above: elem-above-spacing.block,
          below: 0pt,
        )
        [#enum(
            numbering: (..) => none,
            indent: 0pt,
            body-indent: 0pt,
            spacing: elem-above-spacing.spacing,
            number-align: end,
          )#prevent-recursion-label]
      }
    }

    (curr-body-format.whole)(0)(
      item-body,
    )
    hide-line(
      above: 0pt,
      below: elem-below-spacing,
    )
  }
  item-level.update(pop)
  list-level.update(it => it - 1)
}
