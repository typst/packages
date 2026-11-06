# Hochschule Bonn-Rhein-Sieg thesis template (unofficial)

Thesis template for Hochschule Bonn-Rhein-Sieg, based on [Regeln für wissenschaftliche Arbeiten v9.2.1](https://www.h-brs.de/sites/default/files/related/regeln_fuer_wissenschaftliche_arbeiten_9.2.1.pdf).


## Minimal Example

```typst
#import "@preview/h-brs-thesis-unofficial:0.1.1": template

#show: template.with(
  title: "Titel der Arbeit",
  authors: "Max Mustermann",
  type-of-work: "Bachelorarbeit",
  date: "01. Januar 2026",
)

= Einleitung

Text...
```


## Authors

A single author is passed as a string:

```typst
authors: "Max Mustermann",
```

Multiple authors are passed as an array:

```typst
authors: ("Max Mustermann", "Erika Musterfrau"),
```


## Info

`info` accepts an array of `(label, value)` pairs and is rendered on the title page below the author list.

```typst
info: (
  ("Betreuer:in", "Prof. Dr. Erika Musterfrau"),
  ("Zweitgutachter:in", "Prof. Dr. Max Mustermann"),
),
```


## Other Departments

The template is primarily aimed at the computer science department (Fachbereich Informatik), but works for any department by overriding the `department` and `department-en` parameters.

```typst
#show: template.with(
  // ...
  department: "Fachbereich Wirtschaftswissenschaften",
  department-en: "Department of Business Administration and Economics",
)
```


## Language

The template defaults to German (`lang: "de"`). Set `lang: "en"` for an English thesis — all front matter labels (table of contents, list of figures, list of abbreviations, bibliography, statutory declaration) switch to English automatically, and hyphenation is adjusted accordingly.

```typst
#show: template.with(
  title: "My Thesis",
  authors: "Jane Doe",
  type-of-work: "Bachelor Thesis",
  date: "March 1, 2026",
  lang: "en",
)
```


## Declaration

Set `show-declaration: true` to include a statutory declaration (*Eidesstattliche Erklärung*) in the front matter:

```typst
#show: template.with(
  // ...
  show-declaration: true,
)
```


## List of Figures

The *Abbildungsverzeichnis* is automatically included in the front matter when at least 3 image figures appear in the document — override with `force-list-of-figures: true`. Use `figure` with `kind: image` (the default when wrapping an `image()`) and a `caption`:

```typst
#figure(
  image("diagram.png"),
  caption: [System architecture overview],
) <fig-architecture>
```


## Header Title

By default, the page header displays the document title. Use `header-title` to override this behavior.

**Short title** — useful when the full title is too long for the header:

```typst
#show: template.with(
  title: "A Very Long and Descriptive Title That Does Not Fit in the Header",
  header-title: "Short Title",
  // ...
)
```

**Hide the header** — pass `none` or an empty string:

```typst
header-title: none,
```


## Abbreviations

Abbreviations are managed by the [`abbr`](https://typst.app/universe/package/abbr) package.

### Create an `abbr.csv` file

Each row defines one abbreviation:

```
API,Application Programming Interface
CSV,Comma-Separated Values
HTTP,Hypertext Transfer Protocol
REST,Representational State Transfer
```

Format per row:
- `short,long` — singular only; plural defaults to appending "s"
- `short,long,long-plural` — explicit plural form

### Pass the file contents to the template

```typst
#show: template.with(
  abbr-csv-content: read("abbr.csv"),
  // ...
)
```

The template loads all abbreviations and expands them on first use in the body. The *Abkürzungsverzeichnis* is only rendered in the front matter when more than 3 abbreviations are actually used in the document — override with `force-abbreviations: true`.

### 3. Use abbreviations in the document

```typst
The @API is the primary interface.   // → "Application Programming Interface (API)" on first use
                                      // → "API" on subsequent uses

@API:s    // short form: "API"
@API:l    // long form: "Application Programming Interface (API)"
```

See the [abbr package documentation](https://typst.app/universe/package/abbr) for the full reference.

## Font

The *Regeln für wissenschaftliche Arbeiten* specify Arial as the font. Because Arial is a proprietary typeface not bundled with Typst, this template uses **Liberation Sans** by default — a metrically compatible open-source alternative.

If Arial (or any other font) is available in your Typst environment, you can set it explicitly via the `font` parameter:

```typst
#show: template.with(
  // ...
  font: "Arial",
)
```


## Credits

### H-BRS Logo

Derived from [HochschuleB-R-S.svg](https://de.wikipedia.org/wiki/Datei:HochschuleB-R-S.svg) by Hochschule Bonn-Rhein-Sieg, available on Wikimedia Commons.

### DIN 1505-2 Citation Style

`din-1505-2.csl` is sourced from the [Zotero Style Repository](http://www.zotero.org/styles/din-1505-2).

- **Author:** Sven Rothe (mmoole@googlemail.com)
- **Contributor:** Julian Onions (julian.onions@gmail.com)
- **License:** [Creative Commons Attribution-ShareAlike 3.0](http://creativecommons.org/licenses/by-sa/3.0/)
