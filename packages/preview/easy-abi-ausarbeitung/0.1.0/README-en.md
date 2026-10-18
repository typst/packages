# Typst template for the written report of the 5th examination component in Berlin

Typst template for the written report for the 5th examination component in Berlin. You write the content; the template takes care of the cover page, table of contents, references, and declaration of originality.

## Quick Start


```bash
typst init @preview/easy-abi-ausarbeitung:0.1.0 my-report
cd my-report
typst watch main.typ
```

If you are working directly in the repository, compile the example from the template folder:

```bash
typst watch --root . template/main.typ
```

The central idea is a `#show: ausarbeitung.with(...)` block. Everything that follows in the file is set as the main body of the report.

```typst
#import "@preview/easy-abi-ausarbeitung:0.1.0": ausarbeitung

#show: ausarbeitung.with(
	leitfrage: "A very interesting guiding question about blueberries and their role in society!",
	name: "Max Mustermann",
	referenzfach: "History",
	bezugsfach: "Political Science",
	pruefer: ((name: "Dr. Example"), (name: "Mr. Example")),
	vorgelegt_am: datetime.today(),
	abgabetermin_am: datetime(year: 2026, month: 3, day: 15),
	bibliography: bibliography("references.bib", style: "handout-5pk-lmo.csl", title: none),
)

= Themenfindung

Your report starts here.
```

You can use headings, lists, quotations, and sources in the main body as usual. Citations are rendered as footnotes by the template.

## Parameters

### Required

| Parameter | Meaning |
| --- | --- |
| `leitfrage` | Guiding question or title on the cover page |
| `name` | Your name |
| `referenzfach` | First subject of the 5th examination component |
| `bezugsfach` | Second subject of the 5th examination component |
| `pruefer` | List of examiners, for example `((name: "Ms. Example"), (name: "Mr. Example"))` |
| `vorgelegt_am` | Submission date as a `datetime` |
| `abgabetermin_am` | Deadline as a `datetime` |
| `body` | The rest of the document content after the `#show` block |

### Optional

| Parameter | Default | Meaning |
| --- | --- | --- |
| `bibliography-style` | `handout-5pk-lmo` | Bibliography style e.g "ieee" (handout-5pk-lmo is a custom style, specifically for the 5th examination component in Berlin) |
| `gruppenarbeit` | `false` | Uses the plural "we" form on the declaration page |
| `stadt` | `Berlin` | Place in the declaration of originality |
| `schule` | `OSZ Lise-Meitner` | School |
| `abstand-oben` | `25mm` | Top margin |
| `abstand-unten` | `25mm` | Bottom margin |
| `abstand-links` | `25mm` | Left margin |
| `abstand-rechts` | `25mm` | Right margin |
| `schriftart` | `Times New Roman` | `Arial`, `Times New Roman`, or `Verdana` (Times New Roman = 12 pt, the others 11 pt) |

Left and right margins must be between 20 mm and 30 mm, top and bottom margins between 20 mm and 25 mm. For the font, only the three values listed above are allowed.

`vorgelegt_am` must not be after `abgabetermin_am`. Both values must be real `datetime` objects, for example `datetime.today()` or `datetime(year: 2026, month: 3, day: 15)`.

Add your sources to `references.bib` and use the usual Typst citations in the text, for example `@mustermann2024` or `#cite(<mustermann2024>)`.


## Important Files

- [lib.typ](lib.typ) contains the public function `ausarbeitung()`
- [handout-5pk-lmo.csl](handout-5pk-lmo.csl) is a specific citation style asked for by the OSZ Lise-Meitner
- [elemente/deckblatt.typ](elemente/deckblatt.typ) renders the cover page
- [elemente/declaration.typ](elemente/declaration.typ) generates the declaration of originality
- [helpers/datum.typ](helpers/datum.typ) provides date helpers
- [helpers/validators.typ](helpers/validators.typ) contains functions to validate the parameters
- [template/main.typ](template/main.typ) shows a working example
- [template/references.bib](template/references.bib) is the example bibliography

## License

MIT. See [LICENSE](LICENSE).
