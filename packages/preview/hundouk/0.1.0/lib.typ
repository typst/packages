#import "utils/parsing.typ": parse-aozora, parse-kanbun, parse-wenyan, serialize-kanbun
#import "utils/kanbun.typ": hakubun, unicode-kaeriten-to-normalized, yomikudasi
#import "utils/rendering.typ": group-nodes

/// 漢文の疑似縦書き訓点等付きレンダリング
///
/// - tight (bool): trueの場合はアキ組、falseの場合はベタ組
/// - color-hypen (auto, color): 縦棒（ハイフン）の色
/// - hypen (function): 縦棒（ハイフン）のレンダラー
/// - ruby-tracking (length): 読みがな（ルビー、ふりがな）の字間（`auto`の場合、縦書きは`0.1em`、横書きは`0.01em`）
/// - okurigana-tracking (length): 送り仮名の字間（`auto`の場合、縦書きは`0.1em`、横書きは`0.01em`）
/// - ruby-size (length): 読みがな（ルビー、ふりがな）の大きさ（フォントサイズ）
/// - writing-direction (ltr, ttb): 漢文の向き
/// - okurigana-size (length): 送り仮名の大きさ（フォントサイズ）
/// - ruby-gutter (length): 読みがな（ルビー）と親文字の間隔
/// - annotation-gutter (length): 注釈（送り仮名、返り点）と親文字の間隔
/// - hang-kaeriten-on-connector (bool): 接続符（ハイフン）に返り点をぶら下げるかどうか
/// - line-spacing (length): 行間
/// - debug (bool): trueの場合はデバッグ用の色を表示
/// - use-unicode-kanbun (bool): trueの場合はUnicode漢文記号を使用、falseの場合はフォント互換性のため標準的な文字を使用
/// - ruby-vertical-offset (length): 読みがな（ルビー）の縦方向の位置調整 (縦書き時のフォントパディング補正用)
/// - kaeriten-offset (length): 返り点の水平方向の位置調整 (デフォルトは0pt, 0.25em~0.5em推奨)
/// - okurigana-x-offset (length): 送り仮名の水平方向の位置調整 (デフォルトは0pt, 0.25em推奨)
/// - okurigana-y-offset (length): 送り仮名の垂直方向の位置調整 (デフォルトは0pt, 0.25em推奨)
/// - nodes (list): 漢文のノードリスト
/// ->
#let render-kanbun(
  tight: true,
  color-hypen: auto,
  ruby-tracking: auto,
  okurigana-tracking: auto,
  ruby-size: 0.5em,
  okurigana-size: 0.5em,
  ruby-gutter: 0em,
  annotation-gutter: 0em,
  ruby-okurigana-gutter: 0.05em,
  ruby-vertical-offset: 0.05em,
  kaeriten-offset: 0pt,
  okurigana-x-offset: 0pt,
  okurigana-y-offset: 0pt,
  hang-kaeriten-on-connector: true,
  max-chars-for-kaeriten-hanging-on-hyphen: none,
  height: auto,
  writing-direction: ttb,
  use-unicode-kanbun: true,
  char-spacing: 0.05em,
  line-spacing: auto,
  debug: false,
  punctuation-offset: (
    dx: -0.5em,
    dy: 0.2em,
  ),
  hypen: (
    tight: none,
    color-hypen: none,
    use-unicode-kanbun: none,
    writing-direction: none,
    debug: none,
  ) => context {
    let connector = text(
      fill: if color-hypen == auto or color-hypen == none { text.fill } else {
        color-hypen
      },
      if use-unicode-kanbun {
        if writing-direction == ltr { rotate(90deg, [㆐]) } else { [㆐] }
      } else { [―] },
    )
    let width = 2em
    let height = if tight { 0.5em } else { 1em }
    let connector-content = box(
      ..if writing-direction == ttb {
        (width: width, height: height)
      } else {
        (width: height, height: width)
      },
      fill: if debug { orange } else { none },
      align(
        center + horizon,
        connector,
      ),
    )

    let hypen(
      tight: tight,
      color-hypen: color-hypen,
      use-unicode-kanbun: use-unicode-kanbun,
      writing-direction: writing-direction,
      debug: debug,
    ) = connector-content
  },
  nodes,
) = context {
  // #region Check validity of arguments
  if writing-direction != ttb and writing-direction != ltr {
    panic("writing-direction must be either ttb or ltr")
  }


  if color-hypen != auto and type(color-hypen) != color {
    panic("color-hypen must be either auto or color")
  }
  // #endregion

  let ruby-tracking = if ruby-tracking == auto {
    if writing-direction == ltr { 0.01em } else { 0.1em }
  } else { ruby-tracking }

  let okurigana-tracking = if okurigana-tracking == auto {
    if writing-direction == ltr { 0.01em } else { 0.1em }
  } else { okurigana-tracking }

  let leading = if line-spacing == auto {
    par.leading
  } else {
    line-spacing
  }

  let nodes = if not use-unicode-kanbun {
    nodes.map(node => {
      if node.type == "character" and node.at("kaeriten", default: none) != none {
        let k = node.kaeriten
        let new-k = unicode-kaeriten-to-normalized(k)
        node + (kaeriten: new-k)
      } else {
        node
      }
    })
  } else {
    nodes
  }

  let nodes = group-nodes(nodes)

  set text(features: if writing-direction == ttb { ("vert",) } else { () })

  let format-kaeriten(s) = {
    if (
      s != none
        and type(s) == str
        and s.clusters().len() > 1
        and (s.clusters().last() == "レ" or s.clusters().last() == "㆑")
    ) {
      let main = s.clusters().slice(0, s.clusters().len() - 1).join()
      let re = s.clusters().last()
      // Tight stack for ligature look
      stack(dir: ttb, spacing: -0.35em, main, re)
    } else {
      s
    }
  }

  let format-annotation(s, size, tracking) = {
    stack(
      dir: writing-direction,
      spacing: tracking,
      ..s.clusters().map(x => text(size: size)[#x]),
    )
  }

  let make-unit(node, punctuation: none) = {
    if node.type == "connector" {
      return hypen(
        tight: tight,
        color-hypen: color-hypen,
        use-unicode-kanbun: use-unicode-kanbun,
        writing-direction: writing-direction,
        debug: debug,
      )
    }

    if node.type == "connected-group" {
      // Connected group rendering
      let children = node.children
      let char-count = children.filter(c => c.type == "character").len()
      let should-hang-kaeriten = (
        hang-kaeriten-on-connector
          and (
            max-chars-for-kaeriten-hanging-on-hyphen == none or char-count <= max-chars-for-kaeriten-hanging-on-hyphen
          )
      )

      let merged-reading = none
      let merged-left-ruby = none

      // Check for merged readings
      // 1. Ruby (Right/Top)
      let reading-count = 0
      let last-char-reading = none
      for (idx, child) in children.enumerate() {
        if child.type == "character" and child.at("reading", default: none) != none {
          reading-count += 1
          last-char-reading = child.at("reading")
        }
      }
      if (
        reading-count == 1
          and children.last().type == "character"
          and children.last().at("reading", default: none) != none
      ) {
        merged-reading = last-char-reading
      }

      let merged-okurigana = none
      // TTB: Merge Okurigana into the Merged Reading string
      if merged-reading != none and writing-direction == ttb {
        let okuri-parts = ()
        for child in children {
          if child.type == "character" {
            let o = child.at("okurigana", default: none)
            if o != none { okuri-parts.push(o) }
          }
        }
        let full-okuri = okuri-parts.join("")
        if full-okuri != "" {
          merged-okurigana = full-okuri
        }
      }

      // 2. Left Ruby (Left/Bottom)
      let left-ruby-count = 0
      let last-char-left-ruby = none
      for (idx, child) in children.enumerate() {
        if child.type == "character" and child.at("left-ruby", default: none) != none {
          left-ruby-count += 1
          last-char-left-ruby = child.at("left-ruby")
        }
      }
      if (
        left-ruby-count == 1
          and children.last().type == "character"
          and children.last().at("left-ruby", default: none) != none
      ) {
        merged-left-ruby = last-char-left-ruby
      }

      // Collect grid items
      let grid-tracks = ()
      let grid-gutters = ()
      let grid-cells = ()
      let current-track-idx = 0
      let extra-ltr-tracks = 0

      for (idx, child) in children.enumerate() {
        if child.type == "character" {
          let surface = child.surface
          let reading = if merged-reading != none { none } else { child.at("reading", default: none) }
          // TTB: Okurigana is merged into reading, so suppress here.
          // LTR: Okurigana remains separate.
          let okurigana = if merged-reading != none and writing-direction == ttb { none } else {
            child.at("okurigana", default: none)
          }
          let kaeriten = child.at("kaeriten", default: none)
          let left-ruby = if merged-left-ruby != none { none } else { child.at("left-ruby", default: none) }
          let left-okurigana = child.at("left-okurigana", default: none)

          // Kaeriten placement logic (move to next connector if applicable)
          // AND move to PREV connector if hanging is enabled
          let next-is-connector = (idx + 1 < children.len() and children.at(idx + 1).type == "connector")
          // Logic 1: Existing "move-kaeriten" (moves to NEXT connector). Usually for `Re` (returns to prev).
          // If `A[Re]=B`, `Re` on `A` moves to `=`.
          let move-kaeriten = (kaeriten != none and next-is-connector and writing-direction == ttb)

          // Logic 2: "Steal back" (move to PREV connector). Usually for `1` (series marker).
          // If `A-B[1]`, `1` on `B` moves to `-`.
          let prev-is-connector = (idx > 0 and children.at(idx - 1).type == "connector")
          let steal-kaeriten = (
            kaeriten != none and should-hang-kaeriten and prev-is-connector and writing-direction == ttb
          )

          let kaeriten-for-this = if move-kaeriten or steal-kaeriten { none } else { kaeriten }

          // Generate Content
          let reading-content = if reading != none {
            let content = format-annotation(reading, ruby-size, ruby-tracking)
            if writing-direction == ttb {
              v(ruby-vertical-offset)
              content
            } else {
              content
            }
          } else { none }
          let okurigana-content = if okurigana != none {
            move(
              dx: okurigana-x-offset,
              dy: okurigana-y-offset,
              format-annotation(okurigana, okurigana-size, okurigana-tracking),
            )
          } else { none }
          let left-okurigana-content = if left-okurigana != none {
            format-annotation(left-okurigana, okurigana-size, okurigana-tracking)
          } else { none }
          let kaeriten-content = if kaeriten-for-this != none {
            move(dx: kaeriten-offset, text(size: 0.5em)[#format-kaeriten(kaeriten-for-this)])
          } else { none }
          let left-ruby-content = if left-ruby != none {
            format-annotation(left-ruby, ruby-size, ruby-tracking)
          } else { none }

          // Add Tracks (Rows for TTB, Cols for LTR)
          if grid-tracks.len() > 0 {
            grid-gutters.push(0em)
          }
          let k = current-track-idx
          grid-tracks.push(0.5em)
          grid-gutters.push(ruby-okurigana-gutter)
          grid-tracks.push(0.5em)
          current-track-idx += 2

          // Grid Placement
          if writing-direction == ttb {
            // TTB: Rows expand. Cols fixed (0.5, 0.5, 0.5, 0.5)
            // Kanji
            grid-cells.push(
              grid.cell(x: 1, y: k, colspan: 2, rowspan: 2, fill: if debug { rgb("#a1ff8a47") } else { none }, surface),
            )
            // Ruby
            if reading-content != none {
              grid-cells.push(
                grid.cell(
                  x: 3,
                  y: k,
                  rowspan: 2,
                  align: left + horizon,
                  fill: if debug { rgb("#ff8aed47") } else { none },
                  reading-content,
                ),
              )
            }
            // Left Ruby
            if left-ruby-content != none {
              grid-cells.push(
                grid.cell(
                  x: 0,
                  y: k,
                  rowspan: 2,
                  align: right + horizon,
                  fill: if debug { rgb("#f2666647") } else { none },
                  left-ruby-content,
                ),
              )
            }
          } else {
            // LTR: Cols expand. Rows fixed (0.5, 0.5, 0.5, 0.5)
            // k is current COLUMN index.
            // Kanji: x=k, y=1, colspan=2, rowspan=2
            grid-cells.push(
              grid.cell(x: k, y: 1, colspan: 2, rowspan: 2, fill: if debug { rgb("#a1ff8a47") } else { none }, surface),
            )
            // Ruby (Top): y=0
            if reading-content != none {
              grid-cells.push(
                grid.cell(
                  x: k,
                  y: 0,
                  colspan: 2,
                  align: center + bottom,
                  fill: if debug { rgb("#ff8aed47") } else { none },
                  reading-content,
                ),
              )
            }
            // Left Ruby (Bottom): y=3
            if left-ruby-content != none {
              grid-cells.push(
                grid.cell(
                  x: k,
                  y: 3,
                  colspan: 2,
                  align: center + top,
                  fill: if debug { rgb("#f2666647") } else { none },
                  left-ruby-content,
                ),
              )
            }
          }

          // Punctuation (TTB only in this block)
          let is-last = (idx == children.len() - 1) // Assuming group ends with char
          let has-punct = (is-last and punctuation != none)
          let ttb-punct = (writing-direction == ttb and has-punct)

          // Attachments (Okurigana / Kaeriten / Left Okurigana / TTB Punctuation)
          // Need extra track if present
          if writing-direction == ltr {
            // LTR Logic
            // 1. Left Ruby (In-line, Bottom of Char)
            if left-ruby-content != none {
              grid-cells.push(
                grid.cell(
                  x: k,
                  y: 3,
                  colspan: 2,
                  align: center + top,
                  fill: if debug { rgb("#f2666647") } else { none },
                  left-ruby-content,
                ),
              )
            }

            // 2. Side Columns (Right of Char)
            // Okurigana Track
            if okurigana-content != none {
              grid-gutters.push(annotation-gutter)
              grid-tracks.push(auto)
              let trk = current-track-idx
              current-track-idx += 1
              extra-ltr-tracks += 1
              grid-cells.push(
                grid.cell(
                  x: trk,
                  y: 0,
                  rowspan: 2,
                  align: left + horizon,
                  fill: if debug { rgb("#fac400") } else { none },
                  okurigana-content,
                ),
              )
            }

            // Kaeriten Track
            if kaeriten-content != none or left-okurigana-content != none {
              grid-gutters.push(annotation-gutter)
              grid-tracks.push(auto)
              let trk = current-track-idx
              current-track-idx += 1
              extra-ltr-tracks += 1
              grid-cells.push(
                grid.cell(
                  x: trk,
                  y: 2,
                  rowspan: 2,
                  align: left + horizon,
                  fill: if debug { rgb("#00edfa") } else { none },
                  stack(dir: ttb, spacing: 0em, left-okurigana-content, kaeriten-content),
                ),
              )
            }
          } else if okurigana != none or kaeriten-for-this != none or left-okurigana != none or ttb-punct {
            // TTB Attachments (Single Track)
            let g = annotation-gutter
            grid-gutters.push(g)

            grid-tracks.push(auto)
            let annot-track = current-track-idx
            current-track-idx += 1

            if okurigana-content != none {
              grid-cells.push(
                grid.cell(
                  x: 3,
                  y: annot-track,
                  align: left + top,
                  fill: if debug { rgb("#fac400") } else { none },
                  okurigana-content,
                ),
              )
            }
            if kaeriten-content != none or left-okurigana-content != none {
              grid-cells.push(
                grid.cell(
                  x: 1,
                  y: annot-track,
                  align: right + top,
                  fill: if debug { rgb("#00edfa") } else { none },
                  stack(dir: writing-direction, spacing: 0em, left-okurigana-content, kaeriten-content),
                ),
              )
            }
            if ttb-punct {
              let p-content = align(
                top + right,
                move(
                  ..punctuation-offset,
                  text(size: 1em)[#punctuation.surface],
                ),
              )
              grid-cells.push(
                grid.cell(
                  x: 2,
                  y: annot-track,
                  align: right + top,
                  fill: if debug { rgb("#0905ff47") } else { none },
                  p-content,
                ),
              )
            }
          }

          // LTR Punctuation (Append new track)
          if writing-direction == ltr and has-punct {
            if grid-tracks.len() > 0 {
              grid-gutters.push(0em)
            }
            grid-tracks.push(0.5em)
            let punct-track = current-track-idx
            current-track-idx += 1

            let p-content = align(
              top + right,
              move(
                dx: punctuation-offset.dy,
                dy: punctuation-offset.dx,
                text(size: 1em)[#punctuation.surface],
              ),
            )
            grid-cells.push(
              grid.cell(
                x: punct-track,
                y: 3,
                align: right + bottom,
                fill: if debug { rgb("#0905ff47") } else { none },
                p-content,
              ),
            )
          }
        } else if child.type == "connector" {
          // Connector Logic
          let prev-idx = idx - 1
          let next-idx = idx + 1

          let extra-content-list = ()

          // 1. Take from Prev (Existing logic, e.g. Re)
          if writing-direction == ttb and prev-idx >= 0 and children.at(prev-idx).type == "character" {
            let prev-char = children.at(prev-idx)
            let k = prev-char.at("kaeriten", default: none)
            if k != none {
              extra-content-list.push(k)
            }
          }

          // 1.5. Take from Self (Connector's own Kaeriten)
          if child.at("kaeriten", default: none) != none {
            extra-content-list.push(child.at("kaeriten"))
          }

          // 2. Take from Next (New logic, e.g. Ichi)
          if (
            writing-direction == ttb
              and should-hang-kaeriten
              and next-idx < children.len()
              and children.at(next-idx).type == "character"
          ) {
            let next-char = children.at(next-idx)
            let k = next-char.at("kaeriten", default: none)
            if k != none {
              extra-content-list.push(k)
            }
          }

          let extra-content = if extra-content-list.len() > 0 {
            let merged-k = extra-content-list.join("")
            move(dx: kaeriten-offset, text(size: 0.5em)[#format-kaeriten(merged-k)])
          } else { none }

          let h = if tight { 0.5em } else { 1em }
          if grid-tracks.len() > 0 {
            grid-gutters.push(0em)
          }
          grid-tracks.push(h)
          let trk = current-track-idx
          current-track-idx += 1

          let connector-text = text(
            fill: if color-hypen == auto or color-hypen == none { text.fill } else {
              color-hypen
            },
            if use-unicode-kanbun {
              if writing-direction == ltr { rotate(90deg, [㆐]) } else { [㆐] }
            } else { [―] },
          )

          let c-content = if tight { scale(50%, connector-text) } else { connector-text }
          let c-box = box(fill: if debug { orange } else { none }, c-content)

          if writing-direction == ttb {
            if should-hang-kaeriten and extra-content != none {
              // Hang Kaeriten: Split Column
              // Kaeriten (Left/Top Half) -> x: 1
              grid-cells.push(
                grid.cell(
                  x: 1,
                  y: trk,
                  align: right + horizon,
                  fill: if debug { rgb("#00edfa") } else { none },
                  extra-content,
                ),
              )
              // Connector (Right/Bottom Half) -> x: 2
              // Move connector left by 0.25em to align with original center
              let moved-c = move(dx: -0.25em, c-box)
              grid-cells.push(grid.cell(x: 2, y: trk, align: center + horizon, moved-c))
            } else {
              grid-cells.push(grid.cell(x: 1, y: trk, colspan: 2, align: center + horizon, c-box))
              if extra-content != none {
                grid-cells.push(
                  grid.cell(
                    x: 0,
                    y: trk,
                    align: right + horizon,
                    fill: if debug { rgb("#00edfa") } else { none },
                    extra-content,
                  ),
                )
              }
            }
          } else {
            // LTR
            if should-hang-kaeriten and extra-content != none {
              // Hang Kaeriten: Split Row for LTR
              // Connector in Top Half (y: 1)
              // Move connector down by 0.25em
              let moved-c = move(dy: 0.25em, c-box)
              grid-cells.push(grid.cell(x: trk, y: 1, align: center + horizon, moved-c)) // rowspan=1
              // Kaeriten in Bottom Half (y: 2) (Under the hyphen)
              grid-cells.push(
                grid.cell(
                  x: trk,
                  y: 2,
                  align: center + top,
                  fill: if debug { rgb("#00edfa") } else { none },
                  extra-content,
                ),
              )
            } else {
              // Connector in `x: trk`.
              // `y: 1, rowspan: 2`.
              grid-cells.push(grid.cell(x: trk, y: 1, rowspan: 2, align: center + horizon, c-box))
              // Kaeriten (extra)
              if extra-content != none {
                grid-cells.push(
                  grid.cell(
                    x: trk,
                    y: 3,
                    align: center + top,
                    fill: if debug { rgb("#00edfa") } else { none },
                    extra-content,
                  ),
                )
              }
            }
          }
        }
      }


      // Merged Readings and Left Ruby
      if merged-reading != none or merged-okurigana != none {
        let rc = if merged-reading != none {
          let content = format-annotation(merged-reading, ruby-size, ruby-tracking)
          if writing-direction == ttb {
            v(ruby-vertical-offset)
            content
          } else {
            content
          }
        } else { none }
        let oc = if merged-okurigana != none {
          move(
            dx: okurigana-x-offset,
            dy: okurigana-y-offset,
            format-annotation(merged-okurigana, okurigana-size, okurigana-tracking),
          )
        } else { none }

        let merged-content = stack(
          dir: writing-direction,
          spacing: okurigana-tracking,
          ..(rc, oc).filter(x => x != none),
        )
        // Note: For connected-group, layout is simple expansion.
        // We use the stack to hold ruby + okurigana.

        if writing-direction == ttb {
          grid-cells.push(
            grid.cell(
              x: 3,
              y: 0,
              rowspan: current-track-idx,
              align: left + horizon,
              fill: if debug { rgb("#ff8aed47") } else { none },
              merged-content,
            ),
          )
        } else {
          grid-cells.push(
            grid.cell(
              x: 0,
              y: 0,
              colspan: current-track-idx - extra-ltr-tracks,
              align: center + bottom,
              fill: if debug { rgb("#ff8aed47") } else { none },
              merged-content,
            ),
          )
        }
      }
      if merged-left-ruby != none {
        let lrc = format-annotation(merged-left-ruby, ruby-size, ruby-tracking)
        if writing-direction == ttb {
          grid-cells.push(
            grid.cell(
              x: 0,
              y: 0,
              rowspan: current-track-idx,
              align: right + horizon,
              fill: if debug { rgb("#f2666647") } else { none },
              lrc,
            ),
          )
        } else {
          grid-cells.push(
            grid.cell(
              x: 0,
              y: 3,
              colspan: current-track-idx - 2,
              align: center + top,
              fill: if debug { rgb("#f2666647") } else { none },
              lrc,
            ),
          )
        }
      }

      return grid(
        stroke: if debug { 0.1pt + black } else { none },
        columns: if writing-direction == ttb { (0.5em, 0.5em, 0.5em, 0.5em) } else { grid-tracks },
        rows: if writing-direction == ttb { grid-tracks } else { (0.5em, 0.5em, 0.5em, 0.5em) },
        column-gutter: if writing-direction == ttb {
          (ruby-gutter, 0em, ruby-gutter)
        } else {
          grid-gutters
        },
        row-gutter: if writing-direction == ttb {
          grid-gutters
        } else {
          (ruby-gutter, 0em, calc.max(ruby-gutter, annotation-gutter))
        },
        align: center + horizon,
        ..grid-cells,
        fill: if debug { rgb(23, 45, 128, 50%) } else { none }
      )
    }

    if node.type == "punctuation" {
      return grid(
        columns: if writing-direction == ttb { (0.5em, 1em, 0.5em) } else { (1em,) },
        rows: if writing-direction == ttb { (1em,) } else { (0.5em, 1em, 0.5em) },
        align: center + horizon,
        grid.cell(
          x: if writing-direction == ttb { 1 } else { 0 },
          y: if writing-direction == ttb { 0 } else { 1 },
          node.surface,
        ),
        fill: if debug { rgb(128, 45, 128, 50%) } else { none },
      )
    }

    if node.type == "quotation" {
      return grid(
        columns: if writing-direction == ttb { (0.5em, 1em, 0.5em) } else { (1em,) },
        rows: if writing-direction == ttb { (1em,) } else { (2em,) },
        align: center + horizon,
        grid.cell(
          x: if writing-direction == ttb { 1 } else { 0 },
          align: if writing-direction == ttb {
            if node.surface == "「" or node.surface == "『" {
              right + top
            } else {
              left + top
            }
          } else {
            center + horizon
          },
          node.surface,
          fill: if debug { rgb(128, 128, 45, 50%) } else { none },
        ),
      )
    }

    let surface = node.surface
    let reading = node.at("reading", default: none)
    let okurigana = node.at("okurigana", default: none)
    let kaeriten = node.at("kaeriten", default: none)
    let left-ruby = node.at("left-ruby", default: none)
    let left-okurigana = node.at("left-okurigana", default: none)

    let reading-content = if reading != none {
      format-annotation(reading, ruby-size, ruby-tracking)
    } else { none }

    let okurigana-content = if okurigana != none {
      move(
        dx: okurigana-x-offset,
        dy: okurigana-y-offset,
        format-annotation(okurigana, okurigana-size, okurigana-tracking),
      )
    } else { none }

    let left-okurigana-content = if left-okurigana != none {
      format-annotation(left-okurigana, okurigana-size, okurigana-tracking)
    } else { none }

    let kaeriten-content = if kaeriten != none {
      move(dx: kaeriten-offset, text(size: 0.5em)[#format-kaeriten(kaeriten)])
    } else { none }

    let left-ruby-content = if left-ruby != none {
      format-annotation(left-ruby, ruby-size, ruby-tracking)
    } else { none }

    let punctuation-content = if punctuation != none {
      align(
        top + right,
        if punctuation.surface == "〻" {
          text(size: 0.5em, punctuation.surface)
        } else {
          move(
            ..if writing-direction == ttb { punctuation-offset } else {
              (dx: punctuation-offset.dy, dy: punctuation-offset.dx)
            },
            punctuation.surface,
          )
        },
      )
    } else { none }


    let kanji-cell = if writing-direction == ttb {
      (x: 1, y: 1, colspan: 2, rowspan: 2)
    } else {
      (x: 0, y: 1, colspan: 2, rowspan: 2)
    }

    let should-merge-right = (writing-direction == ttb and reading != none and (okurigana != none or tight))

    let ruby-cell = if writing-direction == ttb {
      if should-merge-right {
        if tight {
          (x: 3, y: 1, rowspan: 3, align: left + top)
        } else {
          (x: 3, y: 0, rowspan: 4, align: left + bottom)
        }
      } else if not tight and reading != none and okurigana == none {
        (x: 3, y: 1, rowspan: 2, align: left + horizon) // Ruby Only (Non-Tight)
      } else {
        (x: 3, y: 0, rowspan: 2, align: left + bottom) // Default or Okurigana-only (Ruby cell empty anyway)
      }
    } else {
      (x: 0, y: 0, colspan: 2, align: center + bottom)
    }

    let okurigana-cell = if writing-direction == ttb {
      if should-merge-right {
        none
      } else if not tight and reading != none and okurigana == none {
        none // Ruby Only mode covers this space
      } else {
        (x: 3, y: 2, align: left + top, rowspan: 2)
      }
    } else {
      (x: 2, y: 0, rowspan: 2, align: left + horizon)
    }

    let should-merge-left = (writing-direction == ttb and not tight)

    // Kaeriten & Left Okurigana placement
    let kaeriten-cell = if writing-direction == ttb {
      (x: 1, y: 3, align: right + top)
    } else {
      (x: 3, y: 2, rowspan: 2, align: right + horizon) // LTR TBD: maybe (1, 3, colspan: 2)?
    }

    let left-ruby-cell = if writing-direction == ttb {
      if should-merge-left {
        (x: 0, y: 1, rowspan: 3, align: right + horizon)
      } else {
        (x: 0, y: 1, rowspan: 2, align: right + horizon)
      }
    } else {
      (x: 0, y: 3, colspan: 2, align: center + top) // Bottom (Sidenote)
    }

    let punctuation-cell = if writing-direction == ttb {
      (x: 2, y: 3, align: right + top)
    } else {
      (x: 2, y: 2, rowspan: 2, align: center + horizon) // LTR TBD
    }

    grid(
      columns: if writing-direction == ttb {
        (0.5em, 0.5em, 0.5em, 0.5em)
      } else {
        if tight {
          (auto, 0.5em, auto, if punctuation-content != none { 0.5em } else { auto })
        } else {
          (0.5em, 0.5em, 0.5em, 0.5em)
        }
      },
      rows: if writing-direction == ttb {
        if tight {
          (auto, 0.5em, 0.5em, auto)
        } else {
          (0.5em, 0.5em, 0.5em, 0.5em)
        }
      } else {
        (0.5em, 0.5em, 0.5em, 0.5em)
      },
      column-gutter: if writing-direction == ttb {
        (ruby-gutter, 0em, ruby-gutter)
      } else {
        (0em, annotation-gutter, 0em)
      },
      row-gutter: if writing-direction == ttb {
        (0em, ruby-okurigana-gutter, annotation-gutter)
      } else {
        (ruby-gutter, 0em, calc.max(ruby-gutter, annotation-gutter))
      },

      align: (center + horizon),
      // Default alignment

      // Center: Kanji (2x2)
      grid.cell(
        ..kanji-cell,
        fill: if debug { rgb("#a1ff8a47") } else { none },
        surface,
      ),

      // Right/Top: Reading (Ruby) - OR Merged Right Annotation
      grid.cell(
        ..ruby-cell,
        fill: if debug {
          rgb("#ff8aed47")
        },
        if should-merge-right {
          // Use component specific formatting
          let reading-content = if reading != none {
            if writing-direction == ttb {
              v(ruby-vertical-offset)
            }
            format-annotation(reading, ruby-size, ruby-tracking)
          } else { none }
          let okurigana-content = if okurigana != none {
            format-annotation(okurigana, okurigana-size, okurigana-tracking)
          } else { none }

          stack(
            dir: writing-direction,
            spacing: okurigana-tracking, // Transition spacing
            ..(reading-content, okurigana-content).filter(x => x != none),
          )
        } else {
          if reading != none {
            if writing-direction == ttb {
              v(ruby-vertical-offset)
            }
            format-annotation(reading, ruby-size, ruby-tracking)
          } else { none }
        },
      ),

      // Right/Right: Okurigana (Only if not merged)
      if okurigana-cell != none {
        grid.cell(
          ..okurigana-cell,
          fill: if debug {
            rgb("#fac400")
          },
          okurigana-content,
        )
      },

      // Left/Bottom-Left: Kaeriten & Left Okurigana
      // Left/Bottom-Left: Kaeriten & Left Okurigana (Adjusted for Merge)
      grid.cell(
        ..kaeriten-cell,
        fill: if debug {
          rgb("#00edfa")
        },
        stack(
          dir: writing-direction,
          spacing: if left-okurigana-content != none and kaeriten-content != none and not should-merge-left {
            0.1em
          } else { 0em },
          if should-merge-left { none } else { left-okurigana-content },
          kaeriten-content,
        ),
      ),

      // Left/Center: Left Ruby - OR Merged Left Annotation
      grid.cell(
        ..left-ruby-cell,
        fill: if debug {
          rgb("#f2666647")
        },
        if should-merge-left {
          let children = ()
          if left-ruby != none {
            children += left-ruby.clusters().map(x => text(size: ruby-size)[#x])
          }
          if left-okurigana != none {
            children += left-okurigana.clusters().map(x => text(size: okurigana-size)[#x])
          }
          stack(
            dir: writing-direction,
            spacing: ruby-tracking,
            ..children,
          )
        } else {
          left-ruby-content
        },
      ),

      // Punctuation
      if punctuation-content != none {
        grid.cell(
          ..punctuation-cell,
          fill: if debug { rgb("#0905ff47") } else { none },
          punctuation-content,
        )
      },

      fill: if debug { rgb(23, 45, 128, 50%) } else { none },
    )
  }

  let segments = ()
  let current-segment = ()
  let current-len = 0pt

  let abs-height = if height != auto { measure(v(height)).height } else { auto }

  let i = 0
  while i < nodes.len() {
    let node = nodes.at(i)
    if node.type == "newline" {
      segments.push(current-segment)
      current-segment = ()
      current-len = 0pt
      i += 1
      continue
    }

    let punctuation = none
    if (
      (node.type == "character" or node.type == "connected-group")
        and i + 1 < nodes.len()
        and nodes.at(i + 1).type == "punctuation"
    ) {
      punctuation = nodes.at(i + 1)
      i += 1
    }

    let u = make-unit(node, punctuation: punctuation)
    let size = measure(u)
    let dim = if writing-direction == ttb { size.height } else { size.width }

    if (
      abs-height != auto and current-len + dim > abs-height and current-segment.len() > 0
    ) {
      segments.push(current-segment)
      current-segment = (u,)
      current-len = dim
    } else {
      current-segment.push(u)
      current-len += dim
    }
    i += 1
  }
  segments.push(current-segment)

  let block-dir = if writing-direction == ttb { rtl } else { ttb }

  let render-segment(segment) = {
    stack(dir: writing-direction, spacing: char-spacing, ..segment)
  }

  box(
    width: 100%,
    stack(dir: block-dir, spacing: leading, ..segments.map(render-segment)),
  )
}


/// ピュアテキストの漢文訓点アノテーションから疑似縦書き訓点等付きのレンダリング
///
/// - tight (bool): trueの場合はアキ組、falseの場合はベタ組
/// - color-hypen (auto, color): 縦棒（ハイフン）の色
/// - hypen (function): 縦棒（ハイフン）のレンダラー
/// - ruby-tracking (length): 読みがな（ルビー、ふりがな）の字間
/// - okurigana-tracking (length): 送り仮名の字間
/// - ruby-size (length): 読みがな（ルビー、ふりがな）の大きさ（フォントサイズ）
/// - writing-direction (ltr, ttb): 漢文の向き
/// - okurigana-size (length): 送り仮名の大きさ（フォントサイズ）
/// - ruby-gutter (length): 読みがな（ルビー）と親文字の間隔
/// - annotation-gutter (length): 注釈（送り仮名、返り点）と親文字の間隔
/// - hang-kaeriten-on-connector (bool): 接続符（ハイフン）に返り点をぶら下げるかどうか
/// - max-chars-for-kaeriten-hanging-on-hyphen (int): 接続符（ハイフン）に返り点をぶら下げる際の文字数制限（指定した文字数より多い場合はぶら下げない）
/// - line-spacing (length): 行間
/// - use-unicode-kanbun (bool): trueの場合はUnicode漢文記号を使用、falseの場合はフォント互換性のため標準的な文字を使用
/// - kaeriten-offset (length): 返り点の水平方向の位置調整 (デフォルトは0pt, 推奨は-0.5em)
/// - okurigana-x-offset (length): 送り仮名の水平方向の位置調整 (デフォルトは0pt, 0.25em推奨)
/// - okurigana-y-offset (length): 送り仮名の垂直方向の位置調整 (デフォルトは0pt, 0.25em推奨)
/// - ruby-vertical-offset (length): 読みがな（ルビー）の縦方向の位置調整 (縦書き時のフォントパディング補正用)
/// - body (string, content): 漢文の文字列またはコンテンツノードリスト
/// ->
#let kanbun(..args) = render-kanbun(parse-kanbun(..args.pos()), ..args.named())
