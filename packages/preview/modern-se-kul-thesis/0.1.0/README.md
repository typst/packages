# The `modern-se-kul-thesis` Package
<div align="center">Version 0.1.0</div>

This is an unofficial typst template for doing a thesis at the engineering science faculty at KU Leuven.
This was made by trying to as closely follow the Latex template [here](https://eng.kuleuven.be/docs/kulemt).
## Usage

You can use this template in the web editor by going to "start from template" and searching for "modern-se-kul-thesis".
Alternatively, you can use this template locally by running:
```typ
typst init @preview/modern-se-kul-thesis
```
This will then create a basic folder structure with some fields pre-filled.

## Configuration
- `title`: The title of the thesis.
- `subtitle`: An optional subtitle.
- `academic-year`: Can be a starting year (e.g. 2025) or a tuple of start and end year (e.g. 2025,2027)
- `authors`: An array of all the authors.
- `promotors`: An array of all the promotors.
- `assessors`: An array of all the assessors.
- `supervisors`: An array of all the supervisors.
- `degree: An array containing`: the name of your master, elective and the specified color in hsv (default is for computer science).
- `language`: "en" or "nl".
- `electronic-version`: A boolean toggle to set the thesis as electronic.
- `english-master`: A boolean toggle to use the template for the English master.
- `list-of-figures`: Toggle to add a list of figures.
- `list-of-listings`: Toggle to add a list of listings (code blocks).
- `font-size`: Font size toggle.
- `preface`: The preface of your thesis goes here.
- `abstract`: The abstract of your thesis goes here.
- `dutch-summary`: The dutch summary of your thesis goes here.
- `abbreviations`: The abbreviations used in your thesis go here.
- `symbols`: The symbols used in your thesis go here.
- `bibliography`: The bibliography of your thesis goes here.
- `appendices`: The appendices of your thesis goes here.
- `logo`: The logo of the university for the front page, the logo should be copied from the kulemt latex template
```typ
#import "@preview/modern-se-kul-thesis:0.1.0": template
#show: template.with(
title: [The main title],
subtitle: [The subtitle],
academic-year: 2025,
authors: ("an Author",),
promotors: ("a promotor",),
assessors: ("an assessor",),
supervisors: ("a supervisor",),
degree: (
    elective: "Software engineering",
    master: "Computer Science",
    color: (0, 0, 1, 0),
),
language: "en",
electronic-version: false,
english-master: false,
list-of-figures: true,
list-of-listings: false,
font-size: 11pt,
preface: [#lorem(100)],
abstract: [#lorem(100)],
dutch-summary: [#lorem(100)],
abbreviations: [WIP: Work in progress],
symbols: [$Omega$:Ohm],
bibliography: include bibliography.bib,
appendices: [#lorem(100)],
logo: [Temp]
)
// Put your thesis content here
```
