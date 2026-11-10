#import "@preview/cardinal-su-thesis:0.1.0": *

#chapter-title[Chapter 1]
= Introduction

== How this document is organised

The `chapter-title` call above puts an unnumbered "Chapter 1" label at the top
of the page, and the `= Introduction` heading immediately after it supplies the
numbered chapter title. The pair is the standard way to open a chapter with this
template. Because `chapter-title` already inserts the page break and the
vertical drop, the heading that follows does not add a second one.

Pagination switches from lowercase Roman numerals to Arabic numerals at this
page, restarting at 1 rather than continuing the preliminary sequence. Page
numbers sit in the same place on every page of the document, which is what the
Registrar's consistency rule asks for.

== Cross-references and citations

Citations use Typst's `@key` syntax and resolve against `refs.bib`
@adams2019latent. Several citations in a row collapse under the Nature style
@baptiste2020scaling @choudhury2021robust. Books, chapters, conference papers,
preprints, and technical reports all render from the same file
@doran2018foundations @ellison2022chapter @fujimoto2017efficient
@grewal2023preprint @haddad2016report.

When you need to talk about a reference by number in running prose rather than
as a trailing superscript, `refnum` puts the number on the baseline: as
reviewed in ref.~#refnum(<ibarra2024synthesis>), the conventions differ by
field.

Cross-references to figures, supplementary material, and methods are all
chapter-prefixed and rendered in bold. @fig-example-one in the next chapter
shows a three-panel figure; @supp-note-conventions and @supp-tab-parameters in
the appendix show supplementary notes and tables.

== Heading levels

The template styles four levels of heading. This section demonstrates the third
and fourth.

=== A third-level heading

Third-level headings are bold and set at 12 pt by default. They are the
smallest level that appears in the table of contents, which is generated with
`depth: 3`.

==== A fourth-level heading

Fourth-level headings are italic rather than bold, and do not appear in the
table of contents. Use them sparingly, for the finest subdivisions.

=== Keeping headings with their text

Headings are sticky: Typst will not leave one stranded at the foot of a page
with its text on the next. This addresses the Registrar's rule against a
heading or subheading appearing at the bottom of a page without text following
it.
