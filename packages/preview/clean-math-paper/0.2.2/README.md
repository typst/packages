# clean-math-paper

[![Build Typst Document](https://github.com/JoshuaLampert/clean-math-paper/actions/workflows/build.yml/badge.svg)](https://github.com/JoshuaLampert/clean-math-paper/actions/workflows/build.yml)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/JoshuaLampert/clean-math-paper)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

[Typst](https://typst.app/home/) paper template for mathematical papers built for simple, efficient use and a clean look.
Of course, it can also be used for other subjects, but the following math-specific features are already contained in the template:

- theorems, lemmas, corollaries, proofs etc. prepared using [great-theorems](https://typst.app/universe/package/great-theorems)
- equation settings

## Set-Up

The template is already filled with dummy data, to give users an impression what it looks like. The paper is obtained by compiling `main.typ`.

- after [installing Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) you can conveniently use the following to create a new folder containing this project.

```bash
typst init @preview/clean-math-paper:0.2.2
```

- edit the data in `main.typ` → `#show template.with([your data])`

### Parameters of the Template

- `title`: Title of the paper.
- `authors`: List of names of the authors of the paper. Each entry of the list is a dictionary with the following keys:
  - `name`: Name of the author.
  - `affiliation-id`: The ID of the affiliation in `affiliations`, see below. Can also be left empty.
  - optionally `orcid`: The [ORCID](https://orcid.org/) of the author. If provided, the author's name will be linked to their ORCID profile.
- `affiliations`: List of affiliations of the authors. Each entry of the list is a dictionary with the following keys:
  - `id`: ID of the affiliation, which is used to link the authors to the affiliation, see above. Can also be left empty.
  - `name`: Name of the affiliation.
- `date`: Date of the paper.
- `abstract`: Abstract of the paper. If not provided, nothing will be shown.
- `keywords`: List of keywords of the paper. If not provided, nothing will be shown.
- `AMS`: List of AMS subject classifications of the paper. If not provided, nothing will be shown.
- `lang`: Language of the paper. Supported languages are English, German, French, and Spanish, default is "en".
- `translations`: Dictionary to override the language translations. Please refer to the `Support for languages` section for more information.
- `heading-color`: Color of the headings including the title.
- `link-color`: Color of the links.
- `lines`: Boolean to enable or disable the horizontal lines around the title. Default is `true`.

### Support for mathblocks

This template uses the [great-theorems](https://typst.app/universe/package/great-theorems) package to provide a set of mathblocks. Currently, the following blocks are available: `theorem`, `proposition`, `corollary`, `lemma`, `definition`, `remark`, `example`, `question`, and `proof`. If you want to define your own block, you can do this, e.g., by

```typst
#let answer = my-mathblock(
  blocktitle: "Answer",
  bodyfmt: text.with(style: "italic"),
)
```

where `my-mathblock` already includes the counter shared between mathblocks. You can also directly use `mathblock` instead if you do not want to use the default setting used in this template.

### Support for languages

This template includes translations for English, German, French, and Spanish. To use one of these languages, set the lang parameter to `en`, `de`, `fr`, or `es`:

```typst
#show: template.with(
  lang: "en"
)
```

For languages not included by default, or to override existing translations:

- set `lang` to your language's ISO code (see [Typst docs](https://typst.app/docs/reference/text/text/#parameters-lang))
- provide a `translations` dictionary with your custom translations, like below

```typst
#show: template.with(
  lang: "en",
  translations: (
    "theorem": "Theorem",
    "proposition": "Proposition",
    "corollary": "Corollary",
    "lemma": "Lemma",
    "definition": "Definition",
    "remark": "Remark",
    "example": "Example",
    "question": "Question",
    "proof": "Proof",
    "keywords": "Keywords",
    "ams": "AMS subject classification",
    "appendix": "Appendix",
    "abstract": "Abstract",
  )
)
```

To modify specific translations for a supported language, a partial dictionary is enough. Only the specified keys will be overridden.

## Acknowledgements

Some parts of this template are based on the [arkheion](https://github.com/mgoulao/arkheion) template.

## Feedback & Improvements

If you encounter problems, please open issues. In case you found useful extensions or improved anything We are also very happy to accept pull requests.
