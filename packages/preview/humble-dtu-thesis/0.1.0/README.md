# DTU Thesis Template for Typst

This is a Typst template for writing a **Thesis** at the **Technical University of Denmark (DTU)**. It provides a structured document format similar to LaTeX but using Typst for **simplicity, flexibility, and modern features**.

The original Latex template this is based on and related DTU Latex can be found at [Overleaf DTU](https://www.overleaf.com/edu/dtu#overview)

## 📥 Installation & Usage
You can use this template in the Typst web app by clicking “Start from template” on the dashboard and search for this, humble-dtu-thesis.

Alternatively, you can use the CLI to kick this project off locally using the command
```sh
typst init @preview/humble-dtu-thesis
```

This will create a new project based on this template.

## 📑 Template Structure
The template follows a structured layout:
```
humble-dtu-thesis/
├── main.typ   <-- Thesis entrypoint
├── works.bib  <-- Bibliography file
├── sections/  <-- Thesis sections (introduction, conclusion, etc.)
```

## 🛠 Features
- 📖 **Predefined thesis structure** (title page, abstract, chapters, bibliography, appendices)
- 🎨 **DTU-styled formatting** (matching DTU design guidelines)
- 📑 **Reference management** (BibTeX integration)

## How to use
After initializing the project then simply create your new files in `sections` and include them in the bottom of the `main.typ` file. \
**Note:** that included packages are `@acrostiche` [package link](https://typst.app/universe/package/acrostiche/), for acronyms. 

### ℹ️ Core information
Inside of the `main.typ` file in the `#show`, update the relevant information like title, description, department, etc. This will then be updated throughout the paper and existing pages. 

### 🎨 Fonts
To add new fonts not available already, simply download it's files and add them anywhere inside the template or a dedicated folder, E.g. `tooling/fonts/YourFont`.
The font is set at the start of the `main.typ` file. Simply change the current font inside of this file to the one you've downloaded. 

how the code looks -> `set text(font: "Neo Sans Pro", lang: "en")` \
DTU typography information or other guidelines can be found https://designguide.dtu.dk/typography

### 😎 Functions and extra features
- You can also swap out the whole frontpage content or lastpage's background-color. Simply add these to the end of `#show: dtu-project.with`
    -   `frontpage-input: include "path-to-frontpage",`
    -   `background-color: rgb("#224ea9")`,
- You can utilize `#add-note` and `#show-all-notes()` to do some simple note making. 
- The package can be looked further into at [github typst packages repository](https://github.com/typst/packages/tree/main/packages/preview/humble-dtu-thesis) Inside the `functions.typ` and `lib.typ` files primarily.

Enjoy the template, and feel free to expand or improve the project/template if you wish. 😉

## 📜 License
This template is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

By using this template, you agree to the terms of this license, which allows sharing and adaptation with appropriate attribution. 

Enjoy writing your thesis with Typst! 🚀

