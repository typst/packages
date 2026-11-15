#import "../util/version.typ": package-version

/// State variable for automatic ID management
///
/// Tracks counters and auto-generated IDs for nested list levels.
/// - counter (array): Counter values for each nesting level
/// - auto-id (array): Stack of currently active auto-generated IDs
#let auto-id-state = state("__cdl-auto_id_state__" + package-version, (counter: (), auto-id: ()))

/// Records a new auto-generated ID for the current nesting level
#let auto-record-id = dic => {
  let id
  let level = dic.auto-id.len()
  if level >= dic.counter.len() {
    dic.counter.push(0)
    id = 0
  } else {
    id = dic.counter.at(level) + 1
    dic.counter.at(level) = id
  }
  dic.auto-id.push(id)
  return dic
}

/// Removes the last auto-generated ID from the stack
#let auto-pop-id = dic => {
  _ = dic.auto-id.pop()
  if dic.counter.len() - dic.auto-id.len() >= 2 {
    _ = dic.counter.pop()
  }
  return dic
}

