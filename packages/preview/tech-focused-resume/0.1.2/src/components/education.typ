#import "../layout.typ": body-helper, generic-one-by-two, generic-two-by-two

// Formats an education entry and places its additional content below the details.
#let edu(
  institution: "",
  dates: "",
  degree: "",
  location: "",
  columns: (1fr, 1fr),
  body,
) = {
  generic-two-by-two(
    cols: columns,
    top-left: strong(institution),
    top-right: strong(dates),
    bottom-left: emph(degree),
    bottom-right: emph(location),
  )
  body-helper(body, padding: false)
}
