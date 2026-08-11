#import "state.typ": current-lang-stack, default-lang, is-strict-mode-enabled, stored-translations

#let get-translations = namespace => {
  let translations-in-namespace = stored-translations.get().at(namespace)
  let lang = current-lang-stack.get().first(default: default-lang.get().at(namespace))

  assert(
    translations-in-namespace.keys().contains(lang),
    message: "Language definition for '" + lang + "' does not exist.",
  )
  translations-in-namespace.at(lang)
}

#let resolve-key = key => key.split(".")

#let get-translation = (translations, key) => {
  let key-parts = resolve-key(key)

  let latest-elem = translations

  for (i, key-part) in key-parts.enumerate() {
    latest-elem = latest-elem.at(key-part, default: none)

    assert(
      i < key-parts.len() or type(latest-elem) == dictionary,
      message: "Requested element '"
        + key-part
        + "' was not accessible, as its type was not a dictionary but '"
        + str(type(latest-elem))
        + "'.",
    )
    if latest-elem == none {
      assert(
        not is-strict-mode-enabled.get(),
        message: "Translation '" + key + "' could not be found.",
      )

      return [#text(fill: red, weight: "bold")[??? #key ???]]
    }
  }

  latest-elem
}

#let trk = (
  key,
  ..args,
  namespace: "default",
) => {
  let translations = get-translations(namespace)

  assert(key != none, message: "Cannot translate a key of 'none'.")

  let result = get-translation(translations, key)

  if type(result) == function and args.pos().len() > 0 {
    result(..args)
  } else {
    result
  }
}

#let tr = (
  ..args,
  namespace: "default",
) => {
  let translations = get-translations(namespace)

  let key = args.pos().first(default: none)

  if key == none {
    assert(args.pos().len() == 0, message: "Cannot translate a key of 'none' with arguments.")

    return translations
  }

  return trk(key, ..args.pos().slice(1))
}
