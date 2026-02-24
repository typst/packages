# Manuscr-ISMIN

This template is the one I use to write my reports at the EMSE.
It uses the Typst language and is largely inspired by [Timothé Dupuch's template](https://github.com/thimotedupuch/Template_Rapport_ISMIN_Typst),
the [Bubble template](https://github.com/hzkonor/bubble-template),
the [ilm template](https://github.com/talal/ilm),
and finally the [Diatypst template](https://github.com/skriptum/Diatypst).
Many of the typography rules were taken from [Butterick's Practical Typography](https://practicaltypography.com/).

The `template_report_ISMIN.pdf` file in the [GitHub repository](https://github.com/senaalem/ISMIN_reports_template) is a PDF preview of the compilation result.
I tried to show all the possibilities that Typst offers, with the content obviously being adjustable as you wish.

To learn more about Typst functions and usage, you can use [the documentation](https://typst.app/docs), it's very comprehensive.
Ctrl+Click (or Cmd+Click) also works on functions (in the web application editor).

## Usage

Copy the following code at the beginning of the document:

```typ
#import "@preview/manuscr-ismin:0.1.0": *

#show: manuscr-ismin.with(
  title: "Title",
  subtitle: "Subtitle",
  authors: (
    (
      name: "Auteur 1",
      affiliation: "Filière 1",
      year: "Année 1",
      class: "Classe 1"
    ),
    (
      name: "Auteur 2",
      affiliation: "Filière 2",
      year: "Année 2",
      class: "Classe 2"
    )
  ),
  logo: "assets/logo_emse_white.svg",
  header-title: "Header 1",
  header-subtitle: "Header 3",
  header-middle: [Header 2],
  date: "Date"
)
```

For the logo, you can either get the one in the GitHub repository or go the the [EMSE intranet](https://www.mines-stetienne.fr/intranet/).

### `manuscr-ismin`

Here's a description of the `manuscr-ismin` function parameters:
- `title`: the document title (required)
- `subtitle`: the subtitle
- `authors`: authors field in dictionary form; to use only one author, don't forget to still leave a comma at the end
    - `name`: the author's name
    - `affiliation`: the author's department
    - `year`: the author's year in their curriculum
    - `class`: the author's class
- `date`: the date
- `logo`: the logo you want to use; by default, it's the EMSE logo
- `main-color`: the document's theme color; by default, it's "violet EMSE"
- `header-title`: the left text in the header
- `header-middle`: the centered and bold text in the header
- `header-subtitle`: the right and italic text in the header
- `body-font`: the font for body text; by default, it's Libertinus Serif but for a LaTeX look, use New Computer Modern
- `code-font`: the font for the `raw` function; by default, it's Cascadia Mono but for a __really__ LaTeX look, use New Computer Modern Mono
- `math-font`: the font for the `equation` function; by default, it's New Computer Modern Math
- `mono-font`: the font for the non-native `mono` function; by default it's Libertinus Mono (use a monospace font)
- `number-style`: the number style; by default in `"old-style"` (so oldstyle figures), can be changed to `"lining"` (classic figures)

### Functions

- `violet-emse`: EMSE's purple color
- `gray-emse`: EMSE's gray color
- `lining`: to have numbers in classic style locally if you chose "old-style"; oldstyle figures integrate well with lowercase text, but poorly with uppercase text.
    For example, `#lining[STM32L436RG]` will be much more elegant than `STM32L476RG` if you're using oldstyle figures by default.
- `arcosh`: the hyperbolic arc cosine function for math mode
- `mono`: to use for quickly returning monospace text without the formatting of `raw`.
    To use for example to indicate file names: `toto_tigre.png`

Aside from that, the template also replaces points with commas in math mode, so just use a point to render decimal numbers (commas insert a space after the number); for instance :
```typ
$ y: x arrow.r.bar 2.3 x + 5.7 $
```
