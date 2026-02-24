#import "fix-enum-list.typ": *
#import "../lib/resume-lib.typ" as rl
#import "../lib/label-width-lib.typ" as lw

/// Parses the auto-label-width argument to validate its value.
///
/// Parameters
/// - `auto-label-width`: The value to parse (can be `none`, `auto`, or specific strings).
/// - `level`: The nesting level for which the label width is being set.
///
/// Returns
/// The validated label width value.
///
#let parse-auto-label(auto-label-width, level) = {
  let curr-auto-label = get_depth-value(auto-label-width, level)
  assert(
    curr-auto-label in (none, auto, "none", "each", "all", "enum", "list"),
    message: "The argument should be `none`, `auto`, or one of the following strings: \"each\", \"all\", \"enum\", \"list\".",
  )
  return curr-auto-label
}


/// Enhances the `enum` function with advanced formatting and layout options.
///
/// Parameters
/// - `it`: The enum object to format.
/// - `elem`: Type of element (`"enum"`, `"list"`, or `"both"`).
/// - `indent`: Indentation for each item.
/// - `body-indent`: Spacing between marker and body.
/// - `label-indent`: Indentation for labels.
/// - `is-full-width`: If `true`, items span full width.
/// - `item-spacing`: Spacing between items.
/// - `enum-spacing`: Spacing around the enum.
/// - `enum-margin`: Margin around the enum.
/// - `hanging-type`: Hanging indent type (`"classic"` or `"paragraph"`).
/// - `hanging-indent`: Hanging indent value.
/// - `line-indent`: First line indent.
/// - `absolute-level`: If `true`, uses absolute nesting levels.
/// - `auto-base-level`: Auto-detects base level (v0.2.0).
/// - `label-width`: Width of labels (v0.2.0).
/// - `body-format`: Formatting for body content (v0.2.0).
/// - `label-format`: Formatting for labels (v0.2.0).
/// - `item-format`: Formatting for items (v0.2.0).
/// - `label-align`: Label alignment (v0.2.0).
/// - `label-baseline`: Label baseline (v0.2.0).
/// - `checklist`: Enables checklist mode (v0.2.0).
/// - `func-list`: Function for list formatting.
/// - `func-enum`: Function for enum formatting.
/// - `curr-level`: Current nesting level.
/// - `curr-enum-level`: Current enum level.
/// - `curr-list-level`: Current list level.
/// - `auto-resuming`: Controls resume functionality (v0.2.0).
/// - `auto-label-width`: Controls label width functionality (v0.2.0).
/// - `enum-config`: Configuration for enums.
/// - `list-config`: Configuration for lists.
/// - `args`:  Additional named arguments for text formatting.
///
/// Returns
/// A formatted enum with the specified styling and layout.
#let feat-enum(
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
  auto-resuming: none, /*new ver0.2.0*/
  auto-label-width: none, /*new ver0.2.0*/
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

  /*
  feat: resume a list
  */
  rl.update_resume-level(it => it + 1)

  lw.update-auto_label-level(it => it + 1)
  lw.update-global_label-level(it => it + 1)

  context {
    // levels
    let abs-level = item-level.get().len() - 1
    let abs-enum-level = enum-level.get() - 1
    // let it-level = if auto-base-level { curr-level } else { abs-level }
    let it-enum-level = if auto-base-level { curr-enum-level } else { abs-enum-level }
    let level = if absolute-level { abs-level } else { it-enum-level }
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
      auto-base-level: auto-base-level, /*new ver0.2.0 */
      label-width: label-width, /*new ver0.2.0*/
      body-format: body-format, /*new ver0.2.0*/
      label-format: label-format, /*new ver0.2.0*/
      item-format: item-format, /*new ver0.2.0*/
      label-align: label-align, /*new ver0.2.0*/
      label-baseline: label-baseline, /*new ver0.2.0*/
      checklist: checklist,
      func-enum: func-enum,
      func-list: func-list,
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level + 1,
      curr-list-level: curr-list-level,
      auto-resuming: auto-resuming,
      auto-label-width: auto-label-width,
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

    let parse-formatted-body = if item-format not in (none, (), auto, (:)) {
      pre_parse-formatted-body
    } else {
      native-content
    }

    /*
    feat: resume a list
    */
    let numbers = ()
    if auto-resuming != none {
      let curr-auto-resuming = if auto-resuming != auto {
        let _auto-resuming = get_depth-value(auto-resuming, rel-level)
        assert(type(_auto-resuming) == bool, message: "`auto-resuming` should be a bool if it is not `auto` or `none`.")
        _auto-resuming
      } else { none }

      rl.restart_resuming()
      let key-label = rl.resume-label-list.get()
      let target-enum = if key-label != none {
        let sel = selector(key-label).and(metadata.where(value: enum-resume-ID))
        let keys = query(sel)
        if keys.len() == 0 {
          panic("Can't find the enum with key `" + str(key-label) + "`.")
        } else if keys.len() > 1 {
          panic("The enum with labelled key `" + str(key-label) + "` occurs multiple times.")
        } else {
          if query(sel.after(here())).len() > 0 {
            // 暂时不支持引用后面列表的序号, 否则会造成“layout did not converge with 5 attempts.”
            panic("Resuming an enum before `" + str(key-label) + "` is not supported.")
          }
          sel
        }
      } else { none }
      let cur-resume = if target-enum != none {
        // label-case
        let dic = rl.item-counter-dic.at(target-enum)
        let target-level = item-level.at(target-enum).len() - 1 // 采用absolute level
        let increment = abs-enum-level - curr-level
        dic.counter.at(target-level - increment, default: 0)
      } else if curr-auto-resuming == true {
        // auto-case (using *-enum)
        let dic = rl.item-counter-dic.get()
        dic.counter.at(dic.level - 1, default: 0)
      } else if rl.resume-list.get() {
        // auto-resume-enum
        curr-auto-resuming = true
        let dic = rl.item-counter-dic.get()
        dic.counter.at(dic.level - 1, default: 0)
      } else {
        // sublist case
        let resume-sublist = auto-resuming-form.get()
        if resume-sublist != none {
          let (form, current-level) = resume-sublist
          let curr-form = get_depth-value(form, abs-level - current-level)
          if curr-form != none {
            assert(
              type(curr-form) == bool,
              message: "The value should a bool.",
            )
            if curr-form {
              curr-auto-resuming = true
              let dic = rl.item-counter-dic.get()
              dic.counter.at(dic.level - 1, default: 0)
            } else {
              0
            }
          } else {
            0
          }
        } else { 0 }
      }

      rl.init_resuming-number(it.start, curr-auto-resuming)

      // enum's number (label)
      // [\ ]
      // box(stroke: 1pt + red, inset: 1pt)[init-counter: #context rl.item-counter-dic.get(); #curr-level]
      let cur = if it.start == auto { cur-resume } else { it.start - 1 }
      for i in range(it.children.len()) {
        let child = it.children.at(i)
        if child.has("number") and child.number not in (none, auto) {
          // typst 0.14
          numbers.push(child.number)
          cur = child.number
          rl.update_resuming-number(child.number)
          // box(stroke: 1pt + green, inset: 1pt)[|#context rl.item-counter-dic.get().counter]
        } else {
          cur += 1
          numbers.push(cur)
          rl.update_resuming-number(it => it + 1)
          // box(stroke: 1pt + green, inset: 1pt)[|#context rl.item-counter-dic.get().counter]
        }
      }
    } else {
      let cur = if it.start == auto { 0 } else { it.start - 1 }
      for i in range(it.children.len()) {
        let child = it.children.at(i)
        if child.has("number") and child.number not in (none, auto) {
          numbers.push(child.number)
          cur = child.number
        } else {
          cur += 1
          numbers.push(cur)
        }
      }
    }

    // using curr-level
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


    /*feat: auto-label-width*/
    if auto-label-width != none {
      if auto-label-width == auto {
        if lw.max-width-label.get().unlock {
          let (form, current-level) = width-label-form.get()
          let curr-form = parse-auto-label(form, abs-level - current-level)
          // "each" (default), "all", "only enum or list"
          if curr-form in ("each", "all", "enum", auto) {
            lw.update-auto_width-label-dic(number-max-width, "enum")
            let locate-end = selector(label(auto-label-ID)).and(metadata.where(value: enum-label-ID)).after(here())
            let sel = query(locate-end)
            if sel.len() > 0 {
              let dic = lw.max-width-label.at(sel.first().location())
              let c-level = lw.max-width-label.get().level - 1
              let width-dic = dic.width.at(c-level, default: lw.default-width)
              number-max-width = if curr-form == "all" {
                calc.max(width-dic.list, width-dic.enum)
              } else {
                width-dic.enum
              }
            }
          }
        }
      } else {
        //  全局使用, 一个文档只能使用一个
        let curr-auto-label = parse-auto-label(auto-label-width, rel-level)
        if curr-auto-label in ("all", "enum", "each") {
          lw.update-global_width-label-dic(number-max-width, "enum")
          let dic = lw.max-width-label-global.final()
          let width-dic = dic.width.at(rel-level, default: lw.default-width)
          number-max-width = if curr-auto-label == "all" {
            calc.max(width-dic.list, width-dic.enum)
          } else {
            width-dic.enum
          }
        }
      }
    }

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


    // box(stroke: 1pt + yellow, inset: 1pt)[|#context lw.max-width-label.get()]


    /*
    need to update !!!!!!!!!!!!!!!!!!!
    in fact, we need `widths`
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
      rel-level,
      level,
      number-max-width, /*ver0.1.x*/
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
      number-max-width, /*ver0.1.x*/
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
    // label-align
    let curr-label-align = parse-general-args-with-level-n(
      label-align,
      rel-level,
      enum-config-args.label-align,
      curr-enum-level,
      it.number-align,
      n-last: it.children.len(),
    )
    // label-baseline
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
            [#show-text((curr-body-style)(i), next-show(body))]
          } else {
            [

              #fix-first-line#number-body#h(0em, weak: true)#show-text((curr-body-style)(i), next-show(body))
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

      let label-inset = width + get-block-left-inset(curr-text-size, (curr-body-border.whole)(i)) + outer-left-inset

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

      // parse body (in order to determine how to display number)
      let new-body = rebuild_block-level-elem(
        parse-formatted-body(child.body),
        the-number,
        alignment: base-align,
        auto-margin: enum-width(i) == auto,
        text-size: curr-text-size,
      )

      // [#repr(new-body)]
      // record the left inset of the current block-level elems
      parent-item-inset.update(push(inner-left-inset))
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

  lw.update-auto_label-level(it => it - 1)
  lw.update-global_label-level(it => it - 1)
  /*
  feat: resume a list
  */
  rl.update_resume-level(it => it - 1)
  rl.restart_resuming()


  if curr-level == 0 and elem != "list" {
    state("_default-text-style", (default-text-args,)).update(pop)
    state("_parent-hanging-indent_and_line-indent").update(pop)
  }
}



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

#let get_desc-marker(child) = {
  if child.func() == metadata and child.value.kind == list-ID {
    return child.value.body
  } else {
    return none
  }
}

/// Enhances the `list` function with advanced formatting and layout options.
///
/// Parameters
/// - `it`: The list object to format.
/// - `elem`: Type of element (`"enum"`, `"list"`, or `"both"`).
/// - `indent`: Indentation for each item.
/// - `body-indent`: Spacing between marker and body.
/// - `label-indent`: Indentation for labels.
/// - `is-full-width`: If `true`, items span full width.
/// - `item-spacing`: Spacing between items.
/// - `enum-spacing`: Spacing around the list.
/// - `enum-margin`: Margin around the list.
/// - `hanging-type`: Hanging indent type (`"classic"` or `"paragraph"`).
/// - `hanging-indent`: Hanging indent value.
/// - `line-indent`: First line indent.
/// - `absolute-level`: If `true`, uses absolute nesting levels.
/// - `auto-base-level`: Auto-detects base level (v0.2.0).
/// - `label-width`: Width of labels (v0.2.0).
/// - `body-format`: Formatting for body content (v0.2.0).
/// - `label-format`: Formatting for labels (v0.2.0).
/// - `item-format`: Formatting for items (v0.2.0).
/// - `label-align`: Label alignment (v0.2.0).
/// - `label-baseline`: Label baseline (v0.2.0).
/// - `checklist`: Enables checklist mode (v0.2.0).
/// - `func-list`: Function for list formatting.
/// - `func-enum`: Function for enum formatting.
/// - `curr-level`: Current nesting level.
/// - `curr-enum-level`: Current enum level.
/// - `curr-list-level`: Current list level.
/// - `auto-resuming`: Controls resume functionality (v0.2.0).
/// - `auto-label-width`: Controls label width functionality (v0.2.0).
/// - `enum-config`: Configuration for enum.
/// - `list-config`: Configuration for list.
/// - `args`:  Additional named arguments for text formatting.
///
/// Returns
/// A formatted list with the specified styling and layout.
#let feat-list(
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
  auto-resuming: none, /*new ver0.2.0*/
  auto-label-width: none, /*new ver0.2.0*/
  enum-config: (:), /** config enum only */
  list-config: (:), /** config list only */
  ..args,
) = {
  item-level.update(push("list"))
  list-level.update(it => it + 1)

  rl.update_resume-level(it => it + 1)

  lw.update-auto_label-level(it => it + 1)
  lw.update-global_label-level(it => it + 1)

  context {
    // levels
    let abs-level = item-level.get().len() - 1
    let abs-list-level = list-level.get() - 1
    // let it-level = if auto-base-level { curr-level } else { abs-level }
    let it-list-level = if auto-base-level { curr-list-level } else { abs-list-level }
    let level = if absolute-level { abs-level } else { it-list-level }
    let rel-level = if absolute-level { curr-level } else { curr-enum-level }

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
      auto-base-level: auto-base-level,
      label-width: label-width,
      body-format: body-format,
      label-format: label-format,
      item-format: item-format,
      label-align: label-align,
      label-baseline: label-baseline,
      checklist: checklist,
      func-enum: func-enum,
      func-list: func-list,
      curr-level: curr-level + 1,
      curr-enum-level: curr-enum-level,
      curr-list-level: curr-list-level + 1,
      auto-resuming: auto-resuming,
      auto-label-width: auto-label-width,
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


    let parse-formatted-body = if item-format not in (none, (), auto, (:)) {
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
    feat: resume a list
    */
    if auto-resuming != none {
      rl.init_resuming-zero()
    }


    /*
    feat: description-list (like terms)
    */
    let desc-marker = ()
    let checklist-body = ()
    let setting = setting-checklist.get()
    let curr-checklist = get_depth-value(checklist, rel-level) or get_depth-value(setting.enable, curr-list-level)
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
    // marker: content, function
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


    // feat: auto-label-width
    if auto-label-width != none {
      if auto-label-width == auto {
        if lw.max-width-label.get().unlock {
          let (form, current-level) = width-label-form.get()
          let curr-auto-label = parse-auto-label(form, abs-level - current-level)
          // "each" (default), "all", "only enum or list"
          if curr-auto-label in ("each", "all", "list", auto) {
            lw.update-auto_width-label-dic(marker-max-width, "list")
            let locate-end = selector(label(auto-label-ID)).and(metadata.where(value: enum-label-ID)).after(here())
            let sel = query(locate-end)
            if sel.len() > 0 {
              let dic = lw.max-width-label.at(sel.first().location())
              let c-level = lw.max-width-label.get().level - 1
              let width-dic = dic.width.at(c-level, default: lw.default-width)
              marker-max-width = if curr-auto-label == "all" {
                calc.max(width-dic.list, width-dic.enum)
              } else {
                width-dic.list
              }
            }
          }
        }
      } else {
        //  全局使用, 一个文档只能使用一个
        let curr-auto-label = parse-auto-label(auto-label-width, rel-level)
        if curr-auto-label in ("all", "list", "each") {
          lw.update-global_width-label-dic(marker-max-width, "list")
          let dic = lw.max-width-label-global.final()
          let width-dic = dic.width.at(rel-level, default: lw.default-width)
          marker-max-width = if curr-auto-label == "all" {
            calc.max(width-dic.enum, width-dic.list)
          } else {
            width-dic.list
          }
        }
      }
    }

    /*feat: the style of indent label*/
    let curr-label-width = {
      if list-config-args.label-width != none {
        parse-label-width(
          list-config-args.label-width,
          marker-max-width,
          curr-list-level,
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

      let marker-width = if style == "native" {
        marker-max-width
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

      let label-inset = width + get-block-left-inset(curr-text-size, (curr-body-border.whole)(i)) + outer-left-inset

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


      // parse body (in order to determine how to display number)
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
        // record the left inset of block-level elems
        let item-inset = parent-item-inset.get()
        parent-number-box.update(push((
          body: marker-box.with(alone: is-alone),
          label-inset: label-inset,
          label-height: label-height,
          item-inset: item-inset,
        )))

        item-content(new-body.body)
      } else {
        parent-number-box.update(())
        parent-item-inset.update(())
        if new-body.inline == true {
          item-content(new-body.body, number-body: the-number)
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
  item-level.update(pop)
  list-level.update(it => it - 1)


  rl.update_resume-level(it => it - 1)

  lw.update-auto_label-level(it => it - 1)
  lw.update-global_label-level(it => it - 1)


  if curr-level == 0 and elem != "enum" {
    state("_default-text-style", (default-text-args,)).update(pop)
    state("_parent-hanging-indent_and_line-indent").update(pop)
  }
}
