<p align="center">
    <img width="50%" src="./thumbnail.png"/>
</p>

# Touying Slide Theme for East China Normal University
[![Version](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftouying-simpl-ecnu&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/touying-simpl-ecnu)
[![License](https://img.shields.io/github/license/ccyoung3/touying-simpl-ecnu?style=flat-square)](LICENSE)


A slide theme for East China Normal University based on the [Touying](https://github.com/touying-typ/touying) presentation framework. 

Modified from the [Touying slide theme for China Agricultural University](https://github.com/maxchang3/touying-simpl-cau/); [originally created for Beihang University](https://github.com/Coekjan/touying-buaa).


<!-- [Preview Online](https://ccyoung3.github.io/touying-simpl-ecnu/) -->

## Usage

### Import the theme in existing projects

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-simpl-ecnu:0.2.0": *

#show: ecnu-theme.with(
    config-info(
        title: [Touying for CAU: Customize Your Slide Title Here],
        subtitle: [Customize Your Slide Subtitle Here],
        author: [Authors],
        date: datetime.today(),
        institution: [East China Normal University],
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
$ typst init @preview/touying-simpl-ecnu
Successfully created new project from @preview/touying-simpl-ecnu:<latest>
To start writing, run:
> cd touying-simpl-ecnu
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

- [Typship](https://github.com/sjfhsjfh/typship) - for publishing to the Typst package registry.
- [Typst Upgrade](https://github.com/Coekjan/typst-upgrade) - for upgrading Typst packages.

## License

Licensed under the [MIT License](LICENSE).
