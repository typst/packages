// src/kinsoku/spacing.typ
// Automatic spacing module (Shikiri / Wou-Kan Kakaku)

#import "../pipeline/token.typ": merge-token, token
#import "../kinsoku/kinsoku.typ": (
  is-forbidden-end, is-forbidden-start, is-unbreakable-pair,
)

#let is-alphanumeric(t) = {
  if t == none or (t.type != "char" and t.type != "tcy" and t.type != "turn") {
    return false
  }
  if type(t.text) != str { return false }
  t.text.match(regex("^[A-Za-z0-9,.!?:;]+$")) != none
}

#let is-japanese(t) = {
  if t == none or t.type != "char" { return false }
  if type(t.text) != str { return false }
  t.text.match(regex("^[^\x00-\x7F]+$")) != none
}

#let is-opening-bracket(t, chars) = {
  is-forbidden-end(t, chars)
}

#let is-closing-bracket(t) = {
  if t == none or t.type != "char" { return false }
  let closing = "）〕］｝〉》」』】)]}〞”’"
  closing.contains(t.text)
}

#let is-justification-point(t, forbidden-start, forbidden-end) = {
  if t == none or t.type != "char" { return false }
  (
    not is-opening-bracket(t, forbidden-end)
      and not is-forbidden-start(t, forbidden-start)
  )
}

/// Default spacing rendering module factory.
/// Automatically assigns `space-after` values according to adjacency rules.
///
/// - cjk-european-gap (length): Gap after a CJK char before a European char. Default: 0.25em.
/// - european-cjk-gap (length): Gap after a European char before a CJK char. Default: 0.25em.
/// - bracket-gap (length): Gap after a closing bracket before an opening bracket. Default: 0.5em.
/// -> dictionary: A rendering module dict with `node-renderers` and `transform`.
#let default-spacing(
  cjk-european-gap: 0.25em,
  european-cjk-gap: 0.25em,
  bracket-gap: 0.5em,
) = {
  (
    node-renderers: (
      "spacing": (token, config) => box(
        width: config.sizing.char-box,
        height: token.width,
      ),
    ),
    transform: (tokens, config) => {
      let result = ()
      let len = tokens.len()
      for i in range(len) {
        let t = tokens.at(i)
        let next-t = if i + 1 < len { tokens.at(i + 1) } else { none }

        let space-after = 0pt
        if is-alphanumeric(t) and is-japanese(next-t) {
          space-after = european-cjk-gap
        } else if is-japanese(t) and is-alphanumeric(next-t) {
          space-after = cjk-european-gap
        } else if (
          is-closing-bracket(t)
            and is-opening-bracket(next-t, config.kinsoku.forbidden-end)
        ) {
          space-after = bracket-gap
        }

        let is-jp = is-justification-point(
          t,
          config.kinsoku.forbidden-start,
          config.kinsoku.forbidden-end,
        )

        if (
          config.kinsoku.at("buntetsu-kinsoku", default: true)
            and is-unbreakable-pair(t, next-t, config.kinsoku.unbreakable-chars)
        ) {
          space-after = 0pt
          is-jp = false
        }

        let base-width = 1.0
        let internal-aki = 0.0
        if (
          is-opening-bracket(t, config.kinsoku.forbidden-end)
            or is-closing-bracket(t)
        ) {
          internal-aki = 0.5
        } else if (
          t != none
            and t.type == "char"
            and type(t.text) == str
            and "、。，．".contains(t.text)
        ) {
          internal-aki = 0.5
        }

        t = merge-token(t, (
          space-after: space-after,
          justification-point: is-jp,
          base-width: base-width,
          internal-aki: internal-aki,
          compression-applied: 0pt,
        ))
        result.push(t)
      }
      result
    },
  )
}
