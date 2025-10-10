# Sheen ID - Typst Book Template

A flexible and feature-rich Typst template designed for creating books. It provides a structured set of functions to handle covers, title pages, tables of contents, headers, footers, and chapter styling.

## Features

  - **Customizable Configuration**: Easily change the theme color, page margins, and fonts.
  - **Automated Covers**: Generate full-page color and grayscale covers from an image.
  - **Structured Content**: Functions for creating a title page, table of contents, list of figures, and list of equations.
  - **Dynamic Headers & Footers**: Automatically populates with the book title and chapter titles.
  - **Styled Chapter Pages**: A dedicated function to create beautiful chapter introduction pages with an image and learning objectives.
  - **Pre-styled Elements**: Comes with clean, pre-defined styles for figures, tables, code blocks, math equations, and lists.
  - **Helper Utilities**: Includes a `noindent` function to easily manage paragraph indentation.

-----

## Quick Start

To use this template, import the `sheen-id` package and use its functions to structure your document.

**`main.typ`**

```typst
// 1. Import all functions from the sheen-id package
#import "@preview/sheen-id:0.1.0": *

// 2. Apply the main configuration
#show: doc => conf(
  color: green, // Set the theme color
  doc
)

// 3. Set global images (optional)
#set-chapter-image("path/to/chapter-default.png")
#set-cover("path/to/cover-image.png")

// 4. Create front matter
#make-cover() // or #make-gray-cover()
#make-title(
  title: [My Awesome Book],
  author: [Your Name],
  gap: 4.5in // Optional vertical space
)

// 5. Apply headers and footers to the rest of the document
#show: doc => make-header-footer(doc)

// 6. Generate tables of contents
#make-toc() // Table of Contents
#make-toi() // Table of Images (Figures)
#make-toe() // Table of Equations

// 7. Apply main paragraph styling for the body
#show: doc => make-paragraph(doc)

// 8. Write your content
#include "chapters/chapter1.typ"
#include "chapters/chapter2.typ"
// ... and so on
```

**`chapters/chapter1.typ`**

```typst
// Import all functions from the sheen-id package
#import "@preview/sheen-id:0.1.0": *

#chapter(
  title: [Introduction to Topic],
  objectives: [
    - Understand the basics.
    - Learn key concepts.
    - Prepare for the next chapter.
  ]
)

== My First Section

Here is the main content of the chapter...
```

-----

## API Reference

### Configuration

`#conf(color: blue, doc)`
The main show rule to apply document-wide settings.

  - `color`: Sets the primary theme color for elements like headings and boxes.
  - `doc`: The document body to apply the settings to.

-----

### Page Setup Functions

`#set-cover(path)`
Sets the image to be used by `make-cover()` and `make-gray-cover()`.

  - `path`: A string path to your cover image.

`#set-chapter-image(path)`
Sets the default image used on chapter introduction pages created with `chapter()`.

  - `path`: A string path to the chapter image.

`#make-cover()`
Creates a full-page, full-color cover using the image set by `set-cover()`.

`#make-gray-cover()`
Creates a full-page, grayscale version of the cover.

`#make-title(title:, author:, gap: 5in)`
Generates a text-based title page.

  - `title`: The title of the book.
  - `author`: The author's name.
  - `gap`: (Optional) The amount of vertical space between the title and author.

`#make-header-footer(img-path: none, doc)`
A show rule that applies headers and footers to the `doc`.

  - `img-path`: (Optional) A path to a small image to display in the footer.
  - `doc`: The document body.

-----

### Outline Functions

`#make-toc()`
Generates a "Table of Contents" page.

`#make-toi()`
Generates a "List of Figures" page.

`#make-toe()`
Generates a "List of Equations" page.

-----

### Content Functions

`#make-paragraph(doc)`
A show rule that applies the main body styling (justification, indentation, etc.) to the `doc`.

`#chapter(title:, objectives:)`
Creates a styled chapter introduction page. Best used at the start of an included chapter file.

  - `title`: The title for the chapter.
  - `objectives`: Content (usually a list) detailing the chapter's learning goals.

`#noindent(content)`
A helper function to wrap content that should not have a first-line indent.

-----

## Dependencies

This template relies on the following external Typst packages, which will be fetched automatically when you compile your document:

  - `@preview/i-figured:0.2.4`
  - `@preview/grayness:0.3.0`
  - `@preview/hydra:0.6.2`
  - `@preview/showybox:2.0.4`
