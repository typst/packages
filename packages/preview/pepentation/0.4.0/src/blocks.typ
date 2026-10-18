#import "themes.typ"

/// Styles inline code with a background chip.
///
/// = Parameters
/// - `code-background` (color): Background color for the code.
/// - `code-text` (color or none): Text color, or `none` to inherit.
/// - `content` (content): The content to style.
///
/// = Returns
/// The styled content.
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

/// Derives the chip background for code inside a block.
///
/// The block color is lightened on a dark theme and darkened on a light one.
///
/// = Parameters
/// - `block-color` (color): The block's color.
/// - `is-dark-theme` (bool): Whether the theme is dark.
///
/// = Returns
/// The derived background color.
#let _block-code-background(block-color, is-dark-theme) = {
  if is-dark-theme {
    block-color.rgb().lighten(30%).transparentize(50%)
  } else {
    block-color.rgb().darken(20%).transparentize(50%)
  }
}

/// Returns the inline-code background a block uses for its own code.
///
/// = Parameters
/// - `block-type` (str): The block type, e.g. `"warning"`.
/// - `theme` (dictionary): A resolved theme.
///
/// = Returns
/// The background color for inline code inside that block.
#let block-code-background(block-type, theme) = {
  _block-code-background(
    themes.color-at(theme, "blocks." + block-type + "-color"),
    theme.dark,
  )
}

/// Creates a presentation block with a colored background.
///
/// = Parameters
/// - `block-type` (str): The block type, e.g. `"definition"`.
/// - `content` (content): The content to display in the block.
///
/// = Returns
/// A styled box containing the content.
#let _presentation-block(block-type: str, content: none) = context {
  let theme = themes.theme-state.get()
  let block-color = themes.color-at(theme, "blocks." + block-type + "-color")
  let code-text = theme.code-text
  let block-code-bg = block-code-background(block-type, theme)
  show raw.where(block: false): it => _style-raw(code-background: block-code-bg, code-text: code-text, content: it.text)
  box(
    fill: block-color.transparentize(50%),
    radius: 1em,
    outset: 0.5em,
    width: 100%,
    content
  )
}

/// A definition block, re-exported from `lib.typ`.
#let definition(content) = context {
  _presentation-block(block-type: "definition", content: content)
}

/// A warning block, re-exported from `lib.typ`.
#let warning(content) = context {
  _presentation-block(block-type: "warning", content: content)
}

/// A remark block, re-exported from `lib.typ`.
#let remark(content) = context {
  _presentation-block(block-type: "remark", content: content)
}

/// A hint block, re-exported from `lib.typ`.
#let hint(content) = context {
  _presentation-block(block-type: "hint", content: content)
}

/// An info block, re-exported from `lib.typ`.
#let info(content) = context {
  _presentation-block(block-type: "info", content: content)
}

/// An example block, re-exported from `lib.typ`.
#let example(content) = context {
  _presentation-block(block-type: "example", content: content)
}

/// A quote block, re-exported from `lib.typ`.
#let quote(content) = context {
  _presentation-block(block-type: "quote", content: content)
}

/// A success block, re-exported from `lib.typ`.
#let success(content) = context {
  _presentation-block(block-type: "success", content: content)
}

/// A failure block, re-exported from `lib.typ`.
#let failure(content) = context {
  _presentation-block(block-type: "failure", content: content)
}
