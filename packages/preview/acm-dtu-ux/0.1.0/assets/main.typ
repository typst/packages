#import "@preview/acm-dtu-ux:0.1.0": *

#show: project.with(
  title: "One AR to rule them all",
  authors: (
    (name: "Joe Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "Jack Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "William Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "Averell Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
  ),
  // Insert your abstract, if any, after the colon, wrapped in brackets. If left empty, it will not show up as a chapter altogether.
  // Example: `abstract: [This is my abstract...]`
  abstract: [],
)

// We generated the example code below so you can see how
// your document will look. Go ahead and replace it with
// your own content!

= Introduction (JoA, JaA)
This LaTeX project serves as an ACM SIG Proceedings boilerplate specifically for _02266 - UX Design Prototyping_ and _02266 - User Experience Engineering_.

Make a copy of the project and edit it as needed.

= Related work (WA, AA)
To cite sources and manage references, one should add them to the bibliography.bib and reference them in the document @elements-of-value @klein2013ux.

For internal cross-referencing, one should use labels as seen in @sec:section4.

= Scoping (WA, AA) <sec:section3>
What we decided to focus on was ...

If you followed a "what do we need to find out", "how (what method) should we use" and "what was the outcome" feel free to report it this way also for the scoping / sketching / prototyping / ideation / problem definition phase.

= Iteration \#1 (JoA, WA, AA) <sec:section4>

*What*: In this iteration we wanted to ... our hypothesis/research question/intention was ...

*How*: The methods we used were ... we built ...

*Results/outcome*: The results of our testing/validation ... see appendix for details ... I

*stuff*: Based on our results, we learned that ... we changed ... we will therefore ...


Images are included as follows and referenced with @fig:example.
#figure(
    image("images/example-image.png", width: 70%),
    caption: [Change in appearance in third iteration],
) <fig:example>

In addition to the snippet above, check also in @appendix:wireframes


= Iteration \#2 (JoA, WA, AA) <sec:section5>

*What*: In this iteration we wanted to ... our hypothesis/research question/intention was ...

*How*: The methods we used were ... we built ...

*Results/outcome*: The results of our testing/validation ... see appendix for details ... I

*stuff*: Based on our results, we learned that ... we changed ... we will therefore ...

= Discussion (AA)
#lorem(62)


= Conclusion (WA, JA)
#lorem(72)

= Contributions


#bibliography("bibliography/bibliography.bib")

#colbreak()

#appendix([
= Landing Page (final) <appendix:landing-page>

= Lean Business Model Canvas (final) <appendix:canvas>

= User Story Map (final) <appendix:usm>

= Wireframes (final) <appendix:wireframes>

= Validation (final) <appendix:validation>

= Landing Page (iteration \#3) <appendix:landing-page-3>

= Lean Business Model Canvas (iteration \#3) <appendix:canvas-3>

= User Story Map (iteration \#3) <appendix:usm-3>

= Wireframes (iteration \#3) <appendix:wireframes-3>

= Validation (iteration \#3) <appendix:validation-3>

])
