#import "../core/item-lib.typ": ref-enum
#import "../core/feat-item-lib.typ": ref-resume-list
#import "../util/level-state.typ": default-setting-checklist, setting-checklist


/// Configure checklist settings for a document.
/// - doc (any): The document to apply the checklist settings to.
/// - enable (bool, array): Whether the checklist is enabled (default: true).
/// - baseline (auto, "center", "top", "bottom", array): The baseline alignment for checklist labels (same as `label-baseline` with `"center"`, `"top"`, `"bottom"`). Default is `auto`, controlled by `label-width`.
/// - fill (auto, color, array): The fill color for checklist items (default: auto). If set to `auto`, it uses the current label's style.
/// - radius (length, array): The border radius for checklist items (default: .1em).
/// - solid (none, color, array): The solid border style for checklist items (default: none).
/// - extras (bool, array): Whether to enable extra features (default: false). If `true`, then use the following additional commands:
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
/// - enable-character (bool, array): Whether to enable character-based labels (default: true). When set to `true`, if the character in `[...]` is not among `x, , - /` or the extras characters (if `extras` is `true`), the character in `[...]` will be displayed.
/// - enable-format (bool, array): Whether to enable formatting for the body, with the format content determined by `format-map` (default: false). The default formatting is for the character `"-"`, with the formatting function:
///     ```typst
///     it => strike(text(fill: rgb("#888888"), it))
///     ```
/// - symbol-map (dictionary, function): A map of symbols for checklist items (default: (:)).
///   - Can replace built-in commands or add new ones.
///      - The  format is: `("some-character": content)`.
///   - If a function is specified, its form is: `it => dictionary`, where `it` provides three properties: `fill`, `radius`, `solid`.
/// - format-map (dictionary): A map of formats for checklist items (default: (:)). Formatting for list items.
///   - The format follows: `("some-character": some-function)`.
///   - `some-function` takes the form `it => ...`, It applies the body of the current `some-character` item to this method.
/// -> any
#let config-checklist(
  doc,
  enable: true,
  baseline: auto,
  fill: auto,
  radius: .1em,
  solid: none,
  extras: false,
  enable-character: true,
  enable-format: false,
  symbol-map: (:),
  format-map: (:),
) = {
  setting-checklist.update(dic => {
    dic.prev-checklist.push(dic)
    if dic.enable != enable { dic.enable = enable }
    if dic.label-baseline != baseline { dic.label-baseline = baseline }
    if dic.checklist-fill != fill { dic.checklist-fill = fill }
    if dic.checklist-radius != radius { dic.checklist-radius = radius }
    if dic.checklist-solid != solid { dic.checklist-solid = solid }
    if dic.checklist-map != symbol-map { dic.checklist-map = symbol-map }
    if dic.checklist-format-map != format-map { dic.checklist-format-map = format-map }
    if dic.extras != extras { dic.extras = extras }
    if dic.enable-character != enable-character { dic.enable-character = enable-character }
    if dic.enable-format != enable-format { dic.enable-format = enable-format }
    return dic
  })
  show list: it => it
  doc
  setting-checklist.update(dic => {
    dic.prev-checklist.pop()
  })
}

/// Configure enum reference settings for a document.
/// - doc (any): The document to apply the reference settings to.
/// - full (auto, bool): Default is `auto`, using the `full` value from `enum`. `true` displays the full number (including parent levels); `false` displays only the current item's number.
/// - numbering (auto, function, str): Numbering pattern or formatter. Default is `auto`, using the `numbering` of the referenced `enum`. You can customize the style of the referenced item number.
/// - supplement (auto, content): Supplemental content for the reference. (default: auto).
/// -> any
#let config-ref(doc, full: auto, numbering: auto, supplement: auto) = {
  show ref: ref-enum.with(full: full, numbering: numbering, supplement: supplement)
  doc
}

/// Configure resume reference settings for a document.
///   - If you use the following in your document:
///      ```typst
///      #show: el.config.ref-resume
///      ```
///       You can use `@some-label` instead of `resume-list(<some-label>)`.
/// - doc (any): The document to apply the resume reference settings to.
/// -> any
#let config-ref-resume(doc) = {
  show ref: ref-resume-list
  doc
}

