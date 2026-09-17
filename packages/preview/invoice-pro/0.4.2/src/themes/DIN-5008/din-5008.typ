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
  )
}
