// src/list.typ
// Self-contained list modules: each bundles data and flatten logic.

#import "../pipeline/token.typ": token

/// Default bullet list module factory.
///
/// - marker (str): The bullet character. Default: "・".
/// -> dictionary: A list module dict with `marker`, `flatten`, and `node-renderers`.
#let default-bullet-list-params(
  marker: "・",
) = {
  (
    marker: marker,
    flatten: (c, _flatten, config) => {
      let tokens = ()
      for i in range(c.children.len()) {
        if i > 0 { tokens.push(token("newline", fields: (text: "\n"))) }
        tokens.push(token("bullet-list-marker"))
        tokens += _flatten(c.children.at(i).body, config)
      }
      tokens
    },
    node-renderers: (
      "bullet-list-marker": (token, config) => {
        let f-opt = if config.font != none { (font: config.font) } else { (:) }
        let marker = config.list.bullet.marker
        box(
          width: config.sizing.char-box,
          height: config.sizing.char-box,
          align(center + horizon, text(
            ..f-opt,
            features: config.features,
            marker,
          )),
        )
      },
    ),
  )
}

/// Default numbered list module factory.
/// The formatted number (e.g. "1.") is rendered as forced TCY so the
/// digits and dot stay in a single 1em slot.
///
/// - format (function): (int) => str. Default: n => str(n) + ".".
/// - gap (length): Gap after the number before the item text. Default: 0.25em.
/// -> dictionary: A list module dict with `format`, `gap`, and `flatten`.
#let default-numbered-list-params(
  format: n => str(n) + ".",
  gap: 0.25em,
) = {
  (
    format: format,
    gap: gap,
    flatten: (c, _flatten, config) => {
      let tokens = ()
      let start = c.at("start", default: 1)
      for i in range(c.children.len()) {
        if i > 0 { tokens.push(token("newline", fields: (text: "\n"))) }
        let num = (config.list.numbered.format)(start + i)
        tokens.push(token("tcy", fields: (
          text: num,
          forced: true,
          list-marker: true,
        )))
        let gap = config.list.numbered.gap
        if gap != 0pt { tokens.push(token("spacing", fields: (width: gap))) }
        tokens += _flatten(c.children.at(i).body, config)
      }
      tokens
    },
    node-renderers: (:),
  )
}
