/// Styles inline code blocks with a background color.
///
/// This is an internal helper function that applies styling to raw code blocks
/// within presentation blocks.
///
/// # Parameters
/// - `color` (color or none): Optional color to mix with the default background.
/// - `content` (content): The content to style.
///
/// # Returns
/// A styled box containing the content.
#let _style-raw(color: none, content) = {
  let bg = luma(240)
  let fill = if color != none { bg.rgb().mix(color) } else { bg }
  box(
    fill: fill,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 5pt,
    content
  )
}

/// Creates a styled presentation block with a colored background.
///
/// This is an internal helper function that creates the base styling for
/// presentation blocks (definition, warning, remark, hint).
///
/// # Parameters
/// - `color` (color, default: `gray`): The main color for the block background.
/// - `raw-color` (color or none, default: `none`): Color for inline code blocks.
/// - `content` (content): The content to display in the block.
///
/// # Returns
/// A styled box containing the content with appropriate background and padding.
#let _presentation-block(color: gray, raw-color: none, content) = {
  let rc = if raw-color == none { color } else { raw-color }
  show raw.where(block: false): it => _style-raw(color: rc, it.text)
  box(
    fill: color.transparentize(80%),
    radius: 1em,
    outset: 0.5em,
    width: 100%,
    content
  )
}

/// Creates a definition block with gray background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let definition(content) = _presentation-block(color: gray, content)

/// Creates a warning block with red background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let warning(content) = _presentation-block(color: red, content)

/// Creates a remark block with orange background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let remark(content) = _presentation-block(color: orange, content)

/// Creates a hint block with green background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let hint(content) = _presentation-block(color: green, content)
