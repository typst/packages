# STP BSUIR

An unofficial Typst template for preparing academic and technical documents according to the requirements of the Enterprise Standard of the Belarusian State University of Informatics and Radioelectronics (BSUIR), STP 01-2024 (БГУИР СТП 01-2024).

The template is intended for documents such as term papers, laboratory reports, theses, and other academic documentation that must follow the BSUIR formatting requirements.

## Features

The template currently provides support for:

- **Document structure**
  - introduction;
  - sections, subsections, paragraphs, and subparagraphs;
  - appendices;
  - table of contents;
  - automatic heading numbering.

- **Text and layout**
  - document margins and page layout;
  - paragraph formatting;
  - page numbering;
  - document formatting according to STP 01-2024.

- **Figures**
  - numbered figures;
  - figure captions;
  - references to figures;
  - automatic figure numbering based on the current section.

- **Mathematical formulas**
  - numbered and unnumbered formulas;
  - formula formatting according to the document requirements.

- **Footnotes and references**
  - footnotes;
  - cross-references to document elements;
  - citations using Typst's bibliography and citation mechanisms.

- **Lists**
  - numbered lists;
  - bulleted lists;
  - nested lists;
  - Cyrillic letter numbering for lists;
  - custom numbering for nested list levels.

- **Tables**
  - basic tables;
  - table captions;
  - table numbering.

- **Appendices**
  - automatic appendix lettering;
  - appendix labels in the Приложение А format.

## Usage

Import the template package at the beginning of your document and apply show rule:

```typst
#import "@preview/stp:0.1.0": *

#show: template
```

The package configures the document according to STP 01-2024. The document content can then be written using regular Typst syntax and the template's provided functions.

For example:

```typst
#import "@preview/stp:0.1.0": *

#show: template


#introduction

This is the introduction of the document.

= First Section

This is the first section.

== First Subsection

Some text.

#figure(
  image("image.png"),
  caption: [Example figure],
)

$ x^2 + y^2 = z^2 $

#footnote[An example footnote.]
```

See the included example document for a more complete example.

## Current limitations

Some parts of STP 01-2024 are not fully implemented yet:

- table headings and their formatting;
- complex list numbering;
- references to individual list items;
- paragraph indentation in the bibliography;
- some bibliography formatting requirements;
- complete bibliography styling according to the standard.

Basic tables and lists are supported, but their formatting does not yet fully correspond to all STP requirements.

## Known Typst limitations

Some formatting requirements cannot currently be implemented cleanly because of limitations of Typst itself.

In particular, Typst does not currently provide a suitable way to add paragraph indentation to individual bibliography entries. As a result, bibliography entries cannot be formatted with the required first-line indentation.

