#let _merman-plugin = plugin("merman_typst_plugin.wasm")

#let _source-text(source) = {
  if type(source) == str {
    source
  } else {
    source.text
  }
}

#let _theme-name(theme-name, base-theme) = {
  if theme-name != none {
    theme-name
  } else {
    base-theme
  }
}

#let _diagram-id(id, diagram-id) = {
  if diagram-id != none {
    diagram-id
  } else {
    id
  }
}

#let _layout-options(
  layout,
  text-measurer,
  math-renderer,
  viewport-width,
  viewport-height,
) = {
  if layout != none {
    layout
  } else {
    (
      viewport_width: viewport-width,
      viewport_height: viewport-height,
      text_measurer: text-measurer,
      math_renderer: math-renderer,
    )
  }
}

#let _scale-factor(factor) = {
  if type(factor) == int or type(factor) == float {
    factor * 100%
  } else {
    factor
  }
}

#let _scaled(body, factor) = {
  if factor == none {
    body
  } else {
    scale(x: _scale-factor(factor), y: _scale-factor(factor), reflow: true, body)
  }
}

#let _error-message(result) = {
  if result.message == none {
    result.code_name
  } else {
    result.message
  }
}

#let _diagram-error(result, error-mode, width) = {
  if error-mode == "text" {
    text(fill: rgb("#b91c1c"))[merman: #_error-message(result)]
  } else if error-mode == "placeholder" {
    block(
      width: width,
      inset: 8pt,
      fill: rgb("#fff7f7"),
      stroke: rgb("#ef4444"),
    )[
      #strong[merman diagram error]
      #linebreak()
      #_error-message(result)
    ]
  } else {
    panic("unknown merman error-mode: " + str(error-mode))
  }
}

#let _site-config(site-config, theme, theme-name, base-theme) = {
  if site-config != none {
    site-config
  } else if theme != none or theme-name != none or base-theme != none {
    (
      theme: _theme-name(theme-name, base-theme),
      themeVariables: theme,
    )
  } else {
    none
  }
}

#let _binding-options(
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  if options != none {
    options
  } else {
    (
      fixed_today: fixed-today,
      fixed_local_offset_minutes: fixed-local-offset-minutes,
      site_config: _site-config(site-config, theme, theme-name, base-theme),
      host_theme: host-theme,
      layout: _layout-options(
        layout,
        text-measurer,
        math-renderer,
        viewport-width,
        viewport-height,
      ),
      svg: (
        diagram_id: _diagram-id(id, diagram-id),
        pipeline: pipeline,
        root_background_color: background,
        scoped_css: scoped-css,
        css_override_policy: css-override-policy,
        drop_native_duplicate_fallbacks: drop-native-duplicate-fallbacks,
      ),
    )
  }
}

#let _options-bytes(options) = {
  if options == none {
    bytes(())
  } else {
    bytes(json.encode(options))
  }
}

#let _render-svg-bytes(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  let source-text = _source-text(source)
  let binding-options = _binding-options(
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  )

  let result = json(_merman-plugin.render_svg_json(bytes(source-text), _options-bytes(binding-options)))
  if result.ok {
    bytes(result.svg)
  } else {
    panic(_error-message(result))
  }
}

#let _render-svg-result(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  let source-text = _source-text(source)
  let binding-options = _binding-options(
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  )

  json(_merman-plugin.render_svg_json(bytes(source-text), _options-bytes(binding-options)))
}

#let _validate-payload(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  let source-text = _source-text(source)
  let binding-options = _binding-options(
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  )

  json(_merman-plugin.validate_json(bytes(source-text), _options-bytes(binding-options)))
}

#let _mermaid-image(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
  width: auto,
  height: auto,
  fit: "contain",
  alt: none,
) = {
  image(
    _render-svg-bytes(
      source,
      options: options,
      site-config: site-config,
      host-theme: host-theme,
      theme: theme,
      theme-name: theme-name,
      base-theme: base-theme,
      pipeline: pipeline,
      id: id,
      diagram-id: diagram-id,
      background: background,
      layout: layout,
      scoped-css: scoped-css,
      css-override-policy: css-override-policy,
      drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
      text-measurer: text-measurer,
      math-renderer: math-renderer,
      viewport-width: viewport-width,
      viewport-height: viewport-height,
      fixed-today: fixed-today,
      fixed-local-offset-minutes: fixed-local-offset-minutes,
    ),
    format: "svg",
    width: width,
    height: height,
    fit: fit,
    alt: alt,
  )
}

#let mermaid-svg(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  str(_render-svg-bytes(
    source,
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  ))
}

#let mermaid-result(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  _render-svg-result(
    source,
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  )
}

#let validate-mermaid(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
) = {
  _validate-payload(
    source,
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
  )
}

#let mermaid(
  source,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
) = {
  if error-mode == "panic" {
    _scaled(_mermaid-image(
      source,
      options: options,
      site-config: site-config,
      host-theme: host-theme,
      theme: theme,
      theme-name: theme-name,
      base-theme: base-theme,
      pipeline: pipeline,
      id: id,
      diagram-id: diagram-id,
      background: background,
      layout: layout,
      scoped-css: scoped-css,
      css-override-policy: css-override-policy,
      drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
      text-measurer: text-measurer,
      math-renderer: math-renderer,
      viewport-width: viewport-width,
      viewport-height: viewport-height,
      fixed-today: fixed-today,
      fixed-local-offset-minutes: fixed-local-offset-minutes,
      width: width,
      height: height,
      fit: fit,
      alt: alt,
    ), scale)
  } else {
    let result = _render-svg-result(
      source,
      options: options,
      site-config: site-config,
      host-theme: host-theme,
      theme: theme,
      theme-name: theme-name,
      base-theme: base-theme,
      pipeline: pipeline,
      id: id,
      diagram-id: diagram-id,
      background: background,
      layout: layout,
      scoped-css: scoped-css,
      css-override-policy: css-override-policy,
      drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
      text-measurer: text-measurer,
      math-renderer: math-renderer,
      viewport-width: viewport-width,
      viewport-height: viewport-height,
      fixed-today: fixed-today,
      fixed-local-offset-minutes: fixed-local-offset-minutes,
    )

    if result.ok {
      _scaled(image(
        bytes(result.svg),
        format: "svg",
        width: width,
        height: height,
        fit: fit,
        alt: alt,
      ), scale)
    } else {
      _diagram-error(result, error-mode, width)
    }
  }
}

#let mermaid-raw(
  block,
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
) = {
  mermaid(
    block.text,
    options: options,
    site-config: site-config,
    host-theme: host-theme,
    theme: theme,
    theme-name: theme-name,
    base-theme: base-theme,
    pipeline: pipeline,
    id: id,
    diagram-id: diagram-id,
    background: background,
    layout: layout,
    scoped-css: scoped-css,
    css-override-policy: css-override-policy,
    drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
    text-measurer: text-measurer,
    math-renderer: math-renderer,
    viewport-width: viewport-width,
    viewport-height: viewport-height,
    fixed-today: fixed-today,
    fixed-local-offset-minutes: fixed-local-offset-minutes,
    width: width,
    height: height,
    fit: fit,
    scale: scale,
    alt: alt,
    error-mode: error-mode,
  )
}

#let show-mermaid-blocks(
  options: none,
  site-config: none,
  host-theme: none,
  theme: none,
  theme-name: none,
  base-theme: none,
  pipeline: "resvg-safe",
  id: none,
  diagram-id: none,
  background: none,
  layout: none,
  scoped-css: none,
  css-override-policy: none,
  drop-native-duplicate-fallbacks: none,
  text-measurer: none,
  math-renderer: none,
  viewport-width: none,
  viewport-height: none,
  fixed-today: none,
  fixed-local-offset-minutes: none,
  width: 100%,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "placeholder",
) = block => mermaid-raw(
  block,
  options: options,
  site-config: site-config,
  host-theme: host-theme,
  theme: theme,
  theme-name: theme-name,
  base-theme: base-theme,
  pipeline: pipeline,
  id: id,
  diagram-id: diagram-id,
  background: background,
  layout: layout,
  scoped-css: scoped-css,
  css-override-policy: css-override-policy,
  drop-native-duplicate-fallbacks: drop-native-duplicate-fallbacks,
  text-measurer: text-measurer,
  math-renderer: math-renderer,
  viewport-width: viewport-width,
  viewport-height: viewport-height,
  fixed-today: fixed-today,
  fixed-local-offset-minutes: fixed-local-offset-minutes,
  width: width,
  height: height,
  fit: fit,
  scale: scale,
  alt: alt,
  error-mode: error-mode,
)
