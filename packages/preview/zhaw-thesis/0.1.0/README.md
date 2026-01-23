# The `zhaw-thesis` Package
<div align="center">Version 0.1.0</div>

An unofficial template for ZHAW academic works, adaped from the official branding.

## Setup

### Web-app (easiest)

1. Create a project from https://typst.app/universe/package/zhaw-thesis
2. Download the font files in the repo's font directory.
3. Drag and drop the files into the webapp's file panel on the left (you can create a font folder)

### Local

1. Install Typst from https://typst.app/open-source/
3. Download the font files ftom this repo's font directory and make them accessible to the compiler (https://typst.app/docs/reference/text/text/#parameters-font)
4. Run `typst init @preview/zhaw-thesis:0.1.0` in your project directory

## Configuration

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