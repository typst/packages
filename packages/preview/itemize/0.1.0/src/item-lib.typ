#import "fix-enum-list.typ" as fel


/// Returns the relative nesting depth of an item within an enumeration.
///
/// Returns:
///   The nesting level (1-based index) of the current enumeration item.
///
/// -> int
#let level() = {
  return fel.curr-parent-level.get().len() + 1
}

/// Returns the relative nesting depth of an item within a list.
///
/// Returns:
///   The nesting level (1-based index) of the current list item.
///
/// -> int
#let list-level() = {
  return fel.list-level.get() + 1
}

/// Returns the level counts of the current enumeration item.
///
/// Returns:
///   An array containing the count at each nesting level for the current item.
///
/// > array
#let level-count() = {
  return fel.curr-parent-level.get()
}

/// Reference formatter for enumeration items (supports `@` syntax).
///
/// Usage:
///   Add `#show ref: ref-enum` at document start.
///
/// Returns:
///   Formatted reference content
///
/// Parameters:
///   - it (): The reference target
///   - full (auto|bool): Whether to show full hierarchical numbering.
///     Default: `auto` (inherits from enum context)
///   - numbering (str|function|auto): Numbering pattern or formatter.
///     Default: `auto` (inherits from enum context)
///   - supplement (auto|content): Supplemental content for reference.
///   - no-label-warning (bool): Show warning for missing labels.
///
/// -> content
#let ref-enum(it, full: auto, numbering: auto, supplement: auto, no-label-warning: false) = {
  let el = it.element
  if el != none {
    if el.func() == text or el.func() == enum.item or el.func() == metadata and el.value == fel.enum-ID {
      let enum-count = fel.curr-parent-level.at(it.target)
      if enum-count.len() > 0 {
        let supplement-body = if it.supplement == auto {
          if supplement != auto {
            supplement
          }
        } else {
          it.supplement
        }
        let number-body = if numbering != auto {
          [#std.numbering(numbering, ..enum-count)]
        } else {
          let _full = full
          let (numbering, full) = fel.enum-numbering.at(it.target)
          if (_full == auto and full) or (_full == true) {
            [#std.numbering(numbering, ..enum-count)]
          } else {
            [#fel.apply-numbering-kth(numbering, enum-count.len() - 1, enum-count.last())]
          }
        }
        let content = [#supplement-body~#number-body]
        link(el.location(), content)
      } else {
        it
      }
    } else {
      it
    }
  } else {
    if no-label-warning [#text(weight: "bold", fill: red)[[???]]] else { it }
  }
}



/// Creates a labeled reference point for enumeration items.
///
/// Note:
///   - Only works when attached to `text`/`enum.item` elements
///   - Use this when regular `label()` won't work with enum references
/// Returns:
///   Formatted reference content
///
/// Parameters:
///   - name (str | label): Label identifier
///
/// -> content
#let elabel(name) = {
  let _label = if type(name) == str {
    label(name)
  } else if type(name) == label {
    name
  } else {
    panic("invalid argument: name should be str or label")
  }
  [#metadata(fel.enum-ID)#_label]
}


/// Configures default styling for enumerations and lists.
///
/// - doc (): The document content to process.
/// - indent (length, array, function, auto): Indentation value (default: auto).
///   - If `indent` is `auto`, the item will be indented by the value of `indent` of `enum` or `list`.
///   - If `indent` is an `array`, whose elements are `length` or `auto`, each level of the item will be indented by the corresponding value of the array at position `level - 1`. The last value of the array will be used for residual levels.
///   - If `indent` is a `function`, the return value will be used for each level of the item. The function should be declared as:
///     ```typ
///     (level, label-width, level-type) => (length, auto)
///     ```
///     Where:
///     - `level` indicates the level of the item to be indented.
///     - `label-width` captures the label width of items from level 1 to the current level (i.e., [1, `level`]). Use `(label-width.get)(some-level)` to get the label width at level `some-level` or `label-width.current` for the current level (equivalent to `(label-width.get)(level)`).
///     - `level-type` captures the construction (`enum` or `list`) of items from level 1 to the current level. Use `(level-type.get)(some-level)` or `level-type.current`.
///     - Tip: If you don't need `label-width` or `level-type`, declare the function as:
///       ```typ
///       (level, ..args) => (length, auto)
///       ```
///       or
///       ```typ
///       (level, _, _) => (length, auto)
///       ```
///       or
///       ```typ
///       (level, label-width, _) => (length, auto)
///       ```
///       etc.
///
///     Example:
///     ```typ
///     #let f = (level, label-width, level-type) => {
///         if level >= 2 {
///             -(label-width.get)(level - 1) - (level-type.get)(level - 1).body-indent
///         }
///     }
///     ```
///
/// - body-indent (length, array, function, auto): Body indentation value (default: auto), i.e., the space between the numbering and the body of each item.
///   - If `auto`, it uses the value of `body-indent` of `enum` or `list`.
///   - Similar to the `indent` parameter.
///
/// - is-full-width (bool): Whether to use full width (default: true). This may temporarily fix the bug where block-level equations in the item are not center-aligned in some cases (not an ideal solution).
///
/// - item-spacing (length, array, dictionary, auto): Spacing between items (default: auto).
///   - If `length`, the spacing above and below each item is this value.
///   - If `dictionary`, it should be in the form `(above: value1, below: value2)`, where `above` and `below` define the spacing.
///   - If `auto`, it uses the value of `spacing` of `enum` or `list`.
///   - If `array`, each level of the item uses the corresponding value of the array at position `level - 1`. The last value is used for residual levels.
///
/// - label-indent (length, array, function, auto): The space between the numbering and the left/right side of the item (default: `0em` if `auto`).
///   - Similar to the `indent` parameter.
///
/// - enum-spacing (length, array, dictionary, auto): Spacing between enumerations and lists (default: auto).
///   - If `auto`, it uses the current paragraph spacing or leading (`par.spacing` or `par.leading`), depending on the `tight` parameter of `enum` or `list`.
///   - Similar to `item-spacing`.
///
/// - enum-margin (length, array, auto): Margin of items for enumerations and lists (default: auto).
///   - To make `enum-margin` effective, set `is-full-width` to `false`.
///   - If `auto`, the item width is `auto`.
///   - If `array`, each level uses the corresponding value of the array at position `level - 1`. The last value is used for residual levels.
///
/// - hanging-indent (length, array, function, auto): The indent for all but the first line of a paragraph (default: auto).
///   - If `auto`, it uses the hanging indent of the current paragraph (`par.hanging-indent`).
///   - Similar to `indent`.
///
/// - line-indent (length, array, function, auto): The indent for the first line of a paragraph (default: auto).
///   - If `auto`, it uses the first line indent of current paragraph  (`par.first-line-indent.amount`).
///   - Similar to `indent`.
///
/// - args (arguments): Used to format the text of the numbering. Accepts all named parameters of the `text` function (e.g., `fill: red`, `size: 4em`, `weight: "bold"`).
///   - Values can be `array` or `auto`:
///     - If `auto`, it uses the current `text` value.
///     - If `array`, each level uses the corresponding value of the array at position `level - 1`. The last value is used for residual levels.
///
/// -> any
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
  ..args,
) = {
  show enum: fel.fix-enum.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    absolute-level: true,
    ..args,
  )
  show list: fel.fix-list.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    absolute-level: true,
    ..args,
  )
  doc
}

/// Configures paragraph styling for enumerations and lists.
///
///
/// Returns:
///   Processed document with applied styling
///
/// Parameters:
///
///   - doc (): Document content to process
///   - indent (auto|length|array|function): Indentation value
///   - body-indent (auto|length|array|function): Body indentation
///   - label-indent (auto|length|array|function): Label indentation
///   - is-full-width (bool): Use full width layout
///   - item-spacing (auto|length|array|dictionary): Spacing between items
///   - enum-spacing (auto|length|array|dictionary): Spacing between enumerations
///   - enum-margin (auto|length|array): Margin for enumerations
///   - hanging-indent (auto|length|array|function): Hanging indent
///   - line-indent (auto|length|array|function): first-line indent
///   - args (): Additional formatting arguments
///
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
  ..args,
) = {
  show enum: fel.fix-enum.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "paragraph",
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    absolute-level: true,
    ..args,
  )
  show list: fel.fix-list.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "paragraph",
    hanging-indent: hanging-indent,
    line-indent: line-indent,
    absolute-level: true,
    ..args,
  )
  doc
}

/// Configures default styling for enumerations.
///
///
/// Returns:
///   Processed document with applied styling
///
/// Parameters:
///
///   - doc (): Document content to process
///   - indent (auto|length|array|function): Indentation value
///   - body-indent (auto|length|array|function): Body indentation
///   - label-indent (auto|length|array|function): Label indentation
///   - is-full-width (bool): Use full width layout
///   - item-spacing (auto|length|array|dictionary): Spacing between items
///   - enum-spacing (auto|length|array|dictionary): Spacing between enumerations
///   - enum-margin (auto|length|array): Margin for enumerations
///   - hanging-indent (auto|length|array|function): Hanging indent
///   - line-indent (auto|length|array|function): first-line indent
///   - args (): Additional formatting arguments
///
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
  ..args,
) = {
  show enum: fel.fix-enum.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "default",
    hanging-indent: hanging-indent,
    absolute-level: false,
    ..args,
  )
  doc
}

/// Configures paragraph styling for enumerations.
///
///
/// Returns:
///   Processed document with applied styling
///
/// Parameters:
///
///   - doc (): Document content to process
///   - indent (auto|length|array|function): Indentation value
///   - body-indent (auto|length|array|function): Body indentation
///   - label-indent (auto|length|array|function): Label indentation
///   - is-full-width (bool): Use full width layout
///   - item-spacing (auto|length|array|dictionary): Spacing between items
///   - enum-spacing (auto|length|array|dictionary): Spacing between enumerations
///   - enum-margin (auto|length|array): Margin for enumerations
///   - hanging-indent (auto|length|array|function): Hanging indent
///   - line-indent (auto|length|array|function): first-line indent
///   - args (): Additional formatting arguments
///
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
  ..args,
) = {
  show enum: fel.fix-enum.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "paragraph",
    hanging-indent: hanging-indent,
    absolute-level: false,
    ..args,
  )
  doc
}

/// Configures default styling for lists.
///
///
/// Returns:
///   Processed document with applied styling
///
/// Parameters:
///
///   - doc (): Document content to process
///   - indent (auto|length|array|function): Indentation value
///   - body-indent (auto|length|array|function): Body indentation
///   - label-indent (auto|length|array|function): Label indentation
///   - is-full-width (bool): Use full width layout
///   - item-spacing (auto|length|array|dictionary): Spacing between items
///   - enum-spacing (auto|length|array|dictionary): Spacing between enumerations
///   - enum-margin (auto|length|array): Margin for enumerations
///   - hanging-indent (auto|length|array|function): Hanging indent
///   - line-indent (auto|length|array|function): first-line indent
///   - args (): Additional formatting arguments
///
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
  ..args,
) = {
  show list: fel.fix-list.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "paragraph",
    hanging-indent: hanging-indent,
    absolute-level: false,
    ..args,
  )
  doc
}

/// Configures paragraph styling for lists.
///
///
/// Returns:
///   Processed document with applied styling
///
/// Parameters:
///
///   - doc (): Document content to process
///   - indent (auto|length|array|function): Indentation value
///   - body-indent (auto|length|array|function): Body indentation
///   - label-indent (auto|length|array|function): Label indentation
///   - is-full-width (bool): Use full width layout
///   - item-spacing (auto|length|array|dictionary): Spacing between items
///   - enum-spacing (auto|length|array|dictionary): Spacing between enumerations
///   - enum-margin (auto|length|array): Margin for enumerations
///   - hanging-indent (auto|length|array|function): Hanging indent
///   - line-indent (auto|length|array|function): first-line indent
///   - args (): Additional formatting arguments
///
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
  ..args,
) = {
  show list: fel.fix-list.with(
    indent: indent,
    body-indent: body-indent,
    label-indent: label-indent,
    is-full-width: is-full-width,
    item-spacing: item-spacing,
    enum-spacing: enum-spacing,
    enum-margin: enum-margin,
    hanging-type: "paragraph",
    hanging-indent: hanging-indent,
    absolute-level: false,
    ..args,
  )
  doc
}
