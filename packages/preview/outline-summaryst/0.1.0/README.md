# outline-summaryst

## Description

`outline-summaryst` is a basic template designed for including a summary for each entry in the table of contents, particularly useful for writing books. It provides a simple structure for organizing content and generating formatted documents with summary sections.

## Features

- Generates a summary for each entry in the table of contents.
- Allows customization of title, subtitle, author, and foreword sections.
- Macros for creating new headings.

## Example Usage:
```
#import "@preview/outline-summaryst:0.1.0": outline-summaryst, make-heading


#show: outline-summaryst.with(
  title: "Insert Title Here",
  subtitle: "Insert Subitle Here",
  author: "Author Name",
  foreword-name: "Foreword",
  foreword-contents: [
    Insert foreword here...
  ],
)

#make-heading("Part One", "This is the summary for part one")
#lorem(500)

#make-heading("Chapter One", "Summary for chapter one in part one", level: 2)
#lorem(300)

#make-heading("Chapter Two", "This is the summary for chapter two in part one", level: 2)
#lorem(300)

#make-heading("Part Two", "And here we have the summary for part two")
#lorem(500)

#make-heading("Chapter One", "Summary for chapter one in part two", level: 2)
#lorem(300)

#make-heading("Chapter Two", "Summary for chapter two in part two", level: 2)
#lorem(300)
```

## Note:
Because of the way the project is implemented, headings created with the default `= Heading` syntax will not show in the document nor the Table of Contents. 

Only headings created with the provided `make-heading("heading name", "summary")` are shown.

## License:
This project is licensed under the MIT License. See the LICENSE file for details.

## Contribution:
Contributions are welcome! Feel free to open an issue or submit a pull request on GitHub.


