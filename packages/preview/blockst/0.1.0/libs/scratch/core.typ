// core.typ — Scratch block renderer with full localisation
// Imports mod.typ for rendering functions, uses the nested registry
// and translation files from lang/translations/.

#import "mod.typ": *
#import "registry.typ": REGISTRY
#import "category-map.typ": CATEGORY_MAP
#let _TRANS_DE = toml("lang/translations/de.toml")
#let _TRANS_EN = toml("lang/translations/en.toml")
#let _TRANS_FR = toml("lang/translations/fr.toml")

// Internal helper: split block ID into group key and block key
#let _split-id(id) = {
  let parts = id.split(".")
  let group = parts.first()
  let key = parts.slice(1).join(".")
  (group, key)
}

// Helper: look up the localised text string from translation files
#let get-template(id, lang-code) = {
  let (group, key) = _split-id(id)
  let trans = if lang-code == "en" { _TRANS_EN } else if lang-code == "fr" { _TRANS_FR } else { _TRANS_DE }
  let value = trans.at(group, default: (:)).at(key, default: none)
  if value == none {
    // Fallback: German translation, then raw ID
    _TRANS_DE.at(group, default: (:)).at(key, default: id)
  } else {
    value
  }
}

// Helper: render a pill for a block argument slot
#let make-pill(key, value, colors, shape: none) = {
  let stroke-thickness = get-stroke-from-options(scratch-block-options.get())
  
  // Dropdown-Felder (typischerweise Strings in Rechteck-Pills)
  let dropdown-keys = ("to", "scene", "costume", "backdrop", "effect", "sound", "key", "object", "property", "timeunit", "layer", "direction", "variable", "list", "clone", "option", "mode", "style", "element", "operator", "towards", "param")
  
  // Condition fields (for boolean operators: and, or, not, and direct condition slots)
  let condition-keys = ("operand", "operand1", "operand2", "condition")
  
  // inline: true for reporters/booleans, inline: false for stack blocks
  let use-inline = shape in ("reporter", "boolean")

  if key in dropdown-keys and type(value) == str {
    pill-rect(value, fill: colors.primary, stroke: colors.tertiary + stroke-thickness, dropdown: true, inline: use-inline)
  } else if key in ("color", "color1", "color2") {
    pill-color("        ", fill: value)
  } else if key in condition-keys and (value == none or value == []) {
    // Empty condition → dark placeholder with nested: true for smaller insets
    condition(colorschema: colors, type: "condition", [], nested: true)
  } else {
    number-or-content(value, colors)
  }
}

// Hilfsfunktion: Ersetze Platzhalter in Templates - UNIVERSELLE VERSION
#let fill-template(template, args, colors, shape: none) = {
  // Icon-Definitionen aus scratch.typ
  let flag-icon = box(baseline: 20%, image(icons.green-flag, width: 1em, height: 1em))
  let arrow-right = box(baseline: 20%, image(icons.rotate-right, width: 1.5em, height: 1.5em))
  let arrow-left = box(baseline: 20%, image(icons.rotate-left, width: 1.5em, height: 1.5em))
  let pen-icon = box(baseline: 20%, image(icons.pen, width: 1.5em, height: 1.5em))
  
  // Einfache Templates ohne Platzhalter
  if not template.contains("{") {
    // Plain text without placeholder — add inset for reporter context
    if shape in ("reporter", "boolean") and template.len() > 0 {
      return box(inset: (left: 2mm, right: 2mm), template)
    }
    return template
  }
  
  // Verwende split() statt manueller Iteration
  let parts = ()
  let remaining = template
  let is-first-text = true
  
  while remaining.contains("{") {
    // Finde Position von {
    let before-split = remaining.split("{")
    if before-split.len() < 2 {
      // Kein { gefunden
      if remaining.len() > 0 {
        let text = remaining
        // Letzter Text-Teil - nur right Inset
        if shape in ("reporter", "boolean") and text.len() > 0 {
          parts.push(box(inset: (right: 2mm), text))
        } else {
          parts.push(text)
        }
      }
      break
    }
    
    // Text vor {
    if before-split.at(0).len() > 0 {
      let text = before-split.at(0)
      // Erster Text-Teil - nur left Inset
      if shape in ("reporter", "boolean") and text.len() > 0 {
        if is-first-text {
          parts.push(box(inset: (left: 2mm), text))
          is-first-text = false
        } else {
          parts.push(text)
        }
      } else {
        parts.push(text)
        is-first-text = false
      }
    } else {
      is-first-text = false
    }
    
    // Rest nach {
    let after-open = before-split.slice(1).join("{")
    
    // Finde }
    let inside-split = after-open.split("}")
    if inside-split.len() < 2 {
      // Kein } gefunden - als Text behandeln
      parts.push("{" + after-open)
      break
    }
    
    // Platzhalter-Name
    let placeholder = inside-split.at(0)
    
    // Ersetze bekannte Platzhalter
    if placeholder == "flag" {
      parts.push(flag-icon)
    } else if placeholder == "arrow-right" {
      parts.push(arrow-right)
    } else if placeholder == "arrow-left" {
      parts.push(arrow-left)
    } else if placeholder == "pen" {
      parts.push(pen-icon)
    } else if placeholder in args {
      parts.push(make-pill(placeholder, args.at(placeholder), colors, shape: shape))
    } else {
      // Unbekannter Platzhalter - als Text behalten
      parts.push("{" + placeholder + "}")
    }
    
    // Weiter mit dem Rest
    remaining = inside-split.slice(1).join("}")
  }
  
  // Append remaining text segment
  if remaining.len() > 0 and not remaining.contains("{") {
    // Letzter Text-Teil - nur right Inset
    if shape in ("reporter", "boolean") and remaining.len() > 0 {
      parts.push(box(inset: (right: 2mm), remaining))
    } else {
      parts.push(remaining)
    }
  }
  
  // No parts: return raw template string
  if parts.len() == 0 {
    return template
  }
  
  // Single part: return directly
  if parts.len() == 1 {
    return parts.at(0)
  }
  
  // Build stack of all parts with adjusted spacing for reporter context
  let final-spacing = if shape in ("reporter", "boolean") { 0.75mm } else { 1.5mm }
  return stack(dir: ltr, spacing: final-spacing, ..parts)
}

// Hilfsfunktion: Hole Block-Info aus verschachtelter Registry
#let get-block-info(id) = {
  let (group, key) = _split-id(id)
  let entry = REGISTRY.at(group, default: (:)).at(key, default: none)
  if entry == none {
    (shape: "stack", category: "control")
  } else {
    // Kategorie aus explizitem Feld (nur data-Gruppe) oder aus CATEGORY_MAP ableiten
    let category = entry.at("category", default: CATEGORY_MAP.at(group, default: "control"))
    (shape: entry.at("shape", default: "stack"), category: category)
  }
}

// Central block rendering function with localisation
// NOTE: This function should only be used for simple template-based blocks.
// Complex blocks (operators, reporters, c-blocks) use the original functions from mod.typ.
#let render-block(id, args: (:), lang-code: str, body: [], else-body: none) = context {
  // Normalise language code
  let l = if lang-code == "auto" { "de" } else { lang-code }
  
  // Read options and colours
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  
  // Hole Block-Info aus Registry
  let info = get-block-info(id)
  let category = info.at("category", default: "control")
  let shape = info.at("shape", default: "stack")
  let template = get-template(id, l)
  
  // Kategorie → Farb-Schema: colors hat gleichnamige Felder für alle Kategorien
  let color = colors.at(category, default: colors.control)

  // Custom block definition carries a label-render function, not a normal template value.
  // Handle it before generic template filling to avoid treating functions as inline content.
  if id == "custom.define" {
    let label-func = args.at("label", default: none)
    let define-verb = get-template("custom.define_label", l)
    if label-func != none {
      return define(label-func, verb: define-verb, body)
    }
  }
  
  // Fill template with arguments
  let content = fill-template(template, args, color, shape: shape)

  // Special cases: Control blocks with special shapes.
  // Labels are sourced from the translation system so controls.typ stays language-neutral.
  if id == "control.if_else" or id == "control.if" {
    let cond = if "condition" in args { args.condition } else { condition(colorschema: colors.operators, []) }
    let tmpl-if   = get-template("control.if_label", l)
    let tmpl-then = get-template("control.then", l)
    let tmpl-else = get-template("control.else", l)
    let lbl = ("if-then": tmpl-if, then: tmpl-then, "else": tmpl-else)
    return if-then-else(cond, then: body, else-body: if id == "control.if_else" { else-body } else { none }, labels: lbl)
  } else if id == "control.repeat" {
    let times = if "times" in args { args.times } else { 10 }
    let lbl = (repeat: get-template("control.repeat_label", l), times: get-template("control.times_label", l))
    return repeat(count: times, body: body, labels: lbl)
  } else if id == "control.forever" {
    let lbl = (forever: get-template("control.forever_label", l))
    return repeat-forever(body, labels: lbl)
  } else if id == "control.repeat_until" {
    let cond = if "condition" in args { args.condition } else { condition(colorschema: colors.operators, []) }
    let lbl = ("repeat-until": get-template("control.repeat_until_label", l))
    return repeat-until(cond, body: body, labels: lbl)
  } else if id == "control.start_as_clone" {
    let lbl = get-template("control.start_as_clone", l)
    return when-i-start-as-clone(body, label: lbl)
  }
  
  // Custom block definition without label function falls back to filled content.
  if id == "custom.define" {
    let define-verb = get-template("custom.define_label", l)
    return define(content, verb: define-verb, body)
  }

  // Monitor widgets (not regular scratch blocks)
  if shape == "monitor-variable" {
    let name  = args.at("name", default: "Variable")
    let value = args.at("value", default: 0)
    return variable-monitor(name: name, value: value)
  } else if shape == "monitor-list" {
    let name         = args.at("name", default: "List")
    let items        = args.at("items", default: ())
    let width        = args.at("width", default: 4cm)
    let height       = args.at("height", default: auto)
    let length-label = get-template("data.length_label", l)
    return list-monitor(name: name, items: items, width: width, height: height, length-label: length-label)
  }

  // Render based on shape
  if shape == "hat" {
    // Event blocks
    event(content, body)
  } else if shape == "reporter" {
    // Value reporters — dispatch via dictionary to avoid long if/else chains
    let reporter-dispatch = (
      motion:    motion-reporter,
      looks:     looks-reporter,
      sound:     sound-reporter,
      pen:       pen-reporter,
      sensing:   sensing-reporter,
      variables: variables-reporter,
      lists:     lists-reporter,
      custom:    custom-reporter,
    )
    if category in reporter-dispatch {
      (reporter-dispatch.at(category))(content)
    } else {
      // operators and any unknown category → plain pill
      pill-reporter(content, fill: color.primary, stroke: color.tertiary + stroke-thickness)
    }
  } else if shape == "input" {
    // Custom input (variable reporter)
    variables-reporter(args.at("text", default: ""))

  } else if shape == "boolean" {
    // Boolean reporters (diamond shape)
    condition(colorschema: color, content)
  } else {
    // Stack blocks — dispatch via dictionary
    let stack-dispatch = (
      motion:    motion,
      looks:     looks,
      sound:     sound,
      pen:       pen,
      control:   control,
      sensing:   sensing,
      variables: variables,
      lists:     lists,
      custom:    custom,
    )
    if category in stack-dispatch {
      (stack-dispatch.at(category))(content)
    } else if category == "events" {
      // Event category as stack block (e.g. broadcast)
      scratch-block(colorschema: color, type: "statement", content)
    } else {
      control(content)
    }
  }
}

// Public API for language alias files
// This function is called by lang/de.typ, lang/en.typ etc.
#let block(id, args: (:), lang-code: "auto", body: [], else-body: none) = {
  render-block(id, args: args, lang-code: lang-code, body: body, else-body: else-body)
}
