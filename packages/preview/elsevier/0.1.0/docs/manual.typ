#import "@preview/mantys:1.0.2": *
#import "@preview/swank-tex:0.1.0": LaTeX
#import "@preview/cheq:0.2.2": *

#show: checklist.with(fill: eastern.lighten(95%), stroke: eastern, radius: .2em)

#let abstract = [
   The #package[Elsevier] template is designed to mimic the final appearance of Elsevier journals. It is not intended for submission, but rather to help authors prepare articles that resemble the final published version. It mainly serves as a proof of concept, demonstrating that Typst is a viable option for academic writing and scientific publishing.
]

#show: mantys(
  name: "elsevier.typ",
  version: "0.1.0",
  authors: (
    "Mathieu Aucejo",
    "James R Swift"
  ),
  license: "MIT",
  description: "Elsevier article template for Typst",
  repository: "https://github.com/maucejo/elsevier",

  title: "Elsevier Typst Template",
  date: datetime.today(),

  abstract: abstract,
  show-index: false,
)

= About

The #package[elsevier] package is designed to closely resemble the #LaTeX class used by Elsevier for article formatting, which is not publicly available. It is not intended for submission, but rather to help authors prepare articles that resemble the final published version. It mainly serves as a proof of concept, demonstrating that Typst is a viable option for academic writing and scientific publishing.

This template has been initiated by James R swift (#github-user("jamesrswift")) and finalized by Mathieu Aucejo (#github-user("maucejo")). However, it is still in development and may not be fully compatible with all Elsevier journals.

This manual provides an overview of the features of the #package[elsevier] template and how to use it.

#warning-alert[The template is provided as is by the Typst community and is not affiliated with Elsevier.]

= Usage

== Using Elsevier

To use the #package[Elsevier] template, you need to include the following line at the beginning of your `typ` file:
#codesnippet[```typ
#import "@preview/elsevier:0.1.0": *
```
]

== Initializing the template

After importing #package[Elsevier], you have to initialize the template by a show rule with the #cmd[elsevier] command. This function takes an optional argument to specify the title of the document.
#codesnippet[```typ
#show: elsevier.with(
  ...
)
```
]

#cmd[elsevier] takes the following arguments:
#command("elsevier", ..args(
  paper-type: [Article],
  journal: "mssp",
  title: [],
  abstract: [],
  authors: (),
  institutions: (),
  paper-info: "paper-info-default",
  keywords: (),
  [body])
)[

#argument("paper-type", default: [Article], types: (str, content))[
  Type of the paper.
]

#argument("journal", default: "mssp", types: dictionary)[
  Dictionary containing the journal information. The following journals are available by default:
    - `aam`: Advances in Applied Mathematics
    - `agee`: Agriculture, Ecosystems and Environment
    - `apacoust`: Applied Acoustics
    - `cas`: Computers and Structures
    - `jsv`: Journal of Sound and Vibration
    - `mssp`: Mechanical Systems and Signal Processing
    - `newast`: New Astronomy
    - `structures`: Structures

  You can also create your own journal dictionary by defining a dictionary with the following keys:
  - `name`: Name of the journal
  - `address`: URL of the journal
  - `logo`: Logo of the journal (image)
  - `numcol`: Number of columns in the journal (1 or 2)
  - `foot-info`: Footer information (text)

  #codesnippet[
    ```typ
      // Example of a custom journal dictionary
      #let mssp = (
        name: "Mechanical Systems and Signal Processing",
        address: "www.elsevier.com/locate/ymssp",
        logo: image("path-to-logo/mssp.jpg"),
        numcol: 1,
        foot-info: [Elsevier Ltd. All rights reserved, including those for text and data mining, AI training, and similar technologies.]
      )
    ```
  ]

  #warning-alert[The name of the journal must be given without the quote marks, since it is the name of a dictionary.]
]

#argument("title", default: [], types: (str, content))[
  Title of the article. If not provided, the title will be empty.
]

#argument("abstract", default: [], types: (str, content))[
  Abstract of the article. If not provided, the abstract will be empty.
]

#argument("authors", default: (), types: array)[
  Array containing the list of authors of the article. Each author is defined as a dictionary with the following keys:
  - `name`: Name of the author (required) #dtypes(str, content)
  - `institutions`: List of institutions of the author (required) #dtype(array)
  - `corresponding`: Corresponding author (optional, default: false) #dtype(bool)
  - `orcid`: ORCID of the author (optional) #dtypes(str, content)
  - `email`: Email of the corresponding author (optional) #dtypes(str, content)

  #codesnippet[
    ```typc
    authors: (
      (name: [S. Pythagoras], institutions: ("a",), corresponding: true, orcid: "0000-0001-2345-6789", email:"s.pythagoras@croton.edu"),
      (name: [M. Thales], institutions: ("b", ))
    )
    ```
  ]
]

#argument("institutions", default: (), types: dictionary)[
  Dictionary containing the list of institutions of the article. Each institution is defined as a key-value pair, where the key is a #dtype(str) representing the institution ID and the value is a #dtypes(str, content) giving the name and the address of the institution.

  #codesnippet[
    ```typc
    institutions: (
      "a": [School of Pythagoreans, Croton, Magna Graecia],
      "b": [Milesian School of Natural Philosophy, Miletus, Ionia]
    )
    ```
  ]

  #info-alert[If the paper has only one author, `institutions`must be:
    - `("",)` in the `authors` #dtype(array) of #dtype(dictionary)
    - `("": [Institution name])` in the `institutions` #dtype(dictionary)
    to conform to the Elsevier template requirements.
  ]
]

#argument("paper-info", default: "paper-info-default", types: dictionary)[
  Dictionary containing the paper information. The following keys are available:
  - `year`: Year of publication #dtypes(str, content)
  - `paper-id`: ID of the paper #dtypes(str, content)
  - `volume`: Volume of the journal #dtypes(str, content)
  - `issn`: ISSN of the journal #dtypes(str, content)
  - `received`: Date of receipt #dtypes(str, content)
  - `revised`: Date of revision #dtypes(str, content)
  - `accepted`: Date of acceptance #dtypes(str, content)
  - `online`: Date of online publication #dtypes(str, content)
  - `doi`: DOI of the paper #dtypes(str, content)
  - `open`: Open access license #dtype(dictionary)
    - `name`: Name of the license (e.g. `"CC BY"`) #dtypes(str, content)
    - `url`: URL of the license #dtypes(str, content)
  - `extra-info`: Extra information about the paper #dtypes(str, content)

  #codesnippet[
    ```typc
    paper-info: (
      year: [510 BCE],
      paper-id: [123456],
      volume: [1],
      issn: [1234-5678],
      received: [01 June 510 BCE],
      revised: [01 July 510 BCE],
      accepted: [01 August 510 BCE],
      online: [01 September 510 BCE],
      doi: "https://doi.org/10.1016/j.aam.510bce.101010",
      open: cc-by,
      extra-info: [Communicated by C. Eratosthenes]
    )
    ```
  ]

  #warning-alert[The name of the journal must be given without the quote marks, since it is the name of a dictionary.]
]

#argument("keywords", default: (), types: array)[
  Array containing the keywords of the article. If not provided, the keywords will be empty.
  #codesnippet[
    ```typc
    keywords: (
      "Elsevier",
      "Typst",
      "Template"
    )
    ```
  ]
]
]

#pagebreak()
== Additional features

The #package[elsevier] template provides additional features to help you format your document properly.

=== Appendix

The template allows you to create appendices using the #cmd[appendix] environment. The appendices are then numbered with capital letters (A, B, C, etc.). Figures, tables and equations are numbered accordingly, e.g. Eq. (A.1).

To activate the appendix environment, all you have to do is to place the following command in your document:
#codesnippet[
  ```typ
  #show: appendix

  // Appendix content here
  ```
]

=== Subfigures

Subfigures are not built-in features of Typst, but the #package[elsevier] template provides a way to handle them. It is based on the #package[subpar] package that allows you to create subfigures and properly reference them.

To create a subfigure, you can use the following syntax:

#codesnippet[
  ```typc
  #subfigure(
    figure(image("image1.png"), caption: []), <figa>,
    figure(image("image2.png"), caption: []), <figb>,
    columns: (1fr, 1fr),
    caption: [(a) Left image and (b) Right image],
    label: <fig>
  )
  ```
]

#info-alert[The #cmd("subfigure") function is a wrapper around the #cmd[subpar.grid] function. The numbering is adapted to the context of the document (normal section or appendix).]

= Roadmap

The #package[elsevier] template is still in development and may not be fully compatible with all Elsevier journals. The following features are planned for future releases:
#v(1em)

- [ ] Add more journals dictionaries
#info-alert[If you want to add a journal dictionary, feel free to submit a pull request on the Github repository of the template, (#link-repo("maucejo/elsevier")).]

- [ ] Add more journal-specific styles to the template

