# bone-document
This is a Typst template.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `bone-documente`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/bone-document
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ieee` function with the following named arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `name` key and can have the keys `department`, `organization`,
  `location`, and `email`. All keys accept content.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `bone-document`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/bone-document:0.1.0": bone-document

#show: bone-document.with(
  title: [A Document Templete],
  author: "六个骨头"
)

= Introduction
A Document Templete.

// Your content goes below.
```
