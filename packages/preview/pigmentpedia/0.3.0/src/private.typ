/*
  File: private.typ
  Author: neuralpain
  Date Modified: 2025-01-08

  Description: Private functions shared by
  multiple modules, not accessible to the end
  user.
*/

#import "pigments.typ": *
#import "text-contrast.typ": get-contrast-color

#let pgmt-page-list-heading = [
  #link("https://typst.app/universe/package/pigmentpedia","pigmentpedia") by #link("https://github.com/neuralpain","neuralpain")
]

// color viewbox settings
#let colorbox = (radius: 100%, width: 100%, height: 1em)
#let colorbox-block-properties = (inset: 1em, radius: 10pt, width: 100%, spacing: 8mm)

// page setup for `pigmentpedia` view
#let pigmentpage = (
  paper: "a4",
  margin: (x: 1cm, top: 3cm, bottom: 2cm),
  foreground: none,
  background: none,
  header: align(center, text(11pt, pad(y: 3mm, pgmt-page-list-heading))),
  footer: text(
    11pt,
    [#h(1fr) Pigment Page #context counter(page).display("1") #h(1fr)],
  ),
)

#let group-divider-line = (
  stroke: (
    thickness: 1pt,
    paint: gradient.linear(..color.map.rainbow),
  ),
  length: 100%,
)

/// Page setup for `pigmentpedia`
///
/// - body (content): `pigmentpedia` pages data
/// - bg (color): The color of the page background. This is
///   used to choose a contrast color for the text based on
///   the background color.
/// -> content
#let pgmt-page-setup(body, bg: white) = {
  set page(
    ..pigmentpage,
    fill: bg,
    header: align(center)[
      #let svg-h = 5mm // logo height
      #if bg == white {
        image("../assets/logo/pigmentpedia-logo.png", height: svg-h); v(4mm)
      } else {
        text(11pt, pad(y: 4mm, pgmt-page-list-heading))
      }
    ],
  )
  counter(page).update(1)
  set text(size: 16pt, get-contrast-color(bg), font: "Libertinus Serif")
  set grid(gutter: 2em)
  body
}

/// Show the name of the scope selected to search from.
///
/// The search starts off in the top-level pigmentpedia and
/// then traverses through the sub-dictionaries to find the
/// correct names of the groups.
///
/// - scope (dictionary): The pigment group to reference.
/// - depth (dictionary): The group level being referenced.
/// - l (str): Text to place on the left side of the
///   pigment group name.
/// - r (str): Text to place on the right side of the
///   pigment group name.
/// - bg (color): The color of the page background. This is
///   used to choose a contrast color for the text based on
///   the background color.
/// -> content
#let get-pgmt-group-name(scope, depth: pigmentpedia, l: none, r: none, bg: white) = {
  for (a, b) in depth {
    if b == scope {
      [#l #pigment(get-contrast-color(bg),strong(a)) #r]
    } else if type(b) == "dictionary" {
      get-pgmt-group-name(scope, depth: b, l: l, r: r, bg: bg)
    }
  }
}

/// Error messages for pigmentpedia
#let pgmt-error = (
  not-a-color: {
    align(center + horizon)[
      #pigment(red)[
        `Error: Not a pigment.` \ \
        `Use 'view-pigments()'` \
        `for pigment groups.` \ \
        `Use 'rgb("#000000")'` \
        `to enter HEX codes.`
      ]
    ]
  },
  scope-is-color: {
    set page(fill: white)
    align(center + horizon)[
      #pigment(red)[
        `Error: 'scope' cannot be a pigment.` \ \
        `Please select a pigment group for 'scope'.`
      ]
    ]
  },
  not-a-pgmt-group: {
    set page(fill: white)
    align(center + horizon)[
      #pigment(red)[
        `Error: The selected item` \
        `is not a pigment group.` \ \
        `Use 'view-pigment()' to` \
        `view individual pigments.`
      ]
    ]
  },
)
