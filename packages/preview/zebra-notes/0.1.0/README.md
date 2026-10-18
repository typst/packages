# Zebra Notes

[![Typst Package](https://img.shields.io/badge/Typst-Package-blue)](https://typst.app/universe/package/zebra-notes)

`zebra-notes` is an elegant, non-intrusive collaborative note-taking and task management tool for [Typst](https://typst.app/), providing a standardized way to mark tasks, notes, and comments in academic and technical documents. It is the non-official Typst port of the popular LaTeX package [zebra-goodies](https://github.com/xueruini/zebra-goodies).

## Features

- **Standardized Note Types**: Pre-defined `todo`, `note`, `zebracomment`, `fixed`, and `placeholder`.
- **Automatic Numbering**: Each note type maintains its own independent counter for easy tracking.
- **Visual Distinction**: Notes are styled to be visually distinct, perfect for collaborative editing.
- **Bilingual Friendly**: Designed to work seamlessly in both English and Chinese environments.
- **Summary Table**: Automatically generates a list of all active notes at the end of the document.
- **Production Ready**: Toggle a single line to hide all annotations for the final publication.

## Usage

Import the package and use the built-in note functions:

```typst
#import "@preview/zebra-notes:0.1.0": *

// Enable draft mode to show notes (enabled by default)
//#zebra-draft()

= Section with a note #todo("Check the math", assignee: "Author")

Here is a comment #zebracomment("Is this reference correct?", assignee: "Reviewer").

// Generate a summary table of all notes
#zebra-summary()

// Hide all notes for final version
//#zebra-final()
```

## Repository

The development of this package is independently hosted at:

[lartpang/zebra-notes](https://github.com/lartpang/zebra-notes)

## Acknowledgments

This package is a reimplementation of the LaTeX [`zebra-goodies`](https://github.com/xueruini/zebra-goodies) package by Ruini Xue. We chose the name `zebra-notes` for the Typst ecosystem to clearly describe its functionality while honoring its heritage.

## License

MIT License.
