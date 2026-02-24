# Tierpist

Make tierlists in [Typst](https://typst.app/) using the pastel color palettes from [Catppuccin](https://github.com/catppuccin/catppuccin).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Usage

```typ
#import "@preview/tierpist:0.1.0": tierlist, theme

#show: tierlist.with(
  tiers: (
    [This is S-tier!],
    [This is A-tier!],
    [This is B-tier!],
    grid.cell(align: center)[This is C-tier!],
    [This is D-tier!],
    grid.cell(inset: 1em)[This is E-tier!],
    [This is F-tier!],
  ),

  /// This line is optional
  /// Available themes are:
  /// - `theme.latte` (a light theme)
  /// - `theme.frappe` (a dark theme)
  /// - `theme.macchiato` (a dark theme)
  /// - `theme.mocha` (a dark theme)
  /// The default theme is `theme.macchiato`
  /// See https://typst.app/universe/package/typpuccino
  theme: theme.mocha,

  /// This `page` dictionary is optional
  page: (
    /// The default page size is A4 in landscape orientation
    width: 10in, /// The default page width is `297mm`
    height: 6in, /// The default page height is `210mm`
  ),

  /// This `text` dictionary is optional
  text: (
    /// This line is optional
    /// The default Typst font is `"Libertinus Serif"`
    font: "DejaVu Sans",

    /// This line is optional (and commented out, here)
    /// The default text color is taken from the color theme
    // fill: white,
  )
)

#set page(margin: 1cm)

This text will show up on a new page.
Explain your ranking here!
```

---

Mocha

![Tierlist using the mocha color palette](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/docs/Tierpist-mocha-1.svg)
![Tierlist details using the mocha color palette](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/docs/Tierpist-mocha-2.svg)

---

Macchiato

![Tierlist using the macchiato color palette](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/docs/Tierpist-macchiato-1.svg)

---

Frappe

![Tierlist using the frappe color palette](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/docs/Tierpist-frappe-1.svg)

---

Latte

![Tierlist using the latte color palette](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/docs/Tierpist-latte-1.svg)

## Acknowledgments

**Tierpist** uses the [typpuccino](https://typst.app/universe/package/typpuccino) package published by [Nan Huang](https://github.com/TeddyHuang-00) under the terms of the [MIT License](https://github.com/TeddyHuang-00/typpuccino/blob/main/LICENSE).

## License

**Tierpist** is a free and open-source Typst package available under the terms of the [MIT License](https://github.com/typst/packages/blob/main/packages/preview/tierpist/0.1.0/LICENSE).
