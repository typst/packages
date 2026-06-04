// Entry component for experience, education, projects, etc.
// Custom implementation with location-URL detection and icons

#import "@preview/fontawesome:0.6.0": fa-icon
#import "theme.typ": color-primary, color-secondary, ENTRY_LEFT_COLUMN_WIDTH

// === Custom Entry Function ===
// Location can be a URL (will be clickable) or plain text
// location-url: optional full URI (used for detection and linking)
// location: displayed caption (can differ from URL)
#let entry(
  title: none,
  date: "",
  institution: "",
  location: "",
  location-url: "",
  description,
) = {
  // Determine location type from URL (primary) or location text (fallback)
  let location-kind = if location-url != "" {
    if location-url.contains("nuget.org") { "nuget" }
    else if location-url.contains("github.com") { "github" }
    else if location-url.starts-with("http") or location-url.contains(".com") or location-url.contains(".org") or location-url.contains(".io") or location-url.contains(".net") { "web" }
    else { "text" }
  } else if location != "" {
    // Heuristic for geographic locations (contains comma + country patterns)
    if location.contains(",") and (
      location.contains("Italy") or location.contains("Italia") or
      location.contains("USA") or location.contains("UK") or
      location.contains("France") or location.contains("Germany") or
      location.contains("Spain") or location.contains("Switzerland")
    ) { "geo" }
    else if location.contains("nuget.org") { "nuget" }
    else if location.contains("github.com") { "github" }
    else if location.starts-with("http") or location.contains(".com") or location.contains(".org") or location.contains(".io") { "web" }
    else { "text" }
  } else { "none" }

  // Map location type to FontAwesome icon
  let icon-name = if location-kind == "geo" { "location-dot" }
    else if location-kind == "nuget" { "cube" }
    else if location-kind == "github" { "github" }
    else if location-kind == "web" { "globe" }
    else { none }

  // Determine if we have a clickable link
  let link-url = if location-url != "" {
    if location-url.starts-with("http") { location-url } else { "https://" + location-url }
  } else if location-kind == "web" or location-kind == "nuget" or location-kind == "github" {
    if location.starts-with("http") { location } else { "https://" + location }
  } else { none }

  block(above: 1em, below: 0.65em)[
    #grid(
      columns: (ENTRY_LEFT_COLUMN_WIDTH, auto),
      align: (right, left),
      column-gutter: .8em,
      [
        #text(size: 0.8em, fill: color-secondary, date)
      ],
      [
        #set text(size: 0.85em)

        #text(weight: "semibold", fill: color-primary, title)

        #text(size: 0.9em, smallcaps([
          #if institution != "" or location != "" [
            #institution
            #h(1fr)
            #if location != "" [
              #if icon-name != none [
                #fa-icon(icon-name, size: 0.85em, fill: color-secondary)
              ]
              #if link-url != none [
                #link(link-url)[#text(fill: color-secondary, location)]
              ] else [
                #text(fill: color-secondary, location)
              ]
            ]
          ]
        ]))

        #text(size: 0.9em, description)
      ],
    )
  ]
}
