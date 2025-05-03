#let gen-smart-pagebreak(
  always-skip-even: true,
  skip-with-page-blank: true,
) = {
  if always-skip-even == false {
    pagebreak(weak: true)
  } else if skip-with-page-blank == false {
    pagebreak(weak: true, to: "odd")
  } else {
    page(header: none, footer: none)[~]
  }
}