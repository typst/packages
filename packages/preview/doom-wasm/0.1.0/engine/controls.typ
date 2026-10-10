// Public action names map to the adapter's stable one-byte command protocol.
#let commands = (
  forward: "w", backward: "s", strafe-left: "a", strafe-right: "d",
  run-forward: "W", run-backward: "S", run-left: "A", run-right: "D",
  turn-left: "j", turn-right: "l", fire: "f", use: "e",
  forward-fire: "q", backward-fire: "z",
  weapon-1: "1", weapon-2: "2", weapon-3: "3", weapon-4: "4",
  weapon-5: "5", weapon-6: "6", weapon-7: "7",
  automap: "m", wait: "x", restart: "r", menu: "p",
  menu-up: "i", menu-down: "k", menu-left: "h", menu-right: "o",
  confirm: "c", back: "b", yes: "y", no: "n",
)
#let default-actions = {
  let result = (:)
  for (action, command) in commands { result.insert(action, (command,)) }
  result.restart = ("r", "R")
  result
}

// Overrides replace the keys of that action; () explicitly disables an action.
#let bindings(overrides) = {
  assert(type(overrides) == dictionary, message: "actions must be a dictionary of action names and key tuples")
  let result = default-actions
  for (action, keys) in overrides {
    assert(action in commands, message: "Unknown action: " + action)
    assert(type(keys) == array, message: action + " keys must be a tuple, e.g. (\"v\",)")
    result.insert(action, keys)
  }
  let used = (:)
  for (action, keys) in result {
    for key in keys {
      assert(type(key) == str, message: action + " keys must be strings")
      assert(key.clusters().len() == 1 and key.trim() != "", message: action + " keys must each be one non-whitespace character")
      assert(not (key in used), message: "Key " + repr(key) + " is bound more than once (" + used.at(key, default: action) + ", " + action + ")")
      used.insert(key, action)
    }
  }
  result
}

#let extract(body) = {
  if type(body) == str { body }
  else if body.has("text") { body.text }
  else if body.has("children") { ("", ..body.children.map(extract)).join() }
  else if body.has("body") { extract(body.body) }
  else { "" }
}

#let parse-actions(body, actions: (:)) = {
  let lookup = (:)
  for (action, keys) in bindings(actions) {
    for key in keys { lookup.insert(key, commands.at(action)) }
  }
  ("", ..extract(body).clusters().map(key => lookup.at(key, default: ""))).join()
}

#let key-hint(keys, action) = {
  let values = keys.at(action)
  if values.len() == 0 { "—" } else { values.join("/") }
}
