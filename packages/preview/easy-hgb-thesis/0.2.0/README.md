# Hagenberg Thesis (Typst)

Opinionated Typst template for bachelor and master theses (and related protocols) at University of applied sciences Upper Austria, with a focus on Campus Hagenberg.

![Preview of the template content in modern variant](./thumbnail-flat-modern.png)
![Preview of the template content in classic variant](./thumbnail-flat-classic.png)

## Quick start

(recommended) Create a new project from the official template, then view the generated `main.typ` for a full working example:

```bash
typst init @preview/easy-hgb-thesis
```

To import the package in an existing document:

```typ
#import "@preview/easy-hgb-thesis:0.2.0": full-thesis

#set document(
  title: "Thesis Title",
  author: "Author Name",
  description: "Thesis Description",
)
#set text(lang: "en")
#show: full-thesis.with(
  // customizations...
)
```

## Customization

The template is well documented with inline comments and docstrings. Quick exploration should reveal most customization options for proficient Typst users.

There is a [manual](./easy-hgb-thesis-manual.pdf) for newcomers and detailed customization options for experienced users.

## Intent

Typst makes professional-quality publishing simple and accessible for everyone. I believe more people should benefit from its power and ease of use.

I made this template because I couldn’t find a high-quality, flexible FH thesis template. My goal is to help anyone start their thesis with Typst quickly and easily, while also giving advanced users the freedom to customize the template however they need without unnecessary limitations.

Concretely, this template provides a practical, production-ready thesis layout with:

- pre-structured front matter and content flow
- sensible defaults for typography and page layout
- bilingual labels and declarations
- an extensible API for section-level and document-level styling

## Beware

This template is far from its finished state.
It will evolve based on user feedback and my experience with it as part of my bachelor thesis during the winter term 2026/27. Expect continuous improvements during this period.

# Contributing

Feel free to open an issue or submit a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.
Even something simple like insights about your experience using the template is very valuable.
