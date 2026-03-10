![GitHub Repo stars](https://img.shields.io/github/stars/hei-templates/hei-synd-thesis)
![GitHub Release](https://img.shields.io/github/v/release/hei-templates/hei-synd-thesis)

<h1 align="center">
  <br>
  <img src="https://github.com/hei-templates/hei-synd-logos/blob/5a15ff1e95e012e53c34580554a4834cdec05d01/hei-en.svg" alt="HEI-Vs Logo" width="350">
  <br>
  HEI-Vs Engineering School - Systems Engineering
  <br>
</h1>
<div align="center">
  <br>
  <img src="https://github.com/hei-templates/hei-synd-logos/blob/5a15ff1e95e012e53c34580554a4834cdec05d01/synd.svg" alt="Industrial Systems Logo" width="350">
  <br>
</div>

This is the official template for a Bachelorthesis at the [HEI-Vs Engineering School](https://synd.hevs.io) in Sion, Switzerland. More templates can the found in our [GitHub organization](https://github.com/hei-templates)

![sample](https://github.com/hei-templates/hei-synd-thesis/blob/a1c7d345ec2d09e4841456502c76dd5680a85b9f/sample.png)

## Using the template

1. In the `Typst` Univers select the `hei-synd-thesis` template. Locally you can use the Typst CLI to initialise the project:

   ```bash
   # from the typst universe
   typst init @preview/hei-synd-thesis:0.3.1
   ```

2. Fill in the metadata in the `metadata.typ` file.

All metadata is optional, but it is recommended to fill in as much as possible. The metadata is divided into three sections: `options`, `doc`, and `settings`.

| Metadata                        | Type                                          | Description                                                                                         |
| ------------------------------- | --------------------------------------------- |-----------------------------------------------------------------------------------------------------|
| `options`                       | _dictionary_                                  | These are fixed values for the document, who doesn't contribute to the content.                     |
| `option.type`                   | _string_ ("draft","final")                    | Type of the document. "final" will omit some text at the beginning of chapters (default: `"final"`) |
| `option.lang`                   | _string_ ("en", "fr", "de")                   | Language of the document. Many element will be changed accordingly (default:`"en"`)                 |
| `option.template`               | _string_ ("thesis", "midterm")                | Template of the document (default: `"thesis"`)                                                      |
| `doc`                           | _dictionary_                                  | Document metadata                                                                                   |
| `doc.title`                     | _content_                                     | Title of the document.                                                                              |
| `doc.subtitle`                  | _content_                                     | Subtitle of the document.                                                                           |
| `doc.author`                    | _array_                                       | Array of author                                                                                     |
| `doc.author.at(0)`              | _dictionary_                                  | Author metadata                                                                                     |
| `doc.author.at(0).gender`       | _string_ ("masculin", "feminin", "inclusive") | Gender of the author (default: `"masculin"`)                                                        |
| `doc.author.at(0).name`         | _content_                                     | Name of the author.                                                                                 |
| `doc.author.at(0).email`        | _string_                                      | Email of the author.                                                                                |
| `doc.author.at(0).degree`       | _content_                                     | Degree of the author.                                                                               |
| `doc.author.at(0).affiliation`  | _content_                                     | Affiliation of the author.                                                                          |
| `doc.author.at(0).place`        | _content_                                     | Place of the author.                                                                                |
| `doc.author.at(0).url`          | _string_                                      | URL of the author.                                                                                  |
| `doc.author.at(0).signature`    | _image_                                       | Signature of the author.                                                                            |
| `doc.keywords`                  | _list_ of _string_                            | Keywords for the document.                                                                          |
| `doc.version`                   | _content_                                     | Version of the document.                                                                            |
| `thesis-data-page`              | _content_                                     | content of the thesis data use `image("/path/file.pdf", width: 100%)`                               |
| `summary-page`                  | _dictionary_                                  | Summary page metadata                                                                               |
| `summary-page.logo`             | _image_                                       | Logo for the summary page.                                                                          |
| `summary-page.objective`        | _content_                                     | Objective of the document.                                                                          |
| `summary-page.content`          | _content_                                     | Content of the document.                                                                            |
| `display.report-info`           | _boolean_                                     | Add page "Information about this report" including Declaration of honor (default: `true`)           |
| `display.thesis-data`           | _boolean_                                     | Add page "Thesis Data", requires `thesis-data-page` (default: `true`)                               |
| `display.summary`               | _boolean_                                     | Add page "Summary", requires `summary-page` (default: `true`)                                       |
| `professor`                     | _array_                                       | Array of professor metadata                                                                         |
| `professor.at(0)`               | _dictionary_                                  | Professor metadata                                                                                  |
| `professor.at(0).name`          | _content_                                     | Name of the professor.                                                                              |
| `professor.at(0).email`         | _string_                                      | Email of the professor.                                                                             |
| `professor.at(0).url`           | _string_                                      | URL of the professor.                                                                               |
| `expert`                        | _array_                                       | Array of expert metadata                                                                            |
| `expert.at(0)`                  | _dictionary_                                  | Expert metadata                                                                                     |
| `expert.at(0).name`             | _content_                                     | Name of the expert.                                                                                 |
| `expert.at(0).email`            | _string_                                      | Email of the expert.                                                                                |
| `expert.at(0).url`              | _string_                                      | URL of the expert.                                                                                  |
| `school`                        | _dictionary_                                  | School metadata                                                                                     |
| `school.name`                   | _content_                                     | Name of the school.                                                                                 |
| `school.orientation`            | _content_                                     | Major of the school.                                                                                |
| `school.specialisation`         | _content_                                     | Specialisation of the degree program.                                                               |
| `school.url`                    | _string_                                      | URL of the school.                                                                                  |
| `date`                          | _datetime_                                    | Date matadata of the document                                                                       |
| `date.submission`               | _datetime_                                    | Submission date of the document                                                                     |
| `date.mid-term-submission`      | _datetime_                                    | Mid-term submission date of the document                                                            |
| `date.today`                    | _datetime_                                    | Today's date of the document                                                                        |
| `logos`                         | _dictionary_                                  | Logos metadata                                                                                      |
| `logos.main`                    | _image_                                       | Main logo of the document                                                                           |
| `logos.topleft`                 | _image_                                       | Top left logo of the document                                                                       |
| `logos.topright`                | _image_                                       | Top right logo of the document                                                                      |
| `logos.bottomleft`              | _image_                                       | Bottom left logo of the document                                                                    |
| `logos.bottomright`             | _image_                                       | Bottom right logo of the document                                                                   |
| `tableof`                       | _dictionary_                                  | Table of ... settings for the document                                                              |
| `tableof.toc`                   | _boolean_                                     | Create table of contents (default: `true`)                                                          |
| `tableof.tof`                   | _boolean_                                     | Create table of figures (default: `false`)                                                          |
| `tableof.tot`                   | _boolean_                                     | Create table of tables (default: `false`)                                                           |
| `tableof.tol`                   | _boolean_                                     | Create table of listings (default: `false`)                                                         |
| `tableof.toe`                   | _boolean_                                     | Create table of equations (default: `false`)                                                        |
| `tableof.maxdepth`              | _integer_                                     | Max depth of the table of contents (default: `3`)                                                   |
| `gloss`                         | _boolean_                                     | Create glossary and acronyms (default: `true`)                                                      |
| `appendix`                      | _boolean_                                     | Create appendix (default: `false`)                                                                  |
| `bib`                           | _dictionary_                                  | Bibliography settings for the document                                                              |
| `bib.display`                   | _boolean_                                     | Display bibliography (default: `true`)                                                              |
| `bib.path`                      | _string_                                      | Path to the bibliography file (default: `"/tail/bibliography.bib"`)                                 |
| `bib.style`                     | _string_                                      | Style of the bibliography (default: `"ieee"`)                                                       |

3. Write your content in the `thesis.typ` file as well as the other files in the `main/` folder.

## Usage

In order to build the `Typst` document locally you can use one of the following command:

```bash
# Create pdf
typst compile thesis.typ

# Create pdf and watch for changes
typst watch thesis.typ

# Create pdf with the options for language and type you want
typst compile thesis.typ --input type="draft" --input lang="de"
```

## Features

- [x] All metadata is optional
- [x] Multilanguage support
- [x] Multi author, professor, and expert support
- [x] Support for inclusive gender language
- [x] Customizable logos
- [x] Draft and Final Typesetting via typst inputs
- [x] Title page
- [x] Optional thesis data page
- [x] Optional report info page
- [x] Summary page
- [x] Table of contents
- [x] Table of figures
- [x] Table of tables
- [x] Table of listings
- [x] Table of equations
- [x] Todo Boxes with Table of Todos in draft mode
- [x] Custom Boxes
- [x] Sourcecode with codelst and codly
- [x] Glossary and Acronyms with glossarium
- [x] Bibliography
- [x] Content help
  - [x] Acknowledgements
  - [x] Abstract
  - [x] Introduction
  - [x] Specification
  - [x] Design
  - [x] Implementation
  - [x] Validation
  - [x] Conclusion
- [x] Custom title page

## Planned Features

- [ ] Wavedrom diagrams
- [ ] PlantUML diagrams

## Help

If you need help writting your document look at the [Typst documentation](https://typst.app/docs/) or if ou need more help with the template specifics look at the document [Guide-to-Typst](https://github.com/hei-templates/hei-synd-thesis/blob/main/guide-to-typst.pdf).
IF you need help writing your thesis look at the document [Guide-to-Thesis](https://github.com/hei-templates/hei-synd-thesis/blob/main/guide-to-thesis.pdf)

## Contributing

All notable information about contributing to this project can be found in the [CONTRIBUTING.md](https://github.com/hei-templates/hei-synd-thesis/blob/main/CONTRIBUTING.md) file.

## Issues and Support

If you encounter any issues or have questions regarding the course or any of the repositories, please feel free to open an issue in the respective repository. Our team will be happy to assist you.

## Changelog

All notable changes to this project are documented in the [CHANGELOG.md](https://github.com/hei-templates/hei-synd-thesis/blob/main/CHANGELOG.md) file.

## Find us on

[hevs.ch](https://synd.hevs.io) &nbsp;&middot;&nbsp;
LinkedIn [HEI-Vs](https://www.linkedin.com/showcase/school-of-engineering-valais-wallis/) &nbsp;&middot;&nbsp;
LinkedIn [HES-SO Valais-Wallis](https://www.linkedin.com/groups/104343/) &nbsp;&middot;&nbsp;
Youtube [HES-SO Valais-Wallis](https://www.youtube.com/user/HESSOVS)
Twitter [@hessovalais](https://twitter.com/hessovalais) &nbsp;&middot;&nbsp;
Facebook [@hessovalais](https://www.facebook.com/hessovalais) &nbsp;&middot;&nbsp;
