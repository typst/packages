# biznaga-uma-tfe

**English** · [Español](README.es.md)

Unofficial **Typst** template for bachelor's/master's theses (TFG/TFM) at the **School of Telecommunication Engineering (ETSIT), University of Málaga**.

## Usage

```sh
typst init @preview/biznaga-uma-tfe
```

Edit the parameters in `main.typ`:

```typ
#show: thesis.with(
  title: "<TÍTULO DEL TRABAJO>",
  title-en: "<TÍTULO DEL TRABAJO EN INGLÉS>",
  author-name: "<AUTOR>",
  supervisor-name: "<TUTOR>",
  degree: "<TITULACIÓN>",
  year: "20XX",
  acronyms: csv("01-ini/acronyms.csv", row-type: dictionary),
  show-todos: true,
)
```

- **Acronyms**: `01-ini/acronyms.csv` (`acronym,expansion,en`). Cite them with `@ACRONYM` (first use: expanded form; afterwards: the acronym). `en=1` sets the term in italics.
- **TODOs**: `#TODO[text]`; set `show-todos: false` to hide them. The list is generated in `02-toc/todo.typ`.
- **Utilities**: `minitoc()`, `xtable()`, `algorithm()`, `repo-qr-content()`, `chapterend()`.

## Structure

```
├── main.typ
├── 01-ini/   cover, abstracts, dedication, acknowledgements, acronyms
├── 02-toc/   tables of contents, figures, tables and TODOs
├── 03-cap/   chapters
├── 04-ape/   appendices
└── 05-bib/   bibliography
```

## Fonts

The template uses *TeX Gyre Heros*. Install it to get the intended look; otherwise Typst falls back to another font.

## Acknowledgements

Based on the official LaTeX template:
[Plantilla TFE - ETSIT Universidad de Málaga](https://www.overleaf.com/latex/templates/plantilla-tfe-etsit-universidad-de-malaga/xgkpmrryzwxv)
