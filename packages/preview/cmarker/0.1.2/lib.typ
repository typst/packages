#let _p = plugin("./plugin.wasm")
#let render(
  markdown,
  smart-punctuation: true,
  blockquote: none,
  math: none,
  h1-level: 1,
  raw-typst: true,
  scope: (:),
  show-source: false,
) = {
  if type(markdown) == content and markdown.has("text") {
    markdown = markdown.text
  }
  let options = 0
  if smart-punctuation {
    options += 0b00000001
  }
  if blockquote != none {
    options += 0b00000010
    scope += (blockquote: blockquote)
  }
  if raw-typst {
    options += 0b00000100
  }
  if math != none {
    options += 0b00001000
    scope += (inlinemath: math.with(block: false), displaymath: math.with(block: true))
  }
  let rendered = str(_p.render(bytes(markdown), bytes((options, h1-level))))
  if show-source {
    raw(rendered, block: true, lang: "typ")
  } else {
    eval(rendered, mode: "markup", scope: scope)
  }
}
