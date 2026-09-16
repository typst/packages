#import "../loom-wrapper.typ": compute-motif, loom
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../data/tax.typ" as m-tax
#import "../data/unit.typ"
#import "../logic/unit.typ" as m-unit

/// A container used to visually and structurally group multiple invoice items, bundles,
/// and nested groups together. Unlike `bundle`, a `group` does not aggregate its children
/// into a single line item; instead, all contained items remain full line items and are
/// displayed with hierarchical position IDs (e.g., `1.1`, `1.1.4`).
///
/// -> content
#let group(
  /// The name or title of the group.
  /// -> str | content
  name,
  /// Additional details or description about the group.
  /// -> str | content | auto | none
  description: none,

  /// Whether to display a subtotal row for this group. Defaults to `auto` (which enables it).
  /// -> bool | auto
  show-subtotal: auto,

  /// Optional tax rate or tax dictionary applied by default to items within this group.
  /// -> ratio | dictionary | auto
  tax: auto,
  /// Passed through context to indicate if input prices in this group are treated as gross.
  /// -> bool | auto
  input-gross: auto,
  /// Optional default date or date range for items in this group.
  /// -> datetime | array | auto | none
  date: auto,
  /// Optional default unit of measurement for items in this group.
  /// -> str | content | dictionary | auto | none
  unit: auto,

  /// The content block containing `#item`s, `#bundle`s, or nested `#group`s.
  /// -> content
  body,
) = {
  types.require(name, "group::name", types.text-like)
  types.require(description, "group::description", none, auto, types.text-like)
  types.require(show-subtotal, "group::show-subtotal", auto, bool)

  types.require(tax, "group::tax", auto, types.tax-like)
  types.require(input-gross, "group::input-gross", auto, bool)
  types.require(date, "group::date", none, auto, types.date-like)
  types.require(
    unit,
    "group::unit",
    none,
    auto,
    types.text-like,
    types.unit-input-type,
    dictionary,
    function,
  )

  types.require(body, "group::body", none, content)

  compute-motif(
    name: "group",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      if description != auto and description != none {
        put("group-description", description)
      }

      if input-gross != auto {
        put("input-gross", input-gross)
      }

      if date != auto and date != none {
        derive("date", coercion.to-date(date))
      }

      if tax != auto {
        update("tax", t => if type(t) != ratio { t } else {
          let infer-tax = ctx
            .at("locale", default: (:))
            .at("normalize", default: (:))
            .at("infer-tax", default: (..) => panic(
              "group::tax can not be of type `ratio`.",
            ))
          infer-tax(t)
        })
        derive(
          "tax",
          {
            if type(tax) == ratio {
              let infer-tax = ctx
                .at("locale", default: (:))
                .at("normalize", default: (:))
                .at("infer-tax", default: (..) => panic(
                  "group::tax can not be of type `ratio`.",
                ))
              infer-tax(tax)
            } else {
              m-tax.to-tax(tax)
            }
          },
          default: m-tax.zero(),
        )
      }

      if unit != auto and unit != none {
        derive(
          "unit",
          m-unit.resolve(
            unit,
            ctx.locale,
            quantity: decimal("1"),
            default: m-unit.pc,
          ),
        )
      }
    }),
    measure: (ctx, children) => {
      loom.guards.assert-direct-parent(ctx, "line-items", "group")
      return (
        kind: "group",
        name: name,
        description: if description == auto { none } else { description },
        show-subtotal: if show-subtotal == auto { true } else { show-subtotal },
        children: children,
      )
    },
    body,
  )
}
