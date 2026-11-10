#import "tum-header.typ": tum-logo-height

#let tum-page = (
  type: "a4",
  height: 297mm,
  width: 210mm,
)

#let cover-page-margins = (
  top: 3 * tum-logo-height,
  bottom: tum-logo-height,
  left: tum-logo-height,
  right: tum-logo-height,
)

#let title-page-margins = (
  top: 3 * tum-logo-height,
  bottom: 2 * tum-logo-height,
  left: 2 * tum-logo-height,
  right: 2 * tum-logo-height,
)

#let content-page-margins = (
  top: 3 * tum-logo-height,
  bottom: 2 * tum-logo-height,
  left: 2 * tum-logo-height,
  right: 2 * tum-logo-height,
)

#let first-line-indent = 1em
