#import "item-lib.typ" as item

#import "@preview/elembic:1.1.1" as e: field, types

#let default-enum-list = e.element.declare(
  "default-enum-list",
  prefix: "@preview/fix-enum-list,v1",
  doc: "Configures default styling for enumerations and lists.",
  display: it => {
    item.default-enum-list(
      it.doc,
      indent: it.indent,
      body-indent: it.body-indent,
      label-indent: it.label-indent,
      is-full-width: it.is-full-width,
      item-spacing: it.item-spacing,
      enum-spacing: it.enum-spacing,
      enum-margin: it.enum-margin,
      hanging-indent: it.hanging-indent,
      line-indent: it.line-indent,
      ..it.args,
    )
  },
  fields: (
    field("doc", types.any, folds: false, required: true),
    field(
      "indent",
      types.any,
      default: auto,
      folds: false,
    ),
    field("body-indent", types.any, default: auto, folds: false),
    field("label-indent", types.any, default: auto, folds: false),
    field("is-full-width", bool, default: true, folds: false),
    field("item-spacing", types.any, default: auto, folds: false),
    field("enum-spacing", types.any, default: auto, folds: false),
    field("enum-margin", types.any, default: auto, folds: false),
    field("hanging-indent", types.any, default: auto, folds: false),
    field("line-indent", types.any, default: auto, folds: false),
    field(
      "args",
      types.wrap(types.union(dictionary, auto), fold: prev-fold => (outer, inner) => {
        if inner != auto {
          if outer == auto {
            inner
          } else {
            outer + inner
          }
        } else {
          (:)
        }
      }),
      default: auto,
      folds: true,
    ),
  ),
)

#let paragraph-enum-list = e.element.declare(
  "default-enum-list",
  prefix: "@preview/fix-enum-list,v1",
  doc: "Configures default styling for enumerations and lists.",
  display: it => {
    item.paragraph-enum-list(
      it.doc,
      indent: it.indent,
      body-indent: it.body-indent,
      label-indent: it.label-indent,
      is-full-width: it.is-full-width,
      item-spacing: it.item-spacing,
      enum-spacing: it.enum-spacing,
      enum-margin: it.enum-margin,
      hanging-indent: it.hanging-indent,
      line-indent: it.line-indent,
      ..it.args,
    )
  },
  fields: (
    field("doc", types.any, folds: false, required: true),
    field("indent", types.any, default: auto, folds: false),
    field("body-indent", types.any, default: auto, folds: false),
    field("label-indent", types.any, default: auto, folds: false),
    field("is-full-width", bool, default: true, folds: false),
    field("item-spacing", types.any, default: auto, folds: false),
    field("enum-spacing", types.any, default: auto, folds: false),
    field("enum-margin", types.any, default: auto, folds: false),
    field("hanging-indent", types.any, default: auto, folds: false),
    field("line-indent", types.any, default: auto, folds: false),
    field(
      "args",
      types.wrap(types.union(dictionary, auto), fold: prev-fold => (outer, inner) => {
        if inner != auto {
          if outer == auto {
            inner
          } else {
            outer + inner
          }
        } else {
          (:)
        }
      }),
      default: auto,
      folds: true,
    ),
  ),
)

#let set_(
  indent: none,
  body-indent: none,
  label-indent: none,
  is-full-width: none,
  item-spacing: none,
  enum-spacing: none,
  enum-margin: none,
  hanging-indent: none,
  line-indent: none,
  hanging-type, //classic paragraph
  ..args,
) = it => {
  let default-setting = (
    indent: auto,
    body-indent: auto,
    label-indent: auto,
    is-full-width: true,
    item-spacing: auto,
    enum-spacing: auto,
    enum-margin: auto,
    hanging-indent: auto,
    line-indent: auto,
  )
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
  }
  if hanging-type == "classic" {
    show: e.set_(
      default-enum-list,
      ..if args-none { default-setting } else { dic },
      args: if args-none { auto } else { args.named() },
    )
    show: default-enum-list
    it
  } else if hanging-type == "paragraph" {
    show: e.set_(
      paragraph-enum-list,
      ..if args-none { default-setting } else { dic },
      args: if args-none { auto } else { args.named() },
    )
    show: paragraph-enum-list
    it
  }
}

/// Configures default styling for enumerations and lists.
#let set_default = set_.with("classic")

/// Configures paragraph styling for enumerations and lists.
#let set_paragraph = set_.with("paragraph")
