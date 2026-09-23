#import "@preview/fun-article:0.2.0": appendix, fun-article

#show: fun-article.with(
  title: "When Good Ideas Wear Comfortable Shoes",
  authors: (
    (name: "Ada Lovelace", affils: "1", orcid: "0000-0000-0000-0000", is-corresponding: true),
    (name: "Grace Hopper", affils: "2"),
  ),
  affiliations: (
    (id: "*", name: "Corresponding author: ada@example.com"),
    (id: "1", name: "Department of Curious Systems, Example University"),
    (id: "2", name: "Institute for Practical Imagination"),
  ),
  abstract: "This article demonstrates a compact two-column research layout with a drop-cap abstract, author metadata, affiliations, running headers, and a significance note. It is intended as a lightweight starting point for papers that want a formal structure with a warmer editorial voice.",
  significance: [
    Use the significance note for the shortest possible statement of why the work matters.
  ],
)

= Introduction

Fun Article is a small research-paper template for writing concise articles with a two-column body, a prominent abstract, and a highlighted significance statement. It keeps the page economical while leaving enough visual character for essays, working papers, and short reports.

The template accepts structured author data, affiliation markers, ORCID identifiers, and a configurable page size. The body is ordinary Typst content, so equations, figures, tables, references, and appendices work as they do in any other document.

== A Compact Section

Use headings to divide the article into ordinary sections. The template sets restrained heading styles and a comfortable body measure for dense text.

You can include mathematics inline, such as $a^2 + b^2 = c^2$, or display equations when the argument needs room:

$
  f(x) = integral_0^x exp(-t^2) dif t
$

= Methods

Replace this sample text with your article. The initialized project imports the published package with an absolute package import, so it will keep compiling when created with `typst init`.

= Conclusion

The template is intentionally small: import it, fill in the metadata, and write the article.

#show: appendix

= Optional Notes

Appendices use lettered headings after the `appendix` show rule.
