# HAW Hamburg Typst Template

This is an **`unofficial`** template for writing a report or thesis in the `HAW Hamburg` department of `Computer Science` design using [Typst](https://github.com/typst/typst).

## Usage

To use this package just add the following code to your [Typst](https://github.com/typst/typst) document:

### Report

```typst
#import "@preview/haw-hamburg:0.6.2": report

#show: report.with(
  language: "en",
  title: "Example title",
  author:"Example author",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
)
```

### Bachelor Thesis

```typst
#import "@preview/haw-hamburg:0.6.2": bachelor-thesis

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
)
```

### Master Thesis

```typst
#import "@preview/haw-hamburg:0.6.2": master-thesis

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
)
```

## Examples

Examples can be found inside of the [examples](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples) directory

- For Bachelor  theses see: [Bachelor thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/bachelor-thesis)
- For Master theses see: [Master thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/master-thesis)
- For reports see: [Report example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main/examples/report)
