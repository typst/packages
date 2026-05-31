# Spreet

Spreet is a spreadsheet decoder for typst (excel/opendocument spreadsheets).
In the normal mode the spreadsheet will be read and parsed into a dictonary of 2-dimensional array of strings:
Each workbook in the spreadsheet is mapped as an entry in the dictonary.
Each row of the workbook is represented as an array of strings, and all rows are summarised in a single array.
For full parsing for all information use the "full" option.

> [!WARNING]
> The ‘full’ option is currently in an unstable state. Fundamental changes (breaking changes) may occur.
> Addionally its not fully tested.

!The library only supports normal sheets. Charts are not supported.!


## Example

```typst
#import "@preview/spreet:0.2.0"

#let excel_data_from_bytes = spreet.decode(read("excel.xlsx", encoding: none))
#let opendocument_data_from_bytes = spreet.decode(read("opendocument.ods", encoding: none))

#let excel_data_with_index = spreet.decode(read("excel.xlsx", encoding: none)options: (sheets: (0, "Tabelle2",)))
```

excel_data or opendocument_data contains a dict of all worksheets (of the selected worksheet)

```
(
  Worksheet1: (
    (Row1_Column1, Row1_Column2),
    (Row2_Column1, Row2_Column2),
  ),
  Worksheet2: (
    (Row1_Column1, Row1_Column2),
    (Row2_Column1, Row2_Column2),
  )
)
```

for full decoding with all information use the "full" parameter

```typst
#import "@preview/spreet:0.2.0"

#let excel_data_from_bytes = spreet.decode(read("excel.xlsx", encoding: none), options: (full: true)
#let opendocument_data_from_bytes = spreet.decode(read("opendocument.ods", encoding: none), options: (full: true))
```

excel_data or opendocument_data contains a dict of all worksheets (of the selected worksheet)

```
(
  title: "Title",
  subject: "Subject",
  description: "Description",
  keywords: "keyword",
  creator: "",
  created: (
    year: 2026,
    month: 5,
    day: 31,
    hour: 0,
    minute: 20,
    second: 12,
  ),
  modified: (
    year: 2026,
    month: 5,
    day: 31,
    hour: 17,
    minute: 16,
    second: 12,
  ),
  sheets: (
    (
      name: "Tabelle1",
      rows: (
        (height: "4cm", hidden: false),
        // ...
      ),
      cols: (
        (width: "2.258cm", hidden: false),
        // ...
      ),
      cells: (
        (
          x: 0,
          y: 0,
          col_span: 1,
          row_span: 1,
          value: 1.0,
          style: (
            font: (
              bold: true,
              italic: true,
              size: "14pt",
              color: "#ff3838",
              underline: "single",
              strike: true,
            ),
          ),
        ),
        // ...
      ),
    )
  ),
)
```