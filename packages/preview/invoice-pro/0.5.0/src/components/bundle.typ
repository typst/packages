#import "../loom-wrapper.typ": compute-motif, loom, weave
#import "../logic/modifier-applicator.typ": modifier-applicator
#import "../logic/calc-bundle.typ": calculate-bundle
#import "../logic/calc-item.typ": require-positive-base-quantity
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../data/unit.typ"
#import "../data/tax.typ" as m-tax
#import "../logic/unit.typ" as m-unit

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
  /// The unit of measurement for the bundle. For ZUGFeRD compliance, pass a dictionary: `(display: "Std.", code: "HUR")`.
  /// -> str | content | dictionary | auto | none
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
  types.require(
    unit,
    "bundle::unit",
    none,
    auto,
    types.text-like,
    types.unit-input-type,
    dictionary,
    function,
  )

  types.require(date, "bundle::date", none, auto, types.date-like)
  types.require-day(date, "bundle::date")

  types.require(input-gross, "bundle::input-gross", auto, bool)
  types.require(tax, "bundle::tax", auto, types.tax-like)

  types.require(item-id, "bundle::item-id", none, auto, str, dictionary)
  types.require(reference, "bundle::reference", none, auto, str)

  types.require(body, "bundle::body", none, content)
  require-positive-base-quantity(base-quantity, "bundle")

  let bundle-quantity = if quantity == auto { decimal("1") } else {
    coercion.to-decimal(quantity)
  }
  let bundle-base-quantity = if base-quantity == auto { decimal("1") } else {
    coercion.to-decimal(base-quantity)
  }

  compute-motif(
    name: "bundle",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("description", description)
      put("bundle-description", ctx.at("description", default: description))

      // A nested bundle does not inherit the quantities of the enclosing one:
      // its quantity is the number of it in one unit of the enclosing bundle.
      remove("quantity")
      put("bundle-quantity", bundle-quantity)
      remove("base-quantity")
      put("bundle-base-quantity", bundle-base-quantity)
      // Without an own unit, use the unresolved unit a `group` or `apply`
      // cascades. The resolved unit is kept under `bundle-unit`, so "unit"
      // still carries that cascaded input to the bundled items.
      let unit-input = if unit != auto { unit } else {
        ctx.at("unit", default: auto)
      }
      put(
        "bundle-unit",
        m-unit.resolve(
          unit-input,
          ctx.locale,
          quantity: bundle-quantity,
          default: m-unit.pcs,
        ),
      )
      // Quantity-independent form, used to detect and name a shared unit.
      put(
        "bundle-unit-singular",
        m-unit.resolve(
          unit-input,
          ctx.locale,
          quantity: decimal("1"),
          default: m-unit.pcs,
        ),
      )

      derive("date", date)
      put("bundle-date", if date == auto {
        ctx.at("date", default: auto)
      } else {
        date
      })

      derive(
        "input-gross",
        input-gross,
        default: ctx.at("tax-mode", default: "exclusive") == "inclusive",
      )
      ensure("tax-mode", "exclusive")
      // Without a tax from anywhere (`tax: none` on the invoice), the items
      // are zero rated, marked as implicit (see `tax.implicit-zero`).
      update("tax", t => m-tax.resolve(ctx, t, "bundle"))
      derive(
        "tax",
        m-tax.resolve(ctx, tax, "bundle"),
        default: m-tax.implicit-zero(),
      )

      derive("item-id", item-id)
      derive("reference", reference)

      remove("modifier")

      nest("locale", {
        nest("normalize", {
          ensure("money", (..) => panic(
            "locale::normalize::money is not provided",
          ))
          ensure("money-fine", (..) => panic(
            "locale::normalize::money-fine is not provided",
          ))
        })
      })
    }),
    measure: (ctx, children) => {
      loom.guards.assert-direct-parent(ctx, "line-items", "bundle", "group")
      return calculate-bundle(ctx, children, name)
    },
    (
      modifier-applicator,
    ).fold(body, (c, f) => f(c)),
  )
}
