#import "@preview/ttt-utils:0.1.0": components

#import components: tag as _tag, checkbox

#let eval_row(row) = {
    row = row.map(cell => {
        let c = cell.trim(" ")
        if (c in ("[ ]", "[]")) { align(center, checkbox()) }
        else if (c == "[x]") { align(center,checkbox(fill: green.lighten(30%), tick: true)) } 
        else { cell } 
    })
    row.push("")
    row
}


/// utility function to add a column of emtpy checkboxes
#let add_check_column(data, title: "check") = {
    let header = data.at(0);
    let rows = data.slice(1);
    header.push(title)
    rows = rows.map(r => (..r,"[ ]"))
    return (
        header,
        ..rows
    )
}

/// prints a list of students from the given data.
#let studentlist(data, tag: none, numbered: false, lines: false, rh: auto) = {
    assert(type(numbered) == bool, message: "expected numbered parameter to be a [bool], found " + type(numbered))
    assert.eq(type(lines),bool, message: "expected lines parameter to be a [bool], found " + type(lines))
    assert(type(rh) == length or rh == auto, message: "expected rh parameter to be [auto] or a [length], found " + type(rh))
    assert(type(tag) == str or tag == none, message: "expected tag parameter tp be a [str] or [none], found " + type(tag))

    let header = data.at(0);
    let body = data.slice(1).map(row => eval_row(row));

    if (numbered) {
        header.insert(0, "Nr");
        body = body.enumerate().map(((i, row)) => (str(i+1), row).flatten());
    }
    
    let cols = (auto,) * header.len()
    cols.push(1fr)

    header.push(strong(delta: -200, place(end + horizon, _tag(tag))))
    
    // grid settings
    show grid.cell.where(y: 0): it => strong(delta: 200)[#it]
    let stroke_color = luma(200)
    set grid.vline(stroke: stroke_color)


    let list = grid(
        columns: cols,
        rows: rh,
        inset: 0.6em,
        stroke: (col, _) => if (lines) { (right: stroke_color)},
        fill: (_, row) => if calc.odd(row) { luma(240) } else { white },
        align: (col,_) => if (numbered and col == 0) {horizon + end} else {horizon + start },
        grid.header(..header),
        grid.hline(stroke: stroke_color),
        ..body.flatten(),
        if (numbered) {grid.vline(x:1)} // must be at last position
    )
    
    // wrapper to display the round corners.
    block(
        stroke: stroke_color,
        radius: 5pt,
        clip: true,
        list
    )
}