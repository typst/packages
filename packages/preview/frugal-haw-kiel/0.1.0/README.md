This is a simple HAW Thesis template based off the HAW Hamburg template and changed with the requirements set by Prof. Dr. Lüssem.

## Example
The [full example](https://github.com/arne-berner/haw-kiel-template) can be seen on github.

### Getting started
Some parameters are strictly optional, especially if you don't intend to write your thesis in both german and english. It is good practice to seperate your chapters into files.

```ts
#import "./abstract.typ":abstract
#import "./acknowledgment.typ":acknowledgment
#import "./abbreviations.typ":abbreviations
#import "./glossary.typ":glossary
#import "@preview/HAW-Kiel:0.1.0": *
#show: thesis.with(
  language: "de",
  title-de: "Wie kann ich das Template nutzen, um meine Thesis einfach zu gestalten?",
  keywords-de: ("HAW", "Kiel", "IuE", "Template"),
  abstract-de: abstract,
  title-en: lorem(12),
  keywords-en: ("CCN", "Kiel", "Science", "Applied"),
  abstract-en: ("Another lorem ipsum that might be to long as it is it's worth a try at least."),
  author: lorem(3),
  faculty: "Informatik und Elektrotechnik",
  study-course: "Bachelor of Science Informatik",
  supervisors: ("Prof.Dr. Musterfrau", "Prof.Dr. Musterman"),
  submission-date: datetime(year: 2026, month: 1, day: 16),
  logo: image("./assets/logo.svg"),
  bib: bibliography("./bibliography.bib"),
  abbreviations: abbreviations,
  glossary: glossary,
  use-declaration-of-independent-processing: true,
  before-content: acknowledgment,
  // after-content: (),
)

#pagebreak(weak: true)
#include "chapters/01_intro.typ"
#include "chapters/02_ending.typ"
```
### Abbreviations and Glossary
Abbreviations and Glossaries both make use of [glossarium](https://typst.app/universe/package/glossarium/). You can either use @key or reimport gls for both. In order for glossarium to work, you need to provide an array of this sort:
```ts
#let abbreviations = (
  (
    key: "PR",
    short: "PR",
    long: "Pull Request",
  ),
)
```

## Logo
The HAW Logo has it's own copyright that might not be freely used as indicated by the wikipedia article. Since this is the case the example has a placeholder logo. The logo can be found [here](https://www.haw-kiel.de/fileadmin/template/images/haw_kiel_logo.svg) and you will need to use it as seen in the example. 
```ts
include-logo: false,
```

## Font
The Font used here is Times New Roman. I am aware that this is not available by default on any system. Please check if you have the font installed first.


## License
Licensed under either of
- MIT license (see `LICENSE-MIT`), or
- Apache License, Version 2.0 (see `LICENSE-APACHE`),

at your option.

This repository incorporates files from the [HAW Hamburg Typst template](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/blob/main/LICENSE), which retain their original MIT copyright and license notice.


## Attribution
This project is based on the [HAW Hamburg Typst template](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template).  
Copyright (c) 2024 Lasse Rosenow 
Licensed under the MIT License. See LICENSE-MIT.

Additional contributions are available under the Apache License, Version 2.0.
- Some files are copied verbatim from the original template. These include:
  - `pages/TOC.typ`
  - `pages/listings.typ` (list_of_code)
  - `pages/list_of_figures.typ`
  - `pages/list_of_tables.typ`
  - `pages/declaration_of_independent_processing.typ`
- Other files have been modified to better fit the project's goals, such as:
  - `pages/cover.typ`
  - `pages/abstract.typ`
  - `lib.typ`
  - `translations.typ`
All copied or derived files retain their original MIT copyright notice as part of the license compliance.
