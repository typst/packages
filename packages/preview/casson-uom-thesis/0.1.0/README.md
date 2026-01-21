# Typst PhD thesis template for the University of Manchester

Typst template based upon [The University of Manchester Presentation of Theses Policy](https://documents.manchester.ac.uk/display.aspx?DocID=7420) which relates to the examination of doctoral and MPhil degrees at The University of Manchester and applies to full-time and part-time postgraduate research students of the following degrees: Doctoral degrees: Doctor of Philosophy (PhD); Doctor of Medicine (MD) Doctor of Business Administration (DBA); Professional, Engineering and Enterprise Doctorates; Master of Philosophy (MPhil). This template has been checked to be compliant with the 2024 requirements. Responsibility for ensuring compliance with the University of Manchester Presentation of Theses Policy remains with the candidate.


## Using the template on typst.app
You can download files from the template repository and upload them to your project folder. If doing this, in main.typ use the import line:
  
  `#import "casson-uom-thesis.typ": *`
  
The template should ultimately be available on Typst Universe as casson-uom-thesis. Using this approach, create an account at [Typst.app](https://typst.app/) and start a new project by clicking on Start from template and searching for casson-uom-thesis. Now, the import line in main.typ will need to be:

  `#import "@preview/casson-uom-thesis:0.1.0": *`


## Local installation
If Typst Universe is online, the template will be downloaded automatically to

  `$CACHEDIR/typst/packages/preview/casson-uom-thesis/$VERSION/`

when you run the command

  `typst init @preview/cason-uom-thesis:$VERSION thesis_project_name`

$VERSION should be 0.1.0. The value $CACHEDIR for your OS can be discovered from [https://docs.rs/dirs/latest/dirs/fn.cache_dir.html](https://docs.rs/dirs/latest/dirs/fn.cache_dir.html).

You should then be able to run

  `typst compile main.typ`

or

 `typst compile --pdf-standard a-2b main.typ`

to compile the document .


## Usage
The template takes a number of options (e.g. font, font size, whether the optional front-matter items are displayed). These are detailed in main.typ and should be faily obvious. 
