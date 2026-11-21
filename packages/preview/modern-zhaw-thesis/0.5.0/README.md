# `modern-zhaw-thesis` template

`modern-zhaw-thesis` is a comprehensive template for ZHAW academic works (theses, exercises, reports...), adapted from the official branding and following official requirements. It supports both English and German.

[Here's a showcase](./showcase.pdf) of how it looks like.

## Setup

1. Download the font files from the repo's font directory:

    [GitHub](https://github.com/stanlrt/typst-zhaw-thesis/tree/75773f640f2eb9d8d94e634a3151ddfc12becca3/fonts)

    [Direct download](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fstanlrt%2Ftypst-zhaw-thesis%2Ftree%2F75773f640f2eb9d8d94e634a3151ddfc12becca3%2Ffonts)

### Web-app (easiest)

2. [Create a project using the template](https://typst.app/app?template=modern-zhaw-thesis&version=0.5.0)
3. In the left sidebar, under "Files", create a folder called `fonts`
4. Drag and drop the files into this `fonts` directory

### Local

2. Install Typst from https://typst.app/open-source/
3. Make the downloaded fonts accessible to the compiler (https://typst.app/docs/reference/text/text/#parameters-font)
4. Run `typst init @preview/modern-zhaw-thesis:0.5.0` in your project directory

## All configuration options

Below is the complete list of configuration options, including default values and explanations. Most are optional.

```typ
#import "@preview/modern-zhaw-thesis:0.5.0": zhaw-thesis, languages

// Note: `override` options accept Typst files (`override: [#include "my-override.typ"]`), and `none`

#show: zhaw-thesis.with(
  language: languages.de,       // Document language
  preset: "thesis",             // "thesis": show everything (default)
                                // "draft": hide all frontmatter (to focus on writing)
                                // "exercise": show cover+TOC (no abstract/acks./declaration)

  cover: (
    school: none,               // E.g., "School of Engineering" REQUIRED
    institute: none,            // E.g., "Computer Science" REQUIRED
    work-type: none,            // E.g., "Bachelor Thesis" REQUIRED
    title: none,                // Work's title REQUIRED
    authors: none,              // Author name(s), e.g. ("Max Muster", "Erika Muster") REQUIRED
    supervisors: none,          // Supervisor name(s), two formats:
                                   // 1. Simple: `("Prof. Dr. John Doe", "Dr. Jane Doe")`
                                   // 2. Categorised: `(main: "Prof. Dr. John Doe",
                                   //       secondary: "Dr. Jane Doe", external: "Dr. External")`
    industry-partner: none,     // Industry partner name, e.g. "Schweizer AG"
    study-program: none,        // E.g., "Computer Science BSc"
    override: none,             // Override the cover page with your own file
  ),

  abstract: (
    keywords: none,             // List of keywords, e.g. `("machine learning")` REQUIRED
    en: none,                   // English abstract text
    de: none,                   // German abstract text. REQUIRED by ZHAW even when lang is English.
    override: none,             // Override the abstract page with your own file
  ),

  acknowledgements: (
    text: none,                 // Custom acknowledgements text
    colophon: true,             // Show a small template credit at the bottom of the page
    override: none,             // Override the acknowledgements page with your own file
  ),

  declaration-of-originality: (
    location: none,             // E.g., "Zurich" REQUIRED
    text: none,                 // Custom declaration text
    ai-label: <appendix:ai>,    // Label of your AI usage section; the default text references it if it exists
    override: none,             // Override the declaration page with your own file
  ),

  bibliography: none,           // bibliography() object
                                // e.g. `bibliography("refs.bib", style: "ieee")` (see Typst's docs)
  
  glossary-entries: none,       // Variable containing glossary entries (see template)
  appendix: none,               // Appendix Typst file, e.g. [#include "appendix.typ"]
  date: none,                   // Date shown on cover, abstract and declaration, e.g. `datetime(year: 2026, month: 6, day: 5)`
                                // Defaults to today. Set it to freeze the submission date.
  page-border: true,            // Enable/disable page border  
  print-mode: false,            // Gives a white background to the cover page to reduce ink usage  
)
```

## Exported symbols

The package exports the following symbols for you to use if needed:

```typ
#import "@preview/modern-zhaw-thesis:0.5.0": (
  zhaw-thesis,   // Main template function, see docu above
  callout,       // Coloured callout box to highlight important text

  centered,      // Vertically centred layout
  today,         // Current date in local format; `today(date: d)` formats a given date
  languages,     // Available languages
  push-lang,     // Set new language (see docu below)
  pop-lang,      // Switch back to previous language (see docu below)
)
```

You can refer to the [demo document](./template/main.typ) for usage examples.

## Configuration of dependencies

### Glossary

The template uses the [Glossy package](https://typst.app/universe/package/glossy/) to power the glossary feature under the hood.
You can find instructions about how to use all its options directly on the [package page](https://typst.app/universe/package/glossy/).

### Code blocks

The template uses the [Codly package](https://typst.app/universe/package/codly/) to style code snippets.
Since 0.5.0 the template uses Codly 2, which has a new API: configure it with show rules such as `#show: codly.set_(..)` (import it with `#import "@preview/codly:2.0.0" as codly`). Codly 1 calls like `#codly(..)` no longer affect the template's code blocks. See [its README](https://github.com/Dherse/codly/blob/v2.0.0/README.md) for all options.

### Multi-linguism

Should you need use different languages for different pages of your work, you can refer to [Tieflang's documentation](https://typst.app/universe/package/tieflang/).

## Feature requests & problems

Feel free to [request features or report problems here](https://github.com/stanlrt/typst-zhaw-thesis/issues)

## License and Trademark Notice

### Software License

The Typst code and template structure in this package are licensed under the **MIT-0 License** (MIT No Attribution). See the [LICENSE](LICENSE) file for details.

### ZHAW Logo and Trademark

**Important:** The ZHAW logo and trademark included in this package are **NOT** covered by the MIT-0 license.

- **Trademark Owner:** The ZHAW logo and brand are the exclusive property of Zürcher Hochschule für Angewandte Wissenschaften (ZHAW).
- **Rights:** Users of this package do **not** receive any rights to sublicense, sell, or redistribute the ZHAW logo under the MIT-0 license terms.
- **Usage:** The logo is included for the specific purpose of creating ZHAW-compliant academic documents. Any other use requires permission from ZHAW.

As specified in section 2.b.2 of Creative Commons and similar public licenses: **"The trademark ZHAW is not affected by the license. Patent and trademark rights are not licensed under this Public License."**

For information about ZHAW's branding guidelines, refer to the official [ZHAW trademark guidelines for open educational resources](https://gpmpublic.zhaw.ch/GPMDocProdDPublic/Vorgabedokumente_ZHAW/Z_MB_Merkblatt_CC_Lizenzen_von_OER.pdf).

### Unofficial Template Notice

This is an **unofficial** template created by a student. It is not endorsed, maintained, or supported by ZHAW. The template attempts to follow official ZHAW branding guidelines and academic requirements, but users should verify compliance with current university standards.

## Changelog

### 0.5.0

- **BREAKING**: Requires Typst 0.15.0 or later (needed by Codly 2)
- **BREAKING**: Upgraded Codly from 1.3.0 to 2.0.0. Codly 1 calls in your document (`#codly(..)`, `#codly-disable`, ...) no longer affect code blocks; use Codly 2 show rules instead (`#show: codly.set_(..)`)
- Upgraded Glossy to 0.9.2 and Datify to 1.3.0
- Emphasised text in headings, the cover title and the outline is now slanted (the header font has no italic variant)
- **Font files changed**: Fira Code is now a single variable font and the unused condensed TeX Gyre Heros files are gone. Download the fonts again from the link in the setup section
- Typst 0.15 has breaking changes of its own, see the [Typst 0.15 migration guide](https://typst.app/docs/changelog/0.15.0/)
- Added colophon to acknowledgements page, and the corresponding setting
- Added proper supplements to header labels and appendix
- Fixed header spacing convergence issue
- Fixed H4 labelling
- Fixed labels naming convention
- Fixed abstract keyword alignment
- Fixed abstract formatting
- Added `date` setting to fix the date shown on the cover, abstract and declaration pages (defaults to today)
- Added `ai-label` setting to the declaration of originality, to reference an AI usage section with a custom label
- Set PDF metadata (title, authors, keywords, date) automatically from the cover and abstract settings
- Code snippet figures are now labelled "Code Snippet" / "Code-Snippet" instead of "Listing"
- English dates now use British day-month order (e.g. "17 November 2026")
- Appendix supplement now also applies when the user sets their own heading supplements
- Exported `today` accepts an optional `date:` argument

### 0.4.0

- **BREAKING (layout shifts)**: Tweaked H1 font size and spacing based on feedback
- **BREAKING**: `biblio: (file:, style:)` replaced by `bibliography:` — pass a `bibliography()` object directly (refer to [Typst's docs](https://typst.app/docs/reference/model/bibliography/))
- **BREAKING**: `hide-frontmatter` replaced by `preset` — use `preset: "draft"` for equivalent behaviour
- Added `preset` parameter: `"thesis"` (default, show everything), `"draft"` (hide all frontmatter), `"exercise"` (show cover page + TOC, hide abstract/acknowledgements/declaration)
- Replaced custom Glossy patch with official 0.9.1 release. Should not be a breaking change.

### 0.3.0

- Allow setting overrideable options to `none`
- Fixed edge cases when some options were set to `none` and caused errors
- Fixed declaration of originality appendix ref
- Fixed bug displaying supervisor names in acknowledgements page
- Fixed localisation of "Chapter" label in page header
- Fixed long H1s overlapping with next section

### 0.2.0

- Added custom quote styling
- Fixed glossary issues when no entries are provided
- Localised outline and appendix headings
- Fixed Glossy init-glossary validation bug
- Fixed empty optional supervisor fields
- Fixed translation strings
- Fixed custom declaration of originality body rendering
- Fixed README typos

### 0.1.1

Improved README

### 0.1.0

Initial release
