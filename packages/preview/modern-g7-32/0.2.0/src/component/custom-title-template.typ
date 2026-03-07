#import "../utils.typ": fetch-field, sign-field
#import "title.typ": (
  agreed-field,
  approved-and-agreed-fields,
  approved-field,
  detailed-sign-field,
  if-present,
  per-line,
)
#import "title-templates.typ": custom-title-template as from-module

#let title-utils = (
  per-line,
  if-present,
  fetch-field,
  sign-field,
  detailed-sign-field,
  agreed-field,
  approved-field,
  approved-and-agreed-fields,
)
