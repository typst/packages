#import "utils.typ"

#let process-a-step(rules, ctx: (:), onces: (:)) = {
  if type(rules) != array { rules = (rules,) }
  for rule in rules {
    if rule.type == "apply" {
      let new-modifier
      if rule.name in ctx {
        let old-modifier = ctx.at(rule.name).modifier
        if (
          type(old-modifier) == array and old-modifier.all(m => type(m) == function)
        ) {
          new-modifier = it => utils.pipe(it, ..old-modifier, ..rule.modifier)
        } else {
          new-modifier = rule.modifier
        }
      } else {
        new-modifier = rule.modifier
      }
      ctx.insert(rule.name, (
        case: rule.case,
        modifier: new-modifier,
      ))
    }
    if rule.type == "clear" {
      let _ = ctx.remove(rule.name, default: none)
    }
    if rule.type == "once" {
      let case = "__base__"
      let modifier = (:)
      if not onces.at(rule.name, default: false) {
        case = rule.case
        modifier = rule.modifier
        onces.insert(rule.name, true)
      }
      ctx.insert(rule.name, (
        case: case,
        modifier: modifier,
      ))
    }
  }
  return (ctx, onces)
}

#let process-steps(steps) = {
  let ctx = (:)
  let onces = (:)
  let result = ()
  for step in steps {
    let original = ctx
    (ctx, onces) = process-a-step(step, ctx: ctx, onces: onces)
    result.push(ctx)
    for (name, applied) in onces.pairs() {
      if applied {
        if name in original {
          ctx.insert(name, original.at(name))
        } else {
          let _ = ctx.remove(name)
        }
        let _ = onces.remove(name)
      }
    }
  }
  return result
}


#let control(i, body-func, steps, hider: hide, is-shown: false) = {
  let commands = process-steps(steps)
  let info = (
    subslide: i,
    tag-info: (
      hider: hider,
      is-shown: is-shown,
      defined-states: (:),
      tags: commands.at(i, default: (:)),
    ),
  )
  body-func(info)
}

#let subslide(info, func) = {
  let i = info.subslide
  {
    set heading(outlined: i == 1, bookmarked: i == 1)
    func(info)
  }
  v(0pt)
  counter(page).update(n => n - 1)
  pagebreak(weak: true)
}

#let superhide(body) = {
  show enum: hide
  show list: hide
  hide(body)
}

#let options = (
  handout: false,
  subslide: 1,
  tag-info: (hider: hide, is-shown: false, defined-states: (:), tags: (:)),
  handout-index: auto,
  hider: superhide,
)

#let slide(
  info: options,
  func,
  controls: (),
  hider: auto,
  is-shown: false,
  defined-states: (:),
) = {
  let base-info = utils.merge-dicts(base: options, info)
  let info = utils.merge-dicts(
    base: options,
    info
      + (
        tag-info: (
          hider: if hider == auto { base-info.hider } else { hider },
          is-shown: is-shown,
          defined-states: defined-states,
        ),
      ),
  )

  if type(controls) != array {
    panic("Controls must be an array. Did you forget the trailing `,`?")
  }
  let steps = controls.len()
  let commands = process-steps(controls)
  if steps == 0 { steps += 1 }
  if info.handout {
    let index = if info.handout-index == auto { steps - 1 } else { info.handout-index }
    info.tag-info.tags = commands.at(index, default: (:))
    return subslide(info, func)
  } else {
    for i in range(steps) {
      info.tag-info.tags = commands.at(i, default: (:))
      subslide(info, func)
    }
  }
}

#let set-option(..new-options) = {
  let options = utils.merge-dicts(base: options, new-options.named())
  return (
    slide: slide.with(info: options),
  )
}
