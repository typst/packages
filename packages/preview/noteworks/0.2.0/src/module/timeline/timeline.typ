// =====================================================
// TIMELINE OBJECTS
// =====================================================
// Object constructors for timeline visualizations

/// Create a timeline event
///
/// Parameters:
/// - date: Date/time label (string or content)
/// - title: Event title
/// - description: Optional longer description
/// - highlight: Whether to highlight this event
#let event(
  date,
  title,
  description: none,
  highlight: false,
) = (
  type: "timeline-event",
  date: date,
  title: title,
  description: description,
  highlight: highlight,
)

/// Create a timeline object
///
/// Parameters:
/// - events: Array of event objects
/// - direction: "vertical" or "horizontal"
/// - style: Style overrides (line-color, node-color, etc.)
#let timeline(
  events,
  direction: "vertical",
  style: (:),
) = (
  type: "timeline",
  events: events,
  direction: direction,
  style: style,
)

// =====================================================
// TYPE CHECKERS
// =====================================================

#let is-event(obj) = type(obj) == dictionary and obj.at("type", default: none) == "timeline-event"
#let is-timeline(obj) = type(obj) == dictionary and obj.at("type", default: none) == "timeline"
