A simple package to keep your secrets.

#let redact(text, fill: black, height: 0.68em) = {
  box(fill: fill, height: height, hide(text))
}

Example:
  - Unredacted text
  - Redacted #redact("text")

