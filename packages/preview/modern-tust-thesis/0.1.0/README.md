# Tianjin University of Science and Technology Undergraduate Thesis Typst Template

[[中文](README_zh-cn.md)]

This template is designed for undergraduate thesis writing at Tianjin University of Science and Technology (TUST). It is adapted from [modern-sjtu-thesis](https://github.com/tzhtaylor/modern-sjtu-thesis) with the structure and typography adjusted to comply with the university's guidelines.

---

## Usage

### Web App

Use the [Typst Web App](https://typst.app/) to start a new project from this template directly in your browser:

1. Open https://typst.app/
2. Click "Start from template" and search for "modern-tust-thesis"
3. Create a new project from the template
4. Edit and preview in the web editor

**Note:** The web app environment may not include all the fonts used by this template. You may see font fallback warnings, but compilation will succeed. For the best visual results with proper fonts, use one of the other methods below or upload the fonts manually.

### VS Code with Tinymist (Recommended)

For users who prefer local editing, VS Code together with the Tinymist Typst extension provides a convenient workflow:

1. Install the [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension in VS Code for syntax highlighting, error checking, and PDF preview.
2. Press `Ctrl + Shift + P` (Windows) / `Command + Shift + P` (macOS) to open the command palette, then run **Typst: Show available Typst templates (gallery) for picking up a template** to open Tinymist’s Template Gallery.
3. Find **modern-tust-thesis** in the gallery, click ❤ to favorite it, then click + to create a new project.
4. Open the generated folder in VS Code, open `thesis.typ`, and press `Ctrl + K V` (Windows) / `Command + K V` (macOS) or click the top-right preview button for live editing and preview.

### Command Line with `typst init`

If you prefer using Typst directly from the command line:

1. Ensure you have [Typst](https://github.com/typst/typst) installed
2. Initialize a new project from this template:
   ```
   typst init @preview/modern-tust-thesis:0.1.0
   ```
3. Edit the generated files with your preferred editor
4. Compile with:
   ```
   typst compile thesis.typ
   ```

---

## Template Entry and Configuration

The following section is mainly relevant if you are working with this repository directly
(e.g. for customization or development of the template):

- Entry file: [template/thesis.typ](template/thesis.typ)
- Global information is configured through the `info` configuration; `work-type` is used to select between "Design/Thesis".

---

## Features Overview

- Chinese cover, English cover, declaration page, task description, abstract, table of contents, main content, bibliography, acknowledgments, and appendices
- Figures, tables, algorithms, theorem environments with examples
- Equations with numbering and word count statistics

---

## Font Notes

The template includes a cross-platform font fallback list. If certain fonts are missing on your system, Typst will issue warnings but compilation will not be affected. You can customize the font list as needed in [utils/style.typ](utils/style.typ).

---

## Acknowledgments

This template is adapted from modern-sjtu-thesis and references the organizational methods of some third-party open-source templates. For detailed license information, see [third_party/](third_party/).

---

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