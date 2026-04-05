/// Use ```typ #std.pagebreak()``` if an ```typ #import meander: *```
/// has shadowed the builtin #typ.pagebreak.
/// -> content
#let pagebreak = pagebreak

/// Use ```typ #std.colbreak()``` if an ```typ #import meander: *```
/// has shadowed the builtin #typ.colbreak.
/// -> content
#let colbreak = colbreak

/// Use ```typc std.content``` if an ```typ #import meander: *```
/// has shadowed the builtin #typ.t.content.
/// -> type
#let content = content

/// Use ```typc #std.grid(..)``` if an ```typ #import meander.contour: *```
/// has shadowed the builtin #typ.grid.
/// -> function
#let grid = grid

/// Use ```typc #std.query(..)``` if an ```typ #import meander: *```
/// has shadowed the builtin #typ.query.
/// -> function
#let query = query
