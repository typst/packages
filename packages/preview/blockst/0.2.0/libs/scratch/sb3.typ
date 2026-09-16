// sb3.typ — Typst-side helpers for direct SB3 import via plugin()

#import "text/parser.typ": render-scratch-text as _render-scratch-generic
#import "monitors.typ": list-monitor, variable-monitor

#let _error-prefix = "ERROR:"
#let _default-sb3-plugin = plugin("plugins/sb3_wasm.wasm")

#let _check-plugin-output(text) = {
  if text.starts-with(_error-prefix) {
    panic("SB3 plugin failed: " + text)
  }
  text
}

#let _resolve-plugin(sb3-plugin: auto) = {
  if sb3-plugin == auto {
    _default-sb3-plugin
  } else {
    sb3-plugin
  }
}

#let _normalize-language(language) = {
  if type(language) != str {
    panic("sb3 helpers: language must be a string (supported: en, de, fr).")
  }

  let normalized = language.trim()
  if normalized in ("en", "de", "fr") {
    normalized
  } else {
    panic("sb3 helpers: unsupported language `" + language + "` (supported: en, de, fr).")
  }
}

#let _normalize-target(target) = {
  if target == auto {
    return (mode: "all")
  }

  if type(target) != str {
    panic("sb3 helpers: target must be a string or auto.")
  }

  let normalized = target.trim()
  if normalized == "" {
    panic("sb3 helpers: target must not be empty.")
  }

  if (
    normalized
      in (
        "stage",
        "Stage",
        "scene",
        "Scene",
        "buehne",
        "Buehne",
        "bühne",
        "Bühne",
      )
  ) {
    (mode: "stage")
  } else {
    (mode: "name", value: normalized)
  }
}

#let _matches-target(item, target-filter) = {
  if target-filter.mode == "all" {
    true
  } else if target-filter.mode == "stage" {
    item.is_stage
  } else {
    item.target_name == target-filter.value
  }
}

#let _resolve-show-headers(show-headers, target-filter) = {
  if show-headers == auto {
    target-filter.mode == "all"
  } else if type(show-headers) == bool {
    show-headers
  } else {
    panic("render-sb3-scripts: show-headers must be a boolean or auto.")
  }
}

#let _resolve-show-target-headers(show-target-headers, target-filter) = {
  if show-target-headers == auto {
    target-filter.mode == "all"
  } else if type(show-target-headers) == bool {
    show-target-headers
  } else {
    panic("render-sb3-lists/render-sb3-variables: show-target-headers must be a boolean or auto.")
  }
}

#let _normalize-target-script-number(target-script-number) = {
  if target-script-number == auto {
    return auto
  }

  if type(target-script-number) != int or target-script-number < 1 {
    panic("render-sb3-scripts: target-script-number must be an integer >= 1.")
  }

  target-script-number
}

#let _normalize-target-list-number(target-list-number) = {
  if target-list-number == auto {
    return auto
  }

  if type(target-list-number) != int or target-list-number < 1 {
    panic("render-sb3-lists: target-list-number must be an integer >= 1.")
  }

  target-list-number
}

#let _normalize-target-list-name(target-list-name) = {
  if target-list-name == auto {
    return auto
  }

  if type(target-list-name) != str {
    panic("render-sb3-lists: target-list-name must be a string.")
  }

  let normalized = target-list-name.trim()
  if normalized == "" {
    panic("render-sb3-lists: target-list-name must not be empty.")
  }

  normalized
}

#let _normalize-target-variable-number(target-variable-number) = {
  if target-variable-number == auto {
    return auto
  }

  if type(target-variable-number) != int or target-variable-number < 1 {
    panic("render-sb3-variables: target-variable-number must be an integer >= 1.")
  }

  target-variable-number
}

#let _normalize-target-variable-name(target-variable-name) = {
  if target-variable-name == auto {
    return auto
  }

  if type(target-variable-name) != str {
    panic("render-sb3-variables: target-variable-name must be a string.")
  }

  let normalized = target-variable-name.trim()
  if normalized == "" {
    panic("render-sb3-variables: target-variable-name must not be empty.")
  }

  normalized
}

#let _normalize-image-number(image-number) = {
  if image-number == auto or image-number == none {
    return auto
  }

  if type(image-number) != int or image-number < 1 {
    panic("sb3-image helpers: image-number must be an integer >= 1.")
  }

  image-number
}

#let _normalize-target-image-number(target-image-number) = {
  if target-image-number == auto or target-image-number == none {
    return auto
  }

  if type(target-image-number) != int or target-image-number < 1 {
    panic("sb3-image helpers: target-image-number must be an integer >= 1.")
  }

  target-image-number
}

#let _normalize-image-name(image-name) = {
  if image-name == auto or image-name == none {
    return auto
  }

  if type(image-name) != str {
    panic("sb3-image helpers: image-name must be a string.")
  }

  let normalized = image-name.trim()
  if normalized == "" {
    panic("sb3-image helpers: image-name must not be empty.")
  }

  normalized
}

#let _normalize-include-parser-text(include-parser-text) = {
  if type(include-parser-text) != bool {
    panic("sb3-scripts-catalog: include-parser-text must be a boolean.")
  }
  include-parser-text
}

#let _strip-script-header(script-text) = {
  let normalized = script-text.replace("\r", "")
  let lines = normalized.split("\n")
  if lines.len() == 0 {
    return normalized.trim()
  }

  let first = lines.at(0).trim()
  if first.starts-with("// [") {
    if lines.len() == 1 {
      ""
    } else {
      lines.slice(1).join("\n").trim()
    }
  } else {
    normalized.trim()
  }
}

#let _compact-variables(target) = {
  let out = ()
  let variables = target.at("variables", default: (:))
  for id in variables.keys() {
    let raw = variables.at(id)
    let name = if type(raw) == array and raw.len() > 0 { raw.at(0) } else { "" }
    let value = if type(raw) == array and raw.len() > 1 { raw.at(1) } else { none }
    out.push((
      id: id,
      name: name,
      value: value,
    ))
  }
  out
}

#let _compact-lists(target) = {
  let out = ()
  let lists = target.at("lists", default: (:))
  for id in lists.keys() {
    let raw = lists.at(id)
    let name = if type(raw) == array and raw.len() > 0 { raw.at(0) } else { "" }
    let values = if type(raw) == array and raw.len() > 1 { raw.at(1) } else { () }
    out.push((
      id: id,
      name: name,
      values: values,
    ))
  }
  out
}

#let _compact-target-state(target) = {
  let is-stage = target.at("isStage", default: false)

  let stage-props = if is-stage {
    (
      current_costume: target.at("currentCostume", default: none),
      volume: target.at("volume", default: none),
      tempo: target.at("tempo", default: none),
      video_state: target.at("videoState", default: none),
      video_transparency: target.at("videoTransparency", default: none),
      text_to_speech_language: target.at("textToSpeechLanguage", default: none),
    )
  } else {
    none
  }

  let sprite-props = if not is-stage {
    (
      x: target.at("x", default: none),
      y: target.at("y", default: none),
      direction: target.at("direction", default: none),
      size: target.at("size", default: none),
      visible: target.at("visible", default: none),
      rotation_style: target.at("rotationStyle", default: none),
      draggable: target.at("draggable", default: none),
      current_costume: target.at("currentCostume", default: none),
      volume: target.at("volume", default: none),
    )
  } else {
    none
  }

  (
    name: target.at("name", default: "Unnamed Target"),
    is_stage: is-stage,
    variables: _compact-variables(target),
    lists: _compact-lists(target),
    stage_props: stage-props,
    sprite_props: sprite-props,
  )
}

#let _pick-target-script(filtered-scripts, target-script-number) = {
  let matches = ()
  for item in filtered-scripts {
    if item.local_number == target-script-number {
      matches.push(item)
    }
  }

  if matches.len() == 0 {
    panic("render-sb3-scripts: target-script-number " + str(target-script-number) + " does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("render-sb3-scripts: target-script-number is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _group-scripts-by-target(scripts) = {
  let groups = ()

  for item in scripts {
    let matching-groups = ()
    for group in groups {
      if group.target_name == item.target_name and group.is_stage == item.is_stage {
        matching-groups.push(group)
      }
    }

    if matching-groups.len() == 0 {
      groups.push((
        target_name: item.target_name,
        target_kind: item.target_kind,
        is_stage: item.is_stage,
      ))
    }
  }

  let out = ()
  for group in groups {
    let group-scripts = ()
    for item in scripts {
      if item.target_name == group.target_name and item.is_stage == group.is_stage {
        group-scripts.push(item)
      }
    }

    out.push((
      target_name: group.target_name,
      target_kind: group.target_kind,
      is_stage: group.is_stage,
      scripts: group-scripts,
    ))
  }

  out
}

#let _flatten-grouped-scripts(grouped-catalog) = {
  let out = ()
  for group in grouped-catalog {
    for item in group.scripts {
      out.push(item)
    }
  }
  out
}

#let _pick-target-list(target-states, target-list-number) = {
  let matches = ()
  for target-state in target-states {
    let local-number = 1
    for list-item in target-state.lists {
      if local-number == target-list-number {
        matches.push((
          target_state: target-state,
          list_item: list-item,
          local_number: local-number,
        ))
      }
      local-number += 1
    }
  }

  if matches.len() == 0 {
    panic("render-sb3-lists: target-list-number " + str(target-list-number) + " does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("render-sb3-lists: target-list-number is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _pick-target-list-by-name(target-states, target-list-name) = {
  let matches = ()
  for target-state in target-states {
    let local-number = 1
    for list-item in target-state.lists {
      if list-item.name == target-list-name {
        matches.push((
          target_state: target-state,
          list_item: list-item,
          local_number: local-number,
        ))
      }
      local-number += 1
    }
  }

  if matches.len() == 0 {
    panic("render-sb3-lists: target-list-name `" + target-list-name + "` does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("render-sb3-lists: target-list-name is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _pick-target-variable(target-states, target-variable-number) = {
  let matches = ()
  for target-state in target-states {
    let local-number = 1
    for variable-item in target-state.variables {
      if local-number == target-variable-number {
        matches.push((
          target_state: target-state,
          variable_item: variable-item,
          local_number: local-number,
        ))
      }
      local-number += 1
    }
  }

  if matches.len() == 0 {
    panic("render-sb3-variables: target-variable-number " + str(target-variable-number) + " does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("render-sb3-variables: target-variable-number is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _pick-target-variable-by-name(target-states, target-variable-name) = {
  let matches = ()
  for target-state in target-states {
    let local-number = 1
    for variable-item in target-state.variables {
      if variable-item.name == target-variable-name {
        matches.push((
          target_state: target-state,
          variable_item: variable-item,
          local_number: local-number,
        ))
      }
      local-number += 1
    }
  }

  if matches.len() == 0 {
    panic("render-sb3-variables: target-variable-name `" + target-variable-name + "` does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("render-sb3-variables: target-variable-name is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _pick-image-by-number(images, image-number) = {
  let matches = ()
  for item in images {
    if item.number == image-number {
      matches.push(item)
    }
  }

  if matches.len() == 0 {
    panic("sb3-image helpers: image-number " + str(image-number) + " does not exist.")
  }

  if matches.len() > 1 {
    panic("sb3-image helpers: image-number is ambiguous.")
  }

  matches.at(0)
}

#let _pick-target-image-by-number(images, target-image-number) = {
  let matches = ()
  for item in images {
    if item.local_number == target-image-number {
      matches.push(item)
    }
  }

  if matches.len() == 0 {
    panic("sb3-image helpers: target-image-number " + str(target-image-number) + " does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("sb3-image helpers: target-image-number is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _pick-image-by-name(images, image-name) = {
  let matches = ()
  for item in images {
    if item.asset_name == image-name {
      matches.push(item)
    }
  }

  if matches.len() == 0 {
    panic("sb3-image helpers: image-name `" + image-name + "` does not exist for the selected target.")
  }

  if matches.len() > 1 {
    panic("sb3-image helpers: image-name is ambiguous for the selected target filter.")
  }

  matches.at(0)
}

#let _image-format-for-typst(item) = {
  let format = item.data_format
  if format in ("png", "jpg", "jpeg", "svg") {
    format
  } else {
    panic("sb3-image helpers: unsupported image format `" + format + "`.")
  }
}

#let _image-from-bytes(data, format, width: auto, height: auto) = {
  if width == auto and height == auto {
    std.image(data, format: format)
  } else if width != auto and height == auto {
    std.image(data, format: format, width: width)
  } else if width == auto and height != auto {
    std.image(data, format: format, height: height)
  } else {
    std.image(data, format: format, width: width, height: height)
  }
}

#let _as-number(value, fallback) = {
  if type(value) == int or type(value) == float {
    value
  } else {
    fallback
  }
}

#let _pick-current-target-image(images, target-name, current-costume) = {
  let local-number = _as-number(current-costume, 0) + 1

  for item in images {
    if item.target_name == target-name and item.local_number == local-number {
      return item
    }
  }

  for item in images {
    if item.target_name == target-name {
      return item
    }
  }

  auto
}

#let _ui-labels(language) = {
  if language == "de" {
    (
      no-scripts: "Keine Top-Level-Skripte in dieser sb3 gefunden.",
      no-target-scripts: "Keine Top-Level-Skripte fuer den gewaehlten Ziel-Filter gefunden.",
      no-lists: "Keine Listen fuer den gewaehlten Ziel-Filter gefunden.",
      no-variables: "Keine Variablen für den gewaehlten Ziel-Filter gefunden.",
      stage: "Bühne (Hintergrund)",
      sprite: "Figur",
      script: "Skript",
      list: "Liste",
      variable: "Variable",
      values: "Werte",
      value: "Wert",
      length: "Länge",
    )
  } else if language == "fr" {
    (
      no-scripts: "Aucun script de premier niveau trouve dans ce sb3.",
      no-target-scripts: "Aucun script de premier niveau ne correspond au filtre cible.",
      no-lists: "Aucune liste ne correspond au filtre cible.",
      no-variables: "Aucune variable ne correspond au filtre cible.",
      stage: "Scene (Arriere-plan)",
      sprite: "Lutin",
      script: "Script",
      list: "Liste",
      variable: "Variable",
      values: "Valeurs",
      value: "Valeur",
      length: "longueur",
    )
  } else {
    (
      no-scripts: "No top-level scripts found in this sb3.",
      no-target-scripts: "No top-level scripts match the selected target filter.",
      no-lists: "No lists match the selected target filter.",
      no-variables: "No variables match the selected target filter.",
      stage: "Stage (Backdrop)",
      sprite: "Sprite",
      script: "Script",
      list: "List",
      variable: "Variable",
      values: "Values",
      value: "Value",
      length: "Length",
    )
  }
}

#let _target-title(target-state, ui) = {
  let target-kind = if target-state.is_stage { ui.stage } else { ui.sprite }
  [#target-kind: #target-state.name]
}

#let _render-scratch-text-localized(text, language) = {
  // SB3 importer emits English parser text; render via WASM with target UI language.
  _render-scratch-generic(text, lang-code: language)
}

// Returns metadata for top-level scripts with global numbering.
// Optional target filter: stage or exact target name.
// Optional parsed_text field per item (enabled by default).
// Output format: ((target_name: "...", is_stage: true/false, scripts: ((number: 1, ...), ...)), ...)
#let sb3-scripts-catalog(sb3-bytes, target: auto, include-parser-text: true, language: "en", sb3-plugin: auto) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let target-filter = _normalize-target(target)
  let include-parser-text = _normalize-include-parser-text(include-parser-text)
  let text = str(active-plugin.sb3_scripts_catalog_json(sb3-bytes, bytes(language)))
  let catalog = json(bytes(_check-plugin-output(text)))

  let filtered = ()
  for item in catalog.scripts {
    if _matches-target(item, target-filter) {
      filtered.push(item)
    }
  }

  if not include-parser-text {
    return _group-scripts-by-target(filtered)
  }

  let enriched = ()
  for item in filtered {
    let parser-text = _strip-script-header(_check-plugin-output(str(
      active-plugin.sb3_to_scratch_text_by_number(sb3-bytes, bytes(str(item.number)), bytes(language)),
    )))
    enriched.push((
      number: item.number,
      local_number: item.local_number,
      target_name: item.target_name,
      target_kind: item.target_kind,
      is_stage: item.is_stage,
      parsed_text: parser-text,
    ))
  }

  _group-scripts-by-target(enriched)
}

// Returns compact state snapshots per target.
// Includes variables, lists, and stage/sprite properties.
// Optional target filter: stage or exact target name.
// Output format: ((name: "...", is_stage: true/false, ...), ...)
#let sb3-state-catalog(sb3-bytes, target: auto, sb3-plugin: auto) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let target-filter = _normalize-target(target)
  let project = json(bytes(_check-plugin-output(str(active-plugin.extract_project_json(sb3-bytes)))))

  let target-states = ()
  for target in project.targets {
    let match-item = (
      target_name: target.at("name", default: "Unnamed Target"),
      is_stage: target.at("isStage", default: false),
    )
    if _matches-target(match-item, target-filter) {
      target-states.push(_compact-target-state(target))
    }
  }

  target-states
}

// Low-level: convert SB3 bytes to parser text through the plugin.
// script-number is global and 1-based across all targets.
#let sb3-bytes-to-scratch-text(sb3-bytes, script-number: auto, language: "en", sb3-plugin: auto) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let text = if script-number == auto {
    str(active-plugin.sb3_to_scratch_text(sb3-bytes, bytes(language)))
  } else {
    if type(script-number) != int or script-number < 1 {
      panic("render-sb3-scripts: script-number must be an integer >= 1.")
    }
    str(active-plugin.sb3_to_scratch_text_by_number(sb3-bytes, bytes(str(script-number)), bytes(language)))
  }
  _check-plugin-output(text)
}

// Alias for readability in call sites.
#let sb3-to-scratch-text(sb3-bytes, script-number: auto, language: "en", sb3-plugin: auto) = sb3-bytes-to-scratch-text(
  sb3-bytes,
  script-number: script-number,
  language: language,
  sb3-plugin: sb3-plugin,
)

#let _sb3-to-renderable-scratch-text(sb3-bytes, script-number: auto, language: "en", sb3-plugin: auto) = _strip-script-header(
  sb3-to-scratch-text(
    sb3-bytes,
    script-number: script-number,
    language: language,
    sb3-plugin: sb3-plugin,
  ),
)

// Convenience: directly render imported scripts as blockst content.
#let render-sb3-scripts(
  sb3-bytes,
  script-number: auto,
  target-script-number: auto,
  target: auto,
  sb3-plugin: auto,
  language: "en",
  show-headers: auto,
  header-gap: 1.5mm,
  script-gap: 3mm,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let language = _normalize-language(language)
  let target-script-number = _normalize-target-script-number(target-script-number)
  let target-filter = _normalize-target(target)
  let show-headers = _resolve-show-headers(show-headers, target-filter)
  let ui = _ui-labels(language)

  if script-number != auto and target-script-number != auto {
    panic("render-sb3-scripts: script-number cannot be combined with target-script-number.")
  }

  if script-number != auto and target-filter.mode != "all" {
    panic("render-sb3-scripts: target cannot be combined with script-number.")
  }

  if target-script-number != auto and target-filter.mode == "all" {
    panic("render-sb3-scripts: target-script-number requires target.")
  }

  if script-number == auto {
    let catalog = sb3-scripts-catalog(
      sb3-bytes,
      target: target,
      include-parser-text: false,
      sb3-plugin: active-plugin,
    )

    let filtered-scripts = _flatten-grouped-scripts(catalog)

    if filtered-scripts.len() == 0 {
      let empty-message = if target-filter.mode == "all" { ui.no-scripts } else { ui.no-target-scripts }
      return text(size: 9pt, fill: rgb("666666"))[#empty-message]
    }

    if target-script-number != auto {
      let item = _pick-target-script(filtered-scripts, target-script-number)
      return [
        #if show-headers [
          #let target-kind = if item.is_stage { ui.stage } else { ui.sprite }
          #text(weight: "bold", size: 9pt)[#item.number. #target-kind: #item.target_name - #ui.script #item.local_number]
          #v(header-gap)
        ]
        #_render-scratch-text-localized(
          _sb3-to-renderable-scratch-text(
            sb3-bytes,
            script-number: item.number,
            language: language,
            sb3-plugin: active-plugin,
          ),
          language,
        )
      ]
    }

    [
      #for item in filtered-scripts [
        #if show-headers [
          #let target-kind = if item.is_stage { ui.stage } else { ui.sprite }
          #text(weight: "bold", size: 9pt, black)[#item.number. #target-kind: #item.target_name - #ui.script #item.local_number]
          #v(header-gap)
        ]
        #_render-scratch-text-localized(
          _sb3-to-renderable-scratch-text(
            sb3-bytes,
            script-number: item.number,
            language: language,
            sb3-plugin: active-plugin,
          ),
          language,
        )
        #v(script-gap)
      ]
    ]
  } else {
    _render-scratch-text-localized(
      _sb3-to-renderable-scratch-text(
        sb3-bytes,
        script-number: script-number,
        language: language,
        sb3-plugin: active-plugin,
      ),
      language,
    )
  }
}

#let render-sb3-lists(
  sb3-bytes,
  target: auto,
  target-list-name: auto,
  target-list-number: auto,
  sb3-plugin: auto,
  language: "en",
  show-target-headers: auto,
  target-gap: 2mm,
  item-gap: 0.8mm,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let language = _normalize-language(language)
  let target-list-name = _normalize-target-list-name(target-list-name)
  let target-list-number = _normalize-target-list-number(target-list-number)
  let target-filter = _normalize-target(target)
  let show-target-headers = _resolve-show-target-headers(show-target-headers, target-filter)
  let ui = _ui-labels(language)
  let state = sb3-state-catalog(sb3-bytes, target: target, sb3-plugin: active-plugin)

  if target-list-name != auto and target-list-number != auto {
    panic("render-sb3-lists: target-list-name cannot be combined with target-list-number.")
  }

  if (target-list-name != auto or target-list-number != auto) and target-filter.mode == "all" {
    panic("render-sb3-lists: target-list-name/target-list-number requires target.")
  }

  if target-list-name != auto or target-list-number != auto {
    let match = if target-list-name != auto {
      _pick-target-list-by-name(state, target-list-name)
    } else {
      _pick-target-list(state, target-list-number)
    }
    return [
      #if show-target-headers [
        #text(weight: "bold", size: 9pt)[#_target-title(match.target_state, ui)]
        #v(1mm)
      ]
      #list-monitor(name: match.list_item.name, items: match.list_item.values, width: 5.2cm, length-label: ui.length)
    ]
  }

  let total-lists = 0
  for target-state in state {
    total-lists += target-state.lists.len()
  }

  if total-lists == 0 {
    return text(size: 9pt, fill: rgb("666666"))[#ui.no-lists]
  }

  [
    #for target-state in state [
      #if target-state.lists.len() > 0 [
        #if show-target-headers [
          #text(weight: "bold", size: 9pt)[#_target-title(target-state, ui)]
          #v(1mm)
        ]
        #for list-item in target-state.lists [
          #list-monitor(name: list-item.name, items: list-item.values, width: 5.2cm, length-label: ui.length)
          #v(item-gap)
        ]
        #v(target-gap)
      ]
    ]
  ]
}

#let render-sb3-variables(
  sb3-bytes,
  target: auto,
  target-variable-name: auto,
  target-variable-number: auto,
  sb3-plugin: auto,
  language: "en",
  show-target-headers: auto,
  target-gap: 2mm,
  item-gap: 0.8mm,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let language = _normalize-language(language)
  let target-variable-name = _normalize-target-variable-name(target-variable-name)
  let target-variable-number = _normalize-target-variable-number(target-variable-number)
  let target-filter = _normalize-target(target)
  let show-target-headers = _resolve-show-target-headers(show-target-headers, target-filter)
  let ui = _ui-labels(language)
  let state = sb3-state-catalog(sb3-bytes, target: target, sb3-plugin: active-plugin)

  if target-variable-name != auto and target-variable-number != auto {
    panic("render-sb3-variables: target-variable-name cannot be combined with target-variable-number.")
  }

  if (target-variable-name != auto or target-variable-number != auto) and target-filter.mode == "all" {
    panic("render-sb3-variables: target-variable-name/target-variable-number requires target.")
  }

  if target-variable-name != auto or target-variable-number != auto {
    let match = if target-variable-name != auto {
      _pick-target-variable-by-name(state, target-variable-name)
    } else {
      _pick-target-variable(state, target-variable-number)
    }
    return [
      #if show-target-headers [
        #text(weight: "bold", size: 9pt)[#_target-title(match.target_state, ui)]
        #v(1mm)
      ]
      #variable-monitor(name: match.variable_item.name, value: match.variable_item.value)
    ]
  }

  let total-variables = 0
  for target-state in state {
    total-variables += target-state.variables.len()
  }

  if total-variables == 0 {
    return text(size: 9pt, fill: rgb("666666"))[#ui.no-variables]
  }

  [
    #for target-state in state [
      #if target-state.variables.len() > 0 [
        #if show-target-headers [
          #text(weight: "bold", size: 9pt)[#_target-title(target-state, ui)]
          #v(1mm)
        ]
        #for variable-item in target-state.variables [
          #variable-monitor(name: variable-item.name, value: variable-item.value)
          #v(item-gap)
        ]
        #v(target-gap)
      ]
    ]
  ]
}

#let _validate-image-selector-combination(
  image-number,
  target,
  target-image-number,
  image-name,
) = {
  let target-filter = _normalize-target(target)

  if (
    image-number != auto
      and (
        target-filter.mode != "all" or target-image-number != auto or image-name != auto
      )
  ) {
    panic("sb3-image helpers: image-number cannot be combined with target, target-image-number, or image-name.")
  }

  if target-image-number != auto and image-name != auto {
    panic("sb3-image helpers: target-image-number cannot be combined with image-name.")
  }

  if (target-image-number != auto or image-name != auto) and target-filter.mode == "all" {
    panic("sb3-image helpers: target-image-number/image-name requires target.")
  }
}

// Returns flat metadata for supported image assets in the sb3 archive.
// Supported formats: png, jpg, jpeg, svg.
#let sb3-image-assets-catalog(sb3-bytes, target: auto, sb3-plugin: auto) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let target-filter = _normalize-target(target)
  let text = str(active-plugin.sb3_image_assets_catalog_json(sb3-bytes))
  let catalog = json(bytes(_check-plugin-output(text)))

  let filtered = ()
  for item in catalog.images {
    if _matches-target(item, target-filter) {
      filtered.push(item)
    }
  }

  filtered
}

// Alias for readability.
#let sb3-images-catalog(sb3-bytes, target: auto, sb3-plugin: auto) = sb3-image-assets-catalog(
  sb3-bytes,
  target: target,
  sb3-plugin: sb3-plugin,
)

// Returns raw bytes for a selected image asset.
// Selector priority:
// 1) image-number (global)
// 2) target + target-image-number/image-name
// 3) first image in catalog (or first image for target filter)
#let sb3-image-bytes(
  sb3-bytes,
  image-number: auto,
  target: auto,
  target-image-number: auto,
  image-name: auto,
  sb3-plugin: auto,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let image-number = _normalize-image-number(image-number)
  let target-image-number = _normalize-target-image-number(target-image-number)
  let image-name = _normalize-image-name(image-name)
  _validate-image-selector-combination(
    image-number,
    target,
    target-image-number,
    image-name,
  )

  if image-number != auto {
    return active-plugin.sb3_image_bytes_by_number(sb3-bytes, bytes(str(image-number)))
  }

  let images = sb3-image-assets-catalog(sb3-bytes, target: target, sb3-plugin: active-plugin)
  if images.len() == 0 {
    panic("sb3-image helpers: no supported image assets (png/jpg/jpeg/svg) found for the selected target filter.")
  }

  let selected = if target-image-number != auto {
    _pick-target-image-by-number(images, target-image-number)
  } else if image-name != auto {
    _pick-image-by-name(images, image-name)
  } else {
    images.at(0)
  }

  active-plugin.sb3_image_bytes_by_md5ext(sb3-bytes, bytes(selected.md5ext))
}

// Convenience: import one sb3 image and render it directly in Typst.
#let sb3-image(
  sb3-bytes,
  image-number: auto,
  target: auto,
  target-image-number: auto,
  image-name: auto,
  sb3-plugin: auto,
  width: auto,
  height: auto,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let image-number = _normalize-image-number(image-number)
  let target-image-number = _normalize-target-image-number(target-image-number)
  let image-name = _normalize-image-name(image-name)
  _validate-image-selector-combination(
    image-number,
    target,
    target-image-number,
    image-name,
  )

  let all-images = if image-number != auto {
    let images = sb3-image-assets-catalog(sb3-bytes, sb3-plugin: active-plugin)
    if images.len() == 0 {
      panic("sb3-image helpers: no supported image assets (png/jpg/jpeg/svg) found in this sb3.")
    }
    images
  } else {
    ()
  }

  let selected = if image-number != auto {
    _pick-image-by-number(all-images, image-number)
  } else {
    let filtered = sb3-image-assets-catalog(sb3-bytes, target: target, sb3-plugin: active-plugin)
    if filtered.len() == 0 {
      panic("sb3-image helpers: no supported image assets (png/jpg/jpeg/svg) found for the selected target filter.")
    }

    if target-image-number != auto {
      _pick-target-image-by-number(filtered, target-image-number)
    } else if image-name != auto {
      _pick-image-by-name(filtered, image-name)
    } else {
      filtered.at(0)
    }
  }

  let image-bytes = active-plugin.sb3_image_bytes_by_md5ext(sb3-bytes, bytes(selected.md5ext))
  _image-from-bytes(
    image-bytes,
    _image-format-for-typst(selected),
    width: width,
    height: height,
  )
}

// Renders a static preview of the current Scratch screen state from an sb3.
// Uses Stage 480x360 coordinates by default, matching scratch-run.
// Scratch coordinate system: (0,0) = center, x right, y up.
#let sb3-screen-preview(
  sb3-bytes,
  width: 480,
  height: 360,
  unit: 1,
  background: none,
  show-border: true,
  show-backdrop: true,
  monitor-scale: 1.5,
  sb3-plugin: auto,
  language: auto,
) = {
  let active-plugin = _resolve-plugin(sb3-plugin: sb3-plugin)
  let project = json(bytes(_check-plugin-output(str(active-plugin.extract_project_json(sb3-bytes)))))
  let images = sb3-image-assets-catalog(sb3-bytes, sb3-plugin: active-plugin)

  let stage-width = _as-number(width, 480)
  let stage-height = _as-number(height, 360)
  let stage-unit = _as-number(unit, 1)

  // Physical dimensions of the stage box
  let stage-w = stage-width * stage-unit * 1cm / 100
  let stage-h = stage-height * stage-unit * 1cm / 100

  let stage-target = auto
  let sprite-targets = ()
  for target in project.targets {
    if target.at("isStage", default: false) {
      stage-target = target
    } else {
      sprite-targets.push(target)
    }
  }

  let stage-backdrop = auto
  if stage-target != auto {
    let stage-current-costume = _as-number(stage-target.at("currentCostume", default: 0), 0)
    let stage-images = sb3-image-assets-catalog(
      sb3-bytes,
      target: "stage",
      sb3-plugin: active-plugin,
    )
    for item in stage-images {
      if item.local_number == stage-current-costume + 1 {
        stage-backdrop = item
        break
      }
    }
    if stage-backdrop == auto and stage-images.len() > 0 {
      stage-backdrop = stage-images.at(0)
    }
  }

  // Fallback in case a project has unusual stage metadata.
  if stage-backdrop == auto {
    for item in images {
      if item.is_stage {
        stage-backdrop = item
        break
      }
    }
  }

  let visible-sprites = ()
  for target in sprite-targets {
    if target.at("visible", default: true) == true {
      visible-sprites.push(target)
    }
  }

  // Draw lower layer-order sprites first.
  let sprites = ()
  let max-layer-order = 0
  for target in visible-sprites {
    let layer-order = _as-number(target.at("layerOrder", default: 0), 0)
    if layer-order > max-layer-order {
      max-layer-order = layer-order
    }
  }
  for layer in range(max-layer-order + 1) {
    for target in visible-sprites {
      if _as-number(target.at("layerOrder", default: 0), 0) == layer {
        sprites.push(target)
      }
    }
  }
  if sprites.len() == 0 {
    sprites = visible-sprites
  }

  // 1 scratch unit in physical space
  let unit-len = stage-unit * 1cm / 100

  box(
    width: stage-w,
    height: stage-h,
    clip: true,
    stroke: if show-border { 1pt + rgb("e0e0e0") } else { none },
    radius: 2pt,
    inset: 0pt,
    fill: background,
    {
      // Backdrop — scale and position using SVG native size + rotation center
      if show-backdrop and stage-backdrop != auto {
        let backdrop-bytes = active-plugin.sb3_image_bytes_by_md5ext(
          sb3-bytes,
          bytes(stage-backdrop.md5ext),
        )

        // Get costume metadata from stage target for rotationCenter
        let stage-costumes = if stage-target != auto { stage-target.at("costumes", default: ()) } else { () }
        let stage-current-costume = if stage-target != auto { _as-number(stage-target.at("currentCostume", default: 0), 0) } else { 0 }
        let backdrop-costume = if stage-current-costume < stage-costumes.len() {
          stage-costumes.at(stage-current-costume)
        } else {
          none
        }
        let backdrop-bitmap-res = if backdrop-costume != none {
          _as-number(backdrop-costume.at("bitmapResolution", default: 1), 1)
        } else { 1 }
        let backdrop-rot-cx = if backdrop-costume != none {
          _as-number(backdrop-costume.at("rotationCenterX", default: 0), 0)
        } else { 0 }
        let backdrop-rot-cy = if backdrop-costume != none {
          _as-number(backdrop-costume.at("rotationCenterY", default: 0), 0)
        } else { 0 }

        // Logical scale: 1 image/SVG pixel → (unit-len / bitmapRes) in physical space
        let bd-px-scale = unit-len / (backdrop-bitmap-res * 1pt)

        let bd-format = _image-format-for-typst(stage-backdrop)
        let bd-base = _image-from-bytes(backdrop-bytes, bd-format)

        // Typst naturally assigns 0.75pt to 1px for SVGs (96 DPI CSS). For PNGs, it usually defaults to 1pt (72 DPI).
        let bd-intrinsic-scale = if bd-format == "svg" { 0.75pt } else { 1pt }
        let bd-visual-scale = bd-px-scale * (1pt / bd-intrinsic-scale) * 100%
        let bd-scaled = std.scale(
          x: bd-visual-scale,
          y: bd-visual-scale,
          reflow: true,
          bd-base,
        )

        // Position so that rotationCenter lands at stage center (stage-w/2, stage-h/2)
        // dx/dy offsets are calculated in logical pixels
        let bd-dx = stage-w / 2 - backdrop-rot-cx * bd-px-scale * 1pt
        let bd-dy = stage-h / 2 - backdrop-rot-cy * bd-px-scale * 1pt

        place(top + left, dx: bd-dx, dy: bd-dy, bd-scaled)
      }

      // Sprites
      for target in sprites {
        let target-name = target.at("name", default: "Unnamed Sprite")
        let current-costume = _as-number(target.at("currentCostume", default: 0), 0)

        let sprite-meta = _pick-current-target-image(images, target-name, current-costume)
        if sprite-meta == auto { continue }

        let sprite-bytes = active-plugin.sb3_image_bytes_by_md5ext(
          sb3-bytes,
          bytes(sprite-meta.md5ext),
        )

        // Get costume metadata from project JSON for bitmapResolution and rotationCenter
        let costumes = target.at("costumes", default: ())
        let costume = if current-costume < costumes.len() { costumes.at(current-costume) } else { none }
        let bitmap-res = if costume != none { _as-number(costume.at("bitmapResolution", default: 1), 1) } else { 1 }
        let rot-cx = if costume != none { _as-number(costume.at("rotationCenterX", default: 0), 0) } else { 0 }
        let rot-cy = if costume != none { _as-number(costume.at("rotationCenterY", default: 0), 0) } else { 0 }

        let sprite-size = _as-number(target.at("size", default: 100), 100)
        let sprite-direction = _as-number(target.at("direction", default: 90), 90)
        let sprite-x = _as-number(target.at("x", default: 0), 0)
        let sprite-y = _as-number(target.at("y", default: 0), 0)
        let rotation-style = target.at("rotationStyle", default: "all around")

        // Logical Scale factor: map image pixels to physical stage units.
        // In Scratch, 1 costume pixel = 1/bitmapRes scratch units.
        // So: 1 costume pixel should be (unit-len / bitmapRes) in physical space.
        let px-scale = unit-len / (bitmap-res * 1pt)
        let eff-scale = px-scale * (sprite-size / 100)

        let sprite-format = _image-format-for-typst(sprite-meta)
        let base-content = _image-from-bytes(sprite-bytes, sprite-format)

        // Typst renders 1px implicitly as 0.75pt for SVGs, and ~1pt for PNGs without DPI.
        let intrinsic-scale = if sprite-format == "svg" { 0.75pt } else { 1pt }
        let visual-total-pct = px-scale * (sprite-size / 100) * (1pt / intrinsic-scale) * 100%

        let scaled-content = std.scale(
          x: visual-total-pct,
          y: visual-total-pct,
          reflow: true,
          base-content,
        )

        let oriented-content = if rotation-style == "left-right" {
          if sprite-direction < 0 {
            std.scale(x: -100%, y: 100%, reflow: true, scaled-content)
          } else {
            scaled-content
          }
        } else {
          scaled-content
        }

        let final-content = if rotation-style == "all around" {
          std.rotate((sprite-direction - 90) * 1deg, reflow: true, oriented-content)
        } else {
          oriented-content
        }

        // Position: align the costume's rotation center with the sprite's (x, y) on stage.
        // After reflow scaling, the logical rotation center in the image is at:
        //   (rot-cx * eff-scale * 1pt, rot-cy * eff-scale * 1pt) from top-left
        let dx = stage-w / 2 + sprite-x * unit-len - rot-cx * eff-scale * 1pt
        let dy = stage-h / 2 - sprite-y * unit-len - rot-cy * eff-scale * 1pt

        place(top + left, dx: dx, dy: dy, final-content)
      }

      // Monitors
      let monitors = project.at("monitors", default: ())
      let eff-monitor-scale = (unit-len / 1pt) * monitor-scale
      for monitor in monitors {
        if not monitor.at("visible", default: false) { continue }
        let m-x = _as-number(monitor.at("x", default: 0), 0)
        let m-y = _as-number(monitor.at("y", default: 0), 0)
        let m-mode = monitor.at("mode", default: "default")
        let opcode = monitor.at("opcode", default: "")

        let params = monitor.at("params", default: (:))
        let name = params.at("VARIABLE", default: params.at("LIST", default: ""))
        let raw-value = monitor.at("value", default: "0")

        let monitor-box = none

        if m-mode == "default" {
          monitor-box = context variable-monitor(name: name, value: raw-value)
        } else if m-mode == "large" {
          let bg-color = rgb(255, 140, 26) // Scratch orange
          if "list" in opcode { bg-color = rgb(255, 102, 26) }
          let val-str = if type(raw-value) == array { "[List]" } else { str(raw-value) }
          monitor-box = rect(
            fill: bg-color,
            stroke: 1pt + bg-color.darken(10%),
            radius: 3pt,
            inset: (x: 4pt, y: 3pt),
          )[
            #grid(
              columns: 1,
              align: center + horizon,
              box(width: 14pt, height: 0pt),
              text(font: ("Helvetica Neue", "Helvetica", "Arial"), size: 12pt, weight: 500, fill: white, val-str),
            )
          ]
        } else if m-mode == "list" {
          let items = if type(raw-value) == array { raw-value.map(v => str(v)) } else { (str(raw-value),) }
          let w = monitor.at("width", default: 0)
          let h = monitor.at("height", default: 0)
          let kwargs = (:)
          if w > 0 { kwargs.insert("width", w * 1pt * 2 / 3) }
          if h > 0 { kwargs.insert("height", h * 1pt * 2 / 3) }
          monitor-box = context {
            let lang-code = if language == auto { text.lang } else { language }
            let labels = _ui-labels(lang-code)
            list-monitor(name: name, items: items, length-label: labels.length, ..kwargs)
          }
        }

        if monitor-box != none {
          let scaled-box = std.scale(
            x: eff-monitor-scale * 100%,
            y: eff-monitor-scale * 100%,
            reflow: true,
            monitor-box,
          )
          place(top + left, dx: m-x * unit-len, dy: m-y * unit-len, scaled-box)
        }
      }
    },
  )
}
