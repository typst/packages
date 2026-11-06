# aloecius-aip

This is a typst template for reproducing papers of American Institute of Physics (AIP) publishing house, mainly draft version of Journal of Chemical Physics. This is inspired by the overleaf $\LaTeX$ template of AIP journals.

## Usage

You can use this template with typst web app by simply clicking on "Start from template" on the dashboard and searching for `aloecius-aip`.

For local usage, you can use the typst CLI by invoking the following command

```
typst init @preview/aloecius-aip
```

typst will automatically create a new directory with all the necessary files needed to compile the project.

## Configuration

The preamble or the header of the document should be written in the following way with your own necessary input variables to recreate the same formatting as seen in the [`sample.pdf`](sample.pdf)
```
#import "@preview/aloecius-aip:0.0.1": *

#show: article.with(
  title: "Typst Template for Journal of Chemical Physics (Draft)",
  authors: (
    "Author 1": author-meta(
      "GU",
      email: "user1@domain.com",
    ),
    "Author 2": author-meta(
      "GU",
      cofirst: false
    ),
    "Author 3": author-meta(
      "UG"
    )
  ),
  affiliations: (
    "UG": "University of Global Sciences",
    "GU": "Institute for Chemistry, Global University of Sciences"
  ),
  abstract: [
  Here goes the abstract. 
  ],
  bib: bibliography("./reference.bib")
)
```

## Important Variables

- `title` : Title of the paper
- `authors` : A dictionary connecting the key as name of the author(s) and the value to be the affiliation of them including university, email, mail address, authorship and an alias, an example usage is shown below

```
Example:
(
  "Author Name": (
    "affiliation": "affiliation-label",
    "email": "author.name@example.com", // Optional
    "address": "Mail address",  // Optional
    "name": "Alias Name", // Optional
    "cofirst": false // Optional, identify whether this author is the co-first author
    )
)
```
- `affiliations` : Dictionary of affiliations where keys are affiliations labels and values are affiliations addresses, and example usage is as follows

```
Example:
 (
    "affiliation-label": "Institution Name, University Name, Road, Post Code, Country"
 )
```

- `abstract` : Abstract of the paper
- `bib` : passing the bibliography file wrapped into the typst `bibliography()` function, both `Hayagriva` and `.bib` format is supported. 