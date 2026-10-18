#import "../loom-wrapper.typ": data-motif, loom, loom-key
#import "../logic/calc-item.typ": (
  calculate-item-data, require-positive-base-quantity,
)
#import "../utils/types.typ"
#import "../utils/coercion.typ"
#import "../data/tax.typ" as m-tax
#import "../public/unit.typ" as m-unit
#import "../logic/unit.typ" as unit-logic

/// Normalizes a modifier input (content, dictionary, or signal) into a structured modifier object.
///
/// -> dictionary | none
#let normalize-modifier(
  /// The loom context.
  /// -> dictionary
  ctx,
  /// The modifier to normalize.
  /// -> content | dictionary
  modifier,
) = {
  let modifier-type = type(modifier)
  if modifier-type == content {
    let (_, frames) = loom.core.intertwine(
      key: loom-key,
      loom.path.append(ctx, "line-items"),
      modifier,
    )

    let signals = loom.query.collect-signals(frames, kind: "modifier")

    signals.map(s => (
      name: s.name,
      label: s.at("label", default: auto),
      amount: if s.type == "relative" { float(s.amount) * 100% } else {
        s.amount
      },
      description: s.description,
      tax: s.at("tax", default: none),
    ))
  } else if modifier-type == dictionary {
    modifier
  } else {
    none
  }
}

/// Evaluates a collection of modifiers, flattening arrays and resolving content signals.
///
/// -> array
#let evaluate-modifier(
  /// The loom context.
  /// -> dictionary
  ctx,
  /// The modifier(s) to evaluate.
  /// -> auto | array | content | dictionary
  modifier,
) = {
  let modifier-type = type(modifier)

  if modifier == auto { return auto }

  if modifier-type == array {
    modifier.map(normalize-modifier.with(ctx)).flatten()
  } else if modifier-type == content {
    (normalize-modifier(ctx, modifier),).flatten()
  } else if modifier-type == dictionary {
    (modifier,)
  } else {
    ()
  }.filter(m => m != none)
}

/// Represents a single line item, product, or service on the invoice.
/// It integrates with the loom data model to automatically calculate base prices,
/// totals, and apply relevant taxes and modifiers.
///
/// -> content
#let item(
  /// The name or title of the item.
  /// -> str | content
  name,
  /// Additional details or description about the item.
  /// -> str | content | auto | none
  description: auto,

  /// The amount being billed. Automatically defaults to `1`.
  /// -> int | float | decimal | str | auto
  quantity: auto,
  /// The reference quantity for the price, useful for calculating price-per-unit ratios. Automatically defaults to `1`.
  /// -> int | float | decimal | str | auto
  base-quantity: auto,
  /// The unit of measurement. For ZUGFeRD compliance, pass a dictionary: `(display: "Std.", code: "HUR")`.
  /// -> str | content | dictionary | auto | none
  unit: auto,

  /// The date or a date range `(datetime, datetime)` the item or service was provided.
  /// -> datetime | array | auto | none
  date: auto, // none | datetime | (datetime, datetime)

  /// The price per unit. *Note: You must specify either `price` or `total`, but not both*.
  /// -> int | float | decimal | str | auto
  price: auto,
  /// The total price for the item. *Note: You must specify either `price` or `total`, but not both*.
  /// -> int | float | decimal | str | auto
  total: auto,

  /// Indicates if the provided price/total already includes tax.
  /// -> bool | auto
  input-gross: auto,

  /// The specific tax rate or tax dictionary for this item. Defaults to a zero tax rate.
  /// -> ratio | dictionary | auto
  tax: auto,

  /// An identifier for the item, such as an EAN/GTIN/ISBN string, or a dictionary with `seller`, `buyer`, and `standard` keys.
  /// -> str | dictionary | auto | none
  item-id: auto,
  /// An optional reference string for the item.
  /// -> str | auto | none
  reference: auto, // str optional

  /// A note about the item, printed below its description and written into
  /// the e-invoice (BT-127). Not for an item inside a `bundle`, which is no
  /// line of its own.
  /// -> str | content | auto | none
  note: auto,
  /// The country of origin of the item: a country of the `country` module
  /// (e.g. `country.de`) or an ISO 3166-1 alpha-2 code such as `"DE"`.
  /// Printed with its code below the description and written into the
  /// e-invoice (BT-159). Not for an item inside a `bundle`, which is no line
  /// of its own.
  /// -> function | dictionary | str | auto | none
  origin: auto,

  /// An array of specific modifiers (discounts or surcharges) applied specifically to this item.
  /// -> array | auto | none
  modifier: auto,
) = {
  types.require(name, "item::name", types.text-like)
  types.require(description, "item::description", none, auto, types.text-like)

  types.require(quantity, "item::quantity", auto, types.decimal-like)
  types.require(base-quantity, "item::base-quantity", auto, types.decimal-like)
  require-positive-base-quantity(base-quantity, "item")
  types.require(
    unit,
    "item::unit",
    none,
    auto,
    types.text-like,
    types.unit-input-type,
    dictionary,
    function,
  )

  types.require(date, "item::date", none, auto, types.date-like)
  types.require-day(date, "item::date")

  types.require(price, "item::price", auto, types.decimal-like)
  types.require(total, "item::total", auto, types.decimal-like)
  assert(
    price == auto or total == auto,
    message: "You can only specify the price or the total not both. The other value will be calculated automatically.",
  )

  types.require(input-gross, "item::input-gross", auto, bool)
  types.require(tax, "item::tax", auto, ratio, types.tax-like)

  types.require(item-id, "item::item-id", none, auto, str, dictionary)
  types.require(reference, "item::reference", none, auto, str)
  // Checked only if given, as most items have neither.
  if note != auto { types.require(note, "item::note", none, types.text-like) }
  if origin != auto {
    types.require(
      origin,
      "item::origin",
      none,
      types.text-like,
      dictionary,
      function,
    )
  }

  types.require(
    modifier,
    "item::modifier",
    none,
    auto,
    content,
    loom.matcher.many(loom.matcher.choice(
      types.modifier-like,
      content,
    )),
  )

  data-motif(
    "item",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("description", description)

      derive("quantity", coercion.to-decimal(quantity), default: decimal("1"))
      derive(
        "base-quantity",
        coercion.to-decimal(base-quantity),
        default: decimal("1"),
      )
      // Without an own unit, use the unresolved unit a `group` or `apply`
      // cascades, so it is resolved with this item's quantity.
      let unit-input = if unit != auto { unit } else {
        ctx.at("unit", default: auto)
      }
      put(
        "unit",
        unit-logic.resolve(
          unit-input,
          ctx.locale,
          quantity: if quantity != auto { coercion.to-decimal(quantity) } else {
            ctx.at("quantity", default: decimal("1"))
          },
          default: m-unit.pc,
        ),
      )
      // Quantity-independent form, used to detect and name a shared unit.
      put(
        "unit-singular",
        unit-logic.resolve(
          unit-input,
          ctx.locale,
          quantity: decimal("1"),
          default: m-unit.pc,
        ),
      )

      derive("date", coercion.to-date(date))

      derive("item-price", coercion.to-decimal(price), default: auto)
      derive("item-total", coercion.to-decimal(total), default: auto)

      ensure("tax-mode", "exclusive")
      derive(
        "input-gross",
        input-gross,
        default: ctx.at("tax-mode", default: "exclusive") == "inclusive",
      )
      // Without a tax from anywhere (`tax: none` on the invoice), the item is
      // zero rated, marked as implicit (see `tax.implicit-zero`).
      update("tax", t => m-tax.resolve(ctx, t, "item"))
      derive(
        "tax",
        m-tax.resolve(ctx, tax, "item"),
        default: m-tax.implicit-zero(),
      )

      if ctx.at("tax-exempt-small-biz", default: false) {
        put("tax", ctx.locale.tax.small-enterprise-special-scheme)
      }

      derive("item-id", item-id)
      derive("reference", reference)
      // Set only if given, so that items without them carry no extra keys
      // (`calculate-item-data` reads them with a default).
      if note != auto { put("note", note) }
      if origin != auto { put("origin", origin) }
      // The items of a bundle are no lines of their own: the bundle is
      // printed and written as one line, which names its items, so a note or
      // a country of origin of one of them would be lost.
      if (
        (note not in (auto, none) or origin not in (auto, none))
          and ctx.at("bundle-quantity", default: none) != none
      ) {
        panic(
          "item::note and item::origin are not supported on an item inside a `bundle`: the bundle is one line of the invoice, which prints and states neither the note nor the country of origin of its items. Mention them in the `description` of the bundle, or list the item outside the bundle.",
        )
      }

      derive("modifier", evaluate-modifier(ctx, modifier), default: ())
      update("modifier", evaluate-modifier.with(ctx))

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
    measure: ctx => {
      loom.guards.assert-direct-parent(ctx, "line-items", "bundle", "group")
      return calculate-item-data(ctx, name)
    },
  )
}
