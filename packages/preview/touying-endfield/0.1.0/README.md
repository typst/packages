# Touying Endfield Theme

A presentation theme for [Touying](https://github.com/touying-typ/touying) inspired by the art style of *Arknights: Endfield*, a video game by Hypergryph.

## Preview

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-1.png" alt="title page"></td>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-2.png" alt="outline page"></td>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-3.png" alt="subtitle page"></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-4.png" alt="content page with equations"></td>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-7.png" alt="content page with bullet points and enumerations"></td>
    <td><img src="https://raw.githubusercontent.com/leostudiooo/typst-touying-theme-endfield/main/img/page-8.png" alt="focus page"></td>
    <td></td>
  </tr>
</table>

## Features

- Clean, modern design with a focus on readability
- Inspired by the Endfield Industries visual style
- Support for three navigation modes: sidebar, mini-slides, or none
- Configurable fonts for CJK and Latin scripts
- Focus slide for highlighting key content
- Customizable color schemes

## Installation

Import the theme in your Typst document:

```typst
#import "@preview/touying-endfield:0.1.0": *
```

Or use the template to create a new project:

```bash
typst init @preview/touying-endfield:0.1.0 my-presentation
cd my-presentation
typst compile main.typ
```

## Usage

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-endfield:0.1.0": *

#show: endfield-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "none", // "sidebar", "mini-slides", or "none"
  config-info(
    title: [Presentation Title],
    subtitle: [Presentation Subtitle],
    author: [Author Name],
    date: [2026-01-01],
    institution: [Institution Name],
  ),
)

#title-slide()

#outline-slide()

= Section 1

== Slide 1

Your content here.

#focus-slide[
  Important message!
]
```

## Configuration

### Navigation Modes

- `"none"` (default): Clean slides without navigation
- `"sidebar"`: Left sidebar with section outline
- `"mini-slides"`: Top bar with mini slide previews

### Font Configuration

Use `config-fonts()` to customize fonts:

```typst
#show: endfield-theme.with(
  config-fonts(
    cjk-font-family: ("Source Han Sans",),
    latin-font-family: ("Helvetica",),
    lang: "zh",
    region: "cn",
  ),
)
```

## Example

See the `examples/` directory for complete examples in English and Chinese.

## Fonts

The theme works best with:
- **HarmonyOS Sans** (default, good for CJK)
- **Gilroy** (Can be used in focus slides for emphasis; commercial font)

## Known Issues

1. Unfortunately, the HarmonyOS Sans family has a non-standarized font stretch metadata, and typst would interpret the font weight "light" to use a condensed variant of the font, and italic style would also be affected. Bold renders correctly for now. You cannot fix this by using `#text(stretch: 100%)` since the condensed variant also has a `stretch: 1000` metadata. You may want to use `Source Sans` or `Source Han Sans` as an alternative, uninstall the condensed series, try a community workaround (https://github.com/typst/typst/issues/2917), or wait for an official fix from Typst in the future (https://github.com/typst/typst/issues/2098, still open by Feb 2026). Or, you can optimistically regard it as a feature of the font family.
2. Sidebar navigation does not work responsively (i.e. does not change outline depth or text size based on the number of slides, it *overflows*). Similar issue also exists for mini-slides, but you can customize like `mini-slides: (height: 3em)`. This is due to the limit of touying's built-in `custom-progressive-outline` and `mini-slides` components. Maybe in the future I can implement a more advanced version of these components to fix this. Any useful sugeggetions or PRs are welcome! But if you dont want the bother, just use `navigation: "none"`.
3. Also, the decoration bar of the title slide has a similar issue. Currently this can be fixed by setting a larger `title-height` in `config-store` when the title wraps to multiple lines, but this is not an ideal solution. Again, any useful suggestions or PRs are welcome!

## Contributing
Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/leostudiooo/typst-touying-theme-endfield).

## License

MIT License - See [LICENSE](LICENSE.md) for details.

## Disclaimer

*Arknights: Endfield* is a video game by Hypergryph (Gryphline outside China mainland). This theme is not affiliated with Hypergryph. All trademarks are property of their respective owners.
