# Benplate

A [Typst](https://typst.app/) template for final theses, term papers and similar documents that can be easily customized to fit the requirements of your institution.

## Getting Started

You can use this template in the Typst web editor by clicking "Start from Template" on the dashboard and searching for `benplate`.

In case you're using Typst locally, you can use the CLI to initialize a project using this template with the following command:

```
typst init @preview/benplate my-thesis
```

This will create a new directory called `my-thesis` with a basic project structure. This also includes the default configuration for the title page and other frontmatter elements.

## Fonts

This template uses the following selection of fonts:

- [IBM Plex Serif](https://fonts.google.com/specimen/IBM+Plex+Serif)
- [IBM Plex Sans](https://fonts.google.com/specimen/IBM+Plex+Sans)
- [IBM Plex Mono](https://fonts.google.com/specimen/IBM+Plex+Mono)
- [Libertinus Math](https://github.com/alerque/libertinus)
- [New Computer Modern Math](https://ctan.org/pkg/newcomputermodern) (ships with Typst, used for script letters and integral signs, and as a fallback if Libertinus Math isn't installed)

If you use this template locally, you can install the fonts on your system via the links above. In case you're using the Typst web app, all fonts are available out of the box. All fonts can also be changed via the arguments of the `thesis` function.

## Usage

This template exports the `thesis` function, which takes the following named arguments:

- `title (str)`: The title of the document.
- `author (str)`: The author of the document.
- `date (datetime)`: The creation date of the document. If not explicitly specified, `datetime.today()` is used.
- `lang (str)`: The language of the document, used for hyphenation and Typst's built-in terms. Defaults to `"en"`.
- `body-font (str)`: The font of the body text. Defaults to `"IBM Plex Sans"`.
- `heading-font (str)`: The font of chapter headings and the title. Defaults to `"IBM Plex Serif"`.
- `caption-font (str, auto)`: The font of figure captions. Defaults to `auto`, which uses the `body-font`.
- `math-font (str, array)`: The font of equations, or a list of fonts to try in order. Defaults to the exported `math-font`, which uses Libertinus Math with script letters from New Computer Modern Math.
- `code-font (str)`: The font of raw text and code listings. If it isn't installed, `DejaVu Sans Mono` is used. Defaults to `"IBM Plex Mono"`.
- `body-size (length)`: The size of the body text. Defaults to `11pt`.
- `accent-color (color)`: The color of links, citations and references to figures, equations and sections. Defaults to the exported `accent-color`.
- `print (bool)`: Whether the document is laid out for printing. If `true`, the inner margin is wider than the outer one to leave room for the binding. If `false`, the text is centered on the page, which is easier to read on a screen. The line and page breaks are the same in both cases. Defaults to `false`.

  The template's `main.typ` reads this setting from the command line, so you can create both versions of your document without editing it:

  ```sh
  typst compile main.typ thesis-digital.pdf
  typst compile main.typ thesis-print.pdf --input print=true
  ```

  In the Typst web app, where no inputs can be passed, the text is centered on the page unless you replace the line with `print: true`.
- `frontmatter (content)`: All content that should be included in front of the first chapter of the document.
- `appendix (content)`: Optional content for the documents appendix.
- `backmatter (content)`: All content that should be included at the end of the document.

While both the `frontmatter` and `backmatter` can take arbitrary content, the template also provides functions that provide a default configuration.

### Frontmatter

To start off, I recommend using the `default-frontmatter` function to generate default configuration for the frontmatter. If you are interested in truly making this template your own, you can check out the [customization section](#customization). `default-frontmatter` takes the following arguments:

- `university (str)`: The name of your University.
- `faculty (str)`: The responsible faculty for your study.
- `field (str)`: Your field of study.
- `type (str)`: The type of document you're writing (e.g., Bachelor's Thesis, Master's Thesis, PhD Thesis).
- `author (str)`: Your name.
- `date (datetime)`: The submission date of the document. If not explicitly specified, `datetime.today()` is used.
- `city (str)`: The city where the document was submitted.
- `advisor (str)`: The name of your advisor.
- `first-reviewer (str)`: The name of your first reviewer.
- `second-reviewer (str)`: The name of your second reviewer.
- `accent-color (color)`: The color of the university name on the title page. Pass the same color as to `thesis`.
- `date-format (str)`: The [format](https://typst.app/docs/reference/foundations/datetime/#format) of the dates on the title page and in the declaration. Defaults to `"[day].[month].[year]"`.
- `abstract (content)`: The abstract of the document.
- `acknowledgments (content)`: The acknowledgments of the document.

### Backmatter

Similar to the `frontmatter`, the backmatter can also be configured using the `default-backmatter` function, taking the following arguments:

- `bibliography (content)`: The bibliography of the document. This should be set to Typst's default `bibliography` with the path to your bibliography file as an argument.
- `bib-style (str)`: The bibliography and citation style this document should use. Defaults to `"ieee"`.

### Customization

I created the default functions above so that the final document adheres to certain requirements of my university. However, other institutions may impose different rules, or maybe you want to customize the document to fit your own style.

For that reason, the `default-frontmatter` and `default-backmatter` functions are not part of the package itself. Their implementation is copied into your project when you initialize it as explained in the [getting started section](#getting-started). This should make it relatively straightforward to change these parts of the document.

Fonts, the text size, the accent color, the language and the print layout can be changed via the arguments of the `thesis` function. In case you want to customize the other parts of the template, like paragraph spacing, heading styles, etc., you need to edit the template locally. This can be done by locating your [typst data directory](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) and copying the contents of [this repository](https://github.com/Nasenbaer39/benplate) to `{data-dir}/typst/packages/local/benplate/0.2.0`. This will create a local copy of this template that you are free to edit.

If you believe that there are configuration options that should be available from the get go, feel free to open an issue on GitHub. This of course also applies to potential inconsistencies or bugs in the template.

## Utilities

In addition to functions that define the style of the document, this template also provides a couple of utility functions with the goal to streamline the writing process.

### TODO Tools

First, the template provides three wrappers around functions of the [drafting](https://typst.app/universe/package/drafting) package, which can be used to annotate parts of the document.

The `todo` function creates a colored box around the content you provide it with. Optionally, you can also specify a `color` and a `label` for the box, with default values of `yellow` and `"TODO"`, respectively.

```typ
#import "@preview/benplate:0.2.0": todo

#todo[This is a TODO box]
#todo(color: red, label: "ERROR")[This is a custom ERROR box]
```

The `note` function creates a box in the margins of the document, connecting to the place where it is used. Optionally, you can also specify a `color` for the box, with a default value of `red`.

```typ
#import "@preview/benplate:0.2.0": note

#note[Something really important that should be addressed]
```

The `comment` function draws a colored box around the content it is provided with, inline with the surrounding text. Optionally, you can also specify the `initials` of the person making the comment, which are shown in front of the box, and a `color`, with a default value of dark blue.

```typ
#import "@preview/benplate:0.2.0": comment

#comment(initials: "DS", color: green)[This is a comment]
```

All the functions that ship with the drafting package are also available via the template. An especially useful one is `note-outline()`, which creates a list with links to all drafting notes in the document. All other functions can be found in [draftings documentation](https://typst.app/universe/package/drafting).

### Subfigures

Subfigures can be created using the `subfigure` function. Its usage is exactly the same as the [default figure function](https://typst.app/docs/reference/model/figure/). To work properly, it has to be placed inside the body of a `figure`.

```typ
#import "@preview/benplate:0.2.0": subfigure

#figure(
  grid(
    columns: 2,
    [#subfigure(caption: [First subfigure caption])[First subfigure content] <first>],
    [#subfigure(caption: [Second subfigure caption])[Second subfigure content] <second>],
  ),
  caption: [Caption for the entire figure]
)
```

By assigning a unique identifier to each subfigure, they can also be referenced later in the document like regular figures, which displays them as, e.g., "Figure 1.1a".

### Helper Functions

The `prose` function is a shorthand to create a citation with the prose format.

```typ
#import "@preview/benplate:0.2.0": prose

// The following lines are equivalent
#prose[@some-citation]
#cite(form: "prose", <some-citation>)
```

## Used Packages & Inspiration

This template uses the following packages:

- [hydra](https://typst.app/universe/package/hydra): To display the current chapter and section in the header.
- [outrageous](https://typst.app/universe/package/outrageous): To style the outline in the `default-frontmatter`.
- [drafting](https://typst.app/universe/package/drafting): To create various kinds of comments and notes.

Aside from that, this template is inspired by the [IPLeiria Thesis](https://github.com/joseareia/ipleiria-thesis) LaTeX template.
Many design decisions and also parts of this README are based on the [clean-dhbw template](https://typst.app/universe/package/clean-dhbw).
