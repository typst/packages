![GitHub Repo stars](https://img.shields.io/github/stars/hei-templates/hei-synd-report)
![GitHub Release](https://img.shields.io/github/v/release/hei-templates/hei-synd-report?include_prereleases)

<h1 align="center">
  <br>
  <img src="https://github.com/hei-templates/hei-synd-report/blob/51e8aea5b38bb51cba041bfc0ab769cc12f1a865/img/hei-en.svg" alt="HEI-Vs Logo" width="350">
  <br>
  HEI-Vs Engineering School - Systems Engineering
  <br>
</h1>
<div align="center">
  <br>
  <img src="https://github.com/hei-templates/hei-synd-report/blob/51e8aea5b38bb51cba041bfc0ab769cc12f1a865/img/synd-light.svg" alt="Industrial Systems Logo" width="350">
  <br>
</div>


This is the official template for a students report or project or lab report for the [HEI-Vs Engineering School](https://synd.hevs.io) in Sion, Switzerland. More templates can the found in our [GitHub organization](https://github.com/hei-templates)

![](img/https://github.com/hei-templates/hei-synd-report/blob/51e8aea5b38bb51cba041bfc0ab769cc12f1a865/img/sample.png)

## Using the template

1. In the `Typst` Univers select the `hei-synd-report` template. Locally you can use the Typst CLI to initialise the project:

   ```bash
   # from the typst universe
   typst init @preview/hei-synd-report:0.1.0
   ```

2. Fill in the metadata in the `metadata.typ` file.

All metadata is optional, but it is recommended to fill in as much as possible. The metadata is divided into three sections: `options`, `doc`, and `settings`.

   | Metadata                 | Type                        | Description                                                                                         |
   | ------------------------ | --------------------------- | --------------------------------------------------------------------------------------------------- |
   | `options`                | _dictionary_                | These are fixed values for the document, who doesn't contribute to the content.                     |
   | `option.type`            | _string_ ("draft","final")  | Type of the document. "final" will omit some text at the beginning of chapters (default: `"final"`) |
   | `option.lang`            | _string_ ("en", "fr", "de") | Language of the document. Many element will be changed accordingly (default:`"en"`)                 |
   | `doc`                    | _dictionary_                | Document metadata                                                                                   |
   | `doc.title`              | _content_                   | Title of the document.                                                                              |
   | `doc.abbr`               | _content_                   | Abbreviation of the Title.                                                                          |
   | `doc.subtitle`           | _content_                   | Subtitle of the document.                                                                           |
   | `doc.url`                | _string_                    | URL for the document or project                                                                     |
   | `doc.logos`              | _dictionary_                | Dicrionary for the different logos                                                                  |
   | `doc.logos.tp_topleft`   | _image_                     | Image for the topleft section of the titlepage                                                      |
   | `doc.logos.tp_topright`  | _image_                     | Image for the topright section of the titlepage                                                     |
   | `doc.logos.tp_main`      | _image_                     | Image for the main section of the titlepage                                                         |
   | `doc.logos.header`       | _image_                     | Image for the header of the document                                                                |
   | `doc.authors`            | _list_ of _dictionary_      | List of authors with their metadata                                                                 |
   | `doc.authors.name`       | _content_                   | Name of the author                                                                                  |
   | `doc.authors.abbr`       | _content_                   | Abbreviation of the author                                                                          |
   | `doc.authors.email`      | _string_                    | Email of the author                                                                                 |
   | `doc.authors.url`        | _string_                    | URL of the author                                                                                   |
   | `doc.school`             | _dictionary_                | School metadata                                                                                     |
   | `doc.school.name`        | _content_                   | Name of the school                                                                                  |
   | `doc.school.major`       | _content_                   | Major of the school                                                                                 |
   | `doc.school.orientation` | _content_                   | Orientation of the school                                                                           |
   | `doc.school.url`         | _string_                    | URL of the school                                                                                   |
   | `doc.course`             | _dictionary_                | Course metadata                                                                                     |
   | `doc.course.name`        | _content_                   | Name of the course                                                                                  |
   | `doc.course.url`         | _string_                    | URL of the course                                                                                   |
   | `doc.course.prof`        | _content_                   | Name of the professor                                                                               |
   | `doc.course.class`       | _content_                   | Class of the course                                                                                 |
   | `doc.course.semester`    | _content_                   | Semester of the course                                                                              |
   | `doc.keywords`           | _list_ of _string_          | Keywords for the document                                                                           |
   | `doc.version`            | _content_                   | Version of the document                                                                             |
   | `date`                   | _datetime_                  | Date of the document (default: `datetime.today()`                                                   |
   | `tableof`                | _dictionary_                | Table of ... settings for the document                                                              |
   | `tableof.toc`            | _boolean_                   | Create table of contents (default: `true`)                                                          |
   | `tableof.tof`            | _boolean_                   | Create table of figures (default: `false`)                                                          |
   | `tableof.tot`            | _boolean_                   | Create table of tables (default: `false`)                                                           |
   | `tableof.tol`            | _boolean_                   | Create table of listings (default: `false`)                                                         |
   | `tableof.toe`            | _boolean_                   | Create table of equations (default: `false`)                                                        |
   | `tableof.maxdepth`       | _integer_                   | Max depth of the table of contents (default: `3`)                                                   |
   | `gloss`                  | _boolean_                   | Create glossary and acronyms (default: `true`)                                                      |
   | `appendix`               | _boolean_                   | Create appendix (default: `false`)                                                                  |
   | `bib`                    | _dictionary_                | Bibliography settings for the document                                                              |
   | `bib.display`            | _boolean_                   | Display bibliography (default: `true`)                                                              |
   | `bib.path`               | _string_                    | Path to the bibliography file (default: `"/tail/bibliography.bib"`)                                 |
   | `bib.style`              | _string_                    | Style of the bibliography (default: `"ieee"`)                                                       |

3. Write your content in the `report.typ` file as well as the other files in the `main` folder.

## Usage

In order to build the `Typst` document locally you can use one of the following command:

```bash
# Create pdf
typst compile report.typ

# Create pdf and watch for changes
typst watch report.typ
```

## Features

- [x] All metadata is optional
- [x] Title page
- [x] Table of contents
- [x] Table of figures
- [x] Table of tables
- [x] Table of listings
- [x] Table of equations
- [x] Custom Boxes
- [x] Sourcecode with codelst
- [x] Glossary and Acronyms with Glossarium
- [x] Bibliography
- [x] Draft and Final Typesetting
- [x] Content help
   - [x] Introduction
   - [x] Specification
   - [x] Design
   - [x] Implementation
   - [x] Validation
   - [x] Conclusion
- [ ] Wavedrom diagrams
- [ ] PlantUML diagrams

## Help

If you need help writting your document look at the [Typst documentation](https://typst.app/docs/) or if ou need more help with the template specifics look at the document [Guide-to-Typst](https://github.com/hei-templates/hei-synd-report/blob/51e8aea5b38bb51cba041bfc0ab769cc12f1a865/guide-to-typst.pdf).

## Contributing

If you would like to contribute to any of the repositories in this organization, please follow these steps:

1. Fork the repository you want to contribute to.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with conventional commit messages.
4. Push your branch to your forked repository.
5. Open a pull request in the original repository and describe your changes.

## Issues and Support

If you encounter any issues or have questions regarding the course or any of the repositories, please feel free to open an issue in the respective repository. Our team will be happy to assist you.

## Changelog

All notable changes to this project are documented in the [CHANGELOG.md](./CHANGELOG.md) file.

## Find us on

[hevs.ch](https://synd.hevs.io) &nbsp;&middot;&nbsp;
LinkedIn [HEI-Vs](https://www.linkedin.com/showcase/school-of-engineering-valais-wallis/) &nbsp;&middot;&nbsp;
LinkedIn [HES-SO Valais-Wallis](https://www.linkedin.com/groups/104343/) &nbsp;&middot;&nbsp;
Youtube [HES-SO Valais-Wallis](https://www.youtube.com/user/HESSOVS)
Twitter [@hessovalais](https://twitter.com/hessovalais) &nbsp;&middot;&nbsp;
Facebook [@hessovalais](https://www.facebook.com/hessovalais) &nbsp;&middot;&nbsp;
