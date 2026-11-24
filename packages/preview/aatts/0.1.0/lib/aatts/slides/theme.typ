#import "../constants.typ" as constants
#import "../theme.typ" as base-theme

#import "units.typ" as units


// text styling w/o page setup, usable inside boxes (e.g. scaled previews)
#let typography(
  font-families: constants.font-families,
  highlight: constants.palette.red,
  lang: "en",
  body
  ) = {
  show: base-theme.style.with(
    space: units.space,
    font: units.font,
    weight: units.weight,
    font-families: font-families,
    lang: lang,
    highlight: highlight,
  )

  body
}


#let style(
  paper: "presentation-16-9",
  footer: none,
  font-families: constants.font-families,
  highlight: constants.palette.red,
  lang: "en", 
  body
  ) = {
  set page(
    paper: paper,
    margin: (
      x: units.space.base, 
      y: units.space.base
    ),
    footer: context {
      set text(
        size: units.font.sm, 
        fill: constants.palette.grey.medium
      )
      grid(
        columns: (1fr, auto),
        footer, counter(page).display(),
      )
    },
  )

  show: typography.with(
    font-families: font-families,
    lang: lang,
    highlight: highlight,
  )

  body
}
