# `zhaw-thesis` template

`zhaw-thesis` is an unofficial template for ZHAW academic works, adaped from the official branding, and followoing all official guidelines and requirements.

## Setup

### Web-app (easiest)

1. Create a project from https://typst.app/universe/package/zhaw-thesis
3. In the left sidebar, under "Files", create a folder called "fonts" 
2. Download the font files in the [repo's font directory](https://github.com/stanlrt/typst-zhaw-thesis/tree/main/fonts)
4. Drag and drop the files into the "font" directory in your web-app project

### Local

1. Install Typst from https://typst.app/open-source/
2. Download the font files ftom this repo's font directory and make them accessible to the compiler (https://typst.app/docs/reference/text/text/#parameters-font)
3. Run `typst init @preview/zhaw-thesis:0.1.0` in your project directory

## Configuration options

Below is the complete list of configuration options, inclueing default values and explanations. Most are optional.

```typ
#import "@preview/zhaw-thesis:0.1.0": *
#import "glossary.typ": myGlossary

#show: zhaw-thesis.with(
  language: languages.de,         // Document language 
  cover: (                       
    school: none,                 // E.g., "School of Engineering" REQUIRED
    institute: none,              // E.g., "Computer Science" REQUIRED
    work-type: none,              // E.g., "Bachelor Thesis" REQUIRED
    title: none,                  // Work's title REQUIRED
    authors: none,                // Author name(s), e.g. ("Max Mustermann", "Erika Musterfrau") REQUIRED
    supervisors: none,            // Supervisor name(s), e.g. ("Prof. Dr. John Doe", "Dr. Jane Doe")
    study-program: none,          // E.g., "Computer Science BSc"
    override: none,               // Override cover page with your own file, e.g. [#include: "my-cover.typ"]
  ),
  abstract: (
    keywords: none,               // List of keywords, e.g. ("Typst", "ZHAW", "Thesis Template") REQUIRED
    en: none,                     // English abstract text
    de: none,                     // German abstract text. REQUIRED by ZHAW even when language is English.
    override: none,               // Override abstract page with your own file, e.g. [#include: "my-abstract.typ"]
  ),
  acknowledgements: (
    text: none,                   // Custom acknowledgements text
    override: none,               // Override acknowledgements page with your own file, e.g. [#include: "my-acknowledgements.typ"]
  ),
  declaration-of-originality: (
    location: none,               // E.g., "Zurich" REQUIRED
    text: none,                   // Custom declaration text
    override: none,               // Override declaration page with your own file, e.g. [#include: "my-declaration.typ"]
  ),
  glossary-entries: none,         // Variable containing glossary entries, e.g., myGlossary
  biblio: (
    file-path: none,              // Path to your .bib file, e.g., "references.bib"
    style: "ieee",                // Bibliography style, e.g., "ieee", "apa", etc.
  ),
  appendix: none,                 // Content for the appendix, e.g., [#include: "appendix.typ"]
  page-border: true,              // Enable/disable page border
)
```

## Exported symbols

The package exports the following symbols for you to use if needed:

```typ
#import "@preview/zhaw-thesis:0.1.0": (
  zhaw-thesis,   // Main template function, see docu above
  callout,       // Coloured callout box to highlight important text

  centered,      // Vertically centred layout
  today,         // Current date in local format
  languages,     // Available languages
  push-lang,     // Set new language (see docu below)
  pop-lang,      // Switch back to previous language (see docu below)
)
```

You can refer to the [demo document](https://github.com/stanlrt/typst-zhaw-thesis/blob/main/template/main.typ) for usage examples.

## Configuration of dependencies

### Glossary

The template uses the [Glossy package](https://typst.app/universe/package/glossy/) to power the glossary feature under the hood. 
You can find instructions about how to use all its options directly on the [package page](https://typst.app/universe/package/glossy/).

### Code blocks

The template uses the [Codly package](https://typst.app/universe/package/codly/) to style code snippets.
You can find instructions about how to use all its options in [its PDF manual](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf).

### Multi-linguism

Should you need use different languages for different pages of your work, you can refer to [Tieflang's documentation](https://typst.app/universe/package/tieflang/).

## Feature requests & problems

Feel free to request features or report probems [here](https://github.com/stanlrt/typst-zhaw-thesis/issues)
