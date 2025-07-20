/// Manually adds an event to the given participant
/// - participant (str): The participant concerned by the event
/// - event (str): The event type (see @@EVENTS for ccepted values)
#let _evt(participant, event) = {}

/// Creates a sequence / message between two participants
/// - p1 (str): Start participant
/// - p2 (str): End participant
/// - comment (none, content): Optional comment to display along the arrow
/// - comment-align (str): Where to align the comment with respect to the arrow (see @@comment-align for accepted values)
/// - dashed (bool): Whether the arrow's stroke is dashed or not
/// - start-tip (str): Start arrow tip (see @@tips for accepted values)
/// - end-tip (str): End arrow tip (see @@tips for accepted values)
/// - color (color): Arrow's color
/// - flip (bool): If true, the arrow is flipped (goes from end to start). This is particularly useful for self calls, to change the side on which the arrow appears
/// - enable-dst (bool): If true, enables the destination lifeline
/// - create-dst (bool): If true, creates the destination lifeline and participant
/// - disable-dst (bool): If true, disables the destination lifeline
/// - destroy-dst (bool): If true, destroys the destination lifeline and participant
/// - disable-src (bool): If true, disables the source lifeline
/// - destroy-src (bool): If true, destroy the source lifeline and participant
/// - lifeline-style (auto, dict): Optional styling options for lifeline rectangles (see CeTZ documentation for more information on all possible values)
/// - slant (none, int): Optional slant of the arrow
/// -> array
#let _seq(
  p1,
  p2,
  comment: none,
  comment-align: "left",
  dashed: false,
  start-tip: "",
  end-tip: ">",
  color: black,
  flip: false,
  enable-dst: false,
  create-dst: false,
  disable-dst: false,
  destroy-dst: false,
  disable-src: false,
  destroy-src: false,
  lifeline-style: auto,
  slant: none
) = {}

/// Creates a return sequence
/// #examples.seq-return
/// - comment (none, content): Optional comment to display along the arrow
#let _ret(comment: none) = {}

/// Accepted values for `comment-align` argument of @@_seq()
/// #examples.seq-comm-align
#let comment-align = (
  "start", "end", "left", "center", "right"
)

/// Accepted values for `event` argument of @@_evt()
/// 
/// `EVENTS = ("create", "destroy", "enable", "disable")`
#let EVENTS = ("create", "destroy", "enable", "disable")

/// Accepted values for `start-tip` and `end-tip` arguments of @@_seq()
/// #examples.seq-tips
#let tips = (
  "", ">", ">>", "\\", "\\\\", "/", "//", "x", "o",
)