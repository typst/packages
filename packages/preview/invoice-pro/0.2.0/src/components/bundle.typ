#import "../loom-wrapper.typ": compute-motif, loom, weave
#import "../logic/modifier-applicator.typ": modifier-applicator
#import "../logic/calc-bundle.typ": calculate-bundle
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../data/unit.typ" as m-unit
#import "../data/tax.typ" as m-tax

/// A container used to group multiple items together under a single overarching item.
/// It aggregates the totals and dates of its bundled children and acts as a virtual item
/// within the invoice. If the bundled items have mixed tax brackets, the bundle will
/// automatically distribute modifiers and emit separate virtual items for each tax bracket.
///
/// -> content
#let bundle(
  /// The name or title of the bundle.
  /// -> str | content
  name,
  /// Additional details about the bundle. If set to `auto`, it will automatically generate a description by joining the names of its bundled items.
  /// -> str | content | auto | none
  description: auto,

  /// The quantity of the entire bundle. Automatically defaults to `1`.
  /// -> int | float | decimal | str | auto
  quantity: auto,
  /// The reference quantity for the bundle's price calculation. Automatically defaults to `1`.
  /// -> int | float | decimal | str | auto
  base-quantity: auto,
  /// The unit of measurement for the bundle.
  /// -> str | content | auto | none
  unit: auto,

  /// The date or date range for the bundle. If `auto`, it calculates a single date or date range based on the dates of the bundled items.
  /// -> datetime | array | auto | none
  date: auto,

  /// Passed through the context to indicate if the bundle's internal calculations should be treated as gross (inclusive of tax).
  /// -> bool | auto
  input-gross: auto,
  /// Passed through the context to set a default tax rate for the bundle's items. Defaults to a zero tax rate.
  /// -> ratio | dictionary | auto
  tax: auto,

  /// An identifier for the bundle, such as an EAN/GTIN/ISBN string, or a dictionary with `seller`, `buyer`, and `standard` keys.
  /// -> str | dictionary | auto | none
  item-id: auto,
  /// An optional reference string for the bundle.
  /// -> str | auto | none
  reference: auto,

  /// The content block containing the individual `item`s or nested `bundle`s that make up this bundle.
  /// -> content
  body,
) = {
  types.require(name, "bundle::name", types.text-like)
  types.require(description, "bundle::description", none, auto, types.text-like)

  types.require(quantity, "bundle::quantity", auto, types.decimal-like)
  types.require(
    base-quantity,
    "bundle::base-quantity",
    auto,
    types.decimal-like,
  )
  types.require(unit, "bundle::unit", none, auto, types.text-like)

  types.require(date, "bundle::date", none, auto, types.date-like)

  types.require(input-gross, "bundle::input-gross", auto, bool)
  types.require(tax, "bundle::tax", auto, types.tax-like)

  types.require(item-id, "bundle::item-id", none, auto, str, dictionary)
  types.require(reference, "bundle::reference", none, auto, str)

  types.require(body, "bundle::body", none, content)

  compute-motif(
    name: "bundle",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("description", description)
      put("bundle-description", ctx.at("description", default: description))

      remove("quantity")
      derive(
        "bundle-quantity",
        coercion.to-decimal(quantity),
        default: decimal("1"),
      )
      remove("base-quantity")
      derive(
        "bundle-base-quantity",
        coercion.to-decimal(base-quantity),
        default: decimal("1"),
      )
      derive("unit", unit, default: [pc.])

      derive("date", date)
      put("bundle-date", ctx.at("date", default: date))

      derive("input-gross", input-gross, default: false)
      ensure("tax-mode", "exclusive")
      update("tax", t => if type(t) != ratio { t } else {
        let infer-tax = ctx
          .at("locale", default: (:))
          .at("normalize", default: (:))
          .at("infer-tax", default: (..) => panic(
            "item::tax can not be of type `ratio`.",
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
                "item::tax can not be of type `ratio`.",
              ))
            infer-tax(tax)
          } else {
            m-tax.to-tax(tax)
          }
        },
        default: m-tax.zero(),
      )

      derive("item-id", item-id)
      derive("reference", reference)

      remove("modifier")

      nest("normalize", {
        ensure("money", v => calc.round(coercion.to-decimal(v), digits: 2))
        ensure("money-fine", v => calc.round(coercion.to-decimal(v), digits: 4))
      })
    }),
    measure: (ctx, children) => {
      loom.guards.assert-direct-parent(ctx, "line-items", "bundle")
      return calculate-bundle(ctx, children, name)
    },
    (
      modifier-applicator,
    ).fold(body, (c, f) => f(c)),
  )
}
