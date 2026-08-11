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
    // Internal number of columns per day to use for splitting into parallel
    // events. If five or six stacks should be allowed, increase to 60 (large
    // performance hit).
    let day-col-division = 12

    // Variable that tracks at which row the actual timeslots start.
    let y-start = if title != none { 2 } else { 1 }

    // =============================== STYLING ===============================
    // Sets manual text font or uses the currently active one otherwise.
    set text(font: if font != auto { font } else { text.font },
        size: base-font-size
    )
    // Cell styling
    show grid.cell: it => {
        let textsize = if it.x > 0 and it.y > y-start - 1 {
            let final-size = base-font-size
            // Adjusts the font size based on the available space in the cell.
            if it.rowspan < 8 { 
                final-size = final-size / 2 + (it.rowspan - 2) * 1pt
            }
            // If there are parallel events, also adjust the size.
            if it.colspan < day-col-division {
                // Subtracts from the size more for each added parralel layer.
                // How strong the subtraction is can be controlled by the
                // multiplier at the end of the line.
                final-size = (
                    final-size - (day-col-division / it.colspan * 1pt) * 1.5
                )
            }
            final-size
        } else {
            // This is the font size in the info fields (header).
            base-font-size - 1pt
        }
        let parleading = if it.rowspan < 15 { 0.4em } else { 0.65em }
        set text(size: textsize)
        set par(leading: parleading)
        it
    }

    // ============================ GRID SETUP ===============================
    // Array that holds the column sizes for the grid.
    // The five weekdays are always shown, thus 5 is the starting point.
    let col-array = (1fr,) * 5 * day-col-division
    // This is the column for the hour indications.
    col-array.insert(0, (day-col-division / 2) * 1fr)

    // Array that holds the names to use for the header info.
    let header-texts = info-names.slice(0, 6)
    // Array that holds the actual contents to be parsed into cells later.
    let day-array = (monday, tuesday, wednesday, thursday, friday)

    // Adding the necessary things if the weekend is included.
    if saturday != () {
        // For each added day, we need the number of columns added that a day
        // is split into.
        for _ in range(day-col-division) {
            col-array.push(1fr)
        }
        header-texts.push(info-names.at(6))
        day-array.push(saturday)
    }
    if sunday != () {
        for _ in range(day-col-division) {
            col-array.push(1fr)
        }
        header-texts.push(info-names.at(7))
        day-array.push(sunday)
    }
    // Same for the async column
    if asynchronous != () {
        for _ in range(day-col-division) {
            col-array.push(1fr)
        }
        header-texts.push(info-names.at(8))
        day-array.push(asynchronous)
    }

    // Number of "logical" columns for days, so ranges from 5 - 8
    let colnum = int((col-array.len() - 1) / day-col-division)
    // Actual number of columns in the resulting grid.
    let real-colnum = col-array.len()

    // Setup of the grid rows. Each hour is separated into 5 minute segments,
    // meaning each hour has twelve rows.
    let hournum = end-hour - start-hour
    // Array that contains the final sizing info for the whole grid.
    let row-array = (1fr,) * 12 * hournum
    // The header takes up six times as much height.
    row-array.insert(0, 6fr)

    // This array holds the x value for the first column in each day. Later
    // used to correctly position events.
    let day-starting-x = (0, 1)
    for i in range(1, colnum + 1) {
        day-starting-x.push(1 + i * day-col-division)
    }

    // ======================= FINAL HOUR TEXT CELLS =========================
    // These are the grid cells containing the hour timestamps on the left of
    // the timetable.
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
    // -----------------------------------------------------------------------

    // ================= STARTING HOUR INDICATION LINE CELLS =================
    // Here we create single span grid cells for each hour that together form
    // the hour indication lines across the whole grid. Later when we create
    // the events, all the hour marks that intersect events are deleted from
    // this array so there won't be any collisions.
    let hour-line-cells = (:)
    let hour-y-values = ()
    for yv in range(14, 12 * (hournum + 1), step: 12) {
        // Hour line indications aren't drawn on the async day so we subtract
        // by the columns per day to leave it out.
        for xv in range(1, real-colnum - day-col-division) {
            hour-line-cells.insert(str(xv) + "." + str(yv), grid.cell(
                x: xv, y: yv, stroke: (top: hour-stroke)
            )[])
        }
        hour-y-values.push(yv)
    }
    // -----------------------------------------------------------------------

    // ====================== FINAL HEADER ROW ===============================
    // Array of grid cells in the header row.
    let header-row = ()
    // Running x posision for the new cell to use.
    let xval = 0
    for (i, text) in header-texts.enumerate() {
        // The time col has colspan 1, the other days all span the division
        // number for parallel events.
        let span = if i == 0 { 1 } else { day-col-division }
        header-row.push(
            grid.cell(x: xval, y: y-start - 1, colspan: span)[*#text*]
        )
        // We increase xval by the span to correctly place the next cell.
        xval += span
    }
    // -----------------------------------------------------------------------

    // ================ PARSING OF INPUT EVENTS TO DICT FORM =================
    // Array of day arrays. In each day array are the dicts of events.
    let week = ()

    // Index by which we can get the first x position column from
    // day-starting-x array.
    let day-index = 1
    // We create dictionary tuples for each event in each day.
    for day in day-array {
        // This array holds all the dictionary events for the current day.
        let dict-array = ()

        // Starting x value for the day
        let start-x = day-starting-x.at(day-index)

        // Check if we are on the async day (necessary for not drawing the
        // timestamps around the event text on that day).
        let async-day = if asynchronous != () and day-index == colnum {
            true
        } else { false }

        // Now we iterate through each event defined for the current day and
        // create a dictionary representing it. The reason we make the new
        // dictionary versions is because we need to iterate through the parsed
        // data repeatedly and change the contents multiple times.
        for (start, end, color, content) in day {
            // First, any kind of input for the times is converted to a
            // timestring.
            if type(start) == float {
                start = timefloat-to-timestring(start)
            } else if type(start) == int {
                start = timeint-to-timestring(start)
            }
            if type(end) == float {
                end = timefloat-to-timestring(end)
            } else if type(end) == int {
                end = timeint-to-timestring(end)
            }

            // Row that the cell has to be placed on.
            let start-row = (
                timestring-to-start-row(start, start-hour) + y-start - 1
            )
            // Rowspan so the cell ends on the right row.
            let rownum = timestrings-to-rowspan(start, end, start-hour)

            // Shows start and end times only on non async days and places them
            // either in their own lines or not depending on available height.
            let content = if async-day {
                [#content]
            } else if rownum < 12 {
                [#start #content #end]
            } else {
                [#start\ #content\ #end]
            }

            // Add a new dictionary to the array for this day containing all
            // relevant data for further processing later.
            dict-array.push(
                (start-row: start-row, end-row: start-row + rownum - 1,
                    start-col: start-x,
                    end-col: start-x + day-col-division - 1,
                    rownum: rownum, colspan: day-col-division,
                    color: color, content: content, intersects: (),
                )
            )
        }

        // After the day is finished, add it to the array holding all the days.
        week.push(dict-array)
        day-index += 1
    }
    // -----------------------------------------------------------------------

    // ====================== INTERSECTION PROCESSING ========================
    // Since we have to manipulate the entries via week.at().at() to actually
    // update their values, not just get back and edit copies, we use short
    // variable names. di is equivalent to the previous day-index.
    for di in range(colnum) {
        // Starting x value for the day
        let start-x = day-starting-x.at(di + 1)

        // Dictionary for every block of intersections. We only keep the
        // largest found blocks so using a key to identify them helps.
        let intersection-blocks = (:)

        // Here we do get a copy, but simply to have easier access to the data.
        let dict-array = week.at(di)
        // Look at each event in the day. Same here, these are copies just for
        // easier access. cei is the index of the current event in the day
        // array.
        for (cei, event-dict) in dict-array.enumerate() {
            // Now we go through all indices BEFORE the current one to check
            // for intersections with previously defined events.
            for i in range(cei) {
                // Event dictionary that we are comparing against.
                let compare-dict = dict-array.at(i)
                // Starting row of the current event.
                let event-start = event-dict.start-row
                // End row of the event we are comparing with.
                let compare-end = compare-dict.end-row
                // If the current event starts before the current compared
                // one ends, we have an intersection.
                if event-start <= compare-end {
                    // We add the intersection for both events.
                    week.at(di).at(cei).intersects.push(i)
                    week.at(di).at(i).intersects.push(cei)

                    // ---------- RECURSIVE HELPER FUNCTION ------------------
                    // Goes through a list of indices of events that are
                    // involved in an intersection and finds all other events
                    // they are each intersecting and so on.
                    let traverse-intersections(acc, arr) = {
                        for a in arr {
                            if a not in acc {
                                acc.push(a)
                                traverse-intersections(
                                    acc, week.at(di).at(a).intersects
                                )
                            }
                        }
                        acc
                    }
                    // -------------------------------------------------------

                    // The intersections in both events that are involved so
                    // far.
                    let cur-inters = (week.at(di).at(cei).intersects
                        + week.at(di).at(i).intersects
                    )

                    // tii (total-intersecting-indices) contains all indices
                    // that are in any way involved in an intersecting block of
                    // events.
                    let tii = traverse-intersections((), cur-inters)
                    // We then deduplicate the array and sort it so we always
                    // look at the earliest events first. This means that
                    // parallel events will always cascade down from topleft to
                    // bottom right in order of their starting times,
                    // regardless of order of input in the source file.
                    tii = tii.dedup().sorted(key: elem => {
                        week.at(di).at(elem).start-row
                    })

                    // How many events were part of the same block previously
                    // calculated. We only update it if this pass got more
                    // total events.
                    let prev-len = intersection-blocks.at(
                        str(tii.at(0)), default: ()
                    ).len()

                    // We update our current records of intersection blocks in
                    // the day.
                    if prev-len < tii.len() {
                        intersection-blocks.insert(str(tii.at(0)), tii)
                    }
                }
            }
        }

        // Now we compiled every index of the events involved in each
        // intersection block for that day and go through them individually.
        for tii in intersection-blocks.values() {
            // The number of events involved in the whole intersecting
            // block.
            let num-concurrent = tii.len()

            // Tracks how many events have been moved over into a
            // previous column to save space.
            let swap-num = 0
            // Tracks which event index is the currently furthest
            // "down" event for any parallel column. Starts with just
            // the first event in the whole block.
            let furthest-down = ()
            // Tracks how many day internal columns there are in total.
            let stack-num = 0
            // We go through all events in the intersecting block to
            // see which ones can be drawn under each other and which
            // have to be placed how far to the right in the parallel
            // coloumns.
            for (i, event-index) in tii.enumerate() {
                // Copy of the event we are looking at right now.
                let event = dict-array.at(event-index)

                // Tracks if a swap can be made.
                let swapped = false
                // Now look at all the most "down" placed events for
                // the parallel columns so far to see if the current
                // one can be swapped over into any previously opened
                // column.
                for (si, fi) in furthest-down.enumerate() {
                    // If the event that was furthest "down" so far
                    // doesn't intersect the event we are looking at
                    // now, then we can swap the current one into that
                    // column and stop looking further.
                    if event.start-row > dict-array.at(fi).end-row {
                        // Record there was a swap.
                        swapped = true
                        swap-num += 1
                        // Record where in the horizontal stack of
                        // parallel columns the event ended up.
                        week.at(di).at(event-index).insert(
                            "stack-pos", si
                        )
                        week.at(di).at(event-index).insert(
                            "swapped", swapped
                        )
                        week.at(di).at(event-index).insert(
                            "old-furthest", furthest-down
                        )
                        // Update the now furthest "down" event in the
                        // column.
                        furthest-down.at(si) = event-index
                        week.at(di).at(event-index).insert(
                            "new-furthest", furthest-down
                        )

                        break
                    }
                }

                // If no swap could be made, simply add the event as
                // the furthest down for a new parallel column and give
                // it a new highest stack position.
                if not swapped {
                    furthest-down.push(event-index)
                    week.at(di).at(event-index).insert(
                        "stack-pos", i - swap-num
                    )
                    week.at(di).at(event-index).insert(
                        "swapped", swapped
                    )
                    stack-num = stack-num + 1
                }
            }

            // Now that we recorded all the stack positions and how
            // many swaps were made, we can calculate how many parallel
            // columns are needed to render the intersection block and
            // the resulting single width colspan for all the events
            // involved.
            let num-parallels = num-concurrent - swap-num
            let base-cspan = int(day-col-division / num-parallels)

            // Then as the final step, we update the starting x
            // positions based on where in the stack an event is and
            // set the colspan to be maximised without intersecting
            // events on other columns.
            for event-index in tii {
                let sp = week.at(di).at(event-index).stack-pos
                week.at(di).at(event-index).start-col = (
                    start-x + sp * base-cspan
                )

                // sw is stack width, how many internal columns the
                // current event should end up spanning.
                let sw = 1

                // Check successive stack numbers to see if any of them
                // are open for the current event to expand into. As long as
                // no blocking event in further stacks is detected, the stack
                // width is expanded. Once a block is detected, both loops are
                // broken and the final colspan value is set.
                let i = sp + 1
                let blocked = false
                while i < stack-num {
                    for compare-index in tii.filter(
                        ei => week.at(di).at(ei).stack-pos == i
                    ) {
                        let e = week.at(di).at(event-index)
                        let c = week.at(di).at(compare-index)
                        if not (e.start-row > c.end-row
                            or e.end-row < c.start-row
                        ) {
                            blocked = true
                            break
                        }
                    }

                    if blocked {
                        break
                    }

                    sw = sw + 1
                    i = i + 1
                }

                week.at(di).at(event-index).colspan = base-cspan * sw
            }
        }
    }
    // =======================================================================

    // =========== HOUR LINE PRUNING AND CREATING CELLS FROM DICTS ===========
    // Now that all positions and dimensions are fixed, we go through the whole
    // week again to first remove hour line indication cells where they collide
    // with events and render the event dictionaries into proper grid cells.

    // Array for the final grid cells.
    let cells = ()
    for dict-array in week {
        for event-dict in dict-array {
            // Pruning the hour guide line cells.
            let start-x = event-dict.at("start-col")
            let rangenum = event-dict.at("colspan")
            for i in range(rangenum) {
                let xv = start-x + i
                for h in hour-y-values {
                    let start-y = event-dict.at("start-row")
                    if h >= start-y and h <= start-y + event-dict.at("rownum") {
                        hour-line-cells.remove(
                            // We need the default here since the loop tries
                            // to remove hour lines even if they aren't
                            // there due to day or hour limitations.
                            str(xv) + "." + str(h), default: none
                        )
                    }
                }
            }

            // This is the actual cell being added to the grid.
            cells.push(grid.cell(x: event-dict.at("start-col"),
                y: event-dict.at("start-row"),
                fill: event-dict.at("color"),
                rowspan: event-dict.at("rownum"),
                colspan: event-dict.at("colspan"),
                stroke: stroke,
                event-dict.at("content"))
            )
        }
    }
    // -----------------------------------------------------------------------

    // ============================= TITLE ===================================
    // Adding the actual title cell plus its' row info.
    if title != none {
        // The title row takes up three times height as much as the header.
        row-array.insert(0, auto)
        header-row.push(grid.cell(x: 0, y: 0, colspan: real-colnum,
            stroke: none, fill: none, inset: title-font-size * 0.55,
            text(size: title-font-size, weight: "bold", title)
        ))
    }
    // -----------------------------------------------------------------------

    // ========================== FINAL GRID FILLING =========================
    rect(stroke: border, inset: margin, fill: background, width: width,
        height: height,
        grid(columns: col-array, rows: row-array,
            align: (x, y) => if x == 0 and y > y-start - 1 {
                center + top
            } else {
                center + horizon
            }, inset: 0.35em, stroke: (x, y) => if y == y-start - 1 {
                0.5pt
            } else if calc.rem(x - 1, day-col-division) == 0 {
                (left: 0.5pt, rest: none)
            } else if x == real-colnum - 1 {
                (right: 0.5pt, rest: none)
            }, fill: (x, y) => if y < y-start or x == 0 {
                info-fill
            } else {
                empty-fill
            },
            // Title (if given) and day names
            ..header-row,
            // Bottom border of the whole time table.
            grid.hline(y: (hournum + 1) * 12 + y-start, stroke: 0.5pt),
            // Hour guidelines
            ..hour-line-cells.values(),
            // Time indication cells on the left of the time table.
            ..time-cell-array,
            // Actual content cells.
            ..cells
        )
    )
    // -----------------------------------------------------------------------
}

// Alternative german name for the function.
#let stundenplan(..args) = timetable(..args)
