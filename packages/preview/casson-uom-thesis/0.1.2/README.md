# Typst thesis and dissertation template for the University of Manchester

Typst template for writing PGR reports (e.g. final PhD thesis and progression review reports), and UGT/PGT reports (e.g individual dissertations) based upon: 

- [The University of Manchester Presentation of Theses Policy](https://documents.manchester.ac.uk/display.aspx?DocID=7420)
- [The University of Manchester Presentation of PGR Dissertations Policy](https://documents.manchester.ac.uk/display.aspx?DocID=7441)
- [The University of Manchester Guidance for the Presentation of Taught Dissertations for UG and PGT Provision](https://documents.manchester.ac.uk/display.aspx?DocID=2863)

Templates have been checked against the 2026 policy versions. Responsibility for ensuring compliance with requirements remains with the candidate.

The template needs Typst 0.15 or later.


## Using the template on typst.app
The template is on [Typst Universe](https://typst.app/universe/package/casson-uom-thesis) as casson-uom-thesis. Create an account at [Typst.app](https://typst.app/) and start a new project by clicking on Start from template and searching for casson-uom-thesis.

Alternatively, you can download files from the template repository and upload them to your project folder. If doing this, in main.typ comment out

  `#import "@preview/casson-uom-thesis:0.1.2": *`

and instead uncomment

  `//#import "casson-uom-thesis.typ": *`

Fonts


## Local installation
If Typst Universe is online, the template will be downloaded automatically to

  `$CACHEDIR/typst/packages/preview/casson-uom-thesis/$VERSION/`

when you run the command

  `typst init @preview/casson-uom-thesis:$VERSION thesis_project_name`

$VERSION should be 0.1.2. The value $CACHEDIR for your OS can be discovered from [https://docs.rs/dirs/latest/dirs/fn.cache_dir.html](https://docs.rs/dirs/latest/dirs/fn.cache_dir.html).

You should then be able to run

  `typst compile --pdf-standard ua-1 main.typ `

to compile the document.


## Accessible PDFs
To export an accessible PDF, run

  `typst compile --pdf-standard ua-1 main.typ`

PDF/UA-1 needs alt text on every image and equation. main.typ shows how to add it.

Accessibility aspects in the PDF produced with the template have been checked with PDFix Desktop, PDFUA-1. There is currently an issue relating to ViewerPreferences. 


## Report types
As well as theses, the template can be used for dissertations. Set `report` to:

- `"thesis"`, the default, for a PhD.
- `"continuation-report"` for nine-month, second year, and third year progress reports during a PhD. 
- `"research-dissertation"` for an MSc by Research.
- `"taught-dissertation"` for an undergraduate or taught masters dissertation, such as a BEng or MEng project report or an MSc dissertation. The title page gives `studentid` instead of the name, or a list of IDs for a group project, and `degree` has to be given.

Particularly for taught dissertations, departments/divisions may have their own rules on top of these, so check your course handbook as well.


## Usage
The template takes a number of options (e.g. font, font size, whether the optional front-matter items are displayed). These are detailed in main.typ and should be fairly obvious. 

The preliminary pages follow the order in the policy. The COVID-19 impact statement (`covidstatement`), list of thesis revisions (`revisions`), AI declaration (`aideclaration`) and content notification (`contentnotification`) are only included if given. `declaration` replaces the standard declaration of originality, for when part of the work has been submitted for another degree, and `degree` sets the degree on the title page.

Chapters and appendices start on a new page by themselves.

For a short caption in the list of figures or tables, use `caption: uom-flex-caption([Short caption for list at front], [Longer caption to display in the main text])`.

While writing, set `draft: true`. It puts DRAFT across each page, and lets you use `#uom-todo[...]` for things still to do and `#uom-missing-figure([Caption])` for figures that haven't been made yet. They are listed at the end. Without draft mode the build stops if any are left, so none end up in the version that is handed in.

For a figure made of several parts, use `uom-subfigures`. It takes the same arguments as `subpar.grid` from the [subpar](https://typst.app/universe/package/subpar) package, and numbers the figure and its parts to match the rest of the thesis. main.typ has an example.
