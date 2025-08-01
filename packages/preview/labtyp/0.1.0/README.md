# `labtyp`

`labtyp` is a package that allows using typst for labelling text documents like dialogue threads or legal documents for precise citing.

A json file with the labels in a document can be produced using `typst query`:

```bash
typst query main.typ <lab> > doclabels.json
```
Which can then be translated into `hayagriva` or `biblatex` formats.

`labtyp` defines 3 commands:

- `lab`: creates an in-place label, defined by key, text, note
- `mset`: adds metadata that gets assigned to _subsequent labels_ (i.e. labels defined below the current mset command in the document), like the title of the document, date, pagenumber in the original document, this can be expanded with any key
- Each label ends up being a concatenation of the label information, and the mset information.
- `lablist`: prints a table of the labels created

## Installation

### Local Installation
1. Place the package in:
- Linux/macOS: `~/.local/share/typst/packages/local/labtyp/0.1.0`
- Windows: `%APPDATA%\typst\packages\local\labtyp\0.1.0`
2. Import in your document:
```typ
#import "@local/labtyp:0.1.0": mset, lab, lablist
```

## Test document
```typst
#import "@local/labtyp:0.1.0": mset, lab, lablist

#mset(values: (
title: "My Document",
author: "John Doe",
date: "2025-07-31"
))

= Heading
== Subheading
This is some text.

#lab("key", "Highlighted text", "This is a note") // Creates underlined text and footnote

#mset(values: (date: "2025-08-01")) // Redefine date for subsequent labels
= Another Heading
#lab("key2", "More text", "Another note")

= List of Labels
#lablist() // Displays a table of all labels with hyperlinks
```
