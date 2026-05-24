#import "@preview/documenting-tbre:0.1.0": template, appendix, abbrev

// Input credentials from environment variable (if set) at initialisation of template for author information
#let creds-string = sys.inputs.at("credentials", default: none)

#let author-name = "YOUR_NAME"
#let author-email = "YOUR_EMAIL"

#if creds-string != none {
  let parsed = json(bytes(creds-string))
  author-name = parsed.name
  author-email = parsed.email
}

#show: template.with(
  title: "TBRe Documentation Template",
  doc-type: "Documentation",
  author: author-name,
  email: author-email,
  date: datetime(day: 30, month: 4, year: 2002),
  reviewers: (), 
  doc-id: "TBRe-2026-001", 
  changelog: include "changelog.typ",
  references: bibliography("refs.bib"),
  show-abbreviations: true,
  show-contents: true,
  show-lists: true,
  auto-pagebreak: true,
)

= Formatting Guidelines

When first mentioning an abbreviation use the `abbrev` function to log it and show it in the text. For example #abbrev("TBRe", "Team Bath Racing Electric"). You can set `inline: false` to only log it without showing the full form in the text.

== Figures



=== Graphs

Each should have its own caption, containing a brief description of the content. You should place each figure/table and the accompanying caption in a textbox, convert to a frame, and position appropriately. Do not use a border, and position the figure or table as close as possible to the first reference in the document. Figure @ga-figure shows an example.

#figure(
  image("images/nomex_core_stress_strain_relation.png"),
  caption: [Stress-strain behavior for Nomex honeycomb core material. Shows failure at around 300N/12.1mm, rubbish. Try to keep labels and axes readable, and use a consistent style across all figures.],
)

Figures should always be mentioned in the text by referring to their figure number #sym.dash don't expect the reader to know automatically which figure you are talking about. It is usually good style to place figures and tables at the top of the page (but not on page 1). If the top of the page is not suitable, the bottom of the page can also be good. Positioning the figures is best done when the text of the document is finished.

=== Graphics

Try to reduce file sizes of graphics as much as possible to prevent the repository from becoming too large. Ideally use #link("https://git-lfs.com/", `git-lfs`) to manage large files in git by running the following commands:

```sh
git lfs install
git lfs track "*.png" "*.jpg" "*.jpeg" "*.svg"
git add .gitattributes
git commit -m "Track image files with git-lfs"
```

Image figures can be scaled as needed by adjusting the parameters of the `#image` function. With referencing done via tags like `@ga-figure` referring to `<ga-figure>`, which will automatically update the figure number if you add more figures before it.

#figure(
  image("./images/ga_2026_mar.png"),
  caption: [A screenshot of the General Assembly for a meeting in March 2026],
) <ga-figure>

#v(6pt)

=== Tables

For tables ensure that they are clearly laid out and easy to read. If they are too large to fit on the page, consider breaking them up into multiple tables, or including them in the appendix instead. Each table should have a caption describing its content, and should be referenced in the text by its table number. An example of a table figure is shown in @speed-table.

#figure(
  caption: [Caption text for the figure describing the tabular data, font size can be adjusted for larger tables to ensure data fits #v(6pt)],
  table(
    columns: (30%, 30%),
  )[Distance (m)][Velocity ($"ms"^(-1)$)][100][1.24][150][4.35][200][6.76][250][8.00],
  kind: table,
) <speed-table>

== Equations

The Typst syntax for equations is similar to LaTex but more intuitive with fewer backslashes and less syntax bloat, if you don't know the symbol it is usually its name in plain english. Alternatively you can use the vscode Typst extension to draw the symbol you need. Remember to define the quantities in the equation, and punctuate appropriately. An example is

$
d/ (d t) ( (partial cal(L)) / (partial dot(q)_r)) - (partial cal(L)) / (partial dot(q)_r) = Q_r #h(2pt) , #h(10pt) r = 1,2, dots.c #h(2pt) n
$

which is the Lagrangian equation of motion @jazar2025vehicle, where $cal(L)$ is the Lagrangian, $t$ is time, $q_r$ are the generalized coordinates, and $Q_r$ are the generalized forces. Note the comma, to punctuate the equation within the text. Note also that variables should have the same appearance (font) in equations and in the main text.

== Referencing

When referencing figures, tables, equations, sections, etc. use the `@` symbol followed by the tag you have assigned to the figure/table/section. For example, `@ga-figure` will reference the figure tagged with `<ga-figure>`. This will automatically update the reference number as sections/figures/references are added. You can tag any element with `<tag-name>` to create a reference point for it.

At the end of the document, but before the appendix, a bibliography can be included using the `bibliography` function as shown which will pull in references from the specified .bib file. The default format is "ieee", but other formats are also available. You can also set `title: none` to hide the bibliography title. The `full: true` option will show all references in the .bib file, even if they are not cited in the text.

#bibliography("refs.bib", title: "References", full: true)

// Apply appendix styling 
#show: appendix

= Appendix

Appendices can be in single column format, which makes it much easier to include code snippets, etc. But make sure that everything is clearly readable, and that the main text of the report explains what is in the appendices, and why you have included them.

\

```cpp
#include <iostream>
#include <cmath>
#include <vector>

int main() {
  std::vector<double> x = {1.0, 2.0, 3.0, 4.0, 5.0};
  std::vector<double> y = {1.0, 4.0, 9.0, 16.0, 25.0};

  for (int i = 0; i < x.size(); i++) {
    std::cout << x[i] << " " << y[i] << std::endl;
  }

  return 0;
}

```


#[] <end-appendix>