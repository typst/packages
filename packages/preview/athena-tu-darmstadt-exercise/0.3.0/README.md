# Typst Templates for the TU Darmstadt Corporate Design
These **unofficial** templates enable you to write [Typst](https://github.com/typst/typst) documents in the [TU Darmstadt](https://www.tu-darmstadt.de/) corporate design.

#### Disclaimer
Please ask your supervisor if you are allowed to use Typst and one of these templates for your thesis or other documents.
Note that these templates are not checked by TU Darmstadt for correctness.
Thus, these templates don't guarantee completeness or correctness.
For notes about publishing on TUbama see [Publishing](#publishing-on-tubama).


## Implemented Templates

The templates copy the corresponding LaTeX templates found here: [tuda_latex_templates](https://github.com/tudace/tuda_latex_templates).
Note that there may be visual differences between the original LaTeX template and the Typst version.
Feel free to open an issue [here](https://github.com/tuda-typst/tuda-typst-templates/issues) if you find one!

For missing features, ideas or other problems, feel free to open an issue as well. Contributions are also welcome.

| Template | Preview | Example | Scope |
|----------|---------|---------|-------|
| [tudapub](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/tudapub/template/tudapub.typ) | <img src="https://raw.githubusercontent.com/tuda-typst/tuda-typst-templates/refs/tags/tudaexercise-0.3.0/tudapub/preview/tudapub_prev-01.png" height="300px" alt="An exemplary tudapub front cover"> | [example_tudapub.pdf](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/example_tudapub.pdf) <br/> [example_tudapub.typ](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/example_tudapub.typ) | Master and Bachelor theses |
| [tudaexercise](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/tudaexercise/template/tudaexercise.typ) | <img src="https://raw.githubusercontent.com/tuda-typst/tuda-typst-templates/refs/tags/tudaexercise-0.3.0/tudaexercise/preview/tudaexercise-light.png" height="300px" alt="An exemplary tudaexercise sheet"> | [Example File](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/tudaexercise/example/main.typ) | Exercises |
| [not-tudabeamer-2023](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/tudabeamer/template/lib.typ) | <img src="https://raw.githubusercontent.com/tuda-typst/tuda-typst-templates/refs/tags/tudaexercise-0.3.0/tudabeamer/preview/thumbnail.webp" height="300px" alt="An exemplary tudabeamer title slide"> | [Example File](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/tudabeamer/example/main.typ) | Presentations |

## Usage
To create a new Typst project based on one of these templates locally:
```bash
# for tudapub
typst init @preview/athena-tu-darmstadt-thesis
cd athena-tu-darmstadt-thesis

# for tudaexercise
typst init @preview/athena-tu-darmstadt-exercise
cd athena-tu-darmstadt-exercise

# for not-tudabeamer-2023
typst init @preview/not-tudabeamer-2023
cd not-tudabeamer-2023
```
You can also create a project on the Typst web app based on these templatess.

<details>
<summary>Manual Installation</summary>
For a manual setup create a folder for your writing project and clone this template into the `templates` folder:

```bash
mkdir my_thesis && cd my_thesis
mkdir templates && cd templates
git clone https://github.com/tuda-typst/tuda-typst-templates
```
</details>

### Logo and Font Setup
Download the TUDa logo from [download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf](https://download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf) and put it into the `assets/logos` folder.
Since Typst 0.14.0, you can use the logo PDF file directly.
If you use an earier version of Typst, see below for instructions on how to convert the logo to an SVG file.

<details>
<summary>Converting the Logo to SVG</summary>
Now execute the following script in the `assets/logos` folder to convert it into an svg:

```bash
cd assets/logos
./convert_logo.sh
```

Note: This script uses the `pdf2svg` command, which might not be available to you. In this case we recommend a online converter such as [PDF24 Tools](https://tools.pdf24.org/en/pdf-to-svg). There is also a [tool](https://github.com/FussballAndy/typst-img-to-local) to install images as local Typst packages.
</details>

Also download the required fonts `Roboto` and `XCharter`:
```bash
cd assets/fonts
./download_fonts.sh
```
Optionally, you can install all fonts in the folders in `fonts` on your system.
Alternatively, you can also use Typst's `--font-path` option or install them in a folder and add the folder to the `TYPST_FONT_PATHS` environment variable.

Note: `wget` might not be available to you. You may replace the command with something like `curl <url> -o <filename> -L`

<details>
<summary>Creating a `main.typ` File after Manual Template Installation.</summary>
Create a simple `main.typ` in the root folder (e.g., `my_thesis`) of your new project:

```typ
#import "templates/tuda-typst-templates/tudapub/template/lib.typ": *

#show: tudapub.with(
  title: [
    My Thesis
  ],
  author: "My Name",
  accentcolor: "3d"
)

= My First Chapter
Some Text
```

</details>

### Compiling Your Typst File

```bash
typst watch main.typ --font-path assets/fonts/
```

This will watch your file and recompile it to a PDF when the file is saved. For writing, you can use [VS Code](https://code.visualstudio.com/) with [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist).
Alternatively, use the [Typst web app](https://typst.app/). Note that you'll have to upload your logos and fonts manually.

Note that we add `--font-path` to ensure that the correct fonts are used.
Due to a bug, Typst sometimes uses the font `Roboto condensed` instead of `Roboto`.
To be on the safe side, double-check the embedded fonts in the pdf: There should be no `Roboto condensed`.
Removing `Roboto condensed` from your system prevents this issue.

### Publishing on TUbama
For publishing your compiled document (e.g. thesis) on TUbama, the document has to comply with the pdf/A standard. 
Therefore, set the PDF standard for compiling for the final submission:
```bash
typst compile main.typ --font-path assets/fonts/ --pdf-standard a-2b
```
In case this should not yield a PDF which is accepted by TUbama, you can use a converter to convert from the Typst output to PDF/A, but check that there are no losses during the conversion.

## Contributing

See [CONTRIBUTING.md](https://github.com/tuda-typst/tuda-typst-templates/blob/tudaexercise-0.3.0/CONTRIBUTING.md)
