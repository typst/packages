// ============================================================
// 图片和子图模块 (Figure and Subfigure Module)
// ============================================================
//
// 本模块提供完整的图片处理功能，包括单图片和多子图布局。
// This module provides complete figure functionality, including
// single figures and multi-subfigure layouts.
//
// 模块结构 / Module Structure:
//
// ┌─────────────────────────────────────────────────────────┐
// │ cap-figure()                                            │
// │   单图片：content + 双语标题 + 间距控制                │
// │   Single figure: content + bilingual caption + spacing  │
// └─────────────────────────────────────────────────────────┘
//
// ┌─────────────────────────────────────────────────────────┐
// │ capsubfig()                                              │
// │   子图网格：多个图片排列 + 子标题/覆盖标签 + 主标题    │
// │   Subfigure grid: multiple images + sub/overlay labels  │
// │                                                         │
// │   内部辅助：                                           │
// │   Internal helpers:                                     │
// │   - _parse-label-style()   解析标签样式字符串          │
// │   - _make-label-text()     生成标签文字（含编号）      │
// │   - _add-overlay-label()   在图片上叠加标签            │
// └─────────────────────────────────────────────────────────┘
//
// 子图标签样式 / Subfigure label styles:
// 支持多种格式，可通过 label-style 参数配置：
// Multiple formats via the label-style parameter:
//
//  "(a)" → (a), (b), (c), ...     括号小写字母 / Parenthesized lowercase
//  "(A)" → (A), (B), (C), ...     括号大写字母 / Parenthesized uppercase
//  "(1)" → (1), (2), (3), ...     括号数字 / Parenthesized numbers
//  "(i)" → (i), (ii), (iii), ...  括号小写罗马数字 / Parenthesized roman lowercase
//  "(I)" → (I), (II), (III), ...  括号大写罗马数字 / Parenthesized roman uppercase
//  "图a" → 图a, 图b, 图c, ...    中文前缀 / Chinese prefix
//  "a)"  → a), b), c), ...        仅后缀括号 / Trailing parenthesis only
//  "Fig. A" → Fig. A, Fig. B, ... 英文前缀 / English prefix
//
// 依赖 / Dependencies:
// - src/config.typ: 全局配置、辅助函数
// - src/bicap.typ:  标题生成引擎
//
// ============================================================

#import "config.typ": *
#import "bicap.typ": _make_caption_content

// ============================================================
// 单图片函数 (Single Figure Function)
// ============================================================

/// 创建带双语标题的单个图片，标题始终在图片下方。
/// Create a single figure with bilingual caption; caption always below image.
///
/// - content (content): 图片内容（通常为 `image()` 调用）/ Figure content (usually `image()`)
/// - caption (none | content): 主语言标题 / Main language caption
/// - caption-en (none | content): 英文标题 / English caption
/// - label (none | label): 图片标签，用于交叉引用 / Figure label for cross-references
/// - refer-to (none | label): 续图引用的原图标签 / Original label for continued figure
/// - show-caption (auto | bool): 续图是否显示标题文本 / Show caption in continued figure
/// - figure-above (auto | length): 图片上方间距 / Space above figure
/// - figure-below (auto | length): 图片下方间距 / Space below figure
/// - caption-above (auto | length): 标题与图片间距 / Space between image and caption
/// - caption-leading (auto | length): 标题行距 / Caption line spacing
#let capfig(
  content,
  caption: none,
  caption-en: none,
  label: none,
  refer-to: none,
  show-caption: auto,
  figure-above: auto,
  figure-below: auto,
  caption-above: auto,
  caption-leading: auto,
  // 浮动定位：none（默认，原地）/ top / bottom；auto 跟随全局
  // Floating placement; auto follows global. Forces non-breakable when active.
  placement: (),
) = {
  context {
    // 读取合并后的图片配置 / Read merged figure config
    let fig-config = figure-style-config.get()
    let table-config = table-style-config.get()

    // 解析间距参数（参数优先于全局配置）
    // Resolve spacing params (params take priority over global config)
    let final-figure-above = if figure-above != auto { figure-above } else { fig-config.figure-above }
    let final-figure-below = if figure-below != auto { figure-below } else { fig-config.figure-below }
    let final-caption-above = if caption-above != auto { caption-above } else { fig-config.caption-above }
    let final-caption-leading = if caption-leading != auto { caption-leading } else { fig-config.caption-leading }

    // 浮动定位：per-call > state > none
    // Floating placement: per-call > state > none
    let final-placement = if placement != () {
      placement
    } else {
      fig-config.at("placement", default: none)
    }

    // 构建传递给 bicap 的配置字典（基于 figure-style-config）
    // Build config dict for bicap (based on figure-style-config)
    let merged-config = fig-config

    // 注入本次调用的 caption-leading（可能被参数覆盖）
    // Inject caption-leading for this call (may be overridden by param)
    merged-config.insert("caption-leading", final-caption-leading)

    // 如果图片配置中语言是 auto，但表格配置中有具体语言设置，则继承之
    // If figure config lang is auto but table config has a specific lang, inherit it
    if fig-config.lang == auto and table-config.at("lang", default: auto) != auto {
      merged-config.insert("lang", table-config.lang)
    }

    // 将图片内容和标题放在居中的不换页 block 中
    // Place image content and caption in a centered non-breakable block
    let composed = align(center)[
      #block(
        breakable: false,   // 禁止图片和标题跨页分离 / Prevent page break between image and caption
        above: 0pt,         // 间距由外部 v() 控制，这里设为 0
                            // Spacing controlled by external v(), set to 0 here
        below: 0pt,
      )[
        // 图片内容
        // Image content
        #content
        // 标题上方间距
        // Space above caption
        #v(final-caption-above)
        // 直接调用内部标题生成函数（外层已有 block，不需要 bicap 的 block 包装）
        // Call the internal caption generator directly (outer block exists, so we don't need bicap's wrapper)
        #_make_caption_content(
          caption: caption,
          caption-en: caption-en,
          refer-to: refer-to,
          label: label,
          config: merged-config,
          kind: "figure",
          show-caption: show-caption,
        )
      ]
    ]

    // 浮动包装：placement: top/bottom 时把整体（含上下间距）float。
    // place() 在仅给 vertical alignment（top/bottom）时水平默认贴左——必须补 + center
    // 才能保留 cap-able 一贯的居中行为。Typst 原生 figure(placement: top) 内部也是这么做的。
    // 隐藏 figure 也一同 ride 进来，counter 在 float 落地时 step。
    // Float wrap. place() with vertical-only alignment (top/bottom) defaults horizontally
    // to left — we add `+ center` to keep cap-able's centered look (matches Typst's
    // native figure float behaviour). Hidden figure rides along.
    if final-placement != none {
      let aligned-placement = if final-placement == top { top + center }
        else if final-placement == bottom { bottom + center }
        else { final-placement }
      place(aligned-placement, float: true, composed)
    } else {
      // 图片上方间距（通过 v() 实现）
      // Space above figure (via v())
      v(final-figure-above)
      composed
      // 图片下方间距
      // Space below figure
      v(final-figure-below)
    }
  }
}

// ============================================================
// 子图辅助函数 (Subfigure Helper Functions)
// ============================================================
//
// 以下三个内部函数处理子图标签的解析、生成和渲染：
// The following three internal functions handle subfigure label
// parsing, generation, and rendering:
//
// 标签样式字符串的结构 / Label style string structure:
//   前缀 + 格式字符 + 后缀
//   prefix + format_char + suffix
//
// 例如 / Examples:
//   "(a)" → prefix="(", format="a", suffix=")"
//   "图a" → prefix="图", format="a", suffix=""
//   "Fig. A" → prefix="Fig. ", format="A", suffix=""
//   "a)"  → prefix="", format="a", suffix=")"
//
// 格式字符对应的编号序列 / Format char to numbering sequence:
//   "a" → a, b, c, ..., z
//   "A" → A, B, C, ..., Z
//   "1" → 1, 2, 3, ...
//   "i" → i, ii, iii, iv, v, ...
//   "I" → I, II, III, IV, V, ...
//
// ============================================================

/// 解析 label-style 为指定用途（overlay / subcaption）的字符串样式。
/// Resolve label-style to a string for the requested kind (overlay / subcaption).
///
/// label-style 接受两种形式 / label-style accepts two forms:
/// - `str`（如 `"(a)"`）：overlay 与 subcaption 使用同一样式（默认耦合）
///   `str` (e.g. `"(a)"`): both overlay and subcaption share the style (coupled by default)
/// - `dict`（如 `(overlay: "a)", subcaption: "(a)")`）：分别指定。缺失的键
///    回退到包默认 `"(a)"`，而不是回退到另一边——保持两边各自独立。
///   `dict` (e.g. `(overlay: "a)", subcaption: "(a)")`): per-side override.
///   Missing keys fall back to the package default `"(a)"`, *not* to the other side.
///
/// - style (str | dictionary): 标签样式 / Label style
/// - kind (str): "overlay" 或 "subcaption" / "overlay" or "subcaption"
/// -> str: 已解析为字符串的样式 / Resolved style string
#let _resolve-label-style(style, kind) = {
  if type(style) == str {
    style
  } else if type(style) == dictionary {
    style.at(kind, default: "(a)")
  } else {
    "(a)"
  }
}

/// 解析标签样式字符串，提取格式字符和前后缀
/// Parse label style string, extracting format character and prefix/suffix
///
/// 从标签样式字符串中定位第一个格式字符（a/A/1/i/I），
/// 将其前面的部分作为前缀，后面的部分作为后缀。
///
/// Locates the first format character (a/A/1/i/I) in the style string,
/// using everything before it as prefix and everything after as suffix.
///
/// *解析示例 / Parsing Examples:*
/// - "(a)" → `(format: "a", prefix: "(", suffix: ")")`
/// - "图a" → `(format: "a", prefix: "图", suffix: "")`
/// - "Fig. A" → `(format: "A", prefix: "Fig. ", suffix: "")`  ← 注意前缀里的 "i" 不会被误当作占位符
/// - "(1)" → `(format: "1", prefix: "(", suffix: ")")`
/// - "abc"（无格式字符）→ `(format: "a", prefix: "abc", suffix: "")`
///
/// - style (str): 标签样式字符串 / Label style string
/// -> dictionary: 包含 format, prefix, suffix 三个键的字典
///                Dictionary with keys: format, prefix, suffix
#let _parse-label-style(style) = {
  // 支持的格式字符列表
  // Supported format characters
  let format-chars = ("a", "A", "1", "i", "I")
  let format-char = none
  let format-pos = none

  // 从后向前扫描，找到最后一个格式字符及其位置。
  // Scan from the end to find the LAST format character.
  // 原因：前缀可能包含和格式字符重合的字母（例如 "Fig. A" 中的 "i"），
  // 从前向后扫描会误把 "i" 当作占位符。实际样式占位符总是出现在末尾
  // （"(a)"、"图a"、"Fig. A"、"(1)"），因此从后向前更稳健。
  // Reason: prefixes may contain letters that collide with format chars
  // (e.g. the "i" in "Fig. A"). Scanning forward would wrongly pick that "i"
  // as the placeholder. In practice the placeholder always sits at the end
  // ("(a)", "图a", "Fig. A", "(1)"), so scanning backward is more robust.
  // 注意：用 clusters() 而非 codepoints() 以正确处理多字节字符（如中文）
  // Note: use clusters() not codepoints() to handle multi-byte chars (e.g. Chinese)
  let all-clusters = style.clusters()
  let i = all-clusters.len()
  while i > 0 {
    i = i - 1
    if all-clusters.at(i) in format-chars {
      format-char = all-clusters.at(i)
      format-pos = i
      break
    }
  }

  // 如果没有找到任何格式字符，将整个字符串作为前缀，默认格式为 "a"
  // If no format character found, use entire string as prefix, default format "a"
  if format-char == none {
    return (format: "a", prefix: style, suffix: "")
  }

  // 提取前缀（格式字符前的所有字符）和后缀（格式字符后的所有字符）
  // Extract prefix (everything before format char) and suffix (everything after)
  let prefix = all-clusters.slice(0, format-pos).join()
  let suffix = all-clusters.slice(format-pos + 1).join()

  (format: format-char, prefix: prefix, suffix: suffix)
}

/// 根据索引和样式生成子图标签文本
/// Generate subfigure label text based on index and style
///
/// 使用 _parse-label-style 解析样式，然后根据格式字符和索引生成编号，
/// 最后组合前缀+编号+后缀（可选择是否保留修饰）。
///
/// Uses _parse-label-style to parse the style, generates the number
/// based on format char and index, then combines prefix+number+suffix
/// (optionally stripping decorations).
///
/// *生成示例 / Generation Examples（style="(a)"）:*
/// - idx=0 → "(a)"
/// - idx=1 → "(b)"
/// - idx=25 → "(z)"
///
/// *生成示例（style="(1)"）:*
/// - idx=0 → "(1)"
/// - idx=2 → "(3)"
///
/// *移除修饰 remove-decorations=true（style="(a)"）:*
/// - idx=0 → "a"（用于子图交叉引用的标签部分）
///           (used as the subfigure part of cross-reference)
///
/// - idx (int): 子图索引（从0开始）/ Subfigure index (0-based)
/// - style (str): 标签样式字符串 / Label style string
/// - remove-decorations (bool): 是否移除前缀和后缀（用于生成引用标签）
///                               Remove prefix/suffix (for cross-reference generation)
/// -> str: 生成的标签文本 / Generated label text
#let _make-label-text(idx, style, remove-decorations: false) = {
  let parsed = _parse-label-style(style)
  let format-char = parsed.format

  // 根据格式字符和索引生成编号文本
  // Generate number text based on format character and index
  let number-text = if format-char == "A" {
    // 大写字母：从 'A'(65) 开始，idx=0→"A", idx=1→"B"...
    // Uppercase: start from 'A'(65), idx=0→"A", idx=1→"B"...
    str.from-unicode(65 + idx)
  } else if format-char == "a" {
    // 小写字母：从 'a'(97) 开始
    // Lowercase: start from 'a'(97)
    str.from-unicode(97 + idx)
  } else if format-char == "1" {
    // 阿拉伯数字：从 1 开始
    // Arabic numerals: start from 1
    str(idx + 1)
  } else if format-char == "I" {
    // 大写罗马数字：使用预定义映射表（支持1-20）
    // Uppercase Roman numerals: use predefined map (supports 1-20)
    let roman-map = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
                     "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
    if idx < roman-map.len() { roman-map.at(idx) } else { str(idx + 1) }
  } else if format-char == "i" {
    // 小写罗马数字
    // Lowercase Roman numerals
    let roman-map = ("i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x",
                     "xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx")
    if idx < roman-map.len() { roman-map.at(idx) } else { str(idx + 1) }
  } else {
    // 未知格式字符的保底处理：使用小写字母
    // Fallback for unknown format char: use lowercase letter
    str.from-unicode(97 + idx)
  }

  // 根据 remove-decorations 决定是否添加前缀和后缀
  // Decide whether to add prefix/suffix based on remove-decorations
  if remove-decorations {
    // 只返回编号部分（用于生成交叉引用中的标签字符）
    // Return only the number part (for cross-reference label character)
    number-text
  } else {
    // 返回完整标签：前缀 + 编号 + 后缀
    // Return full label: prefix + number + suffix
    parsed.prefix + number-text + parsed.suffix
  }
}

/// 在图片内容上叠加标签
/// Add an overlay label on top of figure content
///
/// 将标签放置在子图的左上角（通过 place(top + left, ...) 实现）。
/// 标签可以有多种背景样式：无背景、矩形背景、圆形背景。
/// 每个子图可以通过 label-style-override 字典覆盖部分样式。
///
/// Places the label at the top-left of the subfigure via place(top + left, ...).
/// Labels can have: no background, rectangular background, or circular background.
/// Each subfigure can override partial styles via label-style-override dict.
///
/// 可覆盖的样式键 / Overridable style keys:
/// - text-color: 文字颜色 / Text color
/// - stroke: 描边 / Stroke
/// - bg: 背景色 / Background color
/// - bg-shape: 背景形状 / Background shape
/// - bg-radius: 背景圆角 / Background radius
/// - bg-inset: 背景内边距 / Background padding
/// - style: 该子图 overlay 的 label-style 字符串（如 "(I)"）/ Per-subfig overlay label-style
/// - font: 字体列表 / Font list
/// - size: 字号 / Font size
/// - offset: (dx, dy) 偏移量 / Offset from top-left
///
/// - content (content): 子图内容 / Subfigure content
/// - idx (int): 子图索引 / Subfigure index
/// - label-style (str): 标签样式字符串 / Label style string
/// - label-font (array): 字体列表 / Font list
/// - label-size (length): 字号 / Font size
/// - label-offset (tuple): (dx, dy) 偏移量，从左上角算起 / Offset from top-left
/// - label-text-color (color): 文字颜色 / Text color
/// - label-stroke (none | stroke): 描边 / Stroke
/// - label-bg (none | color): 背景色 / Background color
/// - label-bg-shape (str): 背景形状 "rect" 或 "circle" / "rect" or "circle"
/// - label-bg-radius (length): 矩形圆角 / Rect border radius
/// - label-bg-inset (length): 背景内边距 / Background padding
/// - override-style (none | dictionary): 针对此子图的样式覆盖 / Per-subfigure overrides
/// -> content: 含叠加标签的图片内容 / Figure content with overlay label
#let _add-overlay-label(
  content,
  idx,
  label-style,
  label-font,
  label-size,
  label-offset,
  label-text-color,
  label-stroke,
  label-bg,
  label-bg-shape,
  label-bg-radius,
  label-bg-inset,
  override-style: none,
) = {
  // 解析各样式参数：覆盖样式优先于全局样式
  // Resolve each style param: override takes priority over global
  let pick(key, fallback) = if override-style != none and key in override-style {
    override-style.at(key)
  } else {
    fallback
  }
  let overlay-text-color = pick("text-color", label-text-color)
  let overlay-stroke     = pick("stroke", label-stroke)
  let overlay-bg         = pick("bg", label-bg)
  let overlay-bg-shape   = pick("bg-shape", label-bg-shape)
  let overlay-bg-radius  = pick("bg-radius", label-bg-radius)
  let overlay-bg-inset   = pick("bg-inset", label-bg-inset)
  let overlay-style      = pick("style", label-style)
  let overlay-font       = pick("font", label-font)
  let overlay-size       = pick("size", label-size)
  let overlay-offset     = pick("offset", label-offset)

  // 用 box 包装图片内容，使 place() 相对于图片而非页面定位
  // Wrap figure content in box so place() positions relative to the figure, not the page
  box({
    // 图片内容
    content
    // 叠加标签（place 不占据文档流空间）
    // Overlay label (place doesn't take up document flow space)
    place(
      top + left,                 // 定位到左上角 / Anchor to top-left
      dx: overlay-offset.at(0),   // 水平偏移 / Horizontal offset
      dy: overlay-offset.at(1),   // 垂直偏移 / Vertical offset
      {
        // 生成标签文字内容（含前缀+编号+后缀）
        // Generate label text (with prefix+number+suffix)
        let label-content = text(
          font: overlay-font,
          size: overlay-size,
          weight: "bold",           // 标签通常加粗 / Labels are usually bold
          fill: overlay-text-color,
          stroke: overlay-stroke,
        )[#_make-label-text(idx, overlay-style, remove-decorations: false)]

        if overlay-bg != none {
          if overlay-bg-shape == "circle" {
            // ─ 圆形背景：使用 circle() 元素 ─
            // ─ Circular background: use circle() element ─
            circle(
              radius: overlay-size * 0.8,  // 圆的半径基于字号 / Radius based on font size
              fill: overlay-bg,
              stroke: overlay-stroke,
            )[
              #align(center + horizon)[#label-content]
            ]
          } else {
            // ─ 矩形背景（默认）：使用 box() 元素 ─
            // ─ Rectangular background (default): use box() element ─
            box(
              fill: overlay-bg,
              inset: overlay-bg-inset,
              radius: overlay-bg-radius,
              stroke: overlay-stroke,
            )[#label-content]
          }
        } else {
          // ─ 无背景：直接显示标签文字 ─
          // ─ No background: show label text directly ─
          label-content
        }
      }
    )
  })
}

// ============================================================
// 子图布局函数 (Subfigure Layout Function)
// ============================================================

/// 创建多子图网格布局，支持子标题、覆盖标签和主双语标题。
/// Create a multi-subfigure grid layout with subcaptions, overlay labels, and bilingual main caption.
///
/// 每个子图为字典：`(content: ..., subcaption: ..., label: ..., label-style-override: (...))` 。
/// Each subfigure is a dict: `(content: ..., subcaption: ..., label: ..., label-style-override: (...))`.
///
/// - subfigs (array): 子图字典数组 / Array of subfigure dicts
/// - columns (auto | int): 每行列数，auto=所有子图在一行 / Columns per row
/// - caption (none | content): 主标题（主语言）/ Main caption (main language)
/// - caption-en (none | content): 主标题（英文）/ Main caption (English)
/// - label (none | label): 主图标签 / Main figure label
/// - refer-to (none | label): 续图引用的原图标签 / Original label for continuation
/// - show-caption (auto | bool): 续图是否显示标题 / Show caption in continuation
/// - gutter (auto | length): 子图水平间距 / Horizontal gap between subfigures
/// - subcaption-pos (auto | str): 子标题位置 "top"/"bottom"
/// - show-subcaption (auto | bool): 是否显示子标题 / Show subcaptions
/// - show-subcaption-label (auto | bool): 子标题是否含标签 / Subcaption includes label
/// - align (auto | str): 垂直对齐 "top"/"horizon"/"bottom"
/// - label-mode (auto | none | str): 标签模式 / Label mode (none or "overlay")
/// - label-style (auto | str): 标签样式，如 "(a)"/"图a" / Label style
/// - label-font (auto | array): 标签字体 / Label font
/// - label-size (auto | length): 标签大小 / Label size
/// - label-offset (auto | tuple): 标签偏移 (dx, dy) / Label offset
/// - label-text-color (auto | color): 标签颜色 / Label text color
/// - label-stroke (auto | none | stroke): 标签描边 / Label stroke
/// - label-bg (auto | none | color): 标签背景 / Label background
/// - label-bg-shape (auto | str): 背景形状 / Background shape
/// - label-bg-radius (auto | length): 背景圆角 / Background radius
/// - label-bg-inset (auto | length): 背景内边距 / Background padding
/// - label-sep (auto | str): 子图引用分隔符 / Subfigure reference separator
/// - figure-above (auto | length): 图片上方间距 / Space above figure
/// - figure-below (auto | length): 图片下方间距 / Space below figure
/// - caption-above (auto | length): 主标题上方间距 / Space above main caption
/// - subcaption-above (auto | length): 子标题上方间距 / Space above subcaption
/// - subcaption-below (auto | length): 子标题下方间距 / Space below subcaption
#let capsubfig(
  subfigs,
  columns: auto,
  caption: none,
  caption-en: none,
  label: none,
  refer-to: none,
  show-caption: auto,
  gutter: auto,
  subcaption-pos: auto,
  show-subcaption: auto,
  show-subcaption-label: auto,
  align: auto,
  label-mode: auto,
  label-style: auto,
  label-font: auto,
  label-size: auto,
  label-offset: auto,
  label-text-color: auto,
  label-stroke: auto,
  label-bg: auto,
  label-bg-shape: auto,
  label-bg-radius: auto,
  label-bg-inset: auto,
  label-sep: auto,
  figure-above: auto,
  figure-below: auto,
  caption-above: auto,
  subcaption-above: auto,
  subcaption-below: auto,
  subcaption-number-title-spacing: auto,
  // 浮动定位：none / top / bottom；auto 跟随全局
  // Floating placement; auto follows global
  placement: (),
) = {
  // ★ 重要：立即重命名 align 参数，因为 Typst 中 `align` 既是函数又是关键字，
  // 如果不重命名，在函数体内调用 align(center, ...) 时会发生参数名遮蔽冲突。
  // ★ Important: Rename `align` parameter immediately because in Typst,
  // `align` is both a function and a keyword. Without renaming, calling
  // align(center, ...) inside would shadow/conflict with the parameter name.
  let vertical-align-param = align

  context {
    // 读取合并后的图片/子图配置 / Read merged figure/subfigure config
    let config = figure-style-config.get()

    // ── 解析所有参数（参数优先于全局配置）────────────────────────
    // ── Resolve all parameters (params take priority over global config) ──
    let final-gutter = if gutter != auto { gutter } else { config.gutter }
    let final-subcaption-pos = if subcaption-pos != auto { subcaption-pos } else { config.subcaption-pos }
    let final-show-subcaption = if show-subcaption != auto { show-subcaption } else { config.show-subcaption }
    let final-show-subcaption-label = if show-subcaption-label != auto { show-subcaption-label } else { config.show-subcaption-label }
    let final-align = if vertical-align-param != auto { vertical-align-param } else { config.align }
    let final-label-mode = if label-mode != auto { label-mode } else { config.label-mode }
    let final-label-style = if label-style != auto { label-style } else { config.label-style }
    let final-label-font = if label-font != auto { label-font } else { config.label-font }
    let final-label-size = if label-size != auto { label-size } else { config.label-size }
    let final-label-offset = if label-offset != auto { label-offset } else { config.label-offset }
    let final-label-text-color = if label-text-color != auto { label-text-color } else { config.label-text-color }
    let final-label-stroke = if label-stroke != auto { label-stroke } else { config.label-stroke }
    let final-label-bg = if label-bg != auto { label-bg } else { config.label-bg }
    let final-label-bg-shape = if label-bg-shape != auto { label-bg-shape } else { config.label-bg-shape }
    let final-label-bg-radius = if label-bg-radius != auto { label-bg-radius } else { config.label-bg-radius }
    let final-label-bg-inset = if label-bg-inset != auto { label-bg-inset } else { config.label-bg-inset }
    let final-label-sep = if label-sep != auto { label-sep } else { config.label-sep }

    let final-subcaption-above = if subcaption-above != auto { subcaption-above } else { config.subcaption-above }
    let final-subcaption-below = if subcaption-below != auto { subcaption-below } else { config.subcaption-below }

    // 子标题"编号-正文"分隔符：per-call > 全局 state > auto（继承大题注的 number-title-spacing）。
    // 大题注本身的 number-title-spacing 也可能是 auto（默认），此时再退回到语言表。
    // Subcaption number-text separator: per-call > global state > auto (inherit main
    // caption's number-title-spacing). The main number-title-spacing itself may be auto
    // (the default), in which case we fall back to the language table — same path bicap uses.
    let final-subcap-num-sep = {
      let configured = if subcaption-number-title-spacing != auto {
        subcaption-number-title-spacing
      } else {
        config.at("subcaption-number-title-spacing", default: auto)
      }
      if configured != auto {
        configured
      } else {
        let main-spacing = config.at("number-title-spacing", default: auto)
        if main-spacing != auto {
          main-spacing
        } else {
          get-table-text(resolve-lang-code(config.lang), "number-title-spacing")
        }
      }
    }

    // ── 将字符串对齐参数转换为 Typst 对齐值 ─────────────────────
    // ── Convert string alignment param to Typst alignment value ──
    let vertical-align = if final-align == "top" {
      top
    } else if final-align == "bottom" {
      bottom
    } else {
      horizon   // 默认居中对齐 / Default: center alignment
    }

    // ── 确定列数 ─────────────────────────────────────────────────
    // ── Determine number of columns ───────────────────────────────
    let cols = if columns == auto {
      // auto：所有子图放在同一行
      // auto: all subfigures in one row
      subfigs.len()
    } else {
      columns
    }

    // ── 确定子图引用分隔符 ────────────────────────────────────────
    // ── Determine subfigure reference separator ───────────────────
    // 分隔符用于交叉引用中主编号与子图标签之间（如 "图1.1a" 中的连接）
    // Separator between main number and subfig label in cross-references (e.g., "Figure 1.1a")
    // 解析 label-style 为 overlay / subcaption 两个分支的字符串样式。
    // Resolve label-style into per-kind strings.
    let final-label-style-overlay   = _resolve-label-style(final-label-style, "overlay")
    let final-label-style-subcap    = _resolve-label-style(final-label-style, "subcaption")

    // 交叉引用字母的样式来源：跟随"实际可见"的那一侧。
    //   - subcaption 可见（show-subcaption + show-subcaption-label）→ 取 subcaption
    //   - 否则若有 overlay → 取 overlay
    //   - 都不可见（用户既不显示 overlay，又关掉 subcaption-label）→ 仍以 subcaption
    //     作为兜底（语义上与正文最近；该情形下 @ref 也几乎无视觉锚点）。
    // 这样保证用户在图上/标题里"看到的字母"与 `@ref` 渲染出的字母一致。
    //
    // Cross-ref letter source follows whichever side is actually *visible*:
    //   - subcaption visible (show-subcaption + show-subcaption-label) → use subcaption
    //   - else overlay drawn → use overlay
    //   - neither visible → fall back to subcaption (defensive; user has no visual anchor)
    // This keeps the letter in `@ref` consistent with what the reader actually sees.
    let final-label-style-ref = if final-show-subcaption and final-show-subcaption-label {
      final-label-style-subcap
    } else if final-label-mode == "overlay" {
      final-label-style-overlay
    } else {
      final-label-style-subcap
    }

    let sep = if final-label-sep == auto {
      let parsed = _parse-label-style(final-label-style-ref)
      // 数字格式用点分隔（如 "图1.1.2"），字母格式无分隔（如 "图1.1a"）
      // Numeric format uses dot (e.g., "Fig.1.1.2"), letter format uses none (e.g., "Fig.1.1a")
      if parsed.format == "1" { "." } else { "" }
    } else {
      final-label-sep
    }

    // ── 将子图数组按行分组 ────────────────────────────────────────
    // ── Group subfigures into rows ────────────────────────────────
    let rows = ()
    let current-row = ()
    for (idx, subfig) in subfigs.enumerate() {
      current-row.push(subfig)
      // 每当当前行满了（达到列数）或者是最后一个子图时，封装当前行
      // Seal the current row when it's full (reached column count) or at the last subfig
      if current-row.len() == cols or idx == subfigs.len() - 1 {
        rows.push(current-row)
        current-row = ()
      }
    }

    // ── 构建子图内容（需要在 context 中进行，因为要读取计数器）──
    // ── Build subfigure content (needs context to read counters) ──
    let subfig-content = context {
      let fig-config = figure-style-config.get()
      // 计算主图编号字符串（与 _make_caption_content 中的逻辑保持一致）。
      // 支持 use-chapter=false（默认，仅编号）和 use-chapter=true（带章节前缀）。
      // Compute the main figure number string (matches _make_caption_content).
      // Supports both use-chapter=false (default, plain number) and true (with chapter prefix).
      let fig-num = counter(figure.where(kind: image)).get().first() + 1
      let main-num = if fig-config.use-chapter {
        let h = counter(heading).get()
        let chapter-nums = if type(fig-config.numbering-format) == str {
          h.slice(0, calc.min(fig-config.chapter-level, h.len()))
        } else {
          h
        }
        numbering(fig-config.numbering-format, ..chapter-nums, fig-num)
      } else {
        numbering(fig-config.numbering-format, fig-num)
      }

      // ════════════════════════════════════════════════════════════
      // 子图交叉引用注册（Hidden Figure Trick）
      // Subfigure Cross-Reference Registration (Hidden Figure Trick)
      // ════════════════════════════════════════════════════════════
      //
      // 对于每个有 label 的子图，我们需要：
      // For each subfig with a label, we need to:
      //
      // 1. 创建一个可引用的 figure（注册到计数器，可被 @ 引用）
      //    Create a referenceable figure (registered to counter, usable via @)
      // 2. 但该 figure 不应该：出现在目录、占据页面空间、显示内容
      //    But the figure should NOT: appear in outline, take page space, show content
      //
      // 解决方案：用 place(hide[#figure(...)#label]) 在当前位置"注册"一个
      // 不可见、不占空间的隐藏 figure，并绑定标签。
      // Solution: Use place(hide[#figure(...)#label]) to "register" an
      // invisible, zero-space hidden figure at current location with the label.
      //
      // 隐藏 figure 的编号格式设置为 "章号.图号+分隔符+子图字母"，
      // 例如 idx=0, style="(a)" → 编号函数返回 "1.1a"
      // The hidden figure's numbering is set to "chapter.fig-num+sep+label",
      // e.g. idx=0, style="(a)" → numbering returns "1.1a"
      //
      // 注意：每个隐藏 figure 都会使计数器 +1，所以最后需要批量减回去
      // Note: each hidden figure increments counter, so we batch-decrement afterwards

      let hidden-figures = ()
      let subfig-label-count = 0

      for (idx, subfig) in subfigs.enumerate() {
        if "label" in subfig and subfig.label != none {
          subfig-label-count = subfig-label-count + 1

          // 当 ref 跟随 overlay（subcaption 不可见、overlay 可见）时，需要让
          // 单图的 label-style-override.style 也参与计算——否则子图叠加显示
          // "(I)" 但 @ref 仍渲染 "a"。
          // 当 ref 跟随 subcaption 时，subcaption 没有逐子图覆盖，使用全局即可。
          //
          // When ref follows overlay (subcaption hidden, overlay drawn), we have
          // to honour the per-subfig label-style-override.style — otherwise the
          // overlay shows "(I)" while @ref still renders "a". When ref follows
          // subcaption there is no per-subfig override, so the global value is fine.
          let override = subfig.at("label-style-override", default: none)
          let subfig-overlay-style = if override != none and "style" in override {
            override.style
          } else {
            final-label-style-overlay
          }

          let subfig-ref-style = if final-show-subcaption and final-show-subcaption-label {
            final-label-style-subcap
          } else if final-label-mode == "overlay" {
            subfig-overlay-style
          } else {
            final-label-style-subcap
          }

          // 获取此子图的标签字母（不含修饰，如 "(a)" → "a"）
          // Get the label letter without decorations (e.g., "(a)" → "a")
          let sublabel = _make-label-text(idx, subfig-ref-style, remove-decorations: true)

          // sep 也跟随 ref-style：数字格式用 "."，字母格式用 ""。
          // 全局 label-sep 已显式设置时仍优先。
          // sep follows ref-style too: "." for numeric, "" for alpha.
          // Explicit global label-sep still takes priority.
          let subfig-sep = if final-label-sep == auto {
            let parsed = _parse-label-style(subfig-ref-style)
            if parsed.format == "1" { "." } else { "" }
          } else {
            final-label-sep
          }

          hidden-figures = hidden-figures + (
            place(
              hide[
                #figure(
                  kind: image,
                  supplement: if fig-config.supplement != auto {
                    fig-config.supplement
                  } else {
                    // 从语言配置获取图片前缀词（如 "图" 或 "Figure"）
                    // Get figure prefix from language config (e.g., "图" or "Figure")
                    get-table-text(resolve-lang-code(fig-config.lang), "figure")
                  },
                  // 设置子图的引用显示格式：主图编号 + 分隔符 + 子图字母
                  // Set subfig reference display: main-num + sep + sublabel
                  // 例如 main-num="1", sep="", sublabel="a" → "1a"
                  // 或 main-num="1.2", sep="", sublabel="a" → "1.2a"
                  // e.g. main-num="1", sep="", sublabel="a" → "1a"
                  //   or main-num="1.2", sep="", sublabel="a" → "1.2a"
                  numbering: _ => [#main-num#subfig-sep#sublabel],
                  outlined: false,    // 不出现在目录 / Not in outline
                  []
                )#subfig.label    // 绑定子图标签 / Bind subfigure label
              ]
            ),
          )
        }
      }

      // ── 逐行构建子图布局内容 ─────────────────────────────────
      // ── Build subfigure layout content row by row ─────────────
      let row-contents = ()
      for (row-idx, row-subfigs) in rows.enumerate() {
        let start-idx = row-idx * cols         // 此行第一个子图的全局索引
        let num-in-row = row-subfigs.len()     // 此行实际子图数
        // 最后一行且不满列（需要特殊处理 columns 参数）
        // Last row with fewer than full columns (needs special columns handling)
        let is-last-incomplete = num-in-row < cols and row-idx == rows.len() - 1

        // 提取共享的"处理单张子图内容"闭包：应用 overlay 标签（如有）
        // Shared "process one subfig content" closure: applies overlay label if needed
        let process-content(subfig, idx) = {
          let override = subfig.at("label-style-override", default: none)
          if final-label-mode == "overlay" {
            _add-overlay-label(
              subfig.content, idx,
              final-label-style-overlay, final-label-font, final-label-size,
              final-label-offset, final-label-text-color, final-label-stroke,
              final-label-bg, final-label-bg-shape, final-label-bg-radius, final-label-bg-inset,
              override-style: override,
            )
          } else {
            subfig.content
          }
        }

        // 统一处理本行所有子图 / Uniformly process all subfigs in this row
        let contents = ()
        let subcaptions = ()
        for (col-idx, subfig) in row-subfigs.enumerate() {
          let idx = start-idx + col-idx
          contents.push(process-content(subfig, idx))
          if final-show-subcaption {
            let cap-body = if final-show-subcaption-label {
              // 注意：markup 里 `#a #b` 之间会硬编码一个空格；
              // 这里改用 block 形式手动控制分隔符。
              // Note: markup `#a #b` hard-codes a space between them;
              // use block form to control the separator explicitly.
              {
                _make-label-text(idx, final-label-style-subcap, remove-decorations: false)
                final-subcap-num-sep
                subfig.subcaption
              }
            } else {
              subfig.subcaption
            }
            subcaptions.push(text(size: 10pt, cap-body))
          }
        }

        let row-cols = (1fr,) * (if is-last-incomplete { num-in-row } else { cols })

        if final-show-subcaption {
          // 有子标题：用 table 同时控制列间距和行间距
          // With subcaption: use table for both column-gutter and row-gutter
          row-contents.push(table(
            columns: row-cols,
            column-gutter: final-gutter,
            row-gutter: final-subcaption-above,
            stroke: none,
            align: center + vertical-align,
            ..if final-subcaption-pos == "top" {
              (..subcaptions, ..contents)
            } else {
              (..contents, ..subcaptions)
            }
          ))
        } else {
          // 无子标题：grid 更轻量 / No subcaption: grid is lighter
          row-contents.push(grid(
            columns: row-cols,
            column-gutter: final-gutter,
            align: center + vertical-align,
            ..contents
          ))
        }
      }

      // 将所有行内容垂直堆叠（使用 stack 而非 v() 以避免额外的空间）
      // Stack all row contents vertically (use stack instead of v() for precise spacing)
      //
      // ⚠ 计数器回退必须发生在 hidden-figures.join() 之后。
      // 在代码块里 `counter.update(...)` 作为裸语句会被拼进返回内容里，
      // 如果写在 hidden-figures 之前，布局时回退会早于 figure 增量执行，
      // 于是 `max(0, n - k)` 对初始为 0 的计数器无效、最终净多 +k，
      // 主图编号会变成"章号.(k+1)"（如 "1.3" 而非 "1.1"）。
      // ⚠ The counter rollback MUST emit AFTER hidden-figures.join().
      // Inside a code block, a bare `counter.update(...)` is concatenated into
      // the returned content stream; placing it before hidden-figures would
      // make the rollback fire before the figure increments. With an initial
      // counter of 0, `max(0, n - k)` is a no-op, leaving a net +k offset —
      // so the main caption renders as "chapter.(k+1)" (e.g. "1.3" not "1.1").
      [
        #hidden-figures.join()   // 先输出所有隐藏 figure（注册标签）/ Output hidden figures first
        // 批量减回隐藏 figure 造成的计数器增量；calc.max 保护避免布局迭代中 n<k 时报错
        // Batch-rollback the hidden-figure increments; calc.max guards against n<k during layout iterations
        #counter(figure.where(kind: image)).update(n => calc.max(0, n - subfig-label-count))
        #stack(dir: ttb, spacing: 1em, ..row-contents)   // 再垂直堆叠子图行 / Then stack rows
      ]
    }

    // ── 用 cap-figure 包装整个子图组合并添加主标题 ──────────────
    // ── Wrap the entire subfigure assembly with cap-figure for main caption ──
    capfig(
      subfig-content,
      caption: caption,
      caption-en: caption-en,
      label: label,
      refer-to: refer-to,
      show-caption: show-caption,
      figure-above: figure-above,
      figure-below: figure-below,
      caption-above: caption-above,
      placement: placement,
    )
  }
}
