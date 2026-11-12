#import "helpers.typ": linked-text, generic-two-by-two, generic-one-by-two
#import "config.typ": spacing-state

#let info-row(body) = context {
  let s = spacing-state.get()
  block(width: 100%, spacing: s.at("item-spacing"), body)
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
    bottom-left: degree,
    bottom-right: dates,
  )
}

// The first role draws the company. Later roles are one line.
#let employer-info = state("exp-resume-employer", none)

#let role(
  title: "",
  dates: "",
) = context {
  let info = employer-info.get()
  let first = info != none and not info.used

  if first {
    employer-info.update(info + (used: true))
    generic-two-by-two(
      top-left: strong(info.company),
      top-right: info.location,
      bottom-left: title,
      bottom-right: dates,
    )
  } else {
    generic-one-by-two(left: title, right: dates)
  }
}

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

  let stack = if technologies == none {
    ""
  } else if type(technologies) == str {
    technologies.trim()
  } else {
    technologies
  }
  let has-stack = type(stack) != str or stack != ""

  generic-one-by-two(
    left: [*#name*#if has-stack [ (#stack)]],
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
  info-row[*#category*: #items]
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
