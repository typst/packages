# Spreet

Spreet is a spreadsheet decoder for typst (excel/opendocument spreadsheets).
The spreadsheet will be read and parsed into a dictonary of 2-dimensional array of strings:
Each workbook in the spreadsheet is mapped as an entry in the dictonary.
Each row of the workbook is represented as an array of strings, and all rows are summarised in a single array.

## Example

```typst
#import "@preview/spreet:0.1.0"

#let excel_data = spreet.file-decode("excel.xlsx")
#let opendocument_data = spreet.file-decode("opendocument.ods")

#let excel_data_from_bytes = spreet.decode(read("excel.xlsx", encoding: none))
#let opendocument_data_from_bytes = spreet.decode(read("opendocument.ods", encoding: none))

/**
excel_data or opendocument_data contains a dict of all worksheets
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
**/
```
