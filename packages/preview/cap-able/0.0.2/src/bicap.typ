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

    // ── 统一标题行构造器 / Unified caption-line builder ──
    //
    // 按模板 `prefix [+pre-sp+num] [+post-sp+suffix] [+title-sp+title]` 拼接一行标题。
    // 任一部件为 none 则连同其间距一起跳过；rtl 为 true 时把各部件用 box 包裹以防方向混乱。
    // Builds one caption line from template above. `none` parts are skipped along
    // with their spacing; when rtl, each part is wrapped in box to prevent direction issues.
    let _line(prefix, num, suffix, title, pre-sp, post-sp, title-sp, rtl: false) = {
      let b(p) = if rtl and p != none { box[#p] } else { p }
      b(prefix)
      if num != none {
        if pre-sp != none { handle-spacing(pre-sp) }
        b(num)
      }
      if suffix != none {
        if post-sp != none { handle-spacing(post-sp) }
        b(suffix)
      }
      if title != none {
        if title-sp != none { handle-spacing(title-sp) }
        b(title)
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
              let levels = config.chapter-level
              // 在原始标签所在位置处读取标题计数器（非当前位置）
              // Read heading counter AT the original label's location (not current)
              let h = counter(heading).at(original.first().location())
              let chapter-nums = h.slice(0, calc.min(levels, h.len()))
              numbering(config.numbering-format, ..chapter-nums, num)
            } else {
              str(num)
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
        text(size: config.caption-size, weight: config.caption-weight)[
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
                let levels = config.chapter-level
                let h = counter(heading).get()
                let chapter-nums = h.slice(0, calc.min(levels, h.len()))
                numbering(config.numbering-format, ..chapter-nums, num)
              } else {
                numbering("1", num)
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
          let levels = config.chapter-level
          let h = counter(heading).get()
          let chapter-nums = h.slice(0, calc.min(levels, h.len()))
          numbering(config.numbering-format, ..chapter-nums, num)
        } else {
          str(num)
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
        text(size: config.caption-size, weight: config.caption-weight)[
          #main-caption
        ]
      }
    }
  }
}


/// 独立双语标题函数，可用于表格（`kind: "table"`）或图片（`kind: "figure"`）。
/// Standalone bilingual caption for tables (`kind: "table"`) or figures (`kind: "figure"`).
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
) = {
  context {
    // 解析配置：auto 则读取全局表格配置，否则使用传入值
    // Resolve config: auto = read global table config, otherwise use provided value
    let final-config = if config == auto {
      if kind == "figure" { figure-style-config.get() } else { table-style-config.get() }
    } else {
      config
    }

    // 生成标题核心内容
    // Generate the core caption content
    let content = _make_caption_content(
      caption: caption,
      caption-en: caption-en,
      refer-to: refer-to,
      label: label,
      config: final-config,
      kind: kind,
      show-caption: show-caption,
    )

    // 解析语言和首行缩进修复标志 / Resolve language and indent-fix flag
    let (_, should-indent) = resolve-lang-indent(final-config)

    if caption != none or refer-to != none {
      // 用 block 包装：设置不换页、上下间距
      // Wrap in block: non-breakable, above/below spacing
      block(
        breakable: false,
        above: final-config.at("caption-above", default: 0pt),
        below: final-config.at("caption-below", default: 0pt),
      )[
        #content
      ]
      if should-indent { _fakepar }
    }
  }
}
