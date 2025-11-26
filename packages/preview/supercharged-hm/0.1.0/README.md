# HM Typst Template

Unofficial [Typst](https://typst.app/) template for students of Hochschule München (HM).

This repository contains a reusable layout for theses, reports and project documentation, together with a small set of helper functions for acronyms, notes, tables, requirements and code listings.

You can find an example PDF of how the template looks in the `examples` directory of this repository.

To see a minimal example of how you can use this template, check out the `main.typ` file.  
More examples can be added under `examples/` as needed.

## Contributing

If you want to contribute to this template, please open an issue describing the problem or the feature you would like to add.

If you already prepared a pull request, it still helps a lot to have a short issue that explains the motivation and the intended behaviour in your own words.

## Usage

You can use this template in two ways.

### 1. Typst Universe

Once the template is published to Typst Universe you can start a new project directly from the web app:

1. Open the Typst web app.
2. Click “Start from template”.
3. Search for `hm-template` (or the final published name of this template).

Using the CLI you will be able to initialize a new project with:

```shell
typst init @preview/hm-template
```

Typst will create a new directory with all the files needed to get you started.

### 2. Local import from this repository

If you work directly from this repository, import the template library file:

```typst
#import "/template/lib.typ": *
```

A minimal `main.typ` could look like this:

```typst
#import "/template/lib.typ": hm-template

#show: hm-template(
  title: [My Thesis Title],
  subtitle: [Optional Subtitle],
  doc_type: [Masterarbeit],
  authors: "Max Mustermann",
  language: "de",
  bibliography: bibliography("references.bib"),
  glossary: glossary,
  body: [
    = Introduction

    This is the first chapter.
  ],
)
```

> Adjust the import path to match your project structure.

## Fonts

By default the template uses:

- [Roboto](https://fonts.google.com/specimen/Roboto) as the main text font.

If you want to use Typst locally, download the font and install it on your system.  
In the web app you can upload the font to your project and then keep the default `font: "Roboto"` configuration.

For more information on how to add fonts to your project, see the [Typst documentation](https://typst.app/docs/reference/text/text/#parameters-font).

If you prefer a different font family, override the `font` argument of `hm-template`:

```typst
#show: hm-template(
  font: "Linux Libertine",
  ...
)
```

## Used Packages

This template uses the following Typst packages:

- [codelst](https://typst.app/universe/package/codelst): syntax highlighted code blocks

Code snippets are inserted through a small wrapper function `code`, which forwards to `sourcecode` from `codelst` with template specific defaults.

Example:

```typst
#figure(
  caption: "Example code.",
)[
  #code(
    ```py
    def example_function(a: int, b: int) -> int:
        print("Hello, World!")
        return a + b
    ```
  )
]
```

For inline colored code you can use the fenced syntax:

```typst
This calls ```py example_function(a, b)```.
```

## Configuration

This template exports the `hm-template` function with the following named arguments:

`title (content)`: Title of the document shown on the title page.

`subtitle (content)`: Optional subtitle printed below the title.

`doc_type (content)`: Type of the document, for example `Bachelorarbeit`, `Masterarbeit` or `Projektarbeit`.

`top-remark (content)`: Small remark printed at the top of the title page, for example a confidentiality note or internal document number.

`show-table-of-contents (bool)`: Whether the table of contents should be shown, default is `true`.

`toc-depth (int)`: Depth of the table of contents, default is `2`.

`appendix (content)`: Content of the appendix section. It is recommended to pass a variable or function that returns the appendix content.

`language (str)`: Language of the document, for example `"de"` or `"en"`, default is `"de"`.

`glossary (dictionary)`: Glossary and acronym definitions used by the `gls` and `glspl` helpers (see section “Glossary and Acronyms”).

`bibliography (content)`: Bibliography function, for example `bibliography("references.bib")`.

`bib-style (str)`: Bibliography style, default is `"ieee"`.

`font (str)`: Main text font, default is `"Roboto"`.

`version (str)`: Version string of the document or template, printed where appropriate, default is `"0.1"`.

`authors (content | str)`: Author or list of authors. This can be a simple string or a more complex piece of content if you want custom formatting.

`date (datetime)`: Date printed on the title page, default is `datetime.today()`.

`project_logo (content)`: Logo used inside the main document, for example in headers. Typical usage: `image("img/project-logo.pdf")`.

`project_logo_dimensions (array)`: Two element array `(width, height)` for the project logo, default is `(auto, auto)`.

`titlepage_logo (content)`: Logo for the title page. Typical usage: `image("img/university-logo.pdf")`.

`titlepage_logo_dimensions (array)`: Two element array `(width, height)` for the title page logo, default is `(auto, auto)`.

`lastpage (content)`: Optional custom last page, for example an imprint, declaration of authorship or additional legal text.

`text-size (length)`: Base text size for body text (not headers or footers), default is `12pt`.

`body (content*)`: Main content of the document. This is where your chapters go and is required.

Behind the arguments the type of the value is given in parentheses.  
Arguments marked with `*` are required for a useful document.

---

In most cases a thesis or report will at least provide:

- `title`
- `doc_type`
- `authors`
- `language`
- `bibliography`
- `glossary`
- `body`

## Glossary and Acronyms (Glossarium)

The template provides helper functions to work with a glossary and acronyms.

### Reference in text

Use the following helpers inside the text:

- `gls(key)`: Reference a glossary entry in singular form.  
  Example: `#gls("http")`
- `glspl(key)`: Reference a glossary entry in plural form.  
  Example: `#glspl("api")`

Both `#gls("http")` and the label reference `@http` behave consistently.  
Only the first occurrence of a term will be expanded to its long form, later occurrences show only the short form. For example:

```typst
Use the #gls("http") protocol for web traffic.

Later we simply write #gls("http") again without repeating the long form.
```

### Definition

You define the glossary once and pass it to the `glossary` argument of `hm-template`.

A typical structure looks like this:

```typst
#let glossary = (
  "http": (
    short: "HTTP",
    long: "Hypertext Transfer Protocol",
  ),
  "api": (
    short: "API",
    long: "Application Programming Interface",
  ),
)
```

Then pass the dictionary when calling the template:

```typst
#show: hm-template(
  glossary: glossary,
  ...
)
```

## Code, Raw Text and Inline Highlighting

### Block code with syntax highlighting

Use the `code` helper to show syntax highlighted blocks. It wraps `sourcecode` from `codelst` with template defaults.

```typst
#figure(
  caption: "Example code.",
)[
  #code(
    ```py
    def example_function(a: int, b: int) -> int:
        print("Hello, World!")
        return a + b
    ```
  )
]
```

### Inline colored code

For inline highlighted code use fenced language markers:

```typst
The function ```py example_function(a, b)``` prints a greeting.
```

### Inline colored monospace text

If you want monospaced text in a specific color, use `rgb_raw`:

```typst
#rgb_raw("MACHINE_ADAPTER", rgb("#13A256"))
```

This renders the identifier `MACHINE_ADAPTER` in monospace with the given RGB color.

## Notes

A small family of note helpers is available to draw attention to important remarks.

Available functions:

- `note(content)`: Neutral note box.
- `color-note(content, fg, bg)`: Note with custom foreground and background color.
- `warning-note(content)`: Warning style box.
- `good-note(content)`: Positive or success style box.

Example:

```typst
#stack(
  dir: ltr,
  spacing: 10pt,
  note("Note"),
  color-note("Color note", rgb("#2B82BD"), rgb("#c9dfec")),
  warning-note("Warning note"),
  good-note("Good note"),
)
```

Use these note styles sparingly to keep the document readable.

## Tables

For tables, the template provides a styled wrapper `styledtable` around Typst’s `table` function.

You can use it like this:

```typst
#figure(caption: [Example Table])[
  #styledtable(
    table(
      columns: (auto, auto, auto),
      table.header([*Platform*], [*Adapters*], [*Data*]),
      table.hline(),
      [Drone],[
        - wifi
        - lte
      ],[
        - Mission Data
        - Camera feed
        - Flight information
      ],
      [Car],[
        - LTE
      ],[
        - Route information
        - Maintenance Data
      ],
      [Truck],[
        - Lorawan
        - LTE
      ],[
        - Moving & rest times
        - Loading information
        - Maintenance Data
      ],
    )
  )
]
```

`styledtable` takes care of consistent strokes and alternating row backgrounds. You can override:

- `stroke`
- `background_odd`
- `background_even`

to adjust the look for your document.

## Requirements

The `requirements` helper renders grouped functional and non functional requirements in a consistent layout.

### Usage

```typst
#requirements(
  functional_chapter_description: [
    Functional requirements specify what functionality or behavior
    the resulting product under the specified conditions should have.
  ],
  functional: (
    (
      title: [Drone Connectivity],
      description: [The drone shall have connectivity to the server.],
      subrequirements: (
        (
          title: [LTE Connectivity],
          description: [Connectivity to the server shall be achieved via LTE.]
        ),
      ),
    ),
  ),

  non_functional_chapter_description: [
    Nonfunctional or technical requirements describe aspects regarding
    one or more functional requirements. In short, they specify how the
    product should work.
  ],
  nonfunctional: (
    (
      title: [Server Placement],
      description: [The drone server shall be placed in a remote data center.]
    ),
  ),
)
```

Below the rendered block, each requirement is assigned an identifier based on its title. You can reference them from the text like this:

- `@req_Drone_Connectivity`  
- `@req_functional`  
- `@req_nonfunctional`

Example sentence:

```typst
As specified in @req_Drone_Connectivity the system must maintain a link
to the backend server during flight.
```

This makes it easy to keep traceability between your requirements and the main text.
