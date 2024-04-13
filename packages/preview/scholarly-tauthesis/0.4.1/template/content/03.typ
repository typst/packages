/** 03.typ
 *
 * This is an example chapter in a multi-file typst project.
 *
***/

#import "../preamble.typ": *
#import "@preview/scholarly-tauthesis:0.4.1" as tauthesis

= References <references>

Different referencing styles determine how you create in-text citations and
the bibliography (list of references). Two common referencing styles are
presented in this chapter:

- Numeric referencing (Vancouver system), such as [1], [2], …
- Name-year (Harvard) system, such as (Weber 2001), (Kaunisto 2003), ...

A numeric reference is inserted in square brackets, whereas the
last name of the author and the year of publication are given in
parentheses. Both styles are acceptable, but the conventions for
referencing vary between disciplines. You must pick one and use
it consistently throughout your thesis. The list of possible
styles can be found on the typst documentation page
@typst-documentation-bibliography.

The most commonly used tool for creating bibliographies in typst is the
hayagriva YAML format, but typst also supports BibLaTeΧ. The latter is what
this thesis template uses, as it is compatible with LaTeΧ. BibLaTeΧ is based on
gathering the bibliographic information from the sources to a
`bibliography.bib` file using a specialised syntax. Typst reads both this file
and the document being written, and then forms the references and the
bibliography based on this information. A citation style can be chosen
by setting it in the `meta.typ` file, in the variable `mycitationstyle`.

== In-text citations <in-text-citations>

In-text citations are placed within the body of the text as close to the actual
claim that the citation supports as possible. The citation is generally placed
within the sentence before the next period:

- Weber argues that... [1].
- Cattaneo et al. introduce in their study [2] a new...
- The result isldots [1, p. 23]. One must also note... [1, pp. 33--36]
- In accordance with the presented theory... (Weber 2001).
- It must especially be noted... (Cattaneo et al. 2004).
- Weber (2001, p. 230) has stated ...
- Based on literature in the field [1, 3, 5] ...
- Based on literature in the field [1][3][5] ...
- The topic has been widely studied [6--18] ...
- ... existing literature (Weber 2001; Kaunisto 2003; Cattaneo et al. 2004) has ...

Each of the sources listed in the `bibliography.bib` file must be associated
with a unique identifier at the beginning of the entry. These identifiers
should be chosen as descriptively as possible, since all citations are created
using them. In the numeric system each citation is typeset using the `@refname`
command. For example, placing `@Bezanson2017Julia` in a paragraph results in
the following citation: @Bezanson2017Julia.

== The bibliography.bib file <bib-file>

This is where the information related to the possible references is placed.
It is presented in the  form
```bib
@article {
    braams1991babel,
    title={Babel, a multilingual style-option system for use with LaTeΧ’s standard document styles},
    author={Braams, Johannes L},
    journal={TUGboat},
    volume={12},
    number={2},
    pages={291--301},
    year={1991}
}
```
The following information should be provided per source as bibliographic
information, if known:

- author(s),
- title,
- time of publication,
- publisher,
- pages (books and journals), and
- website URL

Typst takes care of presenting them in an internally consistent manner. When
using this system, it is imperative to know the type of the source: a
`journal`, `article`, a `book`, conference proceedings (`proceedings`), a
`report` and a `patent` are only examples of the various possibilities. This
information is also included in the `bibliography.bib` file, and the
presentation is automatically taken care of based on the type of the source.


It is preferable to order the list of references alphabetically by the first
author's last name. This template conforms automatically to this convention. An
excellent way for the easy formation of citation entries is to find a template
using Google Scholar. It produces a good first try for the use of BibTeΧ and
BibLaTeΧ.
