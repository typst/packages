# Changelog

## 0.1.9

> [!TIP]
> Full English translation support has been added. The entire template is now available in English and German, including title page, all headings, figures, listings, and bibliographies. The language is controlled by the `language` parameter.
> ```typst
> #show: thesis.with(
>   // ...
>   language: "en",
> )
> ```

> [!NOTE]
> The `two-langs` parameter has been removed; the order is now determined by the `language` setting.

> [!TIP]
> An `appendix` parameter has been added to the thesis function. Use it to add additional material after the bibliography with separate numbering (A, A.1, A.2, ...).
> ```typst
> #show: thesis.with(
>   // ...
>   appendix: include "appendix.typ",
> )
> ```

> [!NOTE]
> Optional outlines are now shown only if content exists. The list of figures, list of listings, and list of tables are displayed only if they contain at least one element, preventing empty sections in the document.

## 0.1.8

> [!TIP]
> The `course-of-study` parameter has been replaced by `study-name`, which accepts one of the predefined abbreviations from `study-name.<KEY>`. Based on the selected value, the thesis type (Bachelorarbeit/Masterarbeit), academic degree (B.Sc./M.Sc.), faculty, and study program name are derived automatically.
> ```typst
> #show: thesis.with(
>   // ...
>   study-name: study-name.IFB,
> )
> ```

> [!TIP]
> Optional figure lists can now be shown in the appendix. All three are enabled by default and can be turned off individually.
> ```typst
> #show: thesis.with(
>   // ...
>   show-image-outline: true,
>   show-listing-outline: true,
>   show-table-outline: true,
> )
> ```

> [!TIP]
> A new `#done()` helper has been added for draft mode. It renders a checkmark (✅) that is only visible while `draft` is set to `true`.
> ```typst
> #done()
> ```

> [!NOTE]
> Glossary entries in figure captions and outlines no longer force the "first form" of an entry (i.e. showing the long form). This prevents repeated long-form expansions in lists of figures and the table of contents.

> [!NOTE]
> Abbreviations are only listed in the glossary if they are referenced at least twice in the document.

- Fix todo placeholder label for missing study group on title page

## 0.1.7

> [!TIP]
> Print view is now available. Set `print: true` to add blank pages before odd-numbered chapters, alternate page numbers and headers for left/right pages, and widen the inner margin to 3 cm for binding.
> ```typst
> #show: thesis.with(
>   // ...
>   print: true,
> )
> ```

> [!NOTE]
> Fixed roman numeral page numbering (`i`) for front matter (table of contents, abstract). Previously, the numbering counter was not applied correctly.

- Update glossarium to `0.5.10`, datify to `1.0.1`

## 0.1.6

> [!TIP]
> Code blocks are now rendered using `zebraw` with line numbers, a numbering separator, and syntax language label in HM color.

> [!NOTE]
> All draft indicators (title page watermark, page header, `#todo`) now use HM color (`#fb5454`) instead of red.

- Level-3 headings are slightly larger (1.1em)
- Level-5 headings are semibold
- Numbered lists are now indented (same as bullet lists)
- Multi-level heading numbering in the body (`1`, `1.1`, `1.1.1`, `1.1.1.1`)
- Headings use supplement "Kapitel"

## 0.1.5

> [!TIP]
> Bullet and numbered lists are now indented by default.

> [!TIP]
> Level-1 headings in the body are automatically numbered. Headings outside the body (abstract, bibliography) are not numbered.

## 0.1.4

> [!TIP]
> Draft mode now applies visual accents throughout the document: citations are highlighted in orange, footnotes in purple. The citation style automatically switches between `springer-basic-author-date` (draft) and `ieee` (final).

> [!NOTE]
> The draft watermark on the title page and in the page header now shows "ENTWURF" along with the current date.

> [!NOTE]
> Back-references in the abbreviations list are now enabled with deduplication (previously disabled entirely).

- Remove hard-coded Arial font and 10pt font size

## 0.1.3

- Automatic page break before every level-1 heading
- Variable links are rendered without hyperlink decoration (only the content is shown)

## 0.1.2

> [!TIP]
> A `variables-list` parameter has been added. Use it to pre-define frequently used phrases with custom formatting. Variables are usable just like abbreviations via `@key`.
> Keys must be unique across `abbreviations.typ` and `variables.typ`.
> ```typst
> #let variables-list = (
>   (
>     key: "typst",
>     short: text(fill: rgb("#239dad"))[`Typst`],
>   ),
> )
> ```

- Remove student name from page header
- Gracefully handle `none` birth date
- Gracefully handle `none` or empty variable entries (shows a `#todo` placeholder in draft mode)

## 0.1.1

> [!TIP]
> German date formatting is now handled by the `datify` library. Dates are displayed in long German format (e.g. "1. Januar 2025").

> [!NOTE]
> `#todo()` is now context-aware via Typst state. It no longer requires passing `draft` as a parameter.
> ```typst
> #todo[Something to do]
> ```

- Title page shows "Bachelorarbeit zur Erlangung des akademischen Grades Bachelor of Science"
- Add `course-of-study` parameter to pass the study program name to the title page
- Replace HM logo

## 0.1.0

- Initial release
