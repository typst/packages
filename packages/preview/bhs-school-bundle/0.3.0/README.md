# bhs-school-bundle

Professional thesis template for vocational high schools in Austria, following formal requirements of HAK/HAS and Kolleg Imst (Austria), and easily customizable for other schools.

The template provides a structured cover page (HAK and Kolleg variants), required front matter pages, indexes, and running header/footer components for school thesis workflows. Necessary headings and examples for images, tables, citations, etc. are included in the `content.typ` file.

This version supports the thesis template and a basic report template. DIN 5008 letter and english version will follow in a future release.

## Usage

With an existing Typst installation, use the CLI command `typst init @preview/bhs-school-bundle` in a new folder to initialize a new project with the basic configuration for a diploma thesis. With VS Code and the installed extension "myriad-dreamin.tinymist", you can use "View" > "Command Palette" > "Typst: Initialize a new Typst project based on a template" and fill in the template name `@preview/bhs-school-bundle` to do the same.

You can also decide to start a new *.typ file on your own and add the necessary imports and configurations as soon as you need to use the template. To do so, you need to include the template import and initialize needed variables at the beginning of your *.typ file.

Example for thesis:

```typst
// For Kolleg variant: replace "hak" with "kolleg"
#import "@preview/bhs-school-bundle:0.3.0": *

#show: hak.with(
    title: [Thesis Title],
    subtitle: [Thesis Subtitle],
    projecttype: [Diploma Thesis],
    team: (
        (name: [Max Mustermann], responsibility: [Responsible for IT: HTML, CSS, Business: Sales Contract]),
        (name: [Susanne Sorglos], responsibility: [Responsible for IT: HTML, CSS, Business: Sales Contract]),
    ),
    supervisors: (
        [Claudio Landerer],
        [Stefan Stolz],
    ),
    date: [Imst, 2026-06-08],
    font: "New Computer Modern",
    fontsize: 12.5pt,
    sectionnumbering: "1.1.1",
    responsible_default: [Gabi Sorglos],  
    vorwort_text: [Hinweise, wie das bearbeitete Thema gefunden wurde, sowie Danksagungen fur Betreuung und Unterstutzung.],
    kurzfassung_text: [Kurzbeschreibung von Aufgabenstellung und Problemlosung.],
    abstract_text: [Englische Version der Kurzfassung.],
    // project_partner_logo: image("typst_media/logos/Logo_Projektpartner.png"),
    // school_logo: image("typst_media/logos/Logo_Schule.png"),
)

= First Headline of the thesis

Using `typst init @preview/bhs-school-bundle` to initialize this project,you will get a prefilled `thesis_content.typ` file with examples for headings, images, tables, citations, etc. You can use this file as a starting point for your thesis and replace the content with your own.

#lorem(200)
```

Example for report:

```typst
#import "@preview/bhs-school-bundle:0.3.0": *

#show: report.with(
  title: [Der Titel der Arbeit],
  subtitle: [Untertitel der Arbeit],
  //projecttype: [Bericht],
  author: "Max Mustermann, Susanne Sorglos",
  responsible_default: "Susanne Sorglos",
  location: "Imst",
  date: [2026-06-08],
  font: "New Computer Modern",
  fontsize: 12.5pt,
  sectionnumbering: "1.1.1",
  school_logo_path: image("template/typst_media/logos/Logo_Schule.png"),
)

= First Headline of the report

#lorem(200)
```

## Configuration

The template exports two functions:

- `hak`: HAK/HAS cover page variant
- `kolleg`: IT-KOLLEG cover page variant

Both use the same named parameters and are configured through `#show: ...with(...)`.

### Options

- `title` (content): Main title
- `subtitle` (content or `none`): Subtitle
- `projecttype` (content): E.g. diploma thesis
- `team` (array or `none`): Team members with name and responsibility
- `supervisors` (array or `none`): Supervising teachers
- `date` (content or `none`): Date line on the cover page
- `font` (string or `none`): Document font family
- `fontsize` (length): Base font size
- `sectionnumbering` (string or `none`): Heading numbering format
- `paper` (string): Paper format (e.g. `a4`)
- `margin` (dictionary): Page margins
- `responsible_default` (content): Default responsible person for the footer if not set per chapter in content.typ
- `eidesstattliche_erklaerung_text` (content or `none`): Declaration of Authorship
- `abnahmeerklaerung_text` (content or `none`): Acceptance Certificate
- `vorwort_text` (content or `none`): German abstract
- `abstract_text` (content or `none`): English abstract
- `project_partner_logo` (content or `none`): Content for the left cover-page logo (specify an image with e.g. `image("path/to/logo.png")`)
- `school_logo` (content or `none`): Content for the right cover-page school logo (specify an image with e.g. `image("path/to/logo.png")`)

If `project_partner_logo` or `school_logo` are not set, the template uses template logos from `typst_media/logos/`.

## Chapter Responsibility

For the footer, you can set the responsible person per chapter:

```typst
#set-responsible([Max Mustermann])
```
