# HdM Thesis Template

Unofficial [typst](https://typst.app/) template for Hochschule der Medien Stuttgart (Stuttgart Media Univerisity). Inspired by the Template by Prof. Dr. Dirk Heuzeroth 

The template supports both Bachelors and Masters, as well as German and English languages.

## Usage

You can add basic information such as language, contributors, title, etc. in the metadata.yaml file.

In the main file, you will need this:

```typst
#import "@preview/pretty-hdm-thesis:0.1.0": pretty-hdm-thesis
#import "@preview/glossarium:0.5.7": gls, glspl

#import "abstract.typ": abstract_de, abstract_en
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#let metadata = yaml("metadata.yaml")

#show: pretty-hdm-thesis.with(
    metadata, datetime(year: 2025, month: 8, day: 1),
    bib: bibliography("sources.bib"),
    glossary: glossary, acronyms: acronyms,
    abstract_de: abstract_de, abstract_en: abstract_en)
```

You should edit the date to be your submission date, or just use datetime.today() (the default in the template).

All content you add after that is considered part of the thesis and will be added to the Table of Contents.

## Logo

The template supports adding the HdM logo (or some other logo) to the first page and onto the header of odd pages. If you are a member of the University you can find the HdM Logo in the [Intranet](https://www.hdm-stuttgart.de/intranet/services/corporate_design) with your student credentials.

The Logo can be added using the `logo` attribute:

```
#show: pretty-hdm-thesis.with(
    metadata, datetime(year: 2025, month: 8, day: 1),
    bib: bibliography("sources.bib"),
    logo: image("assets/hdm_logo.svg"))
```