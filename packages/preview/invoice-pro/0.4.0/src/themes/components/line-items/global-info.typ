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

  // Standard Tax Statement (Suppressed for small businesses)
  if (
    not layout.show-tax-rates
      and not layout.multiple-tax-rates
      and data.items.len() > 0
      and not data.tax-exempt-small-biz
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
    let unit = data.items.first(default: (unit: none)).unit
    global-infos.push([#info-str.unit #unit])
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

  // Small Business Legal Clause
  if data.tax-exempt-small-biz {
    let grounds = leg-str.vat-exemption
    let legal-grounds = ctx
      .locale
      .tax
      .small-enterprise-special-scheme
      .at("grounds", default: none)

    if lang-eq-region {
      global-infos.push(legal-grounds)
    } else {
      global-infos.push[#grounds (#legal-grounds)]
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
