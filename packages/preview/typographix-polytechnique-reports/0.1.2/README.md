# Typst Polytechnique package

A Typst package for Polytechnique student reports.

For a short introduction to Typst features and detailled information about the package, check the  [guide](https://github.com/remigerme/typst-polytechnique/blob/main/guide.pdf) (available from the repo only).

## Usage

If you want to use it on local, make sure you have the font "New Computer Modern Sans" installed.

Define variables at the top of the template :

```typc
#let title = "Rapport de stage en entreprise sur plusieurs lignes automatiquement"
#let subtitle = "Un sous-titre pour expliquer ce titre"
#let short_title = "Rapport de stage"
#let authors = ("Rémi Germe")
#let date_start = datetime(year: 2024, month: 06, day: 05)
#let date_end = datetime(year: 2024, month: 09, day: 05)
#let despair-mode = false

#set text(lang: "fr")
```

These variables will be used for PDF metadata, default cover page and default header.

## Contributing

Contributions are welcomed ! See [contribution guidelines](CONTRIBUTING.md).

## Todo

- [ ] heading not at the end of a page
- [x] first line indent
- [ ] better spacing between elements
- [ ] handle logos on cover page
- [ ] handle logos on header
