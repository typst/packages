#let image_ratio(image) = {
    let size = measure(image)
    size.width / size.height
}

#let cell(gutter: 0pt, ..args) = {
    let paths = args.pos()
    let images = paths.map(path => image(path))
    let gutters_height = (images.len() - 1) * gutter
    let aspect_ratio = 1.0 / images.map(image => 1.0 / image_ratio(image)).sum()

    (
        images: images,
        gutters_height: gutters_height,
        aspect_ratio: aspect_ratio,
    )
}

#let solve(step: 0, max_steps: 64, tolerance: 1pt, min_height, max_height, available_width, cells) = {
    let height = (min_height + max_height) / 2
    let widths = cells.map(cell => cell.aspect_ratio * (height - cell.gutters_height))

    let solved_width = widths.fold(0pt, (sum, width) => sum + width)
    let deviation = calc.abs(available_width - solved_width)

    // TODO: Add to state for debugging purposes, like seeing how many steps it took
    // [+ #solved_width × #height #widths]

    if deviation < tolerance or step > max_steps {
        return widths
    }

    if solved_width > available_width {
        // Too high
        solve(step: step + 1, max_steps: max_steps, tolerance: tolerance, min_height, height, available_width, cells)
    } else {
        // Too low
        solve(step: step + 1, max_steps: max_steps, tolerance: tolerance, height, max_height, available_width, cells)
    }
}

#let image_row(gutter: 0pt, ..args) = context {
    let cells = args.pos().map(paths => {
        if type(paths) == array {
            cell(gutter: gutter, ..paths)
        } else {
            cell(gutter: gutter, paths)
        }
    })

    layout(parent => {
        let gutters_width = (cells.len() - 1) * gutter
        let available_width = parent.width - gutters_width

        // Theoretical minimum height, as if horizontal gutters where not there
        let min_ratio = cells.fold(0, (sum, cell) => sum + cell.aspect_ratio)
        let min_height = available_width / min_ratio

        // Theoretical maximum height would be the minimum height and all the gutters
        let max_gutters = cells.fold(0pt, (current_max, cell) => calc.max(current_max, cell.gutters_height))
        let max_height = min_height + max_gutters

        let widths = solve(min_height, max_height, available_width, cells)

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

#let image_rows(gutter: 0pt, ..args) = context {
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
        ..rows.map(row => image_row(gutter: gutter, ..row))
    )
}

