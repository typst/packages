# unequivocal-ams
A single-column paper for the American Mathematical Society. The template comes
with functions for theorems and proofs. It also is a nice starting point for a
classy tech report or thesis.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `unequivocal-ams`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/unequivocal-ams
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ams-article` function with the following named arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `name` key and can have the keys `department`, `organization`,
  `location`, and `email`. All keys accept content.
- `abstract`: The content of a brief summary of the paper or `none`. Appears at
  the top of the first column in boldface.
- `paper-size`: Defaults to `us-letter`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
- `bibliography`: The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, Springer MathPhys-style citations.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `ams-article`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/unequivocal-ams:0.1.2": ams-article, theorem, proof

#show: ams-article.with(
  title: [Mathematical Theorems],
  authors: (
    (
      name: "Ralph Howard",
      department: [Department of Mathematics],
      organization: [University of South Carolina],
      location: [Columbia, SC 29208],
      email: "howard@math.sc.edu",
      url: "www.math.sc.edu/~howard"
    ),
  ),
  abstract: lorem(100),
  bibliography: bibliography("refs.bib"),
)

// Your content goes below.
```
