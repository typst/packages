#import "@preview/reprobe:0.1.0": tech-report

#show: tech-report.with(
  // Renders as "My Report: A Technical Report" — the suffix is added by the template.
  title: "My Report",
  subtitle: "My Subtitle",
  authors: (
    (name: "My Name Lastname", email: "email@org.edu", affiliation: 1),
  ),
  affiliations: (
    "Department, Faculty, University",
  ),
  // logo: none,   // drop the seal; omit this line to keep it
  keywords: ("bioinformatics", "GPU", "sequence alignment"),

  abstract: [
    Write this last. One paragraph: what problem you attacked, how you attacked
    it, what you measured, and what the numbers mean. Give the headline result
    as a number rather than an adjective — "13.8× faster than the baseline"
    tells a reader more than "substantially faster."
  ],

  introduction: [
    Motivate the problem and state the contribution. Cite prior work like
    this @knuth1984.

    A workable shape for this section: what problem exists, why the existing
    answers fall short, what you did instead, and what the reader will find in
    the rest of the report. Keep it to a few paragraphs — the details belong in
    Methods.

    == Background

    Subsections are the only headings you write — `==` for a subsection,
    `===` for a sub-subsection. The section headings themselves come from the
    template.

    == Contributions

    A bulleted list is a fair way to make the contributions skimmable:

    - An implementation of the method described in the Methods section.
    - An evaluation on a public dataset, reported in @tab:runtime.
    - A discussion of where the approach stops working.
  ],

  methods: [
    Describe the approach so that somebody else can reproduce it: data,
    hardware, software versions, parameters. If a reader cannot rerun your work
    from this section alone, it is not finished yet.

    == Implementation

    Code listings are written with triple backticks and a language name:

    ```python
    def align(query, ref, gap=-2):
        return smith_waterman(query, ref, gap)
    ```

    == Scoring

    Display equations are numbered automatically, and you can refer back to
    them like @eq-score:

    $ S(i, j) = max cases(
      S(i - 1, j - 1) + sigma(a_i, b_j),
      S(i - 1, j) + g,
      S(i, j - 1) + g,
      0,
    ) $ <eq-score>

    where $sigma$ is the substitution score and $g$ the gap penalty. Inline
    math like $O(n m)$ goes between single dollar signs.

    == Setup

    State the hardware and software exactly: CPU and GPU models, memory,
    compiler and library versions, dataset release, and every parameter you did
    not leave at its default.
  ],

  results: [
    Report what happened. Tables and figures go here.

    #figure(
      table(
        columns: 3,
        table.header([*Method*], [*Runtime (s)*], [*Speedup*]),
        [Baseline], [120.4], [1.0×],
        [Ours], [8.7], [13.8×],
      ),
      caption: [Runtime on the test dataset.],
    ) <tab:runtime>

    Refer to floats by label — @tab:runtime — rather than by position, since
    the layout may move them. Report the measurement conditions along with the
    numbers: how many runs, and what the spread across them was.

    Save the interpretation for the Conclusions. This section is for what the
    instruments said, including the runs that did not go your way.
  ],

  conclusions: [
    What the results support — and what they do not. Tie each claim back to a
    specific number above, and name the threats to validity plainly: dataset
    size, hardware specificity, parameters you did not sweep.
  ],

  future-work: [
    The next experiments, in the order you would run them, with a sentence each
    on what outcome would be informative.
  ],

  acknowledgments: [
    This work was supported by the MegaProbe Lab.
  ],

  bibliography: bibliography("refs.bib"),
)

// Anything after the show rule lands at the end of the document.
// Use it for appendices:
//
// = Appendix: Additional Measurements
