# UPM Report Template for Typst

Unofficial template for Universidad Politécnica de Madrid thesis and reports.

This is a Typst version of the template originally developed by Blazaid at [https://github.com/blazaid/UPM-Report-Template.git](https://github.com/blazaid/UPM-Report-Template.git). My LaTeX version of it is also available at [https://github.com/Tikitikitikidesuka/typst-upm-report.git](https://github.com/Tikitikitikidesuka/typst-upm-report.git).

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `title` | Title of your work | "Title of the Work" |
| `author` | Author's name | "Author's name" |
| `supervisor` | Supervisor's name | "Supervisor's Name" |
| `date` | Document date | Today's date |
| `acknowledgements` | Content for acknowledgements page (optional) | none |
| `abstract-en` | Abstract text (optional) | none |
| `keywords-en` | Keywords for abstract (optional) | none |
| `license-name` | License name | "Creative Commons Attribution..." |
| `license-logo` | Image content for license logo (optional) | CC BY-NC-SA logo image |
| `license-link` | URL to license | CC BY-NC-SA 4.0 URL |
| `university` | University name | "Universidad Politécnica de Madrid" |
| `school-name` | Full school name | "E.T.S. de Ingeniería de Sistemas Informáticos" |
| `school-address` | School address | Campus Sur UPM address |
| `school-abbr` | School abbreviation | "ETSISI" |
| `report-type` | Type of document | "Bachelor's thesis" |
| `degree-name` | Degree program name | "Grado en Ingeniería de Tecnologías..." |
| `school-color` | Primary color for headers and accents | Blue: `rgb(32, 130, 192)` |
| `school-logo` | Image content for school logo | ETSISI logo image |
| `school-watermark` | Image content for school watermark (optional) | UPM watermark image |
| `bibliography-file` | Path to .bib file | "references.bib" |
| `bibliography-style` | Citation style (ieee, apa, mla, etc.) | "ieee" |

## Using the Template

To start a new document with this template:

```
typst init @preview/bean-upm my-thesis
cd my-thesis
```

Then edit `main.typ` and compile with:

```
typst compile main.typ
```

You can also use the [Typst web app](https://typst.app) and search for "bean-upm" in the template gallery.

## Contributing to the Template

If you're developing or modifying this template locally, compile from the repository root with:

```
typst compile --root . template/main.typ
```

## License

This template is distributed under an MIT License.
