# ISMIN Report _Template_

This _template_ is the one I use to write my reports at EMSE.
It uses the Typst language and was greatly inspired by [Timothé Dupuch's template](https://github.com/thimotedupuch/Template_Rapport_ISMIN_Typst),
the [Bubble _template_](https://github.com/hzkonor/bubble-template),
the [ilm _template_](https://github.com/talal/ilm),
and the [Diatypst _template_](https://github.com/skriptum/Diatypst).
Many of the typographic rules were drawn from [_Butterick's Practical Typography_](https://practicaltypography.com/).
I also recommend reading _Règles françaises de typographie mathématique_ by Alexandre André, available [here](http://sgalex.free.fr/typo-maths_fr.pdf).

The file `template_report_ISMIN.pdf` is a PDF preview of the compiled output.
I have tried to showcase all the possibilities offered by Typst and the `manuscr-ismin` function; the content is obviously meant to be adjusted to your needs.

To learn more about Typst and its functions, you can refer to [the documentation](https://typst.app/docs), which is very comprehensive.
Ctrl+Click (or Cmd+Click) also works on functions in the web app editor.

## Usage

I recommend using the [Typst web app](https://typst.app/), but it is also possible to install the compiler as a CLI tool on your machine.
A great setup is Visual Studio Code with the Tinymist extension.
- The `template.typ` file contains all the display rules and functions,
- the `main.typ` file contains the content you want to include in the report,
- the `bibs.yaml` file contains bibliographic references (in Hayagriva format, but Typst also supports BibLaTeX — swap the file as you see fit),
- the `conf.yaml` file is used to configure the fonts used in the document, the main colour (by default, the EMSE purple) and the secondary colour,
- the `assets` directory contains the graphic resources for the _template_ theme,
- the `images` directory contains the images included in the document.

### `conf.yaml`

#### Fonts

Each font is defined by a sub-dictionary with two fields: `font` (the font name) and `options` (a list of OpenType features to enable).
Be careful with the YAML file — font names must be exact.
For example, to get a default LaTeX look:

```yml
fonts:
  body:
    font: "New Computer Modern"
    options: []
  code:
    font: "New Computer Modern Mono"
    options: []
  math:
    font: "New Computer Modern Math"
    options: ["ss03"]
  mono:
    font: "New Computer Modern Mono"
    options: []
  sans:
    font: "New Computer Modern Sans"
    options: []
```

#### Colours

Two colours are defined as hexadecimal strings: `main-colour` for the document's primary colour, and `other-colour` for the secondary colour (used for example for the decorative IMT triangle on the cover page).
For example:
```yml
main-colour: "#FF6347"
other-colour: "#00E81F"
```

### `manuscr-ismin`

Below is a description of the parameters of the `manuscr-ismin` function:
- `title`: the document title (required),
- `subtitle`: the subtitle,
- `school`: information about the school, as a dictionary:
  - `name`: the school name,
  - `subname`: the campus or subdivision name;
- `course`: information about the course, as a dictionary:
  - `ue`: the name of the teaching unit (at ISMIN, UE),
  - `ecue`: the name of the constituent element of a teaching unit (at ISMIN, ECUE),
  - `name`: the UE name,
  - `subname`: the ECUE name;
- `authors`: list of authors, each as a dictionary; if using only one author, do not forget to leave a trailing comma:
  - `name`: the author's name,
  - `affiliation`: the author's track/programme,
  - `email`: their email address;
- `mentor1`, `mentor2`: supervisors, each as a dictionary:
  - `role`: the role (e.g. `"Supervisor"`, `"Co-supervisor"`),
  - `name`: the name,
  - `email`: the email address;
- `date`: the date,
- `academic-year`: the academic year,
- `logo`: the logo to use; defaults to the EMSE logo,
- `header`: the header content (free Typst content),
- `show-imt-triangle`: boolean to show or hide the decorative IMT triangle on the cover page (default: `true`).

### Functions

- `violet-emse`: the EMSE purple colour,
- `gray-emse`: the EMSE grey colour,
- `blue-imt`: the IMT blue colour,

- `lining`: use to get lining (classic) numerals locally; old-style figures blend well with lowercase text, but not with uppercase.
	For example, `#lining[STM32L436RG]` looks much better than `STM32L476RG`,
- `arcosh`: the inverse hyperbolic cosine function for math mode (I needed it),
- `mono`: use to quickly render text in monospace without the formatting of `raw`;
	useful for example to indicate file names: `#mono[toto_tigre.png]`,
- `sans`: use to quickly render text in sans-serif (e.g. `#sans[adder]`),

- `body-font`: the font used for body text,
- `code-font`: the font used by the `raw` function,
- `math-font`: the font used for mathematical equations,
- `mono-font`: the font used by the `mono` function,
- `sans-font`: the font used by the `sans` function,

- `primary-colour`: the document's default colour,
- `other-colour`: the document's secondary colour,
- `block-colour`, `body-colour`, `header-colour`, `fill-colour`: lightened colours derived from `primary-colour`.