# HdM Thesis Template

Unofficial [typst](https://typst.app/) template for Hochschule der Medien Stuttgart (Stuttgart Media Univerisity). Inspired by the Template by Prof. Dr. Dirk Heuzeroth 

The template supports both Bachelors and Masters, as well as German and English languages.

## Usage

You can add basic information such as language, contributors, title, etc. in the metadata.yaml file.

In the main file, you will need this:

```typst
#import "@preview/hdm-thesis:0.1.0": hdm-thesis
#import "@preview/glossarium:0.5.7": gls, glspl

#import "abstract.typ": abstract_de, abstract_en
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#let metadata = yaml("metadata.yaml")

#show: hdm-thesis.with(
    metadata, datetime(year: 2025, month: 8, day: 1),
    bib: bibliography("sources.bib"),
    glossary: glossary, acronyms: acronyms,
    abstract_de: abstract_de, abstract_en: abstract_en)
```

You should edit the date to be your submission date, or just use datetime.today() (the default in the template).

All content you add after that is considered part of the thesis and will be added to the Table of Contents.
