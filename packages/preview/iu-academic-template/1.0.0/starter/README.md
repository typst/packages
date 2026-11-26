# Academic Paper – Quick Start

**Language:** **English** | [Deutsch](README.de.md)

This project uses **Academic Template**, a [Typst](https://typst.app/) template preconfigured for the formatting and citation requirements of **IU Internationale Hochschule**. You can customize the settings in `config.typ` to meet other requirements.

> **Unofficial project.** This template is independently developed and is not published, endorsed, or maintained by IU Internationale Hochschule. Check the current requirements for your course and assessment before submitting your work.

## Getting started

1. Enter your paper details and adjust the formatting in `config.typ`.
2. Replace the example chapters and text in `content.typ` with your own work.
3. Add or update your sources in `references.json`, or select an alternative bibliography file in `config.typ`.
4. If needed, define abbreviations in `abbreviations.typ` and add supplementary material in `appendices.typ`.
5. Store images, diagrams, or other files used in your paper in an `assets/` folder (create it if needed).

**Always compile `main.typ`**, not the other `.typ` files, because it assembles the complete document. Run the following command from your project folder:

```bash
typst compile main.typ
```

This creates `main.pdf`. To rebuild the PDF automatically when source files change, use `typst watch main.typ`.

For local compilation, you need **Typst CLI 0.15.0 or newer** and access to the template package specified in `project.typ`. In the **Typst web app**, the preview updates as you edit, and you can export the PDF directly.

In **Visual Studio Code** with the **Tinymist** extension, you can edit your project files directly. To export or preview the complete document, open `main.typ` and make sure it is the active file in the editor. Open the Command Palette with `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS); alternatively, press `Ctrl+P` or `Cmd+P` and type `>`. Then search for a Typst command such as `Typst: Export the Opened File as PDF` or `Typst Preview: Preview Opened File in Browser` (available commands depend on the installed extension).

## Project files

| File or folder | Purpose |
| --- | --- |
| `config.typ` | Paper details, language, formatting, lists, and bibliography settings |
| `content.typ` | Main chapters and text |
| `references.json` | Default CSL-JSON bibliography |
| `references.bib`, `references.yaml` | Optional alternative bibliography files |
| `abbreviations.typ` | Abbreviation definitions |
| `appendices.typ` | Optional appendices and supplementary material |
| `assets/` | Images, diagrams, logos, and other files used in the paper; create this folder if needed |
| `main.typ` | Entry point for compiling the complete document; normally no changes required |
| `project.typ` | Connection to the template package; normally no changes required |

The template implementation is **not stored in this project**. The package name and version are specified in `project.typ`, which imports the template from `@preview` (Typst Universe) or `@local` (local installation).

## Language and formatting

Set `language: "de"` for German or `language: "en"` for US English in `config.typ`. This changes generated labels and language-dependent formatting; it **does not translate your text**.

The default font setting prefers **Arial** and uses **Liberation Sans** if Arial is unavailable (for example, in the web app). You can change this in `config.typ`. Check the finished PDF against your institution's formatting requirements, as substitute fonts may affect the layout.

## Bibliography and citations

The recommended default setup is **Citrus + CSL-JSON (`references.json`) + IU style**. For APA citations, you can select `style: "apa"` in `config.typ`. Alternative bibliography engines and file formats are also supported; when using them, carefully review your source metadata and the resulting citations.

The included bibliography files contain examples but are **not synchronized automatically**. Maintain the file selected in `config.typ` and consult the Bibliography Guide for source management, citation methods, and reference-list details.

## Documentation and examples

- For installation and updates, see the main repository README ([English](https://github.com/BeaverBytes/academic-template/blob/main/README.md) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/main/README.de.md)).
- For detailed instructions on using the template, see the User Guide ([English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.pdf) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.de.pdf)).
- For information on bibliography formats, citation methods, and reference lists, see the Bibliography Guide ([English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.pdf) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.de.pdf)).

- To explore the template's features and see what a finished document can look like, visit the [demo project](https://github.com/BeaverBytes/academic-template/tree/v1.0.0/demo).

**Before submission:** Replace the example content and bibliography entries, verify your paper details, and check the current course-specific formatting and citation requirements. The template does not guarantee compliance.

## License

The files provided in this starter project are licensed under [MIT No Attribution (MIT-0)](LICENSE). The separately installed template library and its bundled third-party components retain their own licenses. You do not need to credit BeaverBytes in your paper merely because you used this template.
