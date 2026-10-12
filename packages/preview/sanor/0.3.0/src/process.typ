#import "utils.typ"
#import "object-case.typ": provide-object, resolve-case
#import "rules.typ": Applier, apply
#import "class.typ": class, class-of

/// Indices
/// `#s.push(1)` -> go to the next slide
/// `#s.push(-1)` -> go back one slide
/// `#s.push(apply("name"))` -> apply the rule `apply("name")` here
#let get-total-steps(actions) = {
  actions.map(a => if class-of(a) == int { a } else { 1 }).sum(default: 0)
}

/// A step consists of multiple rules, and each rules contains a definition.
#let _process-a-rule(ctx, rule-or-name) = {
  let rule = rule-or-name
  // default rule for "name" shortcut
  if class-of(rule-or-name) == str {
    rule = apply(rule-or-name) // If a name is specified, `apply` rule is used.
  }
  // Previous cases, if available
  let case-steps = ctx.cases.at(rule.name, default: ctx.default-cases)
  // Add the rule to the current step.
  case-steps.at(ctx.step - 1).push(rule.applier)
  // Update the cases of that element
  ctx.cases.insert(rule.name, case-steps)

  return ctx
}

/// Assign the commands to the right element.
#let _allocate-appliers(ctx, actions) = {
  ctx.total-steps = get-total-steps(actions)
  ctx.default-cases = ((),) * ctx.total-steps

  for action in actions {
    if type(action) == int {
      ctx.step += action
    } else if class-of(action) in ("rule", str) {
      ctx = _process-a-rule(ctx, action)
      ctx.step += 1
    } else if class-of(action) == array {
      ctx = action.fold(ctx, (ctx, rule) => _process-a-rule(ctx, rule))
      ctx.step += 1
    } else {
      panic("Unknown rule specification")
    }
  }

  return ctx
}

// MAIN logic
#let _process-a-step(status, step) = {
  // Current appliers in this step, initialization.
  status.appliers = ()
  // If this is the first step, display the history if it is active
  if status.history == () and step == () {
    if status.active {
      status.appliers += (status.base-display,)
    } else {
      status.appliers += (status.base-hidden,)
    }
    // If this is NOT the first step, display according to the history
  } else if step == () {
    status.appliers = status.track
  }

  for applier in step {
    // copy the last status
    status.prev-active = status.active

    if applier.active != auto {
      status.active = applier.active
    }
    // 'track' and 'history' must be equivalent when the element is visible.
    // But, track can have invisible modifiers, which will be eliminated
    // once the element becomes visible.
    if status.active {
      status.track = status.history
    }

    if applier.inherit == true {
      status.appliers += status.track + (applier,)
    } else {
      status.appliers = (applier,)
    }

    if applier.active == false {
      status.current-hidden = applier
    }

    if applier.remain == true {
      if status.active {
        status.history += (applier,)
        status.track = status.history
      } else {
        status.track += (applier,)
      }
    }
  
    if applier.kind == "clear" {
      status.history = ()
      status.track = ()
    }
    // When the rule is active/inactive, it has their own appliers.
    // When the rule is auto active, if it inherits, 
    // it can hide/show based on the history.
    // When the rule is auto active and it does not inherit, 
    // it must ne hidden or show based on status. By default, 
    // it is "base", so we have to force "hidden" when 
    // status.active is false. 
    if applier.active == auto and not applier.inherit and not status.active {
      status.appliers += (status.current-hidden,)
    }
    // restore the previous status for 'once'
    if applier.kind == "once" {
      status.active = status.prev-active
    }
  }

  return (status, status.appliers)
}

#let _process-steps(ctx, steps) = {
  let base-display = Applier("apply", ("base",), inherit: true, active: auto, remain: true)
  let base-hidden = Applier("apply", ("hidden",), inherit: true, active: auto, remain: true)

  let status = class(
    "status",
    active: ctx.is-shown,
    track: (), // for retaining animation
    history: (), // for keep tracks of visible modifiers
    appliers: (),
    base-display: base-display,
    base-hidden: base-hidden,
    current-hidden: base-hidden,
    prev-active: ctx.is-shown, // for restoring 'once' visbility
  )

  let result = ()

  for step in steps {
    (status, step) = _process-a-step(status, step)

    result.push(step.map(a => a.cases).sum())
  }

  return result
}

/// Resolve the commands into cases that can sent to the `tag` function.
#let _process(ctx, actions) = {
  ctx = _allocate-appliers(ctx, actions)
  ctx.cases = utils.map-dict-values(ctx.cases, steps => _process-steps(ctx, steps))

  return ctx
}
