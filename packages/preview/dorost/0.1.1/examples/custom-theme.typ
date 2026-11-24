#import "@preview/dorost:0.1.1": document

#show: document.with(
  lang: "en",
  direction: "ltr",
  page: (paper: "a4", margin: (x: 24mm, y: 22mm)),
  fonts: (body: "Lora", code: "JetBrains Mono"),
  text: (size: 11.5pt, paragraph-spacing: 0.8em),
  colors: (text: rgb("20212B"), accent: rgb("A13D63")),
)

= Your visual choices

Override only the settings you want. Omitted config roles keep the Dorost defaults.
