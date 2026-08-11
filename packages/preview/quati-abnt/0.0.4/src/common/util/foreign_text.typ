// # Text in foreign language. Texto em língua estrangeira.

// Text in foreign language must be emphasized in italics.
#let foreign_text = (
  lang: "en",
  region: "us",
  it,
) => emph(
  text(
    lang: lang,
    region: region,
    it,
  ),
)
