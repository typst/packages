// ========================= BASIC SEATING DIAGRAMS ==========================
#let seating-chart(
    // Main
    columns: 3,
    rows: 4,
    title: none,
    vertical-rows: (),
    vertical-cols: (),
    // Styling for the contents
    font: auto,
    font-size: 20pt,
    title-font-size: 28pt,
    stroke: 2pt,
    fill: none,
    gutter: 0.8em,
    // Styling for the surrounding rectangle
    border: none,
    margin: 0pt,
    background: none,
    width: auto,
    height: auto,
    ..seating-contents
) = context {
    set text(font: if font != auto { font } else { text.font }, size: font-size)
    let column-number = if type(columns) == int { columns } else {
        columns.len()
    }
    let row-number = if type(rows) == int { rows } else { rows.len() }
    let cells = ()
    // Go through all tables adding the necessary cells to the grid.
    for (i, content) in seating-contents.pos().enumerate() {
        // Needed to check if names should be split horizontally or vertically.
        let rownum = calc.div-euclid(i, column-number) + 1
        let colnum = calc.rem(i, column-number) + 1
        let boxes = none
        // If the content hast normal text, we need to split it up into
        // individual cells and then add that to the cells array.
        if content.has("text") {
            let names = content.text.split(",").map(it => {
                let name = it.trim()
                if name.contains("!") {
                    name = [#h(1cm)]
                }
                name
            })
            boxes = grid(
                columns: if rownum in vertical-rows
                    or colnum in vertical-cols { 1fr } else { names.len()
                },
                rows: if rownum in vertical-rows
                    or colnum in vertical-cols { (1fr,) * names.len() 
                } else {
                    1fr
                },
                inset: 1em, align: center + horizon, ..names
            )
        }
        if boxes != none { content = boxes }
        // Here the actual cells get added to the array.
        if content == [] {
            cells.push(grid.cell(stroke: none, content))
        } else {
            cells.push(grid.cell(stroke: stroke, fill: fill, content))
        }
    }
    // Rows have to be handled separately here to add a title row if necessary.
    let row-arr = if type(rows) == int { (1fr,) * rows } else { rows }
    if title != none {
        row-arr.insert(0, auto)
        cells.insert(0, grid.cell(
            colspan: column-number, 
            text(size: title-font-size, weight:"bold")[#title]
        ))
    }
    // This rect is the actual thing that encloses the whole seating chart.
    rect(stroke: border, inset: margin, fill: background, width: width,
        height: height,
        grid(columns: if type(columns) == int { (1fr,) * columns } else {
                columns 
            },
            rows: row-arr, gutter: gutter, inset: 0.25em,
            align: center + horizon, ..cells
        )
    )
}
// German alternate function name to call.
#let sitzplan(..args) = seating-chart(..args)

// ======================== COMPLEX SEATING DIAGRAMS =========================
// Helper functions to be used inside a `free-seating-chart()` call.
// These all return dictionaries that contain the relevant data to turn into
// cells for the grid later.
#let htable(span: auto, ..name-args) = {
    return (
        type: "table",
        dir: "hor",
        span: if span != auto { span } else { name-args.pos().len() },
        names: (..name-args.pos())
    )
}
#let htisch(..args) = htable(..args)

#let vtable(span: auto, ..name-args) = {
    return (
        type: "table",
        dir: "ver",
        span: if span != auto { span } else { name-args.pos().len() },
        names: (..name-args.pos())
    )
}
#let vtisch(..args) = vtable(..args)

#let empty(..args) = {
    let hor = args.at(0, default: 1)
    let ver = args.at(1, default: 1)
    return (type: "empty", horizontal: hor, vertical: ver)
}
#let leer(..args) = empty(..args)

// Main function
#let free-seating-chart(
    // Main
    columns: 6,
    rows: 4,
    title: none,
    // Styling for contents
    font: auto,
    font-size: 20pt,
    title-font-size: 28pt,
    stroke: 2pt,
    fill: none,
    gutter: 0.2em,
    // Styling for the surrounding rectangle
    border: none,
    margin: 0pt,
    background: none,
    width: auto,
    height: auto,
    // Debugging switch
    debug: false,
    ..seating-contents
) = context {
    set text(font: if font != auto { font } else { text.font }, size: font-size)
    let cells = ()
    // Just like before, go through all provided inputs. Enumerate is necessary
    // to display debug information if requested.
    for (i, element) in seating-contents.pos().enumerate() {
        i = i + 1
        // If a table is required ...
        if element.at("type") == "table" {
            // These get all the relevant fields from the dict.
            let dir = element.at("dir", default: "hor")
            let names = element.at("names", default: ())
            let nnum = names.len()
            let span = element.at("span", default: 1)
            // Here we add the grid cell to the array.
            cells.push(grid.cell(
                // Sizing is dependent on if a horizontal or vertical table is
                // added.
                colspan: if dir == "hor" and span > 0 { span } else { 1 },
                rowspan: if dir == "ver" and span > 0 { span } else { 1 },
                stroke: stroke,
                // A content block is necessary to allow draing the debugging
                // number if requested.
                [
                    // There's a grid inside the cell to separate names nicely.
                    #grid(
                        columns: if dir == "hor" { (1fr,) * nnum } else { 1fr },
                        rows: if dir == "ver" { (1fr,) * nnum } else { 1fr },
                        inset: 1em, align: center + horizon,
                        ..names
                    )
                    // Debugging draw if necessary.
                    #if debug { place(top + left, text(fill: red)[#i]) }
                ]
            ))
        // If a spaceholder is required ...
        } else {
            cells.push(grid.cell(colspan: element.at("horizontal"),
                rowspan: element.at("vertical"),
                stroke: if debug { 1pt + red } else { none },
                align: top + left,
                // Debugging draw if necessary.
                if debug { text(fill: red)[#i] } else [])
            )
        }
    }
    // Just like above, rows are handled here to include the title.
    let row-arr = if type(rows) == int { (1fr,) * rows } else { rows }
    if title != none {
        row-arr.insert(0, auto)
        cells.insert(0, grid.cell(
            colspan: columns,
            text(size: title-font-size, weight:"bold")[#title]
        ))
    }
    // This is the actual seating chart rect.
    rect(stroke: border, inset: margin, fill: background, width: width,
        height: height,
        grid(columns: if type(columns) == int { (1fr,) * columns } else {
                columns
            },
            rows: row-arr, gutter: gutter, inset: 0.25em,
            align: center + horizon, ..cells
        )
    )
}
// German alternative function name.
#let freier-sitzplan(..args) = free-seating-chart(..args)
