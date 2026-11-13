# ‘Ilm

> ‘Ilm (Urdu: عِلْم) is the Urdu term for knowledge. It is pronounced as [/ə.ləm/](https://en.wiktionary.org/wiki/%D8%B9%D9%84%D9%85#Urdu).

A versatile, clean and minimal template for non-fiction writing. The template is ideal for
class notes, reports, and books.

It contains a title page, a table of contents, and indices for different types of figures;
images, tables, code blocks.

Dynamic running footer contains the title of the chapter (top-level heading).

See the [example.pdf](https://github.com/talal/ilm/blob/v3.0.0/example.pdf) file to see how it looks.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `ilm`.

Alternatively, you can use the CLI to kick this project off using the command:

```sh
typst init @preview/ilm
```

Typst will create a new directory with all the files needed to get you started.

The template will initialize your package with a sample call to the `ilm` function in a
show rule. If you, however, want to change an existing project to use this template, you
can add a show rule like this at the top of your file:

```typ
#import "@preview/ilm:3.0.0": *

#set text(lang: "en")

#show: ilm.with(
  title: [Your Title],
  authors: "Max Mustermann",
  abstract: [#lorem(30)],
)

#cover-page()

#outline()

// Your content goes here.
```

This template uses [IBM Plex Mono] for raw text (inline code and code blocks) and [Lato] for headings. Both fonts are available in the Typst web app. When compiling locally, install these fonts on your system so the template looks exactly as designed. Otherwise, it will fall back to default fonts, which don’t look as good.

## Configuration

The template exports the `ilm` function with several named arguments (read: options). This function also accepts a single, positional argument for the body.

> The language setting for text (`lang` parameter of `text` function) should be
> defined before the `ilm` function so that headings such as table of contents and
> bibliography will be defined as per the text language. See example above.

### Options

The list below shows a _brief description_ for each option. For a detailed explanation of these options, see the [example.pdf](https://github.com/talal/ilm/blob/v3.0.0/example.pdf) file.

- `title`\
  type: [content]\
  default: `[Your Title]`\
  description: The title for your work.

- `authors`\
  type: `none`, [string], or [array]\
  default: `("Author Name",)`\
  description: The author(s) of your work. Set to `none` or `()` to omit authors from the cover page. A string represents a single author; an array displays authors on separate lines with font size automatically scaled.

- `paper-size`\
  type: [string]\
  default: `"a4"`\
  description: Specify a [paper size string] to change the page size.

- `date`\
  type: [datetime] or `none`\
  default: `datetime.today()`\
  description: The date that will be displayed on the cover page. Set to `none` to disable date.

- `date-format`\
  type: [string]\
  default: `"[month repr:long] [day padding:zero], [year repr:full]"`\
  description: The format for the date that will be displayed on the cover page. By default, the date will be displayed as `MMMM DD, YYYY`.

- `abstract`\
  type: [content] or `none`\
  default: `none`\
  description: A brief summary/description of your work. This is shown on the cover page. Set to `none` to disable.

- `chapter-pagebreak`\
  type: [bool]\
  default: `true`\
  description: Setting this to `false` will prevent numbered chapters from starting on a new page.

- `external-link-circle`\
  type: [bool]\
  default: `true`\
  description: Setting this to `false` will disable the maroon circle that is shown next to external links.

- `footer`\
  type: [string] or `none`\
  default: `"page-number-alternate-with-chapter"`\
  description: Footer style for page numbering. Set to `none` to disable footer entirely. Available styles: `"page-number-alternate-with-chapter"` (alternating sides with chapter name), `"page-number-left-with-chapter"`, `"page-number-right-with-chapter"`, `"page-number-center"`, `"page-number-left"`, `"page-number-right"`.

### Components & Functions

'Ilm exports several standalone functions and components to compose your document:

- `cover-page()`\
  Displays the cover/title page using metadata (`title`, `authors`, `date`, `date-format`, `abstract`) configured in `ilm`.

- `appendix(body)`\
  Applies appendix styling to headings within `body`. It resets the heading counter, switches to alphabetical numbering (`A.1`), and sets the supplement to `[Appendix]`. Can be used as a container (`#appendix[...]`) or as a show rule (`#show: appendix`).

- `list-of-figures(..args)`\
  Renders an outline of figure images. Accepts any parameter supported by Typst's [`outline`][outline]. Defaults to `title: [List of Figures]`.

- `list-of-tables(..args)`\
  Renders an outline of figure tables. Accepts any parameter supported by Typst's [`outline`][outline]. Defaults to `title: [List of Tables]`.

- `list-of-listings(..args)`\
  Renders an outline of raw/code blocks. Accepts any parameter supported by Typst's [`outline`][outline]. Defaults to `title: [List of Listings]`.

- `blockquote(body)`\
  Renders `body` styled as an indented, highlighted blockquote.

- `smallcaps(body, all: false)`\
  Displays small caps with tuned letter tracking, wrapping Typst's `std.smallcaps`.

- `upper(body)`\
  Displays uppercase text with tuned letter tracking, wrapping Typst's `std.upper`.

[array]: https://typst.app/docs/reference/foundations/array/
[bool]: https://typst.app/docs/reference/foundations/bool/
[content]: https://typst.app/docs/reference/foundations/content/
[datetime]: https://typst.app/docs/reference/foundations/datetime/
[ibm plex mono]: https://www.ibm.com/plex/
[lato]: https://www.latofonts.com/
[outline]: https://typst.app/docs/reference/model/outline/
[paper size string]: https://typst.app/docs/reference/layout/page#parameters-paper
[string]: https://typst.app/docs/reference/foundations/str/
