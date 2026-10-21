/// Typesets a letter with a colored header band, a sender address,
/// a date, and a closing signature block.
///
/// The letter's content is passed as the `body` positional argument.
/// Header, sender, and signature are all optional. A multi-signature
/// closing is supported by passing an array of names or signature
/// blocks.
///
/// -> content
#let letter(
  /// Paper size of the letter.
  ///
  /// -> str
  paper: "a4",
  /// Sender address displayed at the top right of the page. If `none`,
  /// the address block is omitted.
  ///
  /// -> none | str | content
  sender-address: none,
  /// Recipient address displayed below the sender address. If `none`,
  /// the address block is omitted.
  ///
  /// -> none | str | content
  recipient-address: none,
  /// Date displayed below the recipient address. `auto` uses the
  /// current date, `none` omits it, and `datetime` values are shown in
  /// Typst's default date format. Pre-formatted strings and content
  /// are shown as-is.
  ///
  /// -> auto | datetime | str | content | none
  date: auto,
  /// Subject line displayed in bold above the letter's content.
  /// If `none`, the subject line is omitted.
  ///
  /// -> none | content
  subject: none,
  /// Closing signature(s). If an array is provided, the elements
  /// are laid out in a grid of up to three columns.
  ///
  /// -> none | str | content | array
  signature: none,
  /// Content displayed in the colored header band at the top of each
  /// page. If `none`, the band still renders with the selected
  /// background color.
  ///
  /// -> none | content
  header-band-content: none,
  /// Fill color of the colored header band.
  ///
  /// -> color
  header-band-background: oklch(95.6%, 0.005, 286deg),
  /// Height of the colored header band.
  ///
  /// -> length
  header-band-height: 2.8cm,
  /// Font used throughout the letter.
  ///
  /// -> str | array
  font: "Libertinus Serif",
  /// Font size of the letter's body.
  ///
  /// -> length
  font-size: 11.25pt,
  /// Spacing between lines of the letter's body.
  ///
  /// -> length
  leading: 0.715em,
  /// Spacing between paragraphs of the letter's body.
  ///
  /// -> length
  spacing: 1.3em,
  /// color used for links inside the letter.
  ///
  /// -> color
  link-font-color: oklch(62.3%, 0.064, 241deg),
  /// If `false` (default) the header band and its content are drawn on
  /// every page. If `true`, both are only drawn on the first page of
  /// multi-page letters.
  ///
  /// -> boolean
  first-page-header: false,
  /// The letter's content.
  ///
  /// -> content
  body,
) = {
  // Format the date if it is not given as content.
  if type(date) == datetime or date == auto {
    let instant = if date == auto { datetime.today() } else { date }
    date = instant.display()
  }

  let header-band-clearance = 1.75cm
  let x-margin = 3cm
  let bottom-margin = 3.3cm
  // If the header band is only drawn on the first page, the top margin
  // does not need to account for the band on subsequent pages. Otherwise,
  // the top margin must be increased to account for the band on every page.
  let top-margin = if first-page-header {
    bottom-margin
  } else {
    header-band-height + header-band-clearance
  }

  // Configure page and text properties.
  set page(
    paper: paper,
    margin: (
      top: top-margin,
      bottom: bottom-margin,
      x: x-margin,
    ),
    background: context {
      if not first-page-header or here().page() == 1 {
        place(
          top + left,
          rect(
            width: 100%,
            height: header-band-height,
            fill: header-band-background,
          ),
        )
        place(
          top + left,
          box(width: 100%, height: header-band-height, inset: (x: x-margin, y: 0pt))[
            #align(horizon)[#header-band-content]
          ]
        )
      }
    },
  )

  set par(
    justify: true,
    leading: leading,
    spacing: spacing,
    justification-limits: (
      tracking: (min: -0.0135em, max: 0.0135em),
      spacing: (min: 80%, max: 120%),
    ),
  )

  set text(
    font: font,
    size: font-size,
    number-type: "lining",
  )

  show link: set text(fill: link-font-color)

  // If the header band is only drawn on the first page, the top margin
  // of the first page must be increased to account for the band.
  if first-page-header { v(header-band-clearance, weak: false) }

  // Display the sender address, if any.
  if sender-address != none {
    set align(right)
    sender-address
  }

  // Display the recipient address, if any.
  if recipient-address != none {
    recipient-address
  }

  // Display the date, if any.
  if date != none {
    set align(right)
    // If the sender address is present but the recipient address is not,
    // add some vertical space before the date.
    if sender-address != none and recipient-address == none { v(0.6cm) }
    date
  }

  // Add the subject line, if any.
  if subject != none { strong(subject) }

  // Add the body text.
  body
  v(0.15cm)

  // Display signature(s). If signature is an array, display in a
  // grid with up to 3 columns. Otherwise, display as-is.
  if type(signature) == array {
    set par(justify: false)

    let count = signature.len()
    let ncols = 3

    // Split signatures into complete rows and remainder.
    let full-rows = calc.quo(count, ncols)
    let remainder = calc.rem(count, ncols)

    // Display full rows.
    if full-rows > 0 {
      grid(
        columns: (1fr,) * ncols,
        column-gutter: 2.2em,
        row-gutter: 2.25em,
        ..signature.slice(0, full-rows * ncols).map(n => align(center)[#n])
      )
    }

    // Display remaining signatures centered.
    if remainder > 0 {
      v(1em, weak: false)
      align(center)[
        #grid(
          columns: (auto,) * remainder,
          column-gutter: 2.25em,
          ..signature.slice(full-rows * ncols).map(n => align(center)[#n])
        )
      ]
    }
  } else {
    signature
  }
}
