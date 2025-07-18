# HPI Thesis Template

This template is for HPI students writing their Bachelor's or Master's thesis. 

## ⚠️ Disclaimer
- This template is not official.
- Official university guidelines may differ from the ones used in this template.

## Getting Started

```
typst init @preview/hpi-thesis
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/hpi-thesis:0.0.1": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study_program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professor: "Prof. Dr. Rosseforp Renttalp",
  advisors: ("This person", "Someone Else"),
  abstract: "Some abstract",
  abstract_de: "Der deutsche Abstract...",
  acknowledgements: "Thanks to ...",
  type: "Master",
  for_print: false
)

... your content ...
```

## You like this template? Consider supporting!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://coff.ee/robert.richter)

![](./0.0.1/thumbnail.png)
