// citrus - CSL-to-Typst Code Generator (Hybrid)
//
// Generates Typst code strings from CSL AST nodes.
// Uses hybrid approach: control flow is compiled, complex elements call helpers.
// The generated code follows the same (content, var-state, done-vars) protocol
// as the stack-based interpreter.

#import "../../data/variables.typ": get-variable
#import "../plan/mod.typ": (
  build-group-plan, build-term-plan, build-text-var-plan,
)

/// Escape a string for use in Typst string literals
#let escape-string(s) = {
  s
    .replace("\\", "\\\\")
    .replace("\"", "\\\"")
    .replace("\n", "\\n")
    .replace("\r", "\\r")
    .replace("\t", "\\t")
}

/// Escape a string for use in Typst content brackets [...]
/// Escapes special markup characters like _, *, #, etc.
#let escape-content(s) = {
  s
    .replace("\\", "\\\\")
    .replace("#", "\\#")
    .replace("_", "\\_")
    .replace("*", "\\*")
    .replace("`", "\\`")
    .replace("$", "\\$")
    .replace("@", "\\@")
    .replace("<", "\\<")
    .replace(">", "\\>")
}

/// Serialize a value to Typst code string (handles all types recursively)
#let serialize-value(v) = {
  if type(v) == str {
    "\"" + escape-string(v) + "\""
  } else if type(v) == bool {
    if v { "true" } else { "false" }
  } else if type(v) == int or type(v) == float {
    str(v)
  } else if type(v) == array {
    if v.len() == 0 { "()" } else {
      let items = v.map(item => serialize-value(item))
      "(" + items.join(", ") + if items.len() == 1 { "," } else { "" } + ")"
    }
  } else if type(v) == dictionary {
    if v.len() == 0 { "(: )" } else {
      let pairs = ()
      for (k, val) in v.pairs() {
        pairs.push("\"" + escape-string(k) + "\": " + serialize-value(val))
      }
      "(" + pairs.join(", ") + ")"
    }
  } else {
    "none"
  }
}

/// Serialize a dictionary to Typst code string
#let serialize-dict(d) = serialize-value(d)

/// Serialize an array to Typst code string
#let serialize-array(arr) = serialize-value(arr)

/// Emit sequential evaluation for children with done-vars propagation
#let compile-children-seq(
  children,
  macros,
  depth,
  compile-fn,
  results-name: "results",
  done-name: "done",
) = {
  let indent = "  " * depth
  let code = ""
  code += indent + "let " + results-name + " = ()\n"
  code += (
    indent + "let " + done-name + " = ctx.at(\"done-vars\", default: ())\n"
  )

  for child in children {
    code += indent + "{\n"
    code += (
      indent
        + "  let child-ctx = (..ctx, done-vars: "
        + done-name
        + ", year-suffix-done: \"__year-suffix-done\" in "
        + done-name
        + ")\n"
    )
    code += indent + "  let (content, state, child-done, child-ends) = {\n"
    code += indent + "    let ctx = child-ctx\n"
    code += compile-fn(child, macros, depth: depth + 3) + "\n"
    code += indent + "  }\n"
    code += indent + "  " + done-name + " = " + done-name + " + child-done\n"
    code += (
      indent
        + "  "
        + results-name
        + ".push((content, state, child-done, child-ends))\n"
    )
    code += indent + "}\n"
  }
  code
}

/// Compile condition expression
/// Instead of regenerating all condition logic, just call the interpreter's eval-condition
#let compile-condition(attrs) = {
  // Inline simple variable-only condition checks
  if "variable" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "variable" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-list = escape-string(attrs.variable)
      let match-mode = escape-string(attrs.at("match", default: "all"))
      if var-list == "issued" {
        return (
          "{\n"
            + "  let has-issued = (\n"
            + "    ctx.fields.at(\"year\", default: \"\") != \"\"\n"
            + "      or ctx.fields.at(\"month\", default: \"\") != \"\"\n"
            + "      or ctx.fields.at(\"day\", default: \"\") != \"\"\n"
            + "      or ctx.fields.at(\"date\", default: \"\") != \"\"\n"
            + "      or ctx.fields.at(\"season\", default: \"\") != \"\"\n"
            + "      or ctx.fields.at(\"literal\", default: \"\") != \"\"\n"
            + "  )\n"
            + "  if \""
            + match-mode
            + "\" == \"none\" {\n"
            + "    not has-issued\n"
            + "  } else {\n"
            + "    has-issued\n"
            + "  }\n"
            + "}"
        )
      }
      return (
        "{ let vars = \""
          + var-list
          + "\".split(\" \").filter(v => v != \"\")\n"
          + "  if vars.len() == 0 { false } else if \""
          + match-mode
          + "\" == \"any\" {\n"
          + "    vars.any(v => has-variable(ctx, v))\n"
          + "  } else if \""
          + match-mode
          + "\" == \"none\" {\n"
          + "    not vars.any(v => has-variable(ctx, v))\n"
          + "  } else if \""
          + match-mode
          + "\" == \"nand\" {\n"
          + "    not vars.all(v => has-variable(ctx, v))\n"
          + "  } else {\n"
          + "    vars.all(v => has-variable(ctx, v))\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple is-numeric condition checks
  if "is-numeric" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "is-numeric" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("is-numeric"))
      return (
        "{ let val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  if val == \"\" { false } else { val.starts-with(regex(\"\\\\d\")) }\n"
          + "}"
      )
    }
  }

  // Inline simple locator condition checks
  if "locator" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "locator" and key != "match" { has-other = true }
    }

    if not has-other {
      let locator-types = escape-string(attrs.at("locator"))
      let match-mode = escape-string(attrs.at("match", default: "any"))
      return (
        "{ let locator-types = \""
          + locator-types
          + "\".split(\" \")\n"
          + "  let current-label = ctx.at(\"locator-label\", default: \"page\")\n"
          + "  let has-locator = ctx.fields.at(\"locator\", default: \"\") != \"\"\n"
          + "  let in-list = locator-types.any(t => t == current-label)\n"
          + "  if \""
          + match-mode
          + "\" == \"none\" {\n"
          + "    has-locator and not in-list\n"
          + "  } else {\n"
          + "    has-locator and in-list\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple disambiguate condition checks
  if "disambiguate" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "disambiguate" and key != "match" { has-other = true }
    }

    if not has-other {
      let disambiguate-value = escape-string(attrs.at("disambiguate"))
      let step = attrs.at("_disambiguate-step", default: "1")
      let step-str = escape-string(step)
      return (
        "{ let needs-disambig = ctx.at(\"disambiguate\", default: false)\n"
          + "  let step = \""
          + step-str
          + "\"\n"
          + "  if type(needs-disambig) == int {\n"
          + "    if type(step) == str { step = int(step) }\n"
          + "    \""
          + disambiguate-value
          + "\" == \"true\" and step <= needs-disambig\n"
          + "  } else {\n"
          + "    \""
          + disambiguate-value
          + "\" == \"true\" and needs-disambig\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple position condition checks
  if "position" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "position" and key != "match" { has-other = true }
    }

    if not has-other {
      let match-mode = attrs.at("match", default: "all")
      if match-mode != "all" {
        let parts = ()
        for (key, val) in attrs {
          parts.push(
            "\"" + escape-string(key) + "\": \"" + escape-string(val) + "\"",
          )
        }
        return "eval-condition((" + parts.join(", ") + ",), ctx)"
      }
      let positions = escape-string(attrs.at("position"))
      return (
        "{ let positions = \""
          + positions
          + "\".split(\" \")\n"
          + "  let current-pos = ctx.at(\"position\", default: \"first\")\n"
          + "  let note-distance = if positions.any(p => p == \"near-note\" or p == \"far-note\") {\n"
          + "    let last-note = ctx.at(\"last-note-number\", default: none)\n"
          + "    let current-note = ctx.at(\"note-number\", default: none)\n"
          + "    if last-note != none and current-note != none { current-note - last-note } else { none }\n"
          + "  } else { none }\n"
          + "  let near-note-threshold = ctx.style.at(\"near-note-distance\", default: 5)\n"
          + "  positions.any(p => {\n"
          + "    if p == current-pos {\n"
          + "      true\n"
          + "    } else if p == \"ibid\" {\n"
          + "      current-pos in (\"ibid\", \"ibid-with-locator\")\n"
          + "    } else if p == \"subsequent\" {\n"
          + "      current-pos in (\"subsequent\", \"ibid\", \"ibid-with-locator\")\n"
          + "    } else if p == \"near-note\" {\n"
          + "      note-distance != none and note-distance <= near-note-threshold\n"
          + "    } else if p == \"far-note\" {\n"
          + "      note-distance == none or note-distance > near-note-threshold\n"
          + "    } else {\n"
          + "      false\n"
          + "    }\n"
          + "  })\n"
          + "}"
      )
    }
  }

  // Inline simple context condition checks
  if "context" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "context" and key != "match" { has-other = true }
    }

    if not has-other {
      let context-value = escape-string(attrs.at("context"))
      return (
        "{ let current-context = ctx.at(\"render-context\", default: \"bibliography\")\n"
          + "  \""
          + context-value
          + "\" == current-context\n"
          + "}"
      )
    }
  }

  // Inline simple genre condition checks
  if "genre" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "genre" and key != "match" { has-other = true }
    }

    if not has-other {
      let genre-list = escape-string(attrs.at("genre"))
      return (
        "{ let genre-list = \""
          + genre-list
          + "\".split(\" \")\n"
          + "  let entry-genre = get-variable(ctx, \"genre\")\n"
          + "  genre-list.any(g => g == entry-genre)\n"
          + "}"
      )
    }
  }

  // Inline simple is-multiple condition checks
  if "is-multiple" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "is-multiple" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("is-multiple"))
      return (
        "{ let val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  val != \"\" and val.contains(\" \")\n"
          + "}"
      )
    }
  }

  // Inline simple has-year-only condition checks
  if "has-year-only" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "has-year-only" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("has-year-only"))
      return (
        "{ let date-val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  if date-val == \"\" { false } else {\n"
          + "    let parts = date-val.split(\"-\")\n"
          + "    parts.len() == 1 or (parts.len() >= 2 and parts.at(1, default: \"\") == \"\")\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple has-to-month-or-season condition checks
  if "has-to-month-or-season" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "has-to-month-or-season" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("has-to-month-or-season"))
      return (
        "{ let date-val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  if date-val == \"\" { false } else {\n"
          + "    let parts = date-val.split(\"-\")\n"
          + "    parts.len() >= 2 and parts.at(1, default: \"\") != \"\" and (parts.len() < 3 or parts.at(2, default: \"\") == \"\")\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple has-day condition checks
  if "has-day" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "has-day" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("has-day"))
      let match-mode = escape-string(attrs.at("match", default: "all"))
      return (
        "{ let date-val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  let has-day-standard = if date-val != \"\" {\n"
          + "    let iso-match = date-val.match(regex(\"^\\\\d{4}[-/]\\\\d{1,2}[-/]\\\\d{1,2}\"))\n"
          + "    if iso-match != none { true } else {\n"
          + "      let text-match = date-val.match(regex(\"[A-Za-z]+\\\\s+\\\\d{1,2},?\\\\s+\\\\d{4}\"))\n"
          + "      text-match != none\n"
          + "    }\n"
          + "  } else { false }\n"
          + "  let has-day-cslm = if date-val != \"\" {\n"
          + "    let parts = date-val.split(\"-\")\n"
          + "    parts.len() >= 3 and parts.at(2, default: \"\") != \"\"\n"
          + "  } else { false }\n"
          + "  if \""
          + match-mode
          + "\" == \"any\" {\n"
          + "    has-day-standard or has-day-cslm\n"
          + "  } else if \""
          + match-mode
          + "\" == \"none\" {\n"
          + "    not (has-day-standard or has-day-cslm)\n"
          + "  } else if \""
          + match-mode
          + "\" == \"nand\" {\n"
          + "    not (has-day-standard and has-day-cslm)\n"
          + "  } else {\n"
          + "    has-day-standard and has-day-cslm\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple is-uncertain-date condition checks
  if "is-uncertain-date" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "is-uncertain-date" and key != "match" { has-other = true }
    }

    if not has-other {
      let var-name = escape-string(attrs.at("is-uncertain-date"))
      return (
        "{ let date-val = get-variable(ctx, \""
          + var-name
          + "\")\n"
          + "  if date-val == \"\" { false } else {\n"
          + "    let s = lower(str(date-val))\n"
          + "    s.contains(\"circa\") or s.contains(\"c.\") or s.contains(\"~\") or s.contains(\"?\") or s.contains(\"ca.\") or s.contains(\"approximately\")\n"
          + "  }\n"
          + "}"
      )
    }
  }

  // Inline simple type condition checks
  if "type" in attrs {
    let has-other = false
    for (key, val) in attrs {
      if key != "type" and key != "match" { has-other = true }
    }

    if not has-other {
      let type-list = escape-string(attrs.at("type"))
      let match-mode = attrs.at("match", default: "all")
      if match-mode == "none" or match-mode == "nand" {
        return "not check-type(ctx, \"" + type-list + "\")"
      }
      return "check-type(ctx, \"" + type-list + "\")"
    }
  }

  // Serialize attrs dict as Typst code
  let parts = ()
  for (key, val) in attrs {
    parts.push("\"" + escape-string(key) + "\": \"" + escape-string(val) + "\"")
  }
  "eval-condition((" + parts.join(", ") + ",), ctx)"
}

/// Emit a macro call with optional cache usage
#let compile-macro-call(
  macro-name,
  indent,
  attrs-str,
  raw: false,
  prefix: "",
  suffix: "",
  use-cache: true,
  shift-quote-level: false,
) = {
  let macro-key = escape-string(macro-name)

  let code = indent + "{\n"
  if use-cache {
    let cache-setup = (
      indent
        + "  let macro-cache = if \"compiled-macro-cache\" in ctx {\n"
        + indent
        + "    ctx.compiled-macro-cache\n"
        + indent
        + "  } else {\n"
        + indent
        + "    (:)\n"
        + indent
        + "  }\n"
    )
    let cache-fetch = (
      indent
        + "  let can-use-cache = (\"done-vars\" not in ctx or ctx.done-vars.len() == 0)\n"
        + indent
        + "  let result = if can-use-cache and \""
        + macro-key
        + "\" in macro-cache {\n"
        + indent
        + "    macro-cache.at(\""
        + macro-key
        + "\")\n"
        + indent
        + "  } else {\n"
        + indent
        + "    let computed = ctx.compiled-macros.at(\""
        + macro-key
        + "\")(ctx)\n"
        + indent
        + "    macro-cache.insert(\""
        + macro-key
        + "\", computed)\n"
        + indent
        + "    computed\n"
        + indent
        + "  }\n"
    )
    code += cache-setup
    code += cache-fetch
    code += indent + "  let content = result.at(0)\n"
    code += indent + "  let state = result.at(1, default: \"none\")\n"
    code += indent + "  let done = result.at(2, default: ())\n"
    code += indent + "  let ends = result.at(3, default: false)\n"
  } else {
    if shift-quote-level {
      code += (
        indent
          + "  let macro-ctx = (..ctx, quote-level: ctx.at(\"quote-level\", default: 0) + 1)\n"
      )
      code += (
        indent
          + "  let result = ctx.compiled-macros.at(\""
          + macro-key
          + "\")(macro-ctx)\n"
      )
    } else {
      code += (
        indent
          + "  let result = ctx.compiled-macros.at(\""
          + macro-key
          + "\")(ctx)\n"
      )
    }
    code += indent + "  let content = result.at(0)\n"
    code += indent + "  let state = result.at(1, default: \"none\")\n"
    code += indent + "  let done = result.at(2, default: ())\n"
    code += indent + "  let ends = result.at(3, default: false)\n"
  }
  if raw {
    code += (
      indent + "  if content != [] and content != none and content != \"\" {\n"
    )
    code += indent + "    (content, state, done, ends)\n"
    code += indent + "  } else {\n"
    code += indent + "    ([], state, done, false)\n"
    code += indent + "  }\n"
  } else {
    code += indent + "  let attrs = " + attrs-str + "\n"
    code += indent + "  let attrs = (..attrs, \"_ends-with-period\": ends)\n"
    code += (
      indent + "  if content != [] and content != none and content != \"\" {\n"
    )
    code += (
      indent
        + "    let (formatted, formatted-ends) = format-text-content(ctx, content, attrs)\n"
    )
    code += (
      indent
        + "    let new-ends = if type(formatted) == str { formatted.ends-with(\".\") } else { formatted-ends }\n"
    )
    code += indent + "    (formatted, state, done, new-ends)\n"
    code += indent + "  } else {\n"
    code += indent + "    ([], state, done, false)\n"
    code += indent + "  }\n"
  }
  code += indent + "}"
  code
}

/// Main recursive compiler function
/// Handles all CSL node types in a single function to avoid forward declaration issues
#let compile-ast(node, macros, depth: 0) = {
  let indent = "  " * depth

  // Handle string nodes
  if type(node) == str {
    let trimmed = node.trim()
    if trimmed == "" {
      return indent + "([], \"none\", (), false)"
    } else {
      return (
        indent
          + "(["
          + escape-content(trimmed)
          + "], \"none\", (), "
          + if trimmed.ends-with(".") { "true" } else { "false" }
          + ")"
      )
    }
  }

  // Handle non-dict nodes
  if type(node) != dictionary {
    return indent + "([], \"none\", (), false)"
  }

  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  // ==========================================================================
  // <text> element
  // ==========================================================================
  if tag == "text" {
    if "variable" in attrs {
      // Call helper for variable lookup with full formatting support
      let attrs-str = serialize-dict(attrs)
      let plan = build-text-var-plan(attrs)
      if (
        not plan.is-page-like
          and plan.form == "long"
          and not plan.has-quotes
          and not plan.has-text-case
          and not plan.has-affixes
          and not plan.has-strip-periods
          and not plan.has-formatting
      ) {
        let plan-str = serialize-dict(plan)
        return (
          indent
            + "get-text-variable-raw(ctx, "
            + attrs-str
            + ", "
            + plan-str
            + ")"
        )
      }
      if (
        plan.is-page-like
          and plan.form == "long"
          and not plan.has-quotes
          and not plan.has-text-case
      ) {
        let plan-str = serialize-dict(plan)
        return (
          indent
            + "get-text-variable-planned(ctx, "
            + attrs-str
            + ", "
            + plan-str
            + ")"
        )
      }
      return indent + "get-text-variable(ctx, " + attrs-str + ")"
    } else if "value" in attrs {
      // Literal value - handle quotes/text-case via helper
      let attrs-str = serialize-dict(attrs)
      let plan = build-text-var-plan(attrs)
      let value = attrs.at("value", default: "")
      let has-quote-chars = (
        type(value) == str
          and (
            value.contains("\"")
              or value.contains("'")
              or value.contains("\u{2018}")
              or value.contains("\u{2019}")
              or value.contains("\u{201C}")
              or value.contains("\u{201D}")
          )
      )
      if (
        not has-quote-chars
          and not plan.has-quotes
          and not plan.has-text-case
          and not plan.has-affixes
          and not plan.has-strip-periods
          and not plan.has-formatting
      ) {
        let plan-str = serialize-dict(plan)
        return (
          indent
            + "format-text-value-raw(ctx, "
            + attrs-str
            + ", "
            + plan-str
            + ")"
        )
      }
      return indent + "format-text-value(ctx, " + attrs-str + ")"
    } else if "term" in attrs {
      // Call helper for term lookup
      let attrs-str = serialize-dict(attrs)
      let plan = build-term-plan(attrs)
      if (
        not plan.has-affixes
          and not plan.has-strip-periods
          and not plan.has-formatting
          and not plan.has-text-case
          and not plan.has-quotes
      ) {
        let plan-str = serialize-dict(plan)
        return indent + "get-term-raw(ctx, " + attrs-str + ", " + plan-str + ")"
      }
      return indent + "get-term(ctx, " + attrs-str + ")"
    } else if "macro" in attrs {
      let macro-name = attrs.macro
      let prefix = attrs.at("prefix", default: "")
      let suffix = attrs.at("suffix", default: "")
      let has-quotes = "quotes" in attrs and attrs.at("quotes") == "true"
      let has-text-case = "text-case" in attrs
      let has-strip-periods = (
        attrs.at("strip-periods", default: "false") == "true"
      )
      let has-formatting = (
        "font-style" in attrs
          or "font-weight" in attrs
          or "font-variant" in attrs
          or "text-decoration" in attrs
          or "vertical-align" in attrs
          or "display" in attrs
      )
      let raw = (
        prefix == ""
          and suffix == ""
          and not has-quotes
          and not has-text-case
          and not has-strip-periods
          and not has-formatting
      )

      let attrs-str = serialize-dict(attrs)
      return compile-macro-call(
        macro-name,
        indent,
        attrs-str,
        raw: raw,
        prefix: prefix,
        suffix: suffix,
        use-cache: not has-quotes,
        shift-quote-level: has-quotes,
      )
    } else {
      return indent + "([], \"none\", (), false)"
    }
  }

  // ==========================================================================
  // <group> element
  // ==========================================================================
  if tag == "group" {
    let delimiter = attrs.at("delimiter", default: "")
    let prefix = attrs.at("prefix", default: "")
    let suffix = attrs.at("suffix", default: "")
    let plan = build-group-plan(attrs, children)

    // Filter valid children
    let valid-children = children.filter(c => (
      type(c) == dictionary and c.at("tag", default: "") != ""
    ))

    if valid-children.len() == 0 {
      return indent + "([], \"none\", (), false)"
    }

    if (
      valid-children.len() == 1
        and delimiter == ""
        and not plan.has-prefix
        and not plan.has-suffix
        and not plan.has-strip-periods
        and not plan.has-formatting
        and plan.allowed-children-only
    ) {
      return compile-ast(valid-children.first(), macros, depth: depth)
    }

    let code = indent + "{\n"
    code += compile-children-seq(
      valid-children,
      macros,
      depth + 1,
      compile-ast,
      results-name: "results",
      done-name: "done",
    )
    code += indent + "  let contents = ()\n"
    code += indent + "  let parts = ()\n"
    code += indent + "  let all-strings = true\n"
    code += indent + "  let has-var = false\n"
    code += indent + "  let has-no-var = false\n"
    code += indent + "  let done = ()\n"
    code += indent + "  for r in results {\n"
    code += indent + "    let c = normalize-content(r.at(0))\n"
    code += indent + "    if c != [] and c != none and c != \"\" {\n"
    code += indent + "      if type(c) != str { all-strings = false }\n"
    code += indent + "      contents.push(c)\n"
    code += indent + "      parts.push((c, r.at(3, default: false)))\n"
    code += indent + "    }\n"
    code += indent + "    let s = r.at(1)\n"
    code += indent + "    if s == \"var\" { has-var = true }\n"
    code += indent + "    if s == \"no-var\" { has-no-var = true }\n"
    code += indent + "    done = done + r.at(2)\n"
    code += indent + "  }\n"
    code += (
      indent + "  if (has-var or has-no-var) and not has-var {\n"
    )
    code += indent + "    ([], \"no-var\", done, false)\n"
    code += indent + "  } else {\n"
    code += indent + "    let end-flag = false\n"
    code += indent + "    for r in results.rev() {\n"
    code += indent + "      if not end-flag {\n"
    code += indent + "        let c = normalize-content(r.at(0))\n"
    code += (
      indent
        + "        if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
    )
    code += indent + "      }\n"
    code += indent + "    }\n"
    if delimiter != "" {
      let escaped = escape-string(delimiter)
      code += indent + "    let joined = if parts.len() > 1 {\n"
      code += indent + "      let joined = ()\n"
      code += indent + "      for i in range(parts.len()) {\n"
      code += indent + "        if i > 0 {\n"
      code += (
        indent
          + "          let prev-content = parts.at(i - 1).at(0)\n"
          + "          let prev-ends = (\n"
          + "            parts.at(i - 1).at(1, default: false)\n"
          + "              or content-to-string(prev-content).trim().ends-with(\".\")\n"
          + "          )\n"
          + "          let next-content = parts.at(i).at(0)\n"
          + "          let next-str = content-to-string(next-content).trim()\n"
          + "          let prev-str = content-to-string(prev-content).trim()\n"
      )
      code += (
        indent
          + "          let delim = if (\""
          + escaped
          + "\".len() > 0 and \""
          + escaped
          + "\".first() == \".\" and prev-ends and \""
          + escaped
          + "\".trim() == \".\") { \""
          + escaped
          + "\".slice(1) } else { \""
          + escaped
          + "\" }\n"
          + "          let delim = if (delim.len() > 0 and delim.first() == \",\" and next-str.starts-with(\"(\") and prev-str.len() > 0 and prev-str.clusters().last().match(regex(\"\\\\d\")) != none) { delim.replace(\",\", \"\") } else { delim }\n"
      )
      code += indent + "          if delim != \"\" { joined.push(delim) }\n"
      code += indent + "        }\n"
      code += indent + "        joined.push(parts.at(i).at(0))\n"
      code += indent + "      }\n"
      code += indent + "      joined.join()\n"
      code += indent + "    } else {\n"
      code += indent + "      contents.join()\n"
      code += indent + "    }\n"
    } else {
      code += (
        indent
          + "    let joined = if all-strings { contents.join(\"\") } else { contents.join() }\n"
      )
    }

    if (
      not plan.has-prefix
        and not plan.has-suffix
        and not plan.has-strip-periods
        and not plan.has-formatting
    ) {
      code += indent + "    let formatted = joined\n"
    } else {
      code += (
        indent
          + "    let formatted = finalize(joined, "
          + serialize-dict(attrs)
          + ")\n"
      )
    }
    // done already accumulated above
    code += (
      indent
        + "    if formatted != [] and formatted != none and formatted != \"\" {\n"
    )
    code += (
      indent
        + "      let final-state = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"var\" }\n"
    )
    code += indent + "      (formatted, final-state, done, end-flag)\n"
    code += indent + "    } else {\n"
    code += (
      indent
        + "      let final-state = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
    )
    code += indent + "      ([], final-state, done, false)\n"
    code += indent + "    }\n"

    code += indent + "  }\n"
    code += indent + "}"
    return code
  }

  // ==========================================================================
  // <choose> element
  // ==========================================================================
  if tag == "choose" {
    let code = indent + "{\n"
    let first = true
    let saw-variable-cond = false

    for branch in children {
      if type(branch) != dictionary { continue }
      let branch-tag = branch.at("tag", default: "")
      let branch-attrs = branch.at("attrs", default: (:))
      let branch-children = branch.at("children", default: ())

      // Filter valid branch children
      let valid-branch-children = branch-children.filter(c => (
        type(c) == dictionary and c.at("tag", default: "") != ""
      ))

      if branch-tag == "if" or branch-tag == "else-if" {
        if "variable" in branch-attrs { saw-variable-cond = true }
        let condition = compile-condition(branch-attrs)
        let force-var = "variable" in branch-attrs

        if first {
          code += indent + "  if " + condition + " {\n"
          first = false
        } else {
          code += indent + "  } else if " + condition + " {\n"
        }

        // Compile branch children
        if valid-branch-children.len() == 1 and not force-var {
          code += (
            compile-ast(valid-branch-children.first(), macros, depth: depth + 2)
              + "\n"
          )
        } else if valid-branch-children.len() > 1 {
          code += indent + "    {\n"
          code += compile-children-seq(
            valid-branch-children,
            macros,
            depth + 3,
            compile-ast,
            results-name: "results",
            done-name: "done",
          )
          code += indent + "      let contents = ()\n"
          code += indent + "      let has-var = false\n"
          code += indent + "      let has-no-var = false\n"
          code += indent + "      for r in results {\n"
          code += indent + "        let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "        if c != [] and c != none and c != \"\" { contents.push(c) }\n"
          )
          code += indent + "        let s = r.at(1)\n"
          code += indent + "        if s == \"var\" { has-var = true }\n"
          code += indent + "        if s == \"no-var\" { has-no-var = true }\n"
          code += indent + "      }\n"
          code += (
            indent
              + "      let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
          )
          if force-var {
            code += (
              indent
                + "      if merged == \"none\" and contents.len() > 0 { merged = \"var\" }\n"
            )
          }
          code += indent + "      let done = ()\n"
          code += indent + "      let end-flag = false\n"
          code += indent + "      for r in results.rev() {\n"
          code += indent + "        done = done + r.at(2)\n"
          code += indent + "        if not end-flag {\n"
          code += indent + "          let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "          if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
          )
          code += indent + "        }\n"
          code += indent + "      }\n"
          code += indent + "      (contents.join(), merged, done, end-flag)\n"
          code += indent + "    }\n"
        } else if valid-branch-children.len() == 1 and force-var {
          code += indent + "    {\n"
          code += compile-children-seq(
            valid-branch-children,
            macros,
            depth + 3,
            compile-ast,
            results-name: "results",
            done-name: "done",
          )
          code += indent + "      let contents = ()\n"
          code += indent + "      let has-var = false\n"
          code += indent + "      let has-no-var = false\n"
          code += indent + "      for r in results {\n"
          code += indent + "        let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "        if c != [] and c != none and c != \"\" { contents.push(c) }\n"
          )
          code += indent + "        let s = r.at(1)\n"
          code += indent + "        if s == \"var\" { has-var = true }\n"
          code += indent + "        if s == \"no-var\" { has-no-var = true }\n"
          code += indent + "      }\n"
          code += (
            indent
              + "      let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
          )
          code += (
            indent
              + "      if merged == \"none\" and contents.len() > 0 { merged = \"var\" }\n"
          )
          code += indent + "      let done = ()\n"
          code += indent + "      let end-flag = false\n"
          code += indent + "      for r in results.rev() {\n"
          code += indent + "        done = done + r.at(2)\n"
          code += indent + "        if not end-flag {\n"
          code += indent + "          let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "          if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
          )
          code += indent + "        }\n"
          code += indent + "      }\n"
          code += indent + "      (contents.join(), merged, done, end-flag)\n"
          code += indent + "    }\n"
        } else {
          code += indent + "    ([], \"none\", (), false)\n"
        }
      } else if branch-tag == "else" {
        let force-var = saw-variable-cond
        code += indent + "  } else {\n"

        if valid-branch-children.len() == 1 and not force-var {
          code += (
            compile-ast(valid-branch-children.first(), macros, depth: depth + 2)
              + "\n"
          )
        } else if valid-branch-children.len() > 1 {
          code += indent + "    {\n"
          code += compile-children-seq(
            valid-branch-children,
            macros,
            depth + 3,
            compile-ast,
            results-name: "results",
            done-name: "done",
          )
          code += indent + "      let contents = ()\n"
          code += indent + "      let has-var = false\n"
          code += indent + "      let has-no-var = false\n"
          code += indent + "      for r in results {\n"
          code += indent + "        let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "        if c != [] and c != none and c != \"\" { contents.push(c) }\n"
          )
          code += indent + "        let s = r.at(1)\n"
          code += indent + "        if s == \"var\" { has-var = true }\n"
          code += indent + "        if s == \"no-var\" { has-no-var = true }\n"
          code += indent + "      }\n"
          code += (
            indent
              + "      let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
          )
          if force-var {
            code += (
              indent
                + "      if merged == \"none\" and contents.len() > 0 { merged = \"var\" }\n"
            )
          }
          code += indent + "      let done = ()\n"
          code += indent + "      let end-flag = false\n"
          code += indent + "      for r in results.rev() {\n"
          code += indent + "        done = done + r.at(2)\n"
          code += indent + "        if not end-flag {\n"
          code += indent + "          let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "          if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
          )
          code += indent + "        }\n"
          code += indent + "      }\n"
          code += indent + "      (contents.join(), merged, done, end-flag)\n"
          code += indent + "    }\n"
        } else if valid-branch-children.len() == 1 and force-var {
          code += indent + "    {\n"
          code += compile-children-seq(
            valid-branch-children,
            macros,
            depth + 3,
            compile-ast,
            results-name: "results",
            done-name: "done",
          )
          code += indent + "      let contents = ()\n"
          code += indent + "      let has-var = false\n"
          code += indent + "      let has-no-var = false\n"
          code += indent + "      for r in results {\n"
          code += indent + "        let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "        if c != [] and c != none and c != \"\" { contents.push(c) }\n"
          )
          code += indent + "        let s = r.at(1)\n"
          code += indent + "        if s == \"var\" { has-var = true }\n"
          code += indent + "        if s == \"no-var\" { has-no-var = true }\n"
          code += indent + "      }\n"
          code += (
            indent
              + "      let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
          )
          code += (
            indent
              + "      if merged == \"none\" and contents.len() > 0 { merged = \"var\" }\n"
          )
          code += indent + "      let done = ()\n"
          code += indent + "      let end-flag = false\n"
          code += indent + "      for r in results.rev() {\n"
          code += indent + "        done = done + r.at(2)\n"
          code += indent + "        if not end-flag {\n"
          code += indent + "          let c = normalize-content(r.at(0))\n"
          code += (
            indent
              + "          if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
          )
          code += indent + "        }\n"
          code += indent + "      }\n"
          code += indent + "      (contents.join(), merged, done, end-flag)\n"
          code += indent + "    }\n"
        } else {
          code += indent + "    ([], \"none\", (), false)\n"
        }
      }
    }

    if not first {
      // Check if we have an else branch already
      let has-else = children.any(b => (
        type(b) == dictionary and b.at("tag", default: "") == "else"
      ))
      if not has-else {
        // Add default else branch to ensure we always return a tuple
        code += indent + "  } else {\n"
        code += indent + "    ([], \"none\", (), false)\n"
      }
      code += indent + "  }\n"
    } else {
      code += indent + "  ([], \"none\", (), false)\n"
    }

    code += indent + "}"
    return code
  }

  // ==========================================================================
  // <names> element - calls format-names helper
  // ==========================================================================
  if tag == "names" {
    let attrs-str = serialize-dict(attrs)
    let children-str = serialize-array(children)

    let var-str = attrs.at("variable", default: "author")
    let single-var = not var-str.contains(" ")
    let var-list = var-str.split(" ")

    let has-substitute = children.any(c => (
      type(c) == dictionary and c.at("tag", default: "") == "substitute"
    ))

    let allowed-children = children
      .filter(c => type(c) == dictionary)
      .all(c => (
        c.at("tag", default: "") in ("name", "label", "et-al", "institution")
      ))

    let name-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "name"
    ))
    let label-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "label"
    ))
    let substitute-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "substitute"
    ))

    let name-attrs = if name-node != none {
      name-node.at("attrs", default: (:))
    } else { (:) }
    if "name-as-sort-order" not in name-attrs {
      let sort-order = attrs.at("name-as-sort-order", default: none)
      if sort-order != none {
        name-attrs.insert("name-as-sort-order", sort-order)
      }
    }

    let name-parts = (:)
    if name-node != none {
      let name-children = name-node.at("children", default: ())
      for child in name-children {
        if (
          type(child) == dictionary
            and child.at("tag", default: "") == "name-part"
        ) {
          let part-attrs = child.at("attrs", default: (:))
          let part-name = part-attrs.at("name", default: "")
          if part-name in ("family", "given") {
            name-parts.insert(part-name, part-attrs)
          }
        }
      }
    }

    let et-al-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "et-al"
    ))
    let et-al-attrs = if et-al-node != none {
      et-al-node.at("attrs", default: (:))
    } else { (:) }
    let et-al-term = et-al-attrs.at("term", default: "et-al")

    let label-attrs = if label-node != none {
      label-node.at("attrs", default: (:))
    } else { (:) }
    let has-label = label-node != none
    let label-position = if label-node != none and name-node != none {
      let label-idx = children.position(c => (
        type(c) == dictionary and c.at("tag", default: "") == "label"
      ))
      let name-idx = children.position(c => (
        type(c) == dictionary and c.at("tag", default: "") == "name"
      ))
      if label-idx != none and name-idx != none and label-idx < name-idx {
        "before"
      } else { "after" }
    } else { "after" }

    let institution-node = children.find(c => (
      type(c) == dictionary and c.at("tag", default: "") == "institution"
    ))
    let institution-attrs = if institution-node != none {
      institution-node.at("attrs", default: (:))
    } else { none }

    let substitute-children = if substitute-node != none {
      substitute-node.at("children", default: ())
    } else { () }

    let plan = (
      var: var-str,
      vars: var-list,
      names-delimiter: attrs.at("delimiter", default: none),
      name-attrs: name-attrs,
      name-parts: name-parts,
      et-al-attrs: et-al-attrs,
      et-al-term: et-al-term,
      label-attrs: label-attrs,
      label-position: label-position,
      has-label: has-label,
      institution-attrs: institution-attrs,
      parent-name-node: name-node,
      parent-label-node: label-node,
      substitute-children: substitute-children,
    )
    let plan-str = serialize-dict(plan)

    if has-substitute {
      return (
        indent
          + "format-names-substitute(ctx, "
          + attrs-str
          + ", "
          + plan-str
          + ")"
      )
    }

    if not has-substitute and allowed-children {
      if single-var {
        return (
          indent
            + "format-names-single(ctx, "
            + attrs-str
            + ", "
            + plan-str
            + ")"
        )
      } else {
        return (
          indent
            + "format-names-multi(ctx, "
            + attrs-str
            + ", "
            + plan-str
            + ")"
        )
      }
    }

    return indent + "format-names(ctx, " + attrs-str + ", " + children-str + ")"
  }

  // ==========================================================================
  // <date> element - calls format-date helper
  // ==========================================================================
  if tag == "date" {
    let attrs-str = serialize-dict(attrs)
    let children-str = serialize-array(children)
    return indent + "format-date(ctx, " + attrs-str + ", " + children-str + ")"
  }

  // ==========================================================================
  // <number> element - compiled form specialization
  // ==========================================================================
  if tag == "number" {
    let attrs-str = serialize-dict(attrs)
    let form = attrs.at("form", default: "numeric")
    let helper = if form == "ordinal" {
      "format-number-ordinal"
    } else if form == "long-ordinal" {
      "format-number-long-ordinal"
    } else if form == "roman" {
      "format-number-roman"
    } else {
      "format-number-numeric"
    }
    return indent + helper + "(ctx, " + attrs-str + ")"
  }

  // ==========================================================================
  // <label> element - calls format-label helper
  // ==========================================================================
  if tag == "label" {
    let attrs-str = serialize-dict(attrs)
    return indent + "format-label(ctx, " + attrs-str + ")"
  }

  // Unknown tag
  indent + "([], \"none\", (), false)"
}

/// Compile a macro definition
#let compile-macro(name, children, macros) = {
  // Filter valid children
  let valid-children = children.filter(c => (
    type(c) == dictionary and c.at("tag", default: "") != ""
  ))

  if valid-children.len() == 0 {
    return "(ctx) => ([], \"none\", (), false)"
  }

  if valid-children.len() == 1 {
    let code = "(ctx) => {\n"
    code += (
      "  let result = "
        + compile-ast(valid-children.first(), macros, depth: 1)
        + "\n"
    )
    code += "  let content = result.at(0)\n"
    code += "  let state = result.at(1, default: \"none\")\n"
    code += "  let done = result.at(2, default: ())\n"
    code += "  let ends = result.at(3, default: false)\n"
    code += "  if state == \"no-var\" {\n"
    code += "    ([], \"no-var\", done, false)\n"
    code += "  } else {\n"
    code += "    (content, state, done, ends)\n"
    code += "  }\n"
    code += "}"
    return code
  }

  // Multiple children
  let code = "(ctx) => {\n"
  code += compile-children-seq(valid-children, macros, 1, compile-ast)
  code += "  let contents = ()\n"
  code += "  let has-var = false\n"
  code += "  let has-no-var = false\n"
  code += "  let done = ()\n"
  code += "  for r in results {\n"
  code += "    let c = normalize-content(r.at(0))\n"
  code += "    if c != [] and c != none and c != \"\" { contents.push(c) }\n"
  code += "    let s = r.at(1)\n"
  code += "    if s == \"var\" { has-var = true }\n"
  code += "    if s == \"no-var\" { has-no-var = true }\n"
  code += "    done = done + r.at(2)\n"
  code += "  }\n"
  code += "  if (has-var or has-no-var) and not has-var {\n"
  code += "    ([], \"no-var\", done, false)\n"
  code += "  } else {\n"
  code += "    let end-flag = false\n"
  code += "    for r in results.rev() {\n"
  code += "      if not end-flag {\n"
  code += "        let c = normalize-content(r.at(0))\n"
  code += "        if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
  code += "      }\n"
  code += "    }\n"
  code += "    let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
  code += "    (contents.join(), merged, done, end-flag)\n"
  code += "  }\n"
  code += "}"
  code
}

/// Compile layout children
#let compile-children(children, macros) = {
  let valid-children = children.filter(c => (
    type(c) == dictionary and c.at("tag", default: "") != ""
  ))

  if valid-children.len() == 0 {
    return "([], \"none\", (), false)"
  }

  if valid-children.len() == 1 {
    return compile-ast(valid-children.first(), macros, depth: 1)
  }

  // Multiple children
  let code = "{\n"
  code += compile-children-seq(valid-children, macros, 1, compile-ast)
  code += "  let contents = ()\n"
  code += "  let has-var = false\n"
  code += "  let has-no-var = false\n"
  code += "  let done = ()\n"
  code += "  for r in results {\n"
  code += "    let c = normalize-content(r.at(0))\n"
  code += "    if c != [] and c != none and c != \"\" { contents.push(c) }\n"
  code += "    let s = r.at(1)\n"
  code += "    if s == \"var\" { has-var = true }\n"
  code += "    if s == \"no-var\" { has-no-var = true }\n"
  code += "    done = done + r.at(2)\n"
  code += "  }\n"
  code += "  let end-flag = false\n"
  code += "  for r in results.rev() {\n"
  code += "    if not end-flag {\n"
  code += "      let c = normalize-content(r.at(0))\n"
  code += "      if c != [] and c != none and c != \"\" { end-flag = r.at(3, default: false) }\n"
  code += "    }\n"
  code += "  }\n"
  code += "  let merged = if has-var { \"var\" } else if has-no-var { \"no-var\" } else { \"none\" }\n"
  code += "  (contents.join(), merged, done, end-flag)\n"
  code += "}"
  code
}
