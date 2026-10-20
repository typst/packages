#import "@preview/magic-isprs:0.1.0": isprs, isprs-heading

#let anonymous = sys.inputs.at("anonymous", default: "false") == "true"

#show: isprs.with(
  title: [Simple Example of a Full Paper Submitted to ISPRS Events],
  abstract: include "content/abstract.typ",
  authors: (
    (
      name: "Lorem Ipsum",
      email: "lipsum@verytechnical.edu",
      institutions: ("vtu", "uon"),
    ),
    (
      name: "Dolor Sit Amet",
      email: "dolor.sit.amet@nowhere.edu",
      institutions: "uon",
    ),
    (
      name: "Consectetur Adipiscing",
      email: "consectetur.adipiscing@nowhere.edu",
      institutions: "uon",
    ),
  ),
  institutions: (
    vtu: (
      name: [Department of Geomatics, Very Technical University],
      location: [City, Country],
      email-suffix: "@verytechnical.edu",
    ),
    uon: (
      name: [Institute of Photogrammetry, University of Nowhere],
      location: [Somewhere, Country],
      email-suffix: "@nowhere.edu",
    ),
  ),
  keywords: (
    "Manuscripts",
    "ISPRS Archives",
    "ISPRS Annals",
    "Template",
    "Example",
  ),
  acknowledgements: include "content/acknowledgements.typ",
  bibliography: bibliography("biblio.yaml"),
  appendix: include "content/appendix.typ",
  anonymous: anonymous,
)


#include "content/introduction.typ"

#include "content/main_body.typ"

#include "content/conclusions.typ"
