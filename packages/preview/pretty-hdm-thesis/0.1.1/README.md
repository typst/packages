# HdM Thesis Template

Unofficial [typst](https://typst.app/) template for Hochschule der Medien Stuttgart (Stuttgart Media Univerisity). Inspired by the Template by Prof. Dr. Dirk Heuzeroth 

The template supports both Bachelors and Masters, as well as German and English languages.

## Usage

You can add basic information such as language, contributors, title, etc. in the metadata.yaml file.

In the main file, you will need this:

```typst
#import "@preview/pretty-hdm-thesis:0.1.1": pretty-hdm-thesis
#import "@preview/glossarium:0.5.7": gls, glspl

#import "abstract.typ": abstract_de, abstract_en
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#let metadata = yaml("metadata.yaml")

#show: pretty-hdm-thesis.with(
    metadata,
    datetime(year: 2025, month: 8, day: 4),
    bib: bibliography("sources.bib"),
    bib-style: "chicago-notes",
    glossary: glossary, acronyms: acronyms,
    abstract-de: abstract-de, abstract-en: abstract-en,
)
```

You should edit the date to be your submission date, or just use datetime.today() (the default in the template).

All content you add after that is considered part of the thesis and will be added to the Table of Contents.

## Optional features

A few things can be changed or disabled depending on what you need or want in your paper.

## Glossary and Acronyms

Those use glossarium to enable you to add linkable explanations for certain terms or acrynms that you might use in your work. If you do not need those you can remove them or set them to `none`. You cannot use `gls` or `glspl` if you remove them both. You may remove only one of them.

## Figure and Table outline

Both can be turned of with `table-outline: false` and `figure-outline: false` respectively

## Declaration of authorship

By default the declaration of authorship will be included right after the first page filled in with title
of your data based on the requirements from the HdM. If you want to remove it because you want to publish a version without it, or because you don't need it for other reasons, you can disable it with `declaration-of-authorship: false`.

## Abstracts

Default abstracts in english and german are provided in the template, you may remove either or both if you do not need them or set them to `none`. If you do write a thesis it is usually a requirement to have both tho.

## Acknowledgements

Those are completely optional and without form, you can shout out important people that helped you write, research, where influential to you or just gush about your cat. As long as your supervisors are fine with it anything goes. If you don't wanna add them just remove it from the parameterlist or set it to `none`.

## Logo

The template supports adding the HdM logo (or some other logo) to the first page and onto the header of odd pages. If you are a member of the University you can find the HdM Logo in the [Intranet](https://www.hdm-stuttgart.de/intranet/services/corporate_design) with your student credentials.

The Logo can be added using the `logo` attribute:

```
#show: pretty-hdm-thesis.with(
    metadata, datetime(year: 2025, month: 8, day: 1),
    bib: bibliography("sources.bib"),
    logo: image("assets/hdm_logo.svg"))
```