/// Merges a user dictionary into a default dictionary.
/// Only keys present in the default dictionary are updated.
#let merge-dictionary(default-dict, user-dict) = {
  if user-dict == none {
    return default-dict
  }
  let new-dict = default-dict
  for (key, value) in user-dict {
    if key in default-dict.keys() {
      new-dict.insert(key, value)
    }
  }
  return new-dict
}

/// Returns the current date formatted string based on locale.
/// Supported locales: "EN", "RU".
#let today(locale) = {
  assert(locale in ("RU", "EN"), message: "Locale must be 'RU' or 'EN'")

  let now = datetime.today()
  let month-idx = now.month() - 1
  
  let months = if locale == "RU" {
    ("Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь")
  } else {
    ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
  }

  [#months.at(month-idx) #now.year()]
}
