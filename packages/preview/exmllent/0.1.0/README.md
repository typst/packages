# eXMLlent

Pure typst implementation of converting XML Excel table to typst table.

## Quick Start

> [!NOTE]
> The current version only supports converting the **Excel exported** XML table to typst table. Not sure if it works for other XML tables (Numbers, Google Sheets, etc.). Pull requests are welcome!

Start by importing the package:

```typ
#import "@preview/exmllent:0.1.0": worksheets-parser, worksheet-parser
```

Then you can use the `worksheets-parser` and `worksheet-parser` functions to convert your XML Excel table to typst table.

With `worksheets-parser` you can convert all worksheets in the XML file to typst tables. When `to-array` is set to `true`, the function will return an array of typst tables. Otherwise, it will return a sequence of tables. For the rest of the arguments, they will be passed to `worksheet-parser`.

```typ
#worksheets-parser(
  xml-workbook: xml("/test-table.xml"),
  to-array: true, // default is false
  // below args will be passed to worksheet-parser
  with-table-styles: false,
  with-table-alignment: false,
  columns: (1fr, 1fr),
  rows: 4em,
  align: center+horizon,
  stroke: yellow,
)
```

With `worksheet-parser` you can convert a specific worksheet in the XML file to a typst table. If `with-table-styles` is set to `true`, the function will use the **styles**(only column width and row height are supported for now) defined in the XML file. Otherwise, it will use the styles specified in the arguments and pass them to the table.

```typ
#worksheet-parser(
  xml-workbook: xml("/test-table.xml"),
  worksheet: "Sheet2",
  with-table-styles: false,
  with-table-alignment: false,
  // if with-table-styles is false, then below args will be passed to table
  columns: (1fr, 1fr),
  // rows: 4em,
  align: center+horizon,
  stroke: yellow,
)
```

Have fun!
