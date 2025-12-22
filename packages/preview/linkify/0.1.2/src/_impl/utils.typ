#let with-smartquote(src) = {
  {
    show "'": smartquote(double: false)
    show "\"": smartquote(double: true)
    src
  }
}
