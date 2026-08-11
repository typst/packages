# Cleanified HPI Thesis Template

This template is for HPI students writing their Bachelor's or Master's thesis. It is intended to follow a clean asthetic.

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
#import "@preview/cleanified-hpi-thesis:0.0.1": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study-program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professor: "Prof. Dr. Rosseforp Renttalp",
  advisors: ("This person", "Someone Else"),
  abstract: "Some abstract",
  abstract-de: "Der deutsche Abstract...",
  acknowledgements: "Thanks to ...",
  type: "Master",
  for-print: false
)

... your content ...
```

## Copyright Notes

Please note that the logos are University of Potsdam ([UP Logo Usage Guidelines](https://www.uni-potsdam.de/fileadmin/projects/zim/files/MMP/PDF_Dateien_MMP/250509-Leitfaden_DigitalPrint-web.pdf)) and Hasso Plattner Institute ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)).

## You like this template? Consider supporting!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://coff.ee/robert.richter)

![](./0.0.1/thumbnail.png)
