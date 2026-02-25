#let merge-settings(settings, default) = {
  let result = default

  for (key, value) in settings {
    if type(value) == dictionary {
      result.insert(key, merge-settings(value, default.at(key, default: (:))))
    } else {
      result.insert(key, value)
    }
  }

  result
}
