// ============================================================
// 独立标题模块 (Standalone Caption Module)
// ============================================================
//
// 本模块提供独立的双语标题生成功能，是 cap-able 包的核心标题引擎。
// This module provides standalone bilingual caption generation,
// serving as the core caption engine of cap-able.
//
// 设计目标 / Design Goals:
// 1. 将"标题生成逻辑"与"表格/图片布局"解耦，使 cap-table、cap-figure 等
//    函数可以统一调用同一套标题逻辑。
//    Decouple "caption generation" from "table/figure layout", allowing
//    cap-table, cap-figure, etc. to share the same caption engine.
//
// 2. 支持主标题和续表/续图两种模式：
//    Support both main and continued (multi-page) caption modes:
//    - 主标题：自动分配新编号，写入计数器，可在目录中显示
//              Main caption: allocates a new number, writes to counter, appears in outline
//    - 续表/续图：引用原始标签的编号，不新增计数，不出现在目录
//                 Continued: references original label's number, no new counter, no outline entry
//
// 3. 支持 25+ 种语言的本地化文本，自动适配间距规则
//    Support 25+ language localizations with automatic spacing rules
//
// 4. 支持 RTL 语言（阿拉伯文、希伯来文、波斯文、乌尔都文）
//    Support RTL languages (Arabic, Hebrew, Persian, Urdu)
//
// 关键技术 / Key Technical Details:
// - 主标题通过插入一个 place(hide[#figure(...)]) 来注册编号，
//   然后立即将计数器减 1，最后在显示时再加 1，从而实现"占位但不渲染"。
//   Main caption registers a number by inserting a hidden figure via
//   place(hide[#figure(...)]), then decrements the counter by 1, and
//   increments when rendering — achieving "register without rendering".
//
// - 续表通过 query(refer-to) 查询原始标签所在位置的计数器值，
//   从而获得原始编号进行显示。
//   Continued captions use query(refer-to) to get the counter value
//   at the original label's location, retrieving its number.
//
// ============================================================

#import "config.typ": *

/// 内部函数：生成标题核心内容（不含外层 block 和间距），由 `bicap()` 和 `cap-table()` 共用。
/// Internal: generate core caption content (no outer block/spacing), shared by `bicap()` and `cap-table()`.
///
/// -> content
#let _make_caption_content(
  /// 主语言标题文本（续表时可为 none，仅显示编号）
  /// Main language caption text (can be none in continuation, showing only number)
  /// -> none | content
  caption: none,
  /// 英文标题文本（双语模式时使用）
  /// English caption text (used in bilingual mode)
  /// -> none | content
  caption-en: none,
  /// 续表/续图引用的原始标签（提供此参数则进入续表模式）
  /// Original label for continued table/figure (entering continuation mode when provided)
  /// -> none | label
  refer-to: none,
  /// 此标题的标签（用于交叉引用，如 <tab:results>）
  /// Label for this caption (for cross-referencing, e.g. <tab:results>)
  /// -> none | label
  label: none,
  /// 样式配置字典（来自 table-style-config 或 figure-style-config）
  /// Style configuration dictionary (from table-style-config or figure-style-config)
  /// -> dictionary
  config: none,
  /// 类型标识："table" 使用表格计数器；"figure" 使用图片计数器
  /// Type identifier: "table" uses table counter; "figure" uses image counter
  /// -> str
  kind: "table",
  /// 续表模式下是否显示标题文本。
  /// auto：若全局 continued-show-caption 也是 auto，则根据是否提供 caption 决定
  /// Whether to show caption text in continuation mode.
  /// auto: if global continued-show-caption is also auto, decided by whether caption is provided
  /// -> auto | bool
  show-caption: auto,
) = {
  context {
    // 确定实际使用的文档语言（可被 config.lang 覆盖，支持 region 区分如 zh-TW）
    // Determine actual document language (can be overridden by config.lang, supports region e.g. zh-TW)
    let doc-lang = resolve-lang-code(config.lang)

    // 根据 kind 确定使用哪组本地化键名
    // Determine which set of localization keys to use based on kind
    // "table" -> table/continued-prefix/continued-suffix 键
    // "figure" -> figure/fig-continued-prefix/fig-continued-suffix 键
    let supplement-key = if kind == "table" { "table" } else { "figure" }
    let continued-prefix-key = if kind == "table" { "continued-prefix" } else { "fig-continued-prefix" }
    let continued-suffix-key = if kind == "table" { "continued-suffix" } else { "fig-continued-suffix" }

    // ── 文本/间距解析辅助 / Text & spacing resolution helpers ──
    //
    // _resolve-main: 解析主语言文本。优先级：英文文档且有 *-en 配置 → *-en；
    //                否则主键配置（非 auto）→ 主键；否则按语言表自动取。
    // _resolve-main: main-lang text. English doc + *-en set → *-en;
    //                otherwise main key (non-auto) → main; else lang-table auto.
    //
    // _resolve-en: 解析英文行文本。优先级：*-en → main → 英文语言表。
    // _resolve-en: English-line text. Priority: *-en → main → English lang-table.
    //
    // _resolve-spacing: 解析间距字段。auto → 语言表取值；否则用配置值。
    // _resolve-spacing: spacing field. auto → lookup by lang; else config value.
    let _resolve-main(main-key, en-key, lang-key) = {
      let en-val = config.at(en-key, default: auto)
      let main-val = config.at(main-key, default: auto)
      if doc-lang == "en" and en-val != auto { en-val }
      else if main-val == auto { get-table-text(doc-lang, lang-key) }
      else { main-val }
    }
    let _resolve-en(main-key, en-key, lang-key) = {
      let en-val = config.at(en-key, default: auto)
      let main-val = config.at(main-key, default: auto)
      if en-val != auto { en-val }
      else if main-val != auto { main-val }
      else { get-table-text("en", lang-key) }
    }
    let _resolve-spacing(key) = {
      let v = config.at(key)
      if v == auto { get-table-text(doc-lang, key) } else { v }
    }

    // ── 解析主语言文本 / Resolve main language text ──
    let final-supplement         = _resolve-main("supplement", "supplement-en", supplement-key)
    let final-continued-prefix   = _resolve-main("continued-prefix", "continued-prefix-en", continued-prefix-key)
    let final-continued-suffix   = _resolve-main("continued-suffix", "continued-suffix-en", continued-suffix-key)

    // ── 解析英文行文本 / Resolve English-line text ──
    let final-supplement-en         = _resolve-en("supplement", "supplement-en", supplement-key)
    let final-continued-prefix-en   = _resolve-en("continued-prefix", "continued-prefix-en", continued-prefix-key)
    let final-continued-suffix-en   = _resolve-en("continued-suffix", "continued-suffix-en", continued-suffix-key)

    // ── 解析各种间距值 / Resolve spacing values ──
    let pre-spacing      = _resolve-spacing("pre-supplement-number-spacing")
    let post-spacing     = _resolve-spacing("post-supplement-number-spacing")
    let title-spacing    = _resolve-spacing("number-title-spacing")
    let title-spacing-en = _resolve-spacing("number-title-spacing-en")

    // 续表显示模式和全局"是否显示标题"配置
    // Continuation mode and global "show caption" setting
    let continued-mode = config.at("continued-mode", default: "prefix")
    let global-show-caption = config.at("continued-show-caption", default: auto)

    // 是否启用英文副标题
    // Whether bilingual English sub-caption is enabled
    let enable-en = config.enable-english-caption

    // 解析 caption-text 分层 dict（whole / prefix / supplement / number / body）。
    // 闭包内的 _line 会读取这里的 layers，无需逐处传参。
    // Resolve caption-text into layered sub-dicts; _line closes over `layers` below.
    let layers = _resolve-caption-text-layers(config.at("caption-text", default: (:)))

    // ── 统一标题行构造器 / Unified caption-line builder ──
    //
    // 按模板 `prefix [+pre-sp+num] [+post-sp+suffix] [+title-sp+title]` 拼接一行标题。
    // 任一部件为 none 则连同其间距一起跳过；rtl 为 true 时把各部件用 box 包裹以防方向混乱。
    // 各部件按 caption-text 分层包装：prefix-block (supplement + num + suffix) 外层包
    // layers.prefix；supplement/suffix 内再包 layers.supplement；num 包 layers.number；
    // title 包 layers.body。各层默认 `(:)` 为透明 wrap。
    // Builds one caption line. Each part is wrapped per the caption-text layers:
    // prefix-block (supplement + num + suffix) wrapped by layers.prefix; supplement and
    // suffix by layers.supplement; num by layers.number; title by layers.body.
    let _line(prefix, num, suffix, title, pre-sp, post-sp, title-sp, rtl: false) = {
      let b(p) = if rtl and p != none { box[#p] } else { p }
      // 先构建 prefix-block：supplement + (pre-sp + num) + (post-sp + suffix)
      let prefix-block = {
        if prefix != none { text(..layers.supplement)[#b(prefix)] }
        if num != none {
          if pre-sp != none { handle-spacing(pre-sp) }
          text(..layers.number)[#b(num)]
        }
        if suffix != none {
          if post-sp != none { handle-spacing(post-sp) }
          text(..layers.supplement)[#b(suffix)]
        }
      }
      text(..layers.prefix)[#prefix-block]
      if title != none {
        if title-sp != none { handle-spacing(title-sp) }
        text(..layers.body)[#b(title)]
      }
    }

    // 统一生成续表标题（包括主语言与可选的英文副标题）。
    // Unified builder for continuation captions (main line + optional English subline).
    //
    // - num: 原始表/图编号；若为 none 表示 query 未找到，采用降级格式
    //   Original table/figure number; none means query missed → fallback format
    // - is-suffix-mode: 续表模式（true=后缀"表X（续）"，false=前缀"续表X"）
    //   Continuation mode (true = suffix "Table X (cont)", false = prefix "Cont. Table X")
    // - show-title: 是否显示 caption 文本
    //   Whether to render caption text
    let _build-continuation-line(num: none, is-suffix-mode: true, show-title: false) = {
      let main-prefix  = if is-suffix-mode { final-supplement }        else { final-continued-prefix }
      let main-suffix  = if is-suffix-mode { final-continued-suffix }  else { none }
      let en-prefix    = if is-suffix-mode { final-supplement-en }     else { final-continued-prefix-en }
      let en-suffix    = if is-suffix-mode { final-continued-suffix-en } else { none }
      // 历史行为：降级（无编号）时跳过 pre-spacing，但仍保留 post-spacing。
      // Historical behavior: fallback (no num) drops pre-spacing but keeps post-spacing.
      let main-pre = if num != none { pre-spacing } else { none }
      let en-pre   = if num != none { [ ] } else { none }
      let title    = if show-title { caption } else { none }
      let title-en = if show-title { caption-en } else { none }

      if doc-lang == "en" and enable-en and caption-en != none {
        _line(main-prefix, num, main-suffix, title-en, main-pre, post-spacing, title-spacing)
      } else if enable-en and caption-en != none {
        let m = _line(main-prefix, num, main-suffix, title,    main-pre, post-spacing, title-spacing)
        let e = _line(en-prefix,   num, en-suffix,   title-en, en-pre,   [ ],          title-spacing-en)
        [#m \ #e]
      } else {
        _line(main-prefix, num, main-suffix, title, main-pre, post-spacing, title-spacing)
      }
    }

    if caption != none or refer-to != none {
      if refer-to != none {
        // ════════════════════════════════════════════════════════
        // 续表/续图分支 (Continuation mode branch)
        // ════════════════════════════════════════════════════════
        //
        // 续表不分配新编号，而是查询原始标签的编号进行显示。
        // Continuation does not allocate a new number but queries
        // the original label's number for display.

        // 决定是否显示标题文本（还是只显示"续表X"之类的编号信息）
        // Decide whether to show caption text or just the continuation identifier
        //
        // 优先级 / Priority:
        // 1. 参数 show-caption 明确指定 → 直接用
        //    show-caption param explicitly set → use directly
        // 2. 全局 continued-show-caption 有值（非 auto）→ 用全局值
        //    Global continued-show-caption is set → use global value
        // 3. 两者都是 auto → 如果提供了 caption/caption-en 则显示，否则不显示
        //    Both auto → show if caption/caption-en is provided
        let should-show-caption = if show-caption == auto {
          if global-show-caption == auto {
            caption != none or caption-en != none
          } else {
            global-show-caption
          }
        } else {
          show-caption
        }

        // 查询原始标签获取其编号
        // Query original label to get its number
        let continuation-caption = {
          let original = query(refer-to)
          if original.len() > 0 {
            // 找到了原始标签，获取其在文档中的编号
            // Found original label, get its number in the document
            let use-ch = config.use-chapter
            // 根据 kind 选择正确的 figure 计数器类型
            // Choose the correct figure counter type based on kind
            let figure-kind = if kind == "table" { table } else { image }
            // 获取原始标签位置处的计数器值（注意：这是历史值，不是当前值）
            // Get counter value AT the original label's location (historical, not current)
            let num = counter(figure.where(kind: figure-kind)).at(original.first().location()).first()

            // 根据编号格式生成编号字符串（带或不带章节前缀）
            // Generate number string with or without chapter prefix
            let table-num = if use-ch {
              // 在原始标签所在位置处读取标题计数器（非当前位置）
              // Read heading counter AT the original label's location (not current)
              let h = counter(heading).at(original.first().location())
              let chapter-nums = if type(config.numbering-format) == str {
                h.slice(0, calc.min(config.chapter-level, h.len()))
              } else {
                h
              }
              numbering(config.numbering-format, ..chapter-nums, num)
            } else {
              // use-chapter: false 也走 numbering-format（保留单数字格式）
              // Honour numbering-format even without chapter prefix.
              numbering(config.numbering-format, num)
            }

            _build-continuation-line(
              num: table-num,
              is-suffix-mode: continued-mode == "suffix",
              show-title: should-show-caption,
            )
          } else {
            // ─ 没有找到原始标签（query 返回空）─
            // ─ Original label not found (query returned empty) ─
            //
            // 可能原因：标签拼写错误，或原始表格在当前位置之后（Typst 暂不支持向后查询）
            // Possible causes: label typo, or original figure appears after current location
            // (Typst doesn't support forward queries yet)
            //
            // 降级处理：不显示编号，只显示续表标识符
            // Fallback: show continuation identifier without number
            _build-continuation-line(
              num: none,
              is-suffix-mode: continued-mode == "suffix",
              show-title: should-show-caption,
            )
          }
        }

        // 渲染续表标题内容（应用标题字号和行距）
        // Render continuation caption content (apply caption size and leading)
        set par(leading: config.caption-leading)
        text(size: config.caption-size, weight: config.caption-weight, ..layers.whole)[
          #continuation-caption
        ]

      } else {
        // ════════════════════════════════════════════════════════
        // 主表/主图分支 (Main table/figure branch)
        // ════════════════════════════════════════════════════════
        //
        // 技术关键：编号注册技巧
        // Technical Key: Number Registration Trick
        //
        // 问题：cap-table 用自定义布局渲染表格，不使用 Typst 的 figure() 包装，
        // 因此无法利用 Typst 内置的 figure 计数器自动编号机制。
        // Problem: cap-table uses custom layout, not Typst's figure() wrapper,
        // so it can't use Typst's built-in figure counter auto-numbering.
        //
        // 解决方案：
        // Solution:
        // 1. 用 place(hide[...]) 在文档流中插入一个不可见的 figure，
        //    其 outlined: true 使其出现在目录中，label 用于交叉引用
        //    Insert an invisible figure using place(hide[...]),
        //    with outlined: true for outline, label for cross-referencing
        // 2. 此操作会使 figure 计数器 +1
        //    This increments the figure counter by 1
        // 3. 立即将计数器 -1（还原到插入前的值）
        //    Immediately decrement counter by 1 (restore to pre-insertion value)
        // 4. 在显示标题时手动读取计数器 +1 来获得正确的当前编号
        //    When rendering, manually read counter + 1 to get the correct current number
        //
        // 这样做的好处：目录和交叉引用都能正确工作，
        // 同时标题可以完全自定义格式（不受 Typst 默认标题格式约束）。
        // Benefits: outline and cross-references work correctly,
        // while the caption format is fully customizable.

        let figure-kind = if kind == "table" { table } else { image }

        // 步骤1：插入隐藏的 figure，注册编号并设置目录条目
        // Step 1: Insert hidden figure, register number and set outline entry
        place(hide[
          #figure(
            kind: figure-kind,
            supplement: final-supplement,
            outlined: true,             // 出现在目录中 / Appears in outline
            caption: {
              // 目录中显示的标题文本（与主标题可能不同）
              // Caption text shown in outline (may differ from main caption)
              if doc-lang == "en" and enable-en and caption-en != none {
                caption-en
              } else if enable-en and caption-en != none {
                if config.outline-bilingual {
                  // 目录双语模式
                  // Bilingual outline mode
                  if config.outline-newline {
                    if is-rtl-lang(doc-lang) {
                      // RTL 语言：英文在前，主语言在后
                      // RTL: English first, main language second
                      [#caption-en \ #caption]
                    } else {
                      [#caption \ #caption-en]
                    }
                  } else {
                    let sep = config.outline-separator
                    if is-rtl-lang(doc-lang) {
                      [#caption-en#sep#caption]
                    } else {
                      [#caption#sep#caption-en]
                    }
                  }
                } else {
                  // 目录只显示主语言
                  // Outline shows main language only
                  caption
                }
              } else {
                caption
              }
            },
            // 同样需要设置编号格式，以便目录中的编号格式正确
            // Also set numbering format so outline shows correct numbers
            numbering: num => {
              if config.use-chapter {
                let h = counter(heading).get()
                let chapter-nums = if type(config.numbering-format) == str {
                  h.slice(0, calc.min(config.chapter-level, h.len()))
                } else {
                  h
                }
                numbering(config.numbering-format, ..chapter-nums, num)
              } else {
                numbering(config.numbering-format, num)
              }
            },
            [],
          )#if label != none { label }   // 绑定交叉引用标签 / Bind cross-reference label
        ])

        // 步骤2：将计数器减 1，抵消上面隐藏 figure 造成的计数增加
        // Step 2: Decrement counter by 1 to cancel the increment from the hidden figure
        counter(figure.where(kind: figure-kind)).update(n => if n > 0 { n - 1 } else { 0 })

        // 步骤3：读取当前计数器值 +1，得到本表格的正确编号
        // Step 3: Read current counter + 1 to get the correct number for this table
        let use-ch = config.use-chapter
        let num = counter(figure.where(kind: figure-kind)).get().first() + 1

        let table-num = if use-ch {
          let h = counter(heading).get()
          let chapter-nums = if type(config.numbering-format) == str {
            h.slice(0, calc.min(config.chapter-level, h.len()))
          } else {
            h
          }
          numbering(config.numbering-format, ..chapter-nums, num)
        } else {
          // use-chapter: false 也走 numbering-format
          numbering(config.numbering-format, num)
        }

        // 步骤4：生成主标题内容（考虑 RTL 和双语布局）
        // Step 4: Generate main caption content (considering RTL and bilingual layout)
        // 使用统一的 _line 构造器；RTL 语言需对各部件 box 包裹并对英文行强制 ltr。
        // Uses the unified _line builder; RTL wraps parts in box and forces ltr on English line.
        let rtl = is-rtl-lang(doc-lang)
        let main-caption = if doc-lang == "en" and enable-en and caption-en != none {
          _line(final-supplement, table-num, none, caption-en, pre-spacing, none, title-spacing)
        } else if enable-en and caption-en != none {
          let m = _line(final-supplement, table-num, none, caption, pre-spacing, none, title-spacing, rtl: rtl)
          let e = _line(final-supplement-en, table-num, none, caption-en, [ ], none, title-spacing-en)
          if rtl { [#m \ #text(dir: ltr)[#e]] } else { [#m \ #e] }
        } else {
          _line(final-supplement, table-num, none, caption, pre-spacing, none, title-spacing, rtl: rtl)
        }

        // 步骤5：将计数器推进 +1（完成本表格的编号分配）
        // Step 5: Advance counter by 1 (completing number allocation for this table)
        counter(figure.where(kind: figure-kind)).step()

        // 步骤6：渲染主标题内容
        // Step 6: Render main caption content
        set par(leading: config.caption-leading)
        text(size: config.caption-size, weight: config.caption-weight, ..layers.whole)[
          #main-caption
        ]
      }
    }
  }
}


/// 独立双语标题函数，可用于表格（`kind: "table"`）或图片（`kind: "figure"`）。
///
/// 调用方式 / Usage:
/// - `#bicap(caption: [...], kind: "...")` —— 仅渲染题注，按 `caption-above` /
///   `caption-below` 间距独立成块。
/// - `#bicap(caption: [...], kind: "...")[body]` —— 把 body 与题注一起包进一个
///   不换页 block，相当于一个 `figure(kind: ...)` 的 cap-able 版本。题注与
///   body 的相对位置由 `caption-position` 决定（state 默认：table=top、figure=bottom；
///   可通过 `captab-style` / `capfig-style` 全局覆盖，或直接传 `config`）。
///
/// Standalone bilingual caption for tables (`kind: "table"`) or figures (`kind: "figure"`).
///
/// Calling forms:
/// - `#bicap(caption: [...], kind: "...")` — caption only, in its own non-breakable block.
/// - `#bicap(caption: [...], kind: "...")[body]` — wraps body and caption together,
///   conceptually a cap-able-flavoured `figure(kind: ...)`. Caption position is taken
///   from `caption-position` (default top for tables, bottom for figures; configurable
///   via `captab-style` / `capfig-style` or by passing `config`).
///
/// -> content
#let bicap(
  /// 主语言标题文本
  /// Main language caption text
  /// -> none | content
  caption: none,
  /// 英文标题文本（双语模式）
  /// English caption text (bilingual mode)
  /// -> none | content
  caption-en: none,
  /// 引用原始表/图的标签（提供此参数则进入续表模式）
  /// Reference to the original table/figure label (enables continuation mode)
  /// -> none | label
  refer-to: none,
  /// 此标题的标签（用于交叉引用）
  /// Label for this caption (for cross-references)
  /// -> none | label
  label: none,
  /// 内容类型："table" 或 "figure"
  /// Content type: "table" or "figure"
  /// -> str
  kind: "table",
  /// 续表/图是否显示标题文本（auto=自动根据 caption 是否提供决定）
  /// Whether to show caption text in continuation (auto = based on whether caption is provided)
  /// -> auto | bool
  show-caption: auto,
  /// 样式配置，auto 则从全局 table-style-config 获取
  /// Style config, auto = use global table-style-config
  /// -> auto | dictionary
  config: auto,
  /// 题注位置（auto = 跟随全局 caption-position；top 或 bottom 直接覆盖）
  /// Caption position (auto = follow global caption-position; top / bottom to override)
  /// -> auto | alignment
  position: auto,
  /// 题注水平对齐：字符串 "center" / "left" / "right" / "text-left" / "text-right"
  /// 也接受 dict (main: ..., continued: ...) 拆分主与续。auto = 跟随全局 caption-align。
  /// Caption horizontal alignment: string "center" / "left" / "right" / "text-left" /
  /// "text-right". Also accepts dict (main, continued) for split. auto = follow global.
  /// -> auto | str | dictionary
  caption-align: auto,
  /// 浮动定位：none（默认，原地）/ top / bottom（浮到当前页或下一页的顶/底）。auto =
  /// 跟随全局 placement。启用时强制 breakable: false（Typst float 不允许跨页）。
  /// Floating placement; auto follows global. Forces breakable: false when active.
  /// -> auto | none | alignment
  placement: (),
  /// 外层 block 是否允许跨页。默认 `true`，让 body 里本身可跨页的内容（如长 captab、
  /// 长段落）顺延到下一页；设为 `false` 则强制把题注 + body 锁在同一页。
  /// Whether the outer block may break across pages. Defaults to `true` so a body
  /// that is itself breakable (e.g. a long captab or paragraph) flows naturally;
  /// set `false` to keep caption + body atomic on one page.
  /// -> bool
  breakable: true,
  /// 跨页时是否在 body 里 *每张原生 #table()* 的顶部重复题注。
  /// 仅在 `kind == "table"` 时生效；通过 `show table:` 注入一个 level-1
  /// `table.header(repeat: true)` 实现，复用与 `captab(continued-caption: true)` 同款的
  /// `query(label) + here().page()` 检测，续页才显示。
  ///
  /// *约定*：一个 bicap 里只放一张 `#table()`。如果 body 里同时有多张表，所有表都会被
  /// 注入相同的题注（因为 bicap 把它们视作"同一题注下的多个表"），通常不是你想要的；
  /// 此时请改写成多个 bicap 调用，或用 `captab` 直接管理每张表的题注。
  ///
  /// `kind == "figure"` 下此参数为 no-op（图片本身不跨页；如有跨页图请用 `refer-to`）。
  ///
  /// Whether to repeat the caption above each native `#table()` inside body when it
  /// breaks across pages. Only active when `kind == "table"`. Implemented by injecting
  /// a level-1 `table.header(repeat: true)` via `show table:`, reusing the
  /// `query(label) + here().page()` mechanism from `captab(continued-caption: true)` so the
  /// repeated caption only renders on continuation pages.
  ///
  /// *Convention*: keep at most one `#table()` per bicap. If body contains multiple
  /// tables, the same caption is injected into ALL of them — usually not what you want;
  /// in that case use multiple bicap calls or manage each table's caption with `captab`.
  ///
  /// No-op when `kind == "figure"`; for cross-page figures use `refer-to`.
  /// -> bool
  continued-caption: false,
  /// 跨页时是否重复 body 内 `#table()` 的 markdown 表头行。
  /// `auto`（默认）= 不干涉用户写在 `table.header(...)` 里的 `repeat` 设定；
  /// `true | false | <int>` = 强制覆盖，跟 Typst 原生 `table.header(repeat: ...)` 一致。
  /// 仅 `kind == "table"` 生效，与 `continued-caption` 互相独立。
  ///
  /// Whether to repeat the markdown header row of `#table()` inside body across pages.
  /// `auto` (default) leaves the user's existing `table.header(repeat: ...)` untouched;
  /// `true | false | <int>` overrides it (matching Typst's native semantics).
  /// Only active when `kind == "table"`; independent of `continued-caption`.
  /// -> auto | bool | int
  repeat-header: auto,
  /// 可选的 body：可以用名参 `body: [...]` 或在调用尾部用内容块 `#bicap()[...]`，
  /// 后者会通过 `..body-args` 收集进来。两种形式等价。
  /// Optional body — pass via the named arg `body: [...]` or as a trailing content
  /// block `#bicap()[...]` (collected through `..body-args`); the two forms are equivalent.
  /// -> none | content
  body: none,
  ..body-args,
) = {
  context {
    // 如果用户用 #bicap()[...] 形式，body 通过 ..body-args 进来
    // If the user wrote #bicap()[...], the body comes in via ..body-args
    let body = if body != none {
      body
    } else if body-args.pos().len() > 0 {
      body-args.pos().first()
    } else {
      none
    }
    // 拒绝 ..body-args 里出现命名参数（bicap 不接受未声明的命名参数）
    // Reject named args in ..body-args (bicap does not accept unknown named args)
    assert(
      body-args.named().len() == 0,
      message: "bicap: unexpected named arguments " + repr(body-args.named().keys()),
    )
    assert(
      body-args.pos().len() <= 1,
      message: "bicap: at most one positional argument (body) is allowed",
    )
    // 解析配置：auto 则读取全局表格配置，否则使用传入值
    // Resolve config: auto = read global table config, otherwise use provided value
    let final-config = if config == auto {
      if kind == "figure" { figure-style-config.get() } else { table-style-config.get() }
    } else {
      config
    }

    // ── continued-caption 启用条件 / continued-caption activation ──
    // 仅在 kind == "table"、有 body、有 caption、且不是 refer-to 模式时启用。
    // 续页 query 需要一个 label，没传就合成隐藏 label（仿照 captab）。
    // Only active when kind == "table" with body + caption (not refer-to mode).
    // Continuation needs a label for query(); auto-synthesise a hidden one if absent.
    let cap-in-body = (continued-caption
                       and kind == "table"
                       and caption != none
                       and refer-to == none
                       and body != none)
    let synth-id = if cap-in-body and label == none {
      counter("__bicap-synth-id").get().first()
    } else { 0 }
    let effective-label = if label != none {
      label
    } else if cap-in-body {
      std.label("__bicap_repeat_" + str(synth-id))
    } else {
      none
    }

    // 生成标题核心内容（用 effective-label 注册，方便续页 query）
    // Generate caption content (registered with effective-label so continuation pages can query it)
    let caption-content = _make_caption_content(
      caption: caption,
      caption-en: caption-en,
      refer-to: refer-to,
      label: effective-label,
      config: final-config,
      kind: kind,
      show-caption: show-caption,
    )

    // 解析语言和首行缩进修复标志 / Resolve language and indent-fix flag
    let (_, should-indent) = resolve-lang-indent(final-config)

    // 解析题注位置：参数 > 全局 state > 按 kind 兜底
    // Resolve caption position: param > global state > kind-based fallback
    let final-position = if position != auto {
      position
    } else {
      final-config.at(
        "caption-position",
        default: if kind == "figure" { bottom } else { top },
      )
    }

    // 题注水平对齐：参数 > 全局 state > "center"；dict 形式 (main, continued) 拆分。
    // 续表那侧 text-left/text-right 静默降级为 left/right（cap-cell 锁在表内）。
    // 必要时改用 *手动 refer-to* 拆段，把续题放到表外。
    // Caption horizontal alignment: param > global state > "center"; dict (main, continued)
    // splits sides. Continuation side text-left/text-right silently degrade to left/right
    // (cap-cell is locked within the table). Use manual refer-to for true text-anchored
    // continuation captions.
    let raw-cap-align = if caption-align != auto {
      caption-align
    } else {
      final-config.at("caption-align", default: "center")
    }
    let final-cap-align-main = if type(raw-cap-align) == dictionary {
      raw-cap-align.at("main", default: "center")
    } else {
      raw-cap-align
    }
    let _cap-align-continued-raw = if type(raw-cap-align) == dictionary {
      raw-cap-align.at("continued", default: "center")
    } else {
      raw-cap-align
    }
    let final-cap-align-continued = if _cap-align-continued-raw == "text-left" { "left" }
      else if _cap-align-continued-raw == "text-right" { "right" }
      else { _cap-align-continued-raw }

    let _resolve-cap-align(s) = {
      if s == "left"        { (kind: "local", value: left) }
      else if s == "right"  { (kind: "local", value: right) }
      else if s == "text-left"  { (kind: "text", value: left) }
      else if s == "text-right" { (kind: "text", value: right) }
      else                  { (kind: "local", value: center) }
    }
    let main-align-resolved      = _resolve-cap-align(final-cap-align-main)
    let continued-align-resolved = _resolve-cap-align(final-cap-align-continued)

    // 浮动定位：per-call > state > none
    // Floating placement: per-call > state > none
    let final-placement = if placement != () {
      placement
    } else {
      final-config.at("placement", default: none)
    }
    // 浮动启用时强制 breakable: false（Typst float 不允许跨页）
    // Float forces breakable: false (Typst floats can't break across pages)
    let breakable = if final-placement != none { false } else { breakable }

    // 如果用了 cap-in-body 且我们合成了 label，把 synth-id 计数器推进 1
    // If cap-in-body used a synthesised label, step the synth counter
    if cap-in-body and label == none {
      counter("__bicap-synth-id").step()
    }

    // 续页 cell 的内容：仅在续页（页码 != 主表登记页）调 _make_caption_content
    // 走 refer-to 分支输出"续表 X.Y caption"，不会重复登记 figure 编号。
    // Continuation cell content: only on continuation pages (page != main location's
    // page) call _make_caption_content's refer-to branch to render "Cont. Table X.Y".
    let cap-cell-content = if cap-in-body {
      context {
        let originals = query(effective-label)
        if originals.len() > 0 {
          let start-page = originals.first().location().page()
          if here().page() != start-page {
            v(final-config.at("caption-above", default: 0pt))
            _make_caption_content(
              caption: caption,
              caption-en: caption-en,
              refer-to: effective-label,
              label: none,
              config: final-config,
              kind: "table",
              show-caption: true,
            )
            v(final-config.at("caption-below", default: 0pt))
          }
        }
      }
    } else { none }

    // body 的展示形式：cap-in-body 时用 show table: rule 给 body 内每张原生
    // #table() 注入一个 level-1 table.header(repeat: true) caption 行；
    // 已经带有 level-1 header 的（例如 captab 自己生成的 table）跳过，避免双层。
    // Body presentation: when cap-in-body, use show table: rule to inject a
    // level-1 table.header(repeat: true) caption row into every native #table()
    // in body. Tables that already have a level-1 table.header (e.g. those generated
    // by captab itself) are skipped to avoid double-stacking.
    // show table 注入条件：要么需要插 caption header（cap-in-body），要么需要
    // 覆盖 markdown 表头的 repeat 设定（repeat-header != auto）。
    // Show-table activation: when caption injection is needed (cap-in-body) OR
    // when we have to override the markdown header's repeat setting.
    let needs-show-table = (
      kind == "table"
      and body != none
      and (cap-in-body or repeat-header != auto)
    )
    let presented-body = if needs-show-table {
      {
        show table: it => {
          let f = it.fields()
          let cols = f.at("columns", default: 1)
          let ncols = if type(cols) == array { cols.len() } else if type(cols) == int { cols } else { 1 }
          let original-children = f.at("children", default: ())
          // 任何 children 里有 level >= 2 的 table.header 说明：要么是 captab 嵌套结构
          // （level 1 caption + level 2 markdown header），要么是我们这条 show rule
          // 上一轮已经处理过的 output（用户原 L1 已被 promote 到 L2）。无论哪种都
          // 直接返回 it，避免重复注入和无限 show-rule 递归。
          // Any child being a level >= 2 table.header means either (a) captab's nested
          // structure, or (b) our own previous-pass output where the user's L1 header
          // was promoted to L2. Either way, skip — both prevents stacking captions and
          // breaks the show-rule recursion.
          let is-captab-shaped = original-children.any(c => (
            c.func() == table.header
            and c.fields().at("level", default: 1) >= 2
          ))
          // 用户原始 L1 header 是否存在
          // Whether the user wrote a level-1 table.header
          let has-user-l1-header = original-children.any(c => (
            c.func() == table.header
            and c.fields().at("level", default: 1) == 1
          ))
          if is-captab-shaped {
            it
          } else if not cap-in-body and not has-user-l1-header {
            // 没有 caption 注入，又没有 L1 header 可以覆盖 repeat —— 没事可做，原样返回
            // Nothing to inject and no user L1 header to override → leave as-is
            it
          } else {
            // 改写用户原有的 level-1 table.header：
            // - cap-in-body 时把 level 提升到 2（让我们的 caption header 占据 level 1）；
            // - repeat-header != auto 时覆盖其 repeat 字段。
            // Rewrite the user's level-1 table.header:
            // - when cap-in-body, promote level to 2 (we take level 1 for the caption);
            // - when repeat-header != auto, override its repeat field.
            // 用户原有 level-1 header 一律 promote 到 level 2：
            // 1) cap-in-body 时让我们的 caption header 占据 level 1；
            // 2) 没有 cap-in-body 但需要覆盖 repeat 时，把 level 推到 2 也能让
            //    `is-captab-shaped` 检查在下一次 show 触发时识别"已处理"，
            //    避免 show rule 无限递归（max show rule depth）。
            // Always promote the user's level-1 header to level 2:
            // 1) when cap-in-body, our cap-header takes level 1;
            // 2) when only overriding repeat, promoting to level 2 makes
            //    `is-captab-shaped` on the next pass detect "already processed",
            //    avoiding the "maximum show rule depth exceeded" panic.
            let promoted-children = original-children.map(c => {
              let is-l1-header = c.func() == table.header and c.fields().at("level", default: 1) == 1
              if is-l1-header {
                let cf = c.fields()
                let kids = cf.at("children", default: ())
                let user-repeat = cf.at("repeat", default: true)
                let final-repeat = if repeat-header != auto { repeat-header } else { user-repeat }
                let other = (:)
                for (k, v) in cf.pairs() {
                  if k != "children" and k != "level" and k != "repeat" {
                    other.insert(k, v)
                  }
                }
                table.header(level: 2, repeat: final-repeat, ..other, ..kids)
              } else {
                c
              }
            })
            // 重建 table，保留所有非 children 字段
            // Rebuild the table preserving all non-children fields
            let other-fields = (:)
            for (k, v) in f.pairs() {
              if k != "children" {
                other-fields.insert(k, v)
              }
            }
            if cap-in-body {
              let cap-header = table.header(
                level: 1,
                repeat: true,
                table.cell(
                  colspan: ncols,
                  stroke: none,
                  align: continued-align-resolved.value,
                  inset: (x: 0pt, y: 0pt),
                  cap-cell-content,
                ),
              )
              // 兜底：如果用户原本没有 L1 header（也就没有可 promote 到 L2 的东西），
              // promoted-children 里就缺乏 level >= 2 的 marker，本轮 output 进入下一次
              // show 触发时 is-captab-shaped 会判 false → 无限递归。塞一个空的
              // level-2 table.header 当 marker，不渲染任何可见内容，仅用于打断递归。
              // Fallback: if the user had no L1 header to promote, promoted-children
              // lacks the level >= 2 marker that the next show-pass uses to short-circuit,
              // causing infinite show-rule recursion. Insert an empty level-2 header as
              // a marker — it renders nothing visible but stops the recursion.
              let has-l2-or-higher = promoted-children.any(c => (
                c.func() == table.header
                and c.fields().at("level", default: 1) >= 2
              ))
              let final-promoted = if has-l2-or-higher {
                promoted-children
              } else {
                (table.header(level: 2, repeat: true),) + promoted-children
              }
              table(..other-fields, cap-header, ..final-promoted)
            } else {
              // 只是覆盖 repeat-header，没有题注重复 / Header-repeat override only
              table(..other-fields, ..promoted-children)
            }
          }
        }
        body
      }
    } else { body }

    // 浮动包装 helper：placement: top/bottom 时把 outer block 包进 place(float: true)。
    // place() 仅给 vertical alignment 时水平默认贴左——补 + center 保留居中行为。
    // 隐藏 figure 一同 ride 进 float wrapper，counter 在 float 落地时 step，`@ref` 解析
    // 到 float 落地页。长 body float 装不下时 Typst 会溢出/裁切——用户应保持 placement: none。
    // Float-wrapping helper. place() with vertical-only alignment defaults to left-align
    // horizontally — we add `+ center` to keep things centered. Hidden figure rides along.
    let _normalize-placement(p) = if p == top { top + center }
      else if p == bottom { bottom + center }
      else { p }
    let _maybe-float(content) = if final-placement != none {
      place(_normalize-placement(final-placement), float: true, content)
    } else {
      content
    }

    if caption != none or refer-to != none {
      if body == none {
        // 旧形式：只渲染题注；走主标题对齐（kind="text" 时占满文本宽对齐到正文边缘，
        // kind="local" 时由调用上下文负责居中——这里直接 align 即可）
        // Caption-only form. Apply main caption-align: text-anchored aligns to text-area
        // edges (full block), local alignment is applied in-place (caller handles centering).
        let cap-line = if main-align-resolved.kind == "text" {
          block(width: 100%, std.align(main-align-resolved.value, caption-content))
        } else {
          std.align(main-align-resolved.value, caption-content)
        }
        _maybe-float(block(
          breakable: breakable,
          above: final-config.at("caption-above", default: 0pt),
          below: final-config.at("caption-below", default: 0pt),
        )[#cap-line])
      } else {
        // 新形式：题注 + body 一起包进一个不换页 block，模拟 figure(body, caption: ...)
        // Body form: wrap caption + body in a single non-breakable block (figure-like)
        let above-key = if kind == "figure" { "figure-above" } else { "caption-above" }
        let below-key = if kind == "figure" { "figure-below" } else { "table-below" }
        // caption 与 body 之间的间距：caption 在上时用 caption-below，caption 在下时用 caption-above
        // Gap between caption and body: caption-below if caption on top; caption-above if caption on bottom
        let gap-key = if final-position == top { "caption-below" } else { "caption-above" }
        let gap = final-config.at(gap-key, default: 0.5em)
        // 根据 main-align-resolved 组合 caption + body：
        //   kind == "text"  → caption 单独占一行 block(width: 100%)，body 居中独立排版；
        //   kind == "local" → caption 与 body 共享一个 align(center) 容器，
        //                     在该容器内对 caption 应用 left/right/center。
        // 由于 bicap 的 body 宽度不可靠测量，"local left/right" 会作用于 *居中容器内*：
        // 当 body < text-width 时，效果与 text-left/text-right 接近但未完全等同
        // （详见手册"已知限制"段落）。
        // For bicap, body width is generally unknown. local left/right aligns within the
        // centered container (≈ text-anchored when body < text width); see the manual.
        let composed = if main-align-resolved.kind == "text" {
          let cap-line = block(width: 100%, std.align(main-align-resolved.value, caption-content))
          let body-line = align(center, presented-body)
          if final-position == top {
            cap-line
            v(gap)
            body-line
          } else {
            body-line
            v(gap)
            cap-line
          }
        } else {
          align(center)[
            #if final-position == top {
              std.align(main-align-resolved.value, caption-content)
              v(gap)
              presented-body
            } else {
              presented-body
              v(gap)
              std.align(main-align-resolved.value, caption-content)
            }
          ]
        }
        _maybe-float(block(
          breakable: breakable,
          above: final-config.at(above-key, default: 0pt),
          below: final-config.at(below-key, default: 0pt),
        )[#composed])
      }
      if should-indent { _fakepar }
    } else if body != none {
      // 没有题注但有 body：直接输出 body（也支持 placement）
      // No caption, only body: emit body (also supports placement)
      _maybe-float(presented-body)
    }
  }
}
