# hak-imst

Typst template for diploma theses at Handelsakademie und Handelsschule Imst and IT-KOLLEG IMST.

The template provides a structured cover page (HAK and Kolleg variants), required front matter pages, indexes, and running header/footer components for school thesis workflows.

## Usage

You can use this template directly in this repository.

1. Open `Diplomarbeit Vorlage.typ`.
2. Adjust metadata in the show rule (title, team, supervisors, date, etc.).
3. Write your document content in `content.typ`.

Example:

```typst
// For Kolleg variant: replace "hak" with "kolleg"
#import "@preview/hak-imst:0.1.0": *

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
	project_partner_logo_path: "typst_media/logos/Logo_Projektpartner.png",
	school_logo_path: "typst_media/logos/Logo_HAK_Imst.png",
)

#include "content.typ"
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
- `project_partner_logo_path` (string or `none`): Path for the left cover-page logo
- `school_logo_path` (string or `none`): Path for the right cover-page school logo

If `project_partner_logo_path` or `school_logo_path` are not set, the template uses default logos from `typst_media/logos/`.

## Chapter Responsibility

For the footer, you can set the responsible person per chapter:

```typst
#set-responsible([Max Mustermann])
```

## About

- Target audience: Diploma thesis teams at HAK/HAS Imst and IT-KOLLEG IMST
- Technology: Typst
- Repository structure: Template logic in `lib.typ`, entry file `Diplomarbeit Vorlage.typ`, document body in `content.typ`
