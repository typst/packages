// Layout a roster of CJK names in a tidy, aligned grid.
//
// The package exposes a single function, `roster-cjk`, documented in README.md.
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// Format a single "word" that may carry a ruby annotation written in
// parentheses, e.g. `小鳥遊(たかなし)` renders 小鳥遊 with the reading たかなし
// above it. Both half-width `()` and full-width `（）` are accepted.
#let format-word-with-ruby(part) = context {
  let match-result = part.match(regex("^(.+?)[(（](.+?)[)）]$"))
  if match-result != none {
    let base = match-result.captures.at(0)
    let ruby-text = match-result.captures.at(1)
    box({
      place(top + center, dy: -0.8em, text(size: 0.6em, ruby-text))
      base
    })
  } else {
    part
  }
}

// Format a whitespace-separated group of words, joining them with a small gap.
#let format-with-ruby(str) = context {
  if str == "" { return str }
  let words = str.split(" ")
  let formatted-words = words.map(w => format-word-with-ruby(w))
  formatted-words.join(h(0.5em))
}

/// Lay out a list of CJK names into a tidy, column-aligned roster grid.
///
/// Supports Chinese names (with optional bracketed suffixes such as `（女）`)
/// and Japanese names (`姓 名 敬称`), the latter optionally annotated with furigana
/// in parentheses. Names longer than a single column automatically span more
/// columns; two-character CJK names are spaced out for visual balance.
///
/// - `names`: An array of name strings.
/// - `cols`   (default `8`): Number of columns in the grid.
/// - `zh-col-width` (default `4.8em`): Width of the column for Chinese names.
/// - `ja-inner-gap` (default `1em`): Gap between the surname / given name / honorific
///   parts of a Japanese name.
/// - `min-gap` (default `1.5em`): Horizontal gap between columns.
/// - `row-gutter` (default `1.2em`): Vertical gap between rows.
/// - `lang` (default `auto`): Force the layout mode. `auto` follows the current
///   `text.lang` (`"ja"` selects the Japanese layout, anything else the Chinese one).
#let roster-cjk(
  names,
  cols: 8,
  zh-col-width: 4.8em,
  ja-inner-gap: 1em,
  min-gap: 1.5em,
  row-gutter: 1.2em,
  lang: auto,
) = context {
  let actual-lang = if lang == auto { text.lang } else { lang }
  let CJKV-range = regex("[[\p{scx=Han}\p{scx=Katakana}\p{scx=Hiragana}\p{scx=Hangul}]&&\p{L}]")
  
  let parsed-ja = ()
  let global-max-sei = 0pt
  let global-max-mei = 0pt
  let global-max-kei = 0pt
  
  if actual-lang == "ja" {
    for name in names {
      let parts = name.split(regex("[\s\u{2003}]+"))
      let raw-sei = parts.at(0, default: "")
      let raw-mei = ""
      let raw-keishou = ""
      if parts.len() >= 3 {
        raw-mei = parts.slice(1, parts.len() - 1).join(" ")
        raw-keishou = parts.at(parts.len() - 1)
      } else if parts.len() == 2 {
        raw-keishou = parts.at(1)
      }
      
      let sei = format-with-ruby(raw-sei)
      let mei = format-with-ruby(raw-mei)
      let keishou = format-with-ruby(raw-keishou)
      
      let w-sei = measure(sei).width
      let w-mei = measure(mei).width
      let w-kei = measure(keishou).width
      
      parsed-ja.push((sei: sei, mei: mei, keishou: keishou, w-sei: w-sei, w-mei: w-mei, w-kei: w-kei))
      
      global-max-sei = calc.max(global-max-sei, w-sei)
      global-max-mei = calc.max(global-max-mei, w-mei)
      global-max-kei = calc.max(global-max-kei, w-kei)
    }
  }
  
  let sep-width = measure(h(ja-inner-gap)).width
  let items-info = ()
  
  let base-width = if actual-lang == "ja" {
    global-max-sei + global-max-mei + global-max-kei + (sep-width * 2)
  } else {
    measure(box(width: zh-col-width)).width
  }
  
  let gutter-width = measure(box(width: min-gap)).width
  
  for i in range(names.len()) {
    let name = names.at(i)
    if actual-lang == "ja" {
      items-info.push((type: "ja", width: base-width))
    } else {
      let core-name = name
      let suffix = ""
      let match-result = name.match(regex("^(.+?)([(（].*)$"))
      if match-result != none {
        core-name = match-result.captures.at(0).trim()
        suffix = match-result.captures.at(1)
      } else {
        core-name = name.trim()
      }
      
      let core-chars = core-name.clusters()
      let display-text = core-name
      
      if core-chars.len() == 2 and core-name.match(CJKV-range) != none {
        display-text = box(width: 3em, core-chars.at(0) + h(1fr) + core-chars.at(1))
      }
      
      let final-display = [#display-text#suffix]
      let w = measure(final-display).width
      
      items-info.push((type: "zh", display: final-display, width: w))
    }
  }
  
  let layout-results = ()
  let current-col = 0
  for i in range(names.len()) {
    let info = items-info.at(i)
    let item-width = info.width
    let span = 1
    
    if item-width > base-width + 0.1pt {
      span = calc.ceil((item-width + gutter-width) / (base-width + gutter-width))
    }
    span = calc.min(span, cols)
    
    let remaining-cols = cols - current-col
    if span > remaining-cols { current-col = 0 }
    
    layout-results.push((col: current-col, span: span))
    current-col = calc.rem(current-col + span, cols)
  }
  
  let col-max-sei = range(cols).map(c => {
    let max-w = 0pt
    for i in range(names.len()) {
      if actual-lang == "ja" and layout-results.at(i).col == c {
        max-w = calc.max(max-w, parsed-ja.at(i).w-sei)
      }
    }
    return max-w
  })
  
  let col-max-mei = range(cols).map(c => {
    let max-w = 0pt
    for i in range(names.len()) {
      if actual-lang == "ja" and layout-results.at(i).col == c {
        max-w = calc.max(max-w, parsed-ja.at(i).w-mei)
      }
    }
    return max-w
  })
  
  let col-max-kei = range(cols).map(c => {
    let max-w = 0pt
    for i in range(names.len()) {
      if actual-lang == "ja" and layout-results.at(i).col == c {
        max-w = calc.max(max-w, parsed-ja.at(i).w-kei)
      }
    }
    return max-w
  })
  
  let cells = ()
  current-col = 0
  
  for i in range(names.len()) {
    let info = items-info.at(i)
    let lay = layout-results.at(i)
    let span = lay.span
    let final-display = []
    
    if info.type == "ja" {
      let c = lay.col
      let p = parsed-ja.at(i)
      let part-sep = h(ja-inner-gap)
      
      final-display = {
        box(width: col-max-sei.at(c), align(left, p.sei))
        part-sep
        if col-max-mei.at(c) > 0pt {
          box(width: col-max-mei.at(c), align(left, p.mei))
          part-sep
        }
        box(width: col-max-kei.at(c), align(right, p.keishou))
      }
    } else {
      final-display = info.display
    }
    
    let remaining-cols = cols - current-col
    if span > remaining-cols {
      for _ in range(remaining-cols) { cells.push(grid.cell([])) }
      current-col = 0
    }
    
    cells.push(grid.cell(colspan: span, align(left + horizon, final-display)))
    current-col = calc.rem(current-col + span, cols)
  }
  
  grid(
    columns: (base-width,) * cols,
    column-gutter: min-gap,
    row-gutter: row-gutter,
    ..cells
  )
}