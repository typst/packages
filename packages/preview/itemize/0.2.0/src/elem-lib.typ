
#import "export-el.typ" as ex-el

#import "@preview/elembic:1.1.1" as e: field, types


#let fold = prev-fold => (outer, inner) => {
  if inner != auto {
    if outer == auto {
      inner
    } else {
      outer + inner
    }
  } else {
    (:)
  }
}
#let elem-enum-list = e.element.declare(
  "elem_enum-list",
  prefix: "@preview/itemize,v2",
  doc: "Element of enum-list",
  display: it => {
    ex-el.get-list-enum-method(
      it.doc,
      it.elem, // "both", "list", "enum"
      it.indent,
      it.body-indent,
      it.label-indent,
      it.is-full-width,
      it.item-spacing,
      it.enum-spacing,
      it.enum-margin,
      it.hanging-type,
      it.hanging-indent,
      it.line-indent,
      it.label-width,
      it.body-format,
      it.label-format,
      it.item-format,
      it.auto-base-level,
      it.label-align, //
      it.label-baseline, //
      it.auto-resuming,
      it.auto-label-width,
      it.checklist,
      it.enum-config, //
      it.list-config, //
      ..it.args,
    )
  },
  fields: (
    field("doc", types.any, folds: false, required: true),
    field("elem", types.any, default: "both", folds: false),
    field("indent", types.any, default: auto, folds: false),
    field("body-indent", types.any, default: auto, folds: false),
    field("label-indent", types.any, default: auto, folds: false),
    field("is-full-width", bool, default: true, folds: false),
    field("item-spacing", types.any, default: auto, folds: false),
    field("enum-spacing", types.any, default: auto, folds: false),
    field("enum-margin", types.any, default: auto, folds: false),
    field("hanging-type", str, default: "classic", folds: false),
    field("hanging-indent", types.any, default: auto, folds: false),
    field("line-indent", types.any, default: auto, folds: false),
    field("label-width", types.any, default: auto, folds: false),
    field("body-format", types.any, default: none, folds: false),
    field("label-format", types.any, default: none, folds: false),
    field("item-format", types.any, default: none, folds: false),
    field("auto-base-level", bool, default: false, folds: false),
    field("label-align", types.any, default: auto, folds: false),
    field("label-baseline", types.any, default: auto, folds: false),
    field("auto-resuming", types.any, default: none, folds: false),
    field("auto-label-width", types.any, default: none, folds: false),
    field("checklist", bool, default: false, folds: false),
    field(
      "enum-config",
      types.wrap(types.union(dictionary, auto), fold: fold),
      default: auto,
      folds: true,
    ),
    field(
      "list-config",
      types.wrap(types.union(dictionary, auto), fold: fold),
      default: auto,
      folds: true,
    ),
    field(
      "args",
      types.wrap(types.union(dictionary, auto), fold: fold),
      default: auto,
      folds: true,
    ),
  ),
)
#let default-setting = (
  indent: auto,
  body-indent: auto,
  label-indent: auto,
  is-full-width: true,
  item-spacing: auto,
  enum-spacing: auto,
  enum-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  label-width: auto,
  body-format: none,
  label-format: none,
  item-format: none,
  auto-base-level: false,
  label-align: auto, //
  label-baseline: auto, //
  enum-config: (:),
  list-config: (:),
  // auto-resuming: none,
  // auto-label-width: none,
  // checklist: false,
)
#let set_elem-enum-list(
  elem: "both", // "both", "list", "enum"
  indent: none,
  body-indent: none,
  label-indent: none,
  is-full-width: none,
  item-spacing: none,
  enum-spacing: none,
  enum-margin: none,
  hanging-type: "classic", // "classic" "paragraph"
  hanging-indent: none,
  line-indent: none,
  label-width: none,
  body-format: none,
  label-format: none,
  item-format: none,
  auto-base-level: none,
  label-align: none, //
  label-baseline: none, //
  auto-resuming: none,
  auto-label-width: none,
  enum-config: none, //
  list-config: none, //
  checklist: false,
  ..args,
) = doc => {
  let args-none = (
    indent == none
      and body-indent == none
      and label-indent == none
      and is-full-width == none
      and item-spacing == none
      and enum-spacing == none
      and enum-margin == none
      and hanging-indent == none
      and line-indent == none
      and label-width == none
      and body-format == none
      and label-format == none
      and item-format == none
      and auto-base-level == none
      and label-align == none
      and label-baseline == none
      and enum-config == none
      and list-config == none
      and args.named().len() == 0
  )
  let dic = {
    if indent != none {
      (indent: indent)
    }
    if body-indent != none {
      (body-indent: body-indent)
    }
    if label-indent != none {
      (label-indent: label-indent)
    }
    if is-full-width != none {
      (is-full-width: is-full-width)
    }
    if item-spacing != none {
      (item-spacing: item-spacing)
    }
    if enum-spacing != none {
      (enum-spacing: enum-spacing)
    }
    if enum-margin != none {
      (enum-margin: enum-margin)
    }
    if hanging-indent != none {
      (hanging-indent: hanging-indent)
    }
    if line-indent != none {
      (line-indent: line-indent)
    }
    if label-width != none {
      (label-width: label-width)
    }
    if body-format != none {
      (body-format: body-format)
    }
    if label-format != none {
      (label-format: label-format)
    }
    if item-format != none {
      (item-format: item-format)
    }
    if label-align != none {
      (label-align: label-align)
    }
    if label-baseline != none {
      (label-baseline: label-baseline)
    }
    if auto-base-level != none {
      (auto-base-level: auto-base-level)
    }
    if enum-config not in (none, (), (:)) {
      (enum-config: enum-config)
    }
    if list-config not in (none, (), (:)) {
      (list-config: list-config)
    }
  }
  show: e.set_(
    elem-enum-list,
    auto-resuming: auto-resuming,
    auto-label-width: auto-label-width,
    checklist: checklist,
    ..if args-none { default-setting } else { dic },
    args: if args-none { auto } else { args.named() },
  )
  show: elem-enum-list.with(elem: elem, hanging-type: hanging-type)
  doc
}


/// Configures default styling for `enum` and `list`.
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
#let set-default = set_elem-enum-list.with(hanging-type: "classic", elem: "both")

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
#let set-paragraph = set_elem-enum-list.with(hanging-type: "paragraph", elem: "both")

