# HAW Hamburg Typst Template

This is an **`unofficial`** template for writing a report or thesis in the `HAW Hamburg` department of `Computer Science` design using [Typst](https://github.com/typst/typst).

## Usage

To use this package, simply add the following code to your document:

### Report

```typst
#import "@preview/haw-hamburg:0.1.0": report

#show: report.with(
  language: "en",
  title: "Example title",
  author:"Example author",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
  include-declaration-of-independent-processing: true,
)
```

### Bachelor Thesis

```typst
#import "@preview/haw-hamburg:0.1.0": bachelor-thesis

#show: bachelor-thesis.with(
  language: "en",

  title-de: "Beispiel Titel",
  keywords-de: ("Stichwort", "Wichtig", "Super"),
  abstract-de: "Beispiel Zusammenfassung",

  title-en: "Example title",
  keywords-en:  ("Keyword", "Important", "Super"),
  abstract-en: "Example abstract",

  author: "Example author",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
  study-course: "Bachelor of Science Informatik Technischer Systeme",
  supervisors: ("Prof. Dr. Example", "Prof. Dr. Example"),
  submission-date: datetime(year: 1948, month: 12, day: 10),
  include-declaration-of-independent-processing: true,
)
```

### Master Thesis

```typst
#import "@preview/haw-hamburg:0.1.0": master-thesis

#show: master-thesis.with(
  language: "en",

  title-de: "Beispiel Titel",
  keywords-de: ("Stichwort", "Wichtig", "Super"),
  abstract-de: "Beispiel Zusammenfassung",

  title-en: "Example title",
  keywords-en:  ("Keyword", "Important", "Super"),
  abstract-en: "Example abstract",

  author: "The Computer",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
  study-course: "Master of Science Computer Science",
  supervisors: ("Prof. Dr. Example", "Prof. Dr. Example"),
  submission-date: datetime(year: 1948, month: 12, day: 10),
  include-declaration-of-independent-processing: true,
)
```

## How to Compile

This project contains an example setup that splits individual chapters into different files.\
This can cause problems when using references etc.\
These problems can be avoided by following these steps:

- Make sure to always compile your `main.typ` file which includes all of your chapters for references to work correctly.
- VSCode:
  - Install the [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension.
  - Make sure to start the `PDF` or `Live Preview` only from within your `main.typ` file.
  - If problems occur it usually helps to close the preview and restart it from your `main.typ` file.

## Examples

Examples can be found inside of the [examples](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples) directory

- For Bachelor  theses see: [Bachelor thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/bachelor-thesis)
- For Master theses see: [Master thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/master-thesis)
- For reports see: [Report example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/report)
