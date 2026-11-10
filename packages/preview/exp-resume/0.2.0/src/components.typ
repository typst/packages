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
) = {
  generic-two-by-two(
    top-left: strong(institution),
    top-right: location,
    bottom-left: emph(degree),
    bottom-right: emph(dates),
  )
}

// The first role draws the company row with itself, as one two-line header.
#let employer-info = state("exp-resume-employer", none)

// Bottom row of the header: regular title, dates on the right.
// The first role in an employer also draws the top row: bold company, italic location.
#let role(
  title: "",
  dates: "",
) = context {
  let s = spacing-state.get()
  let info = employer-info.get()
  let first = info != none and not info.used

  if first {
    employer-info.update(info + (used: true))
    generic-two-by-two(
      top-left: strong(info.company),
      top-right: emph(info.location),
      bottom-left: title,
      bottom-right: dates,
    )
  } else {
    block(width: 100%, above: s.gap, below: s.row)[
      #title #h(1fr) #dates
    ]
  }
}

// One company, then one or more `#role` lines and their bullets.
// The first role is the lower line of the company header.
// A later role uses the same `gap` above it as any other entry header.
#let employer(
  company: "",
  location: "",
  body,
) = {
  employer-info.update((
    company: company,
    location: location,
    used: false,
  ))
  body
  employer-info.update(none)
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
