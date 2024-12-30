# The `elsearticle` template
<div align="center">Version 0.1.0</div>

`elsearticle` is a Typst template that aims to mimic the Elsevier article LaTeX class, a.k.a. `elsearticle.cls`, provided by Elsevier to format manuscript properly for submission to their journals.

## Basic usage

This section provides the minimal amount of information to get started with the template. For more detailed information, see the [manual](/docs/manual.pdf).

To use the `elsearticle` template, you need to include the following line at the beginning of your `typ` file:

```typ
#import "@preview/elsearticle:0.1.0": *
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

## Additional features

The `elsearticle` template provides additional features to help you format your document properly.

### Appendix

To activate the appendix environment, all you have to do is to place the following command in your document:
```typ
#show: appendix

// Appendix content here
```

### Subfigures

Subfigures are not built-in features of Typst, but the #package[Elsearticle] template provides a way to handle them. To create a subfigure, you can use the following syntax:

```typ
#figure(
  grid(columns: 2, gutter: 1em,
  [#subfigure(image("image1.png")) <figa>],
  [#subfigure(image("image2.png")) <figb>]
  ),
  caption: [(a) Left image and (b) Right image],
) <fig>
```

>**NOTE**
>The `subpar` package is not use in this template because it doesn't seem to allow separate supplements : one for the caption and one for referencing the element. In the **Guide for authors**, it is indicated to cite a figure as "Fig. 1" in the text.

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
- [ ] Final - Work started by @JamesXx

*Environment*

- [x] Implementation of the `appendix` environment

*Figures and tables*

- [x] Implementation of the `subfigure` environment
- [x] Proper referencing of figure, subfigures and tables w.r.t. the context
- [x] Recreation of the `link` to cross-reference figures, subfigures and tables

*Equations*

- [x] Proper referencing of equations w.r.t. the context
- [ ] Numbering each equation of a system as "(1a)" -- _On going discussions at the Typst dev level_

*Other features*

- [ ] Line numbering - a PR is currently open on the Typst repo -- See [here](https://github.com/typst/typst/pull/4516")

## License
MIT licensed

Copyright (C) 2024 Mathieu AUCEJO (maucejo)