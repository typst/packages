#import "@preview/stellar-springer-nature:0.1.0": article, bmhead

#show: article.with(
  title: [Article Title],
  short-title: [Article Title],
  authors: (
    (name: "First Author", affiliations: (1, 2), corresponding: true, email: "iauthor@gmail.com"),
    (name: "Second Author", affiliations: (2, 3), equal-contrib: "These authors contributed equally to this work."),
    (name: "Third Author", affiliations: (1, 2)),
  ),
  affiliations: (
    (id: 1, department: "Department", institution: "Organization", address: "Street, City 100190, State, Country"),
    (id: 2, department: "Department", institution: "Organization", address: "Street, City 10587, State, Country"),
    (id: 3, department: "Department", institution: "Organization", address: "Street, City 610101, State, Country"),
  ),
  abstract: [The abstract serves both as a general introduction to the topic and as a brief, non-technical summary of the main results and their implications. Authors are advised to check the author instructions for the journal they are submitting to for word limits and if structural elements like subheadings, citations, or equations are permitted.],
  keywords: ("keyword1", "Keyword2", "Keyword3", "Keyword4"),
)

= Introduction <sec1>

The Introduction section, of referenced text #cite(<bib1>) expands on the background of the work (some overlap with the Abstract is acceptable). The introduction should not include subheadings.

Springer Nature does not impose a strict layout as standard however authors are advised to check the individual requirements for the journal they are planning to submit to as there may be journal-level preferences. When preparing your text please also be aware that some stylistic choices are not supported in full text XML (publication version), including coloured font. These will not be replicated in the typeset article if it is accepted.

= Results <sec2>

Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text.

= This is an example for first level head---section head <sec3>

== This is an example for second level head---subsection head <subsec2>

=== This is an example for third level head---subsubsection head <subsubsec2>

Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text. Sample body text.

= Equations <sec4>

Equations in Typst can either be inline or display equations. For inline equations use the `$...$` syntax. E.g.: The equation $H psi = E psi$ is written via `$H psi = E psi$`.

For display equations (with auto generated equation numbers):

$ norm(tilde(X)(k))^2 <= (sum_(i=1)^p norm(tilde(Y)_i (k))^2 + sum_(j=1)^q norm(tilde(Z)_j (k))^2) / (p + q) $ <eq1>

where,

$ D_mu &= partial_mu - i g (lambda^a) / 2 A^a_mu \
  F^a_(mu nu) &= partial_mu A^a_nu - partial_nu A^a_mu + g f^(a b c) A^b_mu A^a_nu $ <eq2>

= Tables <sec5>

Tables can be inserted via the table and figure environment.

#figure(
  table(
    columns: 4,
    table.hline(stroke: 1.2pt),
    table.header(
      [*Column 1*], [*Column 2*], [*Column 3*], [*Column 4*],
    ),
    table.hline(stroke: 0.5pt),
    [row 1], [data 1], [data 2], [data 3],
    [row 2], [data 4], [data 5], [data 6],
    [row 3], [data 7], [data 8], [data 9],
    table.hline(stroke: 1.2pt),
  ),
  kind: table,
  caption: [Caption text],
) <tab1>

= Figures <sec6>

Figures can be inserted via the `image` and `figure` functions:

#figure(
  rect(width: 90%, height: 4cm, stroke: 0.5pt + luma(180), fill: luma(245))[
    #set align(center + horizon)
    #set text(size: 8pt, fill: luma(120))
    [Replace with your figure]
  ],
  caption: [This is an example figure caption.],
) <fig1>

= Cross referencing <sec8>

Cross-reference figures, tables, equations, and headings using the `@label` syntax. For example, @fig1, @tab1, and @eq1.

= Methods <sec11>

Topical subheadings are allowed. Authors must ensure that their Methods section includes adequate experimental and characterization data necessary for others in the field to reproduce their work.

= Discussion <sec12>

Discussions should be brief and focused. In some disciplines use of Discussion or 'Conclusion' is interchangeable. It is not mandatory to use both. Some journals prefer a section 'Results and Discussion' followed by a section 'Conclusion'. Please refer to Journal-level guidance for any specific requirements.

= Conclusion <sec13>

Conclusions may be used to restate your hypothesis or research question, restate your major findings, explain the relevance and the added value of your work, highlight any limitations of your study, describe future directions for research and recommendations.

// ========================================
// BACKMATTER
// ========================================

#bmhead[Supplementary information]

If your article has accompanying supplementary file/s please state so here.

#bmhead[Acknowledgements]

Acknowledgements are not compulsory. Where included they should be brief. Grant or contribution numbers may be acknowledged.

#heading(numbering: none)[Declarations]

- *Funding*: Not applicable
- *Conflict of interest/Competing interests*: Not applicable
- *Ethics approval and consent to participate*: Not applicable
- *Consent for publication*: Not applicable
- *Data availability*: Not applicable
- *Materials availability*: Not applicable
- *Code availability*: Not applicable
- *Author contribution*: Not applicable

#bibliography("refs.bib", title: "References")
