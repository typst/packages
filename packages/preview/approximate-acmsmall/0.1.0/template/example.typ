#import "@preview/approximate-acmsmall:0.1.0": acmart

#show: acmart.with(
  format: "acmsmall",
  title: "An example paper",
  nonacm: false,
  anonymous: false,
  authors: (
    (
      name: "First Author",
      email: "first@example.com",
      orcid: "1234-5678-9012",
      affiliation: (
        institution: "First Affiliation", 
        streetaddress: "42 First Street",
        postcode: "1234",
        city: "City",
        state: "State",
        country: "Country",
      ),
    ),
    (
      name: "Second Author",
      email: "second@example.com",
      orcid: none,
      affiliation: (
        // This author has two affiliations.
        (institution: "Second Affiliation", country: "Country"),
        (institution: "Third Affiliation", country: "Country"),
      ),
    ),
    (
      // This is a group of two authors sharing the same affiliation.
      authors: (
        (
          name: "Third Author",
          email: none,
          orcid: none,
        ),
        (
          name: "Fourth Author",
          email: "fourth@example.com",
          orcid: none,
        ),
      ),
      affiliation: (institution: "Fourth Affiliation", country: "Country"),
    ),
  ),
  shortauthors: "First et al.",
  abstract: [
    #lorem(30)
  ],
  ccs: (
    ([Computer systems organization], (
        (500, [Embedded systems]),
        (300, [Redundancy]),
        (0,   [Robotics]))),
    ([Networks], (
        (100, [Network reliability]),))
  ),
  keywords: ("datasets", "neural networks", "gaze detection", "text tagging"),
  copyright: "acmlicensed",

  publication: (
   journal: "JACM",
   volume: 37,
   number: 4,
   article-number: 111,
   year: 2018,
   month: 8,
   doi: none,
  ),
)

= First level heading

#lorem(30)

== Second level heading

#lorem(30)

=== Third level heading

#lorem(30)

==== Fourth level heading
#lorem(30)
