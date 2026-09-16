#import "@preview/uuidkit:0.1.0": describe, canonical, is-uuid, v3, v5, named, namespaces

#set page(width: auto, height: auto, margin: 12pt)
#set text(font: "Libertinus Serif", size: 11pt)

#let raw = "cfbff0d1-9375-5685-968c-48ce8b15ae17"
#let parsed = describe(raw)

= uuidkit Example

#table(
  columns: (auto, 1fr),
  align: left,
  stroke: none,
  inset: 4pt,
  [Input], [#raw],
  [Valid], [#is-uuid(raw)],
  [Canonical], [#canonical(raw)],
  [Simple], [#parsed.simple],
  [URN], [#parsed.urn],
  [Version], [#parsed.version],
  [Variant], [#parsed.variant],
  [DNS v3], [#v3(namespaces.dns, "example.com")],
  [DNS v5], [#v5(namespaces.dns, "example.com")],
  [URL v5], [#named("https://typst.app", namespace: namespaces.url, version: 5)],
)
