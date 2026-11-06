#let _p = plugin("./plugin.wasm")
#let render(
  markdown,
  smart-punctuation: true,
  blockquote: none,
  h1-level: 1,
  raw-typst: true,
  scope: (:),
  show-source: false,
) = {
  let options = 0;
  if smart-punctuation { options += 0b00000001; }
  if blockquote != none { options += 0b00000010; }
  if raw-typst { options += 0b00000100; }
  let rendered = str(_p.render(bytes(markdown), bytes((options, h1-level))))
  if show-source {
    raw(rendered, block: true, lang: "typ")
  } else {
    eval(rendered, mode: "markup", scope: (
      blockquote: blockquote,
      image: (..args) => image(..args),
      ..scope,
    ))
  }
}
