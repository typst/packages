# ls3-uni-stuttgart-thesis

Bachelor's and master's thesis template of the Department of Stochastic
Simulation and Safety Research for Hydrosystems, LS3, at the Institute
for Modelling Hydraulic and Environmental Systems, University of
Stuttgart. German or English, two-sided printing, with cover, title
page, declaration including the AI tools statement, abstracts, and
front matter.

## Start a thesis

In the typst.app web app, choose "Start from template" and search for
`ls3-uni-stuttgart-thesis`. On your own machine, run

```bash
typst init @preview/ls3-uni-stuttgart-thesis:0.1.0 my-thesis
```

Then open `main.typ`, fill in your metadata, and write your chapters in
`chapters/`.

## Logos

The University of Stuttgart logo and the LS3 logo ship with the package
and appear on the cover without any setup. The cover crops the official
university logo, drops the "Germany" line of the English version, and
sets the institute and department below it from `institute` and
`chair`.

To use a different logo, pass your own file from the project. Pass
`none` to leave a logo out.

```typst
#import "@preview/ls3-uni-stuttgart-thesis:0.1.0": thesis

#show: thesis.with(
  chair-logo: image("my_logo.png"),
  // ...
)
```

A replacement chair logo is set 25mm wide to fit the white disc unless
you give it a size. A replacement university logo must be one of the
official PDFs from the
[corporate design page](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/logo-und-schrift/),
because the crop is measured on them.

## Font

The template uses TeX Gyre Heros, a free Helvetica clone. The typst.app
web app has it built in. On your own machine, install it from
[CTAN](https://ctan.org/pkg/tex-gyre-heros), or pick another sans font
with `sans-font`. Liberation Sans is a close match.

```typst
#import "@preview/ls3-uni-stuttgart-thesis:0.1.0": thesis

#show: thesis.with(sans-font: "Liberation Sans", /* ... */)
```

## Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `[]` | Thesis title |
| `cover-title` | `auto` | Title on the cover, may use `\` for line breaks |
| `author` | `""` | Your name |
| `matriculation-number` | `""` | Your matriculation number |
| `degree` | `"master"` | `"bachelor"` or `"master"` |
| `language` | `"english"` | `"english"` or `"german"` |
| `date` | `""` | Submission date |
| `examiners`, `supervisors` | `()` | Arrays of names |
| `abstract-en`, `abstract-de` | `none` | Abstract content |
| `abbreviations`, `notation` | `none` | Optional front matter chapters |
| `bib` | `none` | A `bibliography(...)` element |
| `ai-tools` | `none` | AI tools statement, see `main.typ` |
| `body-font` | `"sans"` | `"sans"`, or `"serif"` for a LaTeX-like body |
| `sans-font` | `auto` | Font family or list of families for sans text |
| `institute`, `chair` | `auto` | Institute and chair, on the cover and the title page |
| `university-logo` | `auto` | Bundled university logo, an official logo PDF, or `none` |
| `chair-logo` | `auto` | Bundled LS3 logo in the white disc, any image, or `none` |
| `heading-rule` | `false` | `true` draws a thin blue rule below every chapter heading |

## License

The package is MIT licensed, see `LICENSE`. Source, issues, and pull
requests live at
[LS3-university-of-stuttgart/ls3-typst-templates-public](https://github.com/LS3-university-of-stuttgart/ls3-typst-templates-public). The files in `template/`,
which `typst init` copies into your project, are under MIT-0, so your
thesis carries no license obligations.

## Changelog

### 0.1.0

First release on Typst Universe. The University of Stuttgart and LS3
logos are bundled and can be replaced or left out with `university-logo`
and `chair-logo`. The cover crops the official university logo and sets
the institute and chair lines in Typst. A different sans font can be set
with `sans-font`. Chapter headings have no rule below them by default,
`heading-rule: true` adds one. Code listings use codly 2.0.0, so the
template needs Typst 0.15.0 or newer.
