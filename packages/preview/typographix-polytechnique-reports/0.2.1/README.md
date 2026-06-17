# Typst Polytechnique report template

A Typst template for Polytechnique student reports.

For a short introduction to Typst features and detailled information about the package, check the [guide](guide.pdf) (available from the repo only).

## Usage

If you want to use the template locally, make sure you have the font "New Computer Modern Sans" installed.

Define variables at the top of the template :

```typ
#let title = "Rapport de stage en entreprise sur plusieurs lignes automatiquement"
#let subtitle = "Un sous-titre pour expliquer ce titre"
#let logo = image("path/to/my-logo.png")
#let logo-horizontal = true
#let short-title = "Rapport de stage"
#let authors = ("Rémi Germe")
#let date-start = datetime(year: 2024, month: 06, day: 05)
#let date-end = datetime(year: 2024, month: 09, day: 05)
#let despair-mode = false
#let first-line-indent-all = auto

#set text(lang: "fr")
```

These variables will be used for PDF metadata, default cover page and default header.
