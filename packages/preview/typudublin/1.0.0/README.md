# TypUDublin

**TypUDublin** is a fork of Angelo Nazzaro's [Typxidian](https://github.com/angelonazzaro/typxidian) that has been modified to fit closer to TU Dublin's report format.

The primary difference between this template and that of Nazzaro's Typxidian is additional support for code blocks, TU Dublin colours, and an improved table. Typxidian was based on the functionality of [Obsidian](https://obsidian.md/) and "Alice in a Differentiable Wonderland" by Simone Scardapane.

## Features

The template comes with a structured title page that can include a wide range of academic metadata: title, subtitle, authors, supervisors, university, faculty, department, degree, academic year, a quote and an abstract.

Citations, references and links are configurable with custom colors.   

To improve readability, TypUDublin includes styled environments for notes, tips, and warnings. These callouts are inspired by [Obsidian](https://obsidian.md/).
Mathematical writing is also supported, with environments for definitions, theorems, and proofs.  

<table align="center">
    <tr>
        <td>
              <img src="https://github.com/user-attachments/assets/760fa379-bbae-4159-a181-63e9970224bf" width="350px" alt="A showcase of the callouts inspired by Obsidian">
        </td>
        <td>
            <img src="https://github.com/user-attachments/assets/c0023792-3e94-4b3e-82cf-13332423bd79" width="500px" alt="A showcase of the mathematics environment">
        </td>
    </tr>
    <tr>
        <td>Callouts</td>
        <td>Math environments</td>
    </tr>
</table>

Finally, the template allows you to select fonts, paper sizes, and languages so that the document feels tailored to your academic context.  

## Usage

To use TypUDublin, start a new `.typ` document and import the template.
To use the template locally, run the following command in your terminal:
```bash
typst init @preview/typudublin:1.0.0
```

Here is a minimal example showing how to set up the template with metadata for a thesis:  

```typst
#import "@preview/typudublin:1.0.0": *

#show: template.with(
  title: [TypUDublin],
  subtitle: [A Typst template for TU Dublin reports],
  department: [School of Computer Science],
  course-code: [TU123],
  course: [BSc in Special Course],
  university: [Technological University Dublin],
  authors: (
    (
      name: "Max Mustermann",
      num: "C12345678",
    ),
  ),
  // This comma at the end is vital or it will not compile as it does not stay as an array
  supervisors: ("Dr. Serious Person",),
  declaration-signature: "./figures/signature.png",
  is-thesis: true,
  thesis-type: [Project Report],
  abbreviations: abbreviations,
  abstract-alignment: left,
  chapter-alignment: right,
  bib: bibliography("bibliography.bib"),
  abstract: lorem(200),
  acknowledgments: [#lorem(50)],
  appendix-ai: (
    report-writing: (
      "Create an image of a duck"
    ),
    research: (),
    design: (),
    coding: (),
    other: ()
  )
)
```

Once the metadata is in place, you can start writing your chapters and sections immediately below.  
The template will handle the layout of the title page, abstract, and other structural elements automatically.  

## Working with Chapters
 
Typst does not currently support _textual inclusion_, meaning that you can use only dependencies directly imported in the current file. For this reason, if you plan to split your document into standalone chapters, you must include the package in each file to access its functions.


## Requirements

To work with TypUDublin you will need:

- [Typst](https://typst.app/) version 0.13.1 or newer
- Optionally, a `.bib` file if you want to manage your bibliography. This can be exported by Zotero and other reference managers.
- Optionally, an `abbreviations.typ` file if your document uses acronyms
- The template also makes use of Font Awesome icons via the [fontawesome](https://typst.app/universe/package/fontawesome) package.  
  For these to display correctly, you should install the [Font Awesome 7 Desktop](https://fontawesome.com/download) fonts on your computer,  
  or upload them to your project folder if you are working on the Typst web app.

## License

TypUDublin is distributed under the MIT License and is derived from Nazzaro's Typxidian.
Please note that the cat and dog photographs included in the example document (`main.typ`) are licensed under the [Unsplash terms](https://unsplash.com/license).
