# STP BSUIR
An unofficial Typst template for preparing academic and technical documents 
according to the requirements of the Enterprise Standard of 
the Belarusian State University of Informatics and Radioelectronics (BSUIR), 
STP 01-2024 ([БГУИР СТП 01-2024](https://www.bsuir.by/m/12_100229_1_185586.pdf)).

The template is intended for documents such as term papers, laboratory 
reports, theses, and other academic documentation that must follow the 
BSUIR Enterprise Standard formatting requirements.

## Features
- General text formatting (2.1.x - 2.2.x);
- Support for all list types (2.3.5 - 2.3.8);
- Basic support for formulas and equations;
- Table formatting;
- Appendices;
- Footnotes;
- Experimental implementation of GOST 7.1-2003 bibliography for Hayagriva;


## Usage
Import the template package at the beginning of your document and apply show rule:
```typst
#import "@preview/typo-stp:0.2.0": *

#show: template
```

For example:
```typst
#import "@preview/typo-stp:0.2.0": *

#show: template

#outline()

// there are also #abstract and #conclusion
#introduction
This is the introduction of the document.

= First Section
This is the first section.

- Element;
- Element;
- Element.

== First Subsection
Some text.

+ Element 1.
+ Element 2.
+ Element 3.

== Second Subsection
#abclist[
  First element;   
][
  Second element;
  + First nested element;
  + Second nested element;
][
  Third element.
]

#figure(
  image("image.png"),
  caption: [Example figure],
)

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    table.header[Column 1][Column 2][Column3],
    
    [Content], [Content], [Content],
    // ...
  ),
  caption: [Example table],
)

$ x^2 + y^2 = z^2 $

#explanation[
  / x: something;
  / y: like another variable;
  / z: idk. 
]

#appendix(
  "Not that important",
  "Code listing"
) <code-listing-appendix>

#source-code(
  path("path/to/file"),
  "Displayed name"
)
```

See [example documents](https://github.com/Yakush-A/typstp/tree/main/example) for more complete examples.

## Current limitations
Some parts of STP 01-2024 are not fully implemented yet:

- Built-in title pages, assignment sheets, lists of elements and documents are not available;
- Bibliography styling may still be incomplete;
- Equations formatting;
- Some edge cases like continuous numbering for images, tables, equations. 
