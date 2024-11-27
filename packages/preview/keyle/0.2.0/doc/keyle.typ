#import "@preview/mantys:0.1.4": *
// Vendored because of https://github.com/jneug/typst-mantys/pull/20
#let cmdref(name) = {
  link(cmd-label(name), cmd-(name))
}
// End Vendored

#import "../src/keyle.typ"

#let lib-name = package[keyle]
#show: mantys.with(..toml("../typst.toml"), date: datetime.today(), examples-scope: (keyle: keyle))

#show link: underline
#set text(font:("Linux Libertine", "Liberation Serif"))

// end of preamble

= About

#lib-name is a library that allows you to create HTML `<kbd>` like keyboard shorts simple and easy.

The name, `keyle`, is a combination of `key` and `theme`.

This project is inspired by #link("http://github.com/auth0/kbd")[auth0/kbd] and #link("https://github.com/dogezen/badgery")[dogezen/badgery].
Send them respect!

= Usage

== Importing

#lib-name is imported using

#codesnippet[```typ
    #import "@preview/keyle:0.2.0"
  ```]

== Quick Start

Generate a keyboard renderer with #cmdref("config") function. Section @available-themes lists available themes.

#example(```typst
#let kbd = keyle.config()
#kbd("Ctrl","Shift","Alt","Del")

#let kbd = keyle.config(
  theme: keyle.themes.biolinum,
  delim: keyle.biolinum-key.delim_plus
)
#kbd("Ctrl", "Shift", "Alt", "Del")
```)

There are `compact` and `delim` options to make the output more compact and change the delimiter between keys.

You can either use them in #cmdref("config") function or directly in generated `kbd` function.

#example(```typst
#let kbd = keyle.config(compact: true, delim: "-")
#kbd("Ctrl", "Shift", "Alt", "Del")

#let kbd = keyle.config()
#kbd("Ctrl", "Shift", "Alt", "Del", compact: true, delim: "-")
```)

= Themes

== Built-in Themes <available-themes>

Themes function are available at `#keyle.themes` dictionary.

#grid(columns: (2fr, 1fr), rows: 2em,align: horizon, ..keyle.themes.pairs().map(item => {
    let theme = item.at(0)
    let func = item.at(1)
    (
      raw(lang: "typst", "#keyle.themes." + theme),
      [#let kbd = keyle.config(theme: func)
        #kbd("Home")],
    )

  }).flatten())

== Custom Themes

You can create your own theme by defining a function that takes a string and returns a themed content.

#example(```typst
// https://www.radix-ui.com/themes/playground#kbd
#let radix_kdb(content) = box(
  rect(
    inset: (x: 0.5em),
    outset: (y:0.05em),
    stroke: rgb("#1c2024") + 0.3pt,
    radius: 0.35em,
    fill: rgb("#fcfcfd"),
    text(fill: black, font: (
      "Roboto",
      "Helvetica Neue",
    ), content),
  ),
)
#let kbd = keyle.config(theme: radix_kdb)
#kbd("⌘ D") #kbd("^ F") 
```)

= Symbols

== Mac Keyboard Symbols

#lib-name provides symbols for Mac keyboard. You may need install `Fira Code` font to see the symbols correctly.

- #link("https://fonts.google.com/specimen/Fira+Code?preview.text=%E2%8C%98%E2%87%A7%E2%8C%A5%E2%8C%83%E2%86%A9&query=fira+code")[Fira Code \@ Google Fonts]
- #link("https://support.apple.com/en-hk/guide/mac-help/cpmh0011/mac")[Apple Mac Keyboard Symbols]

#example(```typst
#let mac-key = keyle.mac-key
#let kbd = keyle.config(theme: keyle.themes.standard)
#let mac-key-font = (
  "Fira Code",
  "FiraCode",
  "FiraCode Nerd Font Mono",
)
#grid(
  columns: (2fr, 1fr, 2fr, 1fr),
  rows: 2em,
  align: horizon,
  ..mac-key.pairs().map(item => (
    raw("#mac-key." + item.at(0)),
    kbd(
      text(font: mac-key-font, item.at(1))
    ),
  )).flatten()
)
```)

== Linux Biolinum Keyboard Symbols

#lib-name provides symbols for Linux Biolinum Keyboard font.

- #link("https://libertine-fonts.org/")[Linux Biolinum Keyboard]

#example(```typst
#let biolinum-key = keyle.biolinum-key
#let kbd = keyle.config(theme: keyle.themes.biolinum)
#grid(
  columns: (5fr, 3fr, 5fr, 3fr),
  rows: 2em,
  align: horizon,
  ..biolinum-key.pairs().map(item => (
    raw("#biolinum-key." + item.at(0)),
    kbd(item.at(1)),
  )).flatten()
)
```)

= Available commands

#tidy-module(read("../src/keyle.typ"), name: "keyle", include-example-scope: true)
