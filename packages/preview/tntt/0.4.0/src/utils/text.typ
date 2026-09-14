/// Make text processing functions available for content.
///
/// - fn (function): the function to apply to the text
/// - body (content | str): the text content to process
/// - args (any): additional arguments to pass to the function
/// -> any
#let _use-content(fn, body, ..args) = {
  if type(body) == content { fn(body.text, ..args) } else {
    assert(type(body) == str, message: "Expected content or string, got " + str(type(body)))
    fn(body, ..args)
  }
}

/// Replace all characters in a string with a mask character.
///
/// - text (str): the text to be masked
/// - mask (str): the character to use as a mask
/// -> str
#let _mask-text(text, mask: "█") = mask * text.clusters().len()

#let mask-text(body, ..args) = _use-content(_mask-text, body, ..args)

/// Space out characters in a string with a specified spacing.
///
/// - text (str): the text to space out
/// - space (str): the space to use between characters
/// -> str
#let _space-text(text, space: " ") = text.split("").join(space).trim()

#let space-text(body, ..args) = _use-content(_space-text, body, ..args)

/// Create a text block with distributed text.
///
/// - text (str): the text to distribute
/// - width (length): the width of the block, defaults to auto
/// -> content
#let _distr-text(text, width: auto) = {
  block(
    width: width,
    stack(dir: ltr, ..text.clusters().intersperse(1fr)),
  )
}

#let distr-text(body, ..args) = _use-content(_distr-text, body, ..args)
