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
Settings that adjust the formatting of the thesis are also placed here.

## `body.typ`

This file contains the entirety of the thesis with the exception of the following special sections:
- title page
- abstract
- acknowledgements
- outlines (e.g., table of contents)

In the provided sample files, thesis content is not placed directly within `body.typ` but rather passed into the file with `#include()` statements.
Feel free to adjust the organization or included components of this file as you wish.

## `abstract.typ` and `acknowledgements.typ`

The abstract and acknowledgement sections are the only content files whose positions in the thesis are not controlled within `body.typ`.
The abstract and optionally the acknowledgements will be automatically added into the thesis upon compilation of `main.typ`.
Do not manually `#include()` these files into `body.typ`.

## `references.bib`

A BibLaTeX formatted .bib file to store citations used within the thesis.

## All other `*.typ` files

All other files are content files to be edited and included into `body.typ` with `#include()` statements.

# Settings

Settings are passed into the `#show: uoft.with(...)` call in `main.typ`.

## Essential settings

- `title`: Title of thesis. Default value is `none`. 
- `author`: The full name of the thesis author. Default value is `*missing_param_author*`. 
- `department`: The name of the department associated with the thesis. This field should not include "Department of" (i.e., simply write "Physiology" instead of "Department of Physiology"). Default value is `*missing_param_department*`.
- `degree`: The degree associated with the thesis. Acceptable values must either begin with "Doctor" or "Master".
- `graduation_year`: The year of graduation of the author of the thesis. This value must be passed as a content type and not as a number (`"2025"` or `[2025]` rather than `2025`). Default value is `*missing_param_year*`.

## Optional settings

- `font_size`: The font size to use for the main thesis text. The default value is `12pt`. The specified value must be at least `10pt`.
- `show_acknowledgements`: If the acknowledgements section should be shown. Default value is `true`.
- `show_list_of_tables`: If the list of table section should be shown. Default value is `true`.
- `show_list_of_plates`: If the list of plates section should be shown. Default value is `false`.
- `show_list_of_figures`: If the list of figures should be shown. Default value is `true`.
- `show_list_of_appendices`: If the list of appendices should be shown. Default value is `true`.
- `title_page_top_margin`: How large the top margin should be on the title page. Default value is `5cm`. Acceptable values are `2in` and `5cm`.
- `title_page_bottom_margin`: How large the bottom margin should be on the title page. Default value is `3cm`. Acceptable values are `1.25in` and `3cm`.
- `title_page_gap_1_height`: How large the gap between the title of the thesis and the word "by" should be on the title page. Default is `4cm`. Acceptable values are `1.5in` and `4cm`.
- `title_page_gap_2_height`: How large the gap between the word "by" and the author's name should be on the title page. Default is `4cm`. Acceptable values are `1.5in` and `4cm`.
- `title_page_gap_3_height`: How large the gap between the author's name and the degree should be on the title page. Default is `5cm`. Acceptable values are `2in` and `5cm`.
- `title_page_gap_4_height`: How large the gap between the degree and the copyright line should be on the title page. Default is `3cm`. Acceptable values are `1.25in` and `3cm`.
- `page_size_style`: Whether the page should be 21.5cm by 28cm (`"metric"`) or 8.5in by 11in (`"imperial"`). Default value is `"metric"`.
- `main_margin_style`: What sizes to use for the main thesis margins. Options are:
    - `"left_metric"` 20mm top, 20mm bottom, 32mm left, 20mm right (default)
    - `"left_imperial"` 0.75in top, 0.75in bottom, 1.25in left, 0.75in right
    - `"metric"` 20mm on all sides
    - `"imperial"` 0.75in on all sides
