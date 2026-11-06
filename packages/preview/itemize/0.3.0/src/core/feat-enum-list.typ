// #import "fix-enum-list.typ": *
// #import "inline-enum-list.typ": *
#import "../lib/resume-lib.typ" as rl
#import "../lib/label-width-lib.typ" as lw


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

#import "../foundation/auto-resume.typ": *

/// Ver0.3.0: Reimplement lists using a new layout method
/// Support additional features: auto-label-width, auto-resuming
#let feat-enum(
  it,
  elem: ElemType.enum,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  whole-spacing: auto, /**new ver0.3.0, whole-spacing is the new name of enum-spacing */
  body-margin: auto, /*new ver0.3.0, dict: (left, right)*/
  hanging-type: HangingType.classic, // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  // item-format: none, /*new ver0.2.0, not be used for ver0.3.0*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0; enhance for ver0.3.0*/
  checklist: false, /*new ver0.2.0, for list*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  is-pre-list: false, // TODO
  is-prior-label-v-align: false, // internal
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

  auto-resuming: none, /*new ver0.2.0*/
  auto-label-width: none, /*new ver0.2.0*/
  ..args,
) = {
  if it.has("label") and it.label == prevent-recursion-label or it.children.len() == 0 {
    return it
  }
  item-level.update(push("enum"))
  enum-level.update(it => it + 1)

  auto-id-state.update(auto-record-id)

  //feat: resume a list
  rl.update_resume-level(it => it + 1)

  lw.update-auto_label-level(it => it + 1)
  lw.update-global_label-level(it => it + 1)

  {
    // levels
    let abs-elem-level = item-level.get().len()
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
      hanging-type: hanging-type, // classic paragraph; for ver0.3.0, expose to user
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
      description-config: description-config, /** new ver0.3.0 */
      body-margin: body-margin, /*new new ver0.3.0*/
      whole-spacing: whole-spacing, /*new new ver0.3.0*/
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level + 1,
      curr-list-level: curr-list-level,
      curr-abs-enum-level: curr-abs-enum-level + 1, // TODO: ??????
      curr-abs-list-level: curr-abs-list-level,
      enum-level-info: curr-enum-level-info,
      list-level-info: list-level-info,

      auto-resuming: auto-resuming, /*new ver0.2.0*/
      auto-label-width: auto-label-width, /*new ver0.2.0*/
    )
    let next-show(
      is-prior-label-v-align: false,
      is-pre-list: false,
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
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        doc
      } else {
        show enum: func-enum.with(
          ..all-args,
          ..args,
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
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

    // feat: hanging-type
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

    // Parse step
    let _step = parse-general-args-with-level(
      step,
      rel-level,
      enum-config-args.step,
      curr-enum-level,
      ..args-with-tags-item,
    )

    // feat: resume a list
    let cur-resume = auto
    if auto-resuming != none {
      let curr-auto-resuming = parse-auto-resume(rel-level, auto-resuming, ..args-with-tags-item)
      rl.restart_resuming()
      if it.start == auto {
        let key-label = rl.resume-label-list.get()
        let target-enum = get-target-enum(key-label)
        cur-resume = if target-enum != none {
          // label-case
          let dic = rl.item-counter-dic.at(target-enum)
          // let target-level = item-level.at(target-enum).len() - 1 // absolute level;
          // let increment = abs-enum-level - curr-level // TODO
          let dic-level = dic.level
          dic.counter.at(dic-level - 1, default: auto)
        } else if curr-auto-resuming == true {
          // auto-case (using *-enum)
          let dic = rl.item-counter-dic.get()
          dic.counter.at(dic.level, default: auto)
        } else if rl.resume-list.get() {
          // auto-resume-enum
          curr-auto-resuming = true
          let dic = rl.item-counter-dic.get()
          dic.counter.at(dic.level, default: auto)
        } else {
          // sublist case
          let resume-sublist = auto-resuming-form.get()
          if resume-sublist != none {
            let (form, current-level, current-enum-level) = resume-sublist
            // use the enum's absolute level
            let form-level = if absolute-level { abs-elem-level - current-level } else {
              abs-enum-level - current-enum-level
            }
            let curr-form = parse-auto-resume-form(form, form-level, ..args-with-tags-item)
            if curr-form != none {
              if curr-form {
                curr-auto-resuming = true
                let dic = rl.item-counter-dic.get()
                dic.counter.at(dic.level, default: auto)
              } else {
                auto
              }
            } else {
              auto
            }
          } else { auto }
        }
      }
      rl.init_resuming-number(it.start, curr-auto-resuming)
    }

    let item-skipped = n => item-config-dic.at(n).at(item-args.skipped, default: false)
    for n in range(len) {
      let skipped = item-skipped(n)
      assert(type(skipped) == bool, message: "`skipped` must be a bool;" + "\nbut found: " + repr(skipped))
    }
    let cur = if it.start == auto { if cur-resume != auto { cur-resume + 1 } else { auto } } else { it.start }
    // enum'number
    let numbers = get-enum-numbers(
      _step,
      child-numbers,
      item-skipped,
      start: cur,
      reversed: it.reversed,
      len: len,
    )
    if auto-resuming != none {
      for number in numbers {
        rl.update_resuming-number(number)
      }
    }
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

    // feat: auto-label-width
    if auto-label-width != none {
      if auto-label-width == auto {
        let curr-max-width-label = lw.max-width-label.get()
        if curr-max-width-label.unlock {
          let (form, current-level, current-enum-level) = width-label-form.get()
          let form-level = if absolute-level { abs-elem-level - current-level } else {
            abs-enum-level - current-enum-level
          }
          let curr-form = parse-auto-label(form, form-level, ..args-with-tags-item)
          // "each" (default), "all", "only enum or list"
          if auto-label-elem(curr-form, "enum") {
            lw.update-auto_width-label-dic(number-max-width, "enum")
            let locate-end = selector(metadata.where(value: enum-label-ID, label: label(auto-label-ID))).after(here())
            let sel = query(locate-end)
            if sel.len() > 0 {
              let dic = lw.max-width-label.at(sel.first().location())
              let c-level = curr-max-width-label.level
              let width-dic = dic.width.at(c-level, default: lw.default-width)
              number-max-width = if curr-form == AutoLabelWidth.all {
                calc.max(width-dic.list, width-dic.enum)
              } else {
                width-dic.enum
              }
            }
          }
        }
      } else {
        let curr-auto-label = parse-auto-label(auto-label-width, rel-level, ..args-with-tags-item)
        if auto-label-elem(curr-auto-label, "enum") {
          lw.update-global_width-label-dic(number-max-width, "enum")
          let locate-end = selector(metadata.where(value: global-auto-label-ID)).after(here())
          let sel = query(locate-end)
          if sel.len() > 0 {
            let dic = lw.max-width-label-global.at(sel.first().location())
            let width-dic = dic.width.at(rel-level, default: lw.default-width)
            number-max-width = if curr-auto-label == AutoLabelWidth.all {
              calc.max(width-dic.list, width-dic.enum)
            } else {
              width-dic.enum
            }
          }
        }
      }
    }

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

    // body-margin
    let curr-body-margin = get-body-margin(
      rel-level,
      curr-enum-level,
      level-item,
      body-margin,
      enum-config-args.body-margin,
      get-item-config(item-args.body-margin),
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
      end,
      get-item-config(item-args.label-align),
      level-item,
      ..args-with-tags,
    )

    // label-baseline
    let curr-label-baseline = parse-general-args-with-level-n(
      label-baseline,
      rel-level,
      enum-config-args.label-baseline,
      curr-enum-level,
      0pt,
      get-item-config(item-args.label-baseline),
      level-item,
      ..args-with-tags,
    )

    let same-line-next-list-ID = same-line-next-elem-ID(elem)
    let parse-item-body = it.children.map(child => detect-body-type(
      child.body,
      label-value: same-line-next-list-ID,
      elem: elem,
    ))

    let setting-from-checklist = setting-checklist.get()
    let checklist-info = parse-checklist(
      rel-level,
      curr-enum-level,
      checklist,
      setting-from-checklist,
      character-symbol,
    )

    // description setting
    let desc-items = parse-item-body.map(it => {
      let item = it.at("desc", default: none)
      if item != none {
        item.fields()
      }
    })
    let (
      desc-dic,
      term-format,
      description-format,
      desc-style,
      desc-term-width,
      desc-format,
    ) = get-description-setting(
      description-config,
      enum-config-args.description-config,
      get-item-config(item-args.description-config),
      rel-level,
      curr-enum-level,
      level-item,
      ..args-with-tags,
    )

    let description-info = parse-description(
      desc-items: desc-items,
      format-dic: desc-dic,
      term-format: term-format,
      description-format: description-format,
      desc-style: desc-style,
      term-width: desc-term-width,
      checklist-args: checklist-info,
    )

    let text-dir = get-text-dir()
    let dir = text-dir.text-start
    let dir-rev = text-dir.text-end

    let process-description = process-terms-item.with(
      desc-info: description-info,
      format: desc-format,
      dir: dir,
      dir-rev: dir-rev,
    )

    // Used to determine whether the `above` and `below` attributes of `item-spacing` are used in the first and last items
    let pre-item-below-spacing = none

    let min-indent = float.inf * 1pt

    let min-end-margin-abs = float.inf * 1pt
    let min-end-margin-ratio = float.inf * 1%

    // format function
    // Limits: For curr-body-format (outer, whole), if it modifies font size (such as using upper, text.size, strong, etc.), it will affect the width of label content, causing incorrect display. One solution is to apply label-format again if such styles are present.
    // In itemize, we do not directly apply the styles from curr-body-format (outer, whole) to the label and then test its height and width (this remains impractical because it affects the entire item (label + body), and we are uncertain about the effects when these styles are applied only to the label).
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

    let whole-border = (curr-body-border.whole)(0)
    let whole-inset = whole-border.at("inset", default: (:))
    // only deal with length
    let _whole-top-inset = get-dir-inset(whole-inset, dir: "top")
    assert(
      type(_whole-top-inset) == length,
      message: "Expected a `length` value. \nBut found: " + repr(_whole-top-inset) + ".",
    )
    let whole-top-inset = _whole-top-inset.to-absolute()

    // current block args
    let curr-block-args = get-current-block-args(block)

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

    // each item
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
      if _indent < min-indent { min-indent = _indent }

      // parse body-margin
      let _body-margin = curr-body-margin(i, ..curr-label-width-args, ..parent-elem-args)

      let start-margin = _body-margin.at(dir)

      let end-margin = _body-margin.at(dir-rev)
      end-margin = get-auto-value(end-margin, 0pt)
      let (end-margin-ratio, end-margin-abs) = parse-relative(end-margin)
      end-margin-abs = end-margin-abs.to-absolute()
      if end-margin-ratio < min-end-margin-ratio { min-end-margin-ratio = end-margin-ratio }
      if end-margin-abs < min-end-margin-abs { min-end-margin-abs = end-margin-abs }

      let start-margin-len = if start-margin == auto {
        number-width.width - number-width.amount
      } else {
        let (start-margin-ratio, start-margin-abs) = parse-relative(start-margin)
        let label-start-margin-inset = box-width + _label-indent + _body-indent
        (
          label-start-margin-inset - (label-start-margin-inset * start-margin-ratio + start-margin-abs.to-absolute())
        )
      }

      let h-spacing-args = (
        (
          label-indent: _label-indent,
          label-inset: _label-inset,
          body-indent: _body-indent,
          indent: _indent,
          body-margin: _body-margin,
        )
          + curr-label-width-args
      )

      // outer-border
      let outer-border = (curr-body-border.outer)(i)
      let outer-outset = outer-border.remove("outset", default: (:))
      let outer-dir-outset = get-dir-inset(outer-outset, dir: dir)
      outer-outset = parse-inset-without-dir(outer-outset, dir: dir)
      outer-outset.insert(dir, -_indent + outer-dir-outset)

      // inner-border
      let inner-border = (curr-body-border.inner)(i)
      let inner-inset = inner-border.at("inset", default: (:))

      let _inner-top-inset = get-dir-inset(inner-inset, dir: "top")
      assert(
        type(_inner-top-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-top-inset),
      )
      let inner-top-inset = _inner-top-inset.to-absolute()
      let _inner-bottom-inset = get-dir-inset(inner-inset, dir: "bottom")
      assert(
        type(_inner-bottom-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-bottom-inset),
      )
      let inner-bottom-inset = _inner-bottom-inset.to-absolute()

      let _inner-dir-inset = get-dir-inset(inner-inset, dir: dir)
      assert(
        type(_inner-dir-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-dir-inset),
      )
      let inner-dir-inset = _inner-dir-inset.to-absolute()

      let outer-inset = outer-border.remove("inset", default: (:))
      let _outer-top-inset = get-dir-inset(outer-inset, dir: "top")
      assert(
        type(_outer-top-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_outer-top-inset),
      )
      let outer-top-inset = _outer-top-inset.to-absolute()

      // deal with: end body margin
      if end-margin-abs != 0pt or end-margin-ratio != 0% {
        let outer-dir-rev-inset = get-dir-inset(outer-inset, dir: dir-rev)
        outer-inset = parse-inset-without-dir(outer-inset, dir: dir-rev)
        outer-inset.insert(dir-rev, outer-dir-rev-inset + end-margin)

        let outer-dir-rev-outset = get-dir-inset(outer-outset, dir: dir-rev)
        outer-outset = parse-inset-without-dir(outer-outset, dir: dir-rev)
        outer-outset.insert(dir-rev, outer-dir-rev-outset - end-margin)
      }

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

      //label baseline (label-v-spacing)
      let (
        curr-baseline,
        same-line-style, // need further process
        base-align, /*ver0.3.0: different meaning*/
        impact-first-line, /*ver0.3.0:  only for current label*/
        baseline-at, /*ver0.3.0*/
      ) = parse-baseline(
        curr-label-baseline(i),
        curr-text-style,
        label-height: box-height,
      )
      if impact-first-line == auto {
        impact-first-line = _hanging-type == HangingType.paragraph
      }

      // consider whether the label has baseline (not for ver0.3.0)
      // if base-align == none {
      //   let (box-baseline, ..) = get-baseline-inset-in-box({
      //     styled-child-number
      //     block(height: 0pt, below: 0pt, above: 0.01pt)
      //   })
      //   if box-baseline == 0pt {
      //     base-align = top
      //   }
      // }

      let (body, inline) = parse-item-body.at(i)

      // flag: show in same-line (like: 1.a.I.)
      let is-holding = inline == InlineType.list // enum or list
      let is-description = inline == InlineType.description
      let is-same-line-style = is-holding and (same-line-style != auto)
      if is-same-line-style {
        baseline-at = auto
        curr-baseline = 0pt
      }

      let h-label-align = curr-label-align(i)
      assert(
        type(h-label-align) == alignment,
        message: "`label-align` must be a `alignment` value or `auto`. \nBut found: " + repr(h-label-align),
      )

      // current label
      let label-box-fix-baseline(
        baseline-inset: 0pt,
      ) = label-box-with-baseline(
        styled-numbers.at(i),
        indent: _indent,
        width: box-width,
        height: box-height,
        label-indent: _label-indent,
        label-inset: _label-inset,
        body-inset: _body-indent,
        label-align: h-label-align,
        // baseline info
        baseline-inset: baseline-inset,
        baseline-at: baseline-at,
        // label-border format
        ..label-border,
        given-width: label-width-amount,
        given-align: label-border-align,
        given-height: label-height-amount,
        adjust-width: -start-margin-len,
        dir: dir,
        dir-rev: dir-rev,
      )

      // paragraph spacing: hanging-indent, first-line-indent, line-indent
      let _first-line-inset = curr-first-line-inset(i, ..parent-elem-args, ..h-spacing-args).to-absolute()
      let _temp-line-indent = curr-line-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _line-indent = if _temp-line-indent == auto { auto } else { _temp-line-indent.to-absolute() }
      let _temp-hanging-indent = curr-hanging-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _hanging-indent = if _temp-hanging-indent == auto { auto } else { _temp-hanging-indent.to-absolute() }

      let curr-whole-top-inset = if i == 0 { whole-top-inset } else { 0pt }

      let curr-base-align = if (it.number-align).y != none {
        (it.number-align).y
      } else {
        if not is-same-line-style { base-align } else { same-line-style.base-align }
      }

      // measure label baseline (formatted-with-border)
      let (above-height, below-height) = {
        // if is-same-line is true, in this case the label is aligned to the top for the native lists.
        let at = if not is-same-line-style { auto } else { baseline-at }
        if at == auto {
          let origin-label-box = label-box-fix-baseline()
          let (box-baseline, ..) = get-baseline-inset-in-box(origin-label-box)
          let given-label-baseline = box-baseline + curr-baseline

          get-baseline-at-auto(at: auto, height: box-height, baseline: given-label-baseline)
        } else {
          get-baseline-at-auto(at: at, height: box-height)
        }
      }

      let label-tag = v-line-tag(height: above-height + below-height, baseline: below-height) // for first-line (impact-first-line)

      let inner-block(body) = if (
        inner-border != (:) and inline != InlineType.blank
      ) {
        show pad.where(label: prevent-recursion-label): set block(
          ..default-block-args,
          ..inner-border,
          width: auto, // TODO
          // fill: gray,
        )
        [#pad(rest: 0pt, {
            show pad.where(label: prevent-recursion-label): set block(
              ..default-block-args,
            )
            set block(..default-block-args)
            set block(..curr-block-args)
            body
          })#prevent-recursion-label]
      } else {
        body
      }
      let inner-format(body) = (curr-body-format.inner)(i)({
        inner-block(show-text((curr-body-style)(i), body))
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
      pre-item-below-spacing = curr-item-below-spacing // update

      let out-spacing = { (above: if i == 0 and is-pre-list { auto } else { above-spacing }, below: below-spacing) }

      // process paragraph
      let label-cell-width = if _hanging-type == HangingType.classic { 0pt } else {
        box-width + _body-indent + _label-indent - start-margin-len + inner-dir-inset
      }

      // TODO: enable-process???
      let process-par(
        doc,
        enable-strong-par: false,
        my-first-line-inset: auto,
        enable-process: false,
        label-cell-inset: label-cell-width,
      ) = process-body-par(
        doc,
        enable-strong-par: enable-strong-par,
        my-first-line-inset: my-first-line-inset,
        label-cell-inset: label-cell-inset,
        start-margin-len: start-margin-len,
        enable-process: enable-process, // TODO
        line-indent: _line-indent,
        hanging-indent: _hanging-indent,
        first-line-inset: _first-line-inset,
        start-normal-par: is-holding,
        label-tag: if impact-first-line { label-tag },
      )

      let item-content = {
        // feat: description list
        show: process-description(
          start-margin: start-margin-len,
          process-par: process-par.with(
            label-cell-inset: 0pt,
          ),
        )(i)
        body
      }

      let is-same-line-next-list = (
        get-the-next-list-flag(child, label-value: same-line-next-list-ID)
          or it.has("label") and it.label == same-line-next-list-ID
      )

      let box-info = if is-holding and curr-base-align == none {
        (
          above-height: above-height,
          below-height: below-height,
          inner-top-inset: inner-top-inset,
          outer-top-inset: outer-top-inset,
          whole-top-inset: curr-whole-top-inset,
          same-line-style: same-line-style,
          base-align: curr-base-align,
        )
      }

      let curr-parent-box-info = if is-same-line-next-list {
        parent-box-info + if box-info != none { (box-info,) }
      } else {
        ()
      }

      let label-cell = {
        set block(..default-block-args)
        set block(..curr-block-args)
        if is-holding and curr-base-align == none {
          move-space(
            flag: "label",
            above-height: above-height,
            below-height: below-height,
            inner-top-inset: inner-top-inset,
            same-line-style: same-line-style,
            curr-len: curr-parent-box-info.len(),
          )
        }
        show: disable-par
        label-box-fix-baseline(baseline-inset: curr-baseline)
        // sticky-block
      }

      let enum-item = enum.item(auto, {
        // update: parent-level
        let child-number = numbers.at(i)
        curr-parent-level.update(push((n: i, number: child-number)))

        if auto-base-level {
          curr-base-parent-level.update(base-parent-number + ((n: i, number: child-number),))
        }

        if is-holding and curr-base-align == none {
          move-space(
            flag: "body",
            above-height: above-height,
            below-height: below-height,
            inner-top-inset: inner-top-inset,
            same-line-style: same-line-style,
            curr-len: curr-parent-box-info.len(),
          )
        }

        show enum.where(label: prevent-recursion-label): set block(
          ..default-block-args,
        )
        set block(..default-block-args)
        set block(..curr-block-args)

        {
          let body-baseline-meta = if (
            i == 0 and not is-holding and not is-prior-label-v-align and is-same-line-next-list
          ) {
            show func-layout.where(label: prevent-recursion-label): set block(
              ..default-block-args,
              height: 0pt,
              width: 0pt,
              below: 0pt,
              above: 0pt,
              // fill: gray, // debug
            )
            [#place[#layout(it => {
                  // measure the first line height of the body
                  // not correct when figure.placement = auto or place.float = true and (alignment = auto)
                  let (body-line-height, body-height) = get-first-line-height-in-box(
                    width: it.width,
                    {
                      item-content
                      // hack
                      block(height: 0pt, below: 0pt, above: 0.01pt)
                    },
                  )
                  let top-inset = curr-whole-top-inset + outer-top-inset
                  let line-above-height = body-line-height + inner-top-inset
                  let line-below-height = body-height + inner-bottom-inset - body-line-height
                  let final-body-height
                  if curr-base-align == none {
                    if line-above-height < above-height {
                      line-above-height = above-height
                    }
                    if line-below-height < below-height {
                      line-below-height = below-height
                    }
                    final-body-height = line-above-height + line-below-height
                  } else {
                    final-body-height = calc.max(line-above-height + line-below-height, above-height + below-height)
                  }
                  baseline-tag-meta(
                    tag: el-baseline-label,
                    final-box-height: box-height,
                    final-above-height: above-height,
                    final-below-height: below-height,
                    line-height: line-above-height,
                    body-height: final-body-height,
                    text-style: curr-text-style,
                    final-base-align: curr-base-align,
                    top-inset: top-inset,
                    parent: parent-box-info,
                  )
                })#prevent-parize-recursion-label]#prevent-parize-recursion-label]
          }
          let all-prior-label-v-align = if is-holding {
            is-prior-label-v-align and curr-base-align != none
          } else {
            true
          }
          show: next-show(
            is-pre-list: is-holding,
            is-prior-label-v-align: all-prior-label-v-align,
            base-parent-number: base-parent-number + ((n: i, number: child-number),),
            parent-box-info: curr-parent-box-info,
            parent-fields-info: parent-fields-info + (h-spacing-args + curr-e-args + (n: i),),
          )
          show: inner-format
          show: process-par
          body-baseline-meta
          item-content
        }
        curr-parent-level.update(pop)
        if auto-base-level {
          curr-base-parent-level.update(pop)
        }
      })

      let number-align = (
        if curr-base-align != none {
          curr-base-align
        } else {
          // make sure for further version this is not changed
          if is-holding { top }
        }
          + if (it.number-align).x != none {
            it.number-align.x
          }
      )

      show enum.where(label: prevent-recursion-label): set block(
        ..default-block-args,
        ..outer-border,
        outset: outer-outset,
        ..out-spacing,
        width: auto,
        inset: outer-inset,
      )

      if i > 0 and is-full-item-spacing { hide-line() }
      let outer-format = (curr-body-format.outer)(i)
      let _item-label = get-elem-label(child)
      if _item-label == same-line-next-list-ID {
        _item-label = none
      }
      outer-format[#enum(
          numbering: (..) => label-cell,
          indent: 0pt,
          body-indent: 0pt,
          spacing: elem-above-spacing.spacing,
          number-align: number-align,
          {
            rebuild-label(enum-item, _item-label)
          },
        )#prevent-recursion-label]
      if i == len - 1 and is-full-item-spacing and curr-item-below-spacing != auto {
        hide-line(height: curr-item-below-spacing, below: elem-below-spacing)
      }
    }

    let whole-outset = whole-border.remove("outset", default: (:))

    // display-whole
    if whole-border != (:) {
      let whole-dir-outset = get-dir-inset(whole-outset, dir: dir)
      whole-outset = parse-inset-without-dir(whole-outset, dir: dir)
      // indent outset
      whole-outset.insert(dir, -min-indent + whole-dir-outset)

      let whole-dir-rev-outset = get-dir-inset(whole-outset, dir: dir-rev)
      whole-outset = parse-inset-without-dir(whole-outset, dir: dir-rev)
      // end margin outset
      let whole-end-marging = min-end-margin-abs + min-end-margin-ratio
      whole-outset.insert(dir-rev, -whole-end-marging + whole-dir-rev-outset)

      show enum.where(label: prevent-recursion-label): set block(
        ..default-block-args,
        ..whole-border,
        outset: whole-outset,
        // fill: gray,
        above: if is-pre-list { auto } else { elem-above-spacing.block },
        below: elem-below-spacing,
      )
      [#enum(
          numbering: (..) => none,
          indent: 0pt,
          body-indent: 0pt,
          spacing: elem-above-spacing.spacing,
          number-align: end,
          enum.item(auto, {
            show enum.where(label: prevent-recursion-label): set block(
              ..default-block-args,
            )
            set block(..default-block-args)
            set block(..curr-block-args)
            (curr-body-format.whole)(0)(
              item-body,
            )
          }),
        )#prevent-recursion-label]
    } else {
      (curr-body-format.whole)(0)(
        item-body,
      )
    }
  }

  item-level.update(pop)
  enum-level.update(it => it - 1)

  enum-numbering.update(pop)

  auto-id-state.update(auto-pop-id)

  lw.update-auto_label-level(it => it - 1)
  lw.update-global_label-level(it => it - 1)
  //feat: resume a list
  rl.update_resume-level(it => it - 1)
  rl.restart_resuming()
}

/// Ver0.3.0: Reimplement lists using a new layout method
/// Support additional features: auto-label-width, auto-resuming
#let feat-list(
  it,
  elem: ElemType.list,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  whole-spacing: auto, /**new ver0.3.0, whole-spacing is the new name of enum-spacing*/
  body-margin: auto, /*new ver0.3.0, dict: (left, right)*/
  hanging-type: HangingType.classic, // paragraph
  hanging-indent: auto,
  line-indent: auto,
  absolute-level: false,
  auto-base-level: false, /*new ver0.2.0*/
  label-width: auto, /*new ver0.2.0*/
  body-format: none, /*new ver0.2.0*/
  label-format: none, /*new ver0.2.0*/
  // item-format: none, /*new ver0.2.0, not be used for ver0.3.0*/
  label-align: auto, /*new ver0.2.0*/
  label-baseline: auto, /*new ver0.2.0; enhance for ver0.3.0**/
  checklist: false, /*new ver0.2.0, for list*/
  func-list: none, /*for format args, identify the elem function to next show*/
  func-enum: none, /*for format args, identify the elem function to next show*/
  is-pre-list: false, // internal
  is-prior-label-v-align: false, // internal
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

  auto-resuming: none, /*new ver0.2.0*/
  auto-label-width: none, /*new ver0.2.0*/
  ..args,
) = {
  if it.has("label") and it.label == prevent-recursion-label or it.children.len() == 0 {
    return it
  }

  item-level.update(push("list"))
  list-level.update(it => it + 1)

  rl.update_resume-level(it => it + 1)

  lw.update-auto_label-level(it => it + 1)
  lw.update-global_label-level(it => it + 1)

  {
    // levels
    let abs-elem-level = item-level.get().len()
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
      description-config: description-config, /** new ver0.3.0 */
      body-margin: body-margin, /*new new ver0.3.0*/
      whole-spacing: whole-spacing, /*new new ver0.3.0*/
      // for levels (to void "layout did not converge within 5 attempts")
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level,
      curr-list-level: curr-list-level + 1,
      curr-abs-enum-level: curr-abs-enum-level, // TODO: ??????
      curr-abs-list-level: curr-abs-list-level + 1, // TODO: ??????
      enum-level-info: enum-level-info,
      list-level-info: curr-list-level-info,

      auto-resuming: auto-resuming, /*new ver0.2.0*/
      auto-label-width: auto-label-width, /*new ver0.2.0*/
    )
    let next-show(
      is-prior-label-v-align: false,
      is-pre-list: false,
      // parent number
      base-parent-number: (), /** internal: new ver0.3.0 */
      // parent box info
      parent-box-info: (), /** internal: new ver0.3.0 */
      parent-fields-info: (),
    ) = body => {
      if elem == ElemType.all {
        show enum: func-enum.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        show list: func-list.with(
          ..all-args,
          enum-config: enum-config, /** config enum only */
          list-config: list-config, /** config list only */
          ..args,
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        body
      } else {
        show list: func-list.with(
          ..all-args,
          ..args,
          is-pre-list: is-pre-list,
          is-prior-label-v-align: is-prior-label-v-align,
          base-parent-number: base-parent-number,
          parent-box-info: parent-box-info,
          parent-fields-info: parent-fields-info,
        )
        body
      }
    }

    // feat: resume a list
    if auto-resuming != none {
      rl.init_resuming-zero()
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
    let item-absolute = n => item-config-dic.at(n).at("absolute", default: false)
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

    // feat: auto-label-width
    if auto-label-width != none {
      if auto-label-width == auto {
        if lw.max-width-label.get().unlock {
          let (form, current-level, current-list-level) = width-label-form.get() // TODO
          let form-level = if absolute-level { abs-elem-level - current-level } else {
            abs-list-level - current-list-level
          }
          let curr-form = parse-auto-label(form, form-level, ..args-with-tags-item)
          // "each" (default), "all", "only enum or list"
          if auto-label-elem(curr-form, "list") {
            lw.update-auto_width-label-dic(marker-max-width, "list")
            let locate-end = selector(metadata.where(value: enum-label-ID, label: label(auto-label-ID))).after(here())
            let sel = query(locate-end)
            if sel.len() > 0 {
              let dic = lw.max-width-label.at(sel.first().location())
              let c-level = lw.max-width-label.get().level
              let width-dic = dic.width.at(c-level, default: lw.default-width)
              marker-max-width = if curr-form == AutoLabelWidth.all {
                calc.max(width-dic.list, width-dic.enum)
              } else {
                width-dic.list
              }
            }
          }
        }
      } else {
        let curr-auto-label = parse-auto-label(auto-label-width, rel-level, ..args-with-tags-item)
        if auto-label-elem(curr-auto-label, "list") {
          lw.update-global_width-label-dic(marker-max-width, "list")
          let locate-end = selector(metadata.where(value: global-auto-label-ID)).after(here())
          let sel = query(locate-end)
          if sel.len() > 0 {
            let dic = lw.max-width-label-global.at(sel.first().location())
            let width-dic = dic.width.at(rel-level, default: lw.default-width)
            marker-max-width = if curr-auto-label == AutoLabelWidth.all {
              calc.max(width-dic.list, width-dic.enum)
            } else {
              width-dic.list
            }
          }
        }
      }
    }

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

    // body-margin
    let curr-body-margin = get-body-margin(
      rel-level,
      curr-list-level,
      level-item,
      body-margin,
      list-config-args.body-margin,
      get-item-config(item-args.body-margin),
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

    // label-baseline
    let curr-label-baseline = parse-general-args-with-level-n(
      label-baseline,
      rel-level,
      list-config-args.label-baseline,
      curr-list-level,
      0pt,
      get-item-config(item-args.label-baseline),
      level-item,
      ..args-with-tags,
    )

    // description setting
    let desc-items = parse-item-body.map(it => {
      let item = it.at("desc", default: none)
      if item != none {
        item.fields()
      }
    })
    let (
      desc-dic,
      term-format,
      description-format,
      desc-style,
      desc-term-width,
      desc-format,
    ) = get-description-setting(
      description-config,
      list-config-args.description-config,
      get-item-config(item-args.description-config),
      rel-level,
      curr-list-level,
      level-item,
      ..args-with-tags,
    )

    let description-info = parse-description(
      desc-items: desc-items,
      format-dic: desc-dic,
      term-format: term-format,
      description-format: description-format,
      desc-style: desc-style,
      term-width: desc-term-width,
      checklist-args: checklist-info,
    )

    let text-dir = get-text-dir()
    let dir = text-dir.text-start
    let dir-rev = text-dir.text-end

    let process-description = process-terms-item.with(
      desc-info: description-info,
      format: desc-format,
      dir: dir,
      dir-rev: dir-rev,
    )

    // Used to determine whether the `above` and `below` attributes of `item-spacing` are used in the first and last items
    let pre-item-below-spacing = none

    let min-indent = float.inf * 1pt

    let min-end-margin-abs = float.inf * 1pt
    let min-end-margin-ratio = float.inf * 1%

    // format function
    // Limits: For curr-body-format (outer, whole), if it modifies font size (such as using upper, text.size, strong, etc.), it will affect the width of label content, causing incorrect display. One solution is to apply label-format again if such styles are present.
    // In itemize, we do not directly apply the styles from curr-body-format (outer, whole) to the label and then test its height and width (this remains impractical because it affects the entire item (label + body), and we are uncertain about the effects when these styles are applied only to the label).
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

    let whole-border = (curr-body-border.whole)(0)
    let whole-inset = whole-border.at("inset", default: (:))
    // only deal with length
    let _whole-top-inset = get-dir-inset(whole-inset, dir: "top")
    assert(
      type(_whole-top-inset) == length,
      message: "Expected a `length` value. \nBut found: " + repr(_whole-top-inset) + ".",
    )
    let whole-top-inset = _whole-top-inset.to-absolute()

    // current block args
    let curr-block-args = get-current-block-args(block)

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
      if _indent < min-indent { min-indent = _indent }

      // parse body-margin
      let _body-margin = curr-body-margin(i, ..curr-label-width-args, ..parent-elem-args)

      let start-margin = _body-margin.at(dir)

      let end-margin = _body-margin.at(dir-rev)
      end-margin = get-auto-value(end-margin, 0pt)
      let (end-margin-ratio, end-margin-abs) = parse-relative(end-margin)
      end-margin-abs = end-margin-abs.to-absolute()
      if end-margin-ratio < min-end-margin-ratio { min-end-margin-ratio = end-margin-ratio }
      if end-margin-abs < min-end-margin-abs { min-end-margin-abs = end-margin-abs }

      let start-margin-len = if start-margin == auto {
        number-width.width - number-width.amount
      } else {
        let (start-margin-ratio, start-margin-abs) = parse-relative(start-margin)
        let label-start-margin-inset = box-width + _label-indent + _body-indent
        (
          label-start-margin-inset - (label-start-margin-inset * start-margin-ratio + start-margin-abs.to-absolute())
        )
      }

      let h-spacing-args = (
        (
          label-indent: _label-indent,
          label-inset: _label-inset,
          body-indent: _body-indent,
          indent: _indent,
          body-margin: _body-margin,
          // inner-dir-inset : inner-dir-inset // TODO ???
        )
          + curr-label-width-args
      )

      // outer-border
      let outer-border = (curr-body-border.outer)(i)
      let outer-outset = outer-border.remove("outset", default: (:))
      let outer-dir-outset = get-dir-inset(outer-outset, dir: dir)
      outer-outset = parse-inset-without-dir(outer-outset, dir: dir)
      outer-outset.insert(dir, -_indent + outer-dir-outset)

      // inner-border
      let inner-border = (curr-body-border.inner)(i)
      let inner-inset = inner-border.at("inset", default: (:))

      let _inner-top-inset = get-dir-inset(inner-inset, dir: "top")
      assert(
        type(_inner-top-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-top-inset),
      )
      let inner-top-inset = _inner-top-inset.to-absolute()
      let _inner-bottom-inset = get-dir-inset(inner-inset, dir: "bottom")
      assert(
        type(_inner-bottom-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-bottom-inset),
      )
      let inner-bottom-inset = _inner-bottom-inset.to-absolute()

      let _inner-dir-inset = get-dir-inset(inner-inset, dir: dir)
      assert(
        type(_inner-dir-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_inner-dir-inset),
      )
      let inner-dir-inset = _inner-dir-inset.to-absolute()

      let outer-inset = outer-border.remove("inset", default: (:))
      let _outer-top-inset = get-dir-inset(outer-inset, dir: "top")
      assert(
        type(_outer-top-inset) == length,
        message: "Expected a `length` value. \nBut found: " + repr(_outer-top-inset),
      )
      let outer-top-inset = _outer-top-inset.to-absolute()

      // deal with: end body margin
      if end-margin-abs != 0pt or end-margin-ratio != 0% {
        let outer-dir-rev-inset = get-dir-inset(outer-inset, dir: dir-rev)
        outer-inset = parse-inset-without-dir(outer-inset, dir: dir-rev)
        outer-inset.insert(dir-rev, outer-dir-rev-inset + end-margin)

        let outer-dir-rev-outset = get-dir-inset(outer-outset, dir: dir-rev)
        outer-outset = parse-inset-without-dir(outer-outset, dir: dir-rev)
        outer-outset.insert(dir-rev, outer-dir-rev-outset - end-margin)
      }

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

      let (body, inline, ..checklist-item) = parse-item-body.at(i)

      let (checklist-format, checklist-baseline) = if checklist-item != (:) {
        let checklist = checklist-item.at("checklist", default: none)
        if checklist != none {
          checklist
        } else {
          (none, auto)
        }
      } else {
        (none, auto)
      }

      //label baseline (label-v-spacing)
      let (
        curr-baseline,
        same-line-style, // need further process
        base-align, /*ver0.3.0: different meaning*/
        impact-first-line, /*ver0.3.0:  only for current label*/
        baseline-at, /*ver0.3.0*/
      ) = parse-baseline(
        if checklist-baseline == auto { curr-label-baseline(i) } else { checklist-baseline },
        curr-text-style,
        label-height: box-height,
      )

      if impact-first-line == auto {
        impact-first-line = _hanging-type == HangingType.paragraph
      }

      // flag: show in same-line (like: 1.a.I.)
      let is-holding = inline == InlineType.list // enum or list
      let is-description = inline == InlineType.description
      let is-same-line-style = is-holding and (same-line-style != auto)
      if is-same-line-style {
        baseline-at = auto
        curr-baseline = 0pt
      }

      let h-label-align = curr-label-align(i)
      assert(
        type(h-label-align) == alignment,
        message: "`label-align` must be a `alignment` value or `auto`. \nBut found: " + repr(h-label-align),
      )

      // current label
      let label-box-fix-baseline(
        baseline-inset: 0pt,
      ) = label-box-with-baseline(
        styled-markers.at(i),
        indent: _indent,
        width: box-width,
        height: box-height,
        label-indent: _label-indent,
        label-inset: _label-inset,
        body-inset: _body-indent,
        label-align: h-label-align,
        // baseline info
        baseline-inset: baseline-inset,
        baseline-at: baseline-at,
        // label-border format
        ..label-border,
        given-width: label-width-amount,
        given-align: label-border-align,
        given-height: label-height-amount,
        adjust-width: -start-margin-len,
        dir: dir,
        dir-rev: dir-rev,
      )

      // paragraph spacing: hanging-indent, first-line-indent, line-indent
      let _first-line-inset = curr-first-line-inset(i, ..parent-elem-args, ..h-spacing-args).to-absolute()
      let _temp-line-indent = curr-line-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _line-indent = if _temp-line-indent == auto { auto } else { _temp-line-indent.to-absolute() }
      let _temp-hanging-indent = curr-hanging-indent(i, ..parent-elem-args, ..h-spacing-args)
      let _hanging-indent = if _temp-hanging-indent == auto { auto } else { _temp-hanging-indent.to-absolute() }

      let curr-whole-top-inset = if i == 0 { whole-top-inset } else { 0pt }

      let curr-base-align = if (it.marker-align).y != none {
        (it.marker-align).y
      } else {
        if not is-same-line-style { base-align } else { same-line-style.base-align }
      }

      // measure label baseline (formatted-with-border)
      let (above-height, below-height) = {
        // if is-same-line is true, in this case the label is aligned to the top for the native lists.
        let at = if not is-same-line-style { auto } else { baseline-at }
        if at == auto {
          let origin-label-box = label-box-fix-baseline()
          let (box-baseline, ..) = get-baseline-inset-in-box(origin-label-box)
          let given-label-baseline = box-baseline + curr-baseline

          get-baseline-at-auto(at: auto, height: box-height, baseline: given-label-baseline)
        } else {
          get-baseline-at-auto(at: at, height: box-height)
        }
      }

      let label-tag = v-line-tag(height: above-height + below-height, baseline: below-height) // for first-line (impact-first-line)

      let inner-block(body) = if (
        inner-border != (:) and inline != InlineType.blank
      ) {
        show pad.where(label: prevent-recursion-label): set block(
          ..default-block-args,
          ..inner-border,
          width: auto, // TODO
          // fill: gray,
        )
        [#pad(rest: 0pt, {
            show pad.where(label: prevent-recursion-label): set block(
              ..default-block-args,
            )
            set block(..default-block-args)
            set block(..curr-block-args)
            body
          })#prevent-recursion-label]
      } else {
        body
      }
      let inner-format(body) = (curr-body-format.inner)(i)({
        inner-block(show-text((curr-body-style)(i), {
          if checklist-format != none {
            checklist-format(body)
          } else {
            body
          }
        }))
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
      pre-item-below-spacing = curr-item-below-spacing // update

      let out-spacing = { (above: if i == 0 and is-pre-list { auto } else { above-spacing }, below: below-spacing) }

      // process paragraph
      let label-cell-width = if _hanging-type == HangingType.classic { 0pt } else {
        box-width + _body-indent + _label-indent - start-margin-len + inner-dir-inset
      }

      let process-par(
        doc,
        enable-strong-par: false,
        my-first-line-inset: auto,
        enable-process: false,
        label-cell-inset: label-cell-width,
      ) = process-body-par(
        doc,
        enable-strong-par: enable-strong-par,
        my-first-line-inset: my-first-line-inset,
        label-cell-inset: label-cell-inset,
        start-margin-len: start-margin-len,
        enable-process: enable-process, // TODO
        line-indent: _line-indent,
        hanging-indent: _hanging-indent,
        first-line-inset: _first-line-inset,
        start-normal-par: is-holding,
        label-tag: if impact-first-line { label-tag },
      )

      let item-content = {
        // feat: description list
        show: process-description(
          start-margin: start-margin-len,
          process-par: process-par.with(
            label-cell-inset: 0pt,
          ),
        )(i)
        body
      }

      {
        let is-same-line-next-list = (
          get-the-next-list-flag(child, label-value: same-line-next-list-ID)
            or it.has("label") and it.label == same-line-next-list-ID
        )

        let box-info = if is-holding and curr-base-align == none {
          (
            above-height: above-height,
            below-height: below-height,
            inner-top-inset: inner-top-inset,
            outer-top-inset: outer-top-inset,
            whole-top-inset: curr-whole-top-inset,
            same-line-style: same-line-style,
            base-align: curr-base-align,
          )
        }

        let curr-parent-box-info = if is-same-line-next-list {
          parent-box-info + if box-info != none { (box-info,) }
        } else {
          ()
        }

        let label-cell = {
          set block(..default-block-args)
          set block(..curr-block-args)
          if is-holding and curr-base-align == none {
            move-space(
              flag: "label",
              above-height: above-height,
              below-height: below-height,
              inner-top-inset: inner-top-inset,
              same-line-style: same-line-style,
              curr-len: curr-parent-box-info.len(),
            )
          }
          show: disable-par
          label-box-fix-baseline(baseline-inset: curr-baseline)
          // sticky-block
        }

        let list-item = enum.item(auto, {
          if is-holding and curr-base-align == none {
            move-space(
              flag: "body",
              above-height: above-height,
              below-height: below-height,
              inner-top-inset: inner-top-inset,
              same-line-style: same-line-style,
              curr-len: curr-parent-box-info.len(),
            )
          }

          show enum.where(label: prevent-recursion-label): set block(
            ..default-block-args,
          )
          set block(..default-block-args)
          set block(..curr-block-args)

          {
            let body-baseline-meta = if (
              i == 0 and not is-holding and not is-prior-label-v-align and is-same-line-next-list
            ) {
              // show func-layout.where(label: prevent-recursion-label): set block(
              //   ..default-block-args,
              //   below: 0pt,
              //   above: 0pt,
              //   fill: gray, // debug
              // )
              [#place[#layout(it => {
                    // measure the first line height of the body
                    // not correct when figure.placement = auto or place.float = true and (alignment = auto)
                    let (body-line-height, body-height) = get-first-line-height-in-box(
                      width: it.width,
                      {
                        item-content
                        // hack
                        block(height: 0pt, below: 0pt, above: 0.01pt)
                      },
                    )
                    let top-inset = curr-whole-top-inset + outer-top-inset
                    let line-above-height = body-line-height + inner-top-inset
                    let line-below-height = body-height + inner-bottom-inset - body-line-height
                    let final-body-height
                    if curr-base-align == none {
                      if line-above-height < above-height {
                        line-above-height = above-height
                      }
                      if line-below-height < below-height {
                        line-below-height = below-height
                      }
                      final-body-height = line-above-height + line-below-height
                    } else {
                      final-body-height = calc.max(line-above-height + line-below-height, above-height + below-height)
                    }
                    baseline-tag-meta(
                      tag: el-baseline-label,
                      final-box-height: box-height,
                      final-above-height: above-height,
                      final-below-height: below-height,
                      line-height: line-above-height,
                      body-height: final-body-height,
                      text-style: curr-text-style,
                      final-base-align: curr-base-align,
                      top-inset: top-inset,
                      parent: parent-box-info,
                    )
                  })#prevent-parize-recursion-label]#prevent-parize-recursion-label]
            }
            let all-prior-label-v-align = if is-holding {
              is-prior-label-v-align and curr-base-align != none
            } else {
              true
            }
            show: next-show(
              is-pre-list: is-holding,
              is-prior-label-v-align: all-prior-label-v-align,
              base-parent-number: base-parent-number,
              parent-box-info: curr-parent-box-info,
              parent-fields-info: parent-fields-info + (h-spacing-args + curr-e-args + (n: i),),
            )
            show: inner-format
            show: process-par
            body-baseline-meta
            item-content
          }
        })

        let marker-align = (
          if curr-base-align != none {
            curr-base-align
          } else {
            // make sure for further version this is not changed
            if is-holding { top }
          }
            + if (it.marker-align).x != none {
              it.marker-align.x
            }
        )

        show enum.where(label: prevent-recursion-label): set block(
          ..default-block-args,
          ..outer-border,
          outset: outer-outset,
          ..out-spacing,
          width: auto,
          inset: outer-inset,
        )

        if i > 0 and is-full-item-spacing { hide-line() }
        let outer-format = (curr-body-format.outer)(i)
        let _item-label = get-elem-label(child)
        if _item-label == same-line-next-list-ID {
          _item-label = none
        }
        outer-format[#enum(
            numbering: (..) => label-cell,
            indent: 0pt,
            body-indent: 0pt,
            spacing: elem-above-spacing.spacing,
            number-align: marker-align,
            {
              rebuild-label(list-item, _item-label)
            },
          )#prevent-recursion-label]

        if i == len - 1 and is-full-item-spacing and curr-item-below-spacing != auto {
          hide-line(height: curr-item-below-spacing, below: elem-below-spacing)
        }
      }
    }

    let whole-outset = whole-border.remove("outset", default: (:))

    // display-whole
    if whole-border != (:) {
      let whole-dir-outset = get-dir-inset(whole-outset, dir: dir)
      whole-outset = parse-inset-without-dir(whole-outset, dir: dir)
      // indent outset
      whole-outset.insert(dir, -min-indent + whole-dir-outset)

      let whole-dir-rev-outset = get-dir-inset(whole-outset, dir: dir-rev)
      whole-outset = parse-inset-without-dir(whole-outset, dir: dir-rev)
      // end margin outset
      let whole-end-marging = min-end-margin-abs + min-end-margin-ratio
      whole-outset.insert(dir-rev, -whole-end-marging + whole-dir-rev-outset)

      show enum.where(label: prevent-recursion-label): set block(
        ..default-block-args,
        ..whole-border,
        outset: whole-outset,
        // fill: gray,
        above: if is-pre-list { auto } else { elem-above-spacing.block },
        below: elem-below-spacing,
      )
      [#enum(
          numbering: (..) => none,
          indent: 0pt,
          body-indent: 0pt,
          spacing: elem-above-spacing.spacing,
          number-align: end,
          enum.item(auto, {
            show enum.where(label: prevent-recursion-label): set block(
              ..default-block-args,
            )
            set block(..default-block-args)
            set block(..curr-block-args)
            (curr-body-format.whole)(0)(
              item-body,
            )
          }),
        )#prevent-recursion-label]
    } else {
      (curr-body-format.whole)(0)(
        item-body,
      )
    }
  }
  item-level.update(pop)
  list-level.update(it => it - 1)

  rl.update_resume-level(it => it - 1)

  lw.update-auto_label-level(it => it - 1)
  lw.update-global_label-level(it => it - 1)
}
