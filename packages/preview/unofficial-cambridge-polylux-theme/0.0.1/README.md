# University of Cambridge Theme for Polylux

This is a custom theme for [Polylux](https://typst.app/universe/package/polylux/), 
designed to match the branding and style guidelines of the University of Cambridge.

![Cambridge Theme Preview](https://raw.githubusercontent.com/Matt-Ord/cambridge_polylux_theme/refs/tags/0.0.1/example/main.svg)

## Required Fonts
To use this theme, you need to have the following fonts installed on your system:
- Feijoa Sans
- Open Sans For the body
These fonts can be downloaded from [here](https://www.cam.ac.uk/brand-resources/guidelines/typography).

## Using the Cambridge Logo
The university logo can be downloaded from [here](https://www.cam.ac.uk/brand-resources/logo/download).

## Updating the Example
To update the example document with the latest changes to the theme, run the following command in your terminal:

```bash
typst compile example/main.typ --root .
typst compile example/main.typ --root . --pages 1 --format svg
```