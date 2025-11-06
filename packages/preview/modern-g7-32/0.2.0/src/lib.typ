#import "style.typ": gost-style
#import "utils.typ": fetch-field
#import "component/title-templates.typ": templates
#import "component/performers.typ": fetch-performers, performers-page

#let gost-common(
  title-template,
  title-arguments,
  city,
  year,
  hide-title,
  performers,
  force-performers,
) = {
  set par(justify: false)

  title-arguments = title-arguments.named()

  title-arguments.insert("year", year)

  let show-performers-page = false
  if performers != none {
    performers = fetch-performers(performers)
    if (performers.len() > 1 or force-performers) {
      show-performers-page = true
    } else {
      title-arguments.insert("performer", performers.first())
    }
  }

  if not hide-title {
    block(width: 100%, title-template(..title-arguments), breakable: false)
  }

  if show-performers-page { performers-page(performers) }
}

#let gost(
  title-template: templates.default,
  text-size: (default: 14pt, small: 10pt),
  indent: 1.25cm,
  margin: (left: 30mm, right: 15mm, top: 20mm, bottom: 20mm),
  title-footer-align: center,
  pagination-align: center,
  pagebreaks: true,
  city: none,
  year: auto,
  hide-title: false,
  performers: none,
  force-performers: false,
  ..title-arguments,
  body,
) = {
  let table-counter = counter("table")
  let image-counter = counter("image")
  let citation-counter = counter("citation")
  let appendix-counter = counter("appendix")

  show figure.where(kind: image): it => {
    image-counter.step()
    it
  }
  show figure.where(kind: table): it => {
    table-counter.step()
    it
  }

  if year == auto {
    year = int(datetime.today().display("[year]"))
  }

  text-size = fetch-field(text-size, ("default*", "small"))

  show: gost-style.with(
    year,
    city,
    hide-title,
    text-size.default,
    text-size.small,
    indent,
    margin,
    title-footer-align,
    pagination-align,
    pagebreaks,
  )

  gost-common(
    title-template,
    title-arguments,
    city,
    year,
    hide-title,
    performers,
    force-performers,
  )

  body
}
