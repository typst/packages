# `modern-zhaw-thesis` template

`modern-zhaw-thesis` is an unofficial template for ZHAW academic works, adapted from the official branding and following official requirements. It supports both English and German.

[Here's a showcase](./showcase.pdf) of how it looks like.

## Setup

1. Download the font files from the repo's font directory. 

    [GitHub](https://github.com/stanlrt/typst-zhaw-thesis/tree/28927077165d31305c4438657eb0cdefa32bbcbd/fonts) 

    [Direct download](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fstanlrt%2Ftypst-zhaw-thesis%2Ftree%2F28927077165d31305c4438657eb0cdefa32bbcbd%2Ffonts)

### Web-app (easiest)

2. Create a project from https://typst.app/universe/package/modern-zhaw-thesis
3. In the left sidebar, under "Files", create a folder called "fonts" 
4. Drag and drop the files into the "font" directory in your web-app project

### Local

2. Install Typst from https://typst.app/open-source/
3. Make the downloaded fonts accessible to the compiler (https://typst.app/docs/reference/text/text/#parameters-font)
4. Run `typst init @preview/modern-zhaw-thesis:0.1.0` in your project directory

## Configuration options

Below is the complete list of configuration options, inclueing default values and explanations. Most are optional.

```typ
#import "@preview/modern-zhaw-thesis:0.1.0": zhaw-thesis, languages

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
  glossary-entries: none,         // Variable containing glossary entries, e.g., myGlossary (see template)
  biblio: (
    file: none,                   // Stream to your .bib file, e.g., read("references.bib", encoding: none)
    style: "ieee",                // Bibliography style, e.g., "ieee", "apa", etc.
  ),
  appendix: none,                 // Content for the appendix, e.g., [#include: "appendix.typ"]
  page-border: true,              // Enable/disable page border
  hide-frontmatter: false,        // Hide all content before the first chapter (useful to focus on writing)
)
```

## Exported symbols

The package exports the following symbols for you to use if needed:

```typ
#import "@preview/modern-zhaw-thesis:0.1.0": (
  zhaw-thesis,   // Main template function, see docu above
  callout,       // Coloured callout box to highlight important text

  centered,      // Vertically centred layout
  today,         // Current date in local format
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
You can find instructions about how to use all its options in [its PDF manual](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf).

### Multi-linguism

Should you need use different languages for different pages of your work, you can refer to [Tieflang's documentation](https://typst.app/universe/package/tieflang/).

## Feature requests & problems

Feel free to request features or report probems [here](https://github.com/stanlrt/typst-zhaw-thesis/issues)

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

