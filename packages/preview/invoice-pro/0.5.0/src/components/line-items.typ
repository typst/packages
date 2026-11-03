#import "../loom-wrapper.typ": loom, managed-motif
#import "../logic/modifier-applicator.typ": modifier-applicator
#import "../logic/tax-applicator.typ": tax-applicator
#import "../logic/tree.typ": resolve-tree
#import "../logic/exemption-notes.typ": (
  assign-markers, exemption-notes, group-markers, item-marker,
)
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
  /// Whether to show the total block below the line items.
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

      let resolved-tax-mode = if tax-mode != auto {
        tax-mode
      } else {
        ctx.at("tax-mode", default: "exclusive")
      }
      let resolved-input-gross = if input-gross != auto {
        input-gross
      } else {
        resolved-tax-mode == "inclusive"
      }

      put("input-gross", resolved-input-gross)

      // Without a tax from anywhere (`tax: none` on the invoice), the items
      // are zero rated, marked as implicit (see `tax.implicit-zero`).
      derive("tax", tax, default: m-tax.implicit-zero())
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

      nest("locale", {
        ensure("strings", (:))

        nest("format", {
          ensure("percent", (..) => panic(
            "locale::format::percent is not provided",
          ))
          ensure("number", (..) => panic(
            "locale::format::number is not provided",
          ))
          ensure("currency", (..) => panic(
            "locale::format::currency is not provided",
          ))
          ensure("currency-fine", (..) => panic(
            "locale::format::currency-fine is not provided",
          ))
          ensure("date", (..) => panic("locale::format::date is not provided"))
          ensure("time", (..) => panic("locale::format::time is not provided"))
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
      let tree-result = resolve-tree(children)
      let items = if tree-result.raw-items.len() > 0 {
        tree-result.raw-items
      } else {
        modifier-applicator.items
      }

      let format = ctx.locale.format

      let format-unit(x) = if type(x) == dictionary and "display" in x {
        [#(x.display)]
      } else { [#x] }

      // One marker per distinct exemption ground, in the order of the VAT
      // groups. It links the notes below the line items to the VAT line of
      // their category and, if a category has items exempt for different
      // reasons, to each of these items.
      let markers = assign-markers(tax-applicator.taxes)

      // The label of the country of origin of an item.
      let item-strings = ctx.locale.strings.at("line-items", default: (:))
      let origin-label = item-strings.at("origin", default: none)

      let format-item(item) = loom.mutator.batch(item, {
        import loom.mutator: *

        update("name", x => [#x])
        // The description, followed by the note and the country of origin of
        // the item (`item(note: .., origin: ..)`), each on a line of its own.
        let note = item.at("note", default: none)
        let origin = item.at("origin", default: none)
        if note == none and origin == none {
          put("has-description", item.description != none)
          update("description", x => [#x])
        } else {
          let details = ()
          if item.description != none { details.push([#item.description]) }
          if note != none { details.push([#note]) }
          if origin != none {
            details.push(if origin-label == none { [#origin] } else {
              [#origin-label: #origin]
            })
          }
          put("has-description", true)
          put("description", details.join(linebreak()))
        }

        put("has-date", item.date != none)
        update("date", format.date)

        update("quantity", format.number)
        update("base-quantity", format.number)

        update("unit", format-unit)
        update("unit-singular", format-unit)

        update("price", format.currency-fine)
        update("total", format.currency)
        update("unmodified-total", format.currency)

        update("tax", x => (
          rate: (format.percent)(x.rate),
          category: x.category,
          marker: item-marker(x, markers),
        ))

        put("has-discounts", item.discounts.len() >= 1)
        update("discounts", discounts => discounts.map(d => {
          let display-format = if d.type == "relative" {
            format.percent
          } else { format.currency }
          (
            name: [#d.name],
            label: if d.at("label", default: none) != none { [#d.label] } else {
              none
            },
            description: [#d.description],
            display: display-format(calc.abs(d.display)),
            absolute: (format.currency)(calc.abs(d.absolute)),
            is-percent: d.type == "relative",
            has-description: d.description != none,
          )
        }))

        put("has-surcharge", item.surcharge.len() >= 1)
        update("surcharge", discounts => discounts.map(s => {
          let display-format = if s.type == "relative" {
            format.percent
          } else { format.currency }
          (
            name: [#s.name],
            label: if s.at("label", default: none) != none { [#s.label] } else {
              none
            },
            description: [#s.description],
            display: display-format(calc.abs(s.display)),
            absolute: (format.currency)(calc.abs(s.absolute)),
            is-percent: s.type == "relative",
            has-description: s.description != none,
          )
        }))

        put("has-item-id", item.item-id != none)
        put("has-reference", item.reference != none)
      })

      let formated-entries = tree-result.entries.map(entry => {
        if entry.kind == "item" {
          let f-item = format-item(entry.raw)
          f-item.insert("kind", "item")
          f-item.insert("pos", entry.pos)
          f-item.insert("level", entry.level)
          f-item
        } else if entry.kind == "group-header" {
          (
            kind: "group-header",
            pos: entry.pos,
            level: entry.level,
            name: [#entry.name],
            description: if entry.description != none {
              [#entry.description]
            } else { none },
            has-description: entry.description != none,
          )
        } else if entry.kind == "group-footer" {
          (
            kind: "group-footer",
            pos: entry.pos,
            level: entry.level,
            name: [#entry.name],
            subtotal: (format.currency)(entry.subtotal),
            raw-subtotal: entry.subtotal,
          )
        }
      })

      let formated-items = formated-entries.filter(e => e.kind == "item")

      let formated-taxes = tax-applicator
        .taxes
        .pairs()
        .map(((key, tax)) => {
          let formated-rate = (format.percent)(tax.rate)
          let formated-value = (format.currency)(tax.absolute)
          let grounds-list = m-tax.grounds-of(tax)
          let grounds-markers = group-markers(tax, markers)
          (
            rate: [#formated-rate],
            raw-rate: tax.rate,
            raw-amount: tax.absolute,
            category: [#tax.category],
            amount: [#formated-value],
            // Every distinct exemption ground of the category, joined ...
            grounds: tax.at("grounds", default: none),
            // ... and one by one with their markers, for the notes below the
            // line items.
            grounds-list: grounds-list,
            grounds-markers: grounds-markers,
            // With several grounds, each item is marked with its own.
            itemized-grounds: grounds-list.len() > 1,
            marker: if grounds-markers.len() == 0 { none } else {
              grounds-markers.join(",")
            },
          )
        })

      let prepayments = loom.query.collect-signals(children, kind: "prepayment")
      let gross-total = tax-applicator.gross-total
      let normalized-prepayments = prepayments.map(p => {
        let amount = decimal("0")
        if p.type == "relative" {
          amount = (ctx.locale.normalize.money)(gross-total * p.amount)
        } else {
          amount = p.amount
        }
        (
          name: p.name,
          label: p.label,
          date: p.date,
          reference: p.reference,
          description: p.description,
          method: p.method,
          amount: amount,
          type: p.type,
        )
      })
      let total-prepaid = normalized-prepayments
        .map(p => p.amount)
        .sum(default: decimal("0"))

      let due-total = gross-total - total-prepaid

      let formated-prepayments = normalized-prepayments.map(p => {
        let amount-str = (format.currency)(p.amount)
        (
          name: if p.name != none { [#p.name] } else { none },
          label: if p.label != none { [#p.label] } else { none },
          date: if p.date != none { [#p.date] } else { none },
          reference: if p.reference != none { [#p.reference] } else { none },
          description: if p.description != none { [#p.description] } else {
            none
          },
          method: if p.method != none { [#p.method] } else { none },
          amount: [#amount-str],
          value: p.amount,
        )
      })

      let formated-total = (
        net: (format.currency)(tax-applicator.net-total),
        gross: (format.currency)(tax-applicator.gross-total),
        due: (format.currency)(due-total),
        prepaid: (format.currency)(total-prepaid),
      )

      let unmodified-formated-total = (
        net: (format.currency)(tax-applicator.unmodified-net-total),
        gross: (format.currency)(tax-applicator.unmodified-gross-total),
      )

      let formated-discounts = modifier-applicator.modifier.discounts.map(
        discount => loom.mutator.batch(discount, {
          import loom.mutator: *

          update("name", x => [#x])
          update("label", x => if x != none { [#x] } else { none })
          update("description", x => [#x])

          remove("type")
          put("is-percent", discount.type == "relative")
          update("display", d => {
            if discount.type == "absolute" [#(format.currency)(
              calc.abs(d),
            )] else [#(format.percent)(calc.abs(d))]
          })
          update("absolute", x => (format.currency)(calc.abs(x)))

          if discount.type == "relative" { put("split", (:)) }
          update("split", split => split
            .pairs()
            .map(((_, group)) => {
              (
                tax: (
                  rate: [#(format.percent)(group.tax.rate)],
                  category: [#group.tax.category],
                ),
                amount: [#(format.currency)(calc.abs(group.absolute))],
              )
            }))
        }),
      )

      let formated-surcharges = modifier-applicator.modifier.surcharges.map(
        surcharge => loom.mutator.batch(surcharge, {
          import loom.mutator: *

          update("name", x => [#x])
          update("label", x => if x != none { [#x] } else { none })
          update("description", x => [#x])

          remove("type")
          put("is-percent", surcharge.type == "relative")
          update("display", d => {
            if surcharge.type == "absolute" [#(format.currency)(
              calc.abs(d),
            )] else [#(format.percent)(calc.abs(d))]
          })
          update("absolute", x => (format.currency)(calc.abs(x)))

          if surcharge.type == "relative" { put("split", (:)) }
          update("split", split => split
            .pairs()
            .map(((_, group)) => {
              (
                tax: (
                  rate: [#(format.percent)(group.tax.rate)],
                  category: [#group.tax.category],
                ),
                amount: [#(format.currency)(calc.abs(group.absolute))],
              )
            }))
        }),
      )

      let item-dates = items.map(i => i.date).filter(i => i != none).dedup()

      let item-information = (
        has-dates: item-dates.len() != 0,
        multiple-dates: item-dates.len() > 1,
        multiple-quantities: items.map(i => i.quantity).dedup().len() > 1,
        // Compare the singular form so "1 day" and "2 days" count as one unit.
        multiple-units: items.map(i => i.unit-singular).dedup().len() > 1,
        multiple-tax-rates: items.map(i => i.tax).dedup().len() > 1,
        has-global-modifier: formated-discounts.len()
          + formated-surcharges.len()
          > 0,
        has-prepayments: formated-prepayments.len() > 0,
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

      // The notes that state why a VAT category carries no VAT, with the
      // markers to print (see `exemption-notes`).
      let notes = exemption-notes(
        formated-taxes,
        show-total: layout-information.show-total,
        show-tax-rates: layout-information.show-tax-rates,
        small-business: if ctx.tax-exempt-small-biz {
          (
            clause: ctx.locale.strings.legal.vat-exemption,
            grounds: ctx
              .locale
              .tax
              .small-enterprise-special-scheme
              .at("grounds", default: none),
            same-language: ctx.locale.meta.region
              == ctx.locale.strings.meta.lang,
          )
        },
      )
      // The notes of the invoice (`invoice(notes: ..)`), which the e-invoice
      // states as well (BT-22), follow the exemption notes.
      for note in ctx.at("notes", default: ()) {
        notes.push((kind: "note", marker: none, body: note.text))
      }

      let view = (
        items: formated-items,
        entries: formated-entries,
        discounts: formated-discounts,
        surcharges: formated-surcharges,
        prepayments: formated-prepayments,
        taxes: formated-taxes,
        // Every note is `(kind: .., marker: .., body: ..)`, in print order:
        // the exemption notes (kind "small-business" or "grounds"), then the
        // notes of the invoice (kind "note").
        exemption-notes: notes,
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
          due: due-total,
          prepaid: total-prepaid,
        ),
        formated-total: formated-total,
        // ZUGFeRD Data
        item-data: (
          items: items,
          taxes: tax-applicator.taxes,
          net-total: tax-applicator.net-total,
          gross-total: tax-applicator.gross-total,
          unmodified-net-total: tax-applicator.unmodified-net-total,
          due-total: due-total,
          prepaid-total: total-prepaid,
          prepayments: normalized-prepayments,
          tax-mode: ctx.tax-mode,
          discounts: modifier-applicator.modifier.discounts,
          surcharges: modifier-applicator.modifier.surcharges,
          // Whether the dates of the items are printed: with each item, or
          // below the items when they share one date. They state the date of
          // the supply (BT-72, BG-14) the law requires on the invoice.
          dates-printed: layout-information.has-dates
            and (
              layout-information.show-dates
                or (
                  not layout-information.multiple-dates
                    and layout-information.show-global-information
                )
            ),
        ),
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
