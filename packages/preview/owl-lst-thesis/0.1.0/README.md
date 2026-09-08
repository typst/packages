# Typst style for LST theses

This is a Typst thesis style
for the [Department of Language Science and Technology](https://www.lst.uni-saarland.de/)
at [Saarland University](https://www.uni-saarland.de/).
You can use this for your Bachelor's or Master's Thesis or any other document you like.
The template is maintained by [Alexander Koller](https://www.coli.uni-saarland.de/~koller/).

The template sets up the title page, declaration, abstract, acknowledgments,
table of contents, chapter styling, headers, page numbers, figure captions, and bibliography
formatting for an LST thesis.
The default `screen` mode uses equal left and right margins. The `print` mode is intended for
double-sided printing and binding, with a wider inner margin.


## Quick start in the Typst web app

1. Open the Typst web app.
2. Create a new project from the `owl-lst-thesis` template.
3. Edit the metadata in the `#show` block.
4. Add BibTeX entries and import your BibTeX file with `add-bib-resource`.

You can write the thesis below the `#show: lst` block and export the PDF from the web app.


## Minimal thesis file

This is the smallest useful shape of a thesis file:

```typst
#import "@preview/owl-lst-thesis:0.1.0": *
#import "@preview/pergamon:0.8.0": *

#set text(lang: "en")

#show: lst.with(
  title: "My Thesis Title",
  author: "Jane Student",
  matriculation-number: "1234567",
  degree-program: "coli",
  supervisors: (
    ("Supervisors", "Prof. Dr. First Supervisor", "Prof. Dr. Second Supervisor"),
    ("Additional advisor", "Dr. Helpful Advisor"),
  ),
  date: "31.12.2026",

  abstract: [
    Write a short summary of the thesis here.
  ],

  acknowledgments: [
    Optional acknowledgments go here.
  ])

#add-bib-resource(read("custom.bib"))

= Introduction

Start writing here. Cite papers with Pergamon like this #cite("bender-koller-2020-climbing").

#print-lst-bibliography()
```


## Template arguments

The main function is `lst`. Use it in a `#show` rule around your document content.

- `title`: Thesis title shown on the title page and stored in the PDF metadata. Can be any content.
- `author`: Your name, stored in the PDF metadata. Must be a string.
- `matriculation-number`: Your matriculation number. Must be a string.
- `degree-program`: Required degree program printed on the title page. Use one of the built-in
  abbreviations below, or pass free-form text for custom cases together with `thesis-type`.
- `supervisors`: A tuple of supervisor groups. Each group starts with a role label, followed by
  one or more names. Use strings for all labels and names.
- `date`: Submission date printed on the title page and declaration. Must be a string.
- `thesis-type`: Optional string. By default, the template chooses the localized bachelor's or
  master's thesis label from a built-in degree program. Set this by hand for custom cases such as
  `"Seminar paper"`; this manual value is not localized.
- `city`: Optional string. Defaults to `Saarbrücken` and is printed above the signature line in the
  declaration.
- `mode`: Optional string. Defaults to `"screen"`, which makes the left and right margin equal size. Use `"print"` for a wider inner margin for binding.
- `abstract`: Optional content. If present, the template creates an abstract page.
- `acknowledgments`: Optional content. If present, the template creates an acknowledgments page.

Built-in degree programs:

| Abbreviation | Degree program | English thesis type | German thesis type |
| --- | --- | --- | --- |
| `"langsci"` | `BA Language Science` | `Bachelor's Thesis` | `Bachelorarbeit` |
| `"coli"` | `BSc Computerlinguistik` | `Bachelor's Thesis` | `Bachelorarbeit` |
| `"lst"` | `MSc Language Science and Technology` | `Master's Thesis` | `Masterarbeit` |
| `"lct"` | `MSc Language and Communication Technologies` | `Master's Thesis` | `Masterarbeit` |
| `"tst"` | `MA Translation Science and Technology` | `Master's Thesis` | `Masterarbeit` |

For these built-in abbreviations, the degree program name is printed exactly as shown above. The
thesis type is selected from the document language: `#set text(lang: "en")` prints the English
label, and `#set text(lang: "de")` prints the German label.

The template automatically creates:

- title page with LST and Saarland University logos;
- declaration page;
- PDF metadata with the thesis title, author, and template preparation string;
- abstract and acknowledgments pages when provided;
- table of contents to section depth;
- main-matter page numbering;
- odd-page chapter starts with blank pages where needed;
- running headers with chapter and section information;
- chapter-based numbering for figures, tables, raw figures, and equations;
- LST-styled captions, links, references, and bibliography heading.


## Language

The template localizes its built-in labels from Typst's document language. It defaults to
English. Use German with:

```typst
#set text(lang: "de")
```

This translates template chrome such as chapter labels, front-matter headings, title-page
fields, and the declaration. User-provided thesis text and supervisor role labels are not
translated automatically, so write those labels yourself:

```typst
supervisors: (
  ("Gutachter", "Prof. Dr. First Supervisor", "Prof. Dr. External Reviewer"),
  ("Betreuerin", "Dr. Helpful Advisor"),
)
```


## Writing structure

Use normal Typst headings:

```typst
= Chapter
== Section
=== Subsection
==== Paragraph-style heading
```

The table of contents includes chapters and sections. Subsections and lower heading levels are
not shown in the table of contents.

Use labels for cross-references:

```typst
= Introduction <sec:introduction>

As discussed in @sec:introduction, this chapter introduces the topic.
```

Use figures and tables with labels:

```typst
#figure(caption: [Example figure.])[
  #image("figure.pdf", width: 80%)
] <fig:example>

See @fig:example.
```



## Citations and bibliography with Pergamon

This template uses [Pergamon](https://typst.app/universe/package/pergamon) for author-year citations and bibliography formatting. Keep these
three pieces in your thesis file:

```typst
#import "@preview/pergamon:0.8.0": *

#add-bib-resource(read("custom.bib"))

#print-lst-bibliography()
```

Add references to `custom.bib` in normal BibTeX format. Of course you can also use Bibtex files with different names.

Cite a source in parentheses with `#cite` and as a noun phrase with `#citet`.
Pass the BibTeX key as a string (not as a label like in the default Typst `cite` command):

```typst
#citet("bender-koller-2020-climbing") argued that meaning cannot be learned from form alone.
```

Finally, print the bibliography at the end of the document:

```typst
#print-lst-bibliography()
```

`print-lst-bibliography` is provided by this template. It creates the LST-styled bibliography
heading and then asks Pergamon to print the bibliography.


## Fonts

The template uses Libertinus Serif for the main text and Open Sans for headings, captions, headers, and title-page elements. Install
[Open Sans](https://fonts.google.com/specimen/Open+Sans) locally when compiling offline.

In the Typst web app, Libertinus Serif and Open Sans should be available without extra setup.


## Common metadata patterns

To select another degree program, set `degree-program`:

```typst
#show: lst.with(
  degree-program: "lst",
  title: "My Thesis Title",
  // add the remaining arguments as in the minimal example
)
```

To override the thesis type that is chosen from the degree program, set `thesis-type`:

```typst
#show: lst.with(
  degree-program: "langsci",
  thesis-type: "Seminar paper",
  title: "My Seminar Paper",
  // add the remaining arguments as in the minimal example
)
```

Free-form degree programs are also possible, but then `thesis-type` is required:

```typst
#show: lst.with(
  degree-program: "Certificate Program in Example Studies",
  thesis-type: "Project report",
  title: "My Report",
  // add the remaining arguments as in the minimal example
)
```

If `degree-program` is omitted, the template stops with an error message. If `degree-program` is
free-form and `thesis-type` is omitted, it also stops with an error message. In these free-form
cases, neither the degree program nor the manually supplied thesis type is localized by the
template.

To omit acknowledgments, remove the `acknowledgments` argument. To omit the abstract, remove
the `abstract` argument.

To use German labels throughout the template, set the document language before the `#show`
rule:

```typst
#set text(lang: "de")
```


## Licenses

The Typst source files are released under an MIT-0 license.

The [Open Sans](https://fonts.google.com/specimen/Open+Sans) font is Copyright 2020 by The
Open Sans Project Authors and distributed under the
[SIL Open Font License 11](https://fonts.google.com/specimen/Open+Sans/license).

The Saarland University and LST logos in `logos/` are trademarks of their respective owners,
used with permission, and are not covered by the package license.
