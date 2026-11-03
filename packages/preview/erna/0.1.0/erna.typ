#let image-ratio(image) = {
    let size = measure(image)
    size.width / size.height
}

#let cell(gutter: 0pt, ..args) = {
    let paths = args.pos()
    let images = paths.map(path => image(path))
    let gutters-height = (images.len() - 1) * gutter
    let aspect-ratio = 1.0 / images.map(image => 1.0 / image-ratio(image)).sum()

    (
        images: images,
        gutters-height: gutters-height,
        aspect-ratio: aspect-ratio,
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

#let image-row(gutter: 0pt, ..args) = context {
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
            columns: cells.len(),
            ..cells.enumerate().map(((index, cell)) => {
                grid(
                    gutter: gutter,
                    columns: widths.at(index),
                    ..cell.images
                )
            })
        )
    })
}

#let image-rows(gutter: 0pt, ..args) = context {
    let rows = args.pos().map(row => {
        if type(row) == array {
            row
        } else {
            (row,)
        }
    })

    grid(
        gutter: gutter,
        columns: 1,
        ..rows.map(row => image-row(gutter: gutter, ..row))
    )
}

