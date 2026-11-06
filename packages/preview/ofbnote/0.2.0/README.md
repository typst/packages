# ofbnote
This is a Typst template to help formatting documents according to the French office for biodiversity design guidelines.

## Usage
You can use the CLI to kick this project off using the command
```
typst init @preview/ofbnote
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ofbnote` function with one named argument called `meta` which should be a dictionary of metadata for the document. The `meta` dictionary can contain the following fields:

- `title`: The document's title as a string or content.
- `authors`: The document's author(s) as a string.
- `date`: The document's date as a string or content.
- `version`: The document's version as a string.

It may contains other values, but they have no effect on the final document.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `ofbnote`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/ofbnote:0.2.0": *

#show: ofbnote.with( meta:(
  title: "My note",
  authors: "Me",
  date: "March 23rd, 2023",
  version: "1.0"
))

// Your content goes below.
```
