# superb-pci

Template for [Peer Community In](https://peercommunityin.org/) (PCI) submission and [Peer Community Journal](https://peercommunityjournal.org/) (PCJ) post-recommendation upload.

The template is as close as possible to the LaTeX one.

## Usage

To use this template in Typst, simply import it at the top of your document.
```
#import "@preview/superb-pci:0.1.0": *
```

Alternatively, you can start using this template from the command line with 
```
typst init @preview/superb-pci:0.1.0 my-superb-manuscript-dir
```
or directly in the web app by clicking "Start from template".

Please see the main Readme about Typst packages [https://github.com/typst/packages](https://github.com/typst/packages).

## Configuration

This template exports the `pci` function with the following named arguments:

- `title`: the paper title
- `authors`: array of author dictionaries. Each author must have the `name` field, and can have the optional fields `orcid`, and `affiliations`.
- `affiliations`: array of affiliation dictionaries, each with the keys `id` and `name`. All correspondence between authors and affiliations is done manually.
- `abstract`: abstract of the paper as content
- `doi`: DOI of the paper displayed on the front page
- `keywords`: array of keywords displayed on the front page
- `correspondence`: corresponding address displayed on the front page
- `numbered_sections`: boolean, whether sections should be numbered
- `pcj`: boolean, provides a way to remove the front page and headers/footers for upload to the Peer Community Journal. `[default: false]`

The template will initialize your folder with a sample call to the `pci` function in a show rule and dummy content as an example.
If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/superb-pci:0.1.0": *

#show: pci.with(
  title: [Sample for the template, with quite a very long title],
  abstract: lorem(200),
  authors: (
    (
      name: "Antoine Lavoisier",
      orcid: "0000-0000-0000-0001",
      affiliations: "#,1"
    ),
    (
      name: "Mary P. Curry",
      orcid: "0000-0000-0000-0001",
      affiliations: "#,2",
    ),
    (
      name: "Peter Curry",
      affiliations: "2",
    ),
    (
      name: "Dick Darlington",
      orcid: "0000-0000-0000-0001",
      affiliations: "1,3"
    ),
  ),
  affiliations: (
   (id: "1", name: "Rue sans aplomb, Paris, France"),
   (id: "2", name: "Center for spiced radium experiments, United Kingdom"),
   (id: "3", name: "Bruce's Bar and Grill, London (near Susan's)"),
   (id: "#", name: "Equal contributions"),
  ),
  doi: "https://doi.org/10.5802/fake.doi",
  keywords: ("Scientific writing", "Typst", "PCI", "Example"),
  correspondence: "a-lavois@lead-free-univ.edu",
  numbered_sections: false,
  pcj: false,
)

// Your content goes here
```

You might also need to use the `table_note` function from the template.

## To do

Some things that are not straightforward in Typst yet that need to be added in the futures:

- [ ] line numbers
- [ ] switch equation numbers to the left
