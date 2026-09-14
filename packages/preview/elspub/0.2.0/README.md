# Elsevier publishing template

[![Generic badge](https://img.shields.io/badge/Version-0.2.0-cornflowerblue.svg)]()
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/elsearticle/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/maucejo/elspub/blob/main/docs/manual.pdf)

The `elspub` package is designed to closely resemble the `LaTeX` class used by Elsevier for article formatting, which is not publicly available. It is not intended for submission, but rather to help authors prepare articles that resemble the final published version. It mainly serves as a proof of concept, demonstrating that Typst is a viable option for academic writing and scientific publishing.

The template uses the following fonts to conform to the Elsevier style:
- [`Charis SIL`](https://fonts.google.com/specimen/Charis+SIL) for the main text
- [`STIX Two Math`](https://www.stixfonts.org/) for maths
- [`Roboto`](https://fonts.google.com/specimen/Roboto) for the journal homepage

## Basic usage

This section provides the minimal amount of information to get started with the template. For more detailed information, see the [manual](https://github.com/maucejo/elspub/blob/main/docs/manual.pdf).

To use the `elspub` template, you need to include the following line at the beginning of your `typ` file:

```typ
#import "@preview/elspub:0.1.0": *
```

### Initializing the template

After importing `elspub`, you have to initialize the template by a show rule with the `#elspub()` command. This function takes an optional argument to specify the title of the document.

* `paper-type`: Type of the paper (e.g. `Article`, `Review`, `Letter`).
* `journal`: Dictionary containing the journal information (e.g. `mssp`).
* `title`: Title of the paper.
* `abstract`: Abstract of the paper.
* `authors`: List of the authors of the paper.
* `institutions`: List of the institutions of the paper.
* `paper-info`: Dictionary containing the paper information (e.g. year, volume, ...).
* `keywords`: List of keywords of the paper.


## Additional features

The `elspub` template provides additional features to help you format your document properly.

### Appendix

To activate the appendix environment, all you have to do is to place the following command in your document:
```typ
#show: appendix

// Appendix content here
```

### Subfigures

Subfigures are not built-in features of Typst, but the `elspub` template provides a way to handle them. It is based on the `subpar` package that allows you to create subfigures and properly reference them.

```typ
  #subfigure(
    figure(image("image1.png"), caption: []), <figa>,
    figure(image("image2.png"), caption: []), <figb>,
    columns: (1fr, 1fr),
    caption: [(a) Left image and (b) Right image],
    label: <fig>
  )
```

## Roadmap

- [ ] Add more journals dictionaries
- [ ] Add more journal-specific styles to the template


## License
MIT licensed

Copyright (C) 2025 Mathieu AUCEJO (maucejo) and James R Swift (jamesrswift)