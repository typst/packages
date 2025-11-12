#import "@preview/ai-ethics-tuw:1.0.0": *


#show: ai-ethics-template.with(
  title: [This is the title of the paper],
  author: (
    name: [Author],
    number: [Matrikel number],
    email: [Email address],
    course: [Course name]
  ),
  abstract: [
    Abstract of approximately 100-200 words.
  ],
  keywords: ("Keyword1", "keyword2", "...", "keyword(n)")
)

= Instructions for authors

== Info
This is the template for the paper of the AI Ethics course, TU Wien. The paper should be in English and should be around 10 pages with a 10% buffer. This excludes references. This is the Typst template, adapted from the official LaTeX template.

The reviewing process is single-blind and papers should not be anonymized. The first page should contain an abstract of around 100-200 words. You do not need to add a table of contents but are encouraged to add an "outline of the paper" paragraph at the end of your introduction section. Your paper must be submitted as a PDF in TUWEL.


For the final version incorporating the received feedback, you are asked to mark important changes in the paper by using a coloured font, e.g., blue.


== General Info on the Style
Important information pertaining to the preparation of your paper is listed below. This list resonates publication policies of scientific journals and conferences.

- Please prepare your paper by editing this file (main.typ) as well as the bibliography file, `bibliography.bib`.

- This is an example citation of an important paper @shafer2012fundamentals.


#bibliography("bibliography.bib")
