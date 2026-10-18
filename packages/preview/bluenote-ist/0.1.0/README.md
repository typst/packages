# touying-ist

A Touying-based seminar slide template for the Institute of Science Tokyo.

## Usage

### Start a new project

```bash
typst init @preview/touying-ist:0.1.0
```

The generated project contains:

- `main.typ` as the entry file
- `ppt-config.typ` for title, author, and contact information
- `sections.typ` for slide content
- `imgs/` for editable assets

### Import into an existing project

```typst
#import "@preview/touying-ist:0.1.0": *

#show: ist-theme.with(
  config-info(
    title: [Monthly Seminar],
    subtitle: [Department Research Update],
    author: [Your Name],
    date: datetime.today(),
    institution: [Institute of Science Tokyo],
  ),
)

#title-slide()
#outline-slide(title: none, level: 2, indent: 1em)

= Overview
== Motivation

Your content here.
```

## Local Development

Compile the local example in this repository with:

```bash
typst compile main.typ
```

To export to PowerPoint with the Touying CLI:

```bash
pip install touying
touying compile main.typ --format pptx
```

## License

Licensed under the [MIT License](LICENSE).
