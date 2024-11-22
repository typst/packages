# Typst Templates for the Corporate Design of TU Darmstadt :book:
These **unofficial** templates can be used to write in [Typst](https://github.com/typst/typst) with the corporate design of [TU Darmstadt](https://www.tu-darmstadt.de/).

#### Disclaimer
Please ask your supervisor if you are allowed to use typst and this template for your thesis or other documents.
Note that this template is not checked by TU Darmstadt for correctness.
Thus, this template does not guarantee completeness or correctness.
Also, note that submission in TUbama requires PDF/A which typst currently can't export to (https://github.com/typst/typst/issues/2942).
You can use a converter to convert from the typst output to PDF/A, but check that there are no losses during the conversion. CMYK color space support may be required for printing which is also currently not supported by typst (https://github.com/typst/typst/issues/2942), but this is not relevant when you just submit online.


## Implemented Templates
The templates imitate the style of the corresponding latex templates in [tuda_latex_templates](https://github.com/tudace/tuda_latex_templates).
Note that there can be visual differences between the original latex template and the typst template (you may open an issue when you find one).

For missing features, ideas or other problems you can just open an issue :wink:. Contributions are also welcome.

| Template | Preview | Example | Scope |
|----------|---------|---------|-------|
| [tudapub](https://github.com/JeyRunner/tuda-typst-templates/blob/main/templates/tudapub/template/tudapub.typ) | <img src="https://raw.githubusercontent.com/JeyRunner/tuda-typst-templates/refs/heads/main/templates/tudapub/preview/tudapub_prev-01.png" height="300px"> | [example_tudapub.pdf](https://github.com/JeyRunner/tuda-typst-templates/blob/main/example_tudapub.pdf) <br/> [example_tudapub.typ](https://github.com/JeyRunner/tuda-typst-templates/blob/main/example_tudapub.typ) | Master and Bachelor thesis |
| [tudaexercise](https://github.com/JeyRunner/tuda-typst-templates/blob/main/templates/tudaexercise/template/tudaexercise.typ) | <img src="https://raw.githubusercontent.com/JeyRunner/tuda-typst-templates/refs/heads/main/templates/tudaexercise/preview/tudaexercise_prev-1.png" height="300px"> | [Example File](https://github.com/JeyRunner/tuda-typst-templates/blob/main/templates_examples/tudaexercise/main.typ) | Exercises |

## Usage
Create a new typst project based on this template locally.
```bash
# for tudapub
typst init @preview/athena-tu-darmstadt-thesis
cd athena-tu-darmstadt-thesis

# for tudaexercise
typst init @preview/athena-tu-darmstadt-exercise
cd athena-tu-darmstadt-exercise
```
Or create a project on the typst web app based on this template.

<details>
<summary>Or do a manual installation of this template.</summary>
For a manual setup create a folder for your writing project and download this template into the `templates` folder:

```bash
mkdir my_exercise && cd my_exercise
mkdir templates && cd templates
git clone https://github.com/JeyRunner/tuda-typst-templates templates/
```
</details>

### Logo and Font Setup
Download the tud logo from [download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf](https://download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf) and put it into the `asssets/logos` folder.
Now execute the following script in the `asssets/logos` folder to convert it into an svg:

```bash
cd asssets/logos
./convert_logo.sh
```

Also download the required fonts `Roboto` and `XCharter`:
```bash
cd asssets/fonts
./download_fonts.sh
```
Now you can install all fonts in the folders in `fonts` on your system.

<details>
<summary>Create a main.typ file for the manual template installation.</summary>
Create a simple `main.typ` in the root folder (`my_thesis`) of your new project:

```typst
#import "templates/tuda-typst-templates/templates/tudaexercise/template/lib.typ": *

#show: tudaexercise.with(
  info: (
    title: "My Exercise",
    auhtor: "Your name",
    sheetnumber: 1    
  )
)

= My First Chapter
Some Text
```

</details>

### Compile you typst file

```bash
typst --watch main.typ --font-path asssets/fonts/
```

This will watch your file and recompile it to a pdf when the file is saved. For writing, you can use [Vscode](https://code.visualstudio.com/) with these extensions: [Typst LSP](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp) and [Typst Preview](https://marketplace.visualstudio.com/items?itemName=mgt19937.typst-preview). Or use the [typst web app](https://typst.app/) (here you need to upload the logo and the fonts).

Note that we add `--font-path` to ensure that the correct fonts are used.
Due to a bug (typst/typst#2917 typst/typst#2098) typst sometimes uses the font `Roboto condensed` instead of `Roboto`.
To be on the safe side, double-check the embedded fonts in the pdf (there should be no `Roboto condensed`).
What also works is to uninstall/deactivate all `Roboto condensed` fonts from your system.

## Todos
- [todos of thesis template](https://github.com/JeyRunner/tuda-typst-templates/blob/main/templates/tudapub/TODO.md)