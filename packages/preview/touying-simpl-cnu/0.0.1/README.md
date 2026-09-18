<p align="center">
    <img width="50%" src="./thumbnail.png" alt="Preview of the Touying slide theme for Capital Normal University"/>
</p>

# Touying Slide Theme for Capital Normal University
[![Typst Universe version](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftouying-simpl-cnu&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/touying-simpl-cnu)
[![MIT license](https://img.shields.io/github/license/maxchang3/touying-simpl-cnu?style=flat-square)](LICENSE)


A slide theme for Capital Normal University based on the [Touying](https://github.com/touying-typ/touying) presentation framework. 

Modified from the [Touying slide theme for China Agricultural University](https://github.com/maxchang3/touying-simpl-cau/); [originally created for Beihang University](https://github.com/Coekjan/touying-buaa).

[Preview Online](https://maxchang3.github.io/touying-simpl-cnu/)

## Usage

### Import the theme in existing projects

```typst
#import "@preview/touying:0.7.4": *
#import "@preview/touying-simpl-cnu:0.0.1": *

#show: cnu-theme.with(
    config-info(
        title: [Touying for CNU: Customize Your Slide Title Here],
        subtitle: [Customize Your Slide Subtitle Here],
        author: [Authors],
        date: datetime.today(),
        institution: [Capital Normal University],
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
$ typst init @preview/touying-simpl-cnu
Successfully created new project from @preview/touying-simpl-cnu:<latest>
To start writing, run:
> cd touying-simpl-cnu
> typst watch main.typ
```

## Examples

See [examples](examples) for more details.

Compile the examples yourself:

```console
$ typst compile ./examples/main.typ --root .
```

The compiled presentation will be available at `./examples/main.pdf`.

## Development

This package is maintained using:

- [Typush](https://github.com/Vncntvx/typush) - for publishing to the Typst package registry.
- [Typst Upgrade](https://github.com/Coekjan/typst-upgrade) - for upgrading Typst packages.

## License

Licensed under the [MIT License](LICENSE).
