// ============================================================
// 三线表模块 (Three-line Table Module)
// ============================================================
//
// 本模块提供符合学术规范的三线表功能。
// This module provides academic-standard three-line table functionality.
//
// 什么是三线表 / What is a three-line table:
// 三线表是学术出版物中最常用的表格样式，以三条水平线为特征，
// 无竖线，视觉简洁、信息层次清晰：
// The three-line table is the most common table style in academic publications,
// characterized by three horizontal rules and no vertical rules:
//
//  ═══════════════════════  ← 顶线 1.5pt（粗）/ Top rule 1.5pt (heavy)
//  Header | Header | Header
//  ───────────────────────  ← 中线 0.5pt（细）/ Middle rule 0.5pt (light)
//  Data   | Data   | Data
//  Data   | Data   | Data
//  ═══════════════════════  ← 底线 1.5pt（粗）/ Bottom rule 1.5pt (heavy)
//
// 表格语法（基于 tablem）/ Table syntax (powered by tablem):
// 使用 Markdown 风格的管道符语法：
// Uses Markdown-style pipe syntax:
//
//  | Header 1 | Header 2 | Header 3 |
//  | -------- | -------- | -------- |   ← 分隔行，必须存在 / Required separator row
//  | Cell 1   | Cell 2   | Cell 3   |
//
// 对齐控制 / Alignment control:
//  | :Left | :Center: | Right: |
//
// 单元格合并 / Cell merging:
//  | Span | <    |    ← < 向左合并 / < merges left
//  | A    | Span |
//  | ^    | B    |    ← ^ 向上合并 / ^ merges up
//
// 导出函数 / Exported Functions:
// - cap-table(): 三线表主函数（Three-line table main function）
// - tlt: cap-table 的国际化别名（International alias）
// - biaoge: cap-table 的中文拼音别名（Chinese alias）
//
// 依赖 / Dependencies:
// - @preview/tablem:0.3.0 — Markdown 表格解析
// - src/config.typ         — 全局配置和辅助函数
// - src/bicap.typ          — 标题内容生成引擎
//
// ============================================================

#import "@preview/tablem:0.3.0": tablem
#import "config.typ": *
#import "bicap.typ": _make_caption_content

/// 创建三线表，支持 Markdown 语法、双语标题、续表和自定义线条。
/// Create a three-line table with Markdown syntax, bilingual captions, continuation, and custom lines.
///
/// - columns (auto | int | array): 列配置 / Column config（推荐用法 / preferred）
/// - cols (auto | int | array): columns 的向后兼容别名 / Back-compat alias for columns
/// - size (auto | length): 表格内容字号 / Table content font size
/// - leading (auto | length): 表格内容行距 / Table content line spacing
/// - inset (auto | length | dictionary): 单元格内边距 / Cell padding
/// - caption (none | content): 主语言标题 / Main language caption
/// - caption-en (none | content): 英文标题 / English caption
/// - refer-to (none | label): 续表引用的原表标签 / Original label for continuation
/// - show-caption (auto | bool): 续表是否显示标题文本 / Show caption in continuation
/// - top-rule (auto | stroke): 顶线粗细，接受任何 stroke 值（如 1.5pt + red）/ Top rule stroke
/// - middle-rule (auto | stroke): 中线粗细 / Middle rule stroke
/// - bottom-rule (auto | stroke): 底线粗细 / Bottom rule stroke
/// - hlines (array): 额外横线，每项为 `(row: int, start: int, end: none|int, stroke: stroke)` / Extra h-rules
/// - vlines (array): 额外竖线，每项为 `(col: int, start: int, end: none|int, stroke: stroke)` / Extra v-rules
/// - label (none | label): 表格标签，用于交叉引用 / Label for cross-reference
/// - content (content): Markdown 风格的表格内容 / Markdown-style table content
#let captab(
  columns: auto,
  cols: auto,        // 向后兼容别名 / back-compat alias for columns
  size: auto,
  leading: auto,
  inset: auto,
  caption: none,
  caption-en: none,
  refer-to: none,
  show-caption: auto,
  top-rule: auto,
  middle-rule: auto,
  bottom-rule: auto,
  hlines: (),
  vlines: (),
  label: none,
  content
) = {
  // columns 优先；cols 作为兼容别名 / columns wins; cols is back-compat alias
  let columns = if columns != auto { columns } else { cols }

  context {
    // 读取全局配置状态（在 context 中才能读取）
    // Read global config state (only readable inside context)
    let percentage = table-width-config.get()
    let config = table-style-config.get()

    // 解析样式参数：优先使用传入值，否则使用全局配置
    // Resolve style params: prefer passed value, fall back to global config
    let final-size = if size == auto { config.body-size } else { size }
    let final-leading = if leading == auto { config.body-leading } else { leading }
    let final-inset = if inset == auto { config.cell-inset } else { inset }
    let final-top-rule = if top-rule != auto { top-rule } else { config.at("top-rule", default: 1.5pt) }
    let final-middle-rule = if middle-rule != auto { middle-rule } else { config.at("middle-rule", default: 0.5pt) }
    let final-bottom-rule = if bottom-rule != auto { bottom-rule } else { config.at("bottom-rule", default: 1.5pt) }

    // 解析文档语言和首行缩进修复标志 / Resolve language and indent-fix flag
    let (doc-lang, should-indent) = resolve-lang-indent(config)

    // ── 构建表格主体 ─────────────────────────────────────────────
    // ── Build table body ─────────────────────────────────────────
    let table-body = {
      let raw-table = {
        // 设置文本和段落样式（在 tablem 解析前设置，会应用到所有单元格）
        // Set text/paragraph style before tablem parsing (applies to all cells)
        set text(size: final-size)
        set par(leading: final-leading)

        // 把外层的 columns 闭包别名为 user-columns，避免与 tablem render 回调
        // 的 columns 参数发生遮蔽 / Alias outer columns to avoid shadowing
        let user-columns = columns
        tablem(
          columns: user-columns,
          // tablem 的 render 回调：接收解析好的列数/对齐/单元格内容，
          // 由我们来决定如何渲染最终的 table
          // tablem's render callback: receives parsed columns/alignment/cells,
          // we decide how to render the final table
          render: (columns: auto, align: auto, ..args) => {
            // ── 处理列宽 ──────────────────────────────────────────
            // ── Handle column widths ──────────────────────────────
            let final-columns = if user-columns != auto {
              // 用户指定了 columns：直接使用（不管 tablem 解析到的列数）
              // User specified columns: use directly (ignore tablem-parsed column count)
              user-columns
            } else if type(columns) == int {
              // tablem 检测到 n 列（返回整数）：转换为 n 个等宽 fr 列
              // tablem detected n columns (returns int): convert to n equal-width fr columns
              (1fr,) * columns
            } else {
              // tablem 返回了列宽数组（来自 Markdown 对齐语法）：直接使用
              // tablem returned column width array (from Markdown alignment syntax): use directly
              columns
            }

            // ── 处理对齐 ──────────────────────────────────────────
            // ── Handle alignment ──────────────────────────────────
            let final-align = if align == auto {
              // 无对齐信息：默认居中+垂直居中
              // No alignment info: default to center + horizon
              center + horizon
            } else if type(align) == array {
              // 有对齐数组（来自 Markdown `:---:` 语法）：
              // 保留水平对齐，强制垂直居中
              // Alignment array (from Markdown `:---:` syntax):
              // keep horizontal alignment, force vertical center
              align.map(a => if a == auto { center + horizon } else { a + horizon })
            } else {
              align + horizon
            }

            // ── 构建表格内容列表 ───────────────────────────────────
            // ── Build table content list ───────────────────────────
            let table-content = ()

            // 三线表顶线（默认 1.5pt 粗，可由 top-rule / 全局配置覆盖；
            // 接受任何 stroke 值，如 1.5pt + red）
            // Top rule (default 1.5pt heavy, overridable via top-rule / global config;
            // accepts any stroke value, e.g. 1.5pt + red)
            table-content.push(table.hline(y: 0, stroke: final-top-rule))

            // 中线（默认 0.5pt 细，y=1 = 表头下方）/ Middle rule (default 0.5pt, below header)
            table-content.push(table.hline(y: 1, stroke: final-middle-rule))

            // 添加 tablem 解析到的单元格内容
            // Add tablem-parsed cell content
            table-content += args.pos()

            // ── 添加用户自定义额外横线 ─────────────────────────────
            // ── Add user-defined extra horizontal lines ─────────────
            for line in hlines {
              let y = line.at("row", default: 2)         // 默认第2行上方 / default: above row 2
              let start = line.at("start", default: 0)   // 默认从第0列开始 / default: from col 0
              let end = line.at("end", default: none)     // 默认到最右列 / default: to rightmost
              let stroke-style = line.at("stroke", default: 0.5pt)
              table-content.push(
                table.hline(y: y, start: start, end: end, stroke: stroke-style)
              )
            }

            // ── 添加用户自定义额外竖线 ─────────────────────────────
            // ── Add user-defined extra vertical lines ───────────────
            for line in vlines {
              let x = line.at("col", default: 1)         // 默认第1列右侧 / default: right of col 1
              let start = line.at("start", default: 0)
              let end = line.at("end", default: none)
              let stroke-style = line.at("stroke", default: 0.5pt)
              table-content.push(
                table.vline(x: x, start: start, end: end, stroke: stroke-style)
              )
            }

            // 底线（默认 1.5pt 粗；可由 bottom-rule / 全局配置覆盖）
            // Bottom rule (default 1.5pt; overridable via bottom-rule / global config)
            table-content.push(table.hline(stroke: final-bottom-rule))

            // ── 处理 inset（单元格内边距）─────────────────────────
            // ── Process inset (cell padding) ───────────────────────
            // inset 可以是字典（{x: ..., y: ...}）或标量（统一应用）
            // inset can be a dict ({x: ..., y: ...}) or scalar (uniform)
            let final-table-inset = if type(final-inset) == dictionary {
              final-inset
            } else {
              // 标量转换为 x/y 字典
              // Convert scalar to x/y dict
              (x: final-inset, y: final-inset)
            }

            // 渲染最终的 Typst table（无描边，由我们手动添加三线）
            // Render the final Typst table (no stroke, we add rules manually)
            table(
              columns: final-columns,
              stroke: none,             // 禁用默认描边 / Disable default stroke
              align: final-align,
              inset: final-table-inset,
              ..table-content           // 展开所有内容（线条+单元格）/ Spread all content
            )
          },
          content
        )
      }

      // ── 应用表格宽度百分比 ────────────────────────────────────
      // ── Apply table width percentage ─────────────────────────
      // 通过在左右添加等量 padding 来实现居中缩窄效果
      // Centering + narrowing achieved by adding equal padding on both sides
      let margin-percent = (100 - percentage) / 2
      pad(
        left: margin-percent * 1%,
        right: margin-percent * 1%,
        block(
          width: 100%,
          align(center, raw-table)
        )
      )
    }

    // ── 组合标题和表体 ────────────────────────────────────────────
    // ── Combine caption and table body ───────────────────────────
    //
    // 三种情况：
    // Three cases:
    // 1. 有标题 + 续表（refer-to 非 none）
    //    Has caption + continuation
    // 2. 有标题 + 主表（refer-to 为 none）
    //    Has caption + main table
    // 3. 无标题（只有表体）
    //    No caption (table body only)
    //
    // 标题和表体放在同一个不换页 block 中，防止跨页分离
    // Caption and body are in the same non-breakable block to prevent page splits

    if caption != none {
      // 续表不设置标签（避免重复引用），主表才设置 label
      // Continuation gets no label (avoid duplicate refs); main table gets the label
      let is-continuation = refer-to != none
      block(
        breakable: false,
        above: config.caption-above,
        below: config.table-below,
      )[
        #align(center)[
          #_make_caption_content(
            caption: caption,
            caption-en: caption-en,
            refer-to: refer-to,
            label: if is-continuation { none } else { label },
            config: config,
            kind: "table",
            show-caption: show-caption,
          )
        ]
        // 标题与表体之间的间距；减去 1em 是因为 block 的 below 已贡献默认段距
        // Gap between caption and body; subtract 1em because block below contributes default paragraph spacing
        #v(config.caption-below - 1em)
        #table-body
      ]
      if should-indent { _fakepar }
    } else {
      // ─ 无标题：直接输出表体 ─ (No caption: output table body only)
      table-body
      if should-indent { _fakepar }
    }
  }
}

