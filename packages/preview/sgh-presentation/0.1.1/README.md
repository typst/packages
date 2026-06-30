# sgh-presentation

A presentation theme for [Touying](https://typst.app/universe/package/touying)
following the visual identity of the SGH Warsaw School of Economics (Szkoła
Główna Handlowa w Warszawie). The theme is bilingual — the SGH logo switches
between Polish and English depending on the document language (`pl` / `en`).

The standard font for SGH presentations is Lato (a free font developed in Poland
by Łukasz Dziedzic, available at <https://www.latofonts.com>). If Lato is not
installed, Typst falls back to a default font. On the Typst web app the font is
already available.

The full manual, a complete example presentation, and the matching SGH thesis
template are available in the project repository:
<https://github.com/piotr-m-kuszewski/Szablony_Typst_SGH>.

![Title slide of the example presentation produced with the theme](thumbnail.png)

## Usage

The theme builds on Touying, so import both packages:

```typst
#import "@preview/touying:0.7.4": *
#import "@preview/sgh-presentation:0.1.0": *

#set text(lang: "pl") // the SGH logo follows the language: "pl" or "en"

#show: sgh-presentation-theme.with(
  config-info(
    title: [Prezentacja],
    author: [Ijon Tichy],
    date: [Marzec 2026],
  ),
  // footer: [custom footer],
  // footer-progress: true,
  // aspect-ratio: "4-3",
)

#title-slide()

== A simple slide

Some text on the slide.

= Section

== Another slide

#focus-slide[Wake up!]
```

## Available functions

- `sgh-presentation-theme(...)` — the main theme (used with
  `#show: sgh-presentation-theme.with(...)`). Options include `aspect-ratio`,
  `align`, `header`, `header-right`, `footer`, `footer-right` and
  `footer-progress`.
- `title-slide(...)` — the title slide (SGH logo on the brand background).
- `slide(...)` — a regular content slide.
- `new-section-slide(...)` — a section-divider slide.
- `focus-slide[...]` — a full-bleed slide used to draw attention.

Slide structure follows Touying conventions: level-1 headings (`=`) start new
sections and level-2 headings (`==`) start new slides.

## License

MIT — see the [LICENSE](LICENSE) file.
