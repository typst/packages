#import "@preview/unofficial-oe-nik-thesis:0.1.1": ai-generated

= Implementation <implementation>

== Signed forms

#figure(
  ```typ
  #show: thesis-template.with(
    worksheet: path("signed/worksheet.pdf"),
    declaration: path("signed/declaration.pdf"),
    consultation-log: path("signed/consultation-log.pdf"),
  )
  ```,
  caption: [Inserting the signed forms],
) <signed-forms>

The signed forms are scanned to @pdf and inserted as shown in @signed-forms.
Until then, the template puts red placeholder pages in their place, with the right page count.

== Draft mode <draft-mode>

Draft mode is on by default.
A missing part, like an abstract or a signed form, shows up as a red note instead of an error, so the thesis always compiles.

For the version to submit, turn draft mode off with `draft: false`, or from the command line:

```sh
typst compile --input draft=false main.typ
```

== Citations and abbreviations

Sources go in `bibliography.bib` and are cited by their keys: `@guide` becomes @guide.
The bibliography uses the IEEE style, numbered in the order of the first citations.

Abbreviations work the same way: `@pdf` becomes @pdf.
Only the first use is written out, and only the abbreviations actually used are listed at the end.

== Testing

I tested the parameters with wrong values, some of which an AI suggested @ai-test-cases.
The rector's instruction on AI @ai-instruction requires listing every AI tool used at the end of the thesis, and putting AI-generated text in italics with a reference to the tool:

#ai-generated(<ai-test-cases>)[An unknown degree and a missing registration number.]
