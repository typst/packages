/// Replace all characters in a string with a mask character.
///
/// - text (): the text to be masked
/// - mask (): the character to use as a mask
/// -> string
#let mask-text(text, mask: "█") = mask * text.clusters().len()

/// Space out characters in a string with a specified spacing.
///
/// - text (): the text to space out
/// - spacing (): the spacing to use between characters
/// -> string
#let space-text(text, spacing: " ") = text.split("").join(spacing).trim()
