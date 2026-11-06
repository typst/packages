#import "../util/identifier.typ" as id

#import "../util/level-state.typ" as lst


/// Default dictionary value for tracking counters and levels.
#let default-counter-dic-value = (level: 0, counter: (), resume: (:))

/// State variable to track counters and levels (Uses absolute-level).
#let item-counter-dic = state("_item-counter-dic", default-counter-dic-value) // use absolute-level

/// State variable to track if resuming is active (auto-case).
#let resume-list = state("_is-resuming", false) 

/// State variable to track if sublist resuming is active (auto-case: for sublist (auto-resume-enum)).
#let resume-sublist = state("_is-resuming-sublist", false) 

/// State variable to track the current resume label (label-case).
#let resume-label = state("_resume-label", none) 

/// State variable to track the enum label to resume.
#let resume-label-list = state("_is-resuming-label", none) // label the enum to resume

/// Internal function to update the counter in a dictionary.
///
/// - v (any): Value or function to update the counter.
/// - dic (dictionary): Dictionary to modify.
/// -> dictionary
#let _update-counter(v) = dic => {
  let cur-level = dic.level - 1
  if cur-level >= dic.counter.len() {
    let value = if type(v) == function { v(0) } else { v }
    dic.counter.push(value)
  } else {
    let value = if type(v) == function { v(dic.counter.at(cur-level)) } else { v }
    dic.counter.at(cur-level) = value
  }
  return dic
}

/// Internal function to update the counter from a resume point.
///
/// - key (string): Key to lookup in the resume dictionary.
/// - dic (dictionary): Dictionary to modify.
/// -> dictionary
#let _update-resume(key) = dic => {
  let cur-level = dic.level - 1
  let value = dic.resume.at(key, default: none) // ???
  assert(
    value != none,
    message: "Cannot resume the enum with key `" + key + "`; possibly after that enum you reset the auto-resuming.",
  )
  if cur-level >= dic.counter.len() {
    dic.counter.push(value)
  } else {
    dic.counter.at(cur-level) = value
  }
  return dic
}

/// Internal function to update the nesting level in a dictionary.
///
/// - func (function): Function to update the level.
/// - dic (dictionary): Dictionary to modify.
/// -> dictionary
#let _update-level(func) = dic => {
  dic.level = func(dic.level)
  return dic
}

/// Resets all resuming states to their default values.
#let restart_resuming() = {
  resume-list.update(false)
  resume-label-list.update(none)
  resume-label.update(none)
}

/// Initializes the resuming counter based on the start value and auto-resuming flag.
///
/// - start (any): Starting value for the counter.
/// - auto-resuming (bool): Whether auto-resuming is enabled.
#let init_resuming-number(start, auto-resuming) = {
  if start != auto {
    item-counter-dic.update(_update-counter(start - 1))
  } else {
    let key-label = resume-label-list.get()
    if key-label != none {
      item-counter-dic.update(_update-resume(str(key-label)))
    } else {
      if auto-resuming != true {
        item-counter-dic.update(_update-counter(0))
      }
    }
  }
}

/// Initializes the resuming counter to zero.
#let init_resuming-zero() = {
  item-counter-dic.update(dic => {
    let cur-level = dic.level - 1
    if cur-level >= dic.counter.len() {
      dic.counter.push(0)
    }
    return dic
  })
}

/// Updates the resuming counter using a function.
///
/// - update-f (function): Function to update the counter.
#let update_resuming-number(update-f) = {
  item-counter-dic.update(_update-counter(update-f))
}

/// Updates the nesting level using a function.
///
/// - update-f (function): Function to update the level.
#let update_resume-level(update-f) = {
  item-counter-dic.update(_update-level(update-f))
}

/// Resets the resume dictionary to its default value if the level is not zero.
#let reset_resume-dic() = {
  item-counter-dic.update(dic => {
    if dic.level != 0 {
      default-counter-dic-value
    } else {
      dic
    }
  })
}

/// Stores the current counter value in the resume dictionary under the given key.
///
/// - key-label (any): Key to store the counter value.
#let store_resume(key-label) = {
  item-counter-dic.update(dic => {
    let value = dic.counter.at(dic.level - 1, default: 0)
    dic.resume.insert(str(key-label), value)
    return dic
  })
}

/// Temporarily holds the current state of the resume dictionary.
///
/// Throws an error if called while already holding a state.
#let hold_resume-dic() = {
  item-counter-dic.update(dic => {
    if dic.at("copy", default: none) != none {
      panic("This function cannot be nested.")
    } else {
      dic.insert("copy", (level: dic.level, counter: dic.counter))
      dic.level = default-counter-dic-value.level
      dic.counter = default-counter-dic-value.counter
    }
    return dic
  })
}
/// Recovers the previously held state of the resume dictionary.
#let recover_resume-dic() = {
  item-counter-dic.update(dic => {
    let copy = dic.remove("copy", default: none)
    if copy != none {
      dic.level = copy.level
      dic.counter = copy.counter
    }
    return dic
  })
}

