#import "core/feat-enum-list.typ" as fel
#import "core/new-enum-list.typ" as nel: ElemType, HangingType
#import "core/inline-enum-list.typ" as iel
#import "lib/resume-lib.typ" as rl
#import "util/level-state.typ": *

#let deprecated-args = (
  "enum-spacing": ", use `whole-spacing` instead (since 0.3.0).",
  "enum-margin": ", use `body-margin` instead, which is more flexible (since 0.3.0).",
  "is-full-width": ", now `is-full-width: true` is equivalent to `body-format: (whole: (width: 100%))` (since 0.3.0).",
  "item-format": ", use `body-format` instead (since 0.3.0).",
)

#let ExportType = (
  "default": "default",
  "inline": "inline",
)

/// To generate methods for exporting and configuring `enum` and `list`.
#let get-list-enum-method(
  doc,
  elem, // "both", "list", "enum"
  indent,
  body-indent,
  label-indent,
  // is-full-width, // deprecated
  item-spacing,
  // enum-spacing, // deprecated, use whole-spacing instead
  // enum-margin, // deprecated
  hanging-type,
  hanging-indent,
  line-indent,
  label-width,
  body-format,
  label-format,
  // item-format,
  auto-base-level,
  label-align,
  label-baseline,
  auto-resuming,
  auto-label-width,
  checklist,
  enum-config,
  list-config,
  ref-numbering, /** new ver0.3.0 */
  supplement, /** new ver0.3.0 */
  tight-mode, /** new ver0.3.0 */
  tight-item-mode, /** new ver0.3.0 */
  step, /** new ver0.3.0 */
  label-inset, /** new ver0.3.0 */
  first-line-inset, /** new ver0.3.0 */
  description-config, /** new ver0.3.0 */
  body-margin, /*new new ver0.3.0*/
  whole-spacing, /*new new ver0.3.0*/
  style-type: ExportType.default, // TODO: inline??? feat-inline ??? (not export)
  ..args,
) = {
  // verfiy the deprecated arguments
  let use-deprecated-args = args.named().keys().filter(it => it in deprecated-args.keys())
  if use-deprecated-args != () {
    let msg = for it in use-deprecated-args {
      (
        "`" + it + "` is deprecated" + if deprecated-args.at(it) != none { deprecated-args.at(it) } else { "." },
      )
    }
    panic(
      msg.join("\n"),
    )
  }

  let nested-auto-resume = fel.nested-auto-resume
  if auto-resuming not in (none, false) {
    context if nested-auto-resume.get() {
      panic(
        (
          "For this method, `auto-resuming` can not be set to `"
            + repr(auto-resuming)
            + "`; i.e., these methods can not be used nested."
            + "\nHint: set `auto-resuming` to be `auto` only and then use the method `auto-resume-enum`."
            + "\nHint: Wrap the method in `#[]`."
        ),
      )
    }
    nested-auto-resume.update(true)
    rl.hold_resume-dic()
  }

  if auto-label-width != none {
    if auto-label-width != auto {
      let global-label-width = fel.global-setting-ID-auto-label-width
      context {
        assert(
          not global-label-width.get(),
          message: (
            "Inside this method, `auto-label-width` can be set once for non `auto` or `none`."
              + "\nBut found: "
              + repr(auto-label-width)
              + "."
              + "\nHint: set `auto-label-width` to be `auto` and then use the method `auto-label-item`."
              + "\nHint: Wrap the method in `#[]`."
          ),
        )
      }
      global-label-width.update(true)
    }
  }

  assert(
    style-type in ExportType,
    message: "`style-type` must be one of the following string: "
      + ExportType.keys().map(it => "\"" + it + "\"").join(", ")
      + "."
      + "\nBut found: "
      + repr(style-type)
      + ".",
  )

  let my-enum = if style-type == ExportType.inline {
    iel.inline-enum
  } else {
    nel.new-enum
  }
  let my-list = if style-type == ExportType.inline {
    iel.inline-list
  } else {
    nel.new-list
  }

  let override-enum = if auto-resuming in (none, false) and auto-label-width == none {
    my-enum
  } else {
    fel.feat-enum.with(auto-resuming: auto-resuming, auto-label-width: auto-label-width)
  }
  let override-list = if auto-resuming in (none, false) and auto-label-width == none {
    my-list
  } else {
    if elem == ElemType.list {
      if auto-label-width != none {
        fel.feat-list.with(auto-label-width: auto-label-width)
      } else {
        my-list
      }
    } else {
      fel.feat-list.with(auto-resuming: auto-resuming, auto-label-width: auto-label-width)
    }
  }

  assert(
    type(auto-base-level) == bool,
    message: "`auto-base-level` must be a bool." + "\nBut found: " + repr(auto-base-level),
  )

  let argument = (
    elem: elem,
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    item-spacing: item-spacing,
    hanging-type: hanging-type, // classic paragraph
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    label-width: label-width,
    body-format: body-format,
    label-format: label-format,
    // item-format: item-format,
    label-align: label-align,
    label-baseline: label-baseline,
    checklist: checklist,
    auto-base-level: auto-base-level,
    ref-numbering: ref-numbering, /** new ver0.3.0*/
    supplement: supplement, /** new ver0.3.0  */
    tight-mode: tight-mode, /** new ver0.3.0 */
    tight-item-mode: tight-item-mode, /** new ver0.3.0 */
    step: step, /** new ver0.3.0 */
    label-inset: label-inset, /** new ver0.3.0 */
    first-line-inset: first-line-inset, /** new ver0.3.0 */
    description-config: description-config, /** new ver0.3.0 */
    body-margin: body-margin, /*new new ver0.3.0*/
    whole-spacing: whole-spacing, /*new new ver0.3.0*/
  )
  if elem == ElemType.all {
    show enum: override-enum.with(
      ..args,
      ..argument,
      enum-config: enum-config,
      list-config: list-config,
      func-enum: override-enum,
      func-list: override-list,
      absolute-level: true,
      // curr-abs-enum-level: auto, // TODO
    )
    show list: override-list.with(
      ..args,
      ..argument,
      enum-config: enum-config,
      list-config: list-config,
      func-enum: override-enum,
      func-list: override-list,
      absolute-level: true,
    )

    doc
  } else if elem == ElemType.enum {
    show enum: override-enum.with(
      ..args,
      ..argument,
      func-enum: override-enum,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    // show list: override-list.with(
    //   elem: ElemType.enum,
    //   // func-enum: override-enum,
    //   func-list: override-list,
    //   enum-config: (:),
    //   list-config: (:),
    //   absolute-level: false,
    // )
    doc
  } else if elem == ElemType.list {
    // show enum: override-enum.with(
    //   elem: ElemType.list,
    //   func-enum: override-enum,
    //   enum-config: (:),
    //   list-config: (:),
    //   absolute-level: false,
    // )
    show list: override-list.with(
      ..args,
      ..argument,
      func-list: override-list,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    doc
  }

  if auto-resuming not in (none, false) {
    rl.recover_resume-dic()
    nested-auto-resume.update(false)
  }

  if auto-label-width != none {
    if auto-label-width != auto {
      [#metadata(fel.global-auto-label-ID)]
      fel.lw.update-global_label-width-clear()
      fel.global-setting-ID-auto-label-width.update(false)
    }
  }
}

/// Configures default styling for `enum` and `list`.
/// - doc (content): `enum` and `list` in `doc` to be process.
/// - indent (auto, length, array, function): The indentation of the `enum` or `list`.
///   - Usage:
///     ```
///     #show: el.default-enum-list.with(indent: 1em) // all items are indented by 1em
///     #show: el.default-enum-list.with(indent: (1em, 2em, auto)) // the first level is indented by 1em, the second level is indented by 2em, the third level and beyond are indented by the `enum.indent` or `list.indent`
///     #show: el.default-enum-list.with(indent: (1em, 2em, el.LOOP)) // the first level is indented by 1em, the second level is indented by 2em, the third level is indented by 1em, the fourth level is indented by 2em, and so on
///     #show: el.default-enum-list.with(indent: ((2em, 1em, auto), 1em, auto)) // in the first level, the first item is indented by 2em, the second item is indented by 1em, the third item and beyond are indented by the `enum.indent` or `list.indent`; the second level is indented by 1em, the third level and beyond are indented by the `enum.indent` or `list.indent`
///     #show: el.default-enum-list.with(indent: it => it.level * 1em)
///     ```
///   - `auto`: The indentation is determined by the `enum.indent` or `list.indent`.
///   - `length`: The value of `indent`.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, the item at `level`-th level will be indented by the corresponding value of the array at position `level - 1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///     - The elements in the array can also be an array, where the element at position `n - 1` applies to the item of index `n`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag` (since ver0.3.0): The tag of the current item.
///       - `it.elem-tag` (since ver0.3.0): The tag of the current enum or list.
///       - `it.e` (since ver0.3.0): The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type` (since ver0.3.0): The hanging type of the current level.
///       - `it.marker` (since ver0.3.0): The marker of the current label if it is a `list`.
///       - `it.number` (since ver0.3.0): The number of the current label if it is a `enum`.
///       - `it.label-width` (dictionary) (since ver0.3.0): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent` (since ver0.3.0): The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get` (since ver0.3.0): Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - body-indent (auto, length, array, function): The indentation of the item body, i.e., the space between the label and the body of each item.
///   - Usage: See `indent`.
///   - `auto`: The indentation is determined by the `enum.body-indent` or `list.body-indent`.
///   - `length`: The value of `body-indent`.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be indented by the corresponding value of the array at position `level - 1`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - label-indent (auto, length, array, function): The indentation for the label (the enum's number or the list's marker).
///   - Usage: See `indent`.
///   - ⚠️ *Breaking change*: The `label-indent` now does not impact the width of the label nor the first-line indentation of the body.
///   - `auto`: The label is not indented (equivalent to `0pt`).
///   - `length`: The label is indented by the given value.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be indented by the corresponding value of the array at position `level - 1`.
///     - See also `indent`
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - label-inset (auto, length, array, function): Adds an inset to the label (default: `0pt` if `auto`).
///   - Note: It translates labels horizontally (without affecting the label width and the inset of the first line).
///   - Usage: See `indent`.
///   - `auto`: The label has not inset (equivalent to `0pt`).
///   - `length`: The inset is the specified value.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be inset by the corresponding value of the array at position `level - 1`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - body-margin (auto, relative, dictionary, array, function): The left and right margin of the current item body. Based on the `itemize` design, `label-indent`, the label's content, `body-indent` are belong to the label's body. For `ltr`, the left margin starts from the left of the label's body; for `rtl`, the right margin starts from the right of the label's body.
///   - In particular, `body-margin` can control the starting alignment position of the block-level element in the item body and the actual `100%` width.
///   - *Note*: In general, the layout of `inline-level` elements in the item body are not affected by `body-margin` (except for the actual `100%` width).
///     - The layout of `inline-level` elements usually are affected by `line-indent` and `hanging-indent`.
///   - With this attribute, it is now very easy to implement some lists with very special layouts.
///     - Example: The body of all nested lists is aligned to the left.
///       ```typst
///       #show: el.default-enum-list.with(
///         body-margin: 0pt,
///         indent: (2em, auto),
///         label-indent: it => { -it.label-width.current - it.e.body-indent },
///       )
///       #set enum(full: true)
///       + Level One
///         + Level Two
///           + #lorem(2)
///         + Level Two
///       + Level One
///       ```
///     - Example: Align the (first-level) item body and the first line of the paragraph, e.g., indent both by 2em.
///       ```typst
///       #let indent = 2em
///       #set par(first-line-indent: (amount: indent, all: true))
///       #show: el.default-enum-list.with(
///         body-margin: (0pt, auto),
///         indent: (indent, auto),
///         label-indent: it => {
///           if it.level == 1 {
///             -it.label-width.current - it.e.body-indent
///           } else {
///             auto
///           }
///         },
///       )
///       #lorem(15)
///       + #lorem(15)
///         + #lorem(15)
///       + #lorem(15)
///       ```
///     - Example: Align the (first level) item body and the first line of the paragraph with the `paragraph` hanging style.
///       ```typst
///       #let indent = 2em
///       #set par(first-line-indent: (amount: indent, all: true))
///       #show: el.default-enum-list.with(
///         body-margin: (0pt, auto),
///         indent: (0pt, indent, auto),
///         label-indent: it => {
///           if it.level == 1 {
///             indent - it.label-width.current - it.e.body-indent
///           } else {
///             auto
///           }
///         },
///       )
///       #lorem(15)
///       + #lorem(15)
///         + #lorem(15)
///       + #lorem(15)
///       ```
///   - For `ltr` typography, `body-margin.left` (left body margin) is called `start-margin`, `body-margin.right` (right body margin) is called `end-margin`; for `rtl` typography, `body-margin.left` (left body margin) is called `end-margin`, `body-margin.right` (right body margin) is called `start-margin`.
///   - `auto`: Set `start-margin` and `end-margin` to `auto`. In this case:
///     - `end-margin` is `0pt`
///     - `start-margin` is the label's body width, i.e., the rendered width of the label + `label-indent` + `body-indent`. (Also affected by the `label-width`.)
///       - *Note*: This also works for `hanging-type` is `paragraph` (and so `paragraph-*` method); but in this case, the `hanging-indent` and `line-indent` are reset to make the paragraphs in item body aligned to the left.
///   - `relative`: Set `start-margin` and `end-margin` to the same specified value.
///     - For `start-margin`, the ratio part of `start-margin` is relative to the `label-width`, that is, `start-margin` = `start-margin.length + start-margin.ratio × label's body width`, where *label's body width* = the rendered width of the label + `label-indent` + `body-indent`.
///     - For `end-margin`, the ratio part of `end-margin` is relative to the parent container's width.
///   - `dictionary`: The key values are `left` and `right`, each of which can be `relative`, `auto`. Then the `start-margin` and `end-margin` are set to the corresponding value.
///   - `array` (level-property): The elements are `relative`, `auto`, `dictionary`, or `array`. The `level`-th of the `enum` or `list` will be set to the corresponding value of the array at position `level - 1`.
///     - See `indent`.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => relative | auto | dictionary | array`.
///     - See `indent`.
/// - hanging-type (string, array, function): The hanging type of the paragraphs inside the item body.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(hanging-type: "paragraph")
///     #show: el.default-enum-list.with(hanging-type: ("classic", "paragraph", "classic"))
///     #show: el.default-enum-list.with(hanging-type: it => if calc.odd(it.level) {"paragraph"} else {"classic"})
///    ```
///   - `"classic"`: The native behavior of `enum` or `list`.
///   - `"paragraph"`: For each level, paragraphs inside the item body are not indented; they align to the current `body-margin`'s beginning margin (the same as the `paragraph-*` methods).
///     - Note: But the current `body-margin`'s beginning margin is the same as the `"classic"` one.
///     - Hint: See also the `inline-*` methods.
///   - `array` (level-property): The elements are `"classic"` or `"paragraph"`. Each level of `hanging-type` will be determined by the corresponding value of the array at position `level - 1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value ("classic" or "paragraph") will be used for each level.
///     - The function form: `it => "classic" | "paragraph"`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
/// - line-indent (auto, length, array, function): The indentation for the first line of a paragraph, excluding the first paragraph (default: `auto`).
///   - Note: Paragraphs inside `block-level` elements that appear in the item body are not processed (the related settings are not yet exposed).
///   - Usage: See `indent`.
///   - `auto`: It uses the first line indent of the current paragraph (`par.first-line-indent.amount`).
///   - `length`: The value of the line indent.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be indented by the corresponding value of the array at position `level - 1`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-indent`, `it.label-inset`, `it.body-indent`, `it.indent`, `it.body-margin`: All the horizontal spacing parameters.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - first-line-inset (auto, length, array, function): Adds an inset to the first line of the item body (default: `0pt` if `auto`). If there is no first line, it is ignored.
///   - Note: Paragraphs inside `block-level` elements that appear in the item body are not processed (the related settings are not yet exposed).
///   - Usage: See `indent`.
///   - `auto`: The first line is not inset (equivalent to `0pt`).
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be inset by the corresponding value of the array at position `level - 1`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-indent`, `it.label-inset`, `it.body-indent`, `it.indent`, `it.body-margin`: All the horizontal spacing parameters.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - hanging-indent (auto, length, array, function): The hanging indentation for item body.
///   - Note: Paragraphs inside `block-level` elements that appear in the item body are not processed (the related settings are not yet exposed).
///   - Usage: See `indent`.
///   - `auto`: It uses the hanging indent of the current paragraph (`par.hanging-indent`).
///   - `length`: The hanging indentation is fixed to the specified value.
///   - `array` (level-property): The elements are `length`, `auto` or `array`, each level of the item will be indented by the corresponding value of the array at position `level - 1`.
///     - See also `indent`
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => length | auto | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
///       - `it.label-indent`, `it.label-inset`, `it.body-indent`, `it.indent`, `it.body-margin`: All the horizontal spacing parameters.
///       - `it.label-width` (dictionary): The width info of the current label.
///         - `it.label-width.max`: The maximum width of the labels in the current level.
///         - `it.label-width.current`: The current width of the label.
///       - `it.parent`: The parameter info of the parent containing the current list — the parent's construction element `e`, the item `n` where the parent is located, and the horizontal spacing parameters: `label-indent`, `label-inset`, `body-indent`, `indent`, `body-margin`, `label-width` (`max`, `current`)
///       - `it.get`: Access the parameter info (see `it.parent`) of the current list's ancestors by level
/// - whole-spacing (auto, relative, fraction, dictionary, array, function): The above and below spacing of the current `enum` or `list`.
///   - Usage: See `item-spacing`.
///   - `auto`: The above and below spacing are set to `auto` (See also `block.spacing`). In this case, it may be affected by the `tight-mode`.
///   - `relative`, `fraction`: The above and below spacing are set to the specified value.
///   - `dictionary`: The key values are `above` and `below`, each of which can be `relative`, `fraction` or `auto`. Then the above and below spacing are set to the corresponding value.
///   - `array` (level-property): The elements are `relative`, `fraction`, `auto`, or `dictionary`, the `level`-th of the `enum` or `list` will be set to the corresponding value of the array at position `level - 1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => auto | relative | fraction | dictionary`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
/// - item-spacing (auto, relative, fraction, dictionary, array, function): Spacing between items.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(item-spacing: 1em)
///     #show: el.default-enum-list.with(item-spacing: (below: 1fr, above: auto))
///     #show: el.default-enum-list.with(item-spacing: (1em, (below: 1fr), auto))
///     #show: el.default-enum-list.with(item-spacing: it => it.level * 1em)
///     ```
///   - `auto`: The spacing is determined by the `enum.spacing` or `list.spacing`. And in this case, it may be affected by the `tight-item-mode`.
///   - `relative`, `fraction`: The value of spacing between each item; whose rule is the same as `block.spacing`.
///   - `dictionary`: The key values are `above` and `below`, each of which can be `relative`, `fraction` or `auto`.
///     - Note: The `above` spacing is ignored for the first item, but the `below` spacing is added to the last item.
///     - The spacing between the previous and current items is the previous `below` plus the current `above`.
///       - Note: This differs from setting `item-spacing` to a concrete value.
///   - `array` (level-property): The elements are `relative`, `fraction`, `dictionary`, `auto`, and `array`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => relative | fraction | dictionary | auto | array`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
/// - tight-mode (auto, string, dictionary, array, function): If `whole-spacing` are `auto`, then `tight-mode` is used to determine the above and below spacing of `enum` or `list`.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(tight-mode: "always-tight")
///     #show: el.default-enum-list.with(tight-mode: ("never-tight", "always-tight", auto))
///     #show: el.default-enum-list.with(tight-mode: (tight: auto, not-tight: 2em))
///     ```
///   - Background: For the current `enum` or `list`, the above spacing (denoted as `above-spacing`) and the below spacing (denoted as `below-spacing`) are determined by the following cases:
///     1. The current `enum` or `list` is `tight` (i.e. `enum.tight` or `list.tight` is `true`, see the `tight-item-mode`);
///     2. The current `enum` or `list` is not `tight` (i.e. `enum.tight` or `list.tight` is `false`, see the `tight-item-mode`);
///     3. There is a `parbreak()` between the above paragraph and the current `enum` or `list`: like
///        ```typst
///        The preceding paragraph.  // below has a `parbreak()`
///
///        + items
///        ```
///     4. There is no `parbreak()` between the above paragraph and the current `enum` or `list`: like
///        ```typst
///        The preceding paragraph.
///        + items
///        ```
///     - Combining these cases, we call
///       - case 1 with case 3 *par-tight* (i.e. `tight` with a `parbreak()` above),
///       - case 2 with case 3 *par-not-tight*,
///       - case 1 with case 4 *tight*,
///       - case 2 with case 4 *not-tight*.
///     - Note: In native Typst behavior, cases *par-not-tight*, *par-tight* and *not-tight* are the same.
///   - `auto`: Use the native Typst behavior of `enum` or `list`.
///     - for the *tight* case: `above-spacing` is `enum.spacing` or `list.spacing` (if `auto`, representing `par.leading`); for the other cases it is `auto` (representing `par.spacing`).
///     - `below-spacing` is `auto` (representing `par.spacing`)
///   - `"always-tight"`: `above-spacing` and `below-spacing` are `par.leading` and `auto`, respectively.
///   - `"never-tight"`: `above-spacing` and `below-spacing` are `par.spacing` and `auto`, respectively.
///   - `"compact-tight"`: `above-spacing` and `below-spacing` are both `par.leading`.
///   - `dictionary`: The keys are: `tight`, `not-tight`, `par-tight`, `par-not-tight`, with values of `auto`, `relative`, `fraction`, `array` (with two elements representing the above and below spacing).
///     - If values of the keys are taken `auto`, `relative`, `fraction`, then they represent the `above-spacing`; `below-spacing` is `auto`.
///     - If values of the keys are `array`, then the first element represents the `above-spacing`, and the second element represents the `below-spacing`.
///     - If `tight` is `auto`, use `enum.spacing` or `list.spacing` (if `auto`, representing `par.leading`); if `not-tight` is `auto`, use `auto` (representing `par.spacing`); if `par-tight` and `par-not-tight` are `auto`, use the value of `not-tight`
///     - `tight`, `not-tight`, `par-tight`, `par-not-tight` represent the *tight* case, *not-tight* case, *par-tight* case, *par-not-tight* case, respectively.
///     - *Note*: In order to set `below-spacing` from `par-tight` and `par-not-tight`, you need to add in the document:
///       ```typst
///       #show: el.config.auto-detect-tight
///       ```
///     - Example:
///       ```typst
///       #let first-level-tight-mode = (
///         tight: (auto, 0.65em),
///         par-tight: (auto, auto),
///         not-tight: (1.5em, 1.5em),
///         par-not-tight: (2em, 2em),
///        )
///       #show: el.default-enum-list.with(tight-mode: (first-level-tight-mode, auto))
///       #show: el.config.auto-detect-tight
///       ```
///   - `array` (level-property): Sets `tight-mode` by level. The elements are `auto`, `"always-tight"`, `"never-tight"`, `"compact-tight"`, `dictionary`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => auto | "always-tight" | "never-tight" | "compact-tight" | dictionary`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
/// - tight-item-mode (auto, string, dictionary, array, function): If `item-spacing` is `auto`, then `tight-item-mode` is used to determine the spacing between items.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(tight-item-mode: "always-tight")
///     #show: el.default-enum-list.with(tight-item-mode: ("never-tight", auto))
///     #show: el.default-enum-list.with(tight-item-mode: ((tight: auto, not-tight: 2em), auto))
///     ```
///   - Background: The spacing between items is determined by the following cases:
///     1. *tight*: There is no `parbreak()` between items, like:
///       ```typst
///       + item one // no `parbreak()` below
///       + item two // no `parbreak()` below
///       + item three
///       ```
///     2. *not-tight*: There is a `parbreak()` between items, like:
///       ```typst
///       + item one // has a `parbreak()` below
///
///       + item two
///       + item three
///       ```
///   - `auto`: Use the native Typst behavior of `enum` or `list`.
///     - The spacing uses `enum.spacing` or `list.spacing` (if `auto`, representing `par.leading` for the *tight* case and `par.spacing` for the *not-tight* case).
///   - `"always-tight"`: The spacing is `par.leading`.
///   - `"never-tight"`: The spacing is `par.spacing`.
///   - `dictionary`: The keys are `tight`, `not-tight`, with values of `auto`, `relative`, `fraction`.
///     - If `tight` is `auto`, use `par.leading`
///     - If `not-tight` is `auto`, use `par.spacing`
///     - Use the values of `tight` and `not-tight` for the *tight* case and the *not-tight* case, respectively.
///   - `array` (level-property): Sets `tight-item-mode` by level. The elements are `auto`, `"always-tight"`, `"never-tight"`, `dictionary`.
///     - See also `tight-mode`.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => auto | "always-tight" | "never-tight" | dictionary`
///     - See also `tight-mode`.
/// - label-width (auto, relative, string, dictionary, array, function): Render the width of the label.
///   - Usage:
///     ```typst
///     #show : el.default-enum-list.with(label-width: 2em)
///     #show : el.default-enum-list.with(label-width: ((amount: 2em, style: "constant"), auto))
///     ```
///   - *Notation*:
///     - `real-width`: The real width of the current label's content (calculated by `measure`).
///     - `max-width`: The maximum value of all `real-width`s in the current level.
///   - `auto`: Use the native behavior. That is, the current width of the label will be set to `max-width`.
///   - `relative`: This is the same as `(amount: len, style: "default")`.
///   - `"max"`: This is the same as `auto`.
///   - `dictionary`: The keys are `amount` and `style`.
///     - `amount` can be taken `relative`, `auto` or `"max"`
///       - `relative`: The value is `amount.length + amount.ratio × real-width`.
///       - `auto`: `real-width`.
///       - `"max"`: `max-width`.
///     - `style` can be `"default"`, `"constant"`, `"auto"`, or `"native"`.
///       - `"default"`: If `real-width` is less than `amount`, the label's width is rendered as `amount`; otherwise, the label's width is rendered as `real-width`.
///       - `"constant"`: The label's width is rendered as `amount`.
///       - `"auto"`: The label's width is rendered as `real-width`.
///       - `"native"`: The label's width is rendered as `max-width`.
///         - Also `amount` is set to `max-width` (since ver0.3.0).
///       - *Note*: In order to make the layout more in line with expectations, the `start-margin` (i.e., `body-margin.left` if `text.dir` is `ltr`, `margin-body.right` if `text.dir` is `rtl`) will be set to `amount + body-indent` (if `start-margin` is `auto`).
///   - `array` (level-property): The elements are `auto`, `relative`, `string`, `dictionary` or `array`. The element at the position `level - 1` will be used for the `level`-th level.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => auto | relative | string | dictionary | array`
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag` (since ver0.3.0): The tag of the current item.
///       - `it.elem-tag` (since ver0.3.0): The tag of the current enum or list.
///       - `it.e` (since ver0.3.0): The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type` (since ver0.3.0): The hanging type of the current level.
///       - `it.marker` (since ver0.3.0): The marker of the current label if it is a `list`.
///       - `it.number` (since ver0.3.0): The number of the current label if it is a `enum`.
///       - `it.max-width` (since ver0.3.0): The maximum width of the labels in the current level.
///       - `it.width` (since ver0.3.0): The current width of the label.
/// - label-align (auto, alignment, array, function): The `alignment` that enum numbers and list markers should have.
///   - Note: This is different with `enum.number-align` and `list.marker-align` (the latter are align whole enum numbers and list markers). We suggest to make `enum.number-align` and `list.marker-align` to be default when using `itemize`.
///   - *Note*: In general, this parameter is used to set *horizontal* alignment for label. If want 2D-alignment, then see `label-baseline`.
///   - Usage:
///     ```typst
///     #show : el.default-enum-list.with(label-align: left)
///     #show : el.default-enum-list.with(label-align: (left, right))
///     ```
///   - `auto`: Use `end`.
///   - `alignment`: The alignment of the label.
///   - `array` (level-property): The elements are `auto`, `alignment` or `array`, each level of the item will be set to the corresponding value of the array at position `level - 1`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => auto | alignment | array`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the item.
///       - `it.elem-tag`: The tag of the `enum` or `list`.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
/// - label-baseline (auto, relative, string, dictionary, array, function): Set the baseline style of the label body.
///   - Usage:
///     ```typst
///     #show : el.default-enum-list.with(label-baseline: "center")
///     #show : el.default-enum-list.with(label-baseline: ("top-item", auto))
///     #show : el.default-enum-list.with(label-baseline: (same-line-style: "top-item")) // The default behavior of native `enum` or `list` (Typst 0.15.1)
///     #show : el.default-enum-list.with(label-baseline: 1em)
///     #show : el.default-enum-list.with(label-baseline: (impact-first-line: true))
///     ```
///   - *Note*: By default, `itemize` prioritizes the vertical component of `enum.number-align` or `list.marker-align`. For `label-baseline` to control the vertical alignment of the label body, set the corresponding `number-align`/`marker-align` to its default value (i.e., `end`).
///   - The full form of `label-baseline` is a dictionary with the following keys:
///     - `amount`
///     - `at`
///     - `relative-to`: a dictionary with keys:
///       - `to`, `at`, `shift`
///     - `same-line-style`: a dictionary with keys:
///       - `amount`, `at`, `relative-to` (a dictionary with keys: `to`, `at`, `shift`)
///     - `impact-first-line`
///   - `auto`: The default of `label-baseline` configuration (i.e., using the native behavior), which is the same as `(amount: 0pt, at: auto, relative-to: "baseline", same-line-style: auto, impact-first-line: auto) `
///   - `relative`: An amount to shift the label baseline by.
///     - The same as `(amount: label-baseline)`.
///     - The ratio part is relative to the (rendered) height of the (whole) label body.
///   - `"center"`, `"top"`, `"bottom"`, `"baseline"`: The (first line of the) label body and the first line of the item body will be aligned at the specified (i.e., horizontal, top, bottom, baseline) position. For example, for `"top"`, it means that the top of label body and the top of item body will be aligned.
///     - The same as `(amount: label-baseline, at: at)`, where `at` is `auto` if `label-baseline` is `baseline`, `top` if `label-baseline` is `top`, `bottom` if `label-baseline` is `bottom`, and `horizon` if `label-baseline` is `center`.
///   - `"top-item"`, `"horizon-item"`, `"bottom-item"`: The top, horizontal, or bottom of the label body will be aligned to the top, horizontal, or bottom of the whole item body, respectively.
///     - The same as `(amount: label-baseline)`.
///     - *Note*: `itemize` uses the height of the first character (i.e., [A]) in the first line of the item body. If you manually set the font style of the paragraph's text, this alignment may not be accurate. It is recommended to use the `style` parameter in `body-format` for adjustments.
///   - `dictionary`: The keys are
///     - `amount` (`auto`, `relative`, `"center"`, `"top"`, `"bottom"`, `"baseline"`, `"top-item"`, `"horizon-item"`, `"bottom-item"`): The shift amount of the label body.
///       - `auto` == `0pt` (default)
///       - *Note*: Only when `amount` is `auto` or `relative`, the keys `at` and `relative-to` can work.
///     - `at` (`auto`, `top`, `bottom`, `horizon`): Used to set what the position of the label body to be aligned; the default of `at` is `auto`, meaning the the baseline of the (first line of the) label body. See also the `baseline` parameter of `box`, https://typst.app/docs/reference/layout/box/#parameters-baseline.
///     - `relative-to` (`string`, `content`, `relative`, `array`, `dictionary`): Used to set the offset relative to what position (of item body). Default is `"baseline"`.
///       - `"bottom"`, `"center"`, `"top"`, `"baseline"`: Relative to the first line of the current item body.
///       - `"top-item"`, `"horizon-item"`, `"bottom-item"`: Relative to the top, horizontal, or bottom of the whole item. In this case, `at` is set to `top`, `horizon`, `bottom`, respectively. Users can not set it again.
///       - `content`: The passed content is used to calculate the height. The same as `(to: relative-to, at: auto, shift: 0pt)`.
///       - `relative`: Representing the height of the first line of the current item body. The same as `(to: [A], at: auto, shift: relative-to)`.
///         - The ratio part is relative to the (rendered) height of the (whole) item body.
///       - `array` with 2 elements like `(relative-shift, relative-to)`. This means the label body should be aligned to `relative-to` with the offset of `relative-shift`.
///          - The first element `relative-shift` can be `content` or `relative`.
///          - The second element `relative-to` can be `"bottom"`, `"center"`, `"top"`, `"baseline"`.
///       - `dictionary` with keys: `to`, `at`, `shift`. This means the label body should be aligned to the content of `to`, at the `at` position with the offset of `shift`.
///          - *Note*: Usually, the content of `to` should be added to the first line of the item body.
///          - `to` (`auto`, `content`): If `auto`, it is `[A]`. Default is `[A]`.
///          - `at` (`auto`, `top`, `bottom`, `horizon`): Used to set what the position of `to` to be aligned. Default is `auto`.
///          - `shift` (`relative`): The offset of `shift` at `at` position. The ratio part is relative to the height of the content `to`. Default is `0pt`.
///     - `impact-first-line` (`auto`, `bool`): Whether to impact the first line of the label body by `label-baseline`.
///       - `auto`: If `hanging-typ` is `"paragraph"`, then `true`, else `false`.
///     - `same-line-style` (`auto`, `string`, `dictionary`): If labels from different levels appear on the same line, their alignment is determined by `same-line-style`. That is, it deals with like `+ + Item`. Default is `auto`.
///       - In Typst 0.15, like `+ + Item`, the first label is "top-aligned" to `+ Item` (since `enum` or `list` has no baseline). In default, in `itemize` (since ver0.2.0), the first label and `+ Item` is aligned at baseline.
///       - `auto`: Use the current setting of `label-baseline`.
///       - `"top"`, `"center"`, `"bottom"`, `"baseline"`: The (first line of the) label body on the same line and the first line of the item body will be aligned at the specified (i.e., top, horizontal, bottom, baseline) position.
///       - `"top-item"`, `"horizon-item"`, `"bottom-item"`: The top, horizontal, or bottom of the label body on the same line will be aligned to the top, horizontal, or bottom of the whole item body, respectively.
///       - `"top-label"`, `"center-label"`, `"bottom-label"`, `"baseline-label"`: The top, horizontal, or bottom of the label body on the same line will be aligned to the top, horizontal, or bottom of the *last* label body, respectively.
///       - `dictionary` with keys `amount`, `at`, `relative-to`. This means the label body on the same line will be shifted at the `at` position with the offset of `amount`, and will be aligned determined by `relative-to`.
///         - `amount` (`auto`, `relative`): The shift amount of the label body on the same line. Default is `0pt`.
///           - `auto` == `0pt`.
///           - The ratio part is relative to the (rendered) height of the (whole) label body.
///         - `at` (`auto`, `top`, `bottom`, `horizon`): Used to set what the position of the label body on the same line to be aligned. Default is `auto` (the baseline of the label body).
///         - `relative-to` (`string`, `array`, `dictionary`): Used to set the offset relative to what position (of item body). Default is `"baseline"`. See also the key `relative-to` in `label-baseline`.
///           - `"top"`, `"center"`, `"bottom"`, `"baseline"`: Relative to the first line of the current item body.
///           - `"top-item"`, `"horizon-item"`, `"bottom-item"`: Relative to the top, horizontal, or bottom of the whole item.
///           - `"top-label"`, `"center-label"`, `"bottom-label"`, `"baseline-label"`: Relative to the top, horizontal, or bottom of the last label body.
///           - `content`: The passed content is used to calculate the height. The same as `(to: relative-to, at: auto, shift: 0pt)`.
///           - `relative`: Representing the height of the first line of the current item body. The same as `(to: [A], at: auto, shift: relative-to)`.
///             - The ratio part is relative to the (rendered) height of the (whole) item body.
///           - `array` with 2 elements like `(relative-shift, relative-to)`. This means the label body on the same line should be aligned to `relative-to` with the offset of `relative-shift`.
///             - The first element `relative-shift` can be `content` or `relative`.
///             - The second element `relative-to` can be `"bottom"`, `"center"`, `"top"`, `"baseline"`.
///           - `dictionary` with keys `to`, `at`, `shift`. This means the label body on the line should be aligned to `to` (the last label body or content), at the `at` position with the offset of `shift`.
///             - `to` (`auto`, `"label"`, `content`): If `"label"`, this means the label body on the line should be aligned to the last label body. If `auto`, it is `[A]`.
///             - `at` (`auto`, `top`, `horizon`, `bottom`): Used to set what the position of `to` to be aligned.
///             - `shift` (`relative`): The offset of `shift` at `at` position. The ratio part is relative to the height of the content `to` if `to` is `content` or the last label body if `to` is `"label"`.
///         - Example: In the following, the bottom of the first label is aligned to the bottom of second label.
///           ```typst
///           #show: el.default-enum-list.with(
///             body-format: (stroke: (red, auto)),
///             label-baseline: ((same-line-style: "bottom-label"), auto),
///           )
///           #set list(marker: [#circle(width: 1em, fill: red)])
///           - - #el.item(label-format: (stroke: blue), [$vec(1, 1, 1)$]) #lorem(20)
///             #lorem(10)
///           ```
///   - `array` (level-property): The elements are `auto`, `relative`, `"center"`, `"top"`, `"bottom"`, `"top-item"`, `"horizon-item"`, `"bottom-item"`, `"baseline"`, `dictionary`, or `array`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///     - The elements in the array can also be an array, where the element at position `n - 1` applies to the item of index `n`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => auto | relative | "center" | "top" | "bottom" | "top-item" | "horizon-item" | "bottom-item" | "baseline" | dictionary | array`.
///     - If the returned value is a `array`, then the elements in the array will be used for each item.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag`: The tag of the current item.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///       - `it.marker`: The marker of the current label if it is a `list`.
///       - `it.number`: The number of the current label if it is a `enum`.
/// - label-format (none, dictionary, function, array): Customize item labels.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(label-format: (stroke: red))
///     #show: el.default-enum-list.with(label-format: (fill: (red, blue, auto)))
///     #show: el.default-enum-list.with(label-format: (emph, strong))
///     #show: el.default-enum-list.with(label-format: it => {
///       if it.level == 1 {
///         circle(it.body, inset: 1pt)
///       } else {
///         strong(it.body)
///       }
///     })
///     ```
///   - `none`: Does not take effect.
///   - `content`: The content of the label.
///   - `dictionary`: The keys are
///     - `format`: The format of the label.
///       - `none` == `auto` (default): The same as `it => it.body`.
///       - `content`: The content of the label.
///       - `function` (base-property):
///         - The function form: `body => content`. Apply the function to the label's content (generated by `enum.item.number` + `enum.numbering` or `list.marker`).
///         - The `function` should be wrapped in an `array`, like: `(strong, )`.
///       - `array` (level-property): The elements are `content`, `function` (base-property) or `array`. The element at the position `level - 1` will be used for the `level`-th level.
///         - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///         - otherwise, the last value of the array will be used for residual levels.
///         - If `array`, the (`n-1`)-th element of the array applies to the `n`-th item label at the current level.
///       - `function` (level-property):
///         - The function form: `it => content`.
///         - If the return value is `array`, then each element in the array should be `auto`, `content` or `function` (base-property), which will be applied to the label's content for each item in the current level.
///         - Access the following values available on `it`:
///           - `it.body`: The current label's content.
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the item.
///           - `it.elem-tag`: The tag of the `enum` or `list`.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///         - Example:
///           ```typst
///           #show: el.default-enum-list.with(label-format: (format: it => {
///             if it.tag == "strong" {
///               set text(fill: red, weight: "bold")
///               it.body
///             } else {
///               it.body
///             }
///           }))
///           + #el.item(tag: "strong") #lorem(2)
///           + #lorem(2)
///             + #lorem(2)
///             + #el.item(tag: "strong") #lorem(2)
///           ```
///     - `stroke`, `radius`, `outset`, `fill`, `inset`, `clip`: The *border* of the label, which are the same as `box` arguments.
///       - `auto`: The default value of the argument.
///       - the values of the corresponding named arguments of `box` that can be set.
///       - `array` (level-property): The elements are `auto`, the values of the corresponding named arguments of `box` that can be set, or `array`. The element at the position `level - 1` will be used for the `level`-th level.
///         - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///         - otherwise, the last value of the array will be used for residual levels.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | the value of the corresponding named argument of `box` that can be set | array`
///         - Access the following values available on `it`:
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the item.
///           - `it.elem-tag`: The tag of the `enum` or `list`.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///     - `align` (`auto`, `alignment`, `array`, `function`): The alignment of the label. See `stroke` etc. Default is `start`.
///     - `width-style`, `height-style`: Set the width and height style of the label.
///       - `width-style`:
///         - *Note*: This does not affect the maximum width of the labels in the current level.
///         - `"real-width"`, `"label-width"`, `relative`: The same as `(amount: len, stretched: false)`.
///           - `"real-width"`: The real width of the label.
///           - `"label-width"`: The rendered width of the label determined by the `label-width` parameter.
///         - `dictionary`: The keys are
///           - `amount` (`"real-width"`, `"label-width"`, or `relative`): Set the width of the label to be the specified value.
///             - The ratio part of `amount` is relative to the real width of the label, i.e., the value of `amount` is `amount.ratio × real-width + amount.length`, where `real-width` is the real width of the label.
///           - `stretched` (bool): If `true`, the rendered width of the label will be set to `amount` + `inset.x`, else the rendered width of the label will be determined by the `label-width` parameter (in particular, it does not affect the layout of the item body.).
///       - `height-style`:
///         - `"real-height"`, `relative`: The same as `(amount: len, stretched: false)`.
///         - `"real-height"`: The real height of the label.
///         - `dictionary`: The keys are
///           - `amount` (`"real-height"`, `relative`): Set the height of the label to be the specified value.
///             - The ratio part of `amount` is relative to the real height of the label, i.e., the value of `amount` is `amount.ratio × real-height + amount.length`, where `real-height` is the real height of the label.
///           - `stretched` (bool): If `true`, the rendered height of the label will be set to `amount` + `inset.y`, else use the real height of the label (in particular, it does not affect the layout of the item body.).
///     - Example
///       ```typst
///       #show: el.default-enum-list.with(label-format: (
///         stroke: (red, blue),
///         align: center + horizon,
///         width-style: (amount: 1.2em, stretched: true),
///         height-style: (amount: 1.2em, stretched: true),
///         radius: 1em,
///       ))
///       #set enum(numbering: "1.A")
///       + #lorem(10)
///       + #lorem(10)
///         + #lorem(10)
///         + #lorem(10)
///       ```
///   - `function` (base-property): The same as `(format: func)`.
///   - `array` (level-property): The same as `(format: (func1, func2,...))`.
///   - `function` (level-property): The same as `(format: func)`.
/// - body-format (none, dictionary, function, array): Customize item bodies.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(body-format: (stroke: red))
///     #show: el.default-enum-list.with(body-format: (whole: (stroke: (red, blue, auto))))
///     #show: el.default-enum-list.with(body-format: (
///       inner: (
///         stroke: (red, blue, auto),
///         inset: (5pt, 5pt, auto),
///       ),
///     ))
///     #show: el.default-enum-list.with(body-format: (
///       style: (
///         fill: (red, blue, auto),
///         size: (1.2em, 12pt, auto),
///       )
///     ))
///     #show: el.default-enum-list.with(body-format: (emph, strong, auto))
///     #show: el.default-enum-list.with(body-format: it => {
///       if it.e.tight {
///         show: strong
///         set text(fill: red)
///         it.body
///       } else {
///         it.body
///       }
///     })
///     ```
///   - `none`: Does not take effect.
///   - `dictionary`: The keys are
///     - `style`: Any `text` named arguments (like: `fill`, `size`, `font`, etc.; see https://typst.app/docs/reference/text/text/). The *text-style* of the item body.
///       - See also `..args`.
///     - `whole`, `outer`, `inner`: Format the item body.
///       - `whole`: Wrap the entire `enum` or `list`
///       - `outer`: Wrap the item (including the label)
///       - `inner`: Wrap the item body (excluding the label)
///         - Example:
///           ```typst
///           #show: el.default-enum-list.with(body-format: (
///             inner: (
///               stroke: (red, blue, auto),
///               inset: (5pt,),
///             ),
///             outer: (
///               stroke: (yellow, green, auto),
///               inset: (5pt,),
///             ),
///             whole: (
///               stroke: (purple, maroon, auto),
///               inset: (5pt,),
///             ),
///           ))
///           + Item one
///             + Sub Item one
///             + Sub Item two
///           + Item two
///           ```
///       - *Note*: If `whole`, `outer`, and `inner` are omitted, the default is `outer`.
///       - `whole`, `outer`, or `inner` can be taken `dictionary` with the following keys:
///         - `format` (`none`, `function`, `array`): The format of the item body.
///           - See the `format` in `label-format`.
///           - *Note*: Use the `format` function (since ver0.3.0) to replace the `item-format` (in ver0.2.0) parameter .
///         - `stroke`, `radius`, `outset`, `fill`, `inset`, `clip`, `breakable`, `sticky`, `width`: The *border* of the item body, which are the same as the `block` named elements (note: `width` only works for `whole`).
///           - `auto`: The default value of the argument.
///           - the values of the corresponding named arguments of `block` that can be set.
///           - `array` (level-property), `function` (level-property):
///             - See the *border* in `label-format`.
/// - auto-resuming (none, auto, bool, array, function): Relate to the feature *Resuming Enum*.
///   - `none`: Disable this feature.
///   - `auto`: Enable this feature. In this case, the following methods (`resume`, `resume-label`, `resume-list`, `auto-resume-enum`, `isolated-resume-enum`) can be used.
///     - Use the method `resume()` to continue using the enum numbers from the previous enum at the same level.
///       - Example:
///         ```typst
///         #show: el.default-enum-list.with(auto-resuming: auto)
///         + Item one
///         + Item two
///         Paragraph
///         #el.resume()
///         + new list item one
///         ```
///     - Or use `resume[/*content*/]` to explicitly continue using the enum numbers from the previous level (especially in ambiguous cases) and treat the `[/*content*/]` as new `enum`s.
///       - Example:
///         ```typst
///         #show: el.default-enum-list.with(auto-resuming: auto)
///         + Item one
///         + Item two
///           + Sub item one
///         Paragraph
///         #el.resume[
///           + New list item // resume
///             + Sub item // not resume
///           + New list item
///         ]
///         + New list item one // not resume
///         ```
///     - Use the method `resume-label(<some-label>)` to label the enum you want to resume, and then use `resume-list(<some-label>)` in the desired enum to continue using the labelled enum numbers.
///       - If you use the following in your document:
///         ```typst
///         #show: el.config.ref-resume
///         ```
///         then you can use `@some-label` instead of `resume-list(<some-label>)`.
///       - Example:
///         ```typst
///         #show: el.default-enum-list.with(auto-resuming: auto)
///         + Item one
///         + Item two
///           + Sub item one
///           + Sub item Two
///           + Sub item Three #el.resume-label(<resume:sub>) // The enum you want to resume
///         Paragraph
///         #el.resume-list(<resume:sub>)
///         + New Item // resume
///         ```
///     - Use the method `el.auto-resume-enum(auto-resuming: true)[...]`, where all enum numbers within `[...]` will continue from the previous ones.
///       - See the method `auto-resume-enum` for the details of the argument `auto-resuming` (`bool`, `array`, `function`).
///       - Example:
///         ```typst
///         #show: el.default-enum-list.with(auto-resuming: auto)
///         + Item one
///         + Item two
///           + Sub item
///         Paragraph
///         #el.auto-resume-enum(auto-resuming: true)[
///           + New list item
///             + Sub item
///             + Sub item
///           + New list item
///             + Sub item // resume
///           Paragraph
///           + New list item // resume
///         ]
///         + New list item // not resume
///         ```
///     - The method `isolated-resume-enum[...]` allows the `enum`s in `[...]` to be treated as new enums with independent numbering, without affecting other enums out of the `[...]`.
///   - `bool`: If `auto-resuming` is set to `true`, then all enum numbers will continue from the previous ones.
///   - `array` (level-property): The elements are `bool`. The `level`-th level will be set to the corresponding value of the array at position `level - 1`; now `true` means the enum numbers at the `level`-th level will continue from the previous ones.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => bool`
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the `enum` or `list`.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///     - Example: Using `elem-tag`, specify which `enum` continues to use the previous enum's numbers.
///       ```typst
///       #show: el.default-enum-list.with(auto-resuming: it => {
///         if (it.elem-tag == "resume") { true } else { false }
///       })
///       + Item one
///       + Item two
///         + Sub item one
///         + Sub item two
///       New paragraph
///       + Item one // not resume
///         + #el.item(elem-tag: "resume") Sub item // resume
///       ```
///   - *Note*: If `auto-resuming` is not `none` or `false`, the the methold `default-enum-list(auto-resuming: ...)` can not be used nested.
///     - For large documents like books or articles, set `auto-resuming` to `auto` in the required sublists and use it with methods like `resume`, `resume-label`, `resume-list`, or `auto-resume-enum`.
///     - For small documents like exams, exercises, or CVs, if need to resume enum numbers throughout the document, then use the following at the beginning:
///       - `#show : el.default-enum-list.with(auto-resuming: true)`,
///       or if specify certain enums to continue using the number of the previous enum (with the help of `item(elem-tag: ...)`)
///       - `#show : el.default-enum-list.with(auto-resuming: it => /* ... */)`.
/// - auto-label-width (none, auto, string, array, function): Used to share the same maximum label width for different `enum`s and `list`s.
///   - `none`: Disable this feature.
///   - `auto`: Enable this feature. In this case, use the method `auto-label-item[...]` to share the same maximum label width for `enum` or `list` in `[...]`.
///     - Example: In the following, `List A` and `List B` share the same maximum label width.
///       ```typst
///       #show: el.default-enum-list.with(auto-label-width: auto)
///       + Item one
///       #el.auto-label-item(form: "each")[
///          + Item two // List A
///          Paragraph
///          + New Item one // List B
///          10. Item
///       ]
///       + New enum
///       ```
///     - See the method `el.auto-label-item` for the details of the argument `form` (Similar to `auto-label-width`).
///   - `"each"`: The maximum widths of `enum`'s labels and `list`'s labels are considered separately.
///     - Example: In the following, `List A` and `List B` share the same maximum label width, `Enum A` and `Enum B` share the same maximum label width.
///     ```typst
///     #show: el.default-enum-list.with(auto-label-width: "each")
///     - item // List A
///     - item
///     + item // Enum A
///     10. item
///     - #el.item([#square(width: 1em)]) item // List B
///     Paragraph
///     100. item // Enum B
///     ```
///   - `"list"`: Only the maximum widths of `list`'s labels are considered.
///   - `"enum"`: Only the maximum widths of `enum`'s labels are considered.
///   - `"all"`: The maximum widths of `enum`'s labels and `list`'s labels are both considered.
///   - `array` (level-property): The elements are `none`, `auto`, `"each"`, `"list"`, `"enum"`, `"all"`. The `level`-th level will be set to the corresponding value of the array at position `level - 1`.
///     - For array elements, `"each"` is equivalent to `auto`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => none | auto | "each" | "list" | "enum" | "all"`
///     - For returned values, `"each"` is equivalent to `auto`.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the `enum` or `list`.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///     - Example: In the following, for the same level of `enum`s or `list`s, if they are marked as "auto-label" (with the help of `el.item(elem-tag: ...)`), then they will share the same maximum label width.
///       ```typst
///       #show: el.default-enum-list.with(auto-label-width: it => {
///         if it.elem-tag == "auto-label" { auto }
///       })
///       + Item one
///         + #el.item(elem-tag: "auto-label") Sub Item one
///         + Sub item two
///       + Item one
///         10. #el.item(elem-tag: "auto-label") Sub Item one
///         + Sub item two
///       ```
/// - auto-base-level (bool): By default (since ver0.3.0), `auto-base-level` is set to `true`, meaning each `default-*` (`inline-*`, `paragraph-*`) method now maintains its own level counter, starting from 1. This behavior almost only affects the display of `enum.number` (by `enum.numbering`).
///   - If want to all `enum` use the same counter (as in ver0.2.x), set `auto-base-level` to `false` (but then at least three layout iterations are required).
/// - step (auto, int, function, array): Used to set the step size for `enum`'s number.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(step: 2) // the next enum's number is 2 greater than the current enum's number.
///     ```
///   - `auto`: The step size is `1` if `enum.reversed` is `false`, otherwise it is `-1`.
///   - `int`: The step size is the specified value.
///   - `function` (base-property): The next enum's number is the return value of the function. If the return value is `auto` or `none` (usually used as an initial value), then the step size is `1` if `enum.reversed` is `false`, otherwise it is `-1`.
///     - The function form: `(..nums) => int | auto | none`
///     - Here is an example to make enum's number like factorial:
///       ```typst
///       #let factorial-step = (..nums) => {
///         let numbers = nums.pos()
///         let n = numbers.len()
///         if n >= 2 {
///           return numbers.at(n - 2) + numbers.at(n - 1)
///         }
///       }
///       #show: el.default-enum-list.with(step: (factorial-step,))
///       1. #lorem(2)
///       1. #lorem(2)
///       + #lorem(2)
///       + #lorem(2)
///       + #lorem(2)
///       ```
///   - `array` (level-property): The elements are `int`, `function`, `auto` and `none`. The element at position `level - 1` sets the step size for the `level`-th level.
///     - `int`: The step size is the specified value.
///     - `auto` or `none`: The step size is `1` if `enum.reversed` is `false`, otherwise it is `-1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///   - `function` (level-property): The return value will be used for each level.
///     - The function form: `it => int | auto | function`
///     - If the returned value is a `function`, it should be the above form of `function` (base-property).
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.elem-tag`: The tag of the current enum or list.
///       - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type`: The hanging type of the current level.
///     - Example: for all odd levels, the `enum` numbers are reversed.
///       ```typst
///       #show: el.default-enum-list.with(step: it => {
///         if calc.odd(it.level) {
///           (..nums) => {
///             let numbers = nums.pos()
///             let n = numbers.len() // 1-based count of previous numbers
///             if n == 0 { it.n-last } else { numbers.at(n - 1) - 1 }
///           }
///         } else { auto }
///       })
///       ```
/// - ref-numbering (function, string, dictionary, none): How to number the `enum`'s reference.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(ref-numbering: "(1).(a)")
///     #show: el.default-enum-list.with(ref-numbering: (numbering: "(1).(a)", full: true))
///     ```
///   - `none`: Determined by `enum.numbering` or `config.ref.numbering`.
///   - `function`, `string`: See also `enum.numbering`.
///   - `dictionary`: The keys are `numbering` and `full`.
///     - `numbering` (`function`, `string`, `none`): See also `enum.numbering`.
///     - `full`: (`bool`, `"rel"` `auto`).
///       - If `auto`, determined by `enum.full` or `config.ref.full`.
///       - See also `config.ref.full`.
/// - supplement (auto, content, dictionary, function, array): Used to set supplementary content when referencing enum labels.
///   - Note: This is independent of the `config.ref.supplement` setting, meaning the supplement content and the referenced enum or list label will be passed as a whole to `config.ref.supplement`.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(supplement: [Item])
///     #show: el.default-enum-list.with(supplement: (prefix: [第], suffix: [项]))
///     #show: el.default-enum-list.with(supplement: it => {
///       set text(fill: red, weight: "bold")
///       std.numbering("(1).(a)", ..it.numbers)
///     })
///     #show: el.default-enum-list.with(supplement: it => [#numbering(heading.numbering, ..counter(heading).at(it.target)).#it.body])
///     ```
///   - `auto`: No supplementary content will be added.
///   - `content`: Uses `content` as supplementary content. The effect is that when referencing `enum` labels, `content` is added before the label.
///   - `dictionary`: The keys are: `prefix`, `suffix`, with values of `content`. The effect is that when referencing `enum` labels, `prefix` content is added before the label, and `suffix` content is added after the label.
///   - `array` (level-property): Sets `supplement` by level. The elements are `content`, `dictionary`, `auto`, `array`.
///     - See also `indent`.
///   - `function` (level-property): The return value will be used for each level and each item.
///     - The function form: `it => content`.
///     - Access the following values available on `it`:
///       - `it.body`: The referenced `enum` labels.
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag` (since ver0.3.0): The tag of the item.
///       - `it.elem-tag` (since ver0.3.0): The tag of the `enum` or `list`.
///       - `it.e` (since ver0.3.0): The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type` (since ver0.3.0): The hanging type of the current level.
///       - `it.number` (since ver0.3.0): The number of the current label if it is a `enum`.
///       - `it.target` (since ver0.3.0): The target of the referenced label.
///       - `it.numbers` (since ver0.3.0): The full numbers of the referenced item (including the parent `enum`'s numbers).
/// - checklist (bool, array): Whether to use checklist (default: `false`). If set to `true` (since ver0.3.0), then configure checklist-related features using the method `config.checklist`.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(checklist: true)
///     #show: el.config.checklist.with(
///       // configure
///     )
///     ```
///     See the method `config.checklist` for more details.
///   - `array` (level-property): The elements are `bool`, each level of the item will be set to the corresponding value of the array at position `level - 1`; now `true` means to use checklist for the current level.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
/// - enum-config (dictionary): Configure `enum` in `doc`.
///   - The keys are:
///     - any named arguments of the function `text` (like: `fill`, `size`, `font`, etc.)
///     - `indent`
///     - `body-indent`
///     - `label-indent`
///     - `label-inset`
///     - `body-margin`
///     - `hanging-indent`
///     - `line-indent`
///     - `first-line-inset`
///     - `whole-spacing`
///     - `item-spacing`
///     - `tight-mode`
///     - `tight-item-mode`
///     - `label-width`
///     - `label-baseline`
///     - `label-format`
///     - `label-align`
///     - `body-format`
///     - `step`
///     - `ref-numbering`
///     - `supplement`
///     - `description-config`
///     - `hanging-type`
///   - Rules: If both `*-enum-list` and `enum-config` have the same property set, the settings in `enum-config` take precedence.
///     - For `label-format` and `body-format`, the settings are folded.
///   - The level used in `enum-config` is the relative level of `enum` (i.e., ignore `list`).
///   - The values allowed to be passed in the keys are consistent with the corresponding parameters in the method `default-enum-list`.
/// - list-config (dictionary): Configure `list` in `doc`.
///   - See `enum-config`.
/// - description-config (dictionary, none): Configure the description list.
///   - Using the syntax:
///     - `+ / term: description`
///     - `- / term: description`
///   - The description list is like the following:
///     ```
///     [marker] / [number] [term-body] [description-body]
///     term-body: [prefix] [term] [separator.prefix]
///     description-body: [separator.suffix] [description] [suffix]
///     ```
///     *Note*: Usually, when the `term` and `description` are paragraphs, this will work as expected.
///   - Provide four styles: horizontal description list, hanging description list, stacked description list, plain description list.
///   - Support checklist style for description list (requires setting `checklist` to `true` in `description-config` and this method).
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(description-config: {
///       style: "horizontal",
///       term-format: (strong,),
///     })
///     - / Windows: Windows is a family of graphical operating systems, developed by Microsoft.
///     - / macOS: macOS is a series of graphical operating systems developed and marketed by Apple Inc.
///     - / Linux: Linux is a family of free and open-source operating systems.
///     + / Windows: Windows is a family of graphical operating systems, developed by Microsoft.
///     + / macOS: macOS is a series of graphical operating systems developed and marketed by Apple Inc.
///     + / Linux: Linux is a family of free and open-source operating systems.
///     ```
///   - `none`: Disable the description list.
///   - `dictionary`: The keys are:
///     - `style` (auto, string, array, function): The style of the description list.
///       - `"plain"` == `auto`: Plain description list. The `term-body` and `description-body` are displayed in a single paragraph.
///       - `"hanging"`: Hanging description list. The `term-body` and `description-body` are displayed in a single paragraph, but `hanging-indent` is `2em` in default. The same as native Typst `terms`.
///       - `"stacked"`: Stacked description list. The `term-body` and `description-body` are displayed as two start-aligned paragraphs, respectively.
///       - `"horizontal"`: Horizontal description list. The `term-body` and `description-body` are displayed in a single paragraph, but `description-body` will be indented and aligned according to `term-width` (by default, using the maximum width of the `term-body`).
///       - `array` (level-property): The elements are `auto`, `"plain"`, `"hanging"`, `"stacked"`, `"horizontal"`, or `array`. The element at the position `level - 1` will be used for the `level`-th level.
///         - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///         - otherwise, the last value of the array will be used for residual levels.
///         - The elements in the array can also be an array, where the element at position `n - 1` applies to the item of index `n`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | "plain" | "hanging" | "stacked" | "horizontal" | array`
///         - If the returned value is a `array`, then the elements in the array will be used for each item.
///         - Access the following values available on `it`:
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the current item.
///           - `it.elem-tag`: The tag of the current enum or list.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///           - `it.marker`: The marker of the current label if it is a `list`.
///           - `it.number`: The number of the current label if it is a `enum`.
///           - `it.term-width` (dictionary): The width info of the current label.
///             - `it.term-width.max`: The maximum width of the `term-body` in the current level and in the current style.
///             - `it.term-width.current`: The current width of the `term-body`.
///     - `term-width` (auto, relative, string, dictionary, array, function): The width of the `term-body`.
///       - `auto`: In default,
///         - for "horizontal" style, the `term-width` uses the maximum width of the `term-body` in the current level and in the "horizontal" style. That is, use `(amount: "max", style: "native")`.
///         - for other styles, the `term-width` uses the real width of the `term-body`. That is, use `(amount: auto, style: "native")`.
///       - `relative`, `"max"`, `dictionary`, `array` (level-property): See `label-width` (in *`default-enum-list`*).
///         - The maximum width of the `term-body` in the current level is calculated for different styles.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | relative | string | dictionary | array`.
///         - Access the following values available on `it`:
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the current item.
///           - `it.elem-tag`: The tag of the current enum or list.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///           - `it.marker`: The marker of the current label if it is a `list`.
///           - `it.number`: The number of the current label if it is a `enum`.
///           - `it.style`: The description list style of the current item.
///           - `it.max-width`: The maximum width of the `term-body` in the current level and in the current style.
///           - `it.width`: The width of the `term-body` of the current item.
///     - `term-align` (auto, alignment, array, function): The alignment of the `term-body`.
///       - *Note*: The `term-align` works for the following cases.
///         - The "horizontal" and "stacked" styles;
///         - For "hanging" and "plain" styles, the `term-width` is not `auto` (that is, the real width of the `term-body` is not equal to the rendered width).
///       - `auto` == `start`.
///       - `alignment`: The alignment of the `term-body`.
///       - `array` (level-property): The elements are `auto`, `alignment`, or `array`.
///         - See `style`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | alignment | array`.
///         - Access the following values available on `it`: See `separator`.
///     - `separator` (auto, content, dictionary, array, function): The separator between `term-body` and `description`.
///       - *Note*: `separator` contains two parts: `prefix` and `suffix`.
///         - In default, `separator.prefix` is added after `term` and `separator.suffix` is added before `description`.
///       - `auto`: The `separator.prefix` is `[]` for "stacked" style and `[#h(.6em)#h(0pt, weak: true)]` for other styles. `separator.suffix` is `[]`.
///       - `content`: The `separator.prefix` is `separator` and the `separator.suffix` is `[]`.
///       - `dictionary`:
///         - The keys are `prefix` and `suffix`, with `content` values.
///           - In default, the `prefix` is `[]` and the `suffix` is `[]`.
///         - Now, `separator.prefix` is `prefix` and `separator.suffix` is `suffix`.
///       - `array` (level-property): The elements are `auto`, `content`, `dictionary`, or `array`.
///         - See `style`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | content | dictionary | array`.
///         - Access the following values available on `it`:
///           - `it.style`: The description list style of the current item.
///           - For others, see `style`.
///     - `prefix` (content, array, function): The prefix of the `term`. Default is `[]`. The `prefix` is added before `term`.
///       - `array` (level-property): The elements are `content` or `array`.
///         - See `style`.
///       - `function` (level-property):
///         - The function form: `it => content | array`.
///         - Access the following values available on `it`: See `separator`.
///     - `suffix` (content, array, function): The suffix of the `description`. Default is `[]`. The `suffix` is added after `description`.
///       - *Suggestion*: Using it, control the description list's below spacing (like `block(above: 0pt, below: len)`), or add special symbols, and so on.
///     - `hanging-indent` (auto, length, array, function): The hanging indent of the description list.
///       - `auto`: The `hanging-indent` is `2em` for "hanging" style, and `0pt` for other styles.
///       - `length`: The value of hanging indent.
///       - `array` (level-property): The elements are `auto`, `length`, or `array`.
///         - See `style`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => auto | length | array`.
///         - Access the following values available on `it`: See `separator`.
///     - `term-format` (none, function, array): The format of the `term`.
///       - `none`: Do not apply.
///       - `function` (base-property): Apply the function to the `term` (not the `term-body`).
///         - The function form: `body => content`.
///         - The `function` should be wrapped in an `array`, like: `(strong, )`.
///         - Example: In the following, the `Terms` will be colored by `red` and formatted by `strong`.
///           ```typst
///           #let term-f = body => {
///             show: strong
///             set text(fill: red)
///             body
///           }
///           #show: el.default-enum-list.with(description-config: (
///             term-format: (term-f,),
///           ))
///           / Terms: #lorem(10)
///           ```
///       - `array` (level-property): The elements are `none`, `function` or `array`.
///         - See `style`.
///         - Example: In the following, the `Terms` and `Sub Terms` will be formatted by `strong` and `emph`, respectively.
///           ```typst
///           #show: el.default-enum-list.with(description-config: (
///             term-format: (strong, emph),
///           ))
///           - / Terms: #lorem(10)
///             - / Sub terms: #lorem(10)
///           ```
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => content | array`.
///         - Access the following values available on `it`:
///           - `it.body`: The `term` of the current item.
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the current item.
///           - `it.elem-tag`: The tag of the current enum or list.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///           - `it.marker`: The marker of the current label if it is a `list`.
///           - `it.number`: The number of the current label if it is a `enum`.
///           - `it.term-width` (dictionary): The width info of the current label.
///             - `it.term-width.max`: The maximum width of the `term-body` in the current level and in the current style.
///             - `it.term-width.current`: The current width of the `term-body`.
///         - Example: Format `term` for different styles.
///           ```typst
///           #let desc-style = style => (description-config: (style: style), for-elem: true)
///           #show: el.default-enum-list.with(description-config: (
///             term-format: it => {
///               let format(body) = if it.style == "stacked" {
///                 strong(body)
///                 block(above: 0pt, below: par.leading)
///               } else { emph(body) }
///               format(it.body)
///             },
///           ))
///           - #el.item(..desc-style("stacked"))
///             / CPU: #lorem(10)
///           - / GPU: #lorem(10)
///           Paragraph
///           - #el.item(..desc-style("horizontal"))
///             / CPU: #lorem(10)
///           - / GPU: #lorem(10)
///           ```
///     - `description-format` (none, function, array): The format of the `description`.
///       - See `term-format`.
///     - `checklist` (bool, array, function): Whether to use checklist style description list.
///       - *Note*: In order to enable checklist style, the `checklist` in `default-*` (or `paragraph-*`) must be `true`.
///       - Usage:
///         ```typst
///         #show: el.default-enum-list.with(checklist: true, description-config: (checklist: true))
///         - / [ ] : #lorem(2)
///         + / [-] : #lorem(2)
///         ```
///       - `true`: Enable checklist style.
///       - `false`: Disable checklist style.
///       - `array` (level-property): The elements are `bool` or `array`.
///         - See `style`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => bool | array`.
///         - Access the following values available on `it`: See `separator`.
///     - `enable-first-par` (auto, bool, array, function): Whether to make all the paragraphs in the description list like the first paragraph.
///       - `auto`: For `stacked` style, the `enable-first-par` is `true`, and for other styles, the `enable-first-par` is `false`.
///       - `bool`: Whether to enable the first paragraph.
///       - `array`: The elements are `bool` or `array`.
///         - See `style`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => bool | array`.
///         - Access the following values available on `it`: See `separator`.
///     - `format` (none, function, array): The format of the description list.
///       - `none`: Do not apply.
///       - If the default style is not suitable, you can use `format` to customize the style.
///       - `function` (base-property): Apply the function to the whole description list.
///         - The function form: `body => content`.
///         - The `function` should be wrapped in an `array`, like: `(strong, )`.
///         - Example: In the following, the whole description list will be colored by `red`.
///           ```typst
///           #show: el.default-enum-list.with(description-config: (
///             format: (text.with(fill: red),),
///           ))
///           - / CPU: #lorem(10)
///           - / GPU: #lorem(10)
///           ```
///       - `array` (level-property): The elements are `none`, `function` or `array`.
///         See `term-format`.
///       - `function` (level-property): The return value will be used for each level and each item.
///         - The function form: `it => content`.
///         - Access the following values available on `it`:
///           - `it.body`: The current description list.
///           - `it.level`: The level of the item, starting from 1.
///           - `it.n`: The index of the item, starting from 1.
///           - `it.n-last`: The index of the last item in the current level.
///           - `it.tag`: The tag of the current item.
///           - `it.elem-tag`: The tag of the current enum or list.
///           - `it.e`: The field of the current construct element (`enum` or `list`), but excluding the `children`.
///           - `it.hanging-type`: The hanging type of the current level.
///           - `it.marker`: The marker of the current label if it is a `list`.
///           - `it.number`: The number of the current label if it is a `enum`.
///           - `it.term`, `it.description`: The `term` and the `description` of the current item.
///           - `it.separator`: The `separator`.
///           - `it.prefix`, `it.suffix`: The `prefix` and `suffix` of the current item.
///           - `it.hanging-indent`: The hanging indent of the current item.
///           - `it.style`: The current description list style.
///           - `it.enable-first-par`: The `enable-first-par` of the current item.
///           - `it.term-align`: The `term-align` of the current item.
///           - `it.term-width` (dictionary): The width info of the current label.
///             - `it.term-width.max`: The maximum width of the `term-body` in the current level and in the current style.
///             - `it.term-width.current`: The current width of the `term-body`.
///           - `it.process-par`: Usually use like `show: process-par.with(enable-strong-par: it.enable-first-par)`. Used for internal processing of paragraph models. Advanced usage.
///           - `it.dir`: Current text direction.
/// - args (arguments): Any `text` named arguments (like: `fill`, `size`, `font`, etc.; see https://typst.app/docs/reference/text/text/). Format the current item label.
///   - Usage:
///     ```typst
///     #show: el.default-enum-list.with(fill: red) // All labels are colored red.
///     #show: el.default-enum-list.with(size: (2em, 1.2em, auto)) // The label's size for first level is 2em, the label's size for second level is 1.2em, and the label's size for other levels is `auto` (use the current `text.size`).
///     #show: el.default-enum-list.with(fill: it => {
///       if it.e.tight { // tight enum or list use `red` for label
///         red
///       } else { // otherwise, use `black`
///         black
///       }
///     })
///     ```
///   - *Note*: If some named argument of `text` allows being set as an `array` (base-property), in order to apply it to the current level, you need to further wrap it in an `array`.
///     - Example: In the following, the first level of labels use the font `(name: "DejaVu Sans Mono", covers: "latin-in-cjk")`, and other levels use the font `"Noto Serif CJK SC"`.
///       ```typst
///       #let label-font = ((name: "DejaVu Sans Mono", covers: "latin-in-cjk"), "Noto Serif CJK SC")
///       #show: el.default-enum-list.with(font: label-font)
///       #set enum(numbering: "（1）")
///       + #lorem(2)
///       + #lorem(2)
///         + #lorem(2)
///         + #lorem(2)
///       ```
///     - Example: In the following, for each level, the first index of label uses the font `(name: "DejaVu Sans Mono", covers: "latin-in-cjk")`, and other indices use the font `"Noto Serif CJK SC"`.
///       ```typst
///       #let label-font = ((name: "DejaVu Sans Mono", covers: "latin-in-cjk"), "Noto Serif CJK SC")
///       #show: el.default-enum-list.with(font: (label-font,))
///       #set enum(numbering: "（1）")
///       + #lorem(2)
///       + #lorem(2)
///         + #lorem(2)
///         + #lorem(2)
///       ```
///     - Example: In the following, all the levels of labels use the font `((name: "DejaVu Sans Mono", covers: "latin-in-cjk"), "Noto Serif CJK SC")`.
///       ```typst
///       #let label-font = ((name: "DejaVu Sans Mono", covers: "latin-in-cjk"), "Noto Serif CJK SC")
///       #show: el.default-enum-list.with(font: ((label-font,),))
///       #set enum(numbering: "（1）")
///       + #lorem(2)
///       + #lorem(2)
///         + #lorem(2)
///         + #lorem(2)
///       ```
///   - `array`: All the named arguments of `text` are supported for `array`. The `level`-th of the `enum` or `list` will be set to the corresponding value of the array at position `level - 1`.
///     - The elements of the array are the values of the named arguments of `text` that can be set.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///     - Then elements of the array can be `array`, meaning the element at position `n-1` will apply to the `n`-th index of the label for the current level.
///   - `function`: The return value will be used for each level and each item.
///     - The function form: `it => value | array`, where `value` is any value accepted by the corresponding `text` named argument.
///     - If the return value is `array`, the element at position `n-1` will apply to the `n`-th index of the label for the current level.
///     - Access the following values available on `it`:
///       - `it.level`: The level of the item, starting from 1.
///       - `it.n`: The index of the item, starting from 1.
///       - `it.n-last`: The index of the last item in the current level.
///       - `it.tag` (since ver0.3.0): The tag of the current item.
///       - `it.elem-tag` (since ver0.3.0): The tag of the current enum or list.
///       - `it.e` (since ver0.3.0): The field of the current construct element (`enum` or `list`), but excluding the `children`.
///       - `it.hanging-type` (since ver0.3.0): The hanging type of the current level.
///       - `it.marker` (since ver0.3.0): The marker of the current label if it is a `list`.
///       - `it.number` (since ver0.3.0): The number of the current label if it is a `enum`.
/// -> content
#let default-enum-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true, // change to true in default
  label-width: auto,
  body-format: none,
  label-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.all, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    checklist,
    enum-config,
    list-config,
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}


/// Configures paragraph styling for `enum` and `list`.
///
/// See `default-enum-list`.
#let paragraph-enum-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  // is-full-width: if sys.version <= version(0, 14, 2) { true } else { false }, /**new ver0.3.0 native, deprecated*/
  item-spacing: auto,
  // enum-spacing: none, //
  // enum-margin: auto, //
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true, // change to true in default
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.all, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    HangingType.paragraph,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    checklist,
    enum-config,
    list-config,
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}

/// Configures default styling for `enum`.
///
/// See `default-enum-list`.
#let default-enum(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  // is-full-width: if sys.version <= version(0, 14, 2) { true } else { false }, /**new ver0.3.0 native*/
  item-spacing: auto,
  // enum-spacing: none, //
  // enum-margin: auto, //
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true,
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: auto, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.enum, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    // label-text-indent,
    auto-resuming,
    auto-label-width,
    checklist,
    (:),
    (:),
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}

/// Configures paragraph styling for `enum`.
///
/// See `default-enum-list`.
#let paragraph-enum(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  // is-full-width: if sys.version <= version(0, 14, 2) { true } else { false }, /**new ver0.3.0 native*/
  item-spacing: auto,
  // enum-spacing: none, //
  // enum-margin: auto, //
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true,
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.enum, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    HangingType.paragraph,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    checklist,
    (:),
    (:),
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}

/// Configures default styling for `list`.
///
/// See `default-enum-list`.
#let default-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  // is-full-width: if sys.version <= version(0, 14, 2) { true } else { false }, /**new ver0.3.0 native*/
  item-spacing: auto,
  // enum-spacing: none, //
  // enum-margin: auto, //
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true,
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-label-width: none,
  checklist: false,
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.list, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    none,
    auto-label-width,
    checklist,
    (:),
    (:),
    none,
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    auto,
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}

/// Configures paragraph styling for `list`.
///
/// See `default-enum-list`.
#let paragraph-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  // is-full-width: if sys.version <= version(0, 14, 2) { true } else { false }, /**new ver0.3.0 native*/
  item-spacing: auto,
  // enum-spacing: none, //
  // enum-margin: auto, //
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true,
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-label-width: none,
  checklist: false,
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.list, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    HangingType.paragraph,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    label-baseline,
    none,
    auto-label-width,
    checklist,
    (:),
    (:),
    none,
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    auto,
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    body-margin, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.default,
  )
}

// new ver0.3.0: inline-enum-list

/// Inline layout for `enum` and `list`. That is, it does not use block elements and instead interprets the list content as paragraphs.
/// - In particular, any block elements appearing in the list are laid out flush left.
/// - Content at every level of the list spans the full width of the parent container.
/// - Because of this paragraph behavior, some features of the method `default-enum-list` no longer take effect:
///   - `label-baseline` is not supported.
///   - `Border` of the `body-format` is not supported.
///   - `body-margin` is not supported.
///
/// See `default-enum-list`.
#let inline-enum-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true, // change to true in default
  label-width: auto,
  body-format: none,
  label-format: none,
  label-align: auto,
  // label-baseline: auto,
  // auto-resuming: none,
  // auto-label-width: none,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  // body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.all, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    // is-full-width, //
    item-spacing,
    // enum-spacing, //
    // enum-margin, //
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    auto, // label-baseline
    none, // auto-resuming
    none, // auto-label-width
    checklist,
    enum-config,
    list-config,
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    auto, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.inline,
  )
}

/// Inline layout for `enum`
///
/// See `default-enum-list` and `inline-enum-list`.
#let inline-enum(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true, // change to true in default
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0*/
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  // body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.enum, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    item-spacing,
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    auto, // label-baseline
    none, // auto-resuming
    none, // auto-label-width
    checklist,
    enum-config,
    list-config,
    ref-numbering, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    step, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    auto, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.inline,
  )
}

/// Inline layout for `list`.
///
/// See `default-enum-list` and `inline-enum-list`.
#let inline-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  item-spacing: auto,
  hanging-type: "classic",
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: true, // change to true in default
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  label-align: auto,
  checklist: false,
  // ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0*/
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none, /** new ver0.3.0 */
  // body-margin: auto, /*new new ver0.3.0*/
  whole-spacing: auto, /*new new ver0.3.0*/
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    ElemType.list, // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    item-spacing,
    hanging-type,
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    // item-format,
    auto-base-level,
    label-align,
    auto, // label-baseline
    none, // auto-resuming
    none, // auto-label-width
    checklist,
    enum-config,
    list-config,
    none, /** new ver0.3.0 */
    supplement, /** new ver0.3.0*/
    tight-mode, /** new ver0.3.0 */
    tight-item-mode, /** new ver0.3.0 */
    auto, /** new ver0.3.0*/
    label-inset, /** new ver0.3.0 */
    first-line-inset, /** new ver0.3.0 */
    description-config, /** new ver0.3.0 */
    auto, /*new new ver0.3.0*/
    whole-spacing, /*new new ver0.3.0*/
    ..args,
    style-type: ExportType.inline,
  )
}
