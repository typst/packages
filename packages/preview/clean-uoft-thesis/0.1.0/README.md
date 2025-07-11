# `clean-uoft-thesis`

Unofficial masters and doctoral thesis template for the School of Graduate Studies at the University of Toronto.

# Getting started

The following command will create a directory named `my-thesis/` that will contain the files necessary to render the thesis:

```typ
typst init @preview/clean-uoft-thesis:0.1.0 my-thesis
```

# File organization

The following files are found within the `content/` directory:

## `main.typ`

This is the file which yields the complete thesis upon compilation.
Template settings are placed at the start of this file within the `#show: uoft.with(...)` call.

This file also directly manages the content for the entirety of the thesis with the exception of the following special sections:
- title page
- abstract
- acknowledgements
- outlines (e.g., table of contents)

In the provided sample file, thesis content is not placed directly within `main.typ` but rather passed into the file with `#include` statements.
Feel free to adjust the organization or included components of this file as you wish.

## `abstract.typ` and `acknowledgements.typ`

The abstract and acknowledgement sections are the only content files whose positions in the thesis are not controlled by arbitrary placement within `main.typ`.
They instead must be passed into the `#show: uoft.with(...)` call at the start of `main.typ`.
Do not otherwise manually `#include` these files into `main.typ`.

## `references.bib`

A BibLaTeX formatted .bib file to store citations used within the thesis.

## All other `*.typ` files

All other files are content files to be edited and included into `main.typ` with `#include` statements.

# Settings

Settings are passed into the `#show: uoft.with(...)` call in `main.typ`.

## Essential settings

These settings must be adjusted to suit each individual's thesis.

- `title`: Title of thesis. Default value is `none`. 
- `author`: The full name of the thesis author. Default value is `*missing-param-author*`. 
- `department`: The name of the department associated with the thesis. This field should not include "Department of" (i.e., simply write "Physiology" instead of "Department of Physiology"). Default value is `*missing-param-department*`.
- `degree`: The degree associated with the thesis. Acceptable values must either begin with "Doctor" or "Master".
- `graduation-year`: The year of graduation of the author of the thesis. This value must be passed as a content type and not as a number (`"2025"` or `[2025]` rather than `2025`). Default value is `*missing-param-year*`.

## Optional settings

These settings control formatting and optional components of the thesis and, unless otherwise stated by department-specific formatting instructions, may be ignored.

- `font-size`: The font size to use for the main thesis text. The default value is `12pt`. The specified value must be at least `10pt`.
- `show-acknowledgements`: If the acknowledgements section should be shown. Default value is `true`.
- `show-list-of-tables`: If the list of table section should be shown. Default value is `true`.
- `show-list-of-plates`: If the list of plates section should be shown. Default value is `false`.
- `show-list-of-figures`: If the list of figures should be shown. Default value is `true`.
- `show-list-of-appendices`: If the list of appendices should be shown. Default value is `true`.
- `title-page-top-margin`: How large the top margin should be on the title page. Default value is `5cm`. Acceptable values are `2in` and `5cm`.
- `title-page-bottom-margin`: How large the bottom margin should be on the title page. Default value is `3cm`. Acceptable values are `1.25in` and `3cm`.
- `title-page-gap-1-height`: How large the gap between the title of the thesis and the word "by" should be on the title page. Default is `4cm`. Acceptable values are `1.5in` and `4cm`.
- `title-page-gap-2-height`: How large the gap between the word "by" and the author's name should be on the title page. Default is `4cm`. Acceptable values are `1.5in` and `4cm`.
- `title-page-gap-3-height`: How large the gap between the author's name and the degree should be on the title page. Default is `5cm`. Acceptable values are `2in` and `5cm`.
- `title-page-gap-4-height`: How large the gap between the degree and the copyright line should be on the title page. Default is `3cm`. Acceptable values are `1.25in` and `3cm`.
- `page-size-style`: Whether the page should be 21.5cm by 28cm (`"metric"`) or 8.5in by 11in (`"imperial"`). Default value is `"metric"`.
- `main-margin-style`: What sizes to use for the main thesis margins. Options are:
    - `"left-metric"` 20mm top, 20mm bottom, 32mm left, 20mm right (default)
    - `"left-imperial"` 0.75in top, 0.75in bottom, 1.25in left, 0.75in right
    - `"metric"` 20mm on all sides
    - `"imperial"` 0.75in on all sides
