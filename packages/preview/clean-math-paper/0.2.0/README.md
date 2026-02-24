# clean-math-paper

[![Build Typst Document](https://github.com/JoshuaLampert/clean-math-paper/actions/workflows/build.yml/badge.svg)](https://github.com/JoshuaLampert/clean-math-paper/actions/workflows/build.yml)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/JoshuaLampert/clean-math-paper)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

[Typst](https://typst.app/home/) paper template for mathematical papers built for simple, efficient use and a clean look.
Of course, it can also be used for other subjects, but the following math-specific features are already contained in the template:

- theorems, lemmas, corollaries, proofs etc. prepared using [great-theorems](https://typst.app/universe/package/great-theorems)
- equation settings

## Set-Up

The template is already filled with dummy data, to give users an impression how it looks like. The paper is obtained by compiling `main.typ`.

- after [installing Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) you can conveniently use the following to create a new folder containing this project.

```bash
typst init @preview/clean-math-paper:0.2.0
```

- edit the data in `main.typ` → `#show template.with([your data])`

### Parameters of the Template

- `title`: Title of the paper.
- `authors`: List of names of the authors of the paper. Each entry of the list is a dictionary with the following keys:
  - `name`: Name of the author.
  - `affiliation-id`: The ID of the affiliation in `affiliations`, see below.
  - optionally `orcid`: The [ORCID](https://orcid.org/) of the author. If provided, the author's name will be linked to their ORCID profile.
- `affiliations`: List of affiliations of the authors. Each entry of the list is a dictionary with the following keys:
  - `id`: ID of the affiliation, which is used to link the authors to the affiliation, see above.
  - `name`: Name of the affiliation.
- `date`: Date of the paper.
- `heading-color`: Color of the headings including the title.
- `link-color`: Color of the links.
- `abstract`: Abstract of the paper. If not provided, nothing will be shown.
- `keywords`: List of keywords of the paper. If not provided, nothing will be shown.
- `AMS`: List of AMS subject classifications of the paper. If not provided, nothing will be shown.

## Acknowledgements

Some parts of this template are based on the [arkheion](https://github.com/mgoulao/arkheion) template.

## Feedback & Improvements

If you encounter problems, please open issues. In case you found useful extensions or improved anything We are also very happy to accept pull requests.
