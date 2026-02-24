/// Returns @cmd:auto-or-default.value or default if value equals #typ.v.auto.
///
/// -> any
#let auto-or-default(
  /// The value to check.
  ///
  /// -> any | auto
  value,

  /// The default value as stand in for #typ.v.auto.
  ///
  /// -> any
  default
) = if value == auto { default } else { value }

/// Returns @cmd:none-or-default.value or default if value equals #typ.v.none.
///
/// -> any
#let none-or-default(
  /// The value to check.
  ///
  /// -> any | auto
  value,

  /// The default value as stand in for #typ.v.none.
  ///
  /// -> any
  default
) = if value == none { default } else { value }

/// Separates all overridden arguments from the rest.
///
/// Returns a pair of dictionaries, the rest arguments and the new overrides.
///
/// -> array
#let get-overrides(
  /// The named arguments to separate.
  ///
  /// -> dictionary
  named-args,

  /// A dictionary of source names to separate out and their new names in the
  /// resulting override dictionary.
  ///
  /// -> dictionary
  override-map,
) = {
  let overrides = (:)

  for (from, to) in override-map {
    if from in named-args {
      overrides.insert(to, named-args.remove(from))
    }
  }

  (named-args, overrides)
}

/// Applies a rule multiple times for each value within the given array.
///
/// -> function
#let apply-for-all(
  /// The values to pass to each individual invocation.
  ///
  /// -> array
  values,

  /// The rule to apply, this should be a template function.
  ///
  /// Signature: #lambda(content, ret: content)
  ///
  /// -> function
  rule,
) = outer => {
  show: inner => {
    values.map(rule).fold(inner, (acc, f) => f(acc))
  }

  outer
}

/// Attempts to return all kinds found within figures inside the given content.
///
/// -> array
#let gather-kinds(
  /// Content which contains figures with some unknown kind.
  ///
  /// -> content
  body,
) = {
  if type(body) == content and body.func() == figure {
    if body.at("kind", default: auto) != auto {
      return (figure.kind,)
    }
  } else if body.has("children") {
    return body.children.map(gather-kinds).flatten().dedup()
  }

  (image, raw, table)
}

/// Return the appropriate supplement for the given kind.
#let i18n-supplement(
  /// The kind of a figure as a string.
  ///
  /// -> str
  kind,
) = {
  let map = toml("../assets/i18n.toml")

  if kind not in map.en {
    panic("Unknown kind: `" + kind + "`")
  }

  let lang-map = map.at(text.lang, default: (:))
  let region-map = if text.region != none { lang-map.at(text.region, default: (:)) } else { (:) }
  let term = region-map.at(kind, default: none)

  if term == none {
    term = lang-map.at(kind, default: none)
  }

  if term == none {
    term = map.en.at(kind)
  }

  term
}

/// Attempts to wrap a numbering pattern in a function which provides the same
/// amount of numbers as there are numbering symbols. Numbering functions are
/// passed through.
///
/// Recognizes the following numbering symbols: `1`, `a`, `A`, `i`, `I`, `い`,
/// `イ`, `א`, `가`, `ㄱ`, `*`.
///
/// -> function
#let sparse-numbering(
  /// The numbering pattern/function to wrap.
  ///
  /// -> function | str
  numbering,
) = if type(numbering) == str {
  let symbols = ("1", "a", "A", "i", "I", "い", "イ", "א", "가", "ㄱ", "\\*")
  let c =  numbering.matches(regex(symbols.join("|"))).len()

  if c == 1 {
    // if we have only one symbol we drop the super number
    (_, num) => std.numbering(numbering, num)
  } else {
    (..nums) => std.numbering(numbering, ..nums)
  }
} else {
  numbering
}

/// #property(requires-context: true)
/// Resolves the field of an element within the current context.
///
/// -> any
#let resolve-element-field(
  /// The element function to resolve a field for. This is used as a fallback.
  ///
  /// -> function
  elem,

  /// The instance to use as the primary source for the field.
  ///
  /// -> content
  it,

  /// The name of the field to resolve.
  ///
  /// -> str
  field,
) = {
  if it.has(field) {
    it.at(field)
  } else {
    elem.at(field)
  }
}

