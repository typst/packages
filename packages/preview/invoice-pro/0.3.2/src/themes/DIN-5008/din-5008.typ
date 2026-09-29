#import "../base.typ": *

#import "document.typ": letter-document

#let DIN-5008(
  form: "A",
  font: "Liberation Sans",

  hole-mark: true,
  folding-marks: true,

  margin: (:),
) = {
  types.require(form, "theme::DIN-5008::form", "A", "B")

  base-theme.with(
    document: letter-document(
      form: form,
      font: font,

      hole-mark: hole-mark,
      folding-marks: folding-marks,

      margin: margin,
    ),
  )
}
