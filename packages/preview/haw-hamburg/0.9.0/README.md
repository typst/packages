# HAW Hamburg Typst Template

This is an **`unofficial`** template for writing a report or thesis in the `HAW Hamburg` Faculty of `Computer Science and Digital Society` style using [Typst](https://github.com/typst/typst).

## Usage

To use this package just add the following code to your [Typst](https://github.com/typst/typst) document:

### Report

```typst
#import "@preview/haw-hamburg:0.9.0": report

#show: report.with(
  language: "en",
  title: "Example title",
  author:"Example author",
  faculty: "Computer Science and Digital Society",
)
```

### Bachelor Thesis

```typst
#import "@preview/haw-hamburg:0.9.0": bachelor-thesis

#show: bachelor-thesis.with(
  language: "en",

  title-de: "Beispiel Titel",
  keywords-de: ("Stichwort", "Wichtig", "Super"),
  abstract-de: "Beispiel Zusammenfassung",

  title-en: "Example title",
  keywords-en:  ("Keyword", "Important", "Super"),
  abstract-en: "Example abstract",

  author: "Example author",
  faculty: "Computer Science and Digital Society",
  study-course: "Bachelor of Science Informatik Technischer Systeme",
  supervisors: ("Prof. Dr. Example", "Prof. Dr. Example"),
  submission-date: datetime(year: 1948, month: 12, day: 10),
)
```

### Master Thesis

```typst
#import "@preview/haw-hamburg:0.9.0": master-thesis

#show: master-thesis.with(
  language: "en",

  title-de: "Beispiel Titel",
  keywords-de: ("Stichwort", "Wichtig", "Super"),
  abstract-de: "Beispiel Zusammenfassung",

  title-en: "Example title",
  keywords-en:  ("Keyword", "Important", "Super"),
  abstract-en: "Example abstract",

  author: "The Computer",
  faculty: "Computer Science and Digital Society",
  study-course: "Master of Science Computer Science",
  supervisors: ("Prof. Dr. Example", "Prof. Dr. Example"),
  submission-date: datetime(year: 1948, month: 12, day: 10),
)
```

### Exposé

```typst
#import "@preview/haw-hamburg:0.9.0": expose

#show: expose.with(
  language: "en",
  title: "Example title",
  keywords: ("Keyword", "Important", "Super"),
  author: "Example author",
  faculty: "Computer Science and Digital Society",
  supervisors: ("Prof. Dr. Example", "Prof. Dr. Example"),
  submission-date: datetime(year: 1948, month: 12, day: 10),
)
```

## Examples

Examples can be found inside of the [templates](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/59faf037d79de4ad91ec36dea1a653ed189830a8/templates) directory

- For Bachelor  theses see: [Bachelor thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/59faf037d79de4ad91ec36dea1a653ed189830a8/templates/bachelor-thesis/src)
- For Master theses see: [Master thesis example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/59faf037d79de4ad91ec36dea1a653ed189830a8/templates/master-thesis/src)
- For reports see: [Report example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/59faf037d79de4ad91ec36dea1a653ed189830a8/templates/report/src)
- For exposés see: [Expose example](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/59faf037d79de4ad91ec36dea1a653ed189830a8/templates/expose/src)
