// Up-front checks for `preferences` and `labels`, so errors name the
// caller's input rather than surfacing mid-render. The CV's are in
// `cv-checks.typ`.

#import "../design/icon-set.typ": _fa-glyphs, _icon-glyphs
#import "../design/theme.typ": _default-theme, _tokens
#import "../design/theme-checks.typ": _check-tokens, _font-rule, _is-font
#import "../util/checks.typ": (
  _bool-rule, _check, _check-keys, _check-rules, _check-type,
  _check-unknown-keys, _enum-rule, _list-rule, _positive-int-rule, _type-rule,
)
#import "canonical.typ": _preference-tables
#import "sections.typ": _section-specs
#import "../util/dates.typ": _check-date-template, _date-format-aliases
#import "../util/values.typ": _placeholder-re, _present-str

// `link-contact-info` channels: checked here, resolved per channel in
// `data/contacts.typ`.
#let _contact-channels = ("email", "phone", "location", "url", "profiles")

// Unknown keys panic rather than being silently absorbed. The keys
// named in `tables` (`labels.publication-types`) hold dictionaries that
// merge entry by entry, so a partial override keeps the rest; any
// other key is replaced whole, dictionary or not (`margin`).
#let _strict-merge(defaults, overrides, name, tables: ()) = {
  _check-keys(name, overrides, defaults.keys())
  let merge-key(key, value) = {
    let default = defaults.at(key)
    if key in tables {
      _check-type(name + "." + key, value, (dictionary,), "a dictionary")
      default + value
    } else { value }
  }
  defaults + overrides.pairs().map(((k, v)) => (k, merge-key(k, v))).to-dict()
}

// Every spacing token multiplies `body-size`, so it must be an absolute
// length: `1em` would resolve against itself, and a bare number reaches
// `set text(...)` as a stray positional.
#let _is-body-size(v) = type(v) == length and v.em == 0 and v.abs > 0pt

#let _is-margin-side(v) = type(v) in (length, ratio, relative) or v == auto
#let _is-margin(v) = if type(v) == dictionary {
  v.values().all(_is-margin-side)
} else { _is-margin-side(v) }

// A named formatter, a bracketed template (its tokens are left to
// `_apply-date-template`), or a closure.
#let _is-date-format(v) = (
  type(v) == function
    or (
      type(v) == str and ("[" in v or v == "iso" or v in _date-format-aliases)
    )
)

// The icon tables' value rules: icon-set keys, except `profile-icons`,
// which takes raw FontAwesome glyph names, as it draws networks the
// icon set doesn't ship. Too many to list, so its message points at
// the catalogue instead. A table that isn't a dictionary is left to
// `_strict-merge` to name.
#let _icon-table(rule) = (name, table) => if type(table) == dictionary {
  for (code, icon-name) in table {
    _check("preferences." + name + "." + code, icon-name, rule)
  }
}
#let _icon-names = _icon-table(_enum-rule(_icon-glyphs.keys()))

// A column's section keys; a bare string (`"work"`) is the common
// slip for `("work",)`.
#let _column-sections(name, v) = {
  _check(name, v, _list-rule(
    (str,),
    "an array of section keys (e.g. (\"work\",))",
  ))
  _check-unknown-keys(v, _section-specs.keys(), name)
}

// Every preference's check, in `_default-preferences`' order
// (`tests/unit/validation.typ` holds the two to the same keys): a rule
// (`_check`'s `(ok, expected)`), a checker `(name, value) => ..` that
// panics on a bad value, or `none` for the ignored ones.
#let _preference-rules = (
  // The theme's `font` token, unless `auto` (the theme's).
  font: (v => v == auto or _is-font(v), _font-rule.last()),
  body-size: (_is-body-size, "a positive absolute length (e.g. 10pt)"),
  // Internal: the theme's colour roles, from the deprecated `accent`.
  colours: (name, v) => _check-tokens(
    v,
    _tokens.colours,
    "",
    path: (name,),
  ),
  // Checked before their merge (`_merge-options`), so the deprecated
  // `labels.publication-icons` folded in there isn't.
  publication-icons: _icon-names,
  project-icons: _icon-names,
  profile-icons: _icon-table((
    v => type(v) == str and v in _fa-glyphs,
    "a FontAwesome icon name (https://fontawesome.com/search, e.g. \"kaggle\")",
  )),
  uppercase-name: _bool-rule,
  header-text-align: _enum-rule((left, center, right)),
  photo-size: _type-rule((length, ratio, relative), "a length (e.g. 6em)"),
  photo-shape: _enum-rule(_default-theme.header.photo-radius.keys()),
  // The side of the header text the photo takes.
  photo-position: _enum-rule((left, right, top, bottom)),
  // Deprecated (#239): read into `photo-position` with `"center"`, but
  // checked even when unused, so a typo surfaces before it matters.
  image-stack-order: _enum-rule(("above", "below")),
  // A typo (`qr-code: true`) fails here, not inside `qrcode(...)`.
  qr-code: (
    v => v == none or v == auto or _present-str(v),
    "`none`, `auto`, or a non-empty URL string",
  ),
  paper: _type-rule((str,), "a paper name (e.g. \"a4\")"),
  margin: (
    _is-margin,
    "a length, `auto`, or a dict of them (e.g. (x: 1cm, y: 1.5cm))",
  ),
  column-ratio: (
    v => type(v) in (int, float) and v > 0 and v <= 1,
    "a number in (0, 1]",
  ),
  left-column-sections: _column-sections,
  right-column-sections: _column-sections,
  page-footer: (
    v => v == none or v == auto or type(v) == content,
    "`none`, `auto`, or a content value",
  ),
  last-modified-footer: _bool-rule,
  footer-version: _bool-rule,
  date-format: (name, v) => {
    _check(name, v, (
      _is-date-format,
      "\"long\", \"short\", \"iso\", a bracketed template "
        + "(e.g. \"[day]/[month]/[year]\"), or a closure",
    ))
    if type(v) == str { _check-date-template(v, name) }
  },
  link-contact-info: (name, v) => {
    _check-type(name, v, (bool, dictionary), "a bool or a dict")
    if type(v) == dictionary {
      _check-unknown-keys(v.keys(), _contact-channels, name)
      for (channel, x) in v { _check(name + "." + channel, x, _bool-rule) }
    }
  },
  print-full-urls: _bool-rule,
  maps-provider: (
    v => v == none or (type(v) == str and "{q}" in v),
    "`none` or a URL template string containing `{q}`",
  ),
  max-rating: _positive-int-rule,
  skill-level-display: (
    v => v == auto or v in ("rating", "text"),
    "`auto`, \"rating\" or \"text\"",
  ),
  owner-names: _list-rule((str,), "an array of strings"),
  // Deprecated and ignored (#239).
  group-certificates: none,
  show-pronouns: none,
  references-available-on-request: _bool-rule,
)

// `value` checked as preference `key`, named `name` (`auto`: `key`)
// in a message: the public helpers that take a preference's value
// check it here too.
#let _check-preference(key, value, name: auto) = {
  let rule = _preference-rules.at(key)
  let name = if name == auto { key } else { name }
  if type(rule) == function { rule(name, value) } else if rule != none {
    _check(name, value, rule)
  }
}

// `prefs`, but for the icon tables, checked before their merge
// (`_preference-rules`).
#let _validate-preferences(prefs) = for (key, v) in prefs {
  if key not in _preference-tables { _check-preference(key, v) }
}

// A `{key}` template label. A missing or misspelt (`{totl}`)
// placeholder would otherwise render literally — for the title,
// silently into PDF metadata.
#let _validate-template-label(labels, key, required, optional) = {
  let template = labels.at(key)
  _check-type("labels." + key, template, (str,), "a string")
  let allowed = required + optional
  let found = template.matches(_placeholder-re).map(m => m.captures.first())
  let unknown = found.filter(p => p not in allowed)
  if unknown.len() > 0 {
    panic(
      "labels."
        + key
        + " has unknown placeholder(s) "
        + repr(unknown.map(p => "{" + p + "}"))
        + "; allowed: "
        + repr(allowed.map(p => "{" + p + "}"))
        + ". Got: "
        + repr(template),
    )
  }
  let missing = required.filter(p => p not in found)
  if missing.len() > 0 {
    panic(
      "labels."
        + key
        + " must contain "
        + missing.map(p => "{" + p + "}").join(", ")
        + ". Got: "
        + repr(template),
    )
  }
}

#let _lang-re = regex("^[a-z]{2,3}$")

#let _label-rules = (
  // Deprecated (#239), and merged into the preference's icons by
  // `_canonical-preferences`, which needs a dictionary.
  publication-icons: _type-rule((dictionary,), "a dictionary"),
  // Typst accepts any case; requiring lowercase keeps label files
  // canonical and catches a language *name* ("Irish") up front.
  lang: (
    v => type(v) == str and v.match(_lang-re) != none,
    "a lowercase ISO 639 code (2–3 letters, e.g. \"de\")",
  ),
  months: (
    v => type(v) == array and v.len() == 12 and v.all(m => type(m) == str),
    "an array of 12 strings",
  ),
)

#let _validate-labels(labels) = {
  _check-rules(labels, _label-rules, prefix: "labels.")
  _validate-template-label(labels, "page-number", ("current",), ("total",))
  _validate-template-label(labels, "document-title", ("name",), ())
}
