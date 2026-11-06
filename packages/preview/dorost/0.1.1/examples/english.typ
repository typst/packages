#import "@preview/dorost:0.1.1": document

#show: document.with(lang: "en", direction: "ltr")

= English document

Compose this as a normal Typst document. Dorost provides page and typography defaults, and the author owns the structure.

== Native elements

- lists stay native
- tables stay native

#table(
  columns: 2,
  [Role], [Value],
  [Language], [English],
  [Direction], [Left to right],
)

Inline code: `API.get(2)`. Math: $f(x) = x^2$.
