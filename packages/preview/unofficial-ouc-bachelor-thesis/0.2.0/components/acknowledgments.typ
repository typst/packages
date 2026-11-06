#import "@preview/pointless-size:0.1.2": zh

#let acknowledgments(body) = {
  pagebreak(weak: true)
  heading("致谢".clusters().join(h(.5em * 3)), numbering: none)
  body
}

