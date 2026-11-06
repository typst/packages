#let xml-to-worksheets(xml-workbook) = {
  let workbook = xml-workbook.filter(e => if e.tag == "" { false } else { true }).first()
  let worksheets = workbook.children.filter(e => if "tag" in e { e.tag == "Worksheet" } else { false })

  let styles = workbook
    .children
    .find(e => "tag" in e and e.tag == "Styles")
    .children
    .filter(e => if type(e) == "string" { false } else { true })
    .map(e => {
      (
        e.attrs.ID,
        {
          let attrs = e
            .children
            .filter(e => if type(e) == "string" { false } else { true })
            .filter(e => e.tag == "Alignment")
            .at(0)
            .attrs
          let style = ""
          if "Horizontal" in attrs {
            if style != "" {
              style += "+ "
            }
            style += lower(attrs.Horizontal) + " "
          }
          if "Vertical" in attrs {
            if style != "" {
              style += "+ "
            }
            if attrs.Vertical == "Center" {
              style += "horizon "
            } else {
              style += lower(attrs.Vertical) + " "
            }
          }
          style
        },
      )
    })
    .to-dict()
  (
    worksheets: worksheets,
    styles: styles,
  )
}

/// Parse a named worksheet from an Excel file.
///
/// - xml-workbook (string): The xml-loaded workbook.
/// - worksheets (dictionary): Parsed worksheets from the XML Excel file. (Not available for users)
/// - styles (dictionary): Parsed styles from the XML Excel file. (Not available for users)
/// - worksheet (string): The name of the worksheet to be parsed.
/// - with-table-styles (boolean): If true, apply column width and row height to the table.
/// - with-table-alignment (boolean): If true, apply alignment to the table.
/// - default-row-height (string): The default row height.
/// - table-args (any): Arguments to be passed to table.
/// -> content
#let worksheet-parser(
  xml-workbook: none,
  worksheets: none,
  styles: none,
  worksheet: "Sheet1",
  with-table-styles: true,
  with-table-alignment: true,
  default-row-height: "20pt",
  ..table-args,
) = {
  let (worksheets, styles) = if xml-workbook != none {
    xml-to-worksheets(xml-workbook)
  } else {
    (worksheets, styles)
  }
  let worksheet = worksheets.find(e => e.attrs.Name == worksheet)

  let excel-table = worksheet
    .children
    .find(e => "tag" in e and e.tag == "Table")
    .children
    .filter(e => if type(e) == "string" { false } else { true }) // 去除换行符

  let columns = excel-table
    .map(e => if e.tag == "Column" {
      eval(e.attrs.Width + "pt")
    })
    .filter(e => e != none)

  let rows = excel-table
    .map(e => if e.tag == "Row" {
      eval(if "Height" in e.attrs {
        e.attrs.Height + "pt"
      } else {
        default-row-height
      })
    })
    .filter(e => e != none)

  let cells = excel-table
    .filter(e => e.tag == "Row")
    .map(row => {
      row
        .children
        .filter(e => if type(e) == "string" { false } else { true })
        .map(c => {
          let colspan = if "MergeAcross" in c.attrs {
            eval(c.attrs.MergeAcross) + 1
          } else {
            1
          }
          let rowspan = if "MergeDown" in c.attrs {
            eval(c.attrs.MergeDown) + 1
          } else {
            1
          }
          let content = c.children.at(0).children.at(0)

          if "StyleID" not in c.attrs or not with-table-alignment {
            table.cell(
              colspan: colspan,
              rowspan: rowspan,
              content,
            )
          } else if with-table-alignment {
            let styleId = c.attrs.StyleID
            let style = if styleId != none { styles.at(styleId) } else {
              styles.at("Default")
            }
            table.cell(
              colspan: colspan,
              rowspan: rowspan,
              align: eval(style),
              content,
            )
          } else {
            table.cell(
              colspan: colspan,
              rowspan: rowspan,
              content,
            )
          }
        })
    })
    .flatten()

  if with-table-styles {
    table(
      columns: columns,
      rows: rows,
      ..cells
    )
  } else {
    if columns.len() > 0 {
      table(
        columns: columns,
        ..table-args,
        ..cells
      )
    } else {
      table(
        ..table-args,
        ..cells
      )
    }
  }
}

/// Parse worksheets from an Excel file.
///
/// - xml-workbook (string): The xml-loaded workbook.
/// - to-array (boolean): If true, return an array of tables.
/// - args (any): Arguments to be passed to worksheet-parser.
/// -> content | array
#let worksheets-parser(
  xml-workbook: none,
  to-array: false,
  ..args,
) = {
  let (worksheets, styles) = xml-to-worksheets(xml-workbook)
  for worksheet in worksheets {
    if to-array {
      (
        worksheet-parser(
          worksheets: worksheets,
          styles: styles,
          worksheet: worksheet.attrs.Name,
          ..args,
        ),
      )
    } else {
      worksheet-parser(
        worksheets: worksheets,
        styles: styles,
        worksheet: worksheet.attrs.Name,
        ..args,
      )
    }
  }
}
