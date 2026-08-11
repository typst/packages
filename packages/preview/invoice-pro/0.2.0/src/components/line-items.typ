#import "../loom-wrapper.typ": loom, managed-motif
#import "../logic/modifier-applicator.typ": modifier-applicator
#import "../logic/tax-applicator.typ": tax-applicator
#import "../utils/coercion.typ"
#import "../utils/types.typ"
#import "../data/tax.typ" as m-tax

/// The root container for all invoice items, bundles, and modifiers.
/// It establishes overarching tax settings, manages the global application of modifiers,
/// and handles the formatting of the generated invoice data.
///
/// -> content
#let line-items(
  /// Defines whether the input prices within this container are treated as gross (inclusive of tax) by default. Defaults to `false`.
  /// -> bool | auto
  input-gross: auto,

  /// The default tax rate or tax dictionary applied to the items within this container. Defaults to a zero tax rate.
  /// -> ratio | dictionary | auto
  tax: auto,
  /// Determines how taxes are calculated globally. Defaults to `"exclusive"`.
  /// -> "exclusive" | "inclusive" | auto
  tax-mode: auto,

  /// Override the automatic calculations if columns should be shown
  /// ->  auto | dictionary
  show-column: auto,
  /// Wether to show the total block below the line items.
  /// -> auto | bool
  show-total: auto,
  /// Whether to show the information notices about information that all items have.
  /// -> auto | bool
  show-information: auto,

  /// The content block containing the `item`s, `bundle`s, and `modifier`s.
  /// -> content
  body,
) = {
  types.require(input-gross, "line-items::input-gross", auto, bool)

  types.require(tax, "line-items::tax", auto, types.tax-like)
  types.require(
    tax-mode,
    "line-items::tax-mode",
    auto,
    "exclusive",
    "inclusive",
  )
  types.require(
    show-column,
    "line-items::show-column",
    auto,
    (),
    loom.matcher.dict(loom.matcher.choice(auto, bool)),
  )
  types.require(show-total, "line-items::show-total", auto, bool)

  let show-column-default = (
    pos: auto,
    description: auto,
    modifier: auto,
    date: auto,
    quantity: auto,
    unit: auto,
    unit-price: auto,
    total-price: auto,
    tax-rate: auto,
  )
  let show-column = if type(show-column) == dictionary {
    show-column-default + show-column
  } else {
    show-column-default
  }

  managed-motif(
    "line-items",
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

      derive("input-gross", input-gross, default: tax-mode == "inclusive")

      derive("tax", tax, default: m-tax.zero())
      derive("tax-mode", tax-mode, default: "exclusive")
      ensure("tax-exempt-small-biz", false)

      put("show-column", {
        let base-col = ctx.at("show-column", default: (:))
        if type(base-col) == dictionary {
          base-col + show-column
        } else {
          show-column
        }
      })

      derive("show-total", show-total, default: true)
      derive("show-information", show-information, default: true)

      nest("format", {
        ensure("percent", x => str(calc.round(x * 100)) + "%")
        ensure("number", x => str(x))
        ensure("currency", x => str(calc.round(x, digits: 2)) + "€")
        ensure("currency-fine", x => str(calc.round(x, digits: 4)) + "€")
        ensure("date", date => {
          if type(date) == datetime { date.display() } else if (
            type(date) == array
          ) { date.first().display() + " - " + date.last().display() } else {
            none
          }
        })
      })

      nest("theme", {
        ensure("line-items", (..) => [Line Items])
      })
    }),
    measure: (ctx, children) => {
      let modifier-applicator = loom.query.find-signal(
        children,
        "modifier-applicator",
      )
      let tax-applicator = loom.query.find-signal(children, "tax-applicator")
      let items = modifier-applicator.items

      let formated-items = items.map(item => loom.mutator.batch(item, {
        import loom.mutator: *

        update("name", x => [#x])
        put("has-description", item.description != none)
        update("description", x => [#x])

        put("has-date", item.date != none)
        update("date", ctx.format.date)

        update("quantity", ctx.format.number)
        update("base-quantity", ctx.format.number)

        update("unit", x => [#x])

        update("price", ctx.format.currency-fine)
        update("total", ctx.format.currency)
        update("unmodified-total", ctx.format.currency)

        update("tax", x => (
          rate: (ctx.format.percent)(x.rate),
          category: x.category,
        ))

        put("has-discounts", item.discounts.len() >= 1)
        update("discounts", discounts => discounts.map(d => {
          let display-format = if d.type == "relative" {
            ctx.format.percent
          } else { ctx.format.currency }
          (
            name: [#d.name],
            description: [#d.description],
            display: display-format(calc.abs(d.display)),
            absolute: (ctx.format.currency)(calc.abs(d.absolute)),
            is-percent: d.type == "relative",
            has-description: d.description != none,
          )
        }))

        put("has-surcharge", item.surcharge.len() >= 1)
        update("surcharge", discounts => discounts.map(s => {
          let display-format = if s.type == "relative" {
            ctx.format.percent
          } else { ctx.format.currency }
          (
            name: [#s.name],
            description: [#s.description],
            display: display-format(calc.abs(s.display)),
            absolute: (ctx.format.currency)(calc.abs(s.absolute)),
            is-percent: s.type == "relative",
            has-description: s.description != none,
          )
        }))

        put("has-item-id", item.item-id != none)
        put("has-reference", item.reference != none)
      }))

      let formated-taxes = tax-applicator
        .taxes
        .pairs()
        .map(((key, tax)) => {
          let formated-rate = (ctx.format.percent)(tax.rate)
          let formated-value = (ctx.format.currency)(tax.absolute)
          (
            rate: [#formated-rate],
            category: [#tax.category],
            amount: [#formated-value],
          )
        })

      let formated-total = (
        net: (ctx.format.currency)(tax-applicator.net-total),
        gross: (ctx.format.currency)(tax-applicator.gross-total),
      )

      let unmodified-formated-total = (
        net: (ctx.format.currency)(tax-applicator.unmodified-net-total),
        gross: (ctx.format.currency)(tax-applicator.unmodified-gross-total),
      )

      let formated-discounts = modifier-applicator.modifier.discounts.map(
        discount => loom.mutator.batch(discount, {
          import loom.mutator: *

          update("name", x => [#x])
          update("description", x => [#x])

          remove("type")
          put("is-percent", discount.type == "relative")
          update("display", d => {
            if discount.type == "absolute" [#(ctx.format.currency)(
              calc.abs(d),
            )] else [#(ctx.format.percent)(calc.abs(d))]
          })
          update("absolute", x => (ctx.format.currency)(calc.abs(x)))

          if discount.type == "relative" { put("split", (:)) }
          update("split", split => split
            .pairs()
            .map(((_, group)) => {
              (
                tax: (
                  rate: [#(ctx.format.percent)(group.tax.rate)],
                  category: [#group.tax.category],
                ),
                amount: [#(ctx.format.currency)(calc.abs(group.absolute))],
              )
            }))
        }),
      )

      let formated-surcharges = modifier-applicator.modifier.surcharges.map(
        surcharge => loom.mutator.batch(surcharge, {
          import loom.mutator: *

          update("name", x => [#x])
          update("description", x => [#x])

          remove("type")
          put("is-percent", surcharge.type == "relative")
          update("display", d => {
            if surcharge.type == "absolute" [#(ctx.format.currency)(
              calc.abs(d),
            )] else [#(ctx.format.percent)(calc.abs(d))]
          })
          update("absolute", x => (ctx.format.currency)(calc.abs(x)))

          if surcharge.type == "relative" { put("split", (:)) }
          update("split", split => split
            .pairs()
            .map(((_, group)) => {
              (
                tax: (
                  rate: [#(ctx.format.percent)(group.tax.rate)],
                  category: [#group.tax.category],
                ),
                amount: [#(ctx.format.currency)(calc.abs(group.absolute))],
              )
            }))
        }),
      )

      let item-dates = items.map(i => i.date).filter(i => i != none).dedup()

      let item-information = (
        has-dates: item-dates.len() != 0,
        multiple-dates: item-dates.len() > 1,
        multiple-quantities: items.map(i => i.quantity).dedup().len() > 1,
        multiple-units: items.map(i => i.unit).dedup().len() > 1,
        multiple-tax-rates: items.map(i => i.tax).dedup().len() > 1,
        has-global-modifier: formated-discounts.len()
          + formated-surcharges.len()
          > 0,
      )

      let layout-information = (
        show-pos: if ctx.show-column.pos == auto { true } else {
          ctx.show-column.pos
        },
        show-descriptions: if ctx.show-column.description == auto {
          true
        } else { ctx.show-column.description },
        show-modifier: if ctx.show-column.modifier == auto { true } else {
          ctx.show-column.modifier
        },
        show-dates: if ctx.show-column.date == auto {
          item-information.has-dates
        } else { ctx.show-column.date },
        show-quantity: if ctx.show-column.quantity == auto {
          (
            item-information.multiple-quantities
              or item-information.multiple-units
          )
        } else { ctx.show-column.quantity },
        show-units: if ctx.show-column.unit == auto {
          (
            item-information.multiple-units
              or item-information.multiple-quantities
          )
        } else { ctx.show-column.unit },
        show-unit-price: if ctx.show-column.unit-price == auto {
          item-information.multiple-quantities
        } else { ctx.show-column.unit-price },
        show-total-price: if ctx.show-column.total-price == auto { true } else {
          ctx.show-column.total-price
        },
        show-tax-rates: if ctx.show-column.tax-rate == auto {
          item-information.multiple-tax-rates
        } else { ctx.show-column.tax-rate },

        show-total: ctx.show-total,
        show-global-information: ctx.show-information,

        ..item-information,
      )

      let view = (
        items: formated-items,
        discounts: formated-discounts,
        surcharges: formated-surcharges,
        taxes: formated-taxes,
        total: formated-total,
        unmodified-total: unmodified-formated-total,
        layout-information: layout-information,
        tax-mode: ctx.tax-mode,
        tax-exempt-small-biz: ctx.tax-exempt-small-biz,
      )

      let public = (
        total: (
          net: tax-applicator.net-total,
          gross: tax-applicator.gross-total,
        ),
        formated-total: formated-total,
      )

      return (public, view)
    },
    draw: (ctx, _, view, body) => (ctx.theme.line-items)(ctx, view, body),
    (
      modifier-applicator,
      tax-applicator,
    ).fold(body, (c, f) => f(c)),
  )
}
