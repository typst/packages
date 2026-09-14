#import "../core/styles.typ"

#let parse-schema(
  schema,
  expand-schemas: false,
  expand-choices: 2,
  child-schemas: none,
  // Passing in dtype and value to avoid circular imports
  _dtype: none,
  _value: none,
) = {
  let el = schema

  if type(child-schemas) == str {
    return _dtype(child-schemas)
  }

  // TODO: implement expand-schemas and child-schemas options
  let options = (
    expand-schemas: expand-schemas,
    expand-choices: expand-choices,
    _dtype: _dtype,
    _value: _value,
  )

  // Recursivley handle dictionaries
  if "dictionary-schema" in el {
    if el.dictionary-schema != (:) {
      `(`
      terms(
        hanging-indent: 1.28em,
        indent: .64em,
        ..for (key, el) in el.dictionary-schema {
          (
            terms.item(
              styles.arg(key) + if el.optional {
                ": " + _value(none)
              } else if el.default != none {
                ": " + raw(lang: "typc", repr(el.default))
              },
              parse-schema(
                el,
                child-schemas: if type(child-schemas) == dictionary { child-schemas.at(key, default: none) },
                ..options,
              ),
            ),
          )
        },
      )
      `)`
    } else {
      _dtype(dictionary)
    }
  } else if "descendents-schema" in el {
    _dtype(array) + " of " + parse-schema(
      el.descendents-schema,
      child-schemas: if type(child-schemas) == array { child-schemas },
      ..options,
    )
  } else if el.name == "enum" {
    [one of ]
    `(`
    if expand-choices not in (false, 0) {
      if type(expand-choices) == int and el.choices.len() > expand-choices {
        el.choices.slice(0, expand-choices).map(_value).join(", ") + [ #sym.dots ]
      } else {
        el.choices.map(_value).join(", ")
      }
    } else [
      #sym.dots
    ]
    `)`
  } else {
    _dtype(el.name)
  }
}
