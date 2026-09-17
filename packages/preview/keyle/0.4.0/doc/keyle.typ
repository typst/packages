#import "@preview/tidy:0.4.3"
#import "@preview/codelst:2.0.2": sourcecode
#import "/src/keyle.typ"

#let meta = toml("/typst.toml").package
#let accent = rgb("#1f6feb")

#set document(title: meta.name + " manual", author: meta.authors, date: none)
#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2.4cm),
  footer: context if counter(page).get().first() > 1 [
    #set text(size: 8pt, fill: luma(120))
    #meta.name v#meta.version
    #h(1fr)
    #counter(page).display("1")
  ],
)
#set text(size: 10pt, font: ("Libertinus Serif", "Linux Libertine", "TeX Gyre Pagella"))
#set heading(numbering: (..nums) => if nums.pos().len() <= 3 { numbering("1.1", ..nums) })
#show heading: set text(font: ("TeX Gyre Heros", "Helvetica Neue"))
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(fill: accent, it))
#show link: underline
#show raw.where(block: false): box.with(
  fill: luma(246),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

#let lib-name = smallcaps(meta.name)
#let example-scope = (keyle: keyle, kbd: keyle.kbd)

/// Render a source block next to its evaluated result. Wide results
/// (e.g. symbol tables) read better with `vertical: true`.
#let example(source, vertical: false) = {
  let result = block(
    width: 100%,
    inset: 10pt,
    stroke: 0.4pt + luma(200),
    radius: 4pt,
    fill: luma(252),
    eval(source.text, mode: "markup", scope: example-scope),
  )
  block(
    breakable: vertical,
    if vertical {
      stack(spacing: 0.8em, sourcecode(source, lang: "typ"), result)
    } else {
      grid(
        columns: (3fr, 2fr),
        column-gutter: 1em,
        align: (top, horizon),
        sourcecode(source, lang: "typ"), result,
      )
    },
  )
}

/// Display-only code snippet.
#let codesnippet(source) = block(breakable: false, sourcecode(source, lang: "typ"))

// --- Title ---------------------------------------------------------------

#align(center)[
  #v(1.2cm)
  #text(size: 28pt, font: ("TeX Gyre Heros", "Helvetica Neue"), weight: "bold")[#meta.name]
  #v(0.2em)
  #text(size: 12pt)[v#meta.version]

  #v(0.8em)
  #meta.description

  #v(0.4em)
  #link(meta.repository) #h(1em) MIT License

  #v(1em)
  #{
    let kbd = keyle.config(theme: "flowbite")
    kbd("Ctrl", "Shift", "P")
  }
]

#v(1cm)
#outline(depth: 2, indent: auto)
#pagebreak()

= About

#lib-name is a library that allows you to create HTML `<kbd>` like keyboard shortcuts simple and easy.

The name, `keyle`, is a combination of `key` and `theme`.

This project is inspired by #link("http://github.com/auth0/kbd")[auth0/kbd] and #link("https://github.com/dogezen/badgery")[dogezen/badgery].
Send them respect!

= Usage

== Importing

#lib-name is imported using

#codesnippet(```typ
#import "@preview/keyle:0.4.0"
```)

== Quick Start

The default renderer works out of the box:

#codesnippet(```typ
#import "@preview/keyle:0.4.0": kbd
```)

#example(```typ
#kbd("Ctrl", "Shift", "P")

#kbd("Ctrl+Shift+P")
```)

For customization, generate your own renderer with the `config` function (see @reference). @available-themes lists available themes; a theme can be given by name or as a function.

#example(```typ
#let kbd = keyle.config(theme: "flowbite")
#kbd("Ctrl","Shift","Alt","Del")

#let kbd = keyle.config(
  theme: keyle.themes.biolinum,
  delim: keyle.biolinum-key.delim_plus
)
#kbd("Ctrl", "Shift", "Alt", "Del")
```)

There are `compact` and `delim` options to make the output more compact and change the delimiter between keys.

You can either use them in the `config` function or directly in the generated `kbd` function.

#example(```typ
#let kbd = keyle.config(compact: true, delim: "-")
#kbd("Ctrl", "Shift", "Alt", "Del")

#let kbd = keyle.config()
#kbd("Ctrl", "Shift", "Alt", "Del", compact: true, delim: "-")
```)

== Shortcut Strings

Strings containing `+` are split into individual keys, so a whole shortcut can
be pasted as one argument. A lone `+` (or a string where splitting would
produce an empty part) is kept literal -- pass a plus key as its own argument.
Set `parse: false` in `config` to disable splitting entirely.

#example(```typ
#kbd("Ctrl+Shift+P") \
#kbd("Ctrl", "+") #kbd("+")
```)

== Key Aliases and the Mac Layout

Key names are normalized case-insensitively through an alias table. By default
only unambiguous names are mapped (`cmd`/`command` #sym.arrow ⌘,
`opt`/`option` #sym.arrow ⌥, `up`/`down`/`left`/`right` #sym.arrow arrows), so
`Ctrl`, `Alt` and friends render exactly as written.

#example(```typ
#kbd("cmd", "shift", "P")
#kbd("up") #kbd("down") #kbd("left") #kbd("right")
```)

With `layout: "mac"` every common key name maps to its Apple glyph
(`ctrl` #sym.arrow ⌃, `shift` #sym.arrow ⇧, `enter` #sym.arrow ↩,
`esc` #sym.arrow ⎋, ...).

#example(```typ
#let mac = keyle.config(layout: "mac", delim: none)
#mac("cmd+shift+P") #h(1em)
#mac("Ctrl", "Alt", "Del") #h(1em)
#mac("enter") #mac("esc") #mac("tab")
```)

Set `normalize: false` in `config` to switch normalization off.

== HTML Export

Under Typst's HTML export (`typst compile --features html`), the generated
renderer adapts automatically; PDF/PNG/SVG output is unaffected. The `html`
option of `config` selects the mode:

- `"frame"` (default): embeds the exact themed rendering as inline SVG via `html.frame`.
- `"kbd"`: emits semantic `<kbd>` elements, styled by the browser or your CSS.
- `none`: passes the themed content through unchanged.

#codesnippet(```typ
#import "@preview/keyle:0.4.0": kbd
Press #kbd("Ctrl+Shift+P") to open the command palette.

#let sem = keyle.config(html: "kbd")
Copy with #sem("Ctrl", "C").  // -> <kbd>Ctrl</kbd>+<kbd>C</kbd>
```)

= Themes

== Built-in Themes <available-themes>

Theme functions are available in the `keyle.themes` dictionary, or by name in `config`.

#grid(
  columns: (2fr, 1fr),
  rows: 2em,
  align: horizon,
  ..keyle
    .themes
    .pairs()
    .map(item => {
      let name = item.at(0)
      let func = item.at(1)
      (
        raw(lang: "typ", "#keyle.config(theme: \"" + name + "\")"),
        [#let kbd = keyle.config(theme: func)
          #kbd("Home")],
      )
    })
    .flatten(),
)

== Custom Themes

You can create your own theme by defining a function that takes a symbol and returns themed content.

#example(```typ
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

== Extending a Theme with `.with()`

Every built-in theme is a `keycap` or `svg-keycap` factory with its style
pre-bound. Because they are ordinary functions, you extend any of them using
Typst's native `.with(..)`, without learning a bespoke override API. The text
layer (`text-args`, `wrap`) and the cap layer (`fill`, `stroke`, `radius`,
`raise`, ...) stay separate.

#example(```typ
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

#lib-name provides symbols for Mac keyboards. You may need to install the `Fira Code` font to see the symbols correctly.

- #link("https://fonts.google.com/specimen/Fira+Code?preview.text=%E2%8C%98%E2%87%A7%E2%8C%A5%E2%8C%83%E2%86%A9&query=fira+code")[Fira Code \@ Google Fonts]
- #link("https://support.apple.com/en-hk/guide/mac-help/cpmh0011/mac")[Apple Mac Keyboard Symbols]

#example(vertical: true, ```typ
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

#lib-name provides symbols for the Linux Biolinum Keyboard font.

- #link("https://libertine-fonts.org/")[Linux Biolinum Keyboard]

#example(vertical: true, ```typ
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

#example(```typ
#let kbd = keyle.config(theme: keyle.themes.flowbite)
#kbd(keyle.svg-key.up) #kbd(keyle.svg-key.down)
#kbd(keyle.svg-key.left) #kbd(keyle.svg-key.right)
#kbd(keyle.svg-key.enter) #kbd(keyle.svg-key.backspace)
#kbd(keyle.svg-key.tab) #kbd(keyle.svg-key.win)
```)

= Reference <reference>

#let tidy-style = tidy.styles.default
#let show-module(path, name) = {
  let docs = tidy.parse-module(read(path), name: name, scope: example-scope)
  tidy.show-module(
    docs,
    style: tidy-style,
    sort-functions: none,
    first-heading-level: 2,
    omit-private-definitions: true,
    omit-private-parameters: true,
  )
}

#show-module("/src/keyle.typ", "keyle")
#show-module("/src/cap.typ", "cap")
