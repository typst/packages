// src/tcy.typ
// Tate-chu-yoko (TCY / 縦中横) processing module

#import "../pipeline/token.typ": merge-token, token

/// Default TCY module factory.
/// Returns a self-contained TCY processing module with configurable pattern and sizes.
///
/// - pattern (regex): Regex matching TCY-character runs. Default: `^[A-Za-z0-9,]+$`.
/// - sizes (array): Font sizes for len <=2, ==3, >=4. Default: `(1em, 0.65em, 0.5em)`.
/// -> dictionary: A TCY module dict with a `filter` function.
#let default-tcy(
  pattern: regex("^[A-Za-z0-9,.!?:;]+$"),
  sizes: (1em, 0.65em, 0.5em),
) = {
  (
    pattern: pattern,
    sizes: sizes,
    filter: (tokens, config) => {
      let new-tokens = ()
      let classify-fn = none
      if "categories" in config and "classify" in config.categories {
        classify-fn = config.categories.classify
      }
      for t in tokens {
        if t.type == "tcy" {
          let forced = t.at("forced", default: false)
          if forced != false {
            if forced == "char" {
              if type(t.text) == str {
                for ch in t.text.clusters() {
                  new-tokens.push(merge-token(t, (type: "char", text: ch)))
                }
              } else {
                new-tokens.push(merge-token(t, (type: "char", text: t.text)))
              }
            } else {
              new-tokens.push(t)
            }
          } else if classify-fn != none {
            let cat = classify-fn(t.text, config)
            if cat == "horizontal" {
              new-tokens.push(t)
            } else if cat == "rotated" {
              new-tokens.push(merge-token(t, (type: "turn", text: t.text)))
            } else {
              if type(t.text) == str {
                for ch in t.text.clusters() {
                  new-tokens.push(merge-token(t, (type: "char", text: ch)))
                }
              } else {
                new-tokens.push(merge-token(t, (type: "char", text: t.text)))
              }
            }
          } else {
            new-tokens.push(t)
          }
        } else {
          new-tokens.push(t)
        }
      }
      new-tokens
    },
  )
}
