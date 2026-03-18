#import "@preview/superb-pci:0.1.0": *

#show: pci.with(
  title: [Sample for the template, with quite a very long title],
  abstract: [#lorem(200)],
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
      affiliations: "3"
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
  bibliography: bibliography("refs.bib"),
  pcj: false,
)

= Example of a section, e.g. Introduction
#lorem(100)

= Example of a section, e.g. Material and methods
#lorem(100)

== First subsection
#lorem(100)

== Second subsection
#lorem(200)

== Third subsection
#lorem(100)

= Example of a section, e.g. Results
#lorem(100)

// how to rotate content
#pagebreak()
#rotate(-90deg, reflow: true)[
  = Landscape section
  #lorem(100)

  #lorem(50)

  #lorem(50)
]
#pagebreak()


= Example of a section, e.g. Discussion
#lorem(100)

- toto (see Appendix~sA and @eq:eq1)
- foo (see @fig:fig1)
- bar

== An other subsection
#lorem(100)

+ first item
+ second item
  + 2a<2a> item #link(<2a>)[2a]
  + item 2b (cf.~#cite(<Ivanov_curve-complex_1997>, form: "prose", supplement: [Thm.~3])

=== A subsubsection
#lorem(100)

This is an equation:

$
  1 = 1
$ <eq:eq1>

A paragraph. #lorem(100)

$
  exp(x) = 1 + x + frac(x^2, 2!) + frac(x^3, 3!) + frac(x^4, 4!) + frac(x^5, 5!) + frac(x^6, 6!) + frac(x^7, 7!) +frac(x^8, 8!) +frac(x^9, 9!) \
  + frac(x^10, 10!) + frac(x^11, 11!)+ frac(x^12, 12!) + frac(x^13, 13!) + frac(x^14, 14!) + frac(x^15, 15!) + frac(x^16, 16!) + o(n^16)
$

#figure(
  image("pci-graph-small.png", width: 50%),
  caption: [
    This is the title of the figure. It also contains the legend of the figure, with some math to check everything is working: $log(frac(1, 2))$. The caption is different from the caption of the table (see @tab:tab1).
  ]
) <fig:fig1>

#lorem(100)


#figure(
  [
    #set table.hline(stroke: .6pt)
    #table(
      columns: 5,
      table.hline(),
      table.header(
        [$n$], [1], [2], [3], [4],
      ),
      table.hline(),
      [$n^2$], [1], [4], [9], [16],
      [$n^3$], [1], [4], [9], [18],
      table.hline(),
    )
    #table_note[This is the note of the table if required. It is below the table to look nice. This can be done by using the template function `table_note` in the same block as the table. Compare with the figure caption above (see @fig:fig1).]
  ],
  caption: [
    This is the title of the table. It also contains the legend i.e. an explanation of what the table reveals about the problem at hand (typeset using the `caption` argument of figure()).
  ],
) <tab:tab1>


// Manually do proof at the moment
_Proof._ This is a proof that ends with a \verb+{align}+ type of equation. The last equation should be numbered, but \verb+\qedhere+ breaks it (yet it works in most other journals?)
$
  x &= 1234596748613548534863 \
  3x + y &= "some text" \
  &1234864 + sum_(i=1)^(n) frac(1, i)
$ #math.qed


= Example of a section, e.g. Conclusion
#lorem(200)

// Appendix sections
#appendix()[
= Some other things
<sA>
// \appendix
// \section{Some other things}\label{sA}
If your appendices fit in less than 2 pages, add your appendices here.

If your appendices take more than 2 pages, please proceed as follows:
- deposit them in an open repository such as Zenodo
- add the DOI and the citation in the section “Data, scripts, code, and supplementary information availability”
- add the reference in the list of references

== Example of appendix subsection
#lorem(50)

] // end appendix

// post-sections, make sure to remove numbering
#set heading(numbering: none)
= Acknowledgements

This is your acknowledgments. Preprint version xxx[change to the correct number] of this article has been peer-reviewed and recommended by Peer Community In XYZ[change to the name of the PCI] (#link("https://doi.org/10.24072/pci.xxx")[https://doi.org/10.24072/pci.xxx] [replace by the doi of the recommendation]; #cite(<fake>, form: "prose") [replace by the citation of the recommendation]).

= Fundings

Declare your fundings. If your study has not been supported by particular
funding, please indicate "The authors declare that they have received no
specific funding for this study".

= Conflict of interest disclosure

The authors declare that they comply with the PCI rule of having no financial conflicts of interest in relation to the content of the article. [IF APPROPRIATE: The authors declare the following non-financial conflict of interest: XXX (if some of the authors are recommenders of a PCI, indicate it here)].

= Data, script, code, and supplementary information availability

Data are available online (#link("https://doi.org/10.24072/fake1")[https://doi.org/10.24072/fake1] [Replace by the DOI of the webpage hosting the data]; #cite(<CharleMar_independant-trace-su2_2012>, form: "prose") [Replace by the citation of the data])

Script and codes are available online (#link("https://doi.org/10.24072/fake2")[https://doi.org/10.24072/fake2] [Replace by the DOI of the webpage hosting the script and code]; #cite(<CharleMar_independant-trace-su2_2012>, form: "prose") [Replace by the citation of the script and code])

Supplementary information is available online (#link("https://doi.org/10.24072/fake3")[https://doi.org/10.24072/fake3] [Replace by the DOI of the webpage hosting the Supplementary information]; #cite(<CharleMar_independant-trace-su2_2012>, form: "prose") [Replace by the citation of the Supplementary information])

#v(1em)
The DOI hyperlinks should be active. They should also be present in the reference list and cited in the text.

For the reference section below, do not forget to add a doi for each reference (if available). Do not forget to add the reference of the recommendation, the reference of the data, scripts, code and supplementary material to your bib file, if appropriate.

