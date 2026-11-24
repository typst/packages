#import "helpers.typ": linked-text, generic-two-by-two, generic-one-by-two
#import "spacing.typ": spacing-state

#let summary(body) = {
  body
}

// Single full-width row used by certificates and skills (same spacing).
#let info-row(body) = context {
  let s = spacing-state.get()
  block(width: 100%, spacing: s.row, body)
}

#let edu(
  institution: "",
  dates: "",
  degree: "",
  location: "",
  consistent: false,
) = {
  if consistent {
    generic-two-by-two(
      top-left: strong(institution),
      top-right: dates,
      bottom-left: emph(degree),
      bottom-right: emph(location),
    )
  } else {
    generic-two-by-two(
      top-left: strong(institution),
      top-right: location,
      bottom-left: emph(degree),
      bottom-right: emph(dates),
    )
  }
}

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
) = {
  generic-two-by-two(
    top-left: strong(title),
    top-right: dates,
    bottom-left: company,
    bottom-right: emph(location),
  )
}

#let project(
  name: "",
  technologies: "",
  links: (),
) = {
  let link-items = links
    .filter(item => item.at("url", default: "") != "")
    .map(item => linked-text(
      item.at("url"),
      link-prefix: "https://",
      text: item.at("text", default: ""),
    ))

  generic-one-by-two(
    left: {
      [*#name*#if technologies != "" [ #sym.dash.em #technologies]]
    },
    right: link-items.join([ ∙ ]),
  )
}

#let certificates(
  name: "",
  issuer: "",
  url: "",
  url-text: "",
  date: "",
) = {
  info-row[
    *#name*, #issuer
    #if url != "" {
      [ (#linked-text(url, link-prefix: "https://", text: url-text))]
    }
    #h(1fr) #date
  ]
}

#let skills(
  category: "",
  items: "",
) = {
  info-row[
    *#category*: #items
  ]
}

#let extracurriculars(
  activity: "",
  dates: "",
) = {
  generic-one-by-two(
    left: strong(activity),
    right: dates,
  )
}
