#import "@preview/ieee-vgtc:0.0.2": journal

#show: journal.with(
  // Set review: true to enable review mode (hides authors, shows submission info)
  review: false,
  submission-id: 1234,
  category: "Research",
  // Please declare the paper type of your paper to help reviewers, only shown in review mode
  // Choices:
  // * algorithm/technique
  // * application/design study
  // * evaluation
  // * system
  // * theory/model
  paper-type: "algorithm/technique",
  title: [Global Illumination for Fun and Profit],
  abstract: [#lorem(125) A free copy of this paper and all supplemental materials are available at https://OSF.IO/2NBSG.],
  authors: (
    (
      name: "Josiah S. Carberry",
      organization: [Brown University],
      orcid: "0000-0002-1825-0097",
      email: "jcarberry@example.com"
    ),
    (
      name: "Ed Grimley",
      organization: [Grimley Widgets, Inc.],
      email: "ed.grimley@example.com"
    ),
    (
      name: "Martha Stewart",
      organization: [Martha Stewart Enterprises at Microsoft Research],
      email: "martha.stewart@example.com"
    ),
  ),
  teaser: (
    image: image("figs/clouds.jpg", alt: "A view of clouds with orange sunrays shining through from behind."),
    caption: "Dramatic evening clouds. Note that the teaser may not be wider than the abstract block."
  ),
  index-terms: ("Radiosity", "global illumination", "constant time"),
  bibliography: bibliography("refs.bib"),
)

= Introduction

This template is for papers of VGTC-sponsored conferences such as IEEE VIS, IEEE VR, and ISMAR which are published as special issues of TVCG.
The template does not contain the respective dates of the conference/journal issue, these will be entered by IEEE as part of the publication production process.
Therefore, *please leave the copyright statement at the bottom-left of this first page untouched*.

= Author Details

You should specify ORCID IDs for each author (see https://orcid.org/  to register) for disambiguation and long-term contact preservation. The template shows an example without ORCID IDs for two of the authors.
ORCID IDs should be provided in all cases.

= Hyperlinks and Cross References

Links are automatically shown for URLs but you can customize the name of the link with the `#link` function: https://typst.app/docs/reference/model/link/.

= Figures

Typst automatically detects the type of figure (i.e., table, image, or code) and label them accordingly. Figures are documented at https://typst.app/docs/reference/model/figure/.

For figures with images, the image format is usually detected automatically. For details, head over to the image documentation: https://typst.app/docs/reference/visualize/image/.

== Vector figures

#figure(
  image("figs/chart.svg", alt: "A bar chart showing the number of days per month broken down by weather type.", width: 80%),
  caption: "Stacked bar chart of weather data.",
)

Vector graphics like SVG and PDF are best for charts and other figures with text or lines.
They will look much nicer and crisper and any text in them will be more selectable, searchable, and accessible.

== Raster figures

#figure(
  image("figs/clouds.jpg", alt: "A view of clouds with orange sunrays shining through from behind."),
  caption: "Dramatic evening clouds.",
)

Of the raster graphics formats, screenshots of user interfaces and text, as well as line art, are better shown with PNG.
JPEG is better for photographs.
Make sure all raster graphics are captured in high enough resolution so they look crisp and scale well.

== Alternative texts

Always include an alternative text that describes the image. The alt text should not be the same as the caption, but should describe the image in a way that makes sense when the image is not visible.

== Figures on the first page

The teaser figure should only have the width of the abstract as the template enforces it.
The use of figures other than the optional teaser is not permitted on the first page.
Other figures should begin on the second page.
Papers submitted with figures other than the optional teaser on the first page will be refused.

== Figures with subfigures

Use the grid function to create subfigures.

#figure(
  grid(columns: 2, row-gutter: 2mm, column-gutter: 1mm,
  image("figs/clouds.jpg", alt: "A view of clouds with orange sunrays shining through from behind."),
  align(horizon)[#image("figs/clouds.jpg", alt: "A view of clouds with orange sunrays shining through from behind.")]),
  caption: "Dramatic evening clouds."
)

== Code

Typst supports code blocks and inline code: https://typst.app/docs/reference/text/raw/. For example

```rust
fn main() {
    println!("Hello World!");
}
```

= Lists

You can create both numbered and bulleted lists:

+ First item in a numbered list
+ Second item with multiple lines of text that wraps to demonstrate how the indentation works
+ Third item

Bulleted lists work similarly:

- First bullet point
- Second bullet point
  - Nested bullet point
  - Another nested item
- Third bullet point

= References

An example of the reference formatting is provided in the *References* section at the end.

== Include DOIs

All references which have a DOI should have it included in the bibTeX for the style to display.
The DOI can be entered with or without the https://doi.org/ prefix.

= Equations and Tables

Equations can be added like so:

// $ sum_(j=1)^z j = (z(z+1))/2 $ <eq:sum>
#math.equation(block: true, numbering: "(1)", $sum_(j=1)^z j = (z(z+1))/2$, alt: "Sum from j equals 1 to z of j equals z times open parenthesis z plus 1 close parenthesis divided by 2") <eq:sum2>

Tables, such as @tab:example can also be included.

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: (x, y) => (
      top: if y == 0 { 0.75pt } else if y == 1 { 0.5pt } else { 0pt },
      bottom: 1pt,
    ),
    [*Year*], [*Vis/SciVis*], [*InfoVis*], [*VAST*],
    [2016], [30], [37], [33],
    [2015], [33], [38], [33],
    [2014], [34], [45], [33],
    [2013], [31], [38], [32],
    [2012], [42], [44], [30],
  ),
  caption: [Example table with conference paper counts. Numbers should be right aligned.]
) <tab:example>

= Accessibility

To create accessible PDFs that comply with PDF/UA (Universal Accessibility) standards, compile your document with the `--pdf-standard ua-1` flag:

```bash
typst compile journal.typ --pdf-standard ua-1
```

This ensures your document is accessible to screen readers and other assistive technologies. When using this flag:

- All images must have descriptive `alt` text (or be marked as decorative using `pdf.artifact`)
- All equations must have alt text using the explicit syntax: `#math.equation(block: true, numbering: "(1)", $...$, alt: "description")`
- Avoid embedding PDF images; use SVG or raster formats instead

For more information on creating accessible documents, see the #link("https://typst.app/docs/guides/accessibility/")[Typst accessibility guide].

= Paper overview

In this paper we introduce Typst, a new typesetting system designed to streamline the scientific writing process and provide researchers with a fast, efficient, and easy-to-use alternative to existing systems. Our goal is to shake up the status quo and offer researchers a better way to approach scientific writing. Here is a reference: @netwok2020.

By leveraging advanced algorithms and a user-friendly interface, Typst offers several advantages over existing typesetting systems, including faster document creation, simplified syntax, and increased ease-of-use.

To demonstrate the potential of Typst, we conducted a series of experiments comparing it to other popular typesetting systems, including LaTeX. Our findings suggest that Typst offers several benefits for scientific writing, particularly for novice users who may struggle with the complexities of LaTeX. Additionally, we demonstrate that Typst offers advanced features for experienced users, allowing for greater customization and flexibility in document creation.

Overall, we believe that Typst represents a significant step forward in the field of scientific writing and typesetting, providing researchers with a valuable tool to streamline their workflow and focus on what really matters: their research. In the following sections, we will introduce Typst in more detail and provide evidence for its superiority over other typesetting systems in a variety of scenarios.

= Methods
#lorem(90)

// $ a + b = gamma $
#math.equation(block: true, numbering: "(1)", $a + b = gamma$, alt: "a plus b equals gamma")

#lorem(200)

= Acknowledgments
The authors wish to thank A, B, and C.
This work was supported in part by a grant from XYZ (\# 12345-67890).
