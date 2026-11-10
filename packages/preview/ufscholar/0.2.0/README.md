# UFSCholar

<center>
  Write ABNT-compliant thesis and dissertations for works at UFSC
</center>


## Quick Start

Create the cover and few following pages, and configure the document, by writing

```typst
#import "@preview/ufscholar:0.2.0": *

#show: thesis.with(
  title: [Title of the dissertation\ Can be broken into two lines],
  subtitle: [Complementary subtitle, not more than two lines long],
  author: [Author's complete name],
  address: ([\<City>], [\<State/Province>], [\<Country>]),
  date: datetime.today(),
  lang: "en",
)
```

You must also write various elements by using their respective names. The supported elements this far are:

- Cover Page
- Title Page
- Catalog Card
- Examining Board
- Dedicatory
- Acknowledgements
- Epigraph
- Disclaimer
- Abstract
- List of Figures
- List of Tables
- Summary
- Part
- Appendix
- Annex

Be careful that, for now, the above elements will be placed in the same order you write them, so ensure they are in the same order as above.

## Description

Generate authentic, structured, and standardized articles, compliant with the requirements of the Brazilian Association of Technical Standards (ABNT, in Portuguese) and those of the Federal University of Santa Catarina.

This project was based on [min-article](https://github.com/mayconfmelo/min-article).

## Roadmap

- Ensure correct placement of all document elements.
- Write a complete manual

## More Information

- [Example Typst code](https://github.com/MarkV43/ufscholar/blob/main/template/main.typ)
