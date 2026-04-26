# Typst note template

Simple and Functional Typst Note Template

This template is designed for efficient and organized note-taking with Typst. It provides a clean and straightforward structure, making it easy to capture and organize your thoughts without unnecessary complexity.

## Usage

```typ
#import "@preview/xyznote:0.4.0": *

#show: xyznote.with(
  title: "xyznote",
  author: "wardenxyz",
  abstract: "A simple typst note template",
  createtime: "2024-11-27",
  lang: "zh",
  bibliography-style: "ieee",
  preface: [], //Annotate this line to delete the preface page.
  bibliography-file: bibliography("refs.bib"), //Annotate this line to delete the bibliography page.
)
```

## Features

- **PDF Metadata**: Includes fields for title, author and date.

- **Table of Contents**: Automatically generated ToC for easy navigation through the document.

- **References (Optional)**: A dedicated section for citing sources and references. Include this only if you need it.

## Custom styles

```typ
#tipbox[
  contents
]
```

```typ
#markbox[
  contents
]
```

```typ
#sectionline
```

```typ
This is #highlight(fill: blue.C)[highlighted in blue].

This is #highlight(fill: yellow.C)[highlighted in yellow].

This is #highlight(fill: green.C)[highlighted in green].

This is #highlight(fill: red.C)[highlighted in red].
```

```typ
#brainstorming[
  This is a brainstorming.
]
```

```typ
#definition[
  This is a definition.
]
```

```typ
#question[
  This is a question.
]
```

```typ
#task[
  This is a task.
]
```

```typ
#brainstorming(lang: "zh")[
  This is a brainstorming.
]
```

```typ
#definition(lang: "zh")[
  This is a definition.
]
```

```typ
#question(lang: "zh")[
  This is a question.
]
```

```typ
#task(lang: "zh")[
  This is a task.
]
```

## Edit in the vscode(Recommended)

1. Install the [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension in VS Code, which provides syntax highlighting, error checking, and PDF preview

2. Start the project

```bash
typst init @preview/xyznote:0.4.0
```

```bash
cd xyznote
```

```bash
code .
```

3. Press `Ctrl+K V` to open the PDF preview

4. Click `Export PDF` at the top of the Typst file to export the PDF.

## Edit in the Webapp

Click the `Create project in app` button on the right to edit within the Webapp.

## Acknowledgments

The following projects have been instrumental in providing substantial inspiration and code for this project.

https://github.com/gRox167/typst-assignment-template

https://github.com/DVDTSB/dvdtyp

https://github.com/a-kkiri/SimpleNote

https://github.com/spidersouris/touying-unistra-pristine