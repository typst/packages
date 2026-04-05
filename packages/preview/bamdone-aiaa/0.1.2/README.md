# bamdone-aiaa
This is a Typst template for a one-column paper from the proceedings of the American Institute of Aeronautics and Astronautics. The paper is tightly spaced, fits a lot of content and comes preconfigured for numeric citations from
BibLaTeX or Hayagriva files.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `bamdone-aiaa`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/bamdone-aiaa
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `aiaa` function with the following named arguments:

- `title`: The paper's title as content.
- `authors-and-affiliations`: An array of author dictionaries and affiliation dictionaries. 
  Author dictionaries must have a `name` key and can have the keys `job`, `department`, `aiaa` is optional. Affiliation dictionaries must have the keys `institution`,`city`,`state`,`zip`, and `country`.
- `abstract`: The content of a brief summary of the paper or `none`. Appears at the top of the first column in boldface. Shall be `content`.
- `paper-size`: Defaults to `us-letter`. Specify a [paper size string](https://typst.app/docs/reference/layout/page/#parameters-paper) to change the page format.
- `bibliography`: The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, AIAA-style citations.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `aiaa`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/bamdone-aiaa:0.1.2": aiaa

#show: aiaa.with(
  title: [A typesetting system to untangle the scientific writing process],
  abstract: [
    These instructions give you guidelines for preparing papers for AIAA Technical Papers. Use this document as a template if you are using Typst. Otherwise, use this document as an instruction set. Define all symbols used in the abstract. Do not cite references in the abstract. The footnote on the first page should list the Job Title and AIAA Member Grade for each author, if known. Authors do not have to be AIAA members.
  ],
  authors: (
      (
        name:"First A. Author",
        job:"Insert Job Title",
        department:"Department Name",
        aiaa:"and AIAA Member Grade (if any) for first author"
      ),
      (
        institution:"Business or Academic Affiliation's Full Name 1",
        city:"City",
        state:"State",
        zip:"Zip Code",
        country:"Country"
      ),
  ),
  bibliography: bibliography("refs.bib"),
)

// Your content goes below.
```