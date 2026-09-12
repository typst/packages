#import "utils.typ" as utils: strfmt
#import "object-case.typ": *

// The `cases` are an array of cases.
// `Applier` tells what kind of rule we are dealing with.
// - kind -> "apply" | "once" | "clear", class of the action. "once" will make the animation appears only one step, while the others retain their visibility.
// - inherited -> bool : whether to combine with previous active cases,
// - retained -> bool : whether to retain the animation to the next cases,
// - active -> true | false | auto: ability to change the visibility state of the element. 'true' makes it visible, 'false' makes it hidden, 'auto' retains the previous state.
#let Applier(
  kind,
  cases,
  inherit: true,
  remain: true,
  active: auto,
) = class(
  "applier",
  kind: kind,
  cases: cases,
  inherit: inherit,
  remain: remain,
  active: active,
)

#let Rule(name, applier) = class("rule", name: name, applier: applier)

// Constructor for an applier
// 'maybe-cases' may be 'cases' or 'name' of the element.
// 'kwarg-cases' is for changing properties of the element (as object).
#let make-applier(
  kind,
  ..maybe-cases,
  inherit: true,
  remain: true,
  active: auto,
) = {
  let kwarg-cases = maybe-cases.named()
  let arg-cases = maybe-cases.pos()
  let all-cases = ()
  // Filtering out the empty modifiers
  if kwarg-cases != (:) {
    all-cases += (kwarg-cases,)
  }
  if arg-cases != () {
    all-cases += arg-cases
  }

  Applier(kind, all-cases, inherit: inherit, remain: remain, active: active)
}

#let rule(name, applier, default: "base") = {
  // ensure name is a string
  name = str(name)
  // apply default cases
  if applier.cases == () { applier.cases = (default,) }

  return Rule(name, applier)
}

/// Applies cases to tagged content for the current and all subsequent steps.
///
/// This function creates a rule that applies the specified cases to content
/// tagged with the given name, and keeps those cases active in future steps.
///
/// -> rule
#let apply(
  /// The tag name to apply to.
  /// -> str
  name,
  /// Cases or modifiers to apply.
  /// -> cases
  ..cases,
  /// Whether to combine with existing active cases.
  /// -> bool
  inherit: true,
  /// Whether to remain the active cases to subsequent animations.
  /// -> bool
  remain: true,
  /// Whether the animation can change the visibility of the element.
  /// -> bool
  active: true,
) = rule(
  name,
  default: "base",
  make-applier("apply", ..cases, inherit: inherit, remain: remain, active: active),
)

/// Applies cases to tagged content for only one step.
///
/// This function creates a rule that applies the specified cases to content
/// tagged with the given name, but only for the current step.
///
/// -> rule
#let once(
  /// The tag name to apply to.
  /// -> str
  name,
  ///  Cases or modifiers to apply.
  /// -> cases
  ..cases,
  inherit: true,
  remain: false,
  active: true,
) = rule(
  name,
  default: "base",
  make-applier("once", ..cases, inherit: inherit, remain: remain, active: active),
)

/// Covers tagged content by applying cases and preventing inheritedance.
///
/// This function hides content by applying the specified cases without
/// inheriteding previous modifications.
///
/// -> rule
#let cover(
  /// The tag name to apply to.
  /// -> str
  name,
  ///  Cases or modifiers to apply.
  /// -> cases
  ..cases,
  inherit: true,
  remain: true,
  active: false,
) = rule(
  name,
  default: "hidden",
  make-applier("apply", ..cases, inherit: inherit, remain: remain, active: active),
)

/// Reverts tagged content to specified cases without inheritance.
/// This keeps the previous modifications, unlike 'clear'
///
/// This function applies the specified cases to content without combining
/// with previous modifications.
///
/// -> rule
#let revert(
  /// The tag name to apply to.
  /// -> str
  name,
  ///  Cases or modifiers to apply.
  /// -> cases
  ..cases,
  inherit: false,
  remain: true,
  active: auto,
) = rule(
  name,
  default: "base",
  make-applier("revert", ..cases, inherit: inherit, remain: remain, active: active),
)

/// Forces application of cases without inheritance.
///
/// This is equivalent to `apply(name, ..cases, inherited: false)`.
///
/// -> rule
#let force(
  /// The tag name to apply to.
  /// -> str
  name,
  ///  Cases or modifiers to apply.
  /// -> cases
  ..cases,
) = apply(name, ..cases, inherit: false)

/// Clear the previous animation sequence on an element.
///
/// -> rule
#let clear(
  /// The tag name of the element to clear.
  /// -> str
  name,
  /// Cases or modifiers to apply.
  /// -> cases
  ..cases,
) = rule(
  name,
  default: "base",
  make-applier("clear", ..cases, inherit: false, remain: true, active: auto),
)
