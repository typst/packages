// Built-in theme color palette
// Maps theme names to their corresponding RGB color values
#let _theme-colors = (
  bluey: rgb("3059AB"),
  reddy: rgb("BF3D3D"),
  greeny: rgb("28842F"),
  yelly: rgb("C4853D"),
  purply: rgb("862A70"),
  dusky: rgb("1F4289"),
  darky: black,
)

//************************************************************************\\

// Automatically resizes text to fit within available space
// Used primarily in focus slides to ensure content fits properly
//
// Arguments:
//   body: The content to be resized
//
// Returns: A block with dynamically adjusted font size
#let _resize-text(body) = layout(size => {
  let font-size = text.size
  let (height,) = measure(
    block(width: size.width, text(size: font-size)[#body]),
  )

  let max_height = size.height

  while height > max_height {
    font-size -= 0.2pt
    height = measure(
      block(width: size.width, text(size: font-size)[#body]),
    ).height
  }

  block(
    height: height,
    width: 100%,
    text(size: font-size)[#body],
  )
})

//************************************************************************\\

// Simple horizontal divider line without progress indication
// Used in the front slide to maintain a clean appearance
//
// Arguments:
//   color: The color of the divider line
//
// Returns: A horizontal line element
#let _divider(color: none) = {
  line(
    length: 100%,
    stroke: 2.5pt + color,
  )
}

//************************************************************************\\

// Progress-aware horizontal divider
// Displays a two-tone bar showing presentation progress
// Left portion (solid color) represents completed slides
// Right portion (lightened color) represents remaining slides
//
// Arguments:
//   color: The base color for the progress divider
//
// Returns: A horizontal stack with progress indication
#let _progress-divider(color: none) = context {
  let current = counter(page).get().first()
  let total = counter(page).final().first()
  let progress-width = if total == 0 { 0% } else { (current / total) * 100% }

  stack(
    dir: ltr,
    rect(
      width: progress-width,
      height: 2.5pt,
      fill: color,
      radius: 0pt,
    ),
    rect(
      width: 100% - progress-width,
      height: 2.5pt,
      fill: color.lighten(60%),
      radius: 0pt,
    ),
  )
}

//************************************************************************\\

// Bottom progress bar overlay for slides
// Creates a Beamer-style progress indicator at the bottom of slides
// Uses a subtle background with a solid foreground showing progress
//
// Arguments:
//   color: Color for the progress indicator (default: black)
//   height: Height of the progress bar (default: 3pt)
//
// Returns: Two overlaid rectangles positioned at the bottom of the slide
#let _progress-bar(color: black, height: 3pt) = context {
  let current = counter(page).get().first()
  let total = counter(page).final().first()
  let progress-width = if total == 0 { 0% } else { (current / total) * 100% }

  // Background bar
  place(bottom + left, rect(
    width: 100%,
    height: height,
    fill: rgb(200, 200, 200, 25%),
  ))

  // Progress indicator
  place(bottom + left, rect(
    width: progress-width,
    height: height,
    fill: color,
  ))
}

//************************************************************************\\

// Creates a colored header box for slides
// Dynamically adjusts height based on whether a title is present
// Supports outline mode to mark subsections in the table of contents
//
// Arguments:
//   title: The slide title text (optional)
//   outlined: Whether this slide should appear in the outline (default: false)
//   color: Background color for the header
//   page-num: Page number to display in the header (optional)
//
// Returns: A colored rectangle containing the formatted title and page number
#let _slide-header(title, outlined, color, page-num: none) = {
  let header-height = if title != none { 1.6cm } else { .95cm }

  rect(
    fill: color,
    width: 100%,
    height: header-height,
    inset: .6cm,
    if outlined {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        text(white, weight: "semibold", size: 24pt)[
          #h(.1cm) #title #metadata(title) <subsection>
        ],
        if page-num != none {
          text(white, weight: "semibold", size: 12pt)[#page-num]
        },
      )
    } else if title != none {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        text(white, weight: "semibold", size: 24pt)[
          #h(.1cm) #title
        ],
        if page-num != none {
          text(white, weight: "semibold", size: 12pt)[#page-num]
        },
      )
    },
  )
}

//************************************************************************\\

// Generates the front page layout for presentations
// Displays title, subtitle, author information, and a divider
// Uses a simple divider (without progress) to maintain clean aesthetics
//
// Arguments:
//   title: Main presentation title
//   subtitle: Optional subtitle text
//   authors: Author name(s)
//   info: Additional information (e.g., links, dates)
//   theme-color: Color for styling text and divider
//
// Returns: A formatted front page with all provided information
#let _make-frontpage(
  title,
  subtitle,
  authors,
  info,
  theme-color,
) = {
  set align(left + horizon)
  set page(footer: none)

  text(40pt, weight: "bold")[#smallcaps(title)]
  v(-.95cm)

  if subtitle != none {
    set text(24pt)
    v(.1cm)
    subtitle
  }

  let subtext = ()

  if authors != none {
    subtext.push(text(22pt, weight: "regular")[#authors])
  }

  if info != none {
    subtext.push(text(20pt, fill: theme-color, weight: "regular")[
      #v(-.15cm) #info
    ])
  }

  _divider(color: theme-color)
  subtext.join()
}
