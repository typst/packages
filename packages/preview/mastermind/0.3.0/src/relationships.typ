/// Basic relationship.
/// -> relationship
#let _relationship(
  /// Starting class.
  /// -> string
  from-rect,
  /// End class.
  /// -> string
  to-rect,
  /// Line.
  /// -> array
  line: (),
  /// Starting line mark.
  /// -> string | none
  start-mark: none,
  /// Ending line mark.
  /// -> string | none
  end-mark: none,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return (
    from-rect: from-rect,
    to-rect: to-rect,
    from-side: from-side,
    to-side: to-side,
    name: from-rect + "-" + to-rect,
    start-mark: start-mark,
    end-mark: end-mark,
    line: line,
  )
}

/// Create an inheritance relationship.
/// -> relationship
#let inheritance(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "triangle",
    from-side: from-side,
    to-side: to-side,
  )
}

/// Create an inheritance relationship.
/// -> relationship
#let dependency(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

/// Create an inheritance relationship.
/// -> relationship
#let association(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

/// Create an inheritance relationship.
/// -> relationship
#let aggregation(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond",
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

/// Create an inheritance relationship.
/// -> relationship
#let composition(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond-filled",
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

/// Create an implementation relationship.
/// -> relationship
#let implementation(
  /// Starting class.
  /// -> string
  from-rect,
  /// Ending class.
  /// -> string
  to-rect,
  /// Starting side.
  /// -> "north" | "east" | "south" | "west"
  from-side: none,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  to-side: none,
) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "triangle",
    from-side: from-side,
    to-side: to-side,
  )
}
