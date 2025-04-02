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
├── images/    <-- DTU logos and images
├── sections/  <-- Thesis sections (introduction, conclusion, etc.)
├── tooling/   <-- Functions, preamble, and DTU styling
```

## 🛠 Features
- 📖 **Predefined thesis structure** (title page, abstract, chapters, bibliography, appendices)
- 🎨 **DTU-styled formatting** (matching DTU design guidelines)
- 📑 **Reference management** (BibTeX integration)

## How to use
As typst has packages and templates is this initial version of `humble-dtu-thesis` also appending some code inside of the template for easier access and customization. 

Make sure to explore the `tooling/template.typ` file if interested in modifying certain parts in more details or simply to understand the structure and how the template works. 

And decide if you wish to use package or included template files to run on. Simply comment or uncomment either the import 

```rust
// --main.typ
#import "tooling/template.typ": *
#import "tooling/preamble.typ": *
// #import "@preview/humble-dtu-thesis:0.1.0": *
```

### ℹ️ Core information
Inside of the `main.typ` file in the `#show`, update the relevant information like title, description, department, etc. This will then be updated throughout the paper and existing pages. 

### 🖌️ styling
- The `tooling/template.typ` is responsible for primary styling throughout the tymplate and some header styling and more. 
- The `tooling/functions.typ` contains footer and top level header styling.  
- The `tooling/dtu-template/` contains frontpage, copyright and last page.  

### 🎨 Fonts
To add new fonts not available already, simply download it's files and add them anywhere inside the template or the dedicated folder `tooling/fonts/YourFont`.
The font is set at the start of the `template.typ` file. Simply change the current font inside of this file to the one you've downloaded. 

how the code looks -> `set text(font: "Neo Sans Pro", lang: "en")` \
DTU typography information or other guidelines can be found https://designguide.dtu.dk/typography


### 😎 Functions and extra features
- Inside the `tooling/functions.typ` you can find different extra tools like a fun way to do notes with `#add-note`. \
- If using template files. In the `tooling/template.typ` at the very top you can uncomment and comment the `// #let hide-formalities = true` to hide the formalities (*copyright, abstract, ...*) in the report easily. 

## 📜 License
This template is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

By using this template, you agree to the terms of this license, which allows sharing and adaptation with appropriate attribution. 

Enjoy writing your thesis with Typst! 🚀

