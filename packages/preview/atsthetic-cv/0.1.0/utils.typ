#import "@preview/octique:0.1.1": *
#import "@preview/uniwarn:0.1.1" as uniwarn

#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    to-string(content.text)
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content.has("child") {
    to-string(content.child)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

#let namespace = "ams-cv"

#uniwarn.register-namespace(namespace)

#let warn = uniwarn.warning.with(
  namespace: namespace,
  prefix: "[" + namespace + "] ",
)
