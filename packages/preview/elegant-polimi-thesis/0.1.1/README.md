# elegant-polimi-thesis 🎓

Elegant and simple thesis template for [Typst](https://typst.app/), a modern typesetting program alternative to LaTeX. I based the design of the document on the following two templates:

- [PhD Thesis Template](https://www.overleaf.com/latex/templates/phd-thesis-template/nwjkggvhrzmz)
- [DEIB PhD Thesis Template](https://www.overleaf.com/latex/templates/politecnico-di-milano-deib-phd-thesis-template/ydsvtyzwxfdk)

They are rather similar. The main difference is the PoliBlu colour spread across the headings. I recommend to check them out.

> [!NOTE]
> See the [manual](docs/manual.pdf) and [documentation](docs/docs.pdf) for more information.

## Preview ✨

<p align="center">
  <img alt="Frontispiece" src="thumbnail.png" width="45%">
</p>

## Usage 🖋

Compile with:

```shell
typst c main.typ --pdf-standard a-3b
```

A very simple document:

```typ
#import "@preview/elegant-polimi-thesis:0.1.1": *

#show: polimi-thesis.with(
  title: "Thesis Title",
  author: "Vittorio Robecchi",
  advisor: "Prof. Donatella Sciuto",
  coadvisor: "Prof. Antonio Capone",
  tutor: "Prof. Marco Bramanti",
  colored-headings: true
)

#show: frontmatter

// abstract in English

// sommario in Italian

#show: acknowledgements

// acknowledgements

#toc
#list-of-figures
#list-of-tables

#let nomenclature_ = (
  "key" : "value"
)
#nomenclature(
  nomenclature_,
  indented: true
)

#show: mainmatter

// main section of the thesis

#show: backmatter

// backmatter

#show: appendix

// appendix

#show: backmatter

// bibliography

#show: acknowledgements

// acknowlegments
```

The full list of options is as follows:

- `title`: title of the thesis
- `author`: name and surname of the author
- `advisor`: name and surname of the advisor
- `coadvisor`: name and surname of the coadvisor (can be empty)
- `tutor`: name and surname of the tutor
- `academic-year`: the current academic year
- `cycle`: the cycle of the thesis
- `language`: language of the thesis
- `colored-headings`: whether to use colored headings or not
- `main-logo`: main logo of the thesis

See the `docs/` folder for a thorough example on how to style the thesis; also have a look at `docs/docs.pdf` for the full documentation.

# Contributing 🚀

If you happen to have suggestions, ideas or anything else feel free to open issues and pull requests.
