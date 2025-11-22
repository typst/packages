# wonderous-book
A book template for fiction. The template contains a title page, a table of contents, and a chapter template.

Dynamic running headers contain the title of the chapter and the book.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `wonderous-book`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/wonderous-book
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `book` function with the following named arguments:

- `title`: The book's title as content.
- `author`: Content or an array of content to specify the author.
- `paper-size`: Defaults to `iso-b5`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
- `dedication`: Who or what this book is dedicated to as content or `none`. Will
  appear on its own page.
- `publishing-info`: Details for the front matter of this book as content or
  `none`.

The function also accepts a single, positional argument for the body of the
book.

The template will initialize your package with a sample call to the `book`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/wonderous-book:0.1.1": book

#show: book.with(
  title: [Liam's Playlist],
  author: "Janet Doe",
  dedication: [for Rachel],
  publishing-info: [
    UK Publishing, Inc. \
    6 Abbey Road \
    Vaughnham, 1PX 8A3

    #link("https://example.co.uk/")

    971-1-XXXXXX-XX-X
  ],
)

// Your content goes below.
```
