#import "../utils/header.typ": appendix-page-header
#import "../utils/heading.typ": appendix-first-heading

#let appendix(
  doctype: "master",
  twoside: false,
  body,
) = {
  show: appendix-page-header.with(doctype: doctype, twoside: twoside)
  show: appendix-first-heading.with(twoside: twoside)

  body
}