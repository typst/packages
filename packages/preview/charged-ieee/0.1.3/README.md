# charged-ieee
This is a Typst template for a two-column paper from the proceedings of the
Institute of Electrical and Electronics Engineers. The paper is tightly spaced,
fits a lot of content and comes preconfigured for numeric citations from
BibLaTeX or Hayagriva files.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `charged-ieee`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/charged-ieee
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ieee` function with the following named arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `name` key and can have the keys `department`, `organization`,
  `location`, and `email`. All keys accept content.
- `abstract`: The content of a brief summary of the paper or `none`. Appears at
  the top of the first column in boldface.
- `index-terms`: Array of index terms to display after the abstract. Shall be
  `content`.
- `paper-size`: Defaults to `us-letter`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
- `bibliography`: The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, IEEE-style citations.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `ieee`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/charged-ieee:0.1.3": ieee

#show: ieee.with(
  title: [A typesetting system to untangle the scientific writing process],
  abstract: [
    The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing. Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.
  ],
  authors: (
    (
      name: "Martin Haug",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "haug@typst.app"
    ),
    (
      name: "Laurenz Mädje",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "maedje@typst.app"
    ),
  ),
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
  bibliography: bibliography("refs.bib"),
)

// Your content goes below.
```
