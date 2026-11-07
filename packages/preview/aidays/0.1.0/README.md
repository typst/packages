# Swiss AI Days 2027

Official paper template for Swiss AI Days 2027, adapted from the conference's
LaTeX style. Authored and maintained by
[Olivier D'Ancona](https://github.com/ODAncona).
Requires **Typst 0.15 or later**.

## Usage

Create a paper from the published template:

```sh
typst init @preview/aidays:0.1.0 my-paper
cd my-paper
typst compile main.typ paper.pdf
typst compile --input accepted=true main.typ paper-final.pdf
```

The default is an anonymous submission. The last command produces the
camera-ready version with authors and affiliations. In the Typst web app,
choose the `aidays` template from Typst Universe and start a new project.

The starter in `template/` contains `main.typ` and its bibliography `main.bib`.
Replace the sample content with your manuscript.

The development repository also contains the adapted author instructions and
examples in `main.typ`; see the
[example PDF](https://gitlab.forge.hefr.ch/olivier.dancona/aidays-typst/-/blob/main/example-paper.typst.pdf).

## Configuration

Import `@preview/aidays:0.1.0` and apply `#show: aidays.with(...)` as in the starter:

```typst
#import "@preview/aidays:0.1.0": aidays
#show: aidays.with(
  title: [My Paper Title],
  accepted: false,
  abstract: [A brief, self-contained summary of the paper.],
)

= Introduction
The paper starts here.
```

| Argument | Description |
| --- | --- |
| `title` | Full paper title. |
| `short-title` | Optional one-line running title. |
| `authors` | Author records with `name`, `affiliations`, and optional `equal`, `email`, and `corresponding`. |
| `affiliations` | Affiliation identifiers mapped to their text. |
| `abstract` | Abstract content. |
| `keywords` | PDF metadata keywords. |
| `accepted` | `false` for anonymous review, `true` for camera-ready. |
| `font` | Installed Times-compatible font; defaults to Times New Roman. |

Use `acknowledgements[...]` to show acknowledgements only in the accepted
version, and `appendix[...]` for a one-column appendix on a new page
(`appendix(columns: 2)[...]` for two columns).

## Fonts

The original `said2027.sty` loads `times`, and its instructions require 10-point
Times text. This template uses Times New Roman by default. Font files are not
included: Typst uses fonts available in your system or in the web editor.

Run `typst fonts` to check the fonts available locally. If Times New Roman is
unavailable, install a Times-compatible alternative such as
[TeX Gyre Termes](https://ctan.org/pkg/tex-gyre), then select it:

```sh
typst compile --input font="TeX Gyre Termes" main.typ paper.pdf
```

If the font is not installed in a system font directory, add
`--font-path /path/to/font-directory`.

Times New Roman is not supplied by the Typst web app. In that editor, check the
font list and set `font: "TeX Gyre Termes"` in `main.typ` if available, or upload
the selected font's `.otf`/`.ttf` files to your own project.
Always check the compiler for missing-font warnings before submitting a paper.

Typst embeds OpenType/CID fonts, whereas the original LaTeX instructions mention
Type-1 fonts. Keep fonts embedded and avoid Type-3 fonts in imported graphics.
The implementation follows `said2027.sty` where its layout differs from the
prose instructions.

## License and attribution

The native Typst implementation (`aidays.typ`) and citation style (`aidays.csl`)
are licensed under **MIT**; see [LICENSE](LICENSE).
Copyright 2026 Olivier D'Ancona.

The starter files in `template/` are licensed under **MIT-0**; see
[template/LICENSE](template/LICENSE). Authors may use, modify, and distribute
their manuscripts without attributing this template or including its license.
The package licenses do not apply to authors' own research or manuscript content.

The LaTeX-derived author instructions and their rendered example PDF remain
**CC BY 4.0** in the development repository (`LICENSE-CC-BY`). These documentation
files are not included in the published package. The MIT license does not
relicense the original LaTeX material.

Adapted from the Swiss AI Days 2027 LaTeX
template by Andrei Kucharavy (21 September 2026), itself derived from the
ICML 2025 template. The source credits Pat Langley, Andrea Danyluk, Iain Murray,
Alexandre Bouchard, Csaba Szepesvari, Gang Niu, Sivan Sabato, Jonathan Scarlett,
Tegan Maharaj, Felix Berkenkamp, Dan Roy, Lise Getoor, Tobias Scheffer,
Thorsten Joachims, Johannes Fuernkranz, Kiri Wagstaff, Sam Roweis,
Prasad Tadepalli, Andrew Moore, Kristian Kersting, Codrina Lauth, Alex Smola,
Terran Lane, Ricardo Silva, Fei Sha, Sanjoy Dasgupta, Francesco Figari,
Christoph Sawade, and Daniel Roy. See the original sources for their history.

This adaptation replaces the LaTeX macros with Typst styling and a CSL citation
style, adapts the example instructions, and adds institutional publisher fields
to the sample bibliography for Typst compatibility.

## Maintenance (development repository)

Edit the sources in this repository. Prepare the release with:

```sh
python3 publish.py
```

This synchronizes the package into `.publication/typst-packages`, a persistent
Git checkout of your GitHub fork. It prints the normal `git add`, `git commit`,
and `git push` commands; pushing updates the existing PR. No GitHub API calls
or temporary publication directories are needed.

For a later release, after the preceding version has been accepted, change
`version` in `typst.toml` and run the same command. The helper updates the
versioned imports and prepares a new `aidays-VERSION` branch. Previous published
versions are retained.

To set up the publication checkout on another machine:

```sh
git clone --filter=blob:none --depth 1 --single-branch --branch aidays-0.1.0 --sparse \
  https://github.com/ODAncona/typst-packages.git .publication/typst-packages
git -C .publication/typst-packages sparse-checkout set packages/preview/aidays
git -C .publication/typst-packages remote add upstream https://github.com/typst/packages.git
```

The source repository's `origin` remains on GitLab; the publication checkout's
`origin` is your GitHub fork and its `upstream` is `typst/packages`.
