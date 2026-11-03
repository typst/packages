// Up-front shape checks for `preferences`, `labels` and each CV
// section's entry array, so errors name the caller's input rather than
// surfacing mid-render. Checks on individual `cv` fields stay with the
// code that consumes them, as they apply only when the field is set.

#import "dates.typ": _date_format_aliases
#import "qr.typ": _check_qr_code
#import "text.typ": _placeholder_re

// `linkContactInfo` channels. Here rather than in `header.typ`, which
// renders them, to avoid a cycle: `header.typ` imports this module.
#let _contact_channels = ("email", "phone", "location", "url", "profiles")

#let _quote(s) = "\"" + s + "\""

// `"a" or "b"`, `"a", "b", or "c"`.
#let _prose_list(items) = items.join(
  ", ",
  last: if items.len() == 2 { " or " } else { ", or " },
)

// The shared "must be …" panic.
#let _require(name, value, ok, expected) = {
  if not ok { panic(name + " must be " + expected + ", got: " + repr(value)) }
}

#let _check_unknown_keys(candidates, allowed, what) = {
  let unknown = candidates.filter(k => k not in allowed)
  if unknown.len() > 0 {
    panic(
      "Unknown "
        + what
        + " key(s): "
        + unknown.map(_quote).join(", ")
        + ". Supported: "
        + allowed.map(_quote).join(", "),
    )
  }
}

// Unknown keys panic rather than being silently absorbed. With
// `nested: true`, a dictionary default (a label table such as
// `publicationTypes`) merges key by key, so a partial override keeps
// the rest.
#let _strict_merge(defaults, overrides, name, nested: false) = {
  if type(overrides) != dictionary {
    panic(name + " must be a dictionary, got: " + repr(overrides))
  }
  _check_unknown_keys(overrides.keys(), defaults.keys(), name)
  let merge-key(key, value) = {
    let default = defaults.at(key)
    if nested and type(default) == dictionary {
      _require(
        name + "." + key,
        value,
        type(value) == dictionary,
        "a dictionary",
      )
      default + value
    } else { value }
  }
  defaults + overrides.pairs().map(((k, v)) => (k, merge-key(k, v))).to-dict()
}

#let _check_type(name, value, allowed, expected) = _require(
  name,
  value,
  type(value) in allowed,
  expected,
)

#let _check_bool(name, value) = _check_type(name, value, (bool,), "a bool")

#let _check_enum(name, value, allowed) = _require(
  name,
  value,
  value in allowed,
  _prose_list(allowed.map(_quote)),
)

// Every spacing token multiplies `bodySize`, so it must be an absolute
// length: `1em` would resolve against itself, and a bare number reaches
// `set text(...)` as a stray positional.
#let _is_body_size(v) = type(v) == length and v.em == 0 and v.abs > 0pt

#let _is_margin_side(v) = type(v) in (length, ratio, relative) or v == auto
#let _is_margin(v) = if type(v) == dictionary {
  v.values().all(_is_margin_side)
} else { _is_margin_side(v) }

// A family name, or a fallback list of names / `(name, covers)` dicts.
#let _is_font_list(v) = (
  type(v) == array and v.len() > 0 and v.all(f => type(f) in (str, dictionary))
)
#let _is_font(v) = type(v) == str or _is_font_list(v)

// `section-keys` is passed in, not imported: `layout.typ` imports this
// module. `groupCertificates` is ignored, so it isn't checked.
#let _validate_preferences(preferences, section-keys) = {
  // Only a colour supports `lighten` / `darken`; a palette name string
  // is the common slip.
  _check_type(
    "accent",
    preferences.accent,
    (color,),
    "a colour (e.g. palettes.navy or rgb(\"#1A3A6C\"))",
  )
  _require(
    "bodySize",
    preferences.bodySize,
    _is_body_size(preferences.bodySize),
    "a positive absolute length (e.g. 10pt)",
  )
  _check_type(
    "imageSize",
    preferences.imageSize,
    (length, ratio, relative),
    "a length (e.g. 6em)",
  )
  _check_type("paper", preferences.paper, (str,), "a paper name (e.g. \"a4\")")
  _require(
    "margin",
    preferences.margin,
    _is_margin(preferences.margin),
    "a length, `auto`, or a dict of them (e.g. (x: 1cm, y: 1.5cm))",
  )
  _require(
    "font",
    preferences.font,
    _is_font(preferences.font),
    "a font family name or a non-empty array of them",
  )
  let column-ratio = preferences.columnRatio
  if (
    type(column-ratio) not in (int, float)
      or column-ratio <= 0
      or column-ratio > 1
  ) {
    panic("columnRatio must be a number in (0, 1], got: " + repr(column-ratio))
  }
  let mp = preferences.mapsProvider
  if mp != none {
    if type(mp) != str {
      panic(
        "mapsProvider must be a URL template string (containing `{q}`) or `none`, got: "
          + repr(mp),
      )
    }
    if "{q}" not in mp {
      panic(
        "mapsProvider URL template must contain the `{q}` placeholder, got: "
          + repr(mp),
      )
    }
  }
  _check_enum("imagePosition", preferences.imagePosition, (
    "left",
    "right",
    "center",
  ))
  // Checked even when unused, so a typo surfaces before it matters.
  _check_enum("imageStackOrder", preferences.imageStackOrder, (
    "above",
    "below",
  ))
  _check_enum("headerTextAlign", preferences.headerTextAlign, (
    "left",
    "right",
    "center",
  ))
  let link-contact-info = preferences.linkContactInfo
  if type(link-contact-info) == dictionary {
    _check_unknown_keys(
      link-contact-info.keys(),
      _contact_channels,
      "linkContactInfo",
    )
    for (channel, v) in link-contact-info {
      _check_bool("linkContactInfo." + channel, v)
    }
  } else if type(link-contact-info) != bool {
    panic(
      "linkContactInfo must be a bool or a dict, got: "
        + repr(link-contact-info),
    )
  }
  _check_bool("uppercaseName", preferences.uppercaseName)
  _check_bool("showPronouns", preferences.showPronouns)
  _check_bool("lastModifiedFooter", preferences.lastModifiedFooter)
  _check_bool("footerVersion", preferences.footerVersion)
  _check_bool(
    "referencesAvailableOnRequest",
    preferences.referencesAvailableOnRequest,
  )
  let max-rating = preferences.maxRating
  if type(max-rating) != int or max-rating < 1 {
    panic("maxRating must be a positive integer, got: " + repr(max-rating))
  }
  let page-footer = preferences.pageFooter
  let footer-ok = (
    page-footer == none or page-footer == "auto" or type(page-footer) == content
  )
  if not footer-ok {
    panic(
      "pageFooter must be `none`, the string \"auto\", or a content value, got: "
        + repr(page-footer),
    )
  }
  let df = preferences.dateFormat
  if type(df) == str {
    // Bracketed templates are left to `_apply_date_template`.
    if "[" not in df and df != "iso" and df not in _date_format_aliases {
      panic(
        "dateFormat must be \"long\", \"short\", \"iso\", a bracketed template "
          + "(e.g. \"[day]/[month]/[year]\"), or a closure; got: "
          + repr(df),
      )
    }
  } else if type(df) != function {
    panic(
      "dateFormat must be a string (named formatter or bracketed template) "
        + "or a closure, got: "
        + repr(df),
    )
  }
  _check_qr_code(preferences.qrCode)
  _check_unknown_keys(
    preferences.leftColumnSections,
    section-keys,
    "leftColumnSections",
  )
  _check_unknown_keys(
    preferences.rightColumnSections,
    section-keys,
    "rightColumnSections",
  )
}

// A `{key}` template label. A missing or misspelt (`{totl}`)
// placeholder would otherwise render literally — for the title,
// silently into PDF metadata.
#let _validate_template_label(labels, key, required, optional) = {
  let template = labels.at(key)
  if type(template) != str {
    panic("labels." + key + " must be a string, got: " + repr(template))
  }
  let allowed = required + optional
  let found = template.matches(_placeholder_re).map(m => m.captures.first())
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

// Typst accepts any case; requiring lowercase keeps label files
// canonical and catches a language *name* ("Irish") up front.
#let _lang_re = regex("^[a-z]{2,3}$")

// A dict where a list belongs fails here, not deep in a renderer.
// Returns `entries`.
#let _check_section_entries(key, entries, item-types) = {
  _check_type(key, entries, (array,), "an array")
  let bad = entries.find(e => type(e) not in item-types)
  _require(
    key + " entries",
    bad,
    bad == none,
    _prose_list(item-types.map(repr)),
  )
  entries
}

#let _validate_labels(labels) = {
  let lang = labels.lang
  if type(lang) != str or lang.match(_lang_re) == none {
    panic(
      "labels.lang must be a lowercase ISO 639 code (2–3 letters, e.g. \"de\"), got: "
        + repr(lang),
    )
  }
  _validate_template_label(labels, "pageNumber", ("current",), ("total",))
  _validate_template_label(labels, "documentTitle", ("name",), ())
  let months = labels.months
  if (
    type(months) != array
      or months.len() != 12
      or months.any(m => type(m) != str)
  ) {
    panic(
      "labels.months must be an array of 12 strings, got: " + repr(months),
    )
  }
}
