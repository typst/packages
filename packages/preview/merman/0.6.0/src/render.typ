#import "context.typ": typst-layout
#import "errors.typ": validate-error-mode
#import "image.typ": result-image, svg-bytes-or-panic
#import "options.typ": config-with-context-width, config-with-theme-spec, context-text-style, options-bytes, render-config
#import "plugin.typ": merman-plugin
#import "source.typ": source-text-value
#import "theme.typ": export-theme-preset, materialize-theme
#import "units.typ": context-width-css-px

#let resolve-theme-render-config(config) = {
  if config.typography_overlay == none {
    return config
  }
  let selection = config.binding_options.at("theme", default: none)
  if selection == none or "spec" in selection {
    config
  } else {
    let recipe = if "preset" in selection {
      export-theme-preset(selection.preset, options: config.binding_options)
    } else {
      selection.recipe
    }
    if "preset" in selection and "ok" in recipe {
      recipe
    } else {
      let request = (schema_version: 1, action: "materialize", recipe: recipe)
      let request = if "appearance" in selection {
        (: ..request, appearance: selection.appearance)
      } else {
        request
      }
      let materialized = materialize-theme(request, options: config.binding_options)
      if "spec" in materialized {
        config-with-theme-spec(config, materialized.spec)
      } else {
        materialized
      }
    }
  }
}

#let render-svg-result-with-config(source, config) = {
  let config = resolve-theme-render-config(config)
  if "binding_options" not in config {
    return (: ..config, details: config.at("details", default: none), svg: none)
  }
  let source-text = source-text-value(source)
  let envelope = json(
    merman-plugin.render_svg_json(bytes(source-text), options-bytes(config.binding_options)),
  )
  if envelope.operation != "render-svg" {
    panic("merman Typst plugin returned an unexpected render operation")
  }
  (
    version: envelope.version,
    operation: envelope.operation,
    ok: envelope.ok,
    code: envelope.code,
    code_name: envelope.code_name,
    kind: envelope.kind,
    capability_id: envelope.capability_id,
    message: envelope.message,
    details: if "details" in envelope { envelope.details } else { none },
    svg: if envelope.ok { envelope.data.svg } else { none },
  )
}

#let render-svg-result(source, ..args) = {
  render-svg-result-with-config(source, render-config(..args))
}

#let render-svg-bytes(..args) = {
  svg-bytes-or-panic(render-svg-result(..args))
}

#let analyze-payload-with-config(source, config) = {
  let config = resolve-theme-render-config(config)
  if "binding_options" not in config {
    return config
  }
  let source-text = source-text-value(source)
  let envelope = json(
    merman-plugin.analyze_json(bytes(source-text), options-bytes(config.binding_options)),
  )
  if envelope.operation != "analyze" {
    panic("merman Typst plugin returned an unexpected analysis operation")
  }
  if envelope.ok { envelope.data.analysis } else { envelope }
}

#let analyze-payload(source, ..args) = {
  analyze-payload-with-config(source, render-config(..args))
}

#let mermaid-result(source, ..args) = render-svg-result(source, ..args)

#let mermaid-svg(source, ..args) = {
  str(render-svg-bytes(source, ..args))
}

#let analyze-mermaid(source, ..args) = analyze-payload(source, ..args)

#let render-image(
  source,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
  ..args,
) = {
  let result = render-svg-result(source, ..args)
  result-image(result, width, height, fit, alt, scale, error-mode)
}

#let with-document-render-config(
  operation,
  ..args,
) = context {
  let inferred-text-style = context-text-style(text.font, text.size)
  let base-config = render-config(context-text-style: inferred-text-style, ..args)
  if base-config.direct_layout != none or base-config.direct_container_width != none or base-config.direct_options != none or base-config.profile_options != none or base-config.profile_layout_container_width != none {
    operation(base-config)
  } else {
    typst-layout(size => {
      operation(config-with-context-width(base-config, context-width-css-px(size.width)))
    })
  }
}

#let render-image-with-document-context(
  source,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
  ..args,
) = {
  with-document-render-config(
    config => {
      let result = render-svg-result-with-config(source, config)
      result-image(result, width, height, fit, alt, scale, error-mode)
    },
    ..args,
  )
}

#let mermaid(
  source,
  document-context: false,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
  ..args,
) = {
  let error-mode = validate-error-mode(error-mode)
  if document-context {
    render-image-with-document-context(
      source,
      width: width,
      height: height,
      fit: fit,
      scale: scale,
      alt: alt,
      error-mode: error-mode,
      ..args,
    )
  } else {
    render-image(
      source,
      width: width,
      height: height,
      fit: fit,
      scale: scale,
      alt: alt,
      error-mode: error-mode,
      ..args,
    )
  }
}

#let with-theme-definition-render-config(
  definition,
  on-config,
  on-error,
  document-context: false,
  ..args,
) = {
  let materialize-and-continue = config => {
    let materialized = materialize-theme(definition, options: config.binding_options)
    if "spec" in materialized {
      on-config(config-with-theme-spec(config, materialized.spec))
    } else {
      on-error(materialized)
    }
  }
  if document-context {
    with-document-render-config(materialize-and-continue, ..args)
  } else {
    materialize-and-continue(render-config(..args))
  }
}

#let mermaid-theme-definition(
  source,
  definition,
  document-context: false,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  error-mode: "panic",
  ..args,
) = {
  let error-mode = validate-error-mode(error-mode)
  with-theme-definition-render-config(
    definition,
    config => result-image(
      render-svg-result-with-config(source, config),
      width,
      height,
      fit,
      alt,
      scale,
      error-mode,
    ),
    result => result-image(result, width, height, fit, alt, scale, error-mode),
    document-context: document-context,
    ..args,
  )
}
