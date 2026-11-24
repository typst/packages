#import "../loom-wrapper.typ": compute-motif, loom
#import "../utils/coercion.typ"
#import "../data/tax.typ" as m-tax
#import "group-by-tax.typ": group-by-tax

#let calculate-taxes(ctx, children) = {
  let norm-money = ctx.locale.normalize.money
  let norm-money-fine = ctx.locale.normalize.money-fine
  let strings = ctx.locale.at("strings", default: (:))
  // The VAT group of the small business scheme (`tax-exempt-small-biz`).
  let small-business-key = if ctx.at("tax-exempt-small-biz", default: false) {
    let scheme = (
      ctx
        .locale
        .at("tax", default: (:))
        .at("small-enterprise-special-scheme", default: none)
    )
    if type(scheme) == dictionary { m-tax.to-tax-key(scheme) }
  }

  let modifier-applicator = loom.query.find-signal(
    children,
    "modifier-applicator",
  )
  if modifier-applicator == none {
    panic("tax-applicator needs have a child modifier-applicator")
  }

  let items = modifier-applicator.items
  let tax-groups = modifier-applicator.tax-groups

  let is-net-based = ctx.tax-mode == "exclusive"

  let modifier-groups = tax-groups
    .groups
    .keys()
    .map(key => {
      let applicable-discounts = modifier-applicator.tax-split.discounts.at(
        key,
        default: (),
      )
      let discount-total = applicable-discounts
        .map(d => d.absolute)
        .sum(default: decimal("0"))

      let applicable-surchrages = modifier-applicator.tax-split.surcharges.at(
        key,
        default: (),
      )
      let surchrages-total = applicable-surchrages
        .map(d => d.absolute)
        .sum(default: decimal("0"))

      let total = discount-total + surchrages-total
      (key, total)
    })
    .to-dict()

  let net-total = decimal("0")
  let gross-total = decimal("0")

  let unmodified-net-total = decimal("0")
  let unmodified-gross-total = decimal("0")

  let taxes = (:)

  for (key, group) in tax-groups.groups.pairs() {
    let scope-modifier-totals = modifier-groups.at(key)

    let unmodified-group-total = group.total
    let group-total = group.total + scope-modifier-totals

    let tax = (
      rate: group.tax.rate,
      category: group.tax.category,
      // Every distinct exemption ground of the category, joined.
      grounds: group.tax.at("grounds", default: none),
      // The same grounds one by one, for the printed notes.
      grounds-list: group.at("grounds-list", default: ()),
      // Items of the category without exemption grounds.
      missing-grounds: group.at("missing-grounds", default: 0),
      // The exemption reason codes of the items (BT-121).
      codes: m-tax.codes-of(group.tax),
      // Some item has no tax at all (`tax: none`), see `tax.implicit-zero`.
      implicit: group.tax.at("implicit", default: false),
      absolute: decimal("0"),
      basis: decimal("0"),
    )

    // A category that needs an exemption reason (AE, K, G, O) states the note
    // of the language (`tax-exemption`) when no item gives grounds. It is
    // printed below the line items like other grounds and written as
    // exemption reason into the e-invoice (BT-120), so both say the same.
    // The themes print the note of the small business scheme themselves
    // (`legal.vat-exemption` if the scheme has no grounds), so it is only the
    // reason of its group.
    if tax.grounds-list.len() == 0 and not m-tax.has-grounds(tax.grounds) {
      if key == small-business-key {
        tax.grounds = strings
          .at("legal", default: (:))
          .at("vat-exemption", default: none)
      } else {
        let note = m-tax.default-grounds(tax.category, strings)
        if note != none {
          tax.grounds = note
          tax.grounds-list = (note,)
        }
      }
    }

    if is-net-based {
      let tax-amount = norm-money(group-total * tax.rate)
      tax.absolute = tax-amount
      tax.basis = group-total
      net-total += group-total
      gross-total += group-total + tax-amount

      let unmodified-tax-amount = norm-money(unmodified-group-total * tax.rate)
      unmodified-net-total += unmodified-group-total
      unmodified-gross-total += unmodified-group-total + unmodified-tax-amount
    } else {
      let net = norm-money(group-total / (1 + tax.rate))
      tax.absolute = group-total - net
      tax.basis = net
      net-total += net
      gross-total += group-total

      let unmodified-net = norm-money(unmodified-group-total / (1 + tax.rate))
      unmodified-net-total += unmodified-net
      unmodified-gross-total += unmodified-group-total
    }

    taxes.insert(key, tax)
  }

  (
    unmodified-net-total: unmodified-net-total,
    unmodified-gross-total: unmodified-gross-total,
    net-total: net-total,
    gross-total: gross-total,
    taxes: taxes,
  )
}

#let tax-applicator(
  body,
) = {
  compute-motif(
    scope: ctx => loom.mutator.batch(ctx, {
      import loom.mutator: *

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
      let data = calculate-taxes(ctx, children)

      return (
        (
          loom.frame.new(
            kind: "tax-applicator",
            key: loom.path.current(ctx),
            path: loom.path.get(ctx),
            signal: data,
          ),
        )
          + children
      )
    },
    body,
  )
}
