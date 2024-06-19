# ‘Ilm Catppuccin

> ‘Ilm (Urdu: عِلْم) is the Urdu term for knowledge. It is pronounced as [/ə.ləm/](https://en.wiktionary.org/wiki/%D8%B9%D9%84%D9%85#Urdu).

A versatile, clean and minimal template for non-fiction writing. The template is ideal for
class notes, reports, and books (with the catppuccin color pallette).

It contains a title page, a table of contents, and indices for different types of figures;
images, tables, code blocks.

Dynamic running footer contains the title of the chapter (top-level heading).

See the [example.pdf](https://github.com/Quantalabs/ilm/blob/main/example.pdf) file to see how it looks.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `ilm-catppuccin`.

Alternatively, you can use the CLI to kick this project off using the command

```sh
typst init @preview/ilm-catppuccin
```

Typst will create a new directory with all the files needed to get you started.

This template uses the [Iosevka] font for raw text. In order to use Iosevka, the font must
be installed on your computer. In case Iosevka is not installed, as will be the case for
Typst Web App, then the template will fall back to the default "Fira Mono" font.

## Configuration

This template exports the `ilm` function with the following named arguments:

| Argument | Default Value | Type | Description |
| --- | --- | --- | --- |
| `title` | `Your Title` | [content] | The title for your work. |
| `author` | `Author` | [content] | A string to specify the author's name |
| `paper-size` | `a4` | [string] | Specify a [paper size string] to change the page size. |
| `date` | `none` | [datetime] | The date that will be displayed on the cover page. |
| `date-format` | `[month repr:long] [day padding:zero], [year repr:full]` | [string] | The format for the date that will be displayed on the cover page. By default, the date will be displayed as `MMMM DD, YYYY`. |
| `abstract` | `none` | [content] | A brief summary/description of your work. This is shown on the cover page. |
| `preface` | `none` | [content] | The preface for your work. The preface content is shown on its own separate page after the cover. |
| `table-of-contents` | `outline()` | [content] | The result of a call to the [outline function][outline] or none. Setting this to `none` will disable the table of contents. |
| `bibliography` | `none` | [content] | The result of a call to the [bibliography function][bibliography] or none. Specifying this will configure numeric, IEEE-style citations. |
| `chapter-pagebreak` | `true` | [bool] | Setting this to `false` will prevent chapters from starting on a new page. |
| `figure-index` | `(enabled: false, title: "Index of Figures")` | [dictionary] | Setting this to `true` will display a index of image figures at the end of the document. |
| `table-index` | `(enabled: false, title: "Index of Tables")` | [dictionary] | Setting this to `true` will display a index of table figures at the end of the document. |
| `listing-index` | `(enabled: false, title: "Index of Listings")` | [dictionary] | Setting this to `true` will display a index of listing (code block) figures at the end of the document. |

> [!NOTE]
> The language setting for text (`lang` parameter of `text` function) should be defined before the `ilm` function so that headings such as table of contents and bibliography will be defined as per the text language.

The function also accepts a single, positional argument for the body.

The template will initialize your package with a sample call to the `ilm` function in a
show rule. If you, however, want to change an existing project to use this template, you
can add a show rule like this at the top of your file:

```typ
#import "@preview/ilm-catppuccin:1.1.2": *

#show: ilm.with(
  title: [Your Title],
  author: "Max Mustermann",
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [],
  preface: [],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

// Your content goes below.
```

[iosevka]: https://typeof.net/Iosevka/
[bibliography]: https://typst.app/docs/reference/model/bibliography/
[outline]: https://typst.app/docs/reference/model/outline/
[bool]: https://typst.app/docs/reference/foundations/bool/
[content]: https://typst.app/docs/reference/foundations/content/
[datetime]: https://typst.app/docs/reference/foundations/datetime/
[dictionary]: https://typst.app/docs/reference/foundations/dictionary/
[paper size string]: https://typst.app/docs/reference/layout/page#parameters-paper
[string]: https://typst.app/docs/reference/foundations/str/
