#let left-to-right = ltr
#let right-to-left = rtl

#let default-fonts = (
  body: ("Lora", "Vazirmatn"),
  code: "JetBrains Mono",
)

#let default-page = (
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
)

#let default-text = (
  size: 11pt,
  leading: 0.65em,
  paragraph-spacing: 1em,
  list-indent: 0.6em,
  list-spacing: 0.6em,
)

#let default-colors = (
  text: rgb("202124"),
  muted: rgb("62666d"),
  accent: rgb("235789"),
  rule: rgb("d8dce2"),
)

#let merge-options(name, defaults, options) = {
  if type(options) != dictionary {
    panic("dorost: " + name + " must be a dictionary")
  }
  let unknown = options.keys().filter(key => not (key in defaults.keys()))
  if unknown.len() > 0 {
    panic("dorost: unknown " + name + " option(s): " + unknown.join(", "))
  }
  defaults + options
}

#let resolve-config(lang, direction, fonts, page, text, colors) = {
  if type(lang) != str or lang.trim().len() == 0 {
    panic("dorost: lang must be a non-empty string")
  }
  if direction != "ltr" and direction != "rtl" {
    panic("dorost: direction must be \"ltr\" or \"rtl\"")
  }
  let direction = if direction == "ltr" { left-to-right } else { right-to-left }
  let fonts = merge-options("fonts", default-fonts, fonts)
  let page = merge-options("page", default-page, page)
  let text = merge-options("text", default-text, text)
  let colors = merge-options("colors", default-colors, colors)
  (lang: lang, direction: direction, fonts: fonts, page: page, text: text, colors: colors)
}
