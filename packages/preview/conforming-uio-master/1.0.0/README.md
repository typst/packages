# conforming-uio-master
An unofficial template for writing your Master's thesis at the University of Oslo.

The template only handles front pages, setup for printing and sectioning/chaptering. Numbering for figures, tables, equations and other numbered content is not set up by the template, and must be done separately.

## Usage
Running the following command will create a new directory with all the necessary files
```
typst init conforming-uio-master
```

## Configuration
This package exports the `uio-thesis` function with the following named arguments:
  - `title: []`: The title of the thesis, content or string
  - `subtitle: []`: The subtitle of the thesis, content or string. Can be omitted.
  - `author: []`: The author(s) of the thesis. Multiple authors should have line breaks between.
  - `supervisor: []`: The supervisor(s) of the thesis. Multiple supervisors should have line breaks between.
  - `study-programme: []`: The study programme the thesis is written for.
  - `department: []`: The department the study programme belongs to.
  - `faculty: []`: The faculty the department belongs to.
  - `abstract: []`: The abstract. Should contain headings as level one heading.
  - `preface: []`: The preface.
  - `semester: [Spring]`: The semester the thesis is delivered.
  - `print: false`: Set to true for a version suited for printing.
  - `ects: 60`: The number of ECTS (studiepoeng) for the thesis.
  - `front-page-font: "Nimbus Sans"`: The font on the front page. Should be a grotesk font, similar to _Helvetica_.
  - `font: "libertinus serif"`: The font used on all text except the front page. Default value is the default Typst font.
  - `language: "en"`: Used to set the language, default is `en`for english. Other supported languages are `nb` for norwegian bokmål and `nn` for norwegian nynorsk.


## Minimal working example

```typst
#import "@preview/conforming-uio-master:1.0.0": uio-thesis

#let abstract = [
  = Abstract
  #lorem(100)

  = Sammendrag // Optional abstract in a second language
  #lorem(100)
]
#let preface = lorem(150)

#show: uio-thesis.with(
  title: "Your Title",
  subtitle: "",
  author: "Your Name",
  supervisor: "Your Supervisor",
  study-programme: "Your study programme",
  department: "Your department",
  faculty: "Your faculty",
  abstract: abstract,
  preface: preface,
)
```

## Dependencies
- Developed with Typst 0.14.2, not guaranteed to work with older versions
- hydra 0.6.2 (a typst package used for showing heading in headers)

## Use of the logo
The logo for the University of Oslo is not covered by the MiT license. There are some particular rules regarding it's use, those can be found [here](https://www.uio.no/english/about/designmanual/profile-elements/logo/index.html).
