// src/spacing.typ
// Automatic spacing module (Shikiri / Wou-Kan Kakaku)

#import "../core/token.typ": token

#let is-european(t) = t.type in ("tcy", "turn")
#let is-cjk(t) = (
  t.type == "char"
    and t.text.match(regex("^[^\s\p{P}]$")) != none
    and t.text.match(regex("^[A-Za-z0-9,.!?:;]$")) == none
)

/// Default spacing rendering module factory.
/// Automatically inserts configurable gaps between CJK and European characters.
///
/// - cjk-european-gap (length): Gap after a CJK char before a European char. Default: 0.25em.
/// - european-cjk-gap (length): Gap after a European char before a CJK char. Default: 0.25em.
/// -> dictionary: A rendering module dict with `node-renderers` and `transform`.
#let default-spacing(
  cjk-european-gap: 0.25em,
  european-cjk-gap: 0.25em,
) = {
  (node-renderers: (
      "spacing": (token, config) => box(width: config.sizing.char-box, height: token.width),
    ),
    transform: (tokens) => {
      let result = ()
      let prev = none
      for t in tokens {
        if prev != none {
          if is-cjk(prev) and is-european(t) {
            result.push(token("spacing", fields: (width: cjk-european-gap)))
          } else if is-european(prev) and is-cjk(t) {
            result.push(token("spacing", fields: (width: european-cjk-gap)))
          }
        }
        result.push(t)
        prev = t
      }
      result
    })
}
