
/// Extracts text from #dtype("content").
/// -> string
#let get-text(
  /// A content element.
  /// -> content
  it,
) = {
  if type(it) == content and it.has("text") {
    return it.text
  } else if type(it) in (symbol, int, float, version, bytes, label, type, str) {
    return str(it)
  } else {
    return repr(it)
  }
}


/// Gets the value at #arg[key] from the #typ.t.dict #arg[dict]. #arg[key] can be in dot-notation to access values in nested dictionaries.
/// -> any
#let dict-get(
  /// Dictionary to get Data from
  /// -> dictionary
  dict,
  /// String key of the value in dot-notation.
  /// -> str
  key,
  /// Default value, if the key can't be found.
  /// -> any
  default: none,
) = {
  if "." not in key {
    return dict.at(key, default: default)
  } else {
    let keys = key.split(".")
    while (keys.len() > 0) {
      let k = keys.remove(0)
      if type(dict) != dictionary or k not in dict {
        return default
      } else {
        dict = dict.at(k)
      }
    }
    if keys.len() > 0 {
      return default
    } else {
      return dict
    }
  }
}

/// #test(
///   `utils.update-dict({a: 1, b: { c: 2 }}, "b.c", v => v + 1) == {a: 1, b: { c: 3 }}`
/// )

/// Updates the value in #arg[dict] at #arg[key] by passing the value to #arg[func] and storing the result. If #arg[key] is not in #arg[dict], #arg[default] is used instead.
///
/// #arg[key] may be in dot-notation to update values in nested dictionaries.
/// -> dictionary
#let dict-update(
  /// The #typ.t.dict to update.
  /// -> dictionary | any
  dict,
  /// The key of the value. May be in dot-notation.
  /// -> str
  key,
  /// Update function: #lambda("any", ret:"any")
  /// -> function
  func,
  /// Default value to use if #arg[key] is not found in #arg[dict].
  /// -> any
  default: none,
) = {
  if key != "" and type(dict) != dictionary {
    return func(default)
  }

  if "." not in key {
    dict.insert(key, func(dict.at(key, default: default)))
  } else {
    let keys = key.split(".")
    let k = keys.remove(0)

    if k in dict {
      dict.at(k) = dict-update(dict.at(k), keys.join("."), func, default: default)
    } else {
      dict.insert(k, func(default))
    }
  }
  return dict
}

/// Recursivley merges the passed in dictionaries.
/// #codesnippet[```typ
/// #get.dict-merge(
///     (a: 1, b: 2),
///     (a: (one: 1, two:2)),
///     (a: (two: 4, three:3))
/// )
/// // gives (a:(one:1, two:4, three:3), b: 2)
/// ```]
/// -> dictionary
#let dict-merge(
  /// Dictionaries to merge.
  /// -> dictionary
  ..dicts,
) = {
  if dicts.pos().all(d => type(d) == dictionary) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

/// Creates a #typ.version object from the supplied arguments. #arg[args] can
/// be a string with a version in dot-notation.
/// - #ex(`#utils.ver(1,2,3)`)
/// - #ex(`#utils.ver("1.2.3")`)
/// - #ex(`#utils.ver("1.2", 3)`)
/// -> version
#let ver(
  /// -> int | array | str
  ..args,
) = {
  if args.pos() == () {
    return version(0)
  }

  version(
    ..args
      .pos()
      .map(v => {
        if type(v) == version {
          array(v)
        } else if type(v) == str {
          v.split(".")
        } else {
          v
        }
      })
      .flatten()
      .map(int),
  )
}


#let _unreserved = (
  (
    "-",
    "_",
    ".",
    "~",
  )
    + range(10).map(str)
    + range(65, 65 + 26).map(str.from-unicode)
    + range(97, 97 + 26).map(str.from-unicode)
)

#let to-hex(i) = {
  let _hex-digits = "0123456789ABCDEF"

  "%" + _hex-digits.at(i.bit-rshift(4).bit-and(0x0F)) + _hex-digits.at(i.bit-and(0x0F))
}

#let encode-char(char) = if char not in _unreserved {
  array(bytes(char)).map(to-hex).join()
} else {
  char
}

/// URL-encode a string.
///
/// - #ex(`#utils.url-encode("ä b ß")`)
///
/// -> str
#let url-encode(t) = {
  t.codepoints().map(encode-char).join()
}



/// Displays #arg[code] as inline #typ.raw code (with #arg(inline: true)).
/// - #ex(`#utils.rawi("my-code")`)
/// -> content
#let rawi(
  /// The content to show as inline raw.
  /// -> string | content
  code,
  /// Optional language for highlighting.
  /// -> str
  lang: none,
) = raw(block: false, lang: lang, get-text(code))


/// Shows #arg[code] as inline #typ.raw text (with #arg(block: false)) and with the given #arg[color]. The language argument will be passed to #typ.raw, but will have no effect, since #arg[code] will have an uniform color.
/// - #ex(`#utils.rawc(purple, "some inline code")`)
/// -> content
#let rawc(
  /// Color for the #typ.raw text.
  /// -> color
  color,
  /// String content to be displayed as #typ.raw.
  /// -> str
  code,
  /// Optional language name.
  /// -> str
  lang: none,
) = text(fill: color, rawi(lang: lang, code))


/// Returns a light or dark color, depending on the provided #arg[color].
/// ```example
/// - #utils.get-text-color(red)
/// - #utils.get-text-color(red.lighten(50%))
/// ```
/// -> color
#let get-text-color(
  /// Paint to get the text color for.
  /// -> color | gradient
  color,
  /// Color to use, if #arg[color] is a dark color.
  /// -> color | gradient
  light: white,
  /// Color to use, if #arg[color] is a light color.
  /// -> color | gradient
  dark: black,
) = {
  if type(color) == gradient {
    color = color.sample(50%)
  }
  if std.color.hsl(color).components(alpha: false).last() < 62% {
    light
  } else {
    dark
  }
}


/// Places a hidden #typ.figure in the document, that can be referenced via the
/// usual `@label-name` syntax.
/// -> content
#let place-reference(
  /// Label to reference.
  /// -> label
  label,
  /// Kind for the reference to properly step counters.
  /// -> str
  kind,
  /// Supplement to show when referencing.
  /// -> str
  supplement,
  /// Numbering schema to use.
  /// -> str
  numbering: "1",
) = place()[#figure(
    kind: kind,
    supplement: supplement,
    numbering: numbering,
    [],
  )#label]


/// Creates a preamble to attach to code before evaluating.
/// #arg("imports") is a #typ.t.dict with  (`module`: `imports`) pairs,
/// like #utils.rawi(lang:"typc", `(mantys: "*")`.text). This will create a
/// preamble of the form #value("#import mantys: *;")
/// ```example
/// #utils.build-preamble((mantys: "*", tidy: "parse-module, show-module"))
/// ```
/// -> str
#let build-preamble(
  /// (`module`: `imports`) pairs.
  /// -> dict
  imports,
) = {
  if imports != (:) {
    return (
      imports
        .pairs()
        .map(((mod, imp)) => {
          "#import " + mod + ": " + imp
        })
        .join("; ")
        + ";\n"
    )
  } else {
    return ""
  }
}


/// Adds a preamble for customs imports to #arg[code].
/// -> str
#let add-preamble(
  /// A Typst code block as #typ.raw or #typ.str.
  /// -> content | text
  code,
  /// The imports to add to the code. If it is a #typ.t.dict it will
  /// first be passed to @cmd:utils:build-preamble.
  /// -> dict | str
  imports,
) = {
  if type(code) != str {
    code = code.text
  }
  return build-preamble(imports) + code
}

/// Creates a #typ.label to be placed in the document (usually by cmd:utils.place-reference).
/// // TODO fix label
/// The created label is in the same format #package[Tidy] uses but will be prefixed with `cmd` to identify command references outside of docstrings.
/// - #ex(`#str(mantys.utils.create-label("create-label", arg:"module", module:"utils"))`)
///
/// #test(
///   `str(mantys.utils.create-label("create-label", arg:"module", module:"utils")) == "cmd:utils:create-label.module"`,
///   `str(mantys.utils.create-label("create-label", arg:"module")) == "cmd:create-label.module"`,
///   `str(mantys.utils.create-label("create-label")) == "cmd:create-label"`,
///   `str(mantys.utils.create-label("create-label", module:"utils")) == "cmd:utils:create-label"`
/// )
///
/// -> label
#let create-label(
  /// Name of the command.
  /// -> str
  command,
  /// Argument name to add to the label
  /// -> str
  arg: none,
  /// Optional module of the command.
  /// -> str
  module: none,
  /// Prefix for command labels. By default command labels
  /// are prefixed with `cmd`, eg. `cmd:utils.create-label`.
  /// -> str
  prefix: "cmd",
) = {
  let not-none(s) = s != none
  let label-text = (command, arg).filter(not-none).join(".")
  let label-prefix = (prefix, module).flatten().filter(not-none).join(":")
  return std.label(label-prefix + ":" + label-text)
}

/// Parses a #typ.label text into a #typ.t.dictionary with the command and module name (if present).
/// A label in the format `"cmd:utils.split-cmd-name.arg-name"` will be split into\
/// `(name: "split-cmd-name", arg:"arg-name", module: "utils", prefix:"cmd")`\
/// TODO: removing "mantys" prefix should happen in tidy template
///
/// #test(
///   `mantys.utils.parse-label("cmd:foo:bar.baz") == (name:"bar", arg:"baz", module:"foo", prefix:"cmd")`,
///   `mantys.utils.parse-label(label("cmd:foo:bar")) == (name:"bar", arg:none, module:"foo", prefix:"cmd")`,
///   `mantys.utils.parse-label(label("type:bar.baz")) == (name:"bar", arg:"baz", module:none, prefix:"type")`
/// )
///
/// -> dictionary
#let parse-label(
  /// The label to parse.
  /// -> label | str
  label,
) = {
  if type(label) == std.label { label = str(label) }

  let (..prefixes, command) = label.split(":")
  let parts = command.split(".")

  let module = if prefixes != () and prefixes.last() not in ("cmd", "type", "arg") {
    prefixes.remove(-1)
  }
  return (
    name: parts.first(),
    arg: parts.at(1, default: none),
    module: module,
    prefix: prefixes.join(":"),
  )
}


/// Splits a string into a dictionary with the command name and module (if present).
/// A string of the form `"cmd:utils.split-cmd-name"` will be split into\
/// `(name: "split-cmd-name", module: "utils")`\
/// (Note that the prefix `cmd:` is removed.)
///
/// #test(`mantys.utils.split-cmd-name("cmd:foo.bar") == (name:"bar", module:"foo")`)
///
/// -> dictionary
#let split-cmd-name(
  /// The command optionally with module and `cmd:` prefix.
  /// -> str
  name,
) = {
  let cmd = (name: name, module: none)
  if name.starts-with("cmd:") {
    cmd.name = name.slice(4)
  }
  if cmd.name.contains(".") {
    (cmd.name, cmd.module) = (cmd.name.split(".").slice(1).join("."), cmd.name.split(".").first())
  }
  return cmd
}
