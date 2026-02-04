# ‘Ilm

> ‘Ilm (Urdu: عِلْم) is the Urdu term for knowledge. It is pronounced as [/ə.ləm/](https://en.wiktionary.org/wiki/%D8%B9%D9%84%D9%85#Urdu).

A versatile, clean and minimal template for non-fiction writing. The template is ideal for
class notes, reports, and books.

It contains a title page, a table of contents, and indices for different types of figures;
images, tables, code blocks.

Dynamic running footer contains the title of the chapter (top-level heading).

See the [example.pdf](https://github.com/talal/ilm/blob/main/example.pdf) file to see how it looks.

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
#import "@preview/ilm:2.0.0": *

#set text(lang: "en")

#show: ilm.with(
  title: [Your Title],
  authors: "Max Mustermann",
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [#lorem(30)],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

// Your content goes below.
```

> [!NOTE]
> This template uses the [Iosevka] font for raw text. In order to use Iosevka,
> the font must be installed on your computer. In case Iosevka is not installed, as will be
> the case for Typst Web App, then the template will fall back to the default "Fira Mono"
> font.

## Configuration

This template exports the `ilm` function with the following named arguments:

| Argument (type) | Default Value | Description |
| --- | --- | --- |
| `cover-page` ([string], [content], or `none`) | `"use-ilm-default"` | Cover page customization. Set to `"use-ilm-default"` for the default cover page, `none` to skip the cover page, or provide custom content to create your own cover page. |
| `title` ([content]) | `Your Title` | The title for your work. |
| `authors` ([string] or [array]) | `none` | The author(s) of your work. Can be a string for a single author or an array of strings for multiple authors. Multiple authors will be displayed on separate lines with font size automatically scaled. |
| `paper-size` ([string]) | `a4` | Specify a [paper size string] to change the page size. |
| `date` ([datetime]) | `none` | The date that will be displayed on the cover page. |
| `date-format` ([string]) | `[month repr:long] [day padding:zero], [year repr:full]` | The format for the date that will be displayed on the cover page. By default, the date will be displayed as `MMMM DD, YYYY`. |
| `abstract` ([content]) | `none` | A brief summary/description of your work. This is shown on the cover page. |
| `preface` ([content]) | `none` | The preface for your work. The preface content is shown on its own separate page after the cover. |
| `chapter-pagebreak` ([bool]) | `true` | Setting this to `false` will prevent chapters from starting on a new page. |
| `external-link-circle` ([bool]) | `true` | Setting this to `false` will disable the maroon circle that is shown next to external links. |
| `footer` ([string] or `none`) | `"page-number-alternate-with-chapter"` | Footer style for page numbering. Set to `none` to disable footer entirely. Available styles: `"page-number-alternate-with-chapter"` (alternating sides with chapter name), `"page-number-left-with-chapter"`, `"page-number-right-with-chapter"`, `"page-number-center"`, `"page-number-left"`, `"page-number-right"`. |
| `raw-text` ([string] or [dictionary]) | `(font: ("Iosevka", "Fira Mono"), size: 9pt)` | Customize raw text (code) styling. Set to `"use-typst-default"` to use Typst's default formatting, or provide a dictionary with `font` and `size` keys to customize. |
| `table-of-contents` ([content]) | `outline()` | The result of a call to the [outline function][outline] or none. Setting this to `none` will disable the table of contents. |
| `appendix` ([dictionary]) | `(enabled: false, title: "Appendix", heading-numbering-format: "A.1.1.", body: none)` | Setting `enabled` to `true` and defining your content in `body` will display the appendix after the main body of your document and before the bibliography. |
| `bibliography` ([content]) | `none` | The result of a call to the [bibliography function][bibliography] or none. Specifying this will configure numeric, IEEE-style citations. |
| `figure-index` ([dictionary]) | `(enabled: false, title: "Index of Figures")` | Setting this to `true` will display an index of image figures at the end of the document. |
| `table-index` ([dictionary]) | `(enabled: false, title: "Index of Tables")` | Setting this to `true` will display an index of table figures at the end of the document. |
| `listing-index` ([dictionary]) | `(enabled: false, title: "Index of Listings")` | Setting this to `true` will display an index of listing (code block) figures at the end of the document. |

The above table gives you a _brief description_ of the different options that you can
choose to customize the template. For a detailed explanation of these options, see the
[example.pdf](https://github.com/talal/ilm/blob/main/example.pdf) file.

The function also accepts a single, positional argument for the body.

> [!NOTE]
> The language setting for text (`lang` parameter of `text` function) should be
> defined before the `ilm` function so that headings such as table of contents and
> bibliography will be defined as per the text language.

[bibliography]: https://typst.app/docs/reference/model/bibliography/
[bool]: https://typst.app/docs/reference/foundations/bool/
[content]: https://typst.app/docs/reference/foundations/content/
[datetime]: https://typst.app/docs/reference/foundations/datetime/
[dictionary]: https://typst.app/docs/reference/foundations/dictionary/
[iosevka]: https://typeof.net/Iosevka/
[outline]: https://typst.app/docs/reference/model/outline/
[paper size string]: https://typst.app/docs/reference/layout/page#parameters-paper
[string]: https://typst.app/docs/reference/foundations/str/
