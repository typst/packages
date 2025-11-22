# clean-math-presentation

[![Build Typst Document](https://github.com/JoshuaLampert/clean-math-presentation/actions/workflows/build.yml/badge.svg)](https://github.com/JoshuaLampert/clean-math-presentation/actions/workflows/build.yml)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/JoshuaLampert/clean-math-presentation)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

[Typst](https://typst.app/home/) template for presentations built for simple, efficient use and a clean look
using [touying](https://touying-typ.github.io/).
The template provides a custom title page, a footer, a header, and built-in support for theorem blocks and
proofs.

## Usage

The template is already filled with dummy data, to give users an impression how it looks like. The presentation is obtained by compiling `main.typ`.

- after [installing Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) you can conveniently use the following to create a new folder containing this project.

```bash
typst init @preview/clean-math-presentation:0.1.1
```

- edit the data in `main.typ` → `#show clean-math-presentation.with([your data])`

### Parameters of the Template

- `title`: Title of the presentation.
- `subtitle`: Subtitle of the presentation, optional.
- `short-title`: Short version of the presentation to be shown in the footer, optional.
  If not short title is provided, the `title` will be shown in the footer.
- `date`: Date of the presentation.
- `authors`: List of names of the authors of the presentation. Each entry of the list is a dictionary with the following keys:
  - `name`: Name of the author.
  - `affiliation-id`: The ID of the affiliation in `affiliations`, see below.
- `affiliations`: List of affiliations of the authors. Each entry of the list is a dictionary with the following keys:
  - `id`: ID of the affiliation, which is used to link the authors to the affiliation, see above.
  - `name`: Name of the affiliation.
- `author`: The name of the presenting author, which will be displayed in the footer of each slide. If the `author`
  matches one of the `authors`, this name will be underlined in the title slide.

Other arguments like `align`, `progess-bar` and more
are available and similar to other templates in touying, especially the
[stargazer theme](https://touying-typ.github.io/docs/themes/stargazer).
The colorscheme can be adjusted by passing `config-colors` to the template, e.g.
```typ
config-colors(
  primary: rgb("#6068d6"),
  secondary: rgb("#2f1971"),
)
```
The title page can be created with `#title-slide`. It accepts optionally a `background`, which can be an image or `none` (default)
and up to two logos `logo1` and `logo2` (`none` by default).

The theme provides different types of slides like `#outline-slide`, `#focus-slide`, `#ending-slide`, and the usual `#slide`.
Additionally,it already provides support for theorems and alike by the functions `#theorem`, `#lemma`,
`#corollary`, `#definition`, `#example`, and `#proof`.

## Acknowledgements

Some parts of this template are based on the [stargazer](https://github.com/touying-typ/touying/blob/main/themes/stargazer.typ)
theme from touying.

## Feedback & Improvements

If you encounter problems, please open issues. In case you found useful extensions or improved anything We are also very happy
to accept pull requests.
