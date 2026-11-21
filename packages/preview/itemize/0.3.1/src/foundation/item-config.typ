#import "../util/parse-args.typ": *

#import "../util/func-type.typ": *

/// All the supported arguments (excluding `text-args`) for the `item` method
#let item-args-keys = (
  "indent",
  "body-indent",
  "label-indent",
  "item-spacing",
  "hanging-indent",
  "line-indent",
  "label-width",
  "body-format",
  "label-format",
  "label-align",
  "label-baseline",
  "label-inset",
  "first-line-inset",
  "tight-mode", // for all, only index = 1 will be used
  "tight-item-mode", //for all, only index = 1 will be used
  "ref-numbering", /*only works for enum*/
  "supplement", // different meaning, need labelled to `item`
  "skipped", // should be skipped for current's label (number for enum, marker for list), default: false,
  "step",
  "body", // label's content
  "absolute", // true for abs-level else for rel-level
  "tag", // The identifier of the item (list or enum).
  "elem-tag", // The identifier of the lists (list or enum).
  "description-config",
  "whole-spacing", // for all, only index = 1 will be used
  "body-margin",
  "for-elem",
  "hanging-type", // classic, paragraph; for all, only index = 1 will be used
)

/// All the supported arguments (excluding `text-args`) for the `item` method
#let item-args = item-args-keys.map(it => (it, it)).to-dict()

/// Configure for the current item
/// - args (arguments): Arguments for the current item.
///   - Positional arguments.
///     - body (`content`): Content for the current label body (`enum` or `list`); defaults to `none` to preserve existing label body
///       - *Note*: Both `enum` and `list` support referencing the content of the `body`. However, the `label` needs to be placed after this method, for example:
///         ```typst
///         #show: el.default-enum-list
///         #show: el.config.ref // Enable to support referencing
///         + #el.item([Enum])<enum:a> item <enum:b>
///         - #el.item([List])<list:a> item
///         Test:
///         @enum:a // Output: Enum
///         @list:a // Output: List
///         @enum:b // Output: 1
///         ```
///     - For `enum`, even if the content display of the item label is changed, the current item still has a label number (`enum`'s number) --- and the label number will be the same as the previous one (if `item(skipped: true)`) or the same as the current one (if `item(skipped: false)`).
///   - Named arguments.
///     - Support the following arguments:
///       - label formatting: any `text` named arguments, label-width, label-format, label-baseline, label-align, label-inset, label-indent
///       - body formatting: body-margin, body-format, body-indent
///       - horizontal spacing: indent
///       - vertical spacing: whole-spacing, item-spacing, tight-mode, tight-item-mode
///       - paragraph: hanging-indent, line-indent, first-line-inset, hanging-type
///       - reference: ref-numbering, supplement
///       - enum's numbering: step, skipped
///       - description-list config: description-config
///       - identifier: tag, elem-tag
///       - others: absolute, for-elem.
///     - Details:
///     - any `text` named arguments (like: `fill`, `size`, `font`, etc.): Format the current item label.
///     - indent (`auto`, `length`, `array`, `function`, `none`): The indentation of the `enum` or `list`.
///     - body-indent (`auto`, `length`, `function`, `array`, `none`): The indentation of the body, i.e., the space between the label and the body of each item.
///     - label-indent (`auto`, `length`, `array`, `function`, `none`): The indentation for the label (the enum's number or the list's marker).
///     - label-inset (`auto`, `length`, `array`, `function`, `none`): Adds an inset to the label. It translates labels horizontally (without affecting the label width and the inset of the first line).
///     - item-spacing (`auto`, `relative`, `fraction`, `dictionary`, `array`, `function`, `none`): Spacing between items.
///     - whole-spacing (`auto`, `relative`, `fraction`, `dictionary`, `array`, `function`, `none`): The above and below spacing of the current `enum` or `list`. Only used when `item` is in the first item.
///     - tight-mode (`auto`, `"always-tight"`, `"never-tight"`, `"compact-tight"`, `dictionary`, `array`, `function`, `none`): If `whole-spacing` are `auto`, then `tight-mode` is used to determine the above and below spacing of `enum` or `list`. Only used when `item` is in the first item.
///     - tight-item-mode (`auto`, `"always-tight"`, `"never-tight"`, `dictionary`, `array`, `function`, `none`): If `item-spacing` is `auto`, then `tight-item-mode` is used to determine the spacing between items. Only used when `item` is in the first item.
///     - hanging-indent (`auto`, `length`, `array`, `function`, `none`): The hanging indentation for item body.
///     - line-indent (`auto`, `length`, `array`, `function`, `none`): The indentation for the first line of a paragraph, excluding the first paragraph (default: `auto`).
///     - first-line-inset (`auto`, `length`, `array`, `function`, `none`): Adds an inset to the first line of the item body (default: `0pt` if `auto`). If there is no first line, it is ignored.
///     - hanging-type (`"classic"`, `"paragraph"`, `array`, `function`): Hanging type for multiline content; defaults to "classic". Only used when `item` is in the first item.
///     - label-align (`auto`, `alignment`, `array`, `function`, `none`): The `alignment` that enum numbers and list markers should have. In general, this parameter is used to set *horizontal* alignment for label. If want 2D-alignment, then see `label-baseline`.
///     - label-width (`auto`, `relative`, `"max"`, `dictionary`, `function`, `array`, `none`): Render the width of the label.
///     - body-format (`dictionary`, `array`, `function`, `none`): Customize item bodies.
///     - label-format (`dictionary`, `array`, `function`, `none`): Customize item labels.
///     - label-baseline (`auto`, `relative`, `"center"`, `"top"`, `"bottom"`, `"baseline"`, `"top-item"`, `"horizon-item"`, `"bottom-item"`, `dictionary`, `array`, `function`, `none`): Set the baseline style of the label body.
///     - body-margin (`auto`, `relative`, `dictionary`, `array`, `function`, `none`): The left and right margin of the current item body. Based on the `itemize` design, `label-indent`, the label's content, `body-indent` are belong to the label's body. For `ltr`, the left margin starts from the left of the label's body; for `rtl`, the right margin starts from the right of the label's body.
///     - description-config (`dictionary`, `none`): Configure the description list.
///     - step (`auto`, `int`, `function`, `array`, `none`): Used to set the step size for `enum`'s number.
///     - ref-numbering (`string`, `function`, `dictionary`, `none`): How to number the `enum`'s reference (default: `none`, determined by `enum.numbering` or `config.ref.numbering`). Only used when `item` is in the first item of `enum`.
///       - *Note*: Only work for the current `enum` (not for the nested `enum`).
///       - Example:
///         ```typst
///         #show: el.default-enum-list
///         #set enum(numbering: "1.")
///         #show: el.config.ref
///         + #el.item(ref-numbering: "(1)") item <enum:a>
///           + Sub item <enum:b>
///         Test:
///         @enum:a // Output: (1)
///         @enum:b // Output: 1.
///         ```
///     - supplement (`auto`, `content`, `dictionary`, `function`, `array`, `none`):  Used to set supplementary content when referencing enum labels.
///       - *Note*: This only work when referencing the label body.
///       - Example:
///         ```typst
///         #show: el.default-enum-list
///         #show: el.config.ref
///         + #el.item([Enum], supplement: "Item")<enum:a> item <enum:b>
///         Test:
///         @enum:a // Output: Item Enum
///         @enum:b // Output: 1
///         ```
///     - skipped (`bool`): Only for `enum`, whether to skip current label numbering; if `true`, the label's number will use the previous one, otherwise, the label's number will remain unchanged; defaults to `false`.
///     - absolute (`bool`): Whether to use absolute nesting levels.
///       - `true`: When using the method `*-enum-list`, the meaning of the nesting levels includes `enum` and `list`.
///       - `false` (default): In `list`, the meaning of levels only includes `list`; and in `enum`, the meaning of levels only includes `enum`.
///     - for-elem (`bool`): Whether the properies set by `item` is applied for current `enum` or `list` (not only for the current item); defaults to `false`. Only used when `item` is in the first item.
///       - Example: In the following, for `List A`, all the labels of  are colored by `red`, but for `List B`, only the first item is colored by `red`:
///         ```typst
///         #show: el.default-enum-list
///         // List A
///         + #el.item(for-elem: true, fill: red) List A item one
///         + List A item two
///         Paragraph:
///         // List B
///         + #el.item(fill: red) List A item one
///         + List A item one
///         ```
///     - tag (`any`): The identifier of the item.
///     - elem-tag (`any`): The identifier of the lists (`list` or `enum`).
#let item(..args) = {
  let pos-args = args.pos()
  let named-args = args.named()
  let body
  if pos-args.len() > 0 {
    body = pos-args.at(0)
    if type(body) != content {
      panic("The body should be a content.")
    }
  }
  // verify the arguments
  if named-args.len() > 0 {
    let item-args = named-args
      .pairs()
      .filter(((k, v)) => k not in item-args-keys and k not in default-text-args.keys())
      .map(((k, v)) => k)
    assert(
      item-args == (),
      message: "Found unsuppted argument for the `item` method: " + item-args.join(", ", last: " and ") + ".",
    )
  }
  if body != none or named-args.len() > 0 {
    metadata((..named-args, body: body, kind: item-label-ID))
  }
}


/// Check if the element is the `#item(..args)`
#let is-item-label(e) = {
  return e.func() == metadata and type(e.value) == dictionary and e.value.at("kind", default: none) == item-label-ID
}

#let parse-item(body) = {
  if is-item-label(body) {
    let item-args = body.value
    let _ = item-args.remove("kind")
    return item-args
  } else {
    return none
  }
}

#let parse-item-args(elem-args) = {
  if type(elem-args) == dictionary {
    for k in item-args-keys {
      let value = elem-args.at(k, default: none)
      if value != none {
        (str(k): value)
      }
    }
    // text args
    let dic = for k in default-text-args.keys() {
      let v = elem-args.at(k, default: none)
      if v != none {
        (str(k): v)
      }
    }
    (text-args: dic)
  } else {
    // none
    (:)
  }
}


#let parse-item-func = child => {
  let body = if child.body.func() == func-styled {
    child.body.child
  } else {
    child.body
  }
  let first-child = if body.func() == func-seq and body.children.len() > 0 {
    body.children.first()
  } else {
    body
  }
  return parse-item-args(parse-item(first-child))
}


// #let parse-item-args-arr(elem-args-arr) = {
//   for elem-args in elem-args-arr {
//     if type(elem-args) == dictionary {
//       for k in item-args-keys {
//         let value = elem-args.at(k, default: none)
//         if value != none {
//           (str(k): value)
//         }
//       }
//     }
//   }
//   // text args
//   let dic = for elem-args in elem-args-arr {
//     if type(elem-args) == dictionary {
//       // text args
//       for k in default-text-args.keys() {
//         let v = elem-args.at(k, default: none)
//         if v != none {
//           (str(k): v)
//         }
//       }
//     }
//   }
//   (text-args: dic)
// }

// // support for like `+ #el.item(...) #el.item(...) ...` (do not enable in ver0.3.0)
// #let parse-item-func-arr = child => {
//   let body = if child.body.func() == func-styled {
//     child.body.child
//   } else {
//     child.body
//   }
//   return if body.func() == func-seq and body.children.len() > 0 {
//     let elem-args-arr = ()
//     let dic = for e in body.children {
//       if e == [ ] {
//         continue
//       }
//       let args = parse-item(e)
//       if args == none {
//         break
//       } else {
//         elem-args-arr.push(args)
//       }
//     }
//     parse-item-args-arr(elem-args-arr)
//   } else {
//     parse-item-args(parse-item(body))
//   }
// }
