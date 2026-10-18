#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#let code_setup(body) = {
  show: codly-init
  codly(languages: codly-languages)
  body
}
