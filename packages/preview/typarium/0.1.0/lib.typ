#import "themes/default.typ": default-theme, default-render
#import "themes/terminal.typ": terminal-theme, terminal-render
#import "themes/anatomy.typ": anatomy-theme, anatomy-render
#import "themes/inspector.typ": inspector-theme, inspector-render

#let font-plugin = plugin("font_parser.wasm")

#let _normalize-meta-key(key) = {
  let normalized = key.replace("_", "-")
  if normalized == "type" { "font-type" } else { normalized }
}

#let _normalize-meta-value(value) = {
  if type(value) == dictionary {
    let normalized = (:)
    for (key, entry) in value {
      normalized.insert(_normalize-meta-key(key), _normalize-meta-value(entry))
    }
    normalized
  } else if type(value) == array {
    value.map(entry => _normalize-meta-value(entry))
  } else {
    value
  }
}

#let _is-font-path(value) = type(value) == str and value.match(regex("(?i)\.(ttf|otf|ttc|otc)$")) != none

#let _extract-font-source(item) = {
  if type(item) == str and _is-font-path(item) {
    item
  } else if type(item) == bytes {
    item
  } else if type(item) == dictionary {
    let source = item.at("path", default: none)
    if type(source) in (str, bytes) { source } else { none }
  } else {
    none
  }
}

#let _parse-font-file(source) = {
  let raw-bytes = if type(source) == bytes { source } else { read(source, encoding: none) }
  let json-bytes = font-plugin.extract_metadata(raw-bytes)
  _normalize-meta-value(json(json-bytes))
}

#let variable-font-support = (
  native: false,
  mode: "metadata-only",
  note: "Typst 0.14.x does not currently apply variable font axes during shaping.",
)

#let _normalize-variation-key(key) = lower(str(key))

#let _normalize-variation-values(values) = {
  if type(values) == dictionary {
    let normalized = (:)
    for (key, value) in values {
      normalized.insert(_normalize-variation-key(key), value)
    }
    normalized
  } else {
    (:)
  }
}

#let set-variations(target, values) = {
  let normalized = _normalize-variation-values(values)
  if type(target) == dictionary {
    target + (variation-values: normalized)
  } else if type(target) == str {
    if _is-font-path(target) {
      (path: target, variation-values: normalized)
    } else {
      (name: target, variation-values: normalized)
    }
  } else if type(target) == bytes {
    (path: target, variation-values: normalized)
  } else {
    (variation-values: normalized)
  }
}

#let _axis-normalized-value(axis, value) = {
  let min = axis.at("min-value", default: none)
  let def = axis.at("default-value", default: none)
  let max = axis.at("max-value", default: none)
  if min == none or def == none or max == none {
    none
  } else if value == def {
    0.0
  } else if value < def and def != min {
    (value - def) / (def - min)
  } else if value > def and max != def {
    (value - def) / (max - def)
  } else {
    none
  }
}

#let _resolve-variation-request(meta, resolved-theme) = {
  let values = if type(meta.at("variation-values", default: none)) == dictionary {
    _normalize-variation-values(meta.at("variation-values", default: (:)))
  } else if type(resolved-theme.at("variation-values", default: none)) == dictionary {
    _normalize-variation-values(resolved-theme.at("variation-values", default: (:)))
  } else {
    (:)
  }
  let parsed = if type(meta.at("variations", default: none)) == dictionary { meta.at("variations", default: (:)) } else { (:) }
  let axes = if type(parsed.at("axes", default: none)) == array { parsed.at("axes", default: ()) } else { () }
  let matched-axes = ()
  let unmatched-tags = ()

  for (tag, value) in values {
    let match = none
    for axis in axes {
      if lower(str(axis.at("tag", default: ""))) == _normalize-variation-key(tag) {
        match = axis
      }
    }
    if match == none {
      unmatched-tags.push(_normalize-variation-key(tag))
    } else {
      matched-axes.push(match + (requested-value: value, requested-normalized: _axis-normalized-value(match, value)))
    }
  }

  (
    values: values,
    matched-axes: matched-axes,
    unmatched-tags: unmatched-tags,
    parsed-axis-count: axes.len(),
    native-support: variable-font-support.native,
    applied-in-font-text: false,
    mode: variable-font-support.mode,
    note: variable-font-support.note,
  )
}

#let _resolve-font-meta(item, default-props, context-font, parsed-cache) = {
  let is-str = type(item) == str
  let is-dict = type(item) == dictionary
  let source = _extract-font-source(item)
  let has-font-source = source != none
  let path = if type(source) == str { source } else { none }
  let item-overrides = (:)

  let fallback-name = if type(context-font) == array { context-font.first() } else { context-font }
  let meta-from-wasm = if type(source) == str and source in parsed-cache {
    parsed-cache.at(source)
  } else if type(source) == bytes {
    _parse-font-file(source)
  } else {
    (:)
  }

  let merged = default-props + (
    path: path,
    render-name: meta-from-wasm.at("name", default: fallback-name),
    name: none,
    weight: "regular",
    style: "normal",
  )

  if meta-from-wasm != (:) {
    for (key, value) in meta-from-wasm {
      merged.insert(key, value)
    }
  }

  if is-str and not has-font-source {
    merged.render-name = item
    merged.name = item
  } else if is-dict {
    if has-font-source {
      merged.name = item.at("name", default: merged.render-name)
    } else {
      merged.render-name = item.at("name", default: fallback-name)
      merged.name = item.at("display-name", default: merged.render-name)
    }

    for (key, value) in item {
      if key != "path" {
        let normalized-key = _normalize-meta-key(key)
        let normalized-value = _normalize-meta-value(value)
        merged.insert(normalized-key, normalized-value)
        item-overrides.insert(normalized-key, normalized-value)
      }
    }
  }

  if merged.name == none { merged.name = merged.render-name }
  merged.item-overrides = item-overrides
  merged
}

#let font-showcase(
  fonts: auto,
  theme: (:),
  render: auto,
  columns: 1,
) = context {
  let current-font = text.font
  let normalized-theme = if type(theme) == dictionary { _normalize-meta-value(theme) } else { (:) }
  let base-theme = if type(render) == function { normalized-theme } else { default-theme + normalized-theme }
  let target-fonts = if fonts == auto { current-font } else { fonts }
  if type(target-fonts) in (str, bytes, dictionary) { target-fonts = (target-fonts,) }
  let default-props = (column-count: columns)

  let parsed-cache = (:)
  for item in target-fonts {
    let source = _extract-font-source(item)
    if type(source) == str and not (source in parsed-cache) {
      parsed-cache.insert(source, _parse-font-file(source))
    }
  }

  let active-render = if type(render) == function { render } else { default-render }

  grid(
    columns: (1fr,) * columns,
    column-gutter: base-theme.at("grid-column-gutter", default: 1.6em),
    row-gutter: base-theme.at("grid-row-gutter", default: 0em),
    ..target-fonts.map(item => {
      let meta = _resolve-font-meta(item, default-props, current-font, parsed-cache)
      let item-theme = if type(meta.at("theme", default: (:))) == dictionary { meta.at("theme", default: (:)) } else { (:) }
      let resolved-theme = base-theme + item-theme
      let sample-fallback = meta.at("sample-fallback", default: resolved-theme.at("sample-fallback", default: true))
      let features = if type(meta.at("features", default: none)) == dictionary {
        meta.at("features", default: (:))
      } else if type(resolved-theme.at("features", default: none)) == dictionary {
        resolved-theme.at("features", default: (:))
      } else {
        (:)
      }
      let lang = meta.at("lang", default: resolved-theme.at("lang", default: auto))
      let script = meta.at("script", default: resolved-theme.at("script", default: auto))
      let variation-request = _resolve-variation-request(meta, resolved-theme)
      let text-options = (
        font: meta.render-name,
        weight: meta.weight,
        style: meta.style,
        fallback: sample-fallback,
      )
      if features != (:) {
        text-options.insert("features", features)
      }
      if lang != auto and lang != none {
        text-options.insert("lang", lang)
      }
      if script != auto and script != none {
        text-options.insert("script", script)
      }

      let font-text = text.with(..text-options)
      let it = meta + (
        item-overrides: meta.at("item-overrides", default: (:)),
        sample-fallback: sample-fallback,
        features: features,
        lang: lang,
        script: script,
        font-text: font-text,
        variation-request: variation-request,
        variation-support: variable-font-support,
        theme: resolved-theme,
      )
      active-render(it)
    })
  )
}
