#import "@preview/unofficial-lnu-thesis:0.1.0": essay, appendix-section

#show: essay.with(
  // Title & Subtitle
  title: [Title],
  subtitle: [Subtitle],

  // Cover metadata
  doc-type: [Document type],
  author: [Author Name],
  supervisor: [Supervisor Name],
  examiner: [Examiner Name],
  university: [Linnaeus University],
  term: [xx00],
  subject: [Subject Name],
  level: [xxxx],

  // Front matter
  abstract: [
    Write your abstract here
  ],
  keywords: [
    Write your keywords here
  ],
  acknowledgments: [
    Write your acknowledgments here
  ],

  // Table of Contents
  toc: true,

  // Appendices
  appendices: [
    = Appendix 1
    Note that the appendices have separate pagination and that they have to be listed manually in the table of contents.
  ],
)

// ==========================================
// Main Document Content
// ==========================================

= Introduction
Type your introduction here.

You can cite references using the `@` symbol followed by the citation key from your `.bib` file, for example:
- Standard citation: @shannon1948
- Multiple citations: [@shannon1948; @knuth1984]
- Citation with page numbers: @knuth1984[p. 15]

// ==========================================
// References
// ==========================================
#bibliography("refs.bib", title: "References", style: "apa")
