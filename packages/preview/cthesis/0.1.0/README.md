# CTHesis
An unofficial, slightly opinionated [Typst](https://typst.app/home/) template for theses at Chalmers University of Technology (Gothenburg, Sweden). 

The covers and front matter are based on Chalmers's official LaTeX thesis templates and comply with all [design requirements for publishing](https://www.chalmers.se/en/education/your-studies/masters-and-bachelors-thesis/master-thesis/design-and-publish-master-thesis/).

## Overview
### Layout
- Front cover
- Title page
- Imprint
- English abstract
- Swedish abstract 
- Preface
- Acknowledgements
- List of abbreviations
- Nomenclature
- Table of contents
- List of figures
- List of tables
- ...
- Back cover

### Features
- Supports both English and Swedish via `set text(lang: "en")` and `set text(lang: "sv")`
- Supports both bachelor's and master's theses
- Supports University of Gothenburg collaborations
- Custom styled level 1 headers for chapters and appendices 
- Numeric numbering for chapters and alphabetical for appendices (via `#show: appendix`)
- A `caption` function for specifying separate figure captions in the list of figures and underneath figures.
- Optional, recto-aligned page formatting for physical printing
- Uses `Arial` font for cover pages if available, otherwise falls back to `TeX Gyre Heros` (included in Typst web app). See [docs](https://typst.app/docs/reference/text/text/#parameters-font) for how to add custom fonts. 
- Separate numbering for figures and tables
- Figure and table numbering in appendices are prefixed by appendix numbering letter (e.g., A1)
- Figure and table numbering reset for each appendix
- Embeds the title, author, abstract, keywords, and date into the file metadata

## Getting Started
Visit the template's [homepage](https://typst.app/universe/package/cthesis) and click “Create project in app” to try it out in the Typst web app.

Alternatively, create a local project via the Typst CLI:

```sh
typst init @preview/cthesis:0.1.0
```

## Usage
To initialize the template, invoke the `cth-thesis` function via a show rule at the top of your document:

```typst
#show: cth-thesis.with(title: "Thesis Title")
```
With configuration options (see next section) being passed as needed. All content following this declaration constitutes the thesis body, and level 1 headings (\=) mark chapters, level 2 (\==) sections and level 3 (\===) subsections.

Finally, optionally invoke `appendix` as a show rule to mark the subsequent sections as appendices and format them accordingly.  
```typst
#show: appendix
```
Level 1 headings now mark appendices instead of chapters. 

## Configuration
- `title`: The main title of the thesis
- `subtitle`: An optional subtitle
- `authors`: The name(s) of the author(s)
- `program`: The academic program
- `department`: The department hosting the project
- `abstracts`: A dictionary containing the abstract text mapped by language keys:
    - `en`: English abstract
    - `sv`: Optional Swedish abstract
- `keywords`: The keywords used for metadata and the abstract page
- `supervisors`: The supervisor(s) for the thesis
- `examiner`: The primary examiner
- `advisor`: The corporate or industrial advisor, if applicable
- `co-examiner`: The co-examiner who helped grade the thesis
- `cover`: A dictionary to add a cover image, accepting:
  - `image`: Content representing a cover image
  - `description`: Description of the cover image for the imprint page
- `preface`: The body text for the preface section
- `acknowledgments`: The body text for the acknowledgments section
- `gu`: A boolean value; set to `true` if the project is a joint collaboration with the University of Gothenburg, which adjusts logos and branding accordingly
- `year`: The year of publication; defaults to the current calendar year
- `type`: The thesis type, accepting `"b"`, `"ba"`, `"bachelor"`, or `"bachelors"` for Bachelor's theses, and `"m"`, `"ma"`, `"master"`, or `"masters"` for Master's theses.
- `print`: A boolean value; if `true`, the layout optimizes page breaks for physical two-sided printing by forcing major sections to start on right-hand pages
- `abbreviations`: A dictionary mapping abbreviations directly to their full definitions (e.g., `("CTH": "Chalmers Tekniska Högskola")`).
- `nomenclature`: A nested dictionary of dictionaries used to group terms by category

## To do
- Use new Chalmers logos
- Abstracts in arbitrary languages
