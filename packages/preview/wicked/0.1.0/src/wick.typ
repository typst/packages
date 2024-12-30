#let choose_shared_option(first, second, default) = {
    if first == auto and second == auto {
        return default
    } else if first != auto and second == auto {
        return first
    } else if first == auto and second != auto {
        return second
    } else if first != auto and second != auto {
        return second
    }
}

#let wick(
    id: 0, 
    pos: bottom, 
    dx: 0pt, 
    dy: 0pt, 
    dist: auto,     // 0.5em, 
    offset: auto, // 0.25em, 
    stroke: auto, // 0.5pt, 
    flat: auto,   // true, 
    content
) = context {
    assert.eq(pos.axis(), "vertical", message: "expected a vertical alignment")
    
    let h = here()

    // Find all contraction points up to here
    let points = query(selector(metadata).before(h)).filter(mt => {
        if not mt.has("value") { return false }
        if mt.value.type != "wick" { return false }
        // Contractables
        if mt.value.id != id { return false }
        if mt.value.pos != pos { return false }
        // Sanity checks
        if mt.value.size == none { return false }
        if mt.value.size.width == none { return false }
        if mt.value.size.height == none { return false }
        if mt.value.dist == none { return false }
        if mt.value.offset == none { return false }
        if mt.value.stroke == none { return false }
        if mt.value.flat == none { return false }
        return true
    })

    let size2 = measure(content)
    let meta = metadata((
        "type": "wick", 
        "id": id, 
        "size": size2, 
        "pos": pos,
        "dx": dx, 
        "dy": dy, 
        "dist": dist, 
        "offset": offset, 
        "stroke": stroke, 
        "flat": flat,
    ))

    if calc.rem(points.len(), 2) == 0 { 
        // This is the starting point for a possible contraction
        return [#meta#content]
    }

    // Draw the contraction

    let first = points.last()
    let pos1 = first.location().position()
    let pos2 = h.position()
    let size1 = first.value.size

    if pos1.page != pos2.page { return [#meta#content] }

    let sign = if pos == bottom { +1 } 
               else if pos == top { -1 }
               else if pos == horizon { 0 }
               else { +1 }

    let factor = if pos == bottom { 0 } 
               else if pos == top { 1 }
               else if pos == horizon { 0 }
               else { 0 }

    // Shared options
    let options = (
        dist: choose_shared_option(first.value.dist, dist, 0.5em),
        offset: choose_shared_option(first.value.offset, offset, 0.25em),
        stroke: choose_shared_option(first.value.stroke, stroke, 0.5pt),
        flat: choose_shared_option(first.value.flat, flat, true),
    )

    options.dist = if type(id) == int { options.dist * (1 + id / 2.0) } else{ options.dist }

    let vertical1 = first.value.dy + factor*size1.height
    let vertical2 = dy + factor*size2.height
    if options.flat {
        vertical1 = calc.max(vertical1, vertical2) 
        vertical2 = vertical1
    }

    // 0.25em is require to adjust for the metadata placement
    let vertices = (
        (
            pos1.x + first.value.dx + size1.width/2.0, 
            pos1.y + 0.25em + sign * (options.offset + first.value.dy + factor*size1.height)
        ),
        (
            pos1.x + first.value.dx + size1.width/2.0, 
            pos2.y + 0.25em + sign * (options.dist + vertical1)
        ),
        (
            pos2.x + dx + size2.width/2.0,
            pos2.y + 0.25em + sign * (options.dist + vertical2)
        ),
        (
            pos2.x + dx + size2.width/2.0, 
            pos2.y + 0.25em + sign * (options.offset + dy + factor*size2.height)
        )
    )

    return [#meta#place(dx: -pos2.x, dy: -pos2.y, 
        box(width: 0pt, height: 0pt, path(..vertices, stroke: options.stroke ))
    )#content]
}