# bamdone-ieeeconf
This is a Typst template for a two-column paper from the proceedings of the
Institute of Electrical and Electronics Engineers. The paper is tightly spaced,
fits a lot of content and comes preconfigured for numeric citations from
BibLaTeX or Hayagriva files.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `bamdone-ieeeconf`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/bamdone-ieeeconf
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ieee` function with the following named arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `given`, `surname`, `email`, and `affiliation`.
- `affilitations`: An array of affilitation dictionaries containing `name`, 
  `address`, and `email-suffix`.
- `abstract`: The content of a brief summary of the paper or `none`. Appears at
  the top of the first column in boldface.
- `index-terms`: Array of index terms to display after the abstract. Shall be
  `content`.
- `paper-size`: Defaults to `us-letter`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
- `bibliography`: The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, IEEE-style citations.
- `draft`: can be either true or false and turns on or off markers for page 
  numbers and header/footer callouts for a draft.


The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `ieee`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/bamdone-ieeeconf:0.1.1": ieee

#show: ieee.with(
  title: [Preparation of Papers for IEEE Sponsored Conferences & Symposia],
  abstract: [
    This electronic document is a live template. The various components of your paper [title, text, heads, etc.] are already defined on the style sheet, as illustrated by the portions given in this document.
  ],
authors: (
    (
      given: "Albert",
      surname: "Author",
      email: [albert.author],
      affiliation: 1
    ),
    (
      given: "Bernard D.",
      surname: "Researcher",
      email: [b.d.researcher],
      affiliation: 2
    )
  ),
  affiliations: (
    (
      name: [Faculty of Electrical Engineering, Mathematics and Computer Science, University of Twente],
      address: [7500 AE Enchede, The Netherlands],
      email-suffix: [papercept.net],
    ),
    (
      name: [Department of Electrical Engineering, Wright State University],
      address: [Dayton, OH 45435, USA],
      email-suffix: [ieee.org]
    ),
  ),
  index-terms: (),
  bibliography: bibliography("refs.bib"),
  draft: false,               // Adds the draft markers on the footer and header
  paper-size: "us-letter",
)

// Your content goes below.
```

