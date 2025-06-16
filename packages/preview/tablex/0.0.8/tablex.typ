// Welcome to tablex!
// Feel free to contribute with any features you think are missing.
// Version: v0.0.8

// -- table counter --

#let _tablex-table-counter = counter("_tablex-table-counter")

// -- compat --

// get the types of things so we can compare with them
// (0.2.0-0.7.0: they're strings; 0.8.0+: they're proper types)
#let _array-type = type(())
#let _dict-type = type((a: 5))
#let _bool-type = type(true)
#let _str-type = type("")
#let _color-type = type(red)
#let _stroke-type = type(red + 5pt)
#let _length-type = type(5pt)
#let _rel-len-type = type(100% + 5pt)
#let _ratio-type = type(100%)
#let _int-type = type(5)
#let _float-type = type(5.0)
#let _fraction-type = type(5fr)
#let _function-type = type(x => x)
#let _content-type = type([])
// note: since 0.8.0, alignment and 2d alignment are the same
// but keep it like this for pre-0.8.0
#let _align-type = type(left)
#let _2d-align-type = type(top + left)

// If types aren't strings, this means we're using 0.8.0+.
#let using-typst-v080-or-later = str(type(_str-type)) == "type"

// Attachments use "t" and "b" instead of "top" and "bottom" since v0.3.0.
#let using-typst-v030-or-later = using-typst-v080-or-later or $a^b$.body.has("t")

// This is true if types have fields in the current Typst version.
// This means we can use stroke.thickness, length.em, and so on.
#let typst-fields-supported = using-typst-v080-or-later

// This is true if calc.rem exists in the current Typst version.
// Otherwise, we use a polyfill.
#let typst-calc-rem-supported = using-typst-v030-or-later

// Remainder operation.
#let calc-mod = if typst-calc-rem-supported {
  calc.rem
} else {
  (a, b) => calc.floor(a) - calc.floor(b * calc.floor(a / b))
}

// Returns the sign of the operand.
// -1 for negative, 1 for positive or zero.
#let calc-sign(x) = {
  // For positive: true - false = 1 - 0 = 1
  // For zero: true - false = 1 - 0 = 1
  // For negative: false - true = 0 - 1 = -1
  int(0 <= x) - int(x < 0)
}

// Polyfill for array sum (.sum() is Typst 0.3.0+).
#let array-sum(arr, zero: 0) = {
  arr.fold(zero, (a, x) => a + x)
}

// -- common validators --

// Converts the 'fit-spans' argument to a (x: bool, y: bool) dictionary.
// Optionally use a default dictionary to fill missing arguments with.
// This is in the common section as it is needed by the grid section as well.
#let validate-fit-spans(fit-spans, default: (x: false, y: false), error-prefix: none) = {
  if type(error-prefix) == _str-type {
    error-prefix = " " + error-prefix
  } else {
    error-prefix = ""
  }
  if type(fit-spans) == _bool-type {
    fit-spans = (x: fit-spans, y: fit-spans)
  }
  if type(fit-spans) == _dict-type {
    assert(fit-spans.len() > 0, message: "Tablex error:" + error-prefix + " 'fit-spans', if a dictionary, must not be empty.")
    assert(fit-spans.keys().all(k => k in ("x", "y")), message: "Tablex error:" + error-prefix + " 'fit-spans', if a dictionary, must only have the keys x and y.")
    assert(fit-spans.values().all(v => type(v) == _bool-type), message: "Tablex error:" + error-prefix + " keys 'x' and 'y' in the 'fit-spans' dictionary must be booleans (true/false).")
    for key in ("x", "y") {
      if key in default and key not in fit-spans {
        fit-spans.insert(key, default.at(key))
      }
    }
  } else {
    panic("Tablex error:" + error-prefix + " Expected 'fit-spans' to be either a boolean or dictionary, found '" + str(type(fit-spans)) + "'")
  }
  fit-spans
}

// ------------

// -- types --

#let hlinex(
    start: 0, end: auto, y: auto,
    stroke: auto,
    stop-pre-gutter: auto, gutter-restrict: none,
    stroke-expand: true,
    expand: none
) = (
    tablex-dict-type: "hline",
    start: start,
    end: end,
    y: y,
    stroke: stroke,
    stop-pre-gutter: stop-pre-gutter,
    gutter-restrict: gutter-restrict,
    stroke-expand: stroke-expand,
    expand: expand,
    parent: none,  // if hline was broken into multiple
)

#let vlinex(
    start: 0, end: auto, x: auto,
    stroke: auto,
    stop-pre-gutter: auto, gutter-restrict: none,
    stroke-expand: true,
    expand: none
) = (
    tablex-dict-type: "vline",
    start: start,
    end: end,
    x: x,
    stroke: stroke,
    stop-pre-gutter: stop-pre-gutter,
    gutter-restrict: gutter-restrict,
    stroke-expand: stroke-expand,
    expand: expand,
    parent: none,
)

#let cellx(content,
    x: auto, y: auto,
    rowspan: 1, colspan: 1,
    fill: auto, align: auto,
    inset: auto,
    fit-spans: auto
) = (
    tablex-dict-type: "cell",
    content: content,
    rowspan: rowspan,
    colspan: colspan,
    align: align,
    fill: fill,
    inset: inset,
    fit-spans: fit-spans,
    x: x,
    y: y,
)

#let occupied(x: 0, y: 0, parent_x: none, parent_y: none) = (
    tablex-dict-type: "occupied",
    x: x,
    y: y,
    parent_x: parent_x,
    parent_y: parent_y
)

// -- end: types --

// -- type checks, transformers and validators --

// Is this a valid dict created by this library?
#let is-tablex-dict(x) = (
    type(x) == _dict-type
        and "tablex-dict-type" in x
)

#let is-tablex-dict-type(x, ..dict_types) = (
    is-tablex-dict(x)
        and x.tablex-dict-type in dict_types.pos()
)

#let is-tablex-cell(x) = is-tablex-dict-type(x, "cell")
#let is-tablex-hline(x) = is-tablex-dict-type(x, "hline")
#let is-tablex-vline(x) = is-tablex-dict-type(x, "vline")
#let is-some-tablex-line(x) = is-tablex-dict-type(x, "hline", "vline")
#let is-tablex-occupied(x) = is-tablex-dict-type(x, "occupied")

#let table-item-convert(item, keep_empty: true) = {
    if type(item) == _function-type {  // dynamic cell content
        cellx(item)
    } else if keep_empty and item == () {
        item
    } else if type(item) != _dict-type or "tablex-dict-type" not in item {
        cellx[#item]
    } else {
        item
    }
}

#let rowspanx(length, content, ..cell_options) = {
    if is-tablex-cell(content) {
        (..content, rowspan: length, ..cell_options.named())
    } else {
        cellx(
            content,
            rowspan: length,
            ..cell_options.named())
    }
}

#let colspanx(length, content, ..cell_options) = {
    if is-tablex-cell(content) {
        (..content, colspan: length, ..cell_options.named())
    } else {
        cellx(
            content,
            colspan: length,
            ..cell_options.named())
    }
}

// Get expected amount of cell positions
// in the table (considering colspan and rowspan)
#let get-expected-grid-len(items, col_len: 0) = {
    let len = 0

    // maximum explicit 'y' specified
    let max_explicit_y = items
        .filter(c => c.y != auto)
        .fold(0, (acc, cell) => {
            if (is-tablex-cell(cell)
                    and type(cell.y) in (_int-type, _float-type)
                    and cell.y > acc) {
                cell.y
            } else {
                acc
            }
        })

    for item in items {
        if is-tablex-cell(item) and item.x == auto and item.y == auto {
            // cell occupies (colspan * rowspan) spaces
            len += item.colspan * item.rowspan
        } else if type(item) == _content-type {
            len += 1
        }
    }

    let rows(len) = calc.ceil(len / col_len)

    while rows(len) < max_explicit_y {
        len += col_len
    }

    len
}

// Check if this length is infinite.
#let is-infinite-len(len) = {
    type(len) in (_ratio-type, _fraction-type, _rel-len-type, _length-type) and "inf" in repr(len)
}

// Check if this is a valid color (color, gradient or pattern).
#let is-color(val) = {
    type(val) == _color-type or str(type(val)) in ("gradient", "pattern")
}

#let validate-cols-rows(columns, rows, items: ()) = {
    if type(columns) == _int-type {
        assert(columns >= 0, message: "Error: Cannot have a negative amount of columns.")

        columns = (auto,) * columns
    }

    if type(rows) == _int-type {
        assert(rows >= 0, message: "Error: Cannot have a negative amount of rows.")
        rows = (auto,) * rows
    }

    if type(columns) != _array-type {
        columns = (columns,)
    }

    if type(rows) != _array-type {
        rows = (rows,)
    }

    // default empty column to a single auto column
    if columns.len() == 0 {
        columns = (auto,)
    }

    // default empty row to a single auto row
    if rows.len() == 0 {
        rows = (auto,)
    }

    let col_row_is_valid(col_row) = (
        (not is-infinite-len(col_row)) and (col_row == auto or type(col_row) in (
            _fraction-type, _length-type, _rel-len-type, _ratio-type
            ))
    )

    if not columns.all(col_row_is_valid) {
        panic("Invalid column sizes (must all be 'auto' or a valid, finite length specifier).")
    }

    if not rows.all(col_row_is_valid) {
        panic("Invalid row sizes (must all be 'auto' or a valid, finite length specifier).")
    }

    let col_len = columns.len()

    let grid_len = get-expected-grid-len(items, col_len: col_len)

    let expected_rows = calc.ceil(grid_len / col_len)

    // more cells than expected => add rows
    if rows.len() < expected_rows {
        let missing_rows = expected_rows - rows.len()

        rows += (rows.last(),) * missing_rows
    }

    (columns: columns, rows: rows, items: ())
}

// -- end: type checks and validators --

// -- utility functions --

// Which positions does a cell occupy
// (Usually just its own, but increases if colspan / rowspan
// is greater than 1)
#let positions-spanned-by(cell, x: 0, y: 0, x_limit: 0, y_limit: none) = {
    let result = ()
    let rowspan = if "rowspan" in cell { cell.rowspan } else { 1 }
    let colspan = if "colspan" in cell { cell.colspan } else { 1 }

    if rowspan < 1 {
        panic("Cell rowspan must be 1 or greater (bad cell: " + repr((x, y)) + ")")
    } else if colspan < 1 {
        panic("Cell colspan must be 1 or greater (bad cell: " + repr((x, y)) + ")")
    }

    let max_x = x + colspan
    let max_y = y + rowspan

    if x_limit != none {
        max_x = calc.min(x_limit, max_x)
    }

    if y_limit != none {
        max_y = calc.min(y_limit, max_y)
    }

    for x in range(x, max_x) {
        for y in range(y, max_y) {
            result.push((x, y))
        }
    }

    result
}

// initialize an array with a certain element or init function, repeated
#let init-array(amount, element: none, init_function: none) = {
    let nones = ()

    if init_function == none {
        init_function = () => element
    }

    range(amount).map(i => init_function())
}

// Default 'x' to a certain value if it is equal to the forbidden value
// ('none' by default)
#let default-if-not(x, default, if_isnt: none) = {
    if x == if_isnt {
        default
    } else {
        x
    }
}

// Default 'x' to a certain value if it is none
#let default-if-none(x, default) = default-if-not(x, default, if_isnt: none)

// Default 'x' to a certain value if it is auto
#let default-if-auto(x, default) = default-if-not(x, default, if_isnt: auto)

// Default 'x' to a certain value if it is auto or none
#let default-if-auto-or-none(x, default) = if x in (auto, none) {
    default
} else {
    x
}

// The max between a, b, or the other one if either is 'none'.
#let max-if-not-none(a, b) = if a in (none, auto) {
    b
} else if b in (none, auto) {
    a
} else {
    calc.max(a, b)
}

// Gets the topmost parent of a line.
#let get-top-parent(line) = {
    let previous = none
    let current = line

    while current != none {
        previous = current
        current = previous.parent
    }

    previous
}

// Typst 0.9.0 uses a minus sign ("−"; U+2212 MINUS SIGN) for negative numbers.
// Before that, it used a hyphen minus ("-"; U+002D HYPHEN MINUS), so we use
// regex alternation to match either of those.
#let NUMBER-REGEX-STRING = "(?:−|-)?\\d*\\.?\\d+"

// Check if the given length has type '_length-type' and no 'em' component.
#let is-purely-pt-len(len) = {
    type(len) == _length-type and "em" not in repr(len)
}

// Measure a length in pt by drawing a line and using the measure() function.
// This function will work for negative lengths as well.
//
// Note that for ratios, the measurement will be 0pt due to limitations of
// the "draw and measure" technique (wrapping the line in a box still returns 0pt;
// not sure if there is any viable way to measure a ratio). This also affects
// relative lengths — this function will only be able to measure the length component.
//
// styles: from style()
#let measure-pt(len, styles) = {
    if typst-fields-supported {
        // We can use fields to separate em from pt.
        let pt = len.abs
        let em = len.em
        // Measure with abs (and later multiply by the sign) so negative em works.
        // Otherwise it would return 0pt, and we would need to measure again with abs.
        let measured-em = calc-sign(em) * measure(box(width: calc.abs(em) * 1em), styles).width

        return pt + measured-em
    }

    // Fields not supported, so we have to measure twice when em can be negative.
    let measured-pt = measure(box(width: len), styles).width

    // If the measured length is positive, `len` must have overall been positive.
    // There's nothing else to be done, so return the measured length.
    if measured-pt > 0pt {
        return measured-pt
    }

    // If we've reached this point, the previously measured length must have been `0pt`
    // (drawing a line with a negative length will draw nothing, so measuring it will return `0pt`).
    // Hence, `len` must either be `0pt` or negative.
    // We multiply `len` by -1 to get a positive length, draw a line and measure it, then negate
    // the measured length. This nicely handles the `0pt` case as well.
    measured-pt = -measure(box(width: -len), styles).width
    return measured-pt
}

// Convert a length of type length to pt.
//
// styles: from style()
#let convert-length-type-to-pt(len, styles: none) = {
    // repr examples: "1pt", "1em", "0.5pt", "0.5em", "1pt + 1em", "-0.5pt + -0.5em"
    if is-purely-pt-len(len) {
        // No need to do any conversion because it must already be in pt.
        return len
    }

    // At this point, we will need to draw a line for measurement,
    // so we need the styles.
    if styles == none {
        panic("Cannot convert length to pt ('styles' not specified).")
    }

    return measure-pt(len, styles)
}

// Convert a ratio type length to pt
//
// page-size: equivalent to 100%
#let convert-ratio-type-to-pt(len, page-size) = {
    assert(
        is-purely-pt-len(page-size),
        message: "'page-size' should be a purely pt length"
    )

    if page-size == none {
        panic("Cannot convert ratio to pt ('page-size' not specified).")
    }

    if is-infinite-len(page-size) {
        return 0pt  // page has 'auto' size => % should return 0
    }

    ((len / 1%) / 100) * page-size + 0pt  // e.g. 100% / 1% = 100; / 100 = 1; 1 * page-size
}

// Convert a fraction type length to pt
//
// frac-amount: amount of 'fr' specified
// frac-total: total space shared by fractions
#let convert-fraction-type-to-pt(len, frac-amount, frac-total) = {
    assert(
        is-purely-pt-len(frac-total),
        message: "'frac-total' should be a purely pt length"
    )

    if frac-amount == none {
        panic("Cannot convert fraction to pt ('frac-amount' not specified).")
    }

    if frac-total == none {
        panic("Cannot convert fraction to pt ('frac-total' not specified).")
    }

    if frac-amount <= 0 or is-infinite-len(frac-total) {
        return 0pt
    }

    let len-per-frac = frac-total / frac-amount

    (len-per-frac * (len / 1fr)) + 0pt
}

// Convert a relative type length to pt
//
// styles: from style()
// page-size: equivalent to 100% (optional because the length may not have a ratio component)
#let convert-relative-type-to-pt(len, styles, page-size: none) = {
    if typst-fields-supported or eval(repr(0.00005em)) != 0.00005em {
        // em repr changed in 0.11.0 => need to use fields here
        // or use fields if they're supported anyway
        return convert-ratio-type-to-pt(len.ratio, page-size) + convert-length-type-to-pt(len.length, styles: styles)
    }

    // We will need to draw a line for measurement later,
    // so we need the styles.
    if styles == none {
        panic("Cannot convert relative length to pt ('styles' not specified).")
    }

    // Note on precision: the `repr` for em components is precise, unlike
    // other length components, which are rounded to a precision of 2.
    // This is true up to Typst 0.9.0 and possibly later versions.
    let em-regex = regex(NUMBER-REGEX-STRING + "em")
    let em-part-repr = repr(len).find(em-regex)

    // Calculate the length minus its em component.
    // E.g., 1% + 1pt + 1em -> 1% + 1pt
    let (em-part, len-minus-em) = if em-part-repr == none {
        (0em, len)
    } else {
        // SAFETY: guaranteed to be a purely em length by regex
        let em-part = eval(em-part-repr)
        (em-part, len - em-part)
    }

    // This will give only the pt part of the length.
    // E.g., 1% + 1pt -> 1pt
    // See the documentation on measure-pt for more information.
    let pt-part = measure-pt(len-minus-em, styles)

    // Since we have the values of the em and pt components,
    // we can calculate the ratio part.
    let ratio-part = len-minus-em - pt-part
    let ratio-part-pt = if ratio-part == 0% {
        // No point doing `convert-ratio-type-to-pt` if there's no ratio component.
        0pt
    } else {
        convert-ratio-type-to-pt(ratio-part, page-size)
    }

    // The length part is the pt part + em part.
    // Note: we cannot use `len - ratio-part` as that returns a `_rel-len-type` value,
    // not a `_length-type` value.
    let length-part-pt = convert-length-type-to-pt(pt-part + em-part, styles: styles)

    ratio-part-pt + length-part-pt
}

// Convert a certain (non-relative) length to pt
//
// styles: from style()
// page-size: equivalent to 100%
// frac-amount: amount of 'fr' specified
// frac-total: total space shared by fractions
#let convert-length-to-pt(
    len,
    styles: none, page-size: none, frac-amount: none, frac-total: none
) = {
    page-size = 0pt + page-size

    if is-infinite-len(len) {
        0pt  // avoid the destruction of the universe
    } else if type(len) == _length-type {
        convert-length-type-to-pt(len, styles: styles)
    } else if type(len) == _ratio-type {
        convert-ratio-type-to-pt(len, page-size)
    } else if type(len) == _fraction-type {
        convert-fraction-type-to-pt(len, frac-amount, frac-total)
    } else if type(len) == _rel-len-type {
        convert-relative-type-to-pt(len, styles, page-size: page-size)
    } else {
        panic("Cannot convert '" + type(len) + "' to length.")
    }
}

// Convert a stroke to its thickness
#let stroke-len(stroke, stroke-auto: 1pt, styles: none) = {
    let no-ratio-error = "Tablex error: Stroke cannot be a ratio or relative length (i.e. have a percentage like '53%'). Try using the layout() function (or similar) to convert the percentage to 'pt' instead."
    let stroke = default-if-auto(stroke, stroke-auto)
    if type(stroke) == _length-type {
        convert-length-to-pt(stroke, styles: styles)
    } else if type(stroke) in (_rel-len-type, _ratio-type) {
        panic(no-ratio-error)
    } else if is-color(stroke) {
        1pt
    } else if type(stroke) == _stroke-type {
        if typst-fields-supported {
            // No need for any repr() parsing, just use the thickness field.
            let thickness = default-if-auto(stroke.thickness, 1pt)
            return convert-length-to-pt(thickness, styles: styles)
        }

        // support:
        // - 2pt / 2em / 2cm / 2in   + color
        // - 2.5pt / 2.5em / ...  + color
        // - 2pt + 3em   + color
        let len-regex = "(?:" + NUMBER-REGEX-STRING + "(?:em|pt|cm|in|%)(?:\\s+\\+\\s+" + NUMBER-REGEX-STRING + "em)?)"
        let r = regex("^" + len-regex)
        let s = repr(stroke).find(r)

        if s == none {
            // for more complex strokes, built through dictionaries
            // => "thickness: 5pt" field
            // note: on typst v0.7.0 or later, can just use 's.thickness'
            let r = regex("thickness: (" + len-regex + ")")
            s = repr(stroke).match(r)
            if s != none {
                s = s.captures.first();  // get the first match (the thickness)
            }
        }

        if s == none {
            1pt  // okay it's probably just a color then
        } else {
            let len = eval(s)
            if type(len) == _length-type {
                convert-length-to-pt(len, styles: styles)
            } else if type(len) in (_rel-len-type, _ratio-type) {
                panic(no-ratio-error)
            } else {
                1pt  // should be unreachable
            }
        }
    } else if type(stroke) == _dict-type and "thickness" in stroke {
        let thickness = stroke.thickness
        if type(thickness) == _length-type {
            convert-length-to-pt(thickness, styles: styles)
        } else if type(thickness) in (_rel-len-type, _ratio-type) {
            panic(no-ratio-error)
        } else {
            1pt
        }
    } else {
        1pt
    }
}

// --- end: utility functions ---


// --- grid functions ---

#let create-grid(width, initial_height) = (
    tablex-dict-type: "grid",
    items: init-array(width * initial_height),
    width: width
)

#let is-tablex-grid(value) = is-tablex-dict-type("grid")

// Gets the index of (x, y) in a grid's array.
#let grid-index-at(x, y, grid: none, width: none) = {
    width = default-if-none(grid, (width: width)).width
    width = calc.floor(width)
    (y * width) + calc-mod(x, width)
}

// Gets the cell at the given grid x, y position.
// Width (amount of columns) per line must be known.
// E.g. grid-at(grid, 5, 2, width: 7)  => 5th column, 2nd row  (7 columns per row)
#let grid-at(grid, x, y) = {
    let index = grid-index-at(x, y, width: grid.width)

    if index < grid.items.len() {
        grid.items.at(index)
    } else {
        none
    }
}

// Returns 'true' if the cell at (x, y)
// exists in the grid.
#let grid-has-pos(grid, x, y) = (
    grid-index-at(x, y, grid: grid) < grid.items.len()
)

// How many rows are in this grid? (Given its width)
#let grid-count-rows(grid) = (
    calc.floor(grid.items.len() / grid.width)
)

// Converts a grid array index to (x, y)
#let grid-index-to-pos(grid, index) = (
    (calc-mod(index, grid.width), calc.floor(index / grid.width))
)

// Fetches an entire row of cells (all positions with the given y).
#let grid-get-row(grid, y) = {
    let len = grid.items.len()
    // position of the first cell in that row.
    let first-row-pos = grid-index-at(0, y, grid: grid)
    if len <= first-row-pos {
        // grid isn't large enough, so no row to return
        (none,) * grid.width
    } else {
        // position right after the last cell in this row
        let next-row-pos = first-row-pos + grid.width
        let cell-row = grid.items.slice(first-row-pos, calc.min(len, next-row-pos))
        let cell-row-len = cell-row.len()
        if cell-row-len < grid.width {
            // the row isn't complete because the grid wasn't large enough.
            let missing-cells = (none,) * (grid.width - cell-row-len)
            cell-row += missing-cells
        }
        cell-row
    }
}

// Fetches an entire column of cells (all positions with the given x).
#let grid-get-column(grid, x) = {
    range(grid-count-rows(grid)).map(y => grid-at(grid, x, y))
}

// Expand grid to the given coords (add the missing cells)
#let grid-expand-to(grid, x, y, fill_with: (grid) => none) = {
    let rows = grid-count-rows(grid)
    let rowws = rows

    // quickly add missing rows
    while rows < y {
        grid.items += (fill_with(grid),) * grid.width
        rows += 1
    }

    let now = grid-index-to-pos(grid, grid.items.len() - 1)
    // now columns and/or last missing row
    while not grid-has-pos(grid, x, y) {
        grid.items.push(fill_with(grid))
    }
    let new = grid-index-to-pos(grid, grid.items.len() - 1)

    grid
}

// if occupied (extension of a cell) => get the cell that generated it.
// if a normal cell => return it, untouched.
#let get-parent-cell(cell, grid: none) = {
    if is-tablex-occupied(cell) {
        grid-at(grid, cell.parent_x, cell.parent_y)
    } else if is-tablex-cell(cell) {
        cell
    } else {
        panic("Cannot get parent table cell of a non-cell object: " + repr(cell))
    }
}

// Return the next position available on the grid
#let next-available-position(
    grid, x: 0, y: 0, x_limit: 0, y_limit: 0
) = {
    let cell = (x, y)
    let there_is_next(cell_pos) = {
        let grid_cell = grid-at(grid, ..cell_pos)
        grid_cell != none
    }

    while there_is_next(cell) {
        x += 1

        if x >= x_limit {
            x = 0
            y += 1
        }

        cell = (x, y)

        if y >= y_limit {  // last row reached - stop
            break
        }
    }

    cell
}

// Organize cells in a grid from the given items,
// and also get all given lines
#let generate-grid(items, x_limit: 0, y_limit: 0, map-cells: none, fit-spans: none) = {
    // init grid as a matrix
    // y_limit  x   x_limit
    let grid = create-grid(x_limit, y_limit)

    let grid-index-at = grid-index-at.with(width: x_limit)

    let hlines = ()
    let vlines = ()

    let prev_x = 0
    let prev_y = 0

    let x = 0
    let y = 0

    let first_cell_reached = false  // if true, hline should always be placed after the current row
    let row_wrapped = false  // if true, a vline should be added to the end of a row

    let range_of_items = range(items.len())

    let new_empty_cell(grid, index: auto) = {
        let empty_cell = cellx[]
        let index = default-if-auto(index, grid.items.len())
        let new_cell_pos = grid-index-to-pos(grid, index)
        empty_cell.x = new_cell_pos.at(0)
        empty_cell.y = new_cell_pos.at(1)

        empty_cell
    }

    // go through all input
    for i in range_of_items {
        let item = items.at(i)

        // allow specifying () to change vline position
        if type(item) == _array-type and item.len() == 0 {
            if x == 0 and y == 0 {  // increment vline's secondary counter
                prev_x += 1
            }

            continue  // ignore all '()'
        }

        let item = table-item-convert(item)


        if is-some-tablex-line(item) {  // detect lines' x, y
            if is-tablex-hline(item) {
                let this_y = if first_cell_reached {
                    prev_y + 1
                } else {
                    prev_y
                }

                item.y = default-if-auto(item.y, this_y)

                hlines.push(item)
            } else if is-tablex-vline(item) {
                if item.x == auto {
                    if x == 0 and y == 0 {  // placed before any elements
                        item.x = prev_x
                        prev_x += 1  // use this as a 'secondary counter'
                                     // in the meantime

                        if prev_x > x_limit + 1 {
                            panic("Error: Specified way too many vlines or empty () cells before the first row of the table. (Note that () is used to separate vline()s at the beginning of the table.)  Please specify at most " + str(x_limit + 1) + " empty cells or vlines before the first cell of the table.")
                        }
                    } else if row_wrapped {
                        item.x = x_limit  // allow v_line at the last column
                        row_wrapped = false
                    } else {
                        item.x = x
                    }
                }

                vlines.push(item)
            } else {
                panic("Invalid line received (must be hline or vline).")
            }
            items.at(i) = item  // override item with the new x / y coord set
            continue
        }

        let cell = item

        assert(is-tablex-cell(cell), message: "All table items must be cells or lines.")

        first_cell_reached = true

        let this_x = default-if-auto(cell.x, x)
        let this_y = default-if-auto(cell.y, y)

        if cell.x == none or cell.y == none {
            panic("Error: Received cell with 'none' as x or y.")
        }

        if this_x == none or this_y == none {
            panic("Internal tablex error: Grid wasn't large enough to fit the given cells. (Previous position: " + repr((prev_x, prev_y)) + ", new cell: " + repr(cell) + ")")
        }

        cell.x = this_x
        cell.y = this_y

        if type(map-cells) == _function-type {
            cell = table-item-convert(map-cells(cell))
        }

        assert(is-tablex-cell(cell), message: "Tablex error: 'map-cells' returned something that isn't a valid cell.")

        if row_wrapped {
            row_wrapped = false
        }

        let content = cell.content
        let content = if type(content) == _function-type {
            let res = content(this_x, this_y)
            if is-tablex-cell(res) {
                cell = res
                this_x = cell.x
                this_y = cell.y
                [#res.content]
            } else {
                [#res]
            }
        } else {
            [#content]
        }

        if this_x == none or this_y == none {
            panic("Error: Cell with function as content returned another cell with 'none' as x or y!")
        }

        if type(this_x) != _int-type or type(this_y) != _int-type {
            panic("Error: Cell coordinates must be integers. Invalid pair: " + repr((this_x, this_y)))
        }

        cell.content = content

        // resolve 'fit-spans' option for this cell
        if "fit-spans" not in cell {
            cell.fit-spans = auto
        } else if cell.fit-spans != auto {
            cell.fit-spans = validate-fit-spans(cell.fit-spans, default: fit-spans, error-prefix: "At cell (" + str(this_x) + ", " + str(this_y) + "):")
        }

        // up to which 'y' does this cell go
        let max_x = this_x + cell.colspan - 1
        let max_y = this_y + cell.rowspan - 1

        if this_x >= x_limit {
            panic("Error: Cell at " + repr((this_x, this_y)) + " is placed at an inexistent column.")
        }

        if max_x >= x_limit {
            panic("Error: Cell at " + repr((this_x, this_y)) + " has a colspan of " + repr(cell.colspan) + ", which would exceed the available columns.")
        }

        let cell_positions = positions-spanned-by(cell, x: this_x, y: this_y, x_limit: x_limit, y_limit: none)

        for position in cell_positions {
            let (px, py) = position
            let currently_there = grid-at(grid, px, py)

            if currently_there != none {
                let parent_cell = get-parent-cell(currently_there, grid: grid)

                panic("Error: Multiple cells attempted to occupy the cell position at " + repr((px, py)) + ": one starting at " + repr((this_x, this_y)) + ", and one starting at " + repr((parent_cell.x, parent_cell.y)))
            }

            // initial position => assign it to the cell's x/y
            if position == (this_x, this_y) {
                cell.x = this_x
                cell.y = this_y

                // expand grid to allow placing this cell (including colspan / rowspan)
                let grid_expand_res = grid-expand-to(grid, grid.width - 1, max_y)

                grid = grid_expand_res
                y_limit = grid-count-rows(grid)

                let index = grid-index-at(this_x, this_y)

                if index > grid.items.len() {
                    panic("Internal tablex error: Could not expand grid to include cell at " + repr((this_x, this_y)))
                }
                grid.items.at(index) = cell
                items.at(i) = cell

            // other secondary position (from colspan / rowspan)
            } else {
                let index = grid-index-at(px, py)

                grid.items.at(index) = occupied(x: px, y: py, parent_x: this_x, parent_y: this_y)  // indicate this position's parent cell (to join them later)
            }
        }

        let next_pos = next-available-position(grid, x: this_x, y: this_y, x_limit: x_limit, y_limit: y_limit)

        prev_x = this_x
        prev_y = this_y

        x = next_pos.at(0)
        y = next_pos.at(1)

        if prev_y != y {
            row_wrapped = true  // we changed rows!
        }
    }

    // for missing cell positions: add empty cell
    for (index, item) in grid.items.enumerate() {
        if item == none {
            grid.items.at(index) = new_empty_cell(grid, index: index)
        }
    }

    // while there are incomplete rows for some reason, add empty cells
    while calc-mod(grid.items.len(), grid.width) != 0 {
        grid.items.push(new_empty_cell(grid))
    }

    (
        grid: grid,
        items: grid.items,
        hlines: hlines,
        vlines: vlines,
        new_row_count: grid-count-rows(grid)
    )
}

// -- end: grid functions --

// -- col/row size functions --

// Makes a cell's box, using the given options
// cell - The cell data (including content)
// width, height - The cell's dimensions
// inset - The table's inset
// align_default - The default alignment if the cell doesn't specify one
// fill_default - The default fill color / etc if the cell doesn't specify one
#let make-cell-box(
        cell,
        width: 0pt, height: 0pt, inset: 5pt,
        align_default: left,
        fill_default: none) = {

    let align_default = if type(align_default) == _function-type {
        align_default(cell.x, cell.y)  // column, row
    } else {
        align_default
    }

    let fill_default = if type(fill_default) == _function-type {
        fill_default(cell.x, cell.y)  // row, column
    } else {
        fill_default
    }

    let content = cell.content

    let inset = default-if-auto(cell.inset, inset)

    // use default align (specified in
    // table 'align:')
    // when the cell align is 'auto'
    let cell_align = default-if-auto(cell.align, align_default)

    // same here for fill
    let cell_fill = default-if-auto(cell.fill, fill_default)

    if type(cell_fill) == _array-type {
        let fill_len = cell_fill.len()

        if fill_len == 0 {
            // no fill values specified
            // => no fill
            cell_fill = none
        } else if cell.x == auto {
            // for some reason the cell x wasn't yet
            // determined => just take the last
            // fill value
            cell_fill = cell_fill.last()
        } else {
            // use mod to make the fill value pattern
            // repeat if there are more columns than
            // fill values.
            cell_fill = cell_fill.at(calc-mod(cell.x, fill_len))
        }
    }

    if cell_fill != none and not is-color(cell_fill) {
        panic("Tablex error: Invalid fill specified (must be either a function (column, row) -> fill, a color, an array of valid fill values, or 'none').")
    }

    if type(cell_align) == _array-type {
        let align_len = cell_align.len()

        if align_len == 0 {
            // no alignment values specified
            // => inherit from outside
            cell_align = auto
        } else if cell.x == auto {
            // for some reason the cell x wasn't yet
            // determined => just take the last
            // alignment value
            cell_align = cell_align.last()
        } else {
            // use mod to make the align value pattern
            // repeat if there are more columns than
            // align values.
            cell_align = cell_align.at(calc-mod(cell.x, align_len))
        }
    }

    if cell_align != auto and type(cell_align) not in (_align-type, _2d-align-type) {
        panic("Tablex error: Invalid alignment specified (must be either a function (column, row) -> alignment, an alignment value - such as 'left' or 'center + top' -, an array of alignment values (one for each column), or 'auto').")
    }

    let aligned_cell_content = if cell_align == auto {
        [#content]
    } else {
        align(cell_align)[#content]
    }

    if is-infinite-len(inset) {
        panic("Tablex error: inset must not be infinite")
    }

    box(
        width: width, height: height,
        inset: inset, fill: cell_fill,
        // avoid #set problems
        baseline: 0pt,
        outset: 0pt, radius: 0pt, stroke: none,
        aligned_cell_content)
}

// Sums the sizes of fixed-size tracks (cols/rows). Anything else
// (auto, 1fr, ...) is ignored.
#let sum-fixed-size-tracks(tracks) = {
    tracks.fold(0pt, (acc, el) => {
        if type(el) == _length-type {
            acc + el
        } else {
            acc
        }
    })
}

// Calculate the size of fraction tracks (cols/rows) (1fr, 2fr, ...),
// based on the remaining sizes (after fixed-size and auto columns)
#let determine-frac-tracks(tracks, remaining: 0pt, gutter: none) = {
    let frac-tracks = tracks.enumerate().filter(t => type(t.at(1)) == _fraction-type)

    let amount-frac = frac-tracks.fold(0, (acc, el) => acc + (el.at(1) / 1fr))

    if type(gutter) == _fraction-type {
        amount-frac += (gutter / 1fr) * (tracks.len() - 1)
    }

    let frac-width = if amount-frac > 0 and not is-infinite-len(remaining) {
        remaining / amount-frac
    } else {
        0pt
    }

    if type(gutter) == _fraction-type {
        gutter = frac-width * (gutter / 1fr)
    }

    for (i, size) in frac-tracks {
        tracks.at(i) = frac-width * (size / 1fr)
    }

    (tracks: tracks, gutter: gutter)
}

// Gets the last (rightmost) auto column a cell is inserted in, for
// due expansion
#let get-colspan-last-auto-col(cell, columns: none) = {
    let cell-cols = range(cell.x, cell.x + cell.colspan)
    let last_auto_col = none

    for (i, col) in columns.enumerate() {
        if i in cell-cols and col == auto {
            last_auto_col = max-if-not-none(last_auto_col, i)
        }
    }

    last_auto_col
}

// Gets the last (bottom-most) auto row a cell is inserted in, for
// due expansion
#let get-rowspan-last-auto-row(cell, rows: none) = {
    let cell-rows = range(cell.y, cell.y + cell.rowspan)
    let last_auto_row = none

    for (i, row) in rows.enumerate() {
        if i in cell-rows and row == auto {
            last_auto_row = max-if-not-none(last_auto_row, i)
        }
    }

    last_auto_row
}

// Given a cell that may span one or more columns, sums the
// sizes of the columns it spans, when those columns have fixed sizes.
// Useful to subtract from the total width to find out how much more
// should an auto column extend to have that cell fit in the table.
#let get-colspan-fixed-size-covered(cell, columns: none) = {
    let cell-cols = range(cell.x, cell.x + cell.colspan)
    let size = 0pt

    for (i, col) in columns.enumerate() {
        if i in cell-cols and type(col) == _length-type {
            size += col
        }
    }
    size
}

// Given a cell that may span one or more rows, sums the
// sizes of the rows it spans, when those rows have fixed sizes.
// Useful to subtract from the total height to find out how much more
// should an auto row extend to have that cell fit in the table.
#let get-rowspan-fixed-size-covered(cell, rows: none) = {
    let cell-rows = range(cell.y, cell.y + cell.rowspan)
    let size = 0pt

    for (i, row) in rows.enumerate() {
        if i in cell-rows and type(row) == _length-type {
            size += row
        }
    }
    size
}

// calculate the size of auto columns (based on the max width of their cells)
#let determine-auto-columns(grid: (), styles: none, columns: none, inset: none, align: auto, fit-spans: none, page-width: 0pt) = {
    assert(styles != none, message: "Cannot measure auto columns without styles")
    let total_auto_size = 0pt
    let auto_sizes = ()
    let new_columns = columns

    let all-frac-columns = columns.enumerate().filter(i-col => type(i-col.at(1)) == _fraction-type).map(i-col => i-col.at(0))
    for (i, col) in columns.enumerate() {
        if col == auto {
            // max cell width
            let col_size = grid-get-column(grid, i)
                .fold(0pt, (max, cell) => {
                    if cell == none {
                        panic("Not enough cells specified for the given amount of rows and columns.")
                    }

                    let pcell = get-parent-cell(cell, grid: grid)  // in case this is a colspan
                    let last-auto-col = get-colspan-last-auto-col(pcell, columns: columns)

                    let fit-this-span = if "fit-spans" in pcell and pcell.fit-spans != auto {
                        pcell.fit-spans.x
                    } else {
                        fit-spans.x
                    }
                    let this-cell-can-expand-columns = pcell.colspan == 1 or not fit-this-span

                    // only expand the last auto column of a colspan,
                    // and only the amount necessary that isn't already
                    // covered by fixed size columns.
                    // However, ignore this cell if it is a colspan with
                    // `fit-spans.x == true` (it requests to not expand
                    // columns).
                    if last-auto-col == i and this-cell-can-expand-columns {
                        let cell-spans-all-frac-columns = pcell.colspan > 1 and all-frac-columns.len() > 0 and all-frac-columns.all(i => pcell.x <= i and i < (pcell.x + pcell.colspan))
                        if cell-spans-all-frac-columns and page-width != 0pt and not is-infinite-len(page-width) {
                            // HEURISTIC (only effective when the page width isn't 'auto' / infinite):
                            // If this cell can expand auto cols, but it already
                            // spans all fractional columns, then don't expand
                            // this auto column, as the cell would already have
                            // all remaining available space for itself anyway
                            // through the fractional columns spanned.
                            // Effectively, ignore this colspan - it will already
                            // have the max space possible, since, eventually,
                            // auto columns will be reduced to fit in the available
                            // size.
                            // For 'auto'-width pages, fractional columns will
                            // always have 0pt width, so this doesn't apply.
                            return max
                        }

                        // take extra inset as extra width or height on 'auto'
                        let cell_inset = default-if-auto(pcell.inset, inset)

                        // simulate wrapping this cell in the final box,
                        // but with unlimited width and height available
                        // so we can measure its width.
                        let cell-box = make-cell-box(
                            pcell,
                            width: auto, height: auto,
                            inset: cell_inset, align_default: auto
                        )

                        let width = measure(cell-box, styles).width// + 2*cell_inset // the box already considers inset

                        // here, we are excluding from the width of this cell
                        // at this column all width that was already covered by
                        // previous columns, so we need to specify 'new_columns'
                        // instead of 'columns' as the previous auto columns
                        // also have a fixed size now (we know their width).
                        let fixed_size = get-colspan-fixed-size-covered(pcell, columns: new_columns)

                        calc.max(max, width - fixed_size, 0pt)
                    } else {
                        max
                    }
                })

            total_auto_size += col_size
            auto_sizes.push((i, col_size))
            new_columns.at(i) = col_size
        }
    }

    (total: total_auto_size, sizes: auto_sizes, columns: new_columns)
}

// Try to reduce the width of auto columns so that the table fits within the
// page width.
// Fair version of the algorithm, tries to shrink the minimum amount of columns
// possible. The same algorithm used by native tables.
// Auto columns that are too wide will receive equal amounts of the remaining
// width (the "fair-share").
#let fit-auto-columns(available: 0pt, auto-cols: none, columns: none) = {
    if is-infinite-len(available) {
        // infinite space available => don't modify columns
        return columns
    }

    // Remaining space to share between auto columns.
    // Starts as all of the available space (excluding fixed-width columns).
    // Will reduce as we exclude auto columns from being resized.
    let remaining = available
    let auto-cols-to-resize = auto-cols.len()

    if auto-cols-to-resize <= 0 {
        return columns
    }

    // The fair-share must be the largest possible (to ensure maximum fairness)
    // such that we can shrink the minimum amount of columns possible and, at the
    // same time, ensure that the table won't cross the page width.
    // To do this, we will try to divide the space evenly between each auto column
    // to be resized.
    // If one or more auto columns are smaller than that, then they don't need to be
    // resized, so we will increase the fair share and check other columns, until
    // either none needs to be resized (all are smaller than the fair share)
    // or all columns to be resized are larger than the fair share.
    let last-share
    let fair-share = none
    let fair-share-should-change = true

    // 1. Rule out auto columns from resizing, and determine the final fair share
    // (the largest possible such that no columns are smaller than it).
    // One iteration of this 'while' runs for each attempt at a value for the fair
    // share. Once no non-excluded columns are smaller than the fair share
    // (which would otherwise lead to them being excluded from being resized, and the
    // fair share would increase), the loop stops, and we can resize down all columns
    // larger than the fair share.
    // The loop also stops if all auto columns would be smaller than the fair share,
    // and thus there is nothing to resize.
    while fair-share-should-change and auto-cols-to-resize > 0 {
        last-share = fair-share
        fair-share = remaining / auto-cols-to-resize
        fair-share-should-change = false

        for (_, col) in auto-cols {
            // 1. If it is smaller than the fair share,
            // then it can keep its size, and we should
            // update the fair share.
            // 2. If it is larger than the last fair share,
            // then it wasn't already excluded in any previous
            // iterations.
            if col <= fair-share and (last-share == none or col > last-share) {
                remaining -= col
                auto-cols-to-resize -= 1
                fair-share-should-change = true
            }
        }
    }

    // 2. Resize any columns larger than the calculated fair share to the fair share.
    for (i, col) in auto-cols {
        if col > fair-share {
            columns.at(i) = fair-share
        }
    }

    columns
}

#let determine-column-sizes(grid: (), page_width: 0pt, styles: none, columns: none, inset: none, align: auto, col-gutter: none, fit-spans: none) = {
    let columns = columns.map(c => {
        if type(c) in (_length-type, _rel-len-type, _ratio-type) {
            convert-length-to-pt(c, styles: styles, page-size: page_width)
        } else if c == none {
            0pt
        } else {
            c
        }
    })

    // what is the fixed size of the gutter?
    // (calculate it later if it's fractional)
    let fixed-size-gutter = if type(col-gutter) == _length-type {
        col-gutter
    } else {
        0pt
    }

    let total_fixed_size = sum-fixed-size-tracks(columns) + fixed-size-gutter * (columns.len() - 1)

    let available_size = page_width - total_fixed_size

    // page_width == 0pt => page width is 'auto'
    // so we don't have to restrict our table's size
    if available_size >= 0pt or page_width == 0pt {
        let auto_cols_result = determine-auto-columns(grid: grid, styles: styles, columns: columns, inset: inset, align: align, fit-spans: fit-spans, page-width: page_width)
        let total_auto_size = auto_cols_result.total
        let auto_sizes = auto_cols_result.sizes
        columns = auto_cols_result.columns

        let remaining_size = available_size - total_auto_size
        if remaining_size >= 0pt {
            let frac_res = determine-frac-tracks(
                columns,
                remaining: remaining_size,
                gutter: col-gutter
            )

            columns = frac_res.tracks
            fixed-size-gutter = frac_res.gutter
        } else {
            // don't shrink on width 'auto'
            if page_width != 0pt {
                columns = fit-auto-columns(
                    available: available_size,
                    auto-cols: auto_sizes,
                    columns: columns
                )
            }

            columns = columns.map(c => {
                if type(c) == _fraction-type {
                    0pt  // no space left to be divided
                } else {
                    c
                }
            })
        }
    } else {
        columns = columns.map(c => {
            if c == auto or type(c) == _fraction-type {
                0pt  // no space remaining!
            } else {
                c
            }
        })
    }

    (
        columns: columns,
        gutter: if col-gutter == none {
            none
        } else {
            fixed-size-gutter
        }
    )
}

// calculate the size of auto rows (based on the max height of their cells)
#let determine-auto-rows(grid: (), styles: none, columns: none, rows: none, align: auto, inset: none, fit-spans: none) = {
    assert(styles != none, message: "Cannot measure auto rows without styles")
    let total_auto_size = 0pt
    let auto_sizes = ()
    let new_rows = rows

    for (i, row) in rows.enumerate() {
        if row == auto {
            // max cell height
            let row_size = grid-get-row(grid, i)
                .fold(0pt, (max, cell) => {
                    if cell == none {
                        panic("Not enough cells specified for the given amount of rows and columns.")
                    }

                    let pcell = get-parent-cell(cell, grid: grid)  // in case this is a rowspan
                    let last-auto-row = get-rowspan-last-auto-row(pcell, rows: rows)

                    let fit-this-span = if "fit-spans" in pcell and pcell.fit-spans != auto {
                        pcell.fit-spans.y
                    } else {
                        fit-spans.y
                    }
                    let this-cell-can-expand-rows = pcell.rowspan == 1 or not fit-this-span

                    // only expand the last auto row of a rowspan,
                    // and only the amount necessary that isn't already
                    // covered by fixed size rows.
                    // However, ignore this cell if it is a rowspan with
                    // `fit-spans.y == true` (it requests to not expand
                    // rows).
                    if last-auto-row == i and this-cell-can-expand-rows {
                        let width = get-colspan-fixed-size-covered(pcell, columns: columns)

                        // take extra inset as extra width or height on 'auto'
                        let cell_inset = default-if-auto(pcell.inset, inset)

                        let cell-box = make-cell-box(
                            pcell,
                            width: width, height: auto,
                            inset: cell_inset, align_default: align
                        )

                        // measure the cell's actual height,
                        // with its calculated width
                        // and with other constraints
                        let height = measure(cell-box, styles).height// + 2*cell_inset (box already considers inset)

                        // here, we are excluding from the height of this cell
                        // at this row all height that was already covered by
                        // other rows, so we need to specify 'new_rows' instead
                        // of 'rows' as the previous auto rows also have a fixed
                        // size now (we know their height).
                        let fixed_size = get-rowspan-fixed-size-covered(pcell, rows: new_rows)

                        calc.max(max, height - fixed_size, 0pt)
                    } else {
                        max
                    }
                })

            total_auto_size += row_size
            auto_sizes.push((i, row_size))
            new_rows.at(i) = row_size
        }
    }

    (total: total_auto_size, sizes: auto_sizes, rows: new_rows)
}

#let determine-row-sizes(grid: (), page_height: 0pt, styles: none, columns: none, rows: none, align: auto, inset: none, row-gutter: none, fit-spans: none) = {
    let rows = rows.map(r => {
        if type(r) in (_length-type, _rel-len-type, _ratio-type) {
            convert-length-to-pt(r, styles: styles, page-size: page_height)
        } else {
            r
        }
    })

    let auto_rows_res = determine-auto-rows(
        grid: grid, columns: columns, rows: rows, styles: styles, align: align, inset: inset, fit-spans: fit-spans
    )

    let auto_size = auto_rows_res.total
    rows = auto_rows_res.rows

    // what is the fixed size of the gutter?
    // (calculate it later if it's fractional)
    let fixed-size-gutter = if type(row-gutter) == _length-type {
        row-gutter
    } else {
        0pt
    }

    let remaining = page_height - sum-fixed-size-tracks(rows) - auto_size - fixed-size-gutter * (rows.len() - 1)

    if remaining >= 0pt {  // split fractions in one page
        let frac_res = determine-frac-tracks(rows, remaining: remaining, gutter: row-gutter)
        (
            rows: frac_res.tracks,
            gutter: frac_res.gutter
        )
    } else {
        (
            rows: rows.map(r => {
                if type(r) == _fraction-type {  // no space remaining in this page or box
                    0pt
                } else {
                    r
                }
            }),
            gutter: if row-gutter == none {
                none
            } else {
                fixed-size-gutter
            }
        )
    }
}

// Determine the size of 'auto' and 'fr' columns and rows
#let determine-auto-column-row-sizes(
    grid: (),
    page_width: 0pt, page_height: 0pt,
    styles: none,
    columns: none, rows: none,
    inset: none, gutter: none,
    align: auto,
    fit-spans: none,
) = {
    let columns_res = determine-column-sizes(
        grid: grid,
        page_width: page_width, styles: styles, columns: columns,
        inset: inset,
        align: align,
        col-gutter: gutter.col,
        fit-spans: fit-spans
    )
    columns = columns_res.columns
    gutter.col = columns_res.gutter

    let rows_res = determine-row-sizes(
        grid: grid,
        page_height: page_height, styles: styles,
        columns: columns,  // so we consider available width
        rows: rows,
        inset: inset,
        align: align,
        row-gutter: gutter.row,
        fit-spans: fit-spans
    )
    rows = rows_res.rows
    gutter.row = rows_res.gutter

    (
        columns: columns,
        rows: rows,
        gutter: gutter
    )
}

// -- end: col/row size functions --

// -- width/height utilities --

#let width-between(start: 0, end: none, columns: (), gutter: none, pre-gutter: false) = {
    let col-gutter = default-if-none(default-if-none(gutter, (col: 0pt)).col, 0pt)
    end = default-if-none(end, columns.len())

    let col_range = range(start, calc.min(columns.len() + 1, end))

    let sum = 0pt
    for i in col_range {
        sum += columns.at(i) + col-gutter
    }

    // if the end is after all columns, there is
    // no gutter at the end.
    if pre-gutter or end == columns.len() {
        sum = calc.max(0pt, sum - col-gutter) // remove extra gutter from last col
    }

    sum
}

#let height-between(start: 0, end: none, rows: (), gutter: none, pre-gutter: false) = {
    let row-gutter = default-if-none(default-if-none(gutter, (row: 0pt)).row, 0pt)
    end = default-if-none(end, rows.len())

    let row_range = range(start, calc.min(rows.len() + 1, end))

    let sum = 0pt
    for i in row_range {
        sum += rows.at(i) + row-gutter
    }

    // if the end is after all rows, there is
    // no gutter at the end.
    if pre-gutter or end == rows.len() {
        sum = calc.max(0pt, sum - row-gutter) // remove extra gutter from last row
    }

    sum
}

#let cell-width(x, colspan: 1, columns: (), gutter: none) = {
    width-between(start: x, end: x + colspan, columns: columns, gutter: gutter, pre-gutter: true)
}

#let cell-height(y, rowspan: 1, rows: (), gutter: none) = {
    height-between(start: y, end: y + rowspan, rows: rows, gutter: gutter, pre-gutter: true)
}

// override start and end for vlines and hlines (keep styling options and stuff)
#let v-or-hline-with-span(v_or_hline, start: none, end: none) = {
    (
        ..v_or_hline,
        start: start,
        end: end,
        parent: v_or_hline  // the one that generated this
    )
}

// check the subspan a hline or vline goes through inside a larger span
#let get-included-span(l_start, l_end, start: 0, end: 0, limit: 0) = {
    if l_start in (none, auto) {
        l_start = 0
    }

    if l_end in (none, auto) {
        l_end = limit
    }

    l_start = calc.max(0, l_start)
    l_end = calc.min(end, limit)

    // ---- ====     or ==== ----
    if l_end < start or l_start > end {
        return none
    }

    // --##==   ;   ==##-- ;  #### ; ... : intersection.
    (calc.max(l_start, start), calc.min(l_end, end))
}

// restrict hlines and vlines to the cells' borders.
// i.e.
//                | (vline)
//                |
// (hline) ----====---      (= and || indicate intersection)
//             |  ||
//             ----   <--- sample cell
#let v-and-hline-spans-for-cell(cell, hlines: (), vlines: (), x_limit: 0, y_limit: 0, grid: ()) = {
    // only draw lines from the parent cell
    if is-tablex-occupied(cell) {
        return (
            hlines: (),
            vlines: ()
        );
    }

    let hlines = hlines
        .filter(h => {
            let y = h.y

            let in_top_or_bottom = y in (cell.y, cell.y + cell.rowspan)

            let hline_hasnt_already_ended = (
                h.end in (auto, none)  // always goes towards the right
                or h.end >= cell.x + cell.colspan  // ends at or after this cell
            )

            (in_top_or_bottom
                and hline_hasnt_already_ended)
        })
        .map(h => {
            // get the intersection between the hline and the cell's x-span.
            let span = get-included-span(h.start, h.end, start: cell.x, end: cell.x + cell.colspan, limit: x_limit)

            if span == none {  // no intersection!
                none
            } else {
                v-or-hline-with-span(h, start: span.at(0), end: span.at(1))
            }
        })
        .filter(x => x != none)

    let vlines = vlines
        .filter(v => {
            let x = v.x

            let at_left_or_right = x in (cell.x, cell.x + cell.colspan)

            let vline_hasnt_already_ended = (
                v.end in (auto, none)  // always goes towards the bottom
                or v.end >= cell.y + cell.rowspan  // ends at or after this cell
            )

            (at_left_or_right
                and vline_hasnt_already_ended)
        })
        .map(v => {
            // get the intersection between the hline and the cell's x-span.
            let span = get-included-span(v.start, v.end, start: cell.y, end: cell.y + cell.rowspan, limit: y_limit)

            if span == none {  // no intersection!
                none
            } else {
                v-or-hline-with-span(v, start: span.at(0), end: span.at(1))
            }
        })
        .filter(x => x != none)

    (
        hlines: hlines,
        vlines: vlines
    )
}

// Are two hlines the same?
// (Check to avoid double drawing)
#let is-same-hline(a, b) = (
    is-tablex-hline(a)
        and is-tablex-hline(b)
        and a.y == b.y
        and a.start == b.start
        and a.end == b.end
        and a.gutter-restrict == b.gutter-restrict
)

#let _largest-stroke-among-lines(lines, stroke-auto: 1pt, styles: none) = (
    calc.max(0pt, ..lines.map(l => stroke-len(l.stroke, stroke-auto: stroke-auto, styles: styles)))
)

#let _largest-stroke-among-hlines-at-y(y, hlines: none, stroke-auto: 1pt, styles: none) = {
    _largest-stroke-among-lines(hlines.filter(h => h.y == y), stroke-auto: stroke-auto, styles: styles)
}

#let _largest-stroke-among-vlines-at-x(x, vlines: none, stroke-auto: 1pt, styles: none) = {
    _largest-stroke-among-lines(vlines.filter(v => v.x == x), stroke-auto: stroke-auto, styles: styles)
}

// -- end: width/height utilities --

// -- drawing --

#let parse-stroke(stroke) = {
    if is-color(stroke) {
        stroke + 1pt
    } else if type(stroke) in (_length-type, _rel-len-type, _ratio-type, _stroke-type, _dict-type) or stroke in (none, auto) {
        stroke
    } else {
        panic("Invalid stroke '" + repr(stroke) + "'.")
    }
}

// How much should this line expand?
// If it's not at the edge of the parent line => don't expand
// spanned-tracks-len: row_len (if vline), col_len (if hline)
#let get-actual-expansion(line, spanned-tracks-len: 0) = {
    // TODO: better handle negative expansion
    if line.expand in (none, (none, none), auto, (auto, auto)) {
        return (none, none)
    }
    if type(line.expand) != _array-type {
        line.expand = (line.expand, line.expand)
    }

    let parent = get-top-parent(line)
    let parent-start = default-if-auto-or-none(parent.start, 0)
    let parent-end = default-if-auto-or-none(parent.end, spanned-tracks-len)

    let start = default-if-auto-or-none(line.start, 0)
    let end = default-if-auto-or-none(line.end, spanned-tracks-len)

    let expansion = (none, none)

    if start == parent-start {  // starts where its parent starts
        expansion.at(0) = default-if-auto(line.expand.at(0), 0pt)  // => expand to the left
    }

    if end == parent-end {  // ends where its parent ends
        expansion.at(1) = default-if-auto(line.expand.at(1), 0pt)  // => expand to the right
    }

    expansion
}

#let draw-hline(
    hline,
    initial_x: 0, initial_y: 0, columns: (), rows: (), stroke: auto, vlines: (), gutter: none, pre-gutter: false,
    styles: none,
    rightmost_x: 0, rtl: false,
) = {
    let start = hline.start
    let end = hline.end
    let stroke-auto = parse-stroke(stroke)
    let stroke = default-if-auto(hline.stroke, stroke)
    let stroke = parse-stroke(stroke)

    if default-if-auto-or-none(start, 0) == default-if-auto-or-none(end, columns.len()) { return }

    if gutter != none and gutter.row != none and ((pre-gutter and hline.gutter-restrict == bottom) or (not pre-gutter and hline.gutter-restrict == top)) {
        return
    }

    let expand = get-actual-expansion(hline, spanned-tracks-len: columns.len())
    let left-expand = default-if-auto-or-none(expand.at(0), 0pt)
    let right-expand = default-if-auto-or-none(expand.at(1), 0pt)

    if default-if-auto(hline.stroke-expand, true) == true {
        let largest-stroke = _largest-stroke-among-vlines-at-x.with(vlines: vlines, stroke-auto: stroke-auto, styles: styles)
        left-expand += largest-stroke(default-if-auto-or-none(start, 0)) / 2  // expand to the left to close stroke gap
        right-expand += largest-stroke(default-if-auto-or-none(end, columns.len())) / 2  // close stroke gap to the right
    }

    let y = height-between(start: initial_y, end: hline.y, rows: rows, gutter: gutter, pre-gutter: pre-gutter)
    let start_x = width-between(start: initial_x, end: start, columns: columns, gutter: gutter, pre-gutter: false) - left-expand
    let end_x = width-between(start: initial_x, end: end, columns: columns, gutter: gutter, pre-gutter: hline.stop-pre-gutter == true) + right-expand

    if end_x - start_x < 0pt {
        return  // negative length
    }

    if rtl {
        // invert the line (start from the right instead of from the left)
        start_x = rightmost_x - start_x
        end_x = rightmost_x - end_x
    }

    let start = (
        start_x,
        y
    )
    let end = (
        end_x,
        y
    )

    if stroke != auto {
        if stroke != none {
            line(start: start, end: end, stroke: stroke)
        }
    } else {
        line(start: start, end: end)
    }
}

#let draw-vline(
    vline,
    initial_x: 0, initial_y: 0, columns: (), rows: (), stroke: auto,
    gutter: none, hlines: (), pre-gutter: false, stop-before-row-gutter: false,
    styles: none,
    rightmost_x: 0, rtl: false,
) = {
    let start = vline.start
    let end = vline.end
    let stroke-auto = parse-stroke(stroke)
    let stroke = default-if-auto(vline.stroke, stroke)
    let stroke = parse-stroke(stroke)

    if default-if-auto-or-none(start, 0) == default-if-auto-or-none(end, rows.len()) { return }

    if gutter != none and gutter.col != none and ((pre-gutter and vline.gutter-restrict == right) or (not pre-gutter and vline.gutter-restrict == left)) {
        return
    }

    let expand = get-actual-expansion(vline, spanned-tracks-len: rows.len())
    let top-expand = default-if-auto-or-none(expand.at(0), 0pt)
    let bottom-expand = default-if-auto-or-none(expand.at(1), 0pt)

    if default-if-auto(vline.stroke-expand, true) == true {
        let largest-stroke = _largest-stroke-among-hlines-at-y.with(hlines: hlines, stroke-auto: stroke-auto, styles: styles)
        top-expand += largest-stroke(default-if-auto-or-none(start, 0)) / 2  // close stroke gap to the top
        bottom-expand += largest-stroke(default-if-auto-or-none(end, rows.len())) / 2  // close stroke gap to the bottom
    }

    let x = width-between(start: initial_x, end: vline.x, columns: columns, gutter: gutter, pre-gutter: pre-gutter)
    let start_y = height-between(start: initial_y, end: start, rows: rows, gutter: gutter) - top-expand
    let end_y = height-between(start: initial_y, end: end, rows: rows, gutter: gutter, pre-gutter: stop-before-row-gutter or vline.stop-pre-gutter == true) + bottom-expand

    if end_y - start_y < 0pt {
        return  // negative length
    }

    if rtl {
        // invert the vertical line's x pos (start from the right instead of from the left)
        x = rightmost_x - x
    }

    let start = (
        x,
        start_y
    )
    let end = (
        x,
        end_y
    )

    if stroke != auto {
        if stroke != none {
            line(start: start, end: end, stroke: stroke)
        }
    } else {
        line(start: start, end: end)
    }
}

// -- end: drawing

// main functions

// Gets a state variable that holds the page's max x ("width") and max y ("height"),
// considering the left and top margins.
// Requires placing 'get-page-dim-writer(the_returned_state)' on the
// document.
// The id is to differentiate the state for each table.
#let get-page-dim-state(id) = state("tablex_tablex_page_dims__" + repr(id), (width: 0pt, height: 0pt, top_left: none, bottom_right: none))

// A little trick to get the page max width and max height.
// Places a component on the page (or outer container)'s top left,
// and one on the page's bottom right, and subtracts their coordinates.
//
// Must be fed a state variable, which is updated with (width: max x, height: max y).
// The content it returns must be placed in the document for the page state to be
// written to.
//
// NOTE: This function cannot differentiate between the actual page
// and a possible box or block where the component using this function
// could be contained in.
#let get-page-dim-writer() = locate(w_loc => {
    let table_id = _tablex-table-counter.at(w_loc)
    let page_dim_state = get-page-dim-state(table_id)

    place(top + left, locate(loc => {
        page_dim_state.update(s => {
            if s.top_left != none {
                s
            } else {
                let pos = loc.position()
                let width = s.width - pos.x
                let height = s.width - pos.y
                (width: width, height: height, top_left: pos, bottom_right: s.bottom_right)
            }
        })
    }))

    place(bottom + right, locate(loc => {
        page_dim_state.update(s => {
            if s.bottom_right != none {
                s
            } else {
                let pos = loc.position()
                let width = s.width + pos.x
                let height = s.width + pos.y
                (width: width, height: height, top_left: s.top_left, bottom_right: pos)
            }
        })
    }))
})

// Draws a row group using locate() and a block().
#let draw-row-group(
    row-group,
    is-header: false,
    header-pages-state: none,
    first-row-group: none,
    columns: none, rows: none,
    stroke: none,
    gutter: none,
    repeat-header: false,
    styles: none,
    min-pos: none,
    max-pos: none,
    header-hlines-have-priority: true,
    rtl: false,
    table-loc: none,
    total-width: none,
    global-hlines: (),
    global-vlines: (),
) = {
    let width-between = width-between.with(columns: columns, gutter: gutter)
    let height-between = height-between.with(rows: rows, gutter: gutter)
    let draw-hline = draw-hline.with(columns: columns, rows: rows, stroke: stroke, gutter: gutter, vlines: global-vlines, styles: styles)
    let draw-vline = draw-vline.with(columns: columns, rows: rows, stroke: stroke, gutter: gutter, hlines: global-hlines, styles: styles)

    let group-rows = row-group.rows
    let hlines = row-group.hlines
    let vlines = row-group.vlines
    let (start-y, end-y) = row-group.y_span

    locate(loc => {
        // let old_page = latest-page-state.at(loc)
        // let this_page = loc.page()

        // let page_turned = not is-header and old_page not in (this_page, -1)
        let pos = loc.position()
        let page = pos.page
        let rel_page = page - table-loc.page() + 1

        let at_top = pos.y == min-pos.y  // to guard against re-draw issues
        let header_pages = header-pages-state.at(loc)
        let header_count = header_pages.len()
        let page_turned = page not in header_pages

        // draw row group
        block(
            breakable: false,
            fill: none, radius: 0pt, stroke: none,
        {
            let added_header_height = 0pt  // if we added a header, move down

            // page turned => add header
            if page_turned and at_top and not is-header {
                if repeat-header != false {
                    header-pages-state.update(l => l + (page,))
                    if (repeat-header == true) or (type(repeat-header) == _int-type and rel_page <= repeat-header) or (type(repeat-header) == _array-type and rel_page in repeat-header) {
                        let measures = measure(first-row-group.content, styles)
                        place(top+left, first-row-group.content)  // add header
                        added_header_height = measures.height
                    }
                }
            }

            let row_gutter_dy = default-if-none(gutter.row, 0pt)

            let first_x = none
            let first_y = none
            let rightmost_x = none

            let row_heights = array-sum(rows.slice(start-y, end-y + 1), zero: 0pt)

            let first_row = true
            for row in group-rows {
                for cell_box in row {
                    let x = cell_box.cell.x
                    let y = cell_box.cell.y
                    first_x = default-if-none(first_x, x)
                    first_y = default-if-none(first_y, y)
                    rightmost_x = default-if-none(rightmost_x, width-between(start: first_x, end: none))

                    // where to place the cell (horizontally)
                    let dx = width-between(start: first_x, end: x)

                    // TODO: consider implementing RTL before the rendering
                    // stage (perhaps by inverting 'x' positions on cells
                    // and lines beforehand).
                    if rtl {
                        // invert cell's x position (start from the right)
                        dx = rightmost_x - dx
                        // assume the cell doesn't start at the very end
                        // (that would be weird)
                        // Here we have to move dx back a bit as, after
                        // inverting it, it'd be the right edge of the cell;
                        // we need to keep it as the left edge's x position,
                        // as #place works with the cell's left edge.
                        // To do that, we subtract the cell's width from dx.
                        dx -= width-between(start: x, end: x + cell_box.cell.colspan)
                    }

                    // place the cell!
                    place(top+left,
                        dx: dx,
                        dy: height-between(start: first_y, end: y) + added_header_height,
                        cell_box.box)

                    // let box_h = measure(cell_box.box, styles).height
                    // tallest_box_h = calc.max(tallest_box_h, box_h)
                }
                first_row = false
            }

            let row_group_height = row_heights + added_header_height + (row_gutter_dy * group-rows.len())

            let is_last_row = not is-infinite-len(max-pos.y) and pos.y + row_group_height + row_gutter_dy >= max-pos.y

            if is_last_row {
                row_group_height -= row_gutter_dy
                // one less gutter at the end
            }

            hide(rect(width: total-width, height: row_group_height))

            let draw-hline = draw-hline.with(initial_x: first_x, initial_y: first_y, rightmost_x: rightmost_x, rtl: rtl)
            let draw-vline = draw-vline.with(initial_x: first_x, initial_y: first_y, rightmost_x: rightmost_x, rtl: rtl)

            // ensure the lines are drawn absolutely, after the header
            let draw-hline = (..args) => place(top + left, dy: added_header_height, draw-hline(..args))
            let draw-vline = (..args) => place(top + left, dy: added_header_height, draw-vline(..args))

            let header_last_y = if first-row-group != none {
                first-row-group.row_group.y_span.at(1)
            } else {
                none
            }
            // if this is the second row, and the header's hlines
            // do not have priority (thus are not drawn by them,
            // otherwise they'd repeat on every page), then
            // we draw its hlines for the header, below it.
            let hlines = if not header-hlines-have-priority and not is-header and start-y == header_last_y + 1 {
                let hlines_below_header = first-row-group.row_group.hlines.filter(h => h.y == header_last_y + 1)

                hlines + hlines_below_header
            } else {
                hlines
            }

            for hline in hlines {
                // only draw the top hline
                // if header's wasn't already drawn
                if hline.y == start-y {
                    let header_last_y = if first-row-group != none {
                        first-row-group.row_group.y_span.at(1)
                    } else {
                        none
                    }
                    // pre-gutter is always false here, as we assume
                    // hlines at the top of this row are handled
                    // at pre-gutter by the preceding row,
                    // and at post-gutter by this (the following) row.
                    // these if's are to check if we should indeed
                    // draw this hline, or if the previous row /
                    // the header should take care of it.
                    if not header-hlines-have-priority and not is-header and start-y == header_last_y + 1 {
                        // second row (after header, and it has no hline priority).
                        draw-hline(hline, pre-gutter: false)
                    } else if hline.y == 0 {
                        // hline at the very top of the table.
                        draw-hline(hline, pre-gutter: false)
                    } else if not page_turned and gutter.row != none and hline.gutter-restrict != top {
                        // this hline, at the top of this row group,
                        // isn't restricted to a pre-gutter position,
                        // so let's draw it right above us.
                        // The page turn check is important:
                        // the hline should not be drawn if the header
                        // was repeated and its own hlines have
                        // priority.
                        draw-hline(hline, pre-gutter: false)
                    } else if page_turned and (added_header_height == 0pt or not header-hlines-have-priority) {
                        draw-hline(hline, pre-gutter: false)
                        // no header repeated, but still at the top of the current page
                    }
                } else {
                    if hline.y == end-y + 1 and (
                        (is-header and not header-hlines-have-priority)
                        or (gutter.row != none and hline.gutter-restrict == bottom)) {
                        // this hline is after all cells
                        // in the row group, and either
                        // this is the header and its hlines
                        // don't have priority (=> the row
                        // groups below it - if repeated -
                        // should draw the hlines above them),
                        // or the hline is restricted to
                        // post-gutter => let the next
                        // row group draw it.
                        continue
                    }

                    // normally, only draw the bottom hlines
                    // (and both their pre-gutter and
                    // post-gutter variations)
                    draw-hline(hline, pre-gutter: true)

                    // don't draw the post-row gutter hline
                    // if this is the last row in the page,
                    // the last row in the row group
                    // (=> the next row group will
                    // place the hline above it, so that
                    // lines break properly between pages),
                    // or the last row in the whole table.
                    if gutter.row != none and hline.y < rows.len() and hline.y < end-y + 1 and not is_last_row {
                        draw-hline(hline, pre-gutter: false)
                    }
                }
            }

            for vline in vlines {
                draw-vline(vline, pre-gutter: true, stop-before-row-gutter: is_last_row)

                // don't draw the post-col gutter vline
                // if this is the last vline
                if gutter.col != none and vline.x < columns.len() {
                    draw-vline(vline, pre-gutter: false, stop-before-row-gutter: is_last_row)
                }
            }
        })
    })
}

// Generates groups of rows.
// By default, 1 row + rows from its rowspan cells = 1 row group.
// The first row group is the header, which is repeated across pages.
#let generate-row-groups(
    grid: none,
    columns: none, rows: none,
    stroke: none, inset: none,
    gutter: none,
    fill: none,
    align: none,
    hlines: none, vlines: none,
    repeat-header: false,
    styles: none,
    header-hlines-have-priority: true,
    min-pos: none,
    max-pos: none,
    header-rows: 1,
    rtl: false,
    table-loc: none,
    table-id: none,
) = {
    let col_len = columns.len()
    let row_len = rows.len()

    // specialize some functions for the given grid, columns and rows
    let v-and-hline-spans-for-cell = v-and-hline-spans-for-cell.with(vlines: vlines, x_limit: col_len, y_limit: row_len, grid: grid)
    let cell-width = cell-width.with(columns: columns, gutter: gutter)
    let cell-height = cell-height.with(rows: rows, gutter: gutter)
    let width-between = width-between.with(columns: columns, gutter: gutter)
    let height-between = height-between.with(rows: rows, gutter: gutter)

    // each row group is an unbreakable unit of rows.
    // In general, they're just one row. However, they can be multiple rows
    // if one of their cells spans multiple rows.
    let first_row_group = none

    let header_pages = state("tablex_tablex_header_pages__" + repr(table-id), (table-loc.page(),))
    let this_row_group = (rows: ((),), hlines: (), vlines: (), y_span: (0, 0))

    let total_width = width-between(end: none)

    let row_group_add_counter = 1  // how many more rows are going to be added to the latest row group
    let current_row = 0
    let header_rows_count = calc.min(row_len, header-rows)

    for row in range(0, row_len) {
        // maximum cell total rowspan in this row
        let max_rowspan = 0

        for column in range(0, col_len) {
            let cell = grid-at(grid, column, row)
            let lines_dict = v-and-hline-spans-for-cell(cell, hlines: hlines)
            let hlines = lines_dict.hlines
            let vlines = lines_dict.vlines

            if is-tablex-cell(cell) {
                // ensure row-spanned rows are in the same group
                row_group_add_counter = calc.max(row_group_add_counter, cell.rowspan)

                let width = cell-width(cell.x, colspan: cell.colspan)
                let height = cell-height(cell.y, rowspan: cell.rowspan)

                let cell_box = make-cell-box(
                    cell,
                    width: width, height: height, inset: inset,
                    align_default: align,
                    fill_default: fill)

                this_row_group.rows.last().push((cell: cell, box: cell_box))

                let hlines = hlines
                    .filter(h =>
                        this_row_group.hlines
                            .filter(is-same-hline.with(h))
                            .len() == 0)

                let vlines = vlines
                    .filter(v => v not in this_row_group.vlines)

                this_row_group.hlines += hlines
                this_row_group.vlines += vlines
            }
        }

        current_row += 1
        row_group_add_counter = calc.max(0, row_group_add_counter - 1)  // one row added
        header_rows_count = calc.max(0, header_rows_count - 1)  // ensure at least the amount of requested header rows was added

        // added all pertaining rows to the group
        // now we can draw it
        if row_group_add_counter <= 0 and header_rows_count <= 0 {
            row_group_add_counter = 1

            let row-group = this_row_group

            // get where the row starts and where it ends
            let (start_y, end_y) = row-group.y_span

            let next_y = end_y + 1

            this_row_group = (rows: ((),), hlines: (), vlines: (), y_span: (next_y, next_y))

            let is_header = first_row_group == none
            let content = draw-row-group(
                row-group,
                is-header: is_header,
                header-pages-state: header_pages,
                first-row-group: first_row_group,
                columns: columns, rows: rows,
                stroke: stroke,
                gutter: gutter,
                repeat-header: repeat-header,
                total-width: total_width,
                table-loc: table-loc,
                header-hlines-have-priority: header-hlines-have-priority,
                rtl: rtl,
                min-pos: min-pos,
                max-pos: max-pos,
                styles: styles,
                global-hlines: hlines,
                global-vlines: vlines,
            )

            if is_header {  // this is now the header group.
                first_row_group = (row_group: row-group, content: content)  // 'content' to repeat later
            }

            (content,)
        } else {
            this_row_group.rows.push(())
            this_row_group.y_span.at(1) += 1
        }
    }
}

// -- end: main functions

// option parsing functions

#let _parse-lines(
    hlines, vlines,
    page-width: none, page-height: none,
    styles: none
) = {
    let parse-func(line, page-size: none) = {
        line.stroke-expand = line.stroke-expand == true
        line.expand = default-if-auto(line.expand, none)
        if type(line.expand) != _array-type and line.expand != none {
            line.expand = (line.expand, line.expand)
        }
        line.expand = if line.expand == none {
            none
        } else {
            line.expand.slice(0, 2).map(e => {
                if e == none {
                    e
                } else {
                    e = default-if-auto(e, 0pt)
                    if type(e) not in (_length-type, _rel-len-type, _ratio-type) {
                        panic("'expand' argument to lines must be a pair (length, length).")
                    }

                    convert-length-to-pt(e, styles: styles, page-size: page-size)
                }
            })
        }

        line
    }
    (
        hlines: hlines.map(parse-func.with(page-size: page-width)),
        vlines: vlines.map(parse-func.with(page-size: page-height))
    )
}

// Parses 'auto-lines', generating the corresponding lists of
// new hlines and vlines
#let generate-autolines(auto-lines: false, auto-hlines: auto, auto-vlines: auto, hlines: none, vlines: none, col_len: none, row_len: none) = {
    let auto-hlines = default-if-auto(auto-hlines, auto-lines)
    let auto-vlines = default-if-auto(auto-vlines, auto-lines)

    let new_hlines = ()
    let new_vlines = ()

    if auto-hlines {
        new_hlines = range(0, row_len + 1)
            .filter(y => hlines.filter(h => h.y == y).len() == 0)
            .map(y => hlinex(y: y))
    }

    if auto-vlines {
        new_vlines = range(0, col_len + 1)
            .filter(x => vlines.filter(v => v.x == x).len() == 0)
            .map(x => vlinex(x: x))
    }

    (new_hlines: new_hlines, new_vlines: new_vlines)
}

#let parse-gutters(col-gutter: auto, row-gutter: auto, gutter: auto, styles: none, page-width: 0pt, page-height: 0pt) = {
    col-gutter = default-if-auto(col-gutter, gutter)
    row-gutter = default-if-auto(row-gutter, gutter)

    col-gutter = default-if-auto(col-gutter, 0pt)
    row-gutter = default-if-auto(row-gutter, 0pt)

    if type(col-gutter) in (_length-type, _rel-len-type, _ratio-type) {
        col-gutter = convert-length-to-pt(col-gutter, styles: styles, page-size: page-width)
    }

    if type(row-gutter) in (_length-type, _rel-len-type, _ratio-type) {
        row-gutter = convert-length-to-pt(row-gutter, styles: styles, page-size: page-width)
    }

    (col: col-gutter, row: row-gutter)
}

// Accepts a map-X param, and verifies whether it's a function or none/auto.
#let validate-map-func(map-func) = {
    if map-func not in (none, auto) and type(map-func) != _function-type {
        panic("Tablex error: Map parameters, if specified (not 'none'), must be functions.")
    }

    map-func
}

#let apply-maps(
    grid: (),
    hlines: (),
    vlines: (),
    map-hlines: none,
    map-vlines: none,
    map-rows: none,
    map-cols: none,
) = {
    if type(map-vlines) == _function-type {
        vlines = vlines.map(vline => {
            let vline = map-vlines(vline)
            if not is-tablex-vline(vline) {
                panic("'map-vlines' function returned a non-vline.")
            }
            vline
        })
    }

    if type(map-hlines) == _function-type {
        hlines = hlines.map(hline => {
            let hline = map-hlines(hline)
            if not is-tablex-hline(hline) {
                panic("'map-hlines' function returned a non-hline.")
            }
            hline
        })
    }

    let should-map-rows = type(map-rows) == _function-type
    let should-map-cols = type(map-cols) == _function-type

    if not should-map-rows and not should-map-cols {
        return (grid: grid, hlines: hlines, vlines: vlines)
    }

    let col-len = grid.width
    let row-len = grid-count-rows(grid)

    if should-map-rows {
        for row in range(row-len) {
            let original-cells = grid-get-row(grid, row)

            // occupied cells = none for the outer user
            let cells = map-rows(row, original-cells.map(c => {
                if is-tablex-occupied(c) { none } else { c }
            }))

            if type(cells) != _array-type {
                panic("Tablex error: 'map-rows' returned something that isn't an array.")
            }

            if cells.len() != original-cells.len() {
                panic("Tablex error: 'map-rows' returned " + str(cells.len()) + " cells, when it should have returned exactly " + str(original-cells.len()) + ".")
            }

            for (i, cell) in cells.enumerate() {
                let orig-cell = original-cells.at(i)
                if not is-tablex-cell(orig-cell) {
                    // only modify non-occupied cells
                    continue
                }

                if not is-tablex-cell(cell) {
                    panic("Tablex error: 'map-rows' returned a non-cell.")
                }

                let x = cell.x
                let y = cell.y

                if type(x) != _int-type or type(y) != _int-type or x < 0 or y < 0 or x >= col-len or y >= row-len {
                    panic("Tablex error: 'map-rows' returned a cell with invalid coordinates.")
                }

                if y != row {
                    panic("Tablex error: 'map-rows' returned a cell in a different row (the 'y' must be kept the same).")
                }

                if cell.colspan != orig-cell.colspan or cell.rowspan != orig-cell.rowspan {
                    panic("Tablex error: Please do not change the colspan or rowspan of a cell in 'map-rows'.")
                }

                cell.content = [#cell.content]
                grid.items.at(grid-index-at(cell.x, cell.y, grid: grid)) = cell
            }
        }
    }

    if should-map-cols {
        for column in range(col-len) {
            let original-cells = grid-get-column(grid, column)

            // occupied cells = none for the outer user
            let cells = map-cols(column, original-cells.map(c => {
                if is-tablex-occupied(c) { none } else { c }
            }))

            if type(cells) != _array-type {
                panic("Tablex error: 'map-cols' returned something that isn't an array.")
            }

            if cells.len() != original-cells.len() {
                panic("Tablex error: 'map-cols' returned " + str(cells.len()) + " cells, when it should have returned exactly " + str(original-cells.len()) + ".")
            }

            for (i, cell) in cells.enumerate() {
                let orig-cell = original-cells.at(i)
                if not is-tablex-cell(orig-cell) {
                    // only modify non-occupied cells
                    continue
                }

                if not is-tablex-cell(cell) {
                    panic("Tablex error: 'map-cols' returned a non-cell.")
                }

                let x = cell.x
                let y = cell.y

                if type(x) != _int-type or type(y) != _int-type or x < 0 or y < 0 or x >= col-len or y >= row-len {
                    panic("Tablex error: 'map-cols' returned a cell with invalid coordinates.")
                }
                if x != column {
                    panic("Tablex error: 'map-cols' returned a cell in a different column (the 'x' must be kept the same).")
                }
                if cell.colspan != orig-cell.colspan or cell.rowspan != orig-cell.rowspan {
                    panic("Tablex error: Please do not change the colspan or rowspan of a cell in 'map-cols'.")
                }

                cell.content = [#cell.content]
                grid.items.at(grid-index-at(cell.x, cell.y, grid: grid)) = cell
            }
        }
    }

    (grid: grid, hlines: hlines, vlines: vlines)
}

#let validate-header-rows(header-rows) = {
    header-rows = default-if-auto(default-if-none(header-rows, 0), 1)

    if type(header-rows) != _int-type or header-rows < 0 {
        panic("Tablex error: 'header-rows' must be a (positive) integer.")
    }

    header-rows
}

#let validate-repeat-header(repeat-header, header-rows: none) = {
    if header-rows == none or header-rows < 0 {
        return false  // cannot repeat an empty header
    }

    repeat-header = default-if-auto(default-if-none(repeat-header, false), false)

    if type(repeat-header) not in (_bool-type, _int-type, _array-type) {
        panic("Tablex error: 'repeat-header' must be a boolean (true - always repeat the header, false - never), an integer (amount of pages for which to repeat the header), or an array of integers (relative pages in which the header should repeat).")
    } else if type(repeat-header) == _array-type and repeat-header.any(i => type(i) != _int-type) {
        panic("Tablex error: 'repeat-header' cannot be an array of anything other than integers!")
    }

    repeat-header
}

#let validate-header-hlines-priority(
    header-hlines-have-priority
) = {
    header-hlines-have-priority = default-if-auto(default-if-none(header-hlines-have-priority, true), true)

    if type(header-hlines-have-priority) != _bool-type {
        panic("Tablex error: 'header-hlines-have-priority' option must be a boolean.")
    }

    header-hlines-have-priority
}

// 'validate-fit-spans' is needed by grid, and is thus in the common section

// -- end: option parsing

// Creates a table.
//
// OPTIONS:
// columns: table column sizes (array of sizes,
// or a single size for 1 column)
//
// rows: row sizes (same format as columns)
//
// align: how to align cells (alignment, array of alignments
// (one for each column), or a function
// (col, row) => alignment)
//
// items: The table items, as specified by the columns
// and rows. Can also be cellx, hlinex and vlinex objects.
//
// fill: how to fill cells (color/none, array of colors
// (one for each column), or a function (col, row) => color)
//
// stroke: how to draw the table lines (stroke)
// column-gutter: optional separation (length) between columns
// row-gutter: optional separation (length) between rows
// gutter: quickly apply a length to both column- and row-gutter
//
// repeat-header: true = repeat the first row (or rowspan)
// on all pages; integer = repeat for the first n pages;
// array of integers = repeat on exactly those pages
// (where 1 is the first, so ignored); false = do not repeat
// the first row group (default).
//
// header-rows: minimum amount of rows for the repeatable
// header. 1 by default. Automatically increases if
// one of the cells is a rowspan that would go beyond the
// given amount of rows. For example, if 3 is given,
// then at least the first 3 rows will repeat.
//
// header-hlines-have-priority: if true, the horizontal
// lines below the header being repeated take priority
// over the rows they appear atop of on further pages.
// If false, they draw their own horizontal lines.
// Defaults to true.
//
// rtl: if true, the table is horizontally flipped.
// That is, cells and lines are placed in the opposite order
// (starting from the right), and horizontal lines are flipped.
// This is meant to simulate the behavior of default Typst tables when
// 'set text(dir: rtl)' is used, and is useful when writing in a language
// with a RTL (right-to-left) script.
// Defaults to false.
//
// auto-lines: true = applies true to both auto-hlines and
// auto-vlines; false = applies false to both.
// Their values override this one unless they are 'auto'.
//
// auto-hlines: true = draw a horizontal line on every line
// without a manual horizontal line specified; false = do
// not draw any horizontal line without manual specification.
// Defaults to 'auto' (follows 'auto-lines').
//
// auto-vlines: true = draw a vertical line on every column
// without a manual vertical line specified; false = requires
// manual specification. Defaults to 'auto' (follows
// 'auto-lines')
//
// map-cells: Takes a cellx and returns another cellx (or
// content).
//
// map-hlines: Takes each horizontal line (hlinex) and
// returns another.
//
// map-vlines: Takes each vertical line (vlinex) and
// returns another.
//
// map-rows: Maps each row of cells.
// Takes (row_num, cell_array) and returns
// the modified cell_array. Note that, here, they
// cannot be sent to another row. Also, cells may be
// 'none' if they're a position taken by a cell in a
// colspan/rowspan.
//
// map-cols: Maps each column of cells.
// Takes (col_num, cell_array) and returns
// the modified cell_array. Note that, here, they
// cannot be sent to another row. Also, cells may be
// 'none' if they're a position taken by a cell in a
// colspan/rowspan.
//
// fit-spans: Determine if rowspans and colspans should fit within their
// spanned 'auto'-sized tracks (columns and rows) instead of causing them to
// expand based on the rowspan/colspan cell's size. (Most users of tablex
// shouldn't have to change this option.)
// Must either be a dictionary '(x: true/false, y: true/false)' or a boolean
// true/false (which is converted to the (x: value, y: value) format with both
// 'x' and 'y' being set to the same value; for instance, 'true' becomes
// '(x: true, y: true)').
// Setting 'x' to 'false' (the default) means that colspans will cause the last
// (rightmost) auto column they span to expand if the cell's contents are too
// long; setting 'x' to 'true' negates this, and auto columns will ignore the
// size of colspans. Similarly, setting 'y' to 'false' (the default) means that
// rowspans will cause the last (bottommost) auto row they span to expand if
// the cell's contents are too tall; setting 'y' to 'true' causes auto rows to
// ignore the size of rowspans.
// This setting is mostly useful when you have a colspan or a rowspan spanning
// tracks with fractional (1fr, 2fr, ...) size, which can cause the fractional
// track to have less or even zero size, compromising all other cells in it.
// If you're facing this problem, you may want experiment with setting this
// option to '(x: true)' (if this is affecting columns) or 'true' (for rows
// too, same as '(x: true, y: true)').
// Note that this option can also be set in a per-cell basis through cellx().
// See its reference for more information.
#let tablex(
    columns: auto, rows: auto,
    inset: 5pt,
    align: auto,
    fill: none,
    stroke: auto,
    column-gutter: auto, row-gutter: auto,
    gutter: none,
    repeat-header: false,
    header-rows: 1,
    header-hlines-have-priority: true,
    rtl: false,
    auto-lines: true,
    auto-hlines: auto,
    auto-vlines: auto,
    map-cells: none,
    map-hlines: none,
    map-vlines: none,
    map-rows: none,
    map-cols: none,
    fit-spans: false,
    ..items
) = {
    _tablex-table-counter.step()

    get-page-dim-writer()  // get the current page's dimensions

    let header-rows = validate-header-rows(header-rows)
    let repeat-header = validate-repeat-header(repeat-header, header-rows: header-rows)
    let header-hlines-have-priority = validate-header-hlines-priority(header-hlines-have-priority)
    let map-cells = validate-map-func(map-cells)
    let map-hlines = validate-map-func(map-hlines)
    let map-vlines = validate-map-func(map-vlines)
    let map-rows = validate-map-func(map-rows)
    let map-cols = validate-map-func(map-cols)
    let fit-spans = validate-fit-spans(fit-spans, default: (x: false, y: false))

    layout(size => locate(t_loc => style(styles => {
        let table_id = _tablex-table-counter.at(t_loc)
        let page_dimensions = get-page-dim-state(table_id)
        let page_dim_at = page_dimensions.final(t_loc)
        let t_pos = t_loc.position()

        // Subtract the max width/height from current width/height to disregard margin/etc.
        let page_width = size.width
        let page_height = size.height

        let max_pos = default-if-none(page_dim_at.bottom_right, (x: t_pos.x + page_width, y: t_pos.y + page_height))
        let min_pos = default-if-none(page_dim_at.top_left, t_pos)

        let items = items.pos().map(table-item-convert)

        let gutter = parse-gutters(
            col-gutter: column-gutter, row-gutter: row-gutter,
            gutter: gutter,
            styles: styles,
            page-width: page_width, page-height: page_height
        )

        let validated_cols_rows = validate-cols-rows(
            columns, rows, items: items.filter(is-tablex-cell))

        let columns = validated_cols_rows.columns
        let rows = validated_cols_rows.rows
        items += validated_cols_rows.items

        let col_len = columns.len()
        let row_len = rows.len()

        // generate cell matrix and other things
        let grid_info = generate-grid(
            items,
            x_limit: col_len, y_limit: row_len,
            map-cells: map-cells,
            fit-spans: fit-spans
        )

        let table_grid = grid_info.grid
        let hlines = grid_info.hlines
        let vlines = grid_info.vlines
        let items = grid_info.items

        // When there are more rows than the user specified, we ensure they have
        // the same size as the last specified row.
        let last-row-size = if rows.len() == 0 { auto } else { rows.last() }
        for _ in range(grid_info.new_row_count - row_len) {
            rows.push(last-row-size)  // add new rows (due to extra cells)
        }

        let col_len = columns.len()
        let row_len = rows.len()

        let auto_lines_res = generate-autolines(
            auto-lines: auto-lines, auto-hlines: auto-hlines,
            auto-vlines: auto-vlines,
            hlines: hlines,
            vlines: vlines,
            col_len: col_len,
            row_len: row_len
        )

        hlines += auto_lines_res.new_hlines
        vlines += auto_lines_res.new_vlines

        let parsed_lines = _parse-lines(hlines, vlines, styles: styles, page-width: page_width, page-height: page_height)
        hlines = parsed_lines.hlines
        vlines = parsed_lines.vlines

        let mapped_grid = apply-maps(
            grid: table_grid,
            hlines: hlines,
            vlines: vlines,
            map-hlines: map-hlines,
            map-vlines: map-vlines,
            map-rows: map-rows,
            map-cols: map-cols
        )

        table_grid = mapped_grid.grid
        hlines = mapped_grid.hlines
        vlines = mapped_grid.vlines

        // re-parse just in case
        let parsed_lines = _parse-lines(hlines, vlines, styles: styles, page-width: page_width, page-height: page_height)
        hlines = parsed_lines.hlines
        vlines = parsed_lines.vlines

        // convert auto to actual size
        let updated_cols_rows = determine-auto-column-row-sizes(
            grid: table_grid,
            page_width: page_width, page_height: page_height,
            styles: styles,
            columns: columns, rows: rows,
            inset: inset, align: align,
            gutter: gutter,
            fit-spans: fit-spans
        )

        let columns = updated_cols_rows.columns
        let rows = updated_cols_rows.rows
        let gutter = updated_cols_rows.gutter

        let row_groups = generate-row-groups(
            grid: table_grid,
            columns: columns, rows: rows,
            stroke: stroke, inset: inset,
            gutter: gutter,
            fill: fill, align: align,
            hlines: hlines, vlines: vlines,
            styles: styles,
            repeat-header: repeat-header,
            header-hlines-have-priority: header-hlines-have-priority,
            header-rows: header-rows,
            rtl: rtl,
            min-pos: min_pos,
            max-pos: max_pos,
            table-loc: t_loc,
            table-id: table_id
        )

        grid(columns: (auto,), rows: auto, ..row_groups)
    })))
}

// Same as table but defaults to lines off
#let gridx(..options) = {
    tablex(auto-lines: false, ..options)
}
