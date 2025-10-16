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
| `license-logo` | Path to license logo image | "assets/cc-by-nc-sa.svg" |
| `license-link` | URL to license | CC BY-NC-SA 4.0 URL |
| `university` | University name | "Universidad Politécnica de Madrid" |
| `school-name` | Full school name | "E.T.S. de Ingeniería de Sistemas Informáticos" |
| `school-address` | School address | Campus Sur UPM address |
| `school-abbr` | School abbreviation | "ETSISI" |
| `report-type` | Type of document | "Bachelor's thesis" |
| `degree-name` | Degree program name | "Grado en Ingeniería de Tecnologías..." |
| `school-color` | Primary color for headers and accents | Blue: `rgb(0, 114, 206)` |
| `school-watermark` | Path to school logo/watermark image | "assets/upm-watermark.png" |
| `bibliography-file` | Path to .bib file | "references.bib" |
| `bibliography-style` | Citation style (ieee, apa, mla, etc.) | "ieee" |

## Compiling the Template

To compile this template, run:

```typst compile --root . template/main.typ```

## License

This template is distributed under an MIT License.
