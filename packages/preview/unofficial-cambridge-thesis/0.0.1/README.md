# University of Cambridge Theme thesis template

This is a custom thesis template
designed to match the branding and style guidelines of the University of Cambridge.

![Cambridge Theme Preview](https://raw.githubusercontent.com/Matt-Ord/cambridge_thesis/refs/tags/0.0.1/main.png)

## Required Fonts
To use this theme, you need to have the following fonts installed on your system:
- Feijoa Sans
- Open Sans For the body
These fonts can be downloaded from [here](https://www.cam.ac.uk/brand-resources/guidelines/typography).
By default, this template also uses Fira Math for mathematical typesetting

## Using the Cambridge Crest
The university crest can be downloaded from [here](https://raw.githubusercontent.com/Matt-Ord/cambridge_thesis/refs/tags/0.0.1/crest/University_Crest.pdf).

## Updating the Example
To update the example document with the latest changes to the theme, run the following command in your terminal:

```bash
typst compile example/main.typ --root .
typst compile example/main.typ --root . --pages 1 --format svg
```