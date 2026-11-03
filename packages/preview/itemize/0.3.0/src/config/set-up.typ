#import "../lib/ref-lib.typ": ref-enum

#import "../core/feat-item-lib.typ": ref-resume-list
#import "../util/level-state.typ": auto-detect-tight, default-setting-checklist, setting-checklist
#import "../util/identifier.typ": paragraph-ID


/// Configure checklist settings for a document.
/// - doc (content): The document to apply the checklist settings to.
/// - args (argument): Contains the following arguments:
///   - baseline (`auto`, `"center"`, `"top"`, `"bottom"`, `"baseline"`, `array`): The baseline alignment for checklist labels (same as `label-baseline` with `"center"`, `"top"`, `"bottom"`, `"baseline"`). Default is `auto`, controlled by `label-baseline` of the method `*-enum-list` (`*-enum`, `*-list`).
///   - fill (`auto`, `color`, `none`, `array`): The fill color for checklist items. If set to `auto`, it uses the current label's text style. Default is `auto`.
///   - radius (`auto`, `length`, `dictionary`, `array`): The border radius for checklist items (default: `.1em`). See also `block.radius`.
///   - solid (`none`, `color`, `array`): The solid border style for checklist items (default: `none`).
///   - extras (`bool`, `array`): Whether to enable extra features (default: `false`). If `true`, then use the following additional commands:
///     ```
///     ">": "➡",
///     "<": "📆",
///     "?": "❓",
///     "!": "❗",
///     "*": "⭐",
///     "\"": "❝",
///     "l": "📍",
///     "b": "🔖",
///     "i": "ℹ️",
///     "S": "💰",
///     "I": "💡",
///     "p": "👍",
///     "c": "👎",
///     "f": "🔥",
///     "k": "🔑",
///     "w": "🏆",
///     "u": "🔼",
///     "d": "🔽",
///     ```
///   - enable-character (`bool`, `array`): Whether to enable character-based labels (default: `true`). When set to `true`, if the character in `[...]` is not among `x`, ` `, `-`, `/` or the extras characters (if `extras` is `true`), the character in `[...]` will be displayed.
///   - enable-format (`bool`, `array`): Whether to enable formatting for the item body, with the format content determined by `format-map` (default: `false`). The default formatting is for the character `"-"`, with the formatting function:
///     ```typst
///     it => strike(text(fill: rgb("#888888"), it))
///     ```
///   - symbol-map (`dictionary`, `function`, `array`): A map of symbols for checklist items (default: `(:)`).
///     - `dictionary`: Can replace built-in commands or add new ones.
///       - The key-value pair is: `("some-character": content)`.
///     - `function`: The function form is: `it => dictionary` (the `dictionary` is the above form), where `it` provides three properties: `fill`, `radius`, `solid`.
///   - format-map (`dictionary`, `array`): A map of formats for checklist items (default: `(:)`). Formatting for list items.
///     - The key-value pair is: `("some-character": func)`.
///     - `func` takes the form `it => content`. It applies the body of the current `some-character` item to this method.
/// -> content
#let config-checklist(
  doc,
  ..args,
) = {
  let args-dic = args.named()
  setting-checklist.update(dic => {
    dic.prev-checklist.push(dic)
    if "enable-format" in args-dic { dic.enable-format = args-dic.enable-format }
    if "enable-character" in args-dic { dic.enable-character = args-dic.enable-character }
    if "baseline" in args-dic { dic.label-baseline = args-dic.baseline }
    if "fill" in args-dic { dic.checklist-fill = args-dic.fill }
    if "radius" in args-dic { dic.checklist-radius = args-dic.radius }
    if "solid" in args-dic { dic.checklist-solid = args-dic.solid }
    if "extras" in args-dic { dic.extras = args-dic.extras }
    if "symbol-map" in args-dic { dic.checklist-map = args-dic.symbol-map }
    if "format-map" in args-dic { dic.checklist-format-map = args-dic.format-map }
    dic
  })
  { show list: it => it }
  doc
  setting-checklist.update(dic => {
    dic.prev-checklist.pop()
  })
}

/// Configure enum reference settings for a document.
/// - doc (content): The document to apply the reference settings to.
/// - full (auto, bool, "ref"): Determine to display the full enum numbers.
///   - `auto`: Use the `enum.full` setting.
///   - `true` Display the full number (including parent levels).
///   - `false` Display only the current item's number.
///   - `"ref"` Display the reference number items in a relative manner (i.e., If the current item and the reference item have the same parent level (in the same parent enum), the same parent level is not displayed.)
/// - numbering (auto, string, function): Numbering pattern.
///   - `auto`: Use the `enum.numbering`.
///   - `string`, `function`: Customize the style of the referenced item number. See also `enum.numbering`.
/// - supplement (auto, content, dictionary, function, array): Supplemental content for the reference.
///   - `auto`: No supplementary content will be added.
///   - `content`: Use `content` as supplementary content. The effect is that when referencing `enum` or `list` labels, then content is added before the label.
///   - `dictionary`: The keys are: `prefix`, `suffix`, with values of `content`. The effect is that when referencing enum (list) labels, `prefix` content is added before the label, and `suffix` content is added after the label.
///   - `array` (level-property): The elements are `auto`, `content`, `dictionary` or `array`. The item at `level`-th level will be indented by the corresponding value of the array at position `level - 1`.
///     - If the last element of the array is `LOOP`, the values in the array will be used cyclically;
///     - otherwise, the last value of the array will be used for residual levels.
///     - The elements in the array can also be an array, where the element at position `n - 1` applies to the item of index `n`. *Note*: Not support for `list`.
///   - `function` (level-property): Customize the supplementary content.
///     - The function form: `it => content`.
///     - Access the following values available on `it`:
///       - `it.body`: The referenced `enum` labels.
///       - `it.level` (Only for `enum`): The level of the item, starting from 1.
///       - `it.n` (Only for `enum`): The index of the item, starting from 1.
///       - `it.n-last` (Only for `enum`): The index of the last item in the current level.
///       - `it.tag` (since ver0.3.0) (Only for `enum`): The tag of the item.
///       - `it.elem-tag` (since ver0.3.0) (Only for `enum`): The tag of the `enum` or `list`.
///       - `it.target` (since ver0.3.0): The target of the referenced label.
///       - `it.number` (since ver0.3.0) (Only for `enum`): The number of the referenced item.
///       - `it.numbers` (since ver0.3.0): The full numbers of the referenced item (including the parent `enum`'s numbers). For `list`, this is `()`.
/// - no-label-warning (bool): Whether to disable the warning when the reference label is not found (default: `false`); note that this applies to all references in the document, so we recommend _not_ setting it to `true`.
///
/// -> content
#let config-ref(doc, full: auto, numbering: auto, supplement: auto, no-label-warning: false) = {
  show ref: ref-enum.with(full: full, numbering: numbering, supplement: supplement, no-label-warning: no-label-warning)
  doc
}

/// Configure resume reference settings for a document.
///   - If you use the following in your document:
///      ```typst
///      #show: el.config.ref-resume
///      ```
///
///   then you can use `@some-label` instead of `resume-list(<some-label>)`.
/// - doc (content): The document to apply the resume reference settings to.
/// -> content
#let config-ref-resume(doc) = {
  show ref: ref-resume-list
  doc
}

/// Configure auto-detect-tight settings for a document. If `enable` is `true` and the current `whole-spacing` is `auto`, enable a compact mode between the list and the paragraph below it.
/// - *Note*: Related to the parameter `tight-mode` in `*-enum-list` (`*-enum`, `*-list`).
/// - Usage:
///   ```typst
///   #show: el.config.auto-detect-tight
///   ```
/// - doc (content): The document to apply.
/// - enable (bool): Enable or disable a compact mode between the list and the paragraph below it, controlled by `tight-mode` settings.
///
/// -> content
#let config-auto-detect-tight(doc, enable: true) = {
  if enable == false {
    auto-detect-tight.update(false)
    doc
  } else {
    auto-detect-tight.update(true)
    show parbreak: p => {
      p
      metadata(paragraph-ID)
    }
    doc
    auto-detect-tight.update(false)
  }
}


