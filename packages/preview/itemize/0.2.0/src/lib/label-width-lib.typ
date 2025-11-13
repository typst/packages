

/// State variable to track the maximum width of labels.
///
/// - level (int): Current nesting level.
/// - width (array): Array of widths for each level.
/// - unlock (bool): Whether the state is unlocked for modification.
#let max-width-label = state("_max-width-label", (level: 0, width: (), unlock: false))

/// Global state variable to track the maximum width of labels across all levels.
///
/// - level (int): Current nesting level.
/// - width (array): Array of widths for each level.
#let max-width-label-global = state("_max-width-label-global", (level: 0, width: ()))

/// Default width values for enum and list labels.
///
/// - enum (length): Default width for enum labels.
/// - list (length): Default width for list labels.
#let default-width = (enum: 0em, list: 0em)


/// Internal function to update the nesting level in a dictionary.
///
/// - func (function): Function to update the level.
/// - dic (dictionary): Dictionary to modify.
/// -> dictionary
#let _update-level(func) = dic => {
  dic.level = func(dic.level)
  return dic
}

/// Internal function to update the label width in a dictionary.
///
/// - max-width (length): New maximum width to set.
/// - obj (string): Type of label ("enum" or "list").
/// - dic (dictionary): Dictionary to modify.
/// -> dictionary
#let _update-label-width(max-width, obj) = dic => {
  let cur-level = dic.level - 1
  let len = dic.width.len()
  for i in range(len, dic.level) {
    dic.width.push(default-width)
  }
  let width = dic.width.at(cur-level)
  if max-width > width.at(obj) {
    dic.width.at(cur-level).at(obj) = max-width
  }
  return dic
}


/*Local*/


/// Updates the nesting level of labels in the local state.
///
/// - update-f (function): Function to update the level.
#let update-auto_label-level(update-f) = {
  max-width-label.update(_update-level(update-f))
}


/// Updates the label width in the local state when global auto-width is disabled.
///
/// - max-width (length): New maximum width to set.
/// - obj (string): Type of label ("enum" or "list").
#let update-auto_width-label-dic(max-width, obj) = {
  max-width-label.update(_update-label-width(max-width, obj))
}


/// Locks the local state for modification and clears the width array if it is not empty.
#let hold_width-label-dic() = {
  max-width-label.update(
    dic => {
      if dic.unlock == false {
        dic.unlock = true
        if dic.width != () {
          dic.width = ()
        }
      }
      // dic.insert("copy", dic.width)
      return dic
    },
  )
}

/// Unlocks the local state and resets the width array.
#let recover_width-label-dic() = {
  max-width-label.update(
    dic => {
      // let width = dic.remove("copy")
      // dic.width = width
      dic.unlock = false
      dic.width = ()
      return dic
    },
  )
}


/*Global*/

/// Updates the nesting level of labels in the global state.
///
/// - update-f (function): Function to update the level.
#let update-global_label-level(update-f) = {
  max-width-label-global.update(_update-level(update-f))
}

/// Updates the label width in the global state.
///
/// - max-width (length): New maximum width to set.
/// - obj (string): Type of label ("enum" or "list").
#let update-global_width-label-dic(max-width, obj) = {
  max-width-label-global.update(_update-label-width(max-width, obj))
}


