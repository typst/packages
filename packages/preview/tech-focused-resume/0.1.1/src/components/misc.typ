#import "../layout.typ": generic-one-by-two, no-marker-list-helper

// Formats a certification with its issuer, date, and optional verification link.
#let certificates(
  name: "",
  issuer: "",
  url: "",
  date: "",
  columns: (1fr, 1fr),
) = {
  if url != "" {
    name = link(url)[#name]
  }
  generic-one-by-two(
    cols: columns,
    [*#name*, #issuer],
    [*#date*],
  )
}

// Formats an extracurricular activity with its dates.
#let extracurriculars(
  activity: "",
  dates: "",
  columns: (1fr, 1fr),
) = {
  generic-one-by-two(
    cols: columns,
    strong(activity),
    strong(dates),
  )
}

// Removes list markers and applies shared formatting to a skills list.
#let skills(body) = {
  no-marker-list-helper(body)
}

// Removes list markers and applies shared formatting to a languages list.
#let languages(body) = {
  no-marker-list-helper(body)
}
