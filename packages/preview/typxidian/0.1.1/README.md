# TypXidian

**TypXidian** is a Typst template for academic documents, such as theses, dissertations, and reports.

## Features

The template comes with a structured title page that can include a wide range of academic metadata: title, subtitle, authors, supervisors, university, faculty, department, degree, academic year, a quote and an abstract.  

Citations, references and links are configurable with custom colors.   

To improve readability, TypXidian includes styled environments for notes, tips, and warnings. These callouts are inspired by [Obsidian](https://obsidian.md/).  
Mathematical writing is also supported, with environments for definitions, theorems, and proofs.  

<table align="center">
    <tr>
        <td>
              <img src="https://github.com/user-attachments/assets/760fa379-bbae-4159-a181-63e9970224bf" width="350px">
        </td>
        <td>
            <img src="https://github.com/user-attachments/assets/c0023792-3e94-4b3e-82cf-13332423bd79" width="500px">
        </td>
    </tr>
    <tr>
        <td>Callouts</td>
        <td>Math environments</td>
    </tr>
</table>

Finally, the template allows you to select fonts, paper sizes, and languages so that the document feels tailored to your academic context.  

## Usage

To use TypXidian, start a new `.typ` document and import the template.  
To use the template locally, run the following command in your terminal:
```bash
typst init @preview/typxidian:0.1.1
```

Here is a minimal example showing how to set up the template with metadata for a thesis:  

```typst
#import "@preview/typxidian:0.1.1": *

#show: template.with(
  title: [TypXidian],
  authors: ("Giuseppe Verdi", ),
  supervisors: ("Prof. Mario Rossi", "Prof. Mario Bianchi"),
  subtitle: [A template for academic documents written in Typst],
  university: [University of Salerno],
  faculty: [Faculty of Science],
  degree: [Master's Degree in Machine Learning & Data Science],
  department: [Department of Computer Science],
  academic-year: [2025/2026],
  abstract: lorem(150),
  quote: [
    #lorem(20)
    \ \ #align(right, [-- John Doe])
  ],
  bib: bibliography("bibliography.bib"),
  abbreviations: abbreviations,
)
```

Once the metadata is in place, you can start writing your chapters and sections immediately below.  
The template will handle the layout of the title page, abstract, and other structural elements automatically.  

### Working with Chapters

Typst does not currently support textual inclusion. If you plan to split your document into standalone chapter files, you can simply re-include the package in each file to access its functions

## Requirements

To work with TypXidian you will need:

- [Typst](https://typst.app/) version 0.13.1 or newer
- Optionally, a `.bib` file if you want to manage your bibliography
- Optionally, an `abbreviations.typ` file if your document uses acronyms
- The template also makes use of Font Awesome icons via the [fontawesome](https://typst.app/universe/package/fontawesome) package.  
  For these to display correctly, you should install the [Font Awesome 7 Desktop](https://fontawesome.com/download) fonts on your computer,  
  or upload them to your project folder if you are working on the Typst web app.

## License

TypXidian is distributed under the MIT License.  
Please note that the cat and dog photographs included in the example document (`main.typ`) are licensed under the [Unsplash terms](https://unsplash.com/license).
