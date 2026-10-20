// src/layout/paginate.typ
// Pagination logic for splitting tokens into columns

#import "../kinsoku/kinsoku.typ": (
  apply-spacing-compression, is-forbidden-start, is-valid-line-end,
  justify-line,
)
#import "../pipeline/token.typ": merge-token

/// Splits a flat token array into column groups based on a maximum height
/// (absolute length). Uses pre-measured token heights for accuracy,
/// and consults config.kinsoku.resolve for line-breaking decisions.
///
/// - tokens (array): Array of token dictionaries.
/// - heights (array): Parallel array of absolute heights per token.
/// - max-height (length): Maximum column height as absolute length.
/// - config (dictionary): The layout configuration.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, heights, max-height, config) = {
  let columns = ()
  let current-col = ()
  let current-height = 0pt

  // Add paragraph indent for the very first line
  let par-indent-abs = config.at("paragraph-indent-abs", default: 0pt)

  let is-first-line-list = false
  for j in range(0, tokens.len()) {
    let peek = tokens.at(j)
    if (
      peek.type == "bullet-list-marker"
        or peek.at("list-marker", default: false)
    ) {
      is-first-line-list = true
      break
    }
    if (
      peek.type != "newline"
        and peek.type != "parbreak"
        and peek.type != "heading-anchor"
    ) {
      break
    }
  }

  if par-indent-abs > 0pt and not is-first-line-list {
    let indent-token = (
      type: "spacing",
      text: "",
      width: config.layout.at("paragraph-indent", default: 1em),
    )
    current-col.push(indent-token)
    current-height += par-indent-abs
  }

  let i = 0
  while i < tokens.len() {
    let token = tokens.at(i)
    let h = heights.at(i)

    if token.type == "newline" {
      let prev-type = if i > 0 { tokens.at(i - 1).type } else { none }
      if current-col.len() > 0 or prev-type in ("newline", "parbreak") {
        columns.push(current-col)
      }
      current-col = ()
      current-height = 0pt
      i += 1
      continue
    }

    if token.type == "parbreak" {
      let prev-type = if i > 0 { tokens.at(i - 1).type } else { none }
      if current-col.len() > 0 or prev-type in ("newline", "parbreak") {
        columns.push(current-col)
      }
      current-col = ()
      current-height = 0pt

      // Add paragraph spacing between paragraphs
      let par-spacing-abs = config.at("paragraph-spacing-abs", default: 0pt)
      if par-spacing-abs > 0pt {
        let spacing-token = (
          type: "spacing",
          text: "",
          width: config.layout.at("paragraph-spacing", default: 0em),
        )
        current-col.push(spacing-token)
        current-height += par-spacing-abs
      }

      // Add paragraph indent
      let par-indent-abs = config.at("paragraph-indent-abs", default: 0pt)

      let is-list = false
      for j in range(i + 1, tokens.len()) {
        let peek = tokens.at(j)
        if (
          peek.type == "bullet-list-marker"
            or peek.at("list-marker", default: false)
        ) {
          is-list = true
          break
        }
        if (
          peek.type != "newline"
            and peek.type != "parbreak"
            and peek.type != "heading-anchor"
        ) {
          break
        }
      }

      if par-indent-abs > 0pt and not is-list {
        let indent-token = (
          type: "spacing",
          text: "",
          width: config.layout.at("paragraph-indent", default: 1em),
        )
        current-col.push(indent-token)
        current-height += par-indent-abs
      }

      i += 1
      continue
    }

    if token.type == "vblock" or token.type == "hblock" {
      if current-col.len() > 0 {
        columns.push(current-col)
      }
      columns.push((token,))
      current-col = ()
      current-height = 0pt
      i += 1
      continue
    }

    if current-height > 0pt and current-height + h > max-height {
      config.kinsoku.insert("next-token", if i + 1 < tokens.len() {
        tokens.at(i + 1)
      } else { none })
      let decision = (config.kinsoku.resolve)(
        current-col,
        token,
        h,
        config,
        current-height,
        max-height,
      )

      if decision.action == "burasagari" {
        let hanging-token = merge-token(token, (type: "hanging"))
        current-col.push(hanging-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "oikomi" {
        current-col = apply-spacing-compression(
          current-col,
          decision.compression-amount,
          config,
        )
        current-col.push(token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "push-previous" {
        let popped = ()
        let popped-height = 0pt
        let popped-start = i - current-col.len()
        while current-col.len() > 0 {
          let p = current-col.pop()
          let ph = heights.at(popped-start + current-col.len())
          popped.insert(0, p)
          popped-height += ph

          let new-last = if current-col.len() > 0 { current-col.last() } else {
            none
          }
          if is-valid-line-end(new-last, config.kinsoku.forbidden-end) {
            // If the overflow token is forbidden-start and the new column
            // would start with one too, cascade further to prevent a
            // column-start kinsoku violation.
            let tok-start = is-forbidden-start(
              token,
              config.kinsoku.forbidden-start,
            )
            let pop-start = (
              popped.len() > 0
                and is-forbidden-start(
                  popped.first(),
                  config.kinsoku.forbidden-start,
                )
            )
            let needs-more = tok-start and pop-start
            if not needs-more {
              break
            }
          }
        }

        let exhausted = current-col.len() == 0
        current-col = justify-line(
          current-col,
          max-height - (current-height - popped-height),
          config,
        )
        columns.push(current-col)
        if exhausted {
          // All tokens were popped but the violation persists.
          // Force oidashi to prevent infinite loop.
          current-col = (token,)
          current-height = h
          i += 1
        } else {
          current-col = popped
          current-height = popped-height
        }
        continue
      }

      // oidashi — break normally before the current token
      current-col = justify-line(
        current-col,
        max-height - current-height,
        config,
      )
      columns.push(current-col)
      current-col = (token,)
      current-height = h
    } else {
      current-col.push(token)
      current-height += h
    }

    i += 1
  }

  if current-col.len() > 0 {
    columns.push(current-col)
  }

  columns
}
