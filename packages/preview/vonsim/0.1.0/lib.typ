#let init-vonsim(body) = {
  set raw(syntaxes: "vonsim.sublime-syntax")
  body
}

#let init-vonsim-with-theme(body) = {
  set raw(syntaxes: "vonsim.sublime-syntax", theme: "vonsim.tmTheme")
  body
}

#let background = rgb(41, 37, 36)
#let foreground = rgb(255, 255, 255)
