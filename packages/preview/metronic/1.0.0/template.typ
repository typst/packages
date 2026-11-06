#import "@preview/fontawesome:0.5.0": *

// --------------------------------------
// Theme
// --------------------------------------

#let current-background-color = state("current-background-color", rgb("ffffff"))

#let theme-state = state("theme", (
  accent-color: rgb("61B7AE"),
  background-color: rgb("F2F0EF"),
))

#let get-background-color() = {
  theme-state.at(here()).background-color
}

#let get-accent-color() = {
  theme-state.at(here()).accent-color
}

#let get-current-background-color() = {
  current-background-color.at(here())
}

#let set-current-background-color(col) = {
  current-background-color.update(c => col)
}

#let theme(
  accent-color: none,
  background-color: none,
) = {
  let config = (:)  // empty dictionary
  if accent-color != none {
    config.insert("accent-color", accent-color)
  }
  if background-color != none {
    config.insert("background-color", background-color)
  }
  theme-state.update(it => it + config)
}

// --------------------------------------
// Config
// --------------------------------------

#show heading.where(level: 1): set text(size: 22pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")

#let empty = ""
#let name = "Patrick Rabier"
#let role = "Lead Software Engineer"
#let font = "Inter"

// --------------------------------------
// Helpers
// --------------------------------------

// White text on darker background, black on light ones (with bias)
#let detect-text-color = (bg-color) => {
  let rgb = bg-color.rgb()
  let r = rgb.components().at(1)
  let g = rgb.components().at(1)
  let b = rgb.components().at(2)

  let total = r + g + b
  if total > 220% {
    black
  } else {
    white
  }
}

// Creates a bullet item
#let tag(content) = [
  #context [
    #box(
      fill: get-accent-color().lighten(50%),
      inset: (x: 8pt, y: 4pt),
      radius: 4pt,
      text(
        size: 10pt,
        fill: rgb(get-accent-color()).darken(40%),
        weight: "medium"
      )[#content]
    )
    #h(1pt)
  ]
]

// A group of tags
#let tags(..items) = {
  box(
    width: 100%, clip: true,
    {
      for item in items.pos() {
        tag(item)
        h(4pt) // Add horizontal spacing between tags
      }
    }
  )
}

#let small(content) = {
  text(size: 10pt)[#content]
}

#let medium(content) = {
  text(size: 14pt, weight: "bold")[#content]
}

#let large(content) = {
  text(size: 18pt, weight: "bold")[#content]
}

#let section(
  icon: "",
  name,
  color: none,
  content
) = {
  context {
    let title = [== #fa-icon(icon) #h(8pt) #name]

    let c = if color != none {
      color
    } else {
      detect-text-color(get-current-background-color())
    }

    text(fill: c)[== #fa-icon(icon) #h(8pt) #name]
    pad(y: 15pt)[#content]
  }
}

#let resume-layout = (
  sidebar: none,
  color: gray,
  base-color: white,
  content
) => {
  if sidebar == none {
    pad(20pt, content)
  } else {
    grid(
      columns: (1.9fr, 3fr),
      rows: (100%),
      fill: (x, _) => if x == 0 { color } else { base-color },
      context {
        set-current-background-color(color)
        sidebar
      },
      context {
        set-current-background-color(base-color)
        content
      },
    )
  }
}

#let contact = (phone: "", github: "", location: "", email: "", linkedin: "") => {
  if email != "" [
    #fa-envelope(solid: true) #h(5pt) #email \
  ]
  if phone != "" [
    #fa-phone(solid: true) #h(5pt) #phone \
  ]
  if github != "" [
    #fa-github(solid: true) #h(5pt) #github \
  ]
  if linkedin != "" [
    #fa-linkedin(solid: true) #h(5pt) #linkedin \
  ]
  if location != "" [
    #fa-location-dot(solid: true) #h(5pt) #location \
  ]
}

#let render-area(text-fill, content) = {
    pad(y: 20pt, left: 20pt, right: 14pt, [
      #set text(
        font: font,
        fill: text-fill,
        size: 12pt
      )
      #content
    ])
}

#let resume-page = (
  sidebar: none,
  main
) => {
  context {
    set page("a4", margin: 0pt, fill: get-background-color())
    resume-layout(
      base-color: get-background-color(),
      color: get-accent-color(),
      sidebar: if sidebar != none {
        render-area(detect-text-color(get-accent-color()), sidebar)
      } else {
        none
      },
      render-area(detect-text-color(get-background-color()), main)
    )
  }
}
