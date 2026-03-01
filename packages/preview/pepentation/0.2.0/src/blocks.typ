/// Styles inline code blocks with a background color.
///
/// This is an internal helper function that applies styling to raw code blocks.
///
/// # Parameters
/// - `code-background` (color): Background color for inline code.
/// - `code-text` (color or none): Text color for inline code (optional).
/// - `content` (content): The content to style.
///
/// # Returns
/// A styled box containing the content.
#let _style-raw(code-background: color, code-text: none, content: none) = {
  let styled-content = if code-text != none {
    text(fill: code-text, content)
  } else {
    content
  }
  box(
    fill: code-background,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 5pt,
    styled-content
  )
}

/// Helper to calculate code background for blocks.
///
/// For dark themes: lighten block color to create lighter code background.
/// For light themes: darken block color to create darker code background.
#let _block-code-background(base-code-bg, block-color, is-dark-theme) = {
  if is-dark-theme {
    block-color.rgb().lighten(30%).transparentize(50%)
  } else {
    block-color.rgb().darken(20%).transparentize(50%)
  }
}

/// Creates a styled presentation block with a colored background.
///
/// This is an internal helper function that creates the base styling for
/// presentation blocks (definition, warning, remark, hint, info, example, quote, success, failure).
/// It retrieves theme state internally to determine colors and styling.
///
/// # Parameters
/// - `block-type` (str): The type of block (e.g., "definition", "warning").
/// - `content` (content): The content to display in the block.
///
/// # Returns
/// A styled box containing the content with appropriate background and padding.
#let _presentation-block(block-type: str, content: none) = context {
  let theme = state("pepentation-theme").get()
  let block-color = theme.blocks.at(block-type + "-color")
  let base-code-bg = theme.code-background
  let code-text = theme.code-text
  let is-dark = theme.dark
  let block-code-bg = _block-code-background(base-code-bg, block-color, is-dark)
  show raw.where(block: false): it => _style-raw(code-background: block-code-bg, code-text: code-text, content: it.text)
  box(
    fill: block-color.transparentize(50%),
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
#let definition(content) = context {
  _presentation-block(block-type: "definition", content: content)
}

/// Creates a warning block with red background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let warning(content) = context {
  _presentation-block(block-type: "warning", content: content)
}

/// Creates a remark block with orange background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let remark(content) = context {
  _presentation-block(block-type: "remark", content: content)
}

/// Creates a hint block with green background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let hint(content) = context {
  _presentation-block(block-type: "hint", content: content)
}

/// Creates an info block with blue background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let info(content) = context {
  _presentation-block(block-type: "info", content: content)
}

/// Creates an example block with purple background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let example(content) = context {
  _presentation-block(block-type: "example", content: content)
}

/// Creates a quote block with neutral gray background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let quote(content) = context {
  _presentation-block(block-type: "quote", content: content)
}

/// Creates a success block with green background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let success(content) = context {
  _presentation-block(block-type: "success", content: content)
}

/// Creates a failure block with red background.
///
/// This function is re-exported in `lib.typ` with full documentation.
/// See `lib.typ` for usage examples.
#let failure(content) = context {
  _presentation-block(block-type: "failure", content: content)
}
