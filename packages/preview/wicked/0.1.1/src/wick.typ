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
    dist: auto,   // 0.5em, 
    offset: auto, // 0.25em, 
    stroke: auto, // 0.5pt, 
    flat: auto,   // true, 
    content
) = context {
    // Checking if all data types are correct
    assert(
        type(pos) == alignment, 
        message: "expected `alignment` type for `pos`, found `" + str(type(pos)) + "`"
    )
    assert(
        type(dx) == length, 
        message: "expected `length` type for `dx`, found `" + str(type(dx)) + "`"
    )
    assert(
        type(dy) == length, 
        message: "expected `length` type for `dy`, found `" + str(type(dy)) + "`"
    )
    assert(
        type(dist) == length or dist == auto, 
        message: "expected `length` or `auto` type for `dist`, found `" + str(type(dist)) + "`"
    )
    assert(
        type(offset) == length or offset == auto, 
        message: "expected `length` or `auto` type for `offset`, found `" + str(type(offset)) + "`"
    )
    assert(
        type(flat) == bool or flat == auto, 
        message: "expected `bool` or `auto` type for `flat`, found `" + str(type(flat)) + "`"
    )

    assert.eq(pos.axis(), "vertical", message: "expected a vertical alignment for `pos`, found `" + str(repr(pos)) + "`")
    
    let h = here()

    // Find all contraction points up to here
    let points = query(selector(metadata).before(h)).filter(mt => {
        if not mt.has("value") { return false }
        
        // Check if `metadata.value` is in the form `(type: "wicked", ...)`
        if type(mt.value) != dictionary { return false }
        if not mt.value.keys().contains("type") { return false }
        if mt.value.type != "wick" { return false }
        
        // Check the conditions required for a contraction to happen
        if not mt.value.keys().contains("id") { return false }
        if not mt.value.keys().contains("pos") { return false }
        if mt.value.id != id { return false }
        if mt.value.pos != pos { return false }
        
        // Sanity checks
        if type(mt.value.pos) != alignment { return false }
        if not mt.value.keys().contains("size") { return false }
        if type(mt.value.size) != dictionary { return false }
        if not mt.value.size.keys().contains("width") { return false }
        if type(mt.value.size.width) != length { return false }
        if not mt.value.size.keys().contains("height") { return false }
        if type(mt.value.size.height) != length { return false }
        if not mt.value.keys().contains("dx") { return false }
        if type(mt.value.dx) != length { return false }
        if not mt.value.keys().contains("dy") { return false }
        if type(mt.value.dy) != length { return false }
        if not mt.value.keys().contains("dist") { return false }
        if type(mt.value.dist) != length and mt.value.dist != auto { return false }
        if not mt.value.keys().contains("offset") { return false }
        if type(mt.value.offset) != length and mt.value.offset != auto { return false }
        if not mt.value.keys().contains("stroke") { return false }
        if not mt.value.keys().contains("flat") { return false }
        if type(mt.value.flat) != bool and mt.value.flat != auto { return false }

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

    // 0.25em is required to adjust for the metadata placement
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
        box(width: 0pt, height: 0pt, curve(stroke: options.stroke, 
            curve.move(vertices.at(0)),
            curve.line(vertices.at(1)),
            curve.line(vertices.at(2)),
            curve.line(vertices.at(3)),
        ))
    )#content]
}