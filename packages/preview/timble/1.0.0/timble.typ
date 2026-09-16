// =========================== HELPER FUNCTIONS ==============================
// Converts a timestring like "14.30" to the amount of minutes from the
// starting hour.
#let time-to-minutes(timestring, start-hour) = {
    let parts = timestring.split(".")
    let hours = int(parts.at(0)) - start-hour
    let minutes = int(parts.at(1)) + 5
    minutes = minutes + (hours * 60)
    return minutes
}

// Get's the number of minutes between two timestrings.
#let time-diff-in-minutes(startstring, endstring, start-hour) = {
    let parts = startstring.split(".")
    let start-hours = int(parts.at(0)) - start-hour
    let start-minutes = int(parts.at(1)) + 5
    start-minutes = start-minutes + (start-hours * 60)
    parts = endstring.split(".")
    let end-hours = int(parts.at(0)) - start-hour
    let end-minutes = int(parts.at(1)) + 5
    end-minutes = end-minutes + (end-hours * 60)
    return end-minutes - start-minutes
}

// Converts a number of minutes to a number of rows those represent in the
// grid.
#let minutes-to-rows(minutes) = {
    let remainder = calc.rem(minutes, 5)
    if remainder != 0 {
        minutes = minutes + (5 - remainder)
    }
    return calc.div-euclid(minutes, 5)
}

// Converts a number of minutes to the row at which the timestamp starts.
#let minutes-to-start-row(minutes) = {
    return calc.div-euclid(minutes, 5)
}

// Converts a timestring directly to its starting row.
#let timestring-to-start-row(timestring, start-hour) = {
    return minutes-to-start-row(time-to-minutes(timestring, start-hour))
}

// Converts a start and end time to the necessary rowspan to cover the time
// difference.
#let timestrings-to-rowspan(starttime, endtime, start-hour) = {
    return minutes-to-rows(time-diff-in-minutes(starttime, endtime, start-hour))
}

// Converts a timefloat like 14.30 to the same timestring like "14.30".
#let timefloat-to-timestring(timefloat) = {
    let string = str(timefloat)
    let parts = string.split(".")
    if parts.len() == 1 {
        return string + ".00"
    } else if parts.at(1).len() == 1 {
        string = string + "0"
        return string
    } else { return string }
}

// Converts an hourint like 12 to its timestring like "12.00".
#let timeint-to-timestring(timeint) = {
    return str(timeint) + ".00"
}

// Converts a 24-hour timeint like 17 to an am-pm timestring like "5pm".
#let sensible-timeint-to-nonsense-timestring(sensible) = {
    if sensible == 0 {
        return "12am"
    } else if sensible < 12 {
        return str(calc.rem(sensible, 12)) + "am"
    } else if sensible == 12 {
        return "12pm"
    } else{
        return str(calc.rem(sensible, 12)) + "pm"
    }
}

// Converts a 24-hour timestring like "8.30" to an am-pm timestring like
// "8.30am"
#let sensible-timestring-to-nonsense-timestring(sensible) = {
    let parts = sensible.split(".")
    let hour-int = int(parts.at(0))
    let minutes = parts.at(1)
    if minutes == "00" { minutes = "" } else { minutes = "." + minutes }
    if hour-int == 0 {
        return "12" + minutes + "am"
    } else if hour-int < 12 {
        return str(calc.rem(hour-int, 12)) + minutes + "am"
    } else if hour-int == 12 {
        return "12" + minutes + "pm"
    } else{
        return str(calc.rem(hour-int, 12)) + minutes + "pm"
    }
}

// ================================ TIMETABLE ================================
// Main function of the package.
#let timetable(
    // Main
    monday: (),
    tuesday: (),
    wednesday: (),
    thursday: (),
    friday: (),
    saturday: (),
    sunday: (),
    asynchronous: (),
    title: none,
    start-hour: 8,
    end-hour: 18,
    // Styling for contents
    info-names: ("Time", "Monday", "Tuesday", "Wednesday", "Thursday",
        "Friday", "Saturday", "Sunday", "Asynchronous"
    ),
    time-prefix: "",
    time-suffix: "",
    am-pm-format: false,
    info-fill: rgb("ececec"),
    empty-fill: none,
    font: auto,
    base-font-size: 12pt,
    title-font-size: 26pt,
    stroke: 0.5pt,
    hour-stroke: (paint: gray, thickness: 0.5pt, dash: "loosely-dashed"),
    hour-stroke-in-time-cells: true,
    hour-num-spacing: 1mm,
    // Styling for the surrounding rectangle
    border: none,
    margin: 0pt,
    background: none,
    width: auto,
    height: auto,
) = context {
    // Variable that tracks at which row the actual timeslots start.
    let y-start = if title != none { 2 } else { 1 }
    // STYLING
    // Sets manual text font or uses the currently active one otherwise.
    set text(font: if font != auto { font } else { text.font },
        size: base-font-size
    )
    // Cell styling
    show grid.cell: it => {
        let textsize = if it.x > 0 and it.y > y-start - 1 {
            // Adjusts the font size based on the available space in the cell.
            if it.rowspan < 8 { 
                base-font-size / 2 + (it.rowspan - 2) * 1pt
            } else { base-font-size }
        } else {
            // This is the font size in the info fields (header).
            base-font-size - 1pt
        }
        let parleading = if it.rowspan < 15 { 0.4em } else { 0.65em }
        set text(size: textsize)
        set par(leading: parleading)
        it
    }

    // GRID SETUP
    // Array that holds the column sizes for the grid.
    let col-array = (2fr,) * 5
    col-array.insert(0, 1fr)
    // Array that holds the names to use for the header info.
    let header-texts = info-names.slice(0, 6)
    // Array that holds the actual contents to be parsed into cells later.
    let day-array = (monday, tuesday, wednesday, thursday, friday)

    // Adding the necessary things if the weekend is included.
    if saturday != () {
        col-array.push(2fr)
        header-texts.push(info-names.at(6))
        day-array.push(saturday)
    }
    if sunday != () {
        col-array.push(2fr)
        header-texts.push(info-names.at(7))
        day-array.push(sunday)
    }
    // Same for the async column
    if asynchronous != () {
        col-array.push(2fr)
        header-texts.push(info-names.at(8))
        day-array.push(asynchronous)
    }
    // Final number of columns the timetable uses.
    let colnum = col-array.len()

    // Actual contents of the header row.
    let header-row = ()
    for (i, text) in header-texts.enumerate() {
        header-row.push(grid.cell(x: i, y: y-start - 1)[*#text*])
    }

    // Setup of the grid rows. Each hour is separated into 5 minute segments,
    // meaning each hour has twelve rows.
    let hournum = end-hour - start-hour
    let row-array = (1fr,) * 12 * hournum
    // The header takes up six times as much height.
    row-array.insert(0, 6fr)

    // Creates the cells for the time indications.
    let time-cell-array = ()
    for i in range(0, hournum + 1) {
        let hour-text = if not am-pm-format { str(i + start-hour) } else {
            sensible-timeint-to-nonsense-timestring(i + start-hour)
        }
        if time-prefix != "" { hour-text = time-prefix + hour-text }
        if time-suffix != "" { hour-text = hour-text + time-suffix }
        time-cell-array.push(grid.cell(x: 0, y: y-start + i * 12, rowspan: 12,
            stroke: if hour-stroke-in-time-cells and i > 0 {
                (top: hour-stroke, rest: 0.5pt)
            } else { 0.5pt } )[#v(hour-num-spacing) #hour-text]
        )
    }

    // ACTUAL CREATION OF THE CELLS FOR THE CONTENT
    // Array for the content cells
    let cells = ()
    // Array for the grid cells that draw the hour guide lines.
    let hour-line-cells = ()
    // TODO: Actually use?
    /*let hour-line-rows = ()
    for i in range(1, end-hour - start-hour) {
        hour-line-rows.push(i * 12 + y-start)
    }*/
    // The day by the x value in the grid.
    let xpos = 1
    // Number of the last row in the grid.
    let day-end-row = row-array.len() + 12
    // Number of days in the time table.
    let daynum = day-array.len()
    for day in day-array {
        // Starting point to check for necessary hour lins to draw.
        let start-y = y-start + 12
        // Check if we are on the async day (necessary for not drawing hours
        // bounds on that day).
        let async-day = if asynchronous != () and xpos == daynum { true } else { false }
        // Go through each entry and make the correct cell from it.
        for (start, end, color, content) in day {
            // First, any kind of input for the times is converted to a
            // timestring.
            if type(start) == float {
                start = timefloat-to-timestring(start)
            } else if type(start) == int {
                start = timeint-to-timestring(start)
            }
            // Same for the end time.
            if type(end) == float {
                end = timefloat-to-timestring(end)
            } else if type(end) == int {
                end = timeint-to-timestring(end)
            }
            // Row that the cell has to be placed on.
            let start-row = timestring-to-start-row(start, start-hour) + y-start - 1
            // Rowspan so the cell ends on the right row.
            let rownum = timestrings-to-rowspan(start, end, start-hour)

            // Conform display time to am/pm time format if specified.
            if am-pm-format {
                start = sensible-timestring-to-nonsense-timestring(start)
                end = sensible-timestring-to-nonsense-timestring(end)
            }

            // Shows start and end times only on non async days and places them
            // either in their own lines or not depending on available height.
            let content = if async-day {
                [#content]
            } else if rownum < 12 {
                [#start #content #end]
            } else {
                [#start\ #content\ #end]
            }

            // This is the actual cell being added to the array.
            cells.push(grid.cell(x: xpos, y: start-row, fill: color,
                rowspan: rownum, stroke: stroke, content)
            )
            
            // Creates the horizontal lines at the hour marks via empty cells
            // with one stroke. NOTE: Can't use grid.hline because those
            // override cell stroke.
            if not async-day {
                // Draw hour lins as long as we haven't hit the start of the
                // entry.
                while start-y < start-row {
                    hour-line-cells.push(
                        grid.cell(
                            x: xpos, y: start-y, stroke: (top: hour-stroke)
                        )[]
                    )
                    // Go to the next hour.
                    start-y = start-y + 12
                }
                // Advance to after the entry.
                start-y = start-row + rownum + 1
                // Advance in single steps until we hit a full hour row again.
                // This is necessary so hour lines don't get moved off the full
                // hour based on the end time of the entry.
                while calc.rem(start-y - y-start, 12) != 0 {
                    start-y = start-y + 1
                }
            }
        }
        // After the last content cell of the day, we still need to draw hour
        // lines up to the last hour. Same as before but doesn't need to worry
        // about setting the correct start-y for the next entry.
        if not async-day {
            while start-y < day-end-row {
                hour-line-cells.push(
                    grid.cell(x: xpos, y: start-y, stroke: (top: hour-stroke))[]
                )
                start-y = start-y + 12
            }
        }
        // Go over to the next day x value.
        xpos = xpos + 1
    }
    // Adding the actual title cell plus its' row info.
    if title != none {
        // The title row takes up three times height as much as the header.
        row-array.insert(0, auto)
        header-row.push(grid.cell(x: 0, y: 0, colspan: colnum, stroke: none,
            fill: none, inset: title-font-size * 0.55,
            text(size: title-font-size, weight: "bold", title)
        ))
    }

    // FUNCTION OUTPUT
    rect(stroke: border, inset: margin, fill: background, width: width,
        height: height,
        grid(columns: col-array, rows: row-array,
            align: (x, y) => if x == 0 and y > y-start - 1 {
                center + top
            } else {
                center + horizon
            }, inset: 0.35em, stroke: (x, y) => if y == y-start - 1 {
                0.5pt
            } else {
                (right: 0.5pt, rest: none)
            }, fill: (x, y) => if y < y-start or x == 0 {
                info-fill
            } else {
                empty-fill
            },
            // Day names
            ..header-row,
            // Bottom border of the whole time table.
            grid.hline(y: (hournum + 1) * 12 + y-start, stroke: 0.5pt),
            // Hour guidelines
            ..hour-line-cells,
            // Time indication cells on the left of the time table.
            ..time-cell-array,
            // Actual content cells.
            ..cells
        )
    )
}
// Alternative german name for the function.
#let stundenplan(..args) = timetable(..args)
