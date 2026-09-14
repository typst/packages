# Metropole

A Swiss Modernist document template for Typst. The design draws on the International Typographic Style: clean sans-serif headings, generous leading, a strong accent color, and no decoration that doesn't do work.

## Usage

```typst
#import "@preview/metropole-report:0.1.0": *

#show: metropole.with(
  title: "My Document",
  subtitle: "An Optional Subtitle",
  author: "Your Name",
  date: datetime.today(),
)

= First Section

Your content here.
```

An example document is available as a [.typ file](example/example.typ) and a [compiled PDF](example/example.pdf).

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `title` | `none` | Document title. Appears on the title block and in running headers. |
| `subtitle` | `none` | Document subtitle. Appears below the title in a lighter weight. |
| `author` | `none` | Author name. Appears on the title block and in running headers. |
| `date` | `none` | Publication date. Pass a `datetime` value, e.g. `datetime.today()` or `datetime(year: 2026, month: 1, day: 1)`. |
| `paper-size` | `"a4"` | Paper size. Any Typst paper size string, e.g. `"us-letter"`, `"a4"`. |
| `language` | `"en"` | Document language. Any ISO 639-1 code, e.g. `"de"`, `"fr"`. |
| `date-format` | `"[day] [month repr:long] [year]"` | Date format in Typst's [`datetime.display` syntax](https://typst.app/docs/reference/foundations/datetime/#format). |
| `cover-page` | `false` | When `true`, renders a full-page cover with the accent bar and title. When `false`, renders a compact inline title block at the top of the first content page. |
| `font-size` | `11pt` | Base font size. All other sizes and spacings derive from this value. |
| `leading-ratio` | `1.75` | Line height as a multiple of font size. Controls the baseline grid unit. `1.6`--`1.8` is appropriate for body text. |
| `body-font` | `"Source Serif 4"` | Font used for body text, captions, and quotes. |
| `heading-font` | `"Source Sans 3"` | Font used for headings, labels, headers, footers, and list markers. |
| `raw-font` | `"Source Code Pro"` | Font used for inline and block code. |
| `background-color` | `rgb("#ffffff")` | Page background color. |
| `foreground-color` | `rgb("#000000")` | Body text color. |
| `accent-color` | `transit-red` | Primary accent color. Used for heading rules, list markers, table headers, the title bar, and links. Six presets are provided -- see below. |

## Preset Accent Colors

Metropole exports six accent colors that can be passed directly to `accent-color`:

| Name | Value | Character |
|---|---|---|
| `transit-red` | `rgb(#c53a2f)` | Bold and authoritative. The default. |
| `metro-blue` | `rgb(#005f9e)` | Institutional and measured. |
| `deep-teal` | `rgb(#0f766e)` | Contemporary and composed. |
| `burnt-orange` | `rgb(#c96b2c)` | Warm and editorial. |
| `emerald` | `rgb(#1f7a4f)` | Precise and considered. |
| `deep-violet` | `rgb(#5a4fcf)` | Distinctive and unhurried. |

```typst
#import "@preview/metropole-report:0.1.0": *

#show: metropole.with(
  title: "My Document",
  accent-color: metro-blue,
)
```

## Default Fonts

Be default, Metropole uses three typefaces, all available under the SIL Open Font License:

- **Source Serif 4** — body text. A contemporary optical-size serif, designed for sustained reading. It pairs well with geometric and humanist sans-serifs and holds up at small sizes.
- **Source Sans 3** — headings, labels, and UI chrome. The sans companion to Source Serif. Its open apertures and neutral character make it well-suited to headings, captions, and running text at small sizes.
- **Source Code Pro** — inline and block code. A monospaced face designed to harmonise with Source Sans, from the same family.

To use different fonts, pass them as parameters:

```typst
#show: metropole.with(
  title: "My Document",
  body-font: "Libertinus Serif",
  heading-font: "IBM Plex Sans",
  raw-font: "IBM Plex Mono",
)
```

## License

Copyright © 2026 Haydn Trowell.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
