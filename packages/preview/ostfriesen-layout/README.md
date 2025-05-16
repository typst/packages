# Ostfriesen Layout Typst Template

[![Typst](https://img.shields.io/badge/Typst-v0.13.1+-blue)](https://typst.app/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Status](https://img.shields.io/badge/Status-Beta-yellow.svg)](https://github.com/your-username/typst-template)

A clean, professional Typst template for academic writing at Hochschule Emden/Leer. The template supports multiple authors, custom document types, and follows academic formatting standards.

This is an **`unofficial`** template. It is not affiliated with Hochschule Emden/Leer.

## Acknowledgments

This template is heavily inspired by [HAW-Hamburg-Typst-Template](https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template) created by [Lasse Rosenow](https://github.com/LasseRosenow). Many thanks to Lasse for creating such an excellent foundation that this project builds upon.

## Features

- 📝 Support for multiple authors and matriculation numbers
- 🏢 Company and supervisor information
- 📚 Automatic table of contents, list of figures, and tables
- 📊 Properly styled headings, figures, and tables
- 🔤 Multilingual support (English and German)
- 📄 Declaration of independent processing

## Example

Here are some sample pages of what the final document would look like if created using this template:

<table>
  <tr>
    <td width="33%">
      <img src="https://raw.githubusercontent.com/TobiBeh/HS-Emden-Leer-Typst-Template/main/example/snapshots/abstract.png" alt="Abstract Page Example">
      <p align="center"><em>Abstract Page</em></p>
    </td>
    <td width="33%">
      <img src="https://raw.githubusercontent.com/TobiBeh/HS-Emden-Leer-Typst-Template/main/example/snapshots/toc.png" alt="Table of Contents Example">
      <p align="center"><em>Table of Contents</em></p>
    </td>
    <td width="33%">
      <img src="https://raw.githubusercontent.com/TobiBeh/HS-Emden-Leer-Typst-Template/main/example/snapshots/intro.png" alt="Content Page Example">
      <p align="center"><em>Content Page</em></p>
    </td>
  </tr>
</table>


## Usage

You can use this template in several ways:

### Via the Typst Package Registry (Recommended)

Just add the following code to your Typst document:

```typst
#import "@preview/ostfriesen-layout:0.1.0": thesis

#show: thesis.with(
  // Your configuration here
)
```

## Configuration Options

The template provides numerous configuration options to customize your document:

| Attribute                 | Type             | Default              | Required | Description                                                |
| :------------------------ | :--------------- | :------------------- | :------- | :--------------------------------------------------------- |
| **Document Basics**       |                  |                      |          |                                                            |
| `title`                   | string           | none                 | required | The title of your document                                 |
| `authors`                 | array or string  | ()                   | required | Author names (single author or multiple)                   |
| `matriculation_numbers`   | array or string  | ()                   | optional | Student matriculation numbers                              |
| `date`                    | string or date   | none                 | required | Publication date (e.g., "May 2025" or datetime object)     |
| `documentType`            | string           | none                 | required | Type of document (e.g., "Bachelor Thesis", "Master Thesis")|
| **University Information**|                  |                      |          |                                                            |
| `faculty`                 | string           | none                 | required | Faculty name                                               |
| `department`              | string           | none                 | required | Department name                                            |
| `course_of_studies`       | string           | none                 | optional | Course of studies name                                     |
| **Supervision Details**   |                  |                      |          |                                                            |
| `supervisor1`             | string           | none                 | required | First/primary supervisor                                   |
| `supervisor2`             | string           | none                 | optional | Second supervisor                                          |
| `supervisor3`             | string           | none                 | optional | Third supervisor                                           |
| **Company Information**   |                  |                      |          |                                                            |
| `company`                 | string           | none                 | optional | Company name (for industry collaborations)                 |
| `company_supervisor`      | string           | none                 | optional | Company supervisor name                                    |
| **Content Metadata**      |                  |                      |          |                                                            |
| `abstract`                | content          | none                 | optional | Document abstract                                          |
| `keywords`                | array or string  | ()                   | optional | Keywords related to the document                           |
| **Document Settings**     |                  |                      |          |                                                            |
| `include_declaration`     | boolean          | true                 | optional | Include declaration of independent processing              |
| `lang`                    | string           | "en"                 | optional | Document language: "en" (English) or "de" (German)         |
| **Typography Settings**   |                  |                      |          |                                                            |
| `font`                    | string           | "New Computer Modern"| optional | Font family                                                |
| `font_size`               | length           | 11pt                 | optional | Base font size                                             |
| `line_spacing`            | float            | 1.5                  | optional | Line spacing multiplier                                    |
| **Layout Settings**       |                  |                      |          |                                                            |
| `lower_chapter_headings`  | boolean          | false                | optional | Reduce spacing for level-1-headings                        |
| **Code Highlighting**     |                  |                      |          |                                                            |
| `enable_code_highlighting`| boolean          | true                 | optional | Enable syntax highlighting for code blocks                 |

### Usage Examples

<details>
<summary><b>Basic Document Setup</b> (click to expand)</summary>

```typst
#show: thesis.with(
  title: "Implementation of an Advanced Machine Learning Algorithm",
  authors: "John Doe",
  matriculation_numbers: "123456",
  date: "May 2025", 
  documentType: "Master Thesis",
  faculty: "Faculty of Technology",
  department: "Computer Science",
  supervisor1: "Prof. Dr. Jane Smith"
)
```
</details>

<details>
<summary><b>Multiple Authors and University Details</b></summary>

```typst
#show: thesis.with(
  title: "Blockchain Technologies for Supply Chain Management",
  authors: ("John Doe", "Jane Smith"),
  matriculation_numbers: ("123456", "789012"),
  date: datetime(year: 2025, month: 5, day: 11),
  documentType: "Group Project Report",
  
  faculty: "Faculty of Business Studies",
  department: "Business Informatics",
  course_of_studies: "Digital Business Management",
  
  supervisor1: "Prof. Dr. First Supervisor",
  supervisor2: "Second Supervisor"
)
```
</details>

<details>
<summary><b>Industry Collaboration Project</b></summary>

```typst
#show: thesis.with(
  title: "Development of an IoT Solution for Smart Manufacturing",
  authors: "John Doe",
  matriculation_numbers: "123456",
  date: "May 2025",
  documentType: "Bachelor Thesis",
  
  faculty: "Faculty of Engineering",
  department: "Electrical Engineering",
  course_of_studies: "Embedded Systems",
  
  supervisor1: "Prof. Dr. Academic Supervisor",
  company: "TechCorp GmbH",
  company_supervisor: "Dr. Industry Expert"
)
```
</details>

## Document Structure

<details>
<summary><b>Headings</b></summary>

Use Typst's standard heading syntax:

```typst
= Main Heading (Chapter)
== Second-level Heading (Section)
=== Third-level Heading (Subsection)
```
</details>

<details>
<summary><b>Figures and Images</b></summary>

```typst
#figure(
  image("path/to/image.png", width: 80%),
  caption: [This is a caption for the figure.]
) <fig-label>

// Reference the figure in text
See @fig-label for details.
```
</details>

<details>
<summary><b>Tables</b></summary>

```typst
#figure(
  table(
    columns: (auto, auto, auto),
    [*Header 1*], [*Header 2*], [*Header 3*],
    [Row 1, Col 1], [Row 1, Col 2], [Row 1, Col 3],
    [Row 2, Col 1], [Row 2, Col 2], [Row 2, Col 3],
  ),
  caption: [Sample table with data.]
) <table-label>

// Reference the table in text
As shown in @table-label...
```
</details>


<details>
<summary><b>Citations and Bibliography</b></summary>

1. Create a bibliography file (e.g., references.bib)
2. Reference citations in your document: `According to @smith2022, the results show...`
3. Add the bibliography at the end of your document

```typst
#pagebreak()
#import "lib/pages/translations.typ": translations  
#let t = translations.at("en")  // "en" for English, "de" for German
#heading(t.at("bibliography"), numbering: none, outlined: true)
#bibliography("references.bib", title: none)
```
</details>

<details>
<summary><b>Using Glossary Terms</b></summary>

Reference glossary terms in your document:

```typst
// Reference a glossary term
The @algorithm is efficient.

// Or use functions for more control
The #gls("algorithm") is efficient.
These #glspl("cpu") are powerful.
```

To manually include a glossary section:

```typst
#pagebreak()
#heading("Glossary", numbering: none, outlined: true)
#import "lib/pages/glossary.typ": glossary_entries
#print-glossary(glossary_entries, show-all: true)
```
</details>

## File Organization

For larger documents, we recommend organizing your project files in a modular structure like the provided example:

```
project/
├── main.typ                # Main document that imports template and includes chapter files
├── references.bib          # Bibliography file
├── assets/
│   └── images/             # Images and other media
└── chapters/
    ├── introduction.typ    # Each chapter in a separate file
    ├── background.typ
    └── ...
```

## Requirements

- Typst 0.13.1 or higher
- New Computer Modern font

## Contributing

Contributions to improve the template are welcome! To contribute:

1. Fork the repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

This template is provided under the [MIT License](./LICENSE).

---

<p align="center">
  Made with ❤️ for Hochschule Emden/Leer students
</p>