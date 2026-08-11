// This template is licensed under the MIT-0 License. You can freely use and modify this template without any restrictions.
#import "@preview/stellar-iac:0.5.0": project

#show: project.with(
  paper-code: "IAC-25-A1.2.3",
  title: "Title of the paper",
  authors: (
    (
      name: "John A. Doe",
      email: "john.doe@example.edu",
      affiliation: "Northbridge University",
      corresponding: true,
    ),
    (name: "Jane B. Smith", email: "jane.smith@example.org", affiliation: "Western Institute of Technology"),
  ),
  organizations: (
    (
      name: "Northbridge University",
      display: "Department of Computer Science, Northbridge University, 123 Academic Road, Springfield, USA 12345",
    ),
    (
      name: "Western Institute of Technology",
      display: "Department of Mechanical Engineering, Western Institute of Technology, 456 Research Avenue, Metropolis, USA 67890",
    ),
  ),
  keywords: (
    "Keyword 1",
    "Keyword 2",
    "Keyword 3",
  ),
  header: [#lorem(20)],
  abstract: [#lorem(200)],
)

#heading(numbering: none)[Nomenclature]
#lorem(40)

#heading(numbering: none)[Acronyms/Abbreviations]
#lorem(40)

= Introduction
#lorem(40)

== Subsection headings
#lorem(40)

=== Sub-subsection headings
#lorem(40)

$
  arrow(F)_g = - G (m times m_E) / R_E^2 arrow(i)_r = m arrow(g)_(t a)
$

== Figure

You can reference figures like this @fig:randomized-sine-cosine.

#figure(
  image("img/randomized-sine-cosine.png"),
  caption: [Randomized variations of sine and cosine waveforms over time. The blue curve represents a sine wave with random noise added, while the green curve represents a similarly modified cosine wave.],
) <fig:randomized-sine-cosine>

== Table

You can reference tables like this @table:sample-data.

#figure(
  table(
    columns: 5,
    table.header(
      [],
      [$alpha$],
      [$beta$],
      [$gamma$],
      [$delta$],
    ),

    [Parameter A], [3.21], [1.57], [0.89], [4.76],
    [Parameter B], [0.123], [0.456], [0.789], [0.234],
  ),
  caption: [Sample data of various parameters for $alpha$, $beta$, $gamma$, and $delta$],
) <table:sample-data>

= Cite the references

Indicate references like this @doe2023techniques. Or like this @doe2023techniques @johnson2019renewable.

= Results
#lorem(40)

= Discussion
#lorem(40)

= Conclusion
#lorem(20)

#heading(numbering: none)[Acknowledgements]
#lorem(20)

#heading(numbering: none)[Appendix A. Title of appendix]
#lorem(20)

#heading(numbering: none)[Appendix B. Title of appendix]

#bibliography("references.bib", title: "References", style: "american-institute-of-aeronautics-and-astronautics")
