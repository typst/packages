#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

/// Create a highlighted code block from a string; fences work automatically too.
#let codeblock(source, lang: "text") = raw(source, lang: lang, block: true)

#let show-code(body, accent: black) = {
  show: codly.theme("github-light", accent: accent)
  show: codly.set_(radius: 4pt, padding: 6pt, lang-position: top + right, breakable: false)
  show: codly.lang-set_(languages: codly-languages, display-name: true, display-icon: true)
  show raw.where(block: true): codly.new
  body
}
