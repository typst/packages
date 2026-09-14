#import "utils.typ" as utils: strfmt
#import "object-case.typ": *

/// The `cases` are an array of cases.
/// `Applier` tells what kind of rule we are dealing with.
/// - kind -> "apply" | "once" | "clear", whether the action happens all after, just once, or clear all animations.
/// - inherit -> bool : whether to combine with previous active cases,
/// - active -> true | false | auto:  status to set the element to.
#let Applier(
  kind,
  cases,
  inherit: true,
  active: auto,
) = class(
  "applier",
  kind: kind,
  cases: cases,
  inherit: inherit,
  active: active,
)

#let Rule(name, applier) = class("rule", name: name, applier: applier)

#let make-applier(kind, ..maybe-cases, inherit: true, active: auto) = {
  let kwarg-cases = (make-case(maybe-cases.named()),)
  let arg-cases = maybe-cases.pos().map(make-case)
  Applier(kind, kwarg-cases + arg-cases, inherit: inherit, active: active)
}

#let rule(name, applier, default: "base") = {
  if applier.cases == () { applier.cases = (default,) }
  Rule(name, applier)
}

/// Applies cases to tagged content for the current and all subsequent steps.
///
/// This function creates a rule that applies the specified cases to content
/// tagged with the given name, and keeps those cases active in future steps.
///
/// - name (str): The tag name to apply to.
/// - ..cases (any): Cases or modifiers to apply.
/// - inherit (bool): Whether to combine with existing active cases.
/// -> rule
///
/// #example ```typst
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("text")[Hello]
///   #s.push(apply("text", text.with(fill: red)))
/// ], s))
/// ```
#let apply(name, ..cases, inherit: true) = rule(
  name,
  default: "base",
  make-applier("apply", ..cases, inherit: inherit, active: true),
)

/// Applies cases to tagged content for only one step.
///
/// This function creates a rule that applies the specified cases to content
/// tagged with the given name, but only for the current step.
///
/// - name (str): The tag name to apply to.
/// - ..cases (any): Cases or modifiers to apply.
/// - inherit (bool): Whether to combine with existing active cases.
/// -> rule
///
/// #example ```typst
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("text")[Hello]
///   #s.push(once("text", text.with(fill: red)))
///   #s.push(1)  // Next step, red is gone
/// ], s))
/// ```
#let once(name, ..cases, inherit: true) = rule(
  name,
  default: "base",
  make-applier("once", ..cases, inherit: inherit, active: true),
)

/// Covers tagged content by applying cases and preventing inheritance.
///
/// This function hides content by applying the specified cases without
/// inheriting previous modifications.
///
/// - name (str): The tag name to cover.
/// - ..cases (any): Cases or modifiers to apply.
/// -> rule
///
/// #example ```typst
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("text")[Hello]
///   #s.push(cover("text"))  // Hides the text
/// ], s))
/// ```
#let cover(name, ..cases) = rule(
  name,
  default: "hidden",
  make-applier("apply", ..cases, inherit: false, active: false),
)

/// Reverts tagged content to specified cases without inheritance.
///
/// This function applies the specified cases to content without combining
/// with previous modifications.
///
/// - name (str): The tag name to revert.
/// - ..cases (any): Cases or modifiers to apply.
/// -> rule
///
/// #example ```typst
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("text")[Hello]
///   #s.push(apply("text", text.with(fill: red)))
///   #s.push(revert("text", text.with(fill: blue)))  // Only blue, not red+blue
/// ], s))
/// ```
#let revert(name, ..cases) = rule(
  name,
  default: "base",
  make-applier("apply", ..cases, inherit: false, active: auto),
)

/// Forces application of cases without inheritance.
///
/// This is equivalent to `apply(name, ..cases, inherit: false)`.
///
/// - name (str): The tag name to force.
/// - ..cases (any): Cases or modifiers to apply.
/// -> rule
///
/// #example ```typst
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("text")[Hello]
///   #s.push(force("text", text.with(fill: red)))
/// ], s))
/// ```
#let force(name, ..cases) = apply(name, ..cases, inherit: false)

/// Clear the previous animation sequence on an element.
/// 
/// - name (str): The tag name of the element to clear.
/// -> rule
#let clear(name) = rule(
  name,
  default: "base",
  make-applier("clear", inherit: false, active: auto)
)