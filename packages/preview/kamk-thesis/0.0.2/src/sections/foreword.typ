// Load the translations
#let lang-data = toml("../data/lang.toml")

// Alkusanat / Foreword page; only rendered when the author supplies content.
#let render-foreword(language: "fi", body) = {
  heading(level: 1, outlined: false, strong(lang-data.at(language).foreword))
  body
}
