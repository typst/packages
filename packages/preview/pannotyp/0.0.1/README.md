# PannoTyp

This module adds Hungarian language support to Typst.

> Unless You are writing something in Hungarian You do not need this
> module at all.

## Features

### Hungarian style definitions

This module sets up shome `show` rules:
  - Hungarian-style captions:
    - `1 ábra: Ábra felirata`
    - `2.1 táblázat: Táblázat felirata`
    - `(3.3) egyenlet`
  - Hungarian-style references:
    - `1. ábra`
    - `3. oldal`

### Helper functions

To help writing Hungarian documents the package defines the following helper
functions:
  - `#aref` and `#Aref` for handling definite article cases.
  - `#hq` for Hungarian-style quoting.
  - `#told` for generating various Hungarian suffixes.
  - `#atold` and `#Atold` for mixing `aref` and `told` functions.

## Usage

```typst
#import "@preview/pannotyp:0.0.1" as pt
#show: pt.init
```

> You can also import the modules like
> ```typst
> #import "@preview/pannotyp:0.0.1": *
> #show: init
> ```
> this way You can omit `pt.` from every function name, but it can cause name
> collisions.

Please refer to [Releases](https://codeberg.org/voroskoi/PannoTyp/releases)
page for the latest
[manual](https://codeberg.org/voroskoi/PannoTyp/releases/download/v0.0.1/manual.pdf).

## Changelog

### v0.0.1

Initial Release
