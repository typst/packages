/** 03.typ
 *
 * This is an example chapter in a multi-file Typst project.
 *
***/

#pdf.attach(
  "03.typ",
  relationship: "source",
  mime-type: "text/vnd.typst",
  description: "The Typst source code for the citation instructions chapter 3 of this thesis.",
)

#import "../preamble.typ": *

= References <references>

Different referencing styles determine how you create
in-text citations and the bibliography (list of
references). Two common referencing styles are presented in
this chapter:

- Numeric referencing (Vancouver system), such as [1], [2], …
- Name-year (Harvard) system, such as (Weber 2001), (Kaunisto 2003), ...

A numeric reference is inserted in square brackets, whereas
the last name of the author and the year of publication
are given in parentheses. Both styles are acceptable, but
the conventions for referencing vary between disciplines.
You must pick one and use it consistently throughout your
thesis. The list of possible styles can be found on the
Typst documentation page @typst-documentation-bibliography.

The most commonly used tool for creating bibliographies
in Typst is the Hayagriva @hayagriva-github YAML
@yaml-website format, but Typst also supports BibLaTeΧ
@biblatex-ctan. The former is what this thesis template
uses by default. Both Hayagriva and BibLaTeX are based
on gathering bibliographic information from the sources
to a bibliography file using a specialised syntax. Typst
reads both this file and the document being written,
and then forms the references and the bibliography based
on this information. A citation style can be chosen by
setting it in the `metadata.typ` file, in the variable
`citationStyle`.

== In-text citations <in-text-citations>

In-text citations are placed within the body of the text
as close to the actual claim that the citation supports
as possible. The citation is generally placed within the
sentence before the next period:

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

You _can_ also place a citation after a period, in which
case it refers to the entire preceding paragraph. However,
this is generally not recommended, as it might make it
unclear which claim the citation supports, if there are
manu within the preceding paragraph.

== The bibliography file <bib-file>

Typst works similarly to LaTeX when it comes to citations
and the bibliography:
+ A user collects a database of references into a
  bibliography file, where each reference has a _unique_
  identifier string that can be referenced, such as
  `mainauthor-etal-topic-year`.
+ The file is imported into a project using the
  `bibliography` function @typst-documentation-bibliography
  of Typst. This is done in the file `main.typ` in the case
  of this template.
+ To cite a bibliography file entry with the identifier
  `id`, one writes `@id` within the text of their Typst
  project. As an example of what this might look like,
  placing `@Bezanson2017Julia` in a paragraph results in
  the following citation: @Bezanson2017Julia.
The bibliogprahy file formats that Typst supports
are _Hayagriva_ @hayagriva-github and _BibLaTeX_
@biblatex-ctan. This template contains mostly equivalent
examples of both respective formats in the form of
the files `bibliography.yaml` and `bibliography.bib`.

The preferred format for this template is
Hayagriva, the reason for which will be explained in
@sec-inserting-phd-publications[Section]. If you have
an existing bibliography file in the form of BibLaTeX,
Hayagriva can also be installed as a command line program
@hayagriva-github[Installation], and the BibLaTeX file
converted to Hayagriva format using the command
```bash
hayagriva bibliography.bib > bibliography.yaml
```

There are different kinds of citation types such as
articles or web pages, which should be typeset differently
in the bibliography. In the case of Hayagriva, an article
reference metadata is given in @fig-hayagriva-example,
whereas an equivalent BibLaTeX entry is shown in
@fig-biblatex-example.
#figure(
  ```yaml
  Bezanson2017Julia:
    type: article
    title: >-
      Julia: A fresh approach to numerical computing
    author:
    - Bezanson, Jeff
    - Edelman, Alan
    - Karpinski, Stefan
    - Shah, Viral B
    date: 2017
    page-range: 65-98
    serial-number:
      doi: 10.1137/141000671
    url:
      value: https://doi.org/10.1137/141000671
      date: 2025-10-10
    parent:
      type: periodical
      title: SIAM review
      publisher: SIAM
      issue: 1
      volume: 59
  ```,
  caption: [An example of a Hayagriva article entry.]
) <fig-hayagriva-example>

#figure(
  ```bib
  @article{
  	Bezanson2017Julia,
  	title={{Julia: A fresh approach to numerical computing}},
  	author={Bezanson, Jeff and Edelman, Alan and Karpinski, Stefan and Shah, Viral B},
  	journal={SIAM review},
  	volume={59},
  	number={1},
  	pages={65--98},
  	year={2017},
  	publisher={SIAM},
  	url={https://doi.org/10.1137/141000671}
  }
  ```,
  caption: [An example of a BibLaTeX article entry.]
) <fig-biblatex-example>

It is often preferable to order the list of references
alphabetically by the first author's last name. This
template however uses the `ieee` style by default, meaning
that citations are listed in the bibliography in the
order of apprearance. Change the value of the variable
`citationStyle` in the file `metadata.typ` to change this.

== Inserting PhD publications into your thesis <sec-inserting-phd-publications>

As was mentioned in
@sec-compilation-dissertation-accessibility[Section], the
PDF format has some limitations regarding attaching PDF
files into other PDF files, if one wishes for the final
product to remain standard-conforming. Regardless, this
template provides support for inserting PhD publications at
the end of this document #footnote[Which is not compulsory
for it to be accepted.] using the bibliography file
`bibliography.yaml`, if the export format is not one of
the tagged variants such as PDF/A-3a or PDF/UA-1. You can
therefore test how the PDF attachments would look like if
you just compile your document without accessibility tags:
```sh
typst compile template/main.typ
```

To tell the template which of your references in
`bibliography.yaml` should be considered as compilation
dissertation attachments, you should add additional fields
to the Hayagriva file `bibliography.yaml` entries, that
correspond to your PhD publications. These are of the
following form:
```yaml
path: publications/publication.pdf
license: null or the name of the license
n-of-pages: the number of pages in the document
tauthesis-publication: true or false
author-contribution: >
  A short description of how you contributed to this work.
  This can extend on multiple lines, as long as the lines
  are indented.
```
The `path` field should be in relation to the `main.typ`
file. It might be a good idea to utilize the readily
provided `publications/` folder in the template directory,
where the example publications already reside.

== Attaching Typst-based PhD publications

If you are in the lucky position of being allowed to use
Typst source code to enter your dissertation publications
into your thesis #footnote[Which you again do not _need_ to
do. It is just a bonus if you can.], it should be entirely
possible to make your entire dissertation accessible. To
aid with this, targeting _Open Access publishing channels_
@tuni-open-access-publishing-guide and preferring licenses
such as CC BY 4.0 @cc-by-webpage in your publications
allows you to create a _derivative work_ from the
publication. A derivative work can be a Typst version of
the publication.

The Typst source simply needs to adhere to
related accessibility standard requirements
@typst-accessibility-guide @tuni-lib-hyva-tietaa. Simply
point the `path` field of a Hayagriva bibliography entry
to a valid Typst root file of your publication, and this
template will `#include` it.

*Note 1:* Any included Typst files should _not_ set their
own page size or margins in a way which overwrites the ones
of this template, as the page sizes need to match. Remove
any
```typst
#set page(...)
```
invocations from the start of the publication file, and let
this template handle the page settings for you. Otherwise
you are allowed to customize the appearance of the
publications using `set` and `show` rules of Typst, unless
you wish to use the style of this template. Any utilized
fonts should be accessible, though, so keep that in mind.

*Note 2:* Typst does not support multiple bibliographies
in version #version(0,14,0) natively, but it is a planned
feature of version #version(0,15,0). In the meanwhile, you
might wish to utilize a package such as
#link("https://typst.app/universe/package/alexandria")[`alexandria`]
or
#link("https://typst.app/universe/package/pergamon")[`pergamon`]
to typeset the bibliography of an attached Typst-based PhD
publication and keep it separate from the bibliography of
the main dissertation.
