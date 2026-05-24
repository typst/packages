#let _plugin = plugin("glotter.wasm")

#let supported-languages = (
  "af", "als", "am", "an", "ar", "arz", "as", "ast", "av", "az", "azb",
  "ba", "bar", "bcl", "be", "bg", "bh", "bn", "bo", "bpy", "br", "bs",
  "bxr", "ca", "cbk", "ce", "ceb", "ckb", "co", "cs", "cv", "cy", "da",
  "de", "diq", "dsb", "dty", "dv", "el", "eml", "en", "eo", "es", "et",
  "eu", "fa", "fi", "fr", "frr", "fy", "ga", "gd", "gl", "gn", "gom",
  "gu", "gv", "he", "hi", "hif", "hr", "hsb", "ht", "hu", "hy", "ia",
  "id", "ie", "ilo", "io", "is", "it", "ja", "jbo", "jv", "ka", "kk",
  "km", "kn", "ko", "krc", "ku", "kv", "kw", "ky", "la", "lb", "lez",
  "li", "lmo", "lo", "lrc", "lt", "lv", "mai", "mg", "mhr", "min",
  "mk", "ml", "mn", "mr", "mrj", "ms", "mt", "mwl", "my", "myv", "mzn",
  "nah", "nap", "nds", "ne", "new", "nl", "nn", "no", "oc", "or", "os",
  "pa", "pam", "pfl", "pl", "pms", "pnb", "ps", "pt", "qu", "rm", "ro",
  "ru", "rue", "sa", "sah", "sc", "scn", "sco", "sd", "sh", "si", "sk",
  "sl", "so", "sq", "sr", "su", "sv", "sw", "ta", "te", "tg", "th",
  "tk", "tl", "tr", "tt", "tyv", "ug", "uk", "ur", "uz", "vec", "vep",
  "vi", "vls", "vo", "wa", "war", "wuu", "xal", "xmf", "yi", "yo",
  "yue", "zh",
)

#let supported-language-count = supported-languages.len()

#let supported-labels = supported-languages.map(code => "__label__" + code)

#let cjk-languages = ("ja", "zh", "ko")
#let rtl-languages = ("ar", "fa", "he", "ur")
#let latin-script-languages = (
  "af", "az", "ca", "cs", "cy", "da", "de", "en", "eo", "es", "et", "eu",
  "fi", "fr", "ga", "gl", "hr", "hu", "id", "is", "it", "la", "lt", "lv",
  "ms", "mt", "nl", "no", "pl", "pt", "ro", "sk", "sl", "sq", "sv", "sw",
  "tl", "tr", "uz", "vi",
)

#let normalize-label(label) = {
  if label == none {
    "und"
  } else {
    label.replace("__label__", "")
  }
}

#let is-supported-language(language) = {
  supported-languages.contains(normalize-label(language))
}

#let require-supported-language(language) = {
  let code = normalize-label(language)

  assert(
    is-supported-language(code),
    message: "unsupported language code `" + code + "`",
  )

  code
}

#let _dict-has(d, key) = {
  d.keys().contains(key)
}

#let plain-text(value) = {
  if value == none {
    ""
  } else if type(value) == str {
    value
  } else if type(value) == content {
    let fields = value.fields()

    if _dict-has(fields, "text") {
      plain-text(fields.at("text"))
    } else if _dict-has(fields, "body") {
      plain-text(fields.at("body"))
    } else if _dict-has(fields, "children") {
      plain-text(fields.at("children"))
    } else if _dict-has(fields, "child") {
      plain-text(fields.at("child"))
    } else if _dict-has(fields, "content") {
      plain-text(fields.at("content"))
    } else {
      " "
    }
  } else if type(value) == array {
    value.map(plain-text).join("")
  } else if type(value) == dictionary {
    if _dict-has(value, "text") {
      plain-text(value.at("text"))
    } else if _dict-has(value, "body") {
      plain-text(value.at("body"))
    } else if _dict-has(value, "children") {
      plain-text(value.at("children"))
    } else {
      ""
    }
  } else {
    ""
  }
}

#let _empty-info(input, fallback: "und") = {
  (
    lang: fallback,
    detected-lang: "und",
    label: none,
    probability: 0.0,
    predictions: (),
    margin: none,
    ambiguous: true,
    fallback: fallback,
    input: input,
  )
}

#let detect(
  input,
  k: 1,
  threshold: 0.0,
) = {
  let text = plain-text(input).trim()

  if text == "" {
    ()
  } else {
    let raw = _plugin.detect(
      bytes(text),
      bytes(str(k)),
      bytes(str(threshold)),
    )

    json(raw).map(pred => {
      let label = pred.at("label", default: none)
      let detected-lang = pred.at(
        "lang",
        default: normalize-label(label),
      )

      (
        lang: detected-lang,
        label: label,
        probability: pred.at("probability", default: 0.0),
      )
    })
  }
}

#let detect-info(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
  fallback: "und",
) = {
  let text = plain-text(input).trim()

  if text == "" {
    _empty-info(text, fallback: fallback)
  } else {
    let predictions = detect(
      text,
      k: k,
      threshold: threshold,
    )

    if predictions.len() == 0 {
      _empty-info(text, fallback: fallback)
    } else {
      let top = predictions.at(0)
      let second-probability = if predictions.len() >= 2 {
        predictions.at(1).at("probability")
      } else {
        0.0
      }

      let margin = top.at("probability") - second-probability
      let ambiguous = if min-margin == none {
        false
      } else {
        margin < min-margin
      }

      let detected-lang = top.at("lang")
      let final-lang = if ambiguous {
        fallback
      } else {
        detected-lang
      }

      (
        lang: final-lang,
        detected-lang: detected-lang,
        label: top.at("label"),
        probability: top.at("probability"),
        predictions: predictions,
        margin: margin,
        ambiguous: ambiguous,
        fallback: if ambiguous { fallback } else { none },
        input: text,
      )
    }
  }
}

#let lang(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
  fallback: "und",
) = {
  detect-info(
    input,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
    fallback: fallback,
  ).at("lang")
}

#let is-lang(
  input,
  expected,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  let got = lang(
    input,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
    fallback: "und",
  )

  if type(expected) == array {
    expected.contains(got)
  } else {
    got == expected
  }
}

#let is-ambiguous(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  detect-info(
    input,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
    fallback: "und",
  ).at("ambiguous")
}

#let with-lang(
  body,
  language,
) = {
  text(lang: language)[#body]
}

#let _fmt-number(x) = {
  if x == none {
    "-"
  } else {
    str(calc.round(x, digits: 4))
  }
}

#let _fmt-percent(x) = {
  if x == none {
    "-"
  } else {
    str(calc.round(x * 100, digits: 2)) + "%"
  }
}

#let _fmt-bool(x) = {
  if x { "true" } else { "false" }
}

#let debug-info(
  info,
) = {
  box(
    inset: (x: 4pt, y: 2pt),
    radius: 3pt,
    stroke: 0.5pt + gray,
  )[
    lang=#info.at("lang"),
    detected=#info.at("detected-lang"),
    prob=#_fmt-percent(info.at("probability")),
    margin=#_fmt-percent(info.at("margin")),
    ambiguous=#_fmt-bool(info.at("ambiguous"))
  ]
}

#let auto-text(
  body,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
  fallback: "en",
  debug: false,
) = {
  let info = detect-info(
    body,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
    fallback: fallback,
  )

  [
    #if debug {
      debug-info(info)
      h(0.5em)
    }

    #text(lang: info.at("lang"))[#body]
  ]
}

#let auto-par(
  it,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
  fallback: "en",
) = {
  let l = lang(
    it.body,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
    fallback: fallback,
  )

  set text(lang: l)
  it
}

#let is-cjk(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  is-lang(
    input,
    cjk-languages,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
  )
}

#let is-rtl(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  is-lang(
    input,
    rtl-languages,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
  )
}

#let is-latin(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  is-lang(
    input,
    latin-script-languages,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
  )
}

#let detect-ambiguous(
  input,
  k: 3,
  threshold: 0.0,
  min-margin: 0.12,
) = {
  is-ambiguous(
    input,
    k: k,
    threshold: threshold,
    min-margin: min-margin,
  )
}
