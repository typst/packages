
#import "export-el.typ" as ex-el

#import "@preview/elembic:1.1.1" as e: field, types

// TODO: fold -- label-baseline (amount, same-line-style)

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

#let fold-label-format = prev-fold => (outer, inner) => {
  if inner not in (auto, none) {
    if outer in (auto, none) {
      inner
    } else {
      let outer-border
      let outer-format
      let inner-border
      let inner-format
      if type(outer) == dictionary {
        let outer = outer
        outer-format = outer.remove("format", default: none)
        outer-border = outer
      } else {
        outer-format = outer
      }
      if type(inner) == dictionary {
        let inner = inner
        inner-format = inner.remove("format", default: none)
        inner-border = inner
      } else {
        inner-format = inner
      }
      let format = if inner-format != none { inner-format } else { outer-format }
      let border = outer-border + inner-border
      return (format: format) + border
    }
  } else {
    (:)
  }
}

#let fold-body-format = prev-fold => (outer-f, inner-f) => {
  if inner-f not in (auto, none) {
    if outer-f in (auto, none) {
      inner-f
    } else {
      let border-prev = (outer: (:), inner: (:), whole: (:))
      let format-prev = (outer: none, inner: none, whole: none)
      let style-prev = (:)

      let border-next = (outer: (:), inner: (:), whole: (:))
      let format-next = (outer: none, inner: none, whole: none)
      let style-next = (:)

      if (type(outer-f) == dictionary) {
        let outer = outer-f.at("outer", default: none)
        let inner = outer-f.at("inner", default: none)
        let whole = outer-f.at("whole", default: none)

        style-prev = outer-f.at("style", default: none)

        if outer == none and inner == none and whole == none {
          outer = outer-f
        }

        if type(outer) in (function, array) {
          format-prev.outer = outer
        } else {
          format-prev.outer = if type(outer) == dictionary { outer.remove("format", default: none) }
        }
        if type(inner) in (function, array) {
          format-prev.inner = inner
        } else {
          format-prev.inner = if type(inner) == dictionary { inner.remove("format", default: none) }
        }
        if type(whole) in (function, array) {
          format-prev.whole = whole
        } else {
          format-prev.whole = if type(whole) == dictionary { whole.remove("format", default: none) }
        }
        border-prev.outer = outer
        border-prev.inner = inner
        border-prev.whole = whole
      } else {
        format-prev.outer = outer-f
      }

      if (type(inner-f) == dictionary) {
        let outer = inner-f.at("outer", default: none)
        let inner = inner-f.at("inner", default: none)
        let whole = inner-f.at("whole", default: none)

        let style-next = inner-f.at("style", default: none)

        if outer == none and inner == none and whole == none {
          outer = inner-f
        }

        if type(outer) in (function, array) {
          format-next.outer = outer
        } else {
          format-next.outer = if type(outer) == dictionary { outer.remove("format", default: none) }
        }
        if type(inner) in (function, array) {
          format-next.inner = inner
        } else {
          format-next.inner = if type(inner) == dictionary { inner.remove("format", default: none) }
        }
        if type(whole) in (function, array) {
          format-next.whole = whole
        } else {
          format-next.whole = if type(whole) == dictionary { whole.remove("format", default: none) }
        }
        border-next.outer = outer
        border-next.inner = inner
        border-next.whole = whole
      } else {
        format-next.outer = inner-f
      }
      let style = style-prev + style-next
      let outer = (
        (
          format: if format-next.outer != none { format-next.outer } else { format-prev.outer },
        )
          + border-prev.outer
          + border-next.outer
      )
      let inner = (
        (
          format: if format-next.inner != none { format-next.inner } else { format-prev.inner },
        )
          + border-prev.inner
          + border-next.inner
      )
      let whole = (
        (
          format: if format-next.whole != none { format-next.whole } else { format-prev.whole },
        )
          + border-prev.whole
          + border-next.whole
      )
      return (
        outer: outer,
        inner: inner,
        whole: whole,
        style: style,
      )
    }
  } else {
    (:)
  }
}

#let elem-enum-list = e.element.declare(
  "elem_enum-list",
  prefix: "@preview/itemize,v3",
  doc: "Element of enum-list",
  display: it => {
    ex-el.get-list-enum-method(
      it.doc,
      it.elem, // "both", "list", "enum"
      it.indent,
      it.body-indent,
      it.label-indent,
      // it.is-full-width,
      it.item-spacing,
      // it.enum-spacing,
      // it.enum-margin,
      it.hanging-type,
      it.hanging-indent,
      it.line-indent,
      it.label-width,
      it.body-format,
      it.label-format,
      // it.item-format,
      it.auto-base-level,
      it.label-align, //
      it.label-baseline, //
      it.auto-resuming,
      it.auto-label-width,
      it.checklist,
      it.enum-config, //
      it.list-config, //
      it.ref-numbering, //0.3.0
      it.supplement, //0.3.0
      it.tight-item-mode, //0.3.0
      it.tight-mode, //0.3.0
      it.step, //0.3.0
      it.label-inset, //0.3.0
      it.first-line-inset, //0.3.0
      it.description-config, //0.3.0
      it.body-margin, //0.3.0
      it.whole-spacing, //0.3.0
      ..it.args,
    )
  },
  fields: (
    field("doc", types.any, folds: false, required: true),
    field("elem", types.any, default: ex-el.ElemType.all, folds: false),
    field("indent", types.any, default: auto, folds: false),
    field("body-indent", types.any, default: auto, folds: false),
    field("label-indent", types.any, default: auto, folds: false),
    field("item-spacing", types.any, default: auto, folds: false),
    field("whole-spacing", types.any, default: auto, folds: false),
    field("body-margin", types.any, default: auto, folds: false),
    field("hanging-type", str, default: ex-el.HangingType.classic, folds: false),
    field("hanging-indent", types.any, default: auto, folds: false),
    field("line-indent", types.any, default: auto, folds: false),
    field("label-width", types.any, default: auto, folds: false),
    // field("body-format", types.any, default: none, folds: false),
    field(
      "body-format",
      types.wrap(types.union(dictionary, auto, none, function, array), fold: fold-body-format),
      default: none,
      folds: true,
    ),
    field(
      "label-format",
      types.wrap(types.union(dictionary, auto, none, function, array), fold: fold-label-format),
      default: none,
      folds: true,
    ),
    field("auto-base-level", bool, default: false, folds: false),
    field("label-align", types.any, default: auto, folds: false),
    field("label-baseline", types.any, default: auto, folds: false),
    field("auto-resuming", types.any, default: none, folds: false),
    field("auto-label-width", types.any, default: none, folds: false),
    field("checklist", bool, default: false, folds: false),
    field("ref-numbering", types.any, default: none, folds: false),
    field("supplement", types.any, default: auto, folds: false),
    field("tight-mode", types.any, default: auto, folds: false),
    field("tight-item-mode", types.any, default: auto, folds: false),
    field("step", types.any, default: auto, folds: false),
    field("label-inset", types.any, default: auto, folds: false),
    field("first-line-inset", types.any, default: auto, folds: false),
    field(
      "description-config",
      types.wrap(types.union(dictionary, auto, none), fold: fold),
      default: auto,
      folds: true,
    ),
    field(
      "enum-config",
      types.wrap(types.union(dictionary, auto, none), fold: fold),
      default: auto,
      folds: true,
    ),
    field(
      "list-config",
      types.wrap(types.union(dictionary, auto, none), fold: fold),
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
  // is-full-width: true,
  item-spacing: auto,
  whole-spacing: auto,
  body-margin: auto,
  hanging-indent: auto,
  line-indent: auto,
  label-width: auto,
  body-format: none,
  label-format: none,
  // item-format: none,
  auto-base-level: true,
  label-align: auto, //
  label-baseline: auto, //
  enum-config: (:),
  list-config: (:),
  ref-numbering: none, /** new ver0.3.0 */
  supplement: auto, /** new ver0.3.0 */
  tight-mode: auto, /** new ver0.3.0 */
  tight-item-mode: auto, /** new ver0.3.0 */
  step: auto, /** new ver0.3.0 */
  label-inset: auto, /** new ver0.3.0 */
  first-line-inset: auto, /** new ver0.3.0 */
  description-config: none,
)
#let set_elem-enum-list(
  elem: ex-el.ElemType.all, // "both", "list", "enum"
  indent: none,
  body-indent: none,
  label-indent: none,
  is-full-width: none,
  item-spacing: none,
  whole-spacing: none,
  body-margin: none,
  hanging-type: none, // "classic" "paragraph"
  hanging-indent: none,
  line-indent: none,
  label-width: none,
  body-format: none,
  label-format: none,
  auto-base-level: none,
  label-align: none, //
  label-baseline: none, //
  auto-resuming: none,
  auto-label-width: none,
  enum-config: none, //
  list-config: none, //
  checklist: false,
  ref-numbering: none, /** new ver0.3.0 */
  supplement: none, /** new ver0.3.0 */
  tight-mode: none, /** new ver0.3.0 */
  tight-item-mode: none, /** new ver0.3.0 */
  step: none, /** new ver0.3.0 */
  label-inset: none, /** new ver0.3.0 */
  first-line-inset: none, /** new ver0.3.0 */
  description-config: none,
  ..args,
) = doc => {
  let args-none = (
    indent == none
      and body-indent == none
      and label-indent == none
      and item-spacing == none
      and whole-spacing == none
      and body-margin == none
      and hanging-indent == none
      and line-indent == none
      and label-width == none
      and body-format == none
      and label-format == none
      and auto-base-level == none
      and label-align == none
      and label-baseline == none
      and enum-config == none
      and list-config == none
      and tight-mode == none
      and tight-item-mode == none
      and step == none
      and label-inset == none
      and first-line-inset == none
      and description-config == none
      and checklist == false
      and hanging-type == none
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
    if item-spacing != none {
      (item-spacing: item-spacing)
    }
    if whole-spacing != none {
      (whole-spacing: whole-spacing)
    }
    if body-margin != none {
      (body-margin: body-margin)
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
    if label-align != none {
      (label-align: label-align)
    }
    if label-baseline != none {
      (label-baseline: label-baseline)
    }
    if auto-base-level != none {
      (auto-base-level: auto-base-level)
    }
    if tight-mode != none {
      (tight-mode: tight-mode)
    }
    if tight-item-mode != none {
      (tight-item-mode: tight-item-mode)
    }
    if step != none {
      (step: step)
    }
    if label-inset != none {
      (label-inset: label-inset)
    }
    if first-line-inset != none {
      (first-line-inset: first-line-inset)
    }
    if description-config != none {
      (description-config: description-config)
    }
    if enum-config not in (none, (), (:)) {
      (enum-config: enum-config)
    }
    if list-config not in (none, (), (:)) {
      (list-config: list-config)
    }
    if checklist != false {
      (checklist: checklist)
    }
    if hanging-type != none {
      (hanging-type: hanging-type)
    }
  }
  show: e.set_(
    elem-enum-list,
    auto-resuming: auto-resuming,
    auto-label-width: auto-label-width,
    ref-numbering: ref-numbering,
    supplement: supplement,
    ..if args-none { default-setting } else { dic },
    args: if args-none { auto } else { args.named() },
  )
  show: elem-enum-list.with(elem: elem)
  doc
}


/// Configures default styling for `enum` and `list`. Support `set-rule`.
///
/// Usage
/// ```typst
/// #let item = [
///   + #lorem(5)
///     + #lorem(5)
///     + + #lorem(5)
///   + #lorem(5)
/// ]
/// #show: el.set-default() // need `()`!!!
/// #item
///
/// // change the label color
/// #show: el.set-default(fill: (red, blue, green, auto))
/// #item
///
/// // change the label size
/// #show: el.set-default(size: (20pt, 16pt, 14pt, auto))
/// #item
///
/// // change the body-indent and indent
/// #show: el.set-default(body-indent: (auto, 0.5em), indent: (auto, 0em, 1em, auto))
/// #item
///
/// // use the default style
/// #show: el.set-default()
/// #item
/// ```
///
/// See `default-enum-list`.
#let set-default = set_elem-enum-list.with(elem: ex-el.ElemType.all)

/// Configures paragraph styling for `enum` and `list`. Support `set-rule`.
///
/// See `default-enum-list`.
#let set-paragraph = set_elem-enum-list.with(hanging-type: "paragraph", elem: ex-el.ElemType.all)

