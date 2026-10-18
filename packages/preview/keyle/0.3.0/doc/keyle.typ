#import "@preview/mantys:1.0.2": *

#import "@preview/keyle:0.3.0"

#let doc-serif = ("Linux Libertine", "TeX Gyre Pagella")
#let doc-sans = ("TeX Gyre Heros", "Helvetica Neue")
#let doc-mono = ("FiraCode Nerd Font Mono", "Linux Libertine Mono")

#let doc-theme = create-theme(
  fonts: (
    serif: doc-serif,
    sans: doc-sans,
    mono: doc-mono,
  ),
  text: (font: doc-serif),
  heading: (font: doc-sans),
  code: (font: doc-mono),
)

#let lib-name = package[keyle]
#show: mantys(
  ..toml("../typst.toml"),
  title: [keyle],
  date: datetime.today(),
  theme: doc-theme,
  examples-scope: (
    scope: (keyle: keyle),
  ),
)

#show std.link: underline

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
    #import "@preview/keyle:0.3.0"
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

#grid(columns: (2fr, 1fr), rows: 2em, align: horizon, ..keyle.themes.pairs().map(item => {
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
    outset: (y: 0.05em),
    stroke: rgb("#1c2024") + 0.3pt,
    radius: 0.35em,
    fill: rgb("#fcfcfd"),
    text(fill: black, font: (
      "Helvetica Neue",
      "TeX Gyre Heros",
    ), content),
  ),
)
#let kbd = keyle.config(theme: radix_kdb)
#kbd("⌘ D") #kbd("^ F") 
```)

== Extending a Theme with #raw(".with()")

Every built-in theme is a #cmdref("keycap") or #cmdref("svg-keycap") factory
with its style pre-bound. Because they are ordinary functions, you extend any of
them using Typst's native #raw(".with(..)"), without learning a bespoke override
API. The text layer (`text-args`, `wrap`) and the cap layer (`fill`, `stroke`,
`radius`, `raise`, ...) stay separate.

#example(```typst
#let rose = keyle.themes.flowbite.with(
  fill: rgb("#fee2e2"),
  stroke: rgb("#fca5a5"),
  text-args: (fill: rgb("#991b1b"), weight: "bold"),
)
#let kbd = keyle.config(theme: rose)
#kbd("Ctrl", "Shift", "K")
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
  "FiraCode Nerd Font Mono"
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

== SVG Key Glyphs

A key symbol is just content, so non-textual keys can be passed as inline SVG
glyphs from `#keyle.svg-key`. Available names are `up`, `down`, `left`, `right`,
`enter`, `backspace`, `tab` and `win`.

#example(```typst
#let kbd = keyle.config(theme: keyle.themes.flowbite)
#kbd(keyle.svg-key.up) #kbd(keyle.svg-key.down)
#kbd(keyle.svg-key.left) #kbd(keyle.svg-key.right)
#kbd(keyle.svg-key.enter) #kbd(keyle.svg-key.backspace)
#kbd(keyle.svg-key.tab) #kbd(keyle.svg-key.win)
```)

= Available commands

#tidy-module("keyle", read("../src/keyle.typ"), scope: (keyle: keyle))

#tidy-module("cap", read("../src/cap.typ"), scope: (keyle: keyle))
