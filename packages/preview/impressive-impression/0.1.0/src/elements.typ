#import "utils.typ": crop-image
#import "theme.typ": theme-helper

/// Create a dot rating component.
/// -> content
#let dot-ratings(
  /// Number of active dots to show
  /// -> int
  selected,
  /// Number of dots in total
  /// -> int
  total,
  /// Size of each dot (diameter)
  /// -> length
  size: 12pt,
  /// Spacing between dots
  /// -> length
  spacing: 5pt,
  /// Color of active dots
  /// -> color
  color-active: color.blue,
  /// Color of inactive dots
  /// -> color
  color-inactive: color.gray,
) = {
  let dots = ()

  for value in range(total) {
    let color = if value < selected { color-active } else { color-inactive }
    dots += (
      box(
        circle(
          radius: size / 2,
          fill: color,
        ),
      ),
    )
  }

  grid(
    columns: total,
    column-gutter: spacing,
    ..dots,
  )
}

/// Creates a little pill-shaped button with a label.
/// -> content
#let make-pill(
  /// Label for the pill
  /// -> content
  body,
  /// Theme dictionary to use for styling
  /// -> dictionary
  theme,
) = {
  let th = theme-helper(theme)

  let inner = box(
    body,
    ..th("aside-pill-box-inner"),
  )
  let outer = pad(
    inner,
    ..th("aside-pill-pad"),
  )
  box(outer)
}

/// Create a persona section with following features:
/// - Avatar image with rounded corners and stroke (optional)
/// - Name
/// - Pronouns (optional)
/// - Short description (optional)
///
/// -> content
#let make-aside-persona(
  /// Name of the person
  /// -> string
  name,
  /// Pronouns of the person (optional)
  /// -> string
  pronouns: none,
  /// Short description of the person (optional)
  /// -> string
  short-description: none,
  /// Avatar image (optional)
  /// -> image
  image: none,
  /// Theme dictionary to use for styling
  /// -> dictionary
  theme: none,
) = {
  let th = theme-helper(theme)

  let _profile-image = none
  if th("profile-image-enabled") and image != none {
    _profile-image = align(
      crop-image(
        image: image,
        size: th("profile-image-size"),
        radius: th("profile-image-radius"),
        stroke: th("profile-image-stroke"),
      ),
      center,
    )
  }

  let _pronouns = none
  if pronouns != none {
    _pronouns = align(
      center,
      text(pronouns, ..th("aside-pronouns-text")),
    )
  }

  [
    #{ if _profile-image != none {
      _profile-image
      v(-12pt)
    }}
    #heading(name, level: 1)
    #_pronouns

    #text(short-description, ..th("aside-short-description-text"))
  ]
}

/// Make a grid for use in aside sections using a given theme.
/// -> content
#let make-aside-grid(
  /// Number of columns in the grid
  /// -> int
  columns: none,
  /// Alignments for the grid items
  /// -> array[alignment]
  align: (center + horizon, left + horizon),
  /// Theme dictionary to use for styling
  /// -> dictionary
  theme: none,
  ..contents,
) = {
  assert(theme != none, message: "Theme must be provided for make-aside-grid")

  let th = theme-helper(theme)

  if columns == none or columns == 2{
    columns = (
      th("aside-grid-first-column-width"),
      1fr,
    )
  } else if columns == 3 {
    columns = (
      th("aside-grid-first-column-width"),
      auto,
      1fr,
    )
  }

  grid(
    columns: columns,
    column-gutter: 0.6em,
    row-gutter: 0.7em,
    align: align,
    ..contents,
  )
}

/// Lays out a main content block with a left column for title
/// -> content
#let make-main-content-block(
  /// Title of the block
  /// -> string
  title,
  /// Body content of the block
  /// -> content
  body,
  /// Optional supplementary text (e.g. place, institution)
  /// -> none | string
  supplement: none,
  /// Whether to render the title as a level 3 heading
  /// -> bool
  title-as-heading: true,
  /// Theme dictionary to use for styling
  /// -> dictionary
  theme: none,
) = {
  assert(theme != none, message: "Theme must be provided for make-main-content-block")
  let th = theme-helper(theme)

  if title-as-heading {
    title = heading(title, level: 3)
  } else {
    title = text(title, weight: "medium")
  }

  let rhs-top = grid(
    columns: (auto, 1fr),
    align: (left, right + horizon),
    title,
    [
      #set text(size: 9pt, weight: "medium", fill: th("faint-text-color"))
      #supplement
    ],
  )

  return [
    #rhs-top
    #v(-0.6em)
    #set par(justify: true)
    #body
  ]
}

/// Makes a grid that fits a timeline on the left side
#let make-main-content-block-with-timeline(
  /// Time for timeline. Can be span or single time.
  /// -> content | array[content]
  ///   - If array, it should be a 2-tuple of contents
  time,
  /// Title of the block
  /// -> string
  title,
  /// Body content of the block
  /// -> content
  body,
  /// Optional supplementary text (e.g. place, institution)
  /// -> none | string
  supplement: none,
  /// Whether to render the title as a level 3 heading
  /// -> bool
  title-as-heading: true,
  /// Theme dictionary to use for styling
  /// -> dictionary
  theme: none,

  timeline-width: 0.6cm,
  timeline-line-gap: 5pt,
  timeline-stroke: (
    thickness: 0.5pt,
    cap: "butt",
    dash: "solid",
  ),
) = {
  body = make-main-content-block(
    title,
    body,
    supplement: supplement,
    title-as-heading: title-as-heading,
    theme: theme,
  )
  let cells = ()

  // Timeline
  if type(time) == array {
    cells += (
      grid.cell(time.at(0), colspan: 3, align: bottom),
      grid.cell(body, rowspan: 3),
      [],
      grid.cell([], stroke: timeline-stroke),
      [],
      grid.cell(time.at(1), colspan: 3),
    )
  } else {
    // Single time
    cells += (
      grid.cell(time, colspan: 3),
      grid.cell(body, rowspan: 3),
      grid.cell([], colspan: 3),
      grid.cell([], colspan: 3),
    )
  }

  grid(
    columns: (timeline-width/2, 0pt, timeline-width/2, 1fr),
    rows: (1em, auto, 1em),
    column-gutter: 1em,
    row-gutter: (timeline-line-gap, timeline-line-gap, 0em),
    align: (center, center, center, left),

    ..cells
  )
}