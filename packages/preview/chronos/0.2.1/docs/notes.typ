/// Creates a note
/// - side (str): The side on which to place the note (see @@SIDES for accepted values)
/// - content (content): The note's content
/// - pos (none, str, array): Optional participant(s) on which to draw next to / over. If `side` is "left" or "right", sets next to which participant the note is placed. If `side` is "over", sets over which participant(s) it is placed
/// - color (color): The note's color
/// - shape (str): The note's shape (see @@SHAPES for accepted values)
/// - aligned (bool): True if the note is aligned with another note, in which case `side` must be `"over"`, false otherwise
#let _note(
  side,
  content,
  pos: none,
  color: rgb("#FEFFDD"),
  shape: "default",
  aligned: false
) = {}

/// Accepted values for `shape` argument of @@_note()
/// #examples.notes-shapes
#let SHAPES = ("default", "rect", "hex")

/// Accepted values for `side` argument of @@_note()
/// #examples.notes-sides
#let SIDES = ("left", "right", "over", "across")