# ambivalent-amcis

The (unofficial) AMCIS conference submission template for Typst.

AMCIS stands for the [Americas Conference for Information Systems](https://amcis2026.aisconferences.org/)

## Usage

You can use this template with the Typst web app by clicking "Start from template" on the dashboard and searching for `ambivalent-amcis`.

For local usage, you can use the typst CLI by invoking the following command:

```
typst init @preview/ambivalent-amcis
```

## Fonts
Typst does not allow the embedding of fonts within a template. The AMCIS template requires the use of the Georgia font, which can be downloaded from [font.download](https://font.download/font/georgia-2) for free. Once you have downloaded it, create a folder inside your project called `fonts` and upload the 4 font files (including the bold and bold-italic versions).

## Configuration
The preamble or header of your document should be written in the following way, with your own input variables. Importantly, you can set `camera-ready` to false for the initial submission, which hides the authors, abstract, keywords, and acknowledgements sections. Setting `camera-ready` to true will put each of those in the right place.

```
#import "@preview/ambivalent-amcis:0.1.1": *

#let authors_list = (
  // Authors as ([Author Name], [Affiliation], "email@address.com"),
  ([Ryan Schuetzler], [Brigham Young University], "ryan.schuetzler@byu.edu"),
  ([Alice T. Academic], [Other University], "alice@other.edu"),
  ([Bob B. Bobberson], [Independent Researcher], "bob@example.org")
)

#show: amcis.with(
  title: [Paper Submission Title],
  short-title: [Short title (up to 8 words)], // hidden for initial submission
  paper-type: "Full Paper", // "Full Paper" or "Emergent Research Forum (ERF) Paper"
  abstract: [The abstract should not be included in the initial submission. Set `camera-ready` to `false` until final submission. Abstract should be 150 words or less.], // Hidden for initial submission
  keywords: ([guides], [instructions], [length], [conference publications]),
  acknowledgements: [Please do #underline[_not_] add acknowledgements to your original submission because it may identify authors. Add any acknowledgements to the revised, camera-ready version of your paper.
  ], // hidden for initial submission
  authors: authors_list,
  bib: bibliography("./references.bib", style: "new-apa.csl", title: none),
  camera-ready: false, // true for camera-ready, false for initial submission
)


= Introduction
Begin your paper here.
```
