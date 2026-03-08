# bamdone-rebuttal
This is a Typst template for a rebuttal/response letter.
It allows authors to respond to feedback given by reviewers in a peer-review process on a point-by-point basis.
This template is based heavily on the LaTeX template from Zenke Lab (see [here](https://zenkelab.org/resources/latex-rebuttal-response-to-reviewers-template/)).

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `bamdone-rebuttal`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/bamdone-rebuttal
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `rebuttal` function with the following named arguments:

- `title`: (content), something like "Response Letter" (the default) or "Rebuttal".
- `authors`: (content), list of author names
  the top of the first column in boldface.
- `date`: (content), defaults to `datetime.today().display()`
- `paper-size`: Defaults to `us-letter`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
  Specifying this will configure numeric, IEEE-style citations.

The function also accepts a single, positional argument for the body of the
letter.

In addition, the template exports the `configure` function which accepts the following named arguments corresponding to the text color of various pieces of the letter:

- `point-color`: defaults to `blue.darken(30%)`, the text color for reviewers' points
- `response-color`: defaults to `black`, the text color for the authors' responses
- `new-color`: defaults to `green.darken(30%)`, the text color for changes/additions to the manuscript (i.e., within a `quote` block to show what's changed from the initial submission)

The template will initialize your package with a sample call to the `rebuttal`
function in a show rule. 

```typ
// Optional color configuration
#let (point, response, new) = configure(
  point-color: blue.darken(30%),
  response-color: black,
  new-color: green.darken(30%)
)

// Setup the rebuttal
#show: rebuttal.with(
  authors: [First A. Author and Second B. Author],
  // date: ,
  // paper-size: ,
)

// Your content goes below
We thank the reviewers...
```
