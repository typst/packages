/// Interprets a single element as a singleton.
/// -> array(T)
#let coerce-to-array(
  /// Element or array
  /// -> T | array(T)
  t,
) = {
  if type(t) == array {
    t
  } else {
    (t,)
  }
}

/// Applies some of the standard styling options that affect layout and therefore
/// are stored separately in our internal representation.
/// -> content
#let apply-styles(
  /// Text to style.
  /// -> content
  data,
  /// Applies ```typ #set text(size: ..)```
  /// -> length
  size: auto,
  /// Applies ```typ #set text(lang: ..)```.
  /// -> string
  lang: auto,
  /// Applies ```typ #set text(hyphenate: ..)```.
  /// -> bool
  hyphenate: auto,
  /// Applies ```typ #set par(leading: ..)```.
  /// -> length
  leading: auto,
) = {
  if size != auto {
    data = text(size: size, data)
  }
  if lang != auto {
    data = text(lang: lang, data)
  }
  if hyphenate != auto {
    data = text(hyphenate: hyphenate, data)
  }
  if leading != auto {
    data = [#set par(leading: leading); #data]
  }
  data
}
