/// Possible participant shapes
/// #box(width: 100%, align(center)[
///   #chronos.diagram({
///     import chronos: *
///     let _par = _par.with(show-bottom: false)
///     _par("Foo", display-name: "participant", shape: "participant")
///     _par("Foo1", display-name: "actor", shape: "actor")
///     _par("Foo2", display-name: "boundary", shape: "boundary")
///     _par("Foo3", display-name: "control", shape: "control")
///     _par("Foo4", display-name: "entity", shape: "entity")
///     _par("Foo5", display-name: "database", shape: "database")
///     _par("Foo6", display-name: "collections", shape: "collections")
///     _par("Foo7", display-name: "queue", shape: "queue")
///     _par("Foo8", display-name: "custom", shape: "custom", custom-image: TYPST)
///     _gap()
///   })
/// ])
#let SHAPES = (
  "participant",
  "actor",
  "boundary",
  "control",
  "entity",
  "database",
  "collections",
  "queue",
  "custom"
)

/// Creates a new participant
/// - name (str): Unique participant name used as reference in other functions
/// - display-name (auto, content): Name to display in the diagram. If set to `auto`, `name` is used
/// - from-start (bool): If set to true, the participant is created at the top of the diagram. Otherwise, it is created at the first reference
/// - invisible (bool): If set to true, the participant will not be shown
/// - shape (str): The shape of the participant. Possible values in @@SHAPES
/// - color (color): The participant's color
/// - custom-image (none, image): If shape is 'custom', sets the custom image to display
/// - show-bottom (bool): Whether to display the bottom shape
/// - show-top (bool): Whether to display the top shape
/// -> array
#let _par(
  name,
  display-name: auto,
  from-start: true,
  invisible: false,
  shape: "participant",
  color: rgb("#E2E2F0"),
  custom-image: none,
  show-bottom: true,
  show-top: true,
) = {}

/// Sets some options for columns between participants
///
/// Parameters `p1` and `p2` MUST be consecutive participants (also counting found/lost messages), but they do not need to be in the left to right order
/// - p1 (str): The first neighbouring participant
/// - p2 (str): The second neighbouring participant
/// - width (auto, int, float, length): Optional fixed width of the column\ If the column's content (e.g. sequence comments) is larger, it will overflow
/// - margin (int, float, length): Additional margin to add to the column\ This margin is not included in `width` and `min-width`, but rather added separately
/// - min-width (int, float, length): Minimum width of the column\ If set to a larger value than `width`, the latter will be overriden
/// - max-width (int, float, length, none): Maximum width of the column\ If set to a lower value than `width`, the latter will be overriden\ If set to `none`, no restriction is applied
#let _col(
  p1,
  p2,
  width: auto,
  margin: 0,
  min-width: 0,
  max-width: none
) = {}