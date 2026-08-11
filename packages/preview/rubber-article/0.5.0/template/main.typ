/*
 * The Rubber Article Template.
 *
 * Here is a quick run-down of the template.
 * Some example content has been added for you to see what the template looks like and how it works.
 * Some features of this template are explained here, so you might want to check it out.
 */

#import "@preview/rubber-article:0.5.0": *

// Layout and styling
#show: article.with(
  cols: none, // Tip: use #colbreak() instead of #pagebreak() to seamlessly toggle columns
  eq-chapterwise: true,
  eq-numbering: "(1.1)",
  header-display: true,
  header-title: "The Title of the Paper",
  lang: "en",
  page-margins: 1.75in,
  page-paper: "us-letter",
)

// Frontmatter
#maketitle(title: "The Title of the Paper", authors: ("Authors Name",), date: datetime
  .today()
  .display("[day]. [month repr:long] [year]"))

// Actual Content starts here.
// REMOVE BELOW THIS LINE TO START YOUR OWN CONTENT.
= Introduction
#lorem(50) Here is the paragraph spacing with default settings.

#lorem(60) Here the vspace function is used to add some space between paragraphs on demand to

#vspace
#lorem(100)
$
  x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c))/ (2 a)
$
#lorem(100)

== In this paper
#lorem(70)

#figure(rect(width: 4cm, height: 3cm), caption: shortcap([A short caption of the image], [#lorem(
    30,
  )]))

#lorem(20)

=== Contributions
#lorem(40)

#lorem(40)

= Related Work
#balance(columns(2, [#lorem(200)]))

$
  y = k x + d
$
#lorem(50)

// Example of a custom table
#figure(ctable(cols: "l|cr", [A], [B], [C], ..range(1, 16).map(str)), caption: shortcap(
  "Short caption",
  "This is a custom table",
))

#colbreak()
#show: appendix.with(title: "Appendix")

= Appendix 1
#lorem(35)

== Some more details
#lorem(20)

#fig-outline()
#tab-outline()
