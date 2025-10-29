# UFSCholar

<center>
  Write ABNT-compliant thesis and dissertations for works at UFSC
</center>


## Quick Start

Create the cover and few following pages, and configure the document, by writing

```typst
#import "@preview/ufscholar:0.1.3": *

#show: thesis.with(
  title: [Title of the dissertation\ Can be broken into two lines],
  subtitle: "Complementary subtitle, not more than two lines long",
  author: "Author's complete name",

  logo: image("your-logo.svg", width: 5em),
  institution: [
   Federal University of Santa Catarina\
   Technology Center\
   Automation and Systems Engineering\
   Undergraduate Course in Control and Automation engineering
  ],
  contributors: (
   ("Prof. XXXXXX, Dr.", "Advisor", "UFSC/CTC/DAS"),
   ("XXXXXX, Eng.", "Supervisor", "Company/University XXXX"),
   ("Prof. XXXX, Dr.", "Evaluator", "Institution XXXX"),
   ("Prof. XXXX, Dr.", "Board President", "UFSC/CTC/DAS"),
   ("Prof. XXXX, Dr.", "Course Coordinator", none),
  ),
  cont-in-description: (0, 1),
  cont-in-board: (0, 1, 2, 3),

  address: ("Florianópolis", "Santa Catarina", "Brazil"),
  description: [Final report of the subject DAS5511 (Course Final Project) as a Concluding Dissertation of the Undergraduate Course in Control and Automation Engineering of the Federal University of Santa Catarina.],
  evaluation: [This dissertation was evaluated in the context of the subject DAS5511 (Course Final Project) and approved in its final form by the Undergraduate Course in Control and Automation Engineering],

  lang: "en",
)
```

You can also write various elements by using their respective names. The supported elements this far are:

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
