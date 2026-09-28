<p align="center">
    <img width="50%" src="./thumbnail.png" alt="Preview of the Touying slide theme for China Agricultural University"/>
</p>

# Touying Slide Theme for China Agricultural University
[![Typst Universe version](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftouying-simpl-cau&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/touying-simpl-cau)
[![MIT license](https://img.shields.io/github/license/maxchang3/touying-simpl-cau?style=flat-square)](LICENSE)


A slide theme for China Agricultural University based on the [Touying](https://github.com/touying-typ/touying) presentation framework. 

Modified from the [Touying Slide Theme for Beihang University](https://github.com/Coekjan/touying-buaa).

[Preview Online](https://maxchang3.github.io/touying-simpl-cau/)

## Usage

### Import the theme in existing projects

```typst
#import "@preview/touying:0.8.0": *
#import "@preview/touying-simpl-cau:0.2.2": *

#show: cau-theme.with(
    config-info(
        title: [Touying for CAU: Customize Your Slide Title Here],
        subtitle: [Customize Your Slide Subtitle Here],
        author: [Authors],
        date: datetime.today(),
        institution: [China Agricultural University],
    ),
    // use-background: false, // Uncomment to disable background image
)

#title-slide() // Create a title slide

#outline-slide() // Create an outline slide

// Add your content here
```

### Create a new project with `typst init`

Quickly scaffold a new presentation with:

```console
$ typst init @preview/touying-simpl-cau
Successfully created new project from @preview/touying-simpl-cau:<latest>
To start writing, run:
> cd touying-simpl-cau
> typst watch main.typ
```

## Examples

See [examples/main.typ](examples/main.typ) for more details.

Compile the examples yourself:

```console
$ typst compile ./examples/main.typ --root .
```

The compiled presentation will be available at `./examples/main.pdf`.

## Development

This package is maintained using:

- [Typush](https://github.com/Vncntvx/typush) - for publishing to the Typst package registry.
- [Typst Upgrade](https://github.com/Coekjan/typst-upgrade) - for upgrading Typst packages.

## License & Trademark Notice

- **Code & Templates**: Licensed under the [MIT License](LICENSE).
- **University Logo Notice**: The China Agricultural University logo, shield and campus gate artwork (`assets/CAU_logo.svg`, `assets/CAU_shield.svg`, `assets/Gate.svg`, and preview images such as `thumbnail.png` that contain them) are intellectual property of **China Agricultural University (CAU)**. They are **not covered by the MIT License**. They are included exclusively for non-commercial, academic, and educational presentations, thesis defenses, and reports by China Agricultural University members, in accordance with the [CAU Visual Identity System management rules](https://www.cau.edu.cn/xxgk/whbz/sjsbxt/index.htm). All intellectual property and trademark rights are reserved by China Agricultural University (https://www.cau.edu.cn).
