# Elsearticle template

[![Generic badge](https://img.shields.io/badge/Version-0.3.0-cornflowerblue.svg)]()
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/elsearticle/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/maucejo/elsearticle/blob/main/docs/manual.pdf)

`elsearticle` is a Typst template that aims to mimic the Elsevier article LaTeX class, a.k.a. `elsearticle.cls`, provided by Elsevier to format manuscript properly for submission to their journals.

## Basic usage

This section provides the minimal amount of information to get started with the template. For more detailed information, see the [manual](https://github.com/maucejo/elsearticle/blob/main/docs/manual.pdf).

To use the `elsearticle` template, you need to include the following line at the beginning of your `typ` file:

```typ
#import "@preview/elsearticle:0.3.0": *
```

### Initializing the template

After importing `elsearticle`, you have to initialize the template by a show rule with the `#elsearticle()` command. This function takes an optional argument to specify the title of the document.

* `title`: Title of the paper
* `author`: List of the authors of the paper
* `abstract`: Abstract of the paper
* `journal`: Name of the journal
* `keywords`: List of keywords of the paper
* `format`: Format of the paper. Possible values are `preprint`, `review`, `1p`, `3p`, `5p`
* `numcol`: Number of columns of the paper. Possible values are 1 and 2
* `line-numbering`: Enable line numbering. Possible values are `true` and `false`

## Additional features

The `elsearticle` template provides additional features to help you format your document properly.

### Appendix

To activate the appendix environment, all you have to do is to place the following command in your document:
```typ
#show: appendix

// Appendix content here
```

### Subfigures

Subfigures are not built-in features of Typst, but the `elsearticle` template provides a way to handle them. It is based on the `subpar` package that allows you to create subfigures and properly reference them.

```typ
  #subfigure(
    figure(image("image1.png"), caption: []), <figa>,
    figure(image("image2.png"), caption: []), <figb>,
    columns: (1fr, 1fr),
    caption: [(a) Left image and (b) Right image],
    label: <fig>
  )
```

### Equations

The `elsearticle` template provides the `#nonumeq()` function to create unnmbered equations. The latter function can be used as follows:
```typ
#nonumeq[$
  y = f(x)
  $
]
```

## Roadmap

*Article format*

- [x] Preprint
- [x] Review
- [x] 1p
- [x] 3p
- [x] 5p

*Environment*

- [x] Implementation of the `appendix` environment

*Figures and tables*

- [x] Implementation of the `subfigure` environment

*Equations*

- [x] Proper referencing of equations w.r.t. the context
- [ ] Numbering each equation of a system as "(1a)" -- _On going discussions at the Typst dev level_

*Other features*

- [x] Line numbering - Line numbering - Use the built-in `par.line` function available from Typst v0.12

## License
MIT licensed

Copyright (C) 2024 Mathieu AUCEJO (maucejo)