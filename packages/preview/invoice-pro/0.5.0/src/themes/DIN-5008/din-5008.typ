#import "../base.typ": *
#import "../base-theme/line-items.typ": render-line-items

#import "document.typ": letter-document

#let DIN-5008(
  form: "A",
  font: "Liberation Sans",

  hole-mark: true,
  folding-marks: true,

  color-row-odd: none,
  color-row-even: rgb("e2e8f0"),

  margin: (:),
  footer: none,
) = {
  types.require(form, "theme::DIN-5008::form", "A", "B")

  base-theme.with(
    document: letter-document(
      form: form,
      font: font,

      hole-mark: hole-mark,
      folding-marks: folding-marks,

      margin: margin,
      footer: footer,
    ),
    line-items: render-line-items.with(
      color-row-odd: color-row-odd,
      color-row-even: color-row-even,
    ),
    // The letter prints the reference signs, the `extra` of the sender (next
    // to its address) and of the recipient (in the address field), and the
    // footer, if any, on every page.
    prints: (
      references: true,
      party-extra: true,
      page-content: footer not in (none, []),
    ),
  )
}
