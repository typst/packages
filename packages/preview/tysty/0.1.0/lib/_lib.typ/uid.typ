// Static lookup is pure and can be used during module initialization.
#import "uid.pure.typ": namespaces, _uid_compute

// Full input keys make changed schemas fall back to computation.
#let _uid_cache = json("uid.builtin.json")

#let uid(namespace, name) = {
  if type(namespace) == str and type(name) == str {
    let normalized = lower(namespace)
    let hit = _uid_cache.find(entry => entry.at(0) == normalized and entry.at(1) == name)
    if hit != none { return hit.at(2) }
  }
  _uid_compute(namespace, name)
}

// Call inside context. Insert result.update into the document so subsequent
// locations can see the cached value; result.value is an ordinary UID string.
// No .final() read: cache entries only flow forward through the document.
#let uid-cached(namespace, name) = {
  // Import lazily: state and record use the static uid wrapper above.
  import "state.typ": _mkstate
  let _uid_context_cache = _mkstate("tysty.uid.context-cache.v1", (:))
  let key = repr((
    if type(namespace) == str { lower(namespace) }
    else if type(namespace) == bytes { array(namespace) }
    else { namespace },
    if type(name) == str or type(name) == bytes { array(bytes(name)) }
    else { name },
  ))
  let cache = (_uid_context_cache.get)()
  if key in cache {
    return (value: cache.at(key), update: [])
  }
  let value = uid(namespace, name)
  let update = (_uid_context_cache.update)(entries => {
    entries.insert(key, value)
    entries
  })
  (value: value, update: update)
}

// Callback form automatically inserts the state update. The callback receives
// the UID string and returns document content.
#let with-uid(namespace, name, body) = context {
  let cached = uid-cached(namespace, name)
  cached.update
  body(cached.value)
}
