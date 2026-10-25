#import "state.typ": *

#let _deixis-check-setup-state() = if not deixis-setup-state.get() {
  panic("deixis: You must wrap your document with #show: deixis-setup-notes(..) before declaring any notes!")
}

// Typst's first layout pass has no introspection data: the setup flag still
// reads false there. Panicking inline would drop that pass's live output and
// delay everything depending on it by one pass; bodies first executed by a
// later printer (nested notes in endnotes) then exceed the five-pass budget.
// Content declarations defer the diagnostic to its own context instead. Setup
// removes it from the second pass on; without setup, the final pass fails.
// Value-returning readers, and repeats that cannot paint before the final
// registry exists, keep the inline check and its diagnostic precedence.
#let _deixis-setup-guard() = if not deixis-setup-state.get() { context _deixis-check-setup-state() }
// For contexts with early returns, which would discard a joined guard.
#let _deixis-setup-context(render) = context {
  _deixis-setup-guard()
  render()
}

// Public aliases are normalized separately from private instance/domain keys.
// Encoding every namespace prevents a user name from impersonating another kind.
#let _deixis-scope-key(kind, value) = repr((kind, value))
#let _deixis-scope-name(value, option) = {
  assert(type(value) in (str, label) and str(value).len() > 0,
    message: "deixis: " + option + " must be a nonempty string or label.")
  str(value)
}

#let _deixis-validate-target(target) = if not (
  type(target) in (str, label, int) and (type(target) != int or target <= 0)
    and (type(target) not in (str, label) or str(target).len() > 0)
) {
  panic("deixis: Target must be a nonempty string ID, a label, 0, or a negative integer.")
}

#let _deixis-page-target = (render-id: "page", count-id: "page", inst-id: "page")

// Resolve private parent identities directly. Only public names pass through
// the alias lookup: an encoded-looking user name cannot select an auto instance.
#let _deixis-scope-target(scopes, scope, trail: (), validate: false) = {
  if scope.id in trail {
    if validate { panic("deixis: Cyclic counter synchronization involving " + repr(scope.name) + ".") }
    return (render-id: scope.render-id, count-id: scope.render-id, inst-id: scope.id)
  }
  let count-id = scope.render-id
  if scope.sync-target != auto {
    let sync = scope.sync-target
    if type(sync) == int {
      let idx = scope.parents.len() - 1 + sync
      let parent = if idx >= 0 and idx < scope.parents.len() {
        scopes.find(s => s.id == scope.parents.at(idx))
      } else { none }
      count-id = if parent == none { "page" } else {
        _deixis-scope-target(scopes, parent, trail: trail + (scope.id,), validate: validate).count-id
      }
    } else {
      let name = str(sync)
      let parent = scopes.find(s => s.name == name)
      count-id = if name == "page" { "page" } else if parent == none {
        assert(not validate, message: "deixis: Unknown scope target " + repr(name) + ". Use a declared block ID or page.")
        _deixis-scope-key("block", name)
      } else { _deixis-scope-target(scopes, parent, trail: trail + (scope.id,), validate: validate).count-id }
    }
  }
  (render-id: scope.render-id, count-id: count-id, inst-id: scope.id)
}

// Missing forward declarations get stable provisional keys, never another
// namespace's owner. Diagnose content-producing uses after layout instead of
// erasing the declarations that would satisfy them on the next native pass.
#let _deixis-declared-target(scopes, target, trail: (), validate: false) = {
  if target == "page" { return _deixis-page-target }
  let scope = scopes.find(s => s.name == target)
  if scope == none {
    assert(not validate, message: "deixis: Unknown scope target " + repr(target) + ". Use a declared block ID or page.")
    let key = _deixis-scope-key("block", target)
    return (render-id: key, count-id: key, inst-id: key)
  }
  _deixis-scope-target(scopes, scope, trail: trail, validate: validate)
}

#let _deixis-scope-target-hint(target) = if type(target) in (str, label) and str(target) != "page" {
  [#metadata(str(target))<deixis-scope-target>]
}

#let _deixis-validate-scope-graph() = {
  let scopes = query(<deixis-scope>).map(s => s.value)
  let names = (:)
  for scope in scopes {
    if scope.name != none {
      assert(scope.name not in names,
        message: "deixis: Duplicate block ID " + repr(scope.name) + ". Use thread to share rendering/counters between distinct blocks.")
      names.insert(scope.name, true)
    }
  }
  for scope in scopes { let resolved = _deixis-scope-target(scopes, scope, validate: true) }
  for hint in query(<deixis-scope-target>) {
    let resolved = _deixis-declared-target(scopes, hint.value, validate: true)
  }
}

// Resolution returns independent rendering, numbering, and instance identities.
// Inside state transforms, pass captured scopes to avoid a contextual query.
#let _deixis-resolve-target(sys, target, scopes: none) = {
  let target = if target == auto { 0 } else { target }
  _deixis-validate-target(target)
  if type(target) == int {
    let idx = sys.stack.len() - 1 + target
    if idx >= 0 and idx < sys.stack.len() {
      let level = sys.stack.at(idx)
      return (render-id: level.render-id, count-id: level.count-id, inst-id: level.inst-id)
    }
    return _deixis-page-target
  }
  let name = str(target)
  if name == "page" { return _deixis-page-target }
  if name in sys.blocks {
    let b = sys.blocks.at(name)
    return (render-id: b.render-id, count-id: b.count-id, inst-id: b.inst-id)
  }
  let declarations = if scopes == none { query(<deixis-scope>).map(s => s.value) } else { scopes }
  _deixis-declared-target(declarations, name)
}

// Capture only document declarations before a pure state transform. Reading the
// full state here would add a convergence dependency for every successive mark.
#let _deixis-with-target-scopes(target, render) = if type(target) in (str, label) and str(target) != "page" {
  _deixis-scope-target-hint(target)
  context render(query(<deixis-scope>).map(s => s.value))
} else { render(()) }

#let _deixis-resolve-body-target(sys, reg, target) = if target == auto {
  (render-id: reg.target-id, inst-id: reg.inst-id)
} else { _deixis-resolve-target(sys, target) }
