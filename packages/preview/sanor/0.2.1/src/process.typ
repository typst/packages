#import "utils.typ"
#import "object-case.typ": make-object, resolve-case
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
  if class-of(rule-or-name) == str {
    rule = apply(rule-or-name) // If a name is specified, `apply` rule is used.
  }
  let case-steps = ctx.cases.at(rule.name, default: ctx.default-cases)
  case-steps.at(ctx.step - 1).push(rule.applier)
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

#let _process-a-step(status, step) = {
  let prev = status.appliers
  let out = ()
  let is-last-once = false

  for applier in step {
    if applier.active != auto { status.active = applier.active }

    if applier.kind == "clear" {
      if status.active {
        prev = (status.base-display,)
      } else {
        prev = (status.base-hidden,)
      }
    }

    if applier.inherit {
      out += (applier,)
    } else {
      out = (applier,)
    }

    // to capture the last `once` and deactivate if there is nothing to show.
    is-last-once = applier.kind == "once"
  }

  // filter out the `once` effect and the auto active element from `status.active`.
  status.appliers = prev + out.filter(a => (a.kind != "once" and a.active != auto))
  if is-last-once and status.appliers == () { status.active = false }

  return (status, out)
}

#let _process-steps(ctx, steps) = {
  let base-display = Applier("apply", ("base",), inherit: true, active: auto)
  let base-hidden = Applier("apply", ("hidden",), inherit: true, active: auto)

  let status = class(
    "status",
    active: ctx.is-shown,
    appliers: (),
    base-display: base-display,
    base-hidden: base-hidden,
  )

  let result = ()

  for step in steps {
    step = status.appliers + step
    if step == () {
      step += if status.active { (base-display,) } else { (base-hidden,) }
    }
    (status, step) = _process-a-step(status, step)
    result.push(step.map(a => a.cases).sum())
  }
  return result
}

/// Resolve the commands into cases that can sent to the `tag` function.
#let _process(ctx, actions) = {
  ctx = _allocate-appliers(ctx, actions)
  ctx.cases = ctx
    .cases
    .pairs()
    .map(((name, steps)) => {
      (name, _process-steps(ctx, steps))
    })
    .to-dict()

  return ctx
}
