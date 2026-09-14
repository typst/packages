#import "@preview/bye-ubc:0.2.2": thesis

#show: thesis.with(
  // Avoid using scientific symbols or Greek letters; spell out the words.
  title: [
    Advanced Studies on the Optimization of Thesis Title Generation Algorithms
    for Maximum Perceived Depth and Minimum Reviewer Scrutiny
  ],
  // Should be the name under which you are registered at UBC.
  author: "Daniel Duque",
  // Optional to list these. If listed, must have a degree (abbreviated, e.g.
  // MSc, BSc), institution and graduation year.
  previous-degrees: (
    /*
    (
      abbr: "MPhys",
      institution: "University of Manchester",
      year: "2020",
    ),
    (
      abbr: "BSc",
      institution: "Another University",
      year: "2017",
    ),
    */
  ),
  // Spell out degree in full e.g. Doctor of Philosophy, Master of Science,
  // Master of Arts.
  degree: "Doctor of Philosophy",
  // The specific graduate program in which you are registered. Check
  // SSC/Workday to confirm your program name.
  program: "Physics",
  // Vancouver or Okanagan.
  campus: "Vancouver",
  // The month and year in which your thesis is accepted.
  month: "October",
  year: "2026",
  // Include all committee members. For supervisory committee members who were
  // not part of the examining committee, include them below under
  // `additional-committee`.
  // Adding the external examiner is optional. Ask them whether or not they wish
  // to be listed in the committee page.
  examining-committee: (
    (
      name: "John Doe",
      title: "Research Scientist",
      department: "Physical Sciences Division",
      institution: "TRIUMF",
      role: "Research Co-supervisor",
    ),
    (
      name: "Jane Doe",
      title: "Professor",
      department: "Department of Chemistry",
      institution: "UBC",
      role: "Academic Co-supervisor",
    ),
  ),
  additional-committee: (),
  // Feel free to do these in whatever way works better for you. You can even
  // write these sections directly in [...] content blocks here instead (like
  // the title above).
  abstract: include "./preliminary_pages/abstract.typ",
  lay-summary: include "./preliminary_pages/lay_summary.typ",
  preface: include "./preliminary_pages/preface.typ",
  // These are optional. You can:
  // - Delete these lines if you want to omit them.
  // - Write them by hand either here in a content block or in a separate file.
  // - Use e.g. the `glossarium` or similar packages to handle these for you and
  //   include the generating functions here.
  list-of-symbols: none,
  glossary: none,
  acknowledgments: include "./preliminary_pages/acknowledgments.typ",
  dedication: none,
  bibliography: bibliography("refs.bib"),
  // Also optional. If you don't have any appendices, you can delete this.
  // Same as all other sections, you can just include the content here from a
  // separate file.
  appendices: [
    = First
    #lorem(100)

    = Second
    #lorem(100)
  ],
)

= Introduction
This is the actual body of your thesis. You can write it here, but it is
recommended to write each chapter in a separate file and include them using the
`include "./path/to/chapter.typ"` keyword.

Like @lorem2025 said: #lorem(15)
