#import "../../../utils/types.typ"

#let render-global-info(
  ctx,
  data,

  color-desc: luma(100),
  size-small: 0.85em,
) = {
  types.require(color-desc, "render-global-info::color-desc", color, none)

  let layout = data.layout-information
  let is-net = data.tax-mode == "exclusive"
  let lang-eq-region = ctx.locale.meta.region == ctx.locale.strings.meta.lang
  let sum-str = ctx.locale.strings.summary
  let leg-str = ctx.locale.strings.legal
  let info-str = ctx.locale.strings.global-info

  let global-infos = ()

  let has-exemption-grounds = data
    .at("taxes", default: ())
    .any(t => (
      t.at("grounds", default: none) != none
        and t.grounds != ""
        and t.grounds != []
    ))

  // Standard Tax Statement (Suppressed for small businesses and tax exemptions)
  if (
    not layout.show-tax-rates
      and not layout.multiple-tax-rates
      and data.items.len() > 0
      and not data.tax-exempt-small-biz
      and not has-exemption-grounds
  ) {
    let tax-rate = data.items.first(default: (tax: (rate: [0%]))).tax.rate
    let tax-text = if is-net { sum-str.excluding } else { sum-str.including }
    global-infos.push((info-str.tax-statement)(
      tax-text,
      tax-rate,
      sum-str.vat-tax,
    ))
  }

  // Unit, Quantity, and Date info (Simplified display)
  if (
    not layout.show-units and not layout.multiple-units and data.items.len() > 0
  ) {
    let raw-unit = data.items.first(default: (unit: none)).unit
    let unit = if type(raw-unit) == dictionary {
      raw-unit.at("display", default: raw-unit.at("name", default: none))
    } else {
      raw-unit
    }
    if unit != none {
      global-infos.push([#info-str.unit #unit])
    }
  }

  if not layout.show-quantity and not layout.multiple-quantities {
    let quantity = data.items.first(default: (quantity: 0)).quantity
    global-infos.push([#info-str.quantity #quantity])
  }

  if (
    not layout.show-dates
      and layout.has-dates
      and not layout.multiple-dates
      and data.items.len() > 0
  ) {
    let date = data.items.first(default: (date: none)).date
    global-infos.push([#info-str.date #date])
  }

  let rendered-grounds = ()

  // Small Business Legal Clause
  if data.tax-exempt-small-biz {
    let grounds = leg-str.vat-exemption
    let legal-grounds = ctx
      .locale
      .tax
      .small-enterprise-special-scheme
      .at("grounds", default: none)

    let sm-tax = data
      .at("taxes", default: ())
      .find(t => (
        t.at("grounds", default: none) == legal-grounds or t.category == "E"
      ))
    let sm-tax-is-zero = (
      sm-tax != none
        and (
          sm-tax.at("raw-rate", default: none) == 0%
            or sm-tax.at("raw-rate", default: none) == 0
            or sm-tax.rate == [0%]
            or sm-tax.rate == [0,0%]
            or sm-tax.rate == [0.0%]
        )
    )
    let marker = if sm-tax != none and not sm-tax-is-zero {
      sm-tax.at("marker", default: none)
    } else {
      none
    }
    let marker-str = if marker != none and layout.show-total {
      super[#marker] + [ ]
    } else {
      []
    }

    if lang-eq-region {
      if legal-grounds != none {
        global-infos.push([#marker-str#legal-grounds])
        rendered-grounds.push(legal-grounds)
      }
    } else {
      if legal-grounds != none {
        global-infos.push([#marker-str#grounds (#legal-grounds)])
        rendered-grounds.push(legal-grounds)
      } else {
        global-infos.push([#marker-str#grounds])
      }
    }
  }

  // Tax Exemption Grounds
  for t in data.at("taxes", default: ()) {
    let grounds = t.at("grounds", default: none)
    if grounds != none and grounds != "" and grounds != [] {
      if grounds not in rendered-grounds {
        rendered-grounds.push(grounds)
        let t-is-zero = (
          t.at("raw-rate", default: none) == 0%
            or t.at("raw-rate", default: none) == 0
            or t.rate == [0%]
            or t.rate == [0,0%]
            or t.rate == [0.0%]
        )
        let marker = if not t-is-zero {
          t.at("marker", default: none)
        } else {
          none
        }
        let marker-str = if marker != none and layout.show-total {
          super[#marker] + [ ]
        } else {
          []
        }
        global-infos.push([#marker-str#grounds])
      }
    }
  }

  if layout.show-global-information and global-infos.len() > 0 {
    pad(
      top: 1em,
      text(
        size: size-small,
        fill: color-desc,
        global-infos.join([\ ]),
      ),
    )
  }
}
