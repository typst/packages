hetvid
========================================

This is a template for writing scientific notes in Typst,
with careful handling of indentation, theorem environments,
spacing, and other typographic details.
This template is designed for English and Chinese languages,
typographic details are optimized for Chinese.

The name _hetvid_ derives from Sanskrit word _hetuvidyā_,
which refers to Buddhist logico-epistemology.
The Chinese translation is 因明.

## Usage

A minimal setup is as follows:

```typ
#import "@preview/hetvid:0.1.0": *
#show: hetvid.with(
  title: [Hetvid: A Typst template for lightweight notes],
  author: "itpyi",
  affiliation: "Xijing Ci'en Institute of Translation, Tang Empire",
  header: "Instruction",
  date-created: "2025-03-27",
  date-modified: "2025-04-22",
  abstract: [This is a template designed for writing scientific notes. ],
  toc: true,
)
```

See [`doc.pdf`](https://github.com/itpyi/hetvid/blob/main/0.1.0/doc/doc.pdf) for a detailed explanation of how to use this template.

## Acknowledgements

This template is inspired by the [kunskap](https://typst.app/universe/package/kunskap/) template.

## Plan

- Enable multiple authors.
- Enable emails.

