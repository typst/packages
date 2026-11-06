#import "core/feat-enum-list.typ" as fel


/// To generate methods for exporting and configuring enums and lists
#let get-list-enum-method(
  doc,
  elem, // "both", "list", "enum"
  indent,
  body-indent,
  label-indent,
  is-full-width,
  item-spacing,
  enum-spacing,
  enum-margin,
  hanging-type,
  hanging-indent,
  line-indent,
  label-width,
  body-format,
  label-format,
  item-format,
  auto-base-level,
  label-align,
  label-baseline,
  auto-resuming,
  auto-label-width,
  checklist,
  enum-config,
  list-config,
  ..args,
) = {
  let nested-auto-resume = state("__nested-auto-resume___", false)
  if auto-resuming != none {
    if auto-resuming == auto {
      context if nested-auto-resume.get() {
        panic("Inside `list` or `enum`, `auto-resuming` can not be set to be `auto` again.")
      }
      nested-auto-resume.update(true)
    }
    if auto-resuming != auto {
      context if fel.item-level.get().len() > 0 {
        panic("Inside `list` or `enum`, `auto-resuming` can not be set to be`" + [#auto-resuming].text + "`.")
      }
      let global-resuming = state(fel.global-setting-ID-auto-resuming, false)
      context if global-resuming.get() {
        panic("In each document, `auto-resuming` can be set once for non `auto` or `none`.")
      }

      global-resuming.update(true)
    }
  }
  if auto-label-width != none {
    if auto-label-width != auto {
      context if fel.item-level.get().len() > 0 {
        panic("Inside `list` or `enum`, `auto-label-width` can not be set to `" + [#auto-label-width].text + "`.")
      }
      context {
        let global-label-width = state(fel.global-setting-ID-auto-label-width, false)

        assert(
          not global-label-width.get(),
          message: "In each document, `auto-label-width` can be set once for non `auto` or `none`"
            + "\n"
            + "Hint: set `auto-label-width` to be `auto` and use method `auto-label-item` instead.",
        )
        global-label-width.update(true)
      }
    }
  }

  let override-enum = if auto-resuming == none and auto-label-width == none {
    fel.fix-enum
  } else {
    if elem == "list" {
      fel.fix-enum
    } else {
      fel.feat-enum.with(auto-resuming: auto-resuming, auto-label-width: auto-label-width)
    }
  }
  let override-list = if auto-resuming == none and auto-label-width == none {
    fel.fix-list
  } else {
    if elem == "enum" {
      fel.fix-list
    } else {
      if elem == "list" {
        if auto-label-width != none {
          fel.feat-list.with(auto-label-width: auto-label-width)
        } else {
          fel.fix-list
        }
      } else {
        // elem == "both"
        fel.feat-list.with(auto-resuming: auto-resuming, auto-label-width: auto-label-width)
      }
    }
  }
  let argument = (
    elem: elem,
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: hanging-type, // classic paragraph
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    label-width: label-width,
    body-format: body-format,
    label-format: label-format,
    item-format: item-format,
    label-align: label-align,
    label-baseline: label-baseline,
    checklist: checklist,
    auto-base-level: auto-base-level,
  )
  let parse-doc = doc => {
    if item-format != none {
      if elem == "both" {
        show selector(enum).or(list): fel.privent-label-text-style-all
        doc
      } else if elem == "enum" {
        show enum: fel.privent-label-text-style-all
        doc
      } else if elem == "list" {
        show list: fel.privent-label-text-style-all
        doc
      }
    } else {
      doc
    }
  }

  if elem == "both" {
    show enum: override-enum.with(
      ..args,
      ..argument,
      enum-config: enum-config,
      list-config: list-config,
      func-enum: override-enum,
      func-list: override-list,
      absolute-level: true,
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
    parse-doc(doc)
  } else if elem == "enum" {
    show enum: override-enum.with(
      ..args,
      ..argument,
      func-enum: override-enum,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    show list: override-list.with(
      elem: "enum",

      is-full-width: false, // make the same behaviour as native one
      // func-enum: override-enum,
      func-list: override-list,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    parse-doc(doc)
  } else if elem == "list" {
    show enum: override-enum.with(
      elem: "list",

      is-full-width: false, // make the same behaviour as native one
      func-enum: override-enum,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    show list: override-list.with(
      ..args,
      ..argument,
      func-list: override-list,
      enum-config: (:),
      list-config: (:),
      absolute-level: false,
    )
    parse-doc(doc)
  }
  if auto-resuming == auto {
    nested-auto-resume.update(false)
  }
}


/*自动生成*/


/// Configures default styling for `enum` and `list`.
///
/// - doc (content): The document content to process.
/// - indent (length, array, function, auto): The indent of enum or list (default: auto).
///   - If `indent` is `auto`, the item will be indented by the value of `indent` of `enum` or `list`.
///   - If `indent` is an `array`, whose elements are `length` or `auto` or `array`, each level of the item will be indented by the corresponding value of the array at position `level - 1`. The last value of the array will be used for residual levels.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically.
///     - The elements in the array can also be an array, where each element applies to the corresponding item.
///   - If `indent` is a `function`, the return value will be used for each level and each item. The function should be declared as:
///     ```typ
///     it => length | auto | array
///     ```
///     - `it` is a dictionary that contains the following keys:
///       - `level`: The level of the item, starting from 1.
///       - `n`: The index of the item, starting from 1.
///       - `n-last`: The index of the last item in the current level, starting from 1.
///       - `label-width`: The label max-width of the item. `label-width` captures the label width of items from level 1 to the current level (i.e., [1, `level`]). Use `(label-width.get)(some-level)` to get the label width at level `some-level` or `label-width.current` for the current level (equivalent to `(label-width.get)(level)`).
///       - `e`: captures the construction (`enum` or `list`) of items from level 1 to the current level. Use `(level-type.get)(some-level)` or `level-type.current`.
///     Here's an example using a `function` to align all `label`s to the left:
///      ```typst
///      #let indent-f = it => {
///         if it.level >= 2 {
///            -(it.label-width.get)(it.level - 1) - (it.e.get)(it.level - 1).body-indent
///          } else {
///            auto
///          }
///      }
///      #show: el.default-enum-list.with(indent: indent-f)
///      ```
///    - If the return value is an `array`, it will be used for each item.
/// - body-indent (length, array, function, auto): Body indentation value (default: auto), i.e., the space between the label and the body of each item.
///   - If `auto`, it uses the value of `body-indent` of `enum` or `list`.
///   - Similar to the `indent` parameter.
/// - label-indent (length, array, function, auto): The indentation value for the first line of an item. (default: `0em` if `auto`).
///   - Similar to the `indent` parameter.
/// - is-full-width (bool): Whether to use full width (default: true). This may temporarily fix the bug where block-level equations in the item are not center-aligned in some cases (not an ideal solution).
/// - item-spacing (length, array, function, auto): Spacing between items (default: auto).
///   - If `length`, the spacing between each item is this value.
///   - If `auto`, it uses the value of `spacing` of `enum` or `list`.
///   - If `array`, each level of the item uses the corresponding value of the array at position `level - 1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically, else,
///     - The last value is used for residual levels.
///   - If `function`, the return value will be used for each level and each item.
///     - See `indent` for details.
///
/// - enum-spacing (length, array, dictionary, auto): Spacing between enums and lists (default: auto).
///   - If `auto`, it uses the current paragraph spacing or leading (`par.spacing` or `par.leading`), depending on the `tight` parameter of `enum` or `list`.
///   - Similar to `item-spacing`.
/// - enum-margin (length, array, auto, function): Margin of items for enums and lists (default: auto).
///   - To make `enum-margin` effective, set `is-full-width` to `false`.
///   - If `auto`, the item width is `auto`.
///   - Similar to `item-spacing`.
/// - hanging-indent (length, array, function, auto): The indent for all but the first line of a paragraph (default: auto).
///   - If `auto`, it uses the hanging indent of the current paragraph (`par.hanging-indent`).
///   - Similar to `indent`.
/// - line-indent (length, array, function, auto): The indent for the first line of a paragraph excluding the first paragraph (default: auto).
///   - If `auto`, it uses the first line indent of current paragraph  (`par.first-line-indent.amount`).
///   - Similar to `indent`.
/// - auto-base-level (bool): To maintain compatibility with native behavior, the display of `numbering` and `marker` still uses absolute levels. This means even if you reconfigure `enum.numbering` and `list.marker` in sublists, the display of `numbering` and `marker` in sublists follows the absolute level rules. Default: `false`.
///   - If `auto-base-level` is set to `true`, then it treats the current level as 1.
///   - Note the difference when `enum.full` is set to `true` (only affects the current sublist).
///   - ⚠️ *Breaking change*: When configuring enums and lists using `*-enum-list`, `*-enum`, or `*-list`, the current level is treated as 1
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): An amount to shift the label baseline by. It can be taken
///   + `length`, `auto` or `"center"`, `"top"`, `"bottom"`,
///   + or a `dictionary` with the keys:
///     - `amount`: `length`, `auto` or `"center"`, `"top"`, `"bottom"`
///     - `same-line-style` : `"center"`, `"top"`, `"bottom"`
///     - `alone`: `bool`
///   - The first case is interpreted as `(amount: len, same-line-style: "bottom", alone: false)`
///   - When the label has a paragraph relationship with the first line of text in the current item, the label baseline will shift based on the value of `amount`.
///   - For `"center"`, `"top"`, and `"bottom"`, the label will be aligned to the center, top, or bottom respectively.
///     - ⚠️ We use the height of the first character (e.g., [A]) in the first line of the paragraph where the label is located. If you manually set the font style of the paragraph's text, this alignment may not be accurate, It is recommended to use the `style` parameter in `body-format` for adjustments.
///   - When the value of `amount` is `auto`, set it to `0pt`.
///   - If labels from different levels appear on the same line, their alignment is determined by `same-line-style`.
///   - If `alone` is `true`, it will not participate in the alignment of labels on the same line.
/// - body-format (none, dictionary): Sets the *text style* and *border style* of the body (default: none). It is a dictionary containing the following keys:
///   - `none`: Does not take effect.
///   - `style`: A dictionary that can include any named arguments of `text` to format the text style of `body`.
///   - `whole`, `outer`, `inner`: Dictionaries used to set the borders of the item.
///     - `whole`: Wraps the entire `enum` or `list`
///     - `outer`: Wraps the item (including the label)
///     - `inner`: Wraps the item (excluding the label)
///   - If `whole`, `outer`, or `inner` is omitted, the default is to set the border for `outer`.
///   - Supported border properties (consistent with `block` borders): `stroke`, `radius`, `outset`, `fill`, `inset`, `clip`.
///      - ⚠️ In ver0.2.x, `inset` with `relative` length is temporarily _not supported_!!!
///   - Each value in `style`, `whole`, `outer`, `inner` is also supported `array` and `function` types.
/// - label-format (none, function, array): Customize labels in any way. It takes
///   - `none`: Does not take effect
///   - `function`
///     - The form is: `it => ...`, Access
///       - `it.body` to get the label content,
///       - `it.level` for the current label's level
///       - `it.n` for the current label's index, and
///       - `it.n-last` for the index of the last label in the current level
///   - `array`
///     - The (`level-1`)-th element of the array applies to the label at the `level`-th level.
///     - Each element in the array can be:
///       + A `function` with the form `body => ...`, which applies the label's content to this function.
///       + A `content`, which outputs this content directly.
///       + `auto` or `none`, which means no processing will be done.
///       + An `array`:
///         - Its elements follow the meanings of 1, 2, and 3 above.
///         - The (`n-1`)-th element of the array applies to the `n`-th item's label at the current level.
///    - This method can not only control the style of labels, but also control the content displayed by the current label. In the current version `0.2.x`, we recommend using `enum.numbering` (along with the `numbly` package) to control the output content of labels in `enum`, and `list.marker` to control the output content of labels in `list`.
///    - ⚠️ We no longer recommend formatting labels using `enum.numbering` as in ver0.1.x, In complex cases, it may also cause "layout did not converge within 5 attempts".
///
/// - item-format (function, array, none): Experimental Feature. Freely customize the format of each item's body (default: none).
///  + `none`: Does not take effect.
///  + It accepts a `function` with form:
///    ```typst
///    it => ...
///    ```
///    which will apply to the body of each item'body. `it` has the following properties:
///     - `it.level`: The level of the current item.
///     - `it.body`: The body of the current item.
///     - `it.n`: The index of the current item in the current level.
///     - `it.n-last`: The index of the last item in the current level.
///   + an `array`, whose elements are `function` with form `body => ...` which will be applied to the body of each item in turn.
///   + or a `dictionary` with the following keys:
///     - `whole`: Wraps the entire `enum` or `list`
///     - `outer`: Wraps each item (including the label)
///     - `inner`: Wraps each item (excluding the label)
///     - If `whole`, `outer`, or `inner` is omitted, the default is `outer`.
///     - The values are taken as Case 2 and Case 3 above.
///
///  - However, this may disrupt the correct positioning of the list labels. (The main reason is that `itemize` needs to treat the label and the first line of the body as the same paragraph.).
/// - label-align (alignment, array, auto, function): The `alignment` that enum numbers and list markers should have.
///   - Unless `auto` is used, it cannot be be changed via `#set enum(number-align: ...)`.
///   - For native `list`, it has no such property.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
///   +  `auto`: Uses the native behavior.
///   +  `length`: The width of the label.
///   +  `dictionary`, with keys:
///      - `amount`: `length`, `auto`, or `"max"`.
///      - `style`: `"default"`, `"constant"`, `"auto"`, or `"native"`.
///   - The first case is equivalent to `(amount: len, style: "default")`, where `len` is the specified width value; The second case is equivalent to `(amount: max-width, style: "native")`, where `max-width` is the maximum width of labels at the current level.
///   - Here, `amount` also represents the hanging indent of the item's body (i.e., for the default style, the hanging indent length = `amount` + `body-indent`; for the paragraph style, the hanging indent length = `amount`).
///   - When `amount` is `"max"`, the value of `amount` is the maximum actual width of labels at the current level.
///   - Currently, the setting of `label-width` is also affected by the format of `label-format`, especially when `label-format` specifies width information. In this case, the actual width of the label will be determined by the width specified in `label-format` (usually set via constructs like `box.with(width: ...)`). It is recommended to set the container width in `label-format` to `auto` and then control it via `label-width`.
/// - auto-resuming (none, auto, array, bool): Relate to the feature `Resuming Enum`.
///   - `none`: Disables this feature.
///   - `auto`: Enables this feature. In this case, the following methods can be used.
///      - Use the method `resume()` to continue using the enum numbers from the previous enum at the same level.
///      - Use `resume[...]` to explicitly continue using the enum numbers from the previous level (especially in ambiguous cases) and treat the `[...]` as a new `enum`.
///      - Use the method `resume-label(<some-label>)` to label the enum you want to resume, and then use `resume-list(<some-label>)` in the desired enum to continue using the labelled enum numbers.
///         -  If you use the following in your document:
///            ```typst
///            #show: el.config.ref-resume
///            ```
///            You can use `@some-label` instead of `resume-list(<some-label>)`.
///     - Or use the method `auto-resume-enum(auto-resuming: true)[...]`, where all enum numbers within `[...]` will continue from the previous ones.
///     - The method `isolated-resume-enum[...]` allows the `[...]` to be treated as a new enum with independent numbering, without affecting other enums.
///   - `bool` | `array`: If `auto-resuming` is set to `true`, all enum numbers will continue from the previous ones. It can also be set as an array, e.g., `(false, true)` means the first level does not enable the resuming feature, while subsequent levels do.
///      - For small documents like exams, exercises, or CVs, if you need to resume enum numbers throughout the document, you can use the following at the beginning:
///       ```typst
///       #show : el.default-enum-list.with(auto-resuming: true)
///       ```
///       We recommend using this only at the document's start. Generally,
///         - `el.default-enum-list.with(auto-resuming: true)` and
///         - `el.default-enum-list.with(auto-resuming: auto)`
///       may interfere with each other.
///     - For large documents like books or articles, we recommend not setting `auto-resuming` at the beginning (i.e., leave it as `none`). Instead, set this parameter to `auto` in the required sublists and use it with methods like `resume`, `resume-label`, `resume-list`, or `auto-resume-enum`.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): To ensure consistent first-line indentation of the body across different enums and lists, you can now set `auto-label-width` to `auto` and use the method `auto-label-item` to align the sublists within.
///   - `none`: Disables this feature.
///   - `auto`: Enables this feature and uses the method `auto-label-item` to align the sublists within.
///   - "all", "each", "list", "enum" or an array: The values and meanings of `auto-label-width` are the same as those of the `form` parameter in the `auto-label-item` method.
///    - In a document, `auto-label-width` only retrieves the actual maximum width of labels at the current level of enums and lists.
/// - checklist (bool, array): Enables checklist.
///   - Alternatively, You can also enable and configure checklist-related features using the method `config.checklist`.
/// - args (arguments): Used to format the text of the numbering. Accepts all named parameters of the `text` function (e.g., `fill: red`, `size: 4em`, `weight: "bold"`).
///   - Values can be `array`, `auto` or `function`:
///     - If `auto`, it uses the current `text` value.
///     - If `array`, each level uses the corresponding value of the array at position `level - 1`.
///       - If the last element of the array is `LOOP`, the values in the array will be used cyclically, else,
///       - The last value is used for residual levels.
///    - if `function`, the return value will be used for each level and each item. The function should be declared as:
///     ```typ
///     it => some-value | auto | array
///     ```
///     - `it` is a dictionary that contains the following keys:
///       - `level`: The level of the item.
///       - `n`: The index of the item.
///       - `n-last`: The index of the last item.
/// - enum-config (dictionary): Configure `enum` in `doc` (default: (:)).
///    - The parameter type is a dictionary, and the currently allowed properties (keys) are:
///       - `indent`,
///       - `body-indent`,
///       - `label-indent`,
///       - `is-full-width`,
///       - `item-spacing`,
///       - `enum-spacing`,
///       - `enum-margin`,
///       - `hanging-indent`,
///       - `line-indent`,
///       - `label-width`,
///       - `label-align`,
///       - `label-baseline`,
///       - `label-format`,
///       - `body-format`,
///       - any named arguments of the function `text`
///    - Rules: If both `*-enum-list` and `enum-config` have the same property set, the rules are:
///       - The settings in `enum-config`  take precedence.
///       - For properties of function type, a composite operation is used, where the inner function is provided by `enum-config`:
///           - `label-format`, `item-format`
///       - For properties that are dictionaries composed of multiple attributes, these attributes are merged, and if the same attribute exists, the value from `enum-config` is used.
//            - `body-format`
/// - list-config (dictionary): Configure `list` in `doc` (default: (:)).
///   - Similar to `enum-config`.
/// -> content
#let default-enum-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  ..args,
  enum-config: (:),
  list-config: (:),
) = {
  return get-list-enum-method(
    doc,
    "both", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "classic",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    checklist,
    enum-config,
    list-config,
    ..args,
  )
}


/// Configures paragraph styling for `enum` and `list`.
///
/// See `default-enum-list`.
///
/// - doc (content): The document to process.
/// - indent (length, array, function, auto): The indentation level.
/// - body-indent (length, array, function, auto): The body indentation level.
/// - label-indent (length, array, function, auto): The label indentation level.
/// - is-full-width (bool): Whether the element spans full width.
/// - item-spacing (length, array, function, auto): Spacing between items.
/// - enum-spacing (length, array, dictionary, auto): Spacing specific to enumerations.
/// - enum-margin (length, array, auto, function): Margin around enumerations.
/// - hanging-indent (length, array, function, auto): The hanging indentation level.
/// - line-indent (length, array, function, auto): The line indentation level.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
/// - body-format (none, dictionary): Formatting for the body.
/// - label-format (none, function, array): Formatting for the label.
/// - item-format (function, array, none): Formatting for individual items.
/// - auto-base-level (bool): Whether to auto-detect the base level.
/// - label-align (alignment, array, auto, function): Alignment for the label.
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): Baseline alignment for the label.
/// - auto-resuming (none, auto, array, bool): Whether to auto-resume the element.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): Whether to auto-adjust the label width.
/// - checklist (boolean, array): Whether the list is a checklist.
/// - enum-config (dictionary): Configuration for enumerations.
/// - list-config (dictionary): Configuration for lists.
/// - args (any): Used to format the text of the numbering. Accepts all named parameters of the `text` function
/// -> content
#let paragraph-enum-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  checklist: false,
  enum-config: (:),
  list-config: (:),
  ..args,
) = {
  return get-list-enum-method(
    doc,
    "both", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "paragraph",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    checklist,
    enum-config,
    list-config,
    ..args,
  )
}

/// Configures default styling for `enum`.
///
/// See `default-enum-list`.
///
/// - doc (content): The document to process.
/// - indent (length, array, function, auto): The indentation level.
/// - body-indent (length, array, function, auto): The body indentation level.
/// - label-indent (length, array, function, auto): The label indentation level.
/// - is-full-width (bool): Whether the element spans full width.
/// - item-spacing (length, array, function, auto): Spacing between items.
/// - enum-spacing (length, array, dictionary, auto): Spacing specific to enumerations.
/// - enum-margin (length, array, auto, function): Margin around enumerations.
/// - hanging-indent (length, array, function, auto): The hanging indentation level.
/// - line-indent (length, array, function, auto): The line indentation level.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
/// - body-format (none, dictionary): Formatting for the body.
/// - label-format (none, function, array): Formatting for the label.
/// - item-format (function, array, none): Formatting for individual items.
/// - auto-base-level (bool): Whether to auto-detect the base level.
/// - label-align (alignment, array, auto, function): Alignment for the label.
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): Baseline alignment for the label.
/// - auto-resuming (none, auto, array, bool): Whether to auto-resume the element.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): Whether to auto-adjust the label width.
/// - args (any): Used to format the text of the numbering. Accepts all named parameters of the `text` function
/// -> content
#let default-enum(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  ..args,
) = {
  return get-list-enum-method(
    doc,
    "enum", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "classic",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    // label-text-indent,
    auto-resuming,
    auto-label-width,
    false,
    (:),
    (:),
    ..args,
  )
}

/// Configures paragraph styling for `enum`.
///
/// See `default-enum-list`.
///
/// - doc (content): The document to process.
/// - indent (length, array, function, auto): The indentation level.
/// - body-indent (length, array, function, auto): The body indentation level.
/// - label-indent (length, array, function, auto): The label indentation level.
/// - is-full-width (bool): Whether the element spans full width.
/// - item-spacing (length, array, function, auto): Spacing between items.
/// - enum-spacing (length, array, dictionary, auto): Spacing specific to enumerations.
/// - enum-margin (length, array, auto, function): Margin around enumerations.
/// - hanging-indent (length, array, function, auto): The hanging indentation level.
/// - line-indent (length, array, function, auto): The line indentation level.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
/// - body-format (none, dictionary): Formatting for the body.
/// - label-format (none, function, array): Formatting for the label.
/// - item-format (function, array, none): Formatting for individual items.
/// - auto-base-level (bool): Whether to auto-detect the base level.
/// - label-align (alignment, array, auto, function): Alignment for the label.
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): Baseline alignment for the label.
/// - auto-resuming (none, auto, array, bool): Whether to auto-resume the element.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): Whether to auto-adjust the label width.
/// - args (any): Used to format the text of the numbering. Accepts all named parameters of the `text` function
/// -> content
#let paragraph-enum(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-resuming: none,
  auto-label-width: none,
  ..args,
) = {
  return get-list-enum-method(
    doc,
    "enum", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "paragraph",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    auto-resuming,
    auto-label-width,
    false,
    (:),
    (:),
    ..args,
  )
}

/// Configures default styling for `list`.
///
/// See `default-enum-list`.
///
/// - doc (content): The document to process.
/// - indent (length, array, function, auto): The indentation level.
/// - body-indent (length, array, function, auto): The body indentation level.
/// - label-indent (length, array, function, auto): The label indentation level.
/// - is-full-width (bool): Whether the element spans full width.
/// - item-spacing (length, array, function, auto): Spacing between items.
/// - enum-spacing (length, array, dictionary, auto): Spacing specific to enumerations.
/// - enum-margin (length, array, auto, function): Margin around enumerations.
/// - hanging-indent (length, array, function, auto): The hanging indentation level.
/// - line-indent (length, array, function, auto): The line indentation level.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
/// - body-format (none, dictionary): Formatting for the body.
/// - label-format (none, function, array): Formatting for the label.
/// - item-format (function, array, none): Formatting for individual items.
/// - auto-base-level (bool): Whether to auto-detect the base level.
/// - label-align (alignment, array, auto, function): Alignment for the label.
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): Baseline alignment for the label.
/// - auto-resuming (none, auto, array, bool): Whether to auto-resume the element.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): Whether to auto-adjust the label width.
/// - checklist (boolean, array): Whether the list is a checklist.
/// - args (any): Used to format the text of the numbering. Accepts all named parameters of the `text` function
/// -> content
#let default-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-label-width: none,
  checklist: false,
  ..args,
) = {
  return get-list-enum-method(
    doc,
    "list", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "classic",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    none,
    auto-label-width,
    checklist,
    (:),
    (:),
    ..args,
  )
}

/// Configures paragraph styling for `list`.
///
/// See `default-enum-list`.
///
/// - doc (content): The document to process.
/// - indent (length, array, function, auto): The indentation level.
/// - body-indent (length, array, function, auto): The body indentation level.
/// - label-indent (length, array, function, auto): The label indentation level.
/// - is-full-width (bool): Whether the element spans full width.
/// - item-spacing (length, array, function, auto): Spacing between items.
/// - enum-spacing (length, array, dictionary, auto): Spacing specific to enumerations.
/// - enum-margin (length, array, auto, function): Margin around enumerations.
/// - hanging-indent (length, array, function, auto): The hanging indentation level.
/// - line-indent (length, array, function, auto): The line indentation level.
/// - label-width (auto, length, dictionary, array, function): The width of the label.
/// - body-format (none, dictionary): Formatting for the body.
/// - label-format (none, function, array): Formatting for the label.
/// - item-format (function, array, none): Formatting for individual items.
/// - auto-base-level (bool): Whether to auto-detect the base level.
/// - label-align (alignment, array, auto, function): Alignment for the label.
/// - label-baseline (auto, length, array, function, dictionary, "center", "top", "bottom"): Baseline alignment for the label.
/// - auto-resuming (none, auto, array, bool): Whether to auto-resume the element.
/// - auto-label-width (none, auto, array, "all", "each", "list", "enum"): Whether to auto-adjust the label width.
/// - checklist (boolean, array): Whether the list is a checklist.
/// - args (any): Used to format the text of the numbering. Accepts all named parameters of the `text` function
/// -> content
#let paragraph-list(
  doc,
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  auto-base-level: false,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  label-align: auto,
  label-baseline: auto,
  auto-label-width: none,
  checklist: false,
  ..args,
) = context {
  return get-list-enum-method(
    doc,
    "list", // "both", "list", "enum"
    indent,
    body-indent,
    label-indent,
    is-full-width,
    item-spacing,
    enum-spacing,
    enum-margin,
    "paragraph",
    hanging-indent,
    line-indent,
    label-width,
    body-format,
    label-format,
    item-format,
    auto-base-level,
    label-align,
    label-baseline,
    none,
    auto-label-width,
    checklist,
    (:),
    (:),
    ..args,
  )
}
