//! Text processing utilities

/// Extract text from content or return string as is.
///
/// - body (content, str): the text content to extract
/// -> str
#let _select-text(body) = if type(body) == content { body.text } else {
  assert(type(body) == str, message: "Expected content or string, got " + str(type(body)))
  body
}

/// Replace all characters in a string with a mask character.
///
/// - text (str): the text to be masked
/// - mask (str): the character to use as a mask
/// -> str
#let _mask-text(text, mask) = mask * text.clusters().len()

/// Replace all characters in a string with a mask character.
///
/// - body (content, str): the text to be masked
/// - mask (str): the character to use as a mask
/// -> str
#let mask-text(body, mask: "█") = _mask-text(_select-text(body), mask)

/// Space out characters in a string with a specified spacing.
///
/// - text (str): the text to space out
/// - space (str): the space to use between characters
/// -> str
#let _space-text(text, space) = text.split("").join(space).trim()

/// Space out characters in a string with a specified spacing.
///
/// - body (content, str): the text to space out
/// - space (str): the space to use between characters
/// -> str
#let space-text(body, space: " ") = _space-text(_select-text(body), space)

/// Create a text block with distributed text.
///
/// - text (str): the text to distribute
/// - width (length): the width of the block, defaults to auto
/// -> content
#let _distr-text(text, width) = block(width: width, stack(dir: ltr, ..text.clusters().intersperse(1fr)))

/// Create a text block with distributed text.
///
/// - body (content, str): the text to distribute
/// - width (length): the width of the block, defaults to auto
/// -> content
#let distr-text(body, width) = _distr-text(_select-text(body), width)

/// Create a vertical stack of text clusters, for CJK characters only.
///
/// - text (str): the text to stack
/// - spacing (length): the spacing between lines
/// -> content
#let _v-text(text, spacing) = stack(dir: ttb, ..text.clusters(), spacing: spacing)

/// Create a vertical stack of text clusters, for CJK characters only.
///
/// - body (content, str): the text to stack
/// - spacing (length): the spacing between lines
/// -> content
#let v-text(body, spacing: 3.6pt) = _v-text(_select-text(body), spacing)

/// Create a text block with fixed-width text by adjusting tracking,
/// only supports single-line text and width relative to font size.
///
/// - text (str): the text to adjust
/// - width (length): the target width
/// -> content
#let _fixed-text(str, width) = text(tracking: (width - str.clusters().len() * 1em) / (str.clusters().len() - 1), str)

/// Create a text block with fixed-width text by adjusting tracking,
/// only supports single-line text and width relative to font size.
///
/// - body (content, str): the text to adjust
/// - width (length): the target width
/// -> content
#let fixed-text(body, width) = _fixed-text(_select-text(body), width)
