# keyle

<p align="center">
  <a href="https://raw.githubusercontent.com/magicwenli/keyle/main/doc/keyle.pdf">
    <img alt="Documentation" src="https://img.shields.io/website?down_message=offline&label=manual&up_color=007aff&up_message=online&url=https://raw.githubusercontent.com/magicwenli/keyle/main/doc/keyle.pdf" />
  </a>
  <a href="https://github.com/magicwenli/keyle/blob/main/LICENSE">
    <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-brightgreen">
  </a>
</p>

A simple way to style keyboard shortcuts in your documentation.

This package was inspired by [auth0/kbd](https://auth0.github.io/kbd/) and [dogezen/badgery](https://github.com/dogezen/badgery). Also thanks to [tweh/menukeys](https://github.com/tweh/menukeys) -- A LaTeX package for menu keys generation.

Document generating using [jneug/typst-mantys](https://github.com/jneug/typst-mantys).

Send them respect and love.

## Usage

Please see the [keyle.pdf](https://github.com/magicwenli/keyle/blob/main/doc/keyle.pdf) for more documentation.

`keyle` is imported using:

```typst
#import "@preview/keyle:0.2.0"
```

### Example

#### Custom Delimiter

```tpy
#let kbd = keyle.config()
#kbd("Ctrl", "Shift", "K", delim: "-")
```
![Custom Delimiter](test/test-1.png)

#### Compact Mode

```tpy
#let kbd = keyle.config()
#kbd("Ctrl", "Shift", "K", compact: true)
```
![Compact Mode](test/test-2.png)

#### Standard Theme

```tpy
#let kbd = keyle.config(theme: keyle.themes.standard)
#keyle.gen-examples(kbd)
```
![Standard Theme](test/test-3.png)

#### Deep Blue Theme

```tpy
#let kbd = keyle.config(theme: keyle.themes.deep-blue)
#keyle.gen-examples(kbd)
```
![Deep Blue Theme](test/test-4.png)

#### Type Writer Theme

```tpy
#let kbd = keyle.config(theme: keyle.themes.type-writer)
#keyle.gen-examples(kbd)
```
![Type Writer Theme](test/test-5.png)

#### Biolinum Theme

```tpy
#let kbd = keyle.config(theme: keyle.themes.biolinum, delim: keyle.biolinum-key.delim_plus)
#keyle.gen-examples(kbd)
```
![Biolinum Theme](test/test-6.png)

#### Custom Theme

```tpy
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
#keyle.gen-examples(kbd)
```
![Custom Theme](test/test-7.png)

## License

MIT
