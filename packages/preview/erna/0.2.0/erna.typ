#let aspect-ratio(content) = {
    let size = measure(content)
    size.width / size.height
}

#let cell(gutter: 0pt, ..args) = {
    let items = args.pos()
    let gutters-height = (items.len() - 1) * gutter
    let combined-aspect-ratio = 1.0 / items.map(item => 1.0 / aspect-ratio(item)).sum()

    (
        items: items,
        gutters-height: gutters-height,
        aspect-ratio: combined-aspect-ratio,
    )
}

#let solve(step: 0, max-steps: 64, tolerance: 1pt, min-height, max-height, available-width, cells) = {
    let height = (min-height + max-height) / 2
    let widths = cells.map(cell => cell.aspect-ratio * (height - cell.gutters-height))

    let solved-width = widths.fold(0pt, (sum, width) => sum + width)
    let deviation = calc.abs(available-width - solved-width)

    // TODO: Add to state for debugging purposes, like seeing how many steps it took
    // [+ #solved-width × #height #widths]

    if deviation < tolerance or step > max-steps {
        return widths
    }

    if solved-width > available-width {
        // Too high
        solve(step: step + 1, max-steps: max-steps, tolerance: tolerance, min-height, height, available-width, cells)
    } else {
        // Too low
        solve(step: step + 1, max-steps: max-steps, tolerance: tolerance, height, max-height, available-width, cells)
    }
}

#let row(gutter: 0pt, ..args) = context {
    let cells = args.pos().map(paths => {
        if type(paths) == array {
            cell(gutter: gutter, ..paths)
        } else {
            cell(gutter: gutter, paths)
        }
    })

    layout(parent => {
        let gutters-width = (cells.len() - 1) * gutter
        let available-width = parent.width - gutters-width

        // Theoretical minimum height, as if horizontal gutters where not there
        let min-ratio = cells.fold(0, (sum, cell) => sum + cell.aspect-ratio)
        let min-height = available-width / min-ratio

        // Theoretical maximum height would be the minimum height and all the gutters
        let max-gutters = cells.fold(0pt, (current-max, cell) => calc.max(current-max, cell.gutters-height))
        let max-height = min-height + max-gutters

        let widths = solve(min-height, max-height, available-width, cells)

        // TODO: Add to state for debugging
        // [widths #widths]

        grid(
            gutter: gutter,
            columns: widths,
            ..cells.enumerate().map(((index, cell)) => {
                let heights = cell.items.map(content => {
                  let width = widths.at(index)
                  let height = widths.at(index) / aspect-ratio(content)
                  height
                })
                grid(
                    gutter: gutter,
                    columns: widths.at(index),
                    rows: heights,
                    ..cell.items.map(content => {
                        let width = widths.at(index)
                        let height = widths.at(index) / aspect-ratio(content)
                        let factor = 100% * (width / measure(content).width)

                        // TODO: Instead of factor, it would be easier to just use x: width and y: height, but https://github.com/typst/typst/issues/6636 makes it buggy
                        let scaled = scale(factor, reflow: true, content)

                        scaled
                    })
                )
            })
        )
    })
}

#let multiple-rows(gutter: 0pt, ..args) = context {
    let rows = args.pos().map(arg => {
        if type(arg) == array {
            arg
        } else {
            (arg,)
        }
    })

    grid(
        gutter: gutter,
        columns: 1,
        ..rows.map(single-row => row(gutter: gutter, ..single-row))
    )
}

