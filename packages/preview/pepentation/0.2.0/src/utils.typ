/// Merges a user dictionary into a default dictionary.
///
/// Only keys present in the default dictionary are updated. Keys in `user-dict`
/// that are not in `default-dict` are ignored. If `user-dict` is `none`, the
/// default dictionary is returned unchanged.
///
/// # Parameters
/// - `default-dict` (dictionary): The default dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user-provided dictionary to merge.
///
/// # Returns
/// A new dictionary with user values merged into defaults.
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

/// Returns the current date as a formatted string based on locale.
///
/// The date is formatted as "Month Year" (e.g., "January 2025" or "Январь 2025").
///
/// # Parameters
/// - `locale` (string): The locale code, either `"EN"` or `"RU"`.
///
/// # Returns
/// A formatted string containing the current month and year.
///
/// # Panics
/// Panics if `locale` is not `"EN"` or `"RU"`.
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

/// Merges nested dictionaries, including sub-dictionaries.
///
/// This function handles merging of nested dictionary structures, such as
/// theme dictionaries with a `blocks` sub-dictionary.
///
/// # Parameters
/// - `default-dict` (dictionary): The default dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user-provided dictionary to merge.
///
/// # Returns
/// A new dictionary with user values merged into defaults, including nested dictionaries.
#let merge-nested-dictionary(default-dict, user-dict) = {
  if user-dict == none {
    return default-dict
  }
  let new-dict = default-dict
  for (key, value) in user-dict {
    if key in default-dict.keys() {
      if type(default-dict.at(key)) == dictionary and type(value) == dictionary {
        new-dict.insert(key, merge-nested-dictionary(default-dict.at(key), value))
      } else {
        new-dict.insert(key, value)
      }
    }
  }
  return new-dict
}
