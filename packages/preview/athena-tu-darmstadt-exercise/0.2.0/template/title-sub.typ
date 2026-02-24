/// Provides functions to style the subline in the title card of the template.
/// Currently the following two functions exist:
/// - exercise: Behaves pretty much like in the LaTeX template
/// - submission: Behaves out of the box more like Rubos LaTeX template but also has
///   customization options and allows more info-fields.

#import "common/format.typ": format-date, text-roboto

/// To be used as `title-sub`
/// 
/// The default version of the title subline.
/// 
/// *Possible `info` items:*
/// - `term`: The current term (types: #str)
/// - `date`: A date related to the exercise (types: #str, #datetime)
/// - `sheet`: The number of this sheet/exercise (types: #int)
/// 
/// - additional (content,none): Additional content to be displayed after the previous options
/// -> function
#let exercise(additional: none) = (info, dict) => {
  if "term" in info {
    info.term
    linebreak()
  }
  if "date" in info {
    format-date(info.date, dict.locale)
    linebreak()
  }
  if "sheet" in info {
    [#dict.sheet #info.sheet]
    linebreak()
  }
  if additional != none {
    additional
  }
}

#let submission-item-style(key, value) = if type(value) == array {
  [
    #text-roboto(strong(key)): \
    #value.join(linebreak())
  ]
} else {
  [#text-roboto(strong(key)): #value]
}

/// To be used as `title-sub`
/// 
/// Allows more customization about how to display information about this document.
/// 
/// *Possible `info` items:*
/// - `term`: The current term (types: #str)
/// - `date`: The due date of the submission (types: #str, #datetime)
/// - `sheet`: The number of this sheet/exercise (types: #int)
/// - `group`: A identifier for the lecture group (types: #int, #str)
/// - `tutor`: The name of the tutor of the lecture group (types: #str)
/// - `lecturer`: The name of the lecturer (types: #str)
/// 
/// If you want to add more options you have two options:
/// 
/// 1. Pass the option as key-value pair:
/// ```
/// submission(
///   left: ("sheet", ("Magic", "1234"))
/// )
/// ```
/// 
/// 2. Pass option via `info` and add definition to `dict-addon`:
/// ```
/// info: (
///   magic: 1234
/// )
/// ...
/// submission(
///   left: ("magic"),
///   dict-addon: (magic: "Magic")
/// )
/// ```
/// Additionally the names for fields can be overwritten by putting a new definition in 
/// `dict-addon`
/// 
/// If you pass something other than a string to left or right the item will simply be
/// displayed as is. Thus you can also add manual content on either side.
/// 
/// How the information is displayed can further be styled using `item-style`. By default
/// this has the following format:
/// *key*: value
///
/// - left (array): The options to be displayed on the left side
/// - right (array): The options to be displayed on the right side
/// - dict-addon (dictionary): Additional definitions of items to be used
/// - item-style (function): A function (str,any)=>content that takes in a name, it's value 
///   and yields content correspondingly
/// -> function
#let submission(
  left: ("term", "date"),
  right: ("sheet", "group", "tutor", "lecturer"),
  dict-addon: (:),
  item-style: submission-item-style
) = {
  assert.eq(type(item-style), function,
    message: "Expected item-style of submission(...) to be a function")

  let resolve-item(i, info, dict) = if type(i) == array {
    assert.eq(i.len(), 2,
      message: "Custom items in submission should have form (key, value). Got: '" + repr(i) + "' Or did you mean to just write '" + repr(i.at(0)) + "'?")
    let (k,v) = i
    return item-style(k,v)
  } else if type(i) != str {
    return i
  } else if i in info {
    assert(i in dict,
      message: "Unknown item '" + i + "' in submission, please use manual syntax: (\"Display Name\", \"Value\")")
    // Format date ignores formatting if type isn't date thus this works
    return item-style(dict.at(i), format-date(info.at(i), dict.locale))
  } else {
    return none
  }

  let resolve-items(arr, info, dict) = if type(arr) != array {
    (resolve-item(arr,info,dict),)
  } else {
    arr.map(i => resolve-item(i, info, dict))
  }

  let filter-none(arr) = arr.filter(x => x != none)

  return (info, dict) => {
    let full-dict = dict + dict-addon
    let left-items = resolve-items(left, info, full-dict)
    let right-items = resolve-items(right, info, full-dict)
    grid(
      columns: (1fr,1fr),
      align: (alignment.left, alignment.right),

      filter-none(left-items).join(linebreak()),
      filter-none(right-items).join(linebreak())
    )
  }
}