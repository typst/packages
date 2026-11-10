// mrbogo-cv - Cover Letter Template
// Unified entry point with language and letter parameterization
// Usage: typst compile --input lang=en --input letter=example letter.typ output.pdf

#let lang = sys.inputs.at("lang", default: "en")
#let letter-file = sys.inputs.at("letter", default: "example")

#import "@preview/mrbogo-cv:1.0.5": *
#import "content/" + lang + "/profile.typ": author
#import "content/letters/" + letter-file + ".typ": recipient, letter-body

#set text(lang: lang)

#show: letter.with(
  author: author,
  accent-color: color-primary,
  header-text-color: color-dark,
  profile-picture: image("assets/profile.png"),
  recipient: recipient,
)

#letter-body
