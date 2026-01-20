# Tianjin University of Science and Technology Undergraduate Thesis Typst Template

[中文](README_zh-cn.md)

This template is designed for undergraduate thesis writing at Tianjin University of Science and Technology (TUST). It is adapted from [modern-sjtu-thesis](https://github.com/tzhtaylor/modern-sjtu-thesis) with the structure and typography adjusted to comply with the university's guidelines.

## Usage

### VS Code Local Editing (Recommended)

1. Install the [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension for syntax highlighting, error checking, and PDF preview.
2. Open this repository and edit the template entry file [template/thesis.typ](template/thesis.typ).
3. Use `Ctrl + K V` (Windows) / `Command + K V` (macOS) for real-time preview.

### Compilation

Execute the following command in the repository root directory:

- `typst compile template/thesis.typ`

## Template Entry and Configuration

- Entry file: [template/thesis.typ](template/thesis.typ)
- Global information is configured through the `info` configuration; `work-type` is used to select between "Design/Thesis".

## Features Overview

- Chinese cover, English cover, declaration page, task description, abstract, table of contents, main content, bibliography, acknowledgments, and appendices
- Figures, tables, algorithms, theorem environments with examples
- Equations with numbering and word count statistics

## Font Notes

The template includes a cross-platform font fallback list. If certain fonts are missing on your system, Typst will issue warnings but compilation will not be affected. You can customize the font list as needed in [utils/style.typ](utils/style.typ).

## Acknowledgments

This template is adapted from modern-sjtu-thesis and references the organizational methods of some third-party open-source templates. For detailed license information, see [third_party/](third_party/).

## License

This project is licensed under the MIT License.

It also includes third-party components licensed under other open source licenses.
See the third_party/ directory for details.

### University Logo

This template includes the logo of Tianjin University of Science and Technology
for the purpose of academic thesis formatting.

The university logo is not covered by the MIT license of this package.
Its use is intended for non-commercial, academic, and educational purposes only,
such as preparing theses or reports for the university.

Users are responsible for ensuring that their use of the logo complies with
the university’s policies and applicable regulations.