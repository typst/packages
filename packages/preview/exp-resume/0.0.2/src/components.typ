#import "helpers.typ": linked-text, generic-two-by-two, generic-one-by-two

// Summary section component: renders a justified paragraph of 2-3 lines.
// `resume` already sets `set par(justify: true)` for the whole body.
#let summary(body) = {
  body
}

// Section components below
#let edu(
  institution: "",
  dates: "",
  degree: "",
  location: "",
  // Makes dates on upper right like rest of components
  consistent: false,
) = {
  if consistent {
    // edu-constant style (dates top-right, location bottom-right)
    generic-two-by-two(
      top-left: strong(institution),
      top-right: dates,
      bottom-left: emph(degree),
      bottom-right: emph(location),
    )
  } else {
    // original edu style (location top-right, dates bottom-right)
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

// Project links: links: ((url: "github.com/...", text: "Github"), ...)
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
  block(width: 100%, spacing: 0.65em)[
    *#name*, #issuer
    #if url != "" {
      [ (#linked-text(url, link-prefix: "https://", text: url-text))]
    }
    #h(1fr) #date
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