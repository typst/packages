# ISMIN Report _Template_

This _template_ is the one I use to write my reports at EMSE.
It uses the Typst language and was greatly inspired by [Timothé Dupuch's template](https://github.com/thimotedupuch/Template_Rapport_ISMIN_Typst),
the [Bubble _template_](https://github.com/hzkonor/bubble-template),
the [ilm _template_](https://github.com/talal/ilm),
and the [Diatypst _template_](https://github.com/skriptum/Diatypst).
Many of the typographic rules were drawn from [_Butterick's Practical Typography_](https://practicaltypography.com/).
I also recommend reading _Règles françaises de typographie mathématique_ by Alexandre André, available [here](http://sgalex.free.fr/typo-maths_fr.pdf).

The file [`manuscr-ismin.pdf`](https://github.com/senaalem/manuscr-ismin/blob/56a37c85d57dbdb37df4128097e57bcaf265cec9/manuscr-ismin.pdf) is a PDF preview of the compiled output.
I have tried to showcase all the possibilities offered by Typst and the `manuscr-ismin` function; the content is obviously meant to be adjusted to your needs.

To learn more about Typst and its functions, you can refer to [the documentation](https://typst.app/docs), which is very comprehensive.
Ctrl+Click (or Cmd+Click) also works on functions in the web app editor.

## Usage

I recommend using the [Typst web app](https://typst.app/), but it is also possible to install the compiler as a CLI tool on your machine.
A great setup is Visual Studio Code with the Tinymist extension.
- The `template.typ` file contains all the display rules and functions,
- the `main.typ` file contains the content you want to include in the report,
- the `bibs.yaml` file contains bibliographic references (in Hayagriva format, but Typst also supports BibLaTeX — swap the file as you see fit),
- the `assets` directory contains the graphic resources for the _template_ theme,
- the `images` directory contains the images included in the document.

### `manuscr-ismin`

All configuration is done directly through the parameters of the `manuscr-ismin` function in `main.typ`.
Below is a description of its parameters:

- `title`: the document title (required),
- `subtitle`: the subtitle,
- `school`: information about the school, as a dictionary:
  - `name`: the school name,
  - `subname`: the campus or subdivision name;
- `course`: information about the course, as a dictionary:
  - `ue`: the label displayed for the teaching unit (e.g. `"UE"`),
  - `ecue`: the label displayed for the constituent element (e.g. `"ECUE"`),
  - `name`: the name of the teaching unit,
  - `subname`: the name of the constituent element;
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
- `show-imt-triangle`: boolean to show or hide the decorative IMT triangle on the cover page (default: `true`),
- `latex-look`: boolean to use _New Computer Modern_ fonts instead of the default ones, for a LaTeX-like appearance (default: `false`),
- `main-colour`: the document's primary colour; defaults to the EMSE purple (`violet-emse`),
- `other-colour`: the document's secondary colour, used notably for the decorative triangle; defaults to the IMT blue (`blue-imt`),
- `lang`: changes typographic rules to suit either the French or the English language; can be `"fr"` or `"en"`.

### Functions and colours

- `violet-emse`: the EMSE purple colour,
- `gray-emse`: the EMSE grey colour,
- `blue-imt`: the IMT blue colour,
- `lining`: use to get lining (classic) numerals locally; old-style figures blend well with lowercase text, but not with uppercase,
- `arcosh`: the inverse hyperbolic cosine function for math mode.