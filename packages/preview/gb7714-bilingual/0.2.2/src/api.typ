// GB/T 7714 双语参考文献系统 - 公共 API

#import "@preview/citegeist:0.2.2": load-bibliography

#import "core/state.typ": (
  _bib-data, _cite-marker, _collect-citations, _compute-year-suffixes, _config,
  _style, _version,
)
#import "core/language.typ": detect-language
#import "core/utils.typ": format-citation-numbers
#import "versions/mod.typ": get-citation-config, get-version-config
#import "authors.typ": format-author-intext
#import "renderers/mod.typ": render-entry

/// 初始化 GB/T 7714 双语参考文献系统（内部实现）
///
/// - bib-content: BibTeX 文件内容
/// - hidden-bib: 隐藏的 bibliography 元素（用于让 @key 语法工作）
/// - style: 引用风格，"numeric"（顺序编码制）或 "author-date"（著者-出版年制）
/// - version: 标准版本，"2015" 或 "2025"（默认）
/// - show-url: 是否显示 URL（默认 true）
/// - show-doi: 是否显示 DOI（默认 true）
/// - show-accessed: 是否显示访问日期（默认 true）
#let init-gb7714-impl(
  bib-content,
  style: "numeric",
  version: "2025",
  show-url: true,
  show-doi: true,
  show-accessed: true,
  doc,
) = {
  // 加载 bib 数据
  let bib-data = load-bibliography(bib-content)
  // 创建隐藏的 bibliography（让 @key 语法工作）
  hide(bibliography(bytes(bib-content), title: none))

  // 设置状态
  _bib-data.update(bib-data)
  _style.update(style)
  _version.update(version)
  _config.update((
    show-url: show-url,
    show-doi: show-doi,
    show-accessed: show-accessed,
  ))

  // 拦截 cite 元素
  show cite: it => {
    let key = str(it.key)

    // 放置 metadata 标记（用于后续 query 收集）
    _cite-marker(key)

    // 渲染引用
    context {
      let current-style = _style.get()
      let current-version = _version.get()
      let bib = _bib-data.get()
      let citations = _collect-citations()
      let cite-config = get-citation-config(current-version)

      // 获取 form 参数（nil, "normal", "prose", "full", "author", "year"）
      let form = it.form

      if current-style == "numeric" {
        // 顺序编码制
        let order = citations.at(key, default: citations.len() + 1)

        // 处理 supplement（页码等）
        let supplement-content = if it.supplement != none {
          [, #it.supplement]
        } else {
          []
        }

        // 根据 form 决定输出形式
        if form == "author" or form == "year" {
          // numeric 模式下 author/year 需要从 entry 获取
          let entry = bib.at(key, default: none)
          if entry != none {
            let lang = detect-language(entry)
            if form == "author" {
              let author-text = format-author-intext(
                entry.parsed_names,
                lang,
                version: current-version,
              )
              link(label("gb7714-ref-" + key), author-text)
            } else {
              // form == "year"
              let year = entry.fields.at("year", default: "n.d.")
              link(label("gb7714-ref-" + key), str(year))
            }
          } else {
            text(fill: red, "[??" + key + "??]")
          }
        } else if form == "prose" or form == "full" {
          // 非上标形式（散文引用）
          link(label("gb7714-ref-" + key), [[#order#supplement-content]])
        } else {
          // 默认/normal: 上标形式
          link(label("gb7714-ref-" + key), super[[#order#supplement-content]])
        }
      } else {
        // 著者-出版年制: （Author，Year）或（Author 等，Year）
        let entry = bib.at(key, default: none)
        if entry != none {
          // 检测语言
          let lang = detect-language(entry)
          let author-text = format-author-intext(
            entry.parsed_names,
            lang,
            version: current-version,
          )
          let year = entry.fields.at("year", default: "n.d.")

          // 计算年份后缀（消歧）
          let suffixes = _compute-year-suffixes(bib, citations)
          let suffix = suffixes.at(key, default: "")
          let year-with-suffix = str(year) + suffix

          // 处理 supplement（页码等）
          let supplement-content = if it.supplement != none {
            [#cite-config.author-year-sep#it.supplement]
          } else {
            []
          }

          // 括号和分隔符
          let lparen = cite-config.lparen
          let rparen = cite-config.rparen
          let sep = cite-config.author-year-sep

          // 根据 form 决定输出形式
          if form == "author" {
            // 仅作者
            link(label("gb7714-ref-" + key), author-text)
          } else if form == "year" {
            // 仅年份（带括号）
            link(label("gb7714-ref-" + key), [#lparen#year-with-suffix#rparen])
          } else if form == "prose" {
            // 散文形式: Author (Year) 或 Author（Year）
            link(
              label("gb7714-ref-" + key),
              [#author-text #lparen#year-with-suffix#supplement-content#rparen],
            )
          } else {
            // 默认/normal/full: (Author, Year)
            link(
              label("gb7714-ref-" + key),
              [#lparen#author-text#sep#year-with-suffix#supplement-content#rparen],
            )
          }
        } else {
          text(fill: red, "[??" + key + "??]")
        }
      }
    }
  }

  doc
}

// ============================================================================
// 低层 API：获取原始数据，用于完全自定义渲染
// ============================================================================

/// 获取被引用的条目列表（低层 API）
///
/// 返回一个数组，每个元素包含：
/// - `key`: 引用键
/// - `order`: 引用顺序（用于 numeric 模式编号）
/// - `year-suffix`: 年份消歧后缀（如 "a", "b"）
/// - `lang`: 检测到的语言（"zh" 或 "en"）
/// - `entry-type`: 条目类型（"article", "book" 等）
/// - `fields`: 原始字段字典（title, author, journal, year, ...）
/// - `parsed-names`: 解析后的作者/编者名字
/// - `rendered`: 使用默认渲染器生成的文本
/// - `ref-label`: 用于链接跳转的 label 对象
/// - `labeled-rendered`: 已附加 label 的渲染结果（推荐使用）
///
/// 使用方法：
/// ```typst
/// context {
///   let entries = get-cited-entries()
///   for e in entries {
///     // 方式1：使用已附加 label 的渲染结果
///     e.labeled-rendered
///     // 方式2：自定义内容 + label
///     [自定义内容 #e.ref-label]
///   }
/// }
/// ```
/// config 参数可选，默认显示所有

// 排序辅助函数（被 get-cited-entries 和 get-all-entries 共用）
#let _get-sort-key-for-name(name) = {
  let prefix = name.at("prefix", default: "")
  let family = name.at("family", default: "")
  if prefix != "" {
    prefix + " " + family
  } else {
    family
  }
}

#let _sort-entries(entries, style) = {
  if style == "numeric" {
    entries.sorted(key: it => it.order)
  } else {
    // author-date: 按作者姓名排序，同作者则按第二个作者排序，以此类推，最后按年份排序
    entries.sorted(key: it => {
      // 获取排序用的名字（优先 author，其次 editor）
      let names = it.parsed-names.at("author", default: ())
      if names.len() == 0 {
        names = it.parsed-names.at("editor", default: ())
      }

      // 构建所有作者的排序键元组
      let name-sort-keys = ()
      if names.len() > 0 {
        for name in names {
          name-sort-keys.push(lower(_get-sort-key-for-name(name)))
        }
      } else {
        // 无作者/编辑者时，根据语言使用排序键
        if it.lang == "en" {
          name-sort-keys.push("anonymous")
        } else {
          name-sort-keys.push("佚") // 佚 名 排在中文最后
        }
      }

      // 获取年份用于次级排序
      let year-sort-key = it.fields.at("year", default: "")

      // 返回元组：(所有作者排序键..., 年份)
      name-sort-keys.push(year-sort-key)
      name-sort-keys
    })
  }
}

#let get-cited-entries(
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let bib = _bib-data.get()
  let citations = _collect-citations()
  let current-style = _style.get()
  let current-version = _version.get()
  let suffixes = _compute-year-suffixes(bib, citations)

  let entries = citations
    .pairs()
    .map(((key, order)) => {
      let entry = bib.at(key, default: none)
      if entry == none { return none }

      let lang = detect-language(entry)
      // 顺序编码制不需要年份后缀消歧（用编号区分）
      let year-suffix = if current-style == "numeric" {
        ""
      } else {
        suffixes.at(key, default: "")
      }
      let rendered = render-entry(
        entry,
        lang,
        year-suffix: year-suffix,
        style: current-style,
        version: current-version,
        config: config,
      )

      let ref-label = label("gb7714-ref-" + key)
      (
        key: key,
        order: order,
        year-suffix: year-suffix,
        lang: lang,
        entry-type: entry.at("entry_type", default: "misc"),
        fields: entry.at("fields", default: (:)),
        parsed-names: entry.at("parsed_names", default: (:)),
        rendered: rendered,
        // 便捷字段：用于链接跳转
        ref-label: ref-label, // label 对象，用法：[内容 #e.ref-label]
        labeled-rendered: [#rendered #ref-label], // 已附加 label 的渲染结果
      )
    })
    .filter(x => x != none)

  // 排序
  _sort-entries(entries, current-style)
}

/// 获取所有参考文献条目（即使未被引用）
///
/// 当 `full: true` 时使用此函数代替 `get-cited-entries()`
///
/// config 参数可选，默认显示所有
#let get-all-entries(
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let bib = _bib-data.get()
  let citations = _collect-citations()
  let current-style = _style.get()
  let current-version = _version.get()
  let suffixes = _compute-year-suffixes(bib, citations)

  // 按引用顺序为所有被引用的条目分配顺序号
  let cited-keys = citations.keys()
  let cited-count = cited-keys.len()

  // 处理被引用的条目（按引用顺序）
  let cited-entries = cited-keys
    .enumerate()
    .map(((i, key)) => {
      let entry = bib.at(key)
      let lang = detect-language(entry)

      // 顺序编码制不需要年份后缀消歧（用编号区分）
      let year-suffix = if current-style == "numeric" {
        ""
      } else {
        suffixes.at(key, default: "")
      }
      let rendered = render-entry(
        entry,
        lang,
        year-suffix: year-suffix,
        style: current-style,
        version: current-version,
        config: config,
      )

      let ref-label = label("gb7714-ref-" + key)
      (
        key: key,
        order: i + 1,
        year-suffix: year-suffix,
        lang: lang,
        entry-type: entry.at("entry_type", default: "misc"),
        fields: entry.at("fields", default: (:)),
        parsed-names: entry.at("parsed_names", default: (:)),
        rendered: rendered,
        ref-label: ref-label,
        labeled-rendered: [#rendered #ref-label],
        is-cited: true,
      )
    })

  // 处理未被引用的条目
  let bib-keys = bib.keys()
  let uncited-keys = bib-keys.filter(k => (
    citations.at(k, default: none) == none
  ))

  let uncited-entries = uncited-keys
    .enumerate()
    .map(((i, key)) => {
      let entry = bib.at(key)
      let lang = detect-language(entry)

      // 顺序编码制不需要年份后缀消歧（用编号区分）
      let year-suffix = if current-style == "numeric" {
        ""
      } else {
        suffixes.at(key, default: "")
      }
      let rendered = render-entry(
        entry,
        lang,
        year-suffix: year-suffix,
        style: current-style,
        version: current-version,
        config: config,
      )

      let ref-label = label("gb7714-ref-" + key)
      (
        key: key,
        order: cited-count + i + 1,
        year-suffix: year-suffix,
        lang: lang,
        entry-type: entry.at("entry_type", default: "misc"),
        fields: entry.at("fields", default: (:)),
        parsed-names: entry.at("parsed_names", default: (:)),
        rendered: rendered,
        ref-label: ref-label,
        labeled-rendered: [#rendered #ref-label],
        is-cited: false,
      )
    })

  // 合并并排序
  let all-entries = cited-entries + uncited-entries
  all-entries = _sort-entries(all-entries, current-style)

  // 重新分配 order（author-date 模式下按排序后的顺序）
  if current-style == "author-date" {
    for (i, e) in all-entries.enumerate() {
      e.order = i + 1
    }
  }

  all-entries
}

// ============================================================================
// 高层 API：开箱即用，符合 GB/T 7714 标准
// ============================================================================

/// 渲染参考文献列表（高层 API）
///
/// - title: 参考文献标题
///   - `auto`（默认）：根据正文语言自动选择（"参考文献" 或 "References"），一级标题
///   - `none`：不显示标题
///   - 自定义内容：直接显示（可传入 `heading(level: 2)[...]` 控制级别）
/// - full: 是否显示所有参考文献（即使未被引用），默认 false
/// - full-control: 完全控制渲染的回调函数（可选）
///   - 签名：`(entries) => content`
///   - entries: 由 `get-cited-entries()` 返回的数组
///   - 使用此参数时，库只负责提供数据，用户完全控制输出
///
/// 使用方法：
/// ```typst
/// // 标准用法
/// #gb7714-bibliography()
///
/// // 自定义标题级别
/// #gb7714-bibliography(title: heading(level: 2)[参考文献])
///
/// // 显示所有参考文献（即使未被引用）
/// #gb7714-bibliography(full: true)
///
/// // 完全自定义渲染
/// #gb7714-bibliography(full-control: entries => {
///   for e in entries [
///     [#e.order]#h(0.5em)#e.rendered
///     #parbreak()
///   ]
/// })
/// ```
#let gb7714-bibliography(
  title: auto,
  full: false,
  full-control: none,
) = {
  context {
    let bib = _bib-data.get()

    // 处理 auto 标题 - 基于正文语言而非文献语言
    let actual-title = title
    if title == auto {
      let text-lang = text.lang
      let is-chinese = text-lang == "zh"
      actual-title = heading(numbering: none, if is-chinese {
        "参考文献"
      } else { "References" })
    }

    // 显示标题
    if actual-title != none {
      actual-title
    }

    let current-config = _config.get()
    // 根据 full 参数选择获取所有条目或仅获取被引用的条目
    let entries = if full {
      get-all-entries(config: current-config)
    } else {
      get-cited-entries(config: current-config)
    }
    let current-style = _style.get()

    // 如果用户提供了 full-control，完全交给用户
    if full-control != none {
      full-control(entries)
    } else if current-style == "numeric" {
      // 顺序编码制：悬挂缩进
      set par(hanging-indent: 2em, first-line-indent: 0em)
      for e in entries {
        [[#e.order]#h(0.5em)#e.labeled-rendered]
        parbreak()
      }
    } else {
      // 著者-出版年制：悬挂缩进
      set par(hanging-indent: 2em, first-line-indent: 0em)
      for e in entries {
        e.labeled-rendered
        parbreak()
      }
    }
  }
}

/// 多引用合并：按作者分组，同作者年份用逗号，不同作者用分号
///
/// 用法：
/// ```typst
/// // 简单形式（字符串）
/// #multicite("smith2020a", "smith2020b", "jones2019")
///
/// // 混合形式（字符串 + 字典）
/// #multicite(
///   (key: "smith2020a", supplement: [260]),
///   "smith2020b",
///   (key: "jones2019", supplement: [Ch. 3]),
/// )
///
/// // 非上标形式
/// #multicite("smith2020a", "smith2020b", form: "prose")
///
/// // 内容体形式（支持 @key 引用和页码）
/// #multicite[@smith2020 @jones2021]
/// #multicite[@smith2020[p. 42] @jones2021]
/// ```
///
/// 参数：
/// - keys: 引用键列表，每个元素可以是：
///   - 字符串：引用键
///   - 字典：(key: 引用键, supplement: 页码)
///   - 内容体中的 @key 引用
/// - form: 引用形式（可选）
///   - none/"normal": 默认（numeric 上标，author-date 带括号）
///   - "prose": 非上标形式
///
/// 输出：
/// - numeric 模式：[1, 260; 2-3]（带 supplement 的单独显示，其他压缩）
/// - author-date 模式：（Smith，2020a, 260，2020b；Jones，2019, Ch. 3）
#let multicite(..args) = {
  let raw-list = args.pos()
  let form = args.named().at("form", default: none)

  // 边界情况：空引用列表
  if raw-list.len() == 0 {
    return []
  }

  // 内容体形式：#multicite[@key1 @key2 ...]
  // 当传入内容体时，会作为一个 content 类型的 positional 参数到达
  let normalized = if (
    raw-list.len() == 1 and type(raw-list.first()) == content
  ) {
    let body = raw-list.first()
    let children = if body.has("children") {
      body.children
    } else {
      (body,)
    }
    children
      .filter(it => it != [ ] and it != parbreak())
      .map(it => {
        if it.func() == ref {
          // @key 或 @key[supplement]
          let key = str(it.target)
          let supp = it.at("supplement", default: none)
          // ref supplement 为 auto 时表示没有指定 supplement
          let supp = if supp == auto { none } else { supp }
          (key: key, supplement: supp)
        } else {
          // 忽略其他内容（如普通文字）
          none
        }
      })
      .filter(it => it != none)
  } else {
    // 传统形式：字符串或字典参数
    raw-list.map(item => {
      if type(item) == str {
        (key: item, supplement: none)
      } else {
        (
          key: item.at("key"),
          supplement: item.at("supplement", default: none),
        )
      }
    })
  }

  // 放置所有 metadata 标记（用于收集引用顺序）
  for item in normalized {
    _cite-marker(item.key)
  }

  context {
    let bib = _bib-data.get()
    let citations = _collect-citations()
    let suffixes = _compute-year-suffixes(bib, citations)
    let current-style = _style.get()
    let current-version = _version.get()
    let cite-config = get-citation-config(current-version)

    if current-style == "numeric" {
      // 顺序编码制：保持原始顺序，连续的无 supplement 引用压缩
      // 格式：[1：250, 2-4]（整体在一个方括号内，用逗号分隔）
      let parts = ()
      let pending-orders = () // 待压缩的编号

      for item in normalized {
        let order = citations.at(item.key, default: 0)
        if item.supplement != none {
          // 有 supplement：先输出之前积累的无 supplement 编号，再输出当前
          if pending-orders.len() > 0 {
            let formatted = format-citation-numbers(pending-orders)
            parts.push(formatted)
            pending-orders = ()
          }
          // 编号：页码
          parts.push([#order#cite-config.locator-sep#item.supplement])
        } else {
          // 无 supplement：累积待压缩
          pending-orders.push(order)
        }
      }

      // 处理剩余的无 supplement 编号
      if pending-orders.len() > 0 {
        let formatted = format-citation-numbers(pending-orders)
        parts.push(formatted)
      }

      let first-key = normalized.first().key
      let result = parts.join(", ")
      let linked = link(label("gb7714-ref-" + first-key), [[#result]])

      // 根据 form 决定是否上标
      if form == "prose" or form == "full" {
        linked
      } else {
        super(linked)
      }
    } else {
      // 著者-出版年制：按作者分组
      // 收集引用信息
      let cite-info = normalized
        .map(item => {
          let entry = bib.at(item.key, default: none)
          if entry == none {
            return none
          }
          let names = entry.parsed_names.at("author", default: ())
          let first-author = if names.len() > 0 {
            names.first().at("family", default: "")
          } else {
            "?"
          }
          let lang = detect-language(entry)
          let year = str(entry.fields.at("year", default: "n.d."))
          let suffix = suffixes.at(item.key, default: "")
          (
            key: item.key,
            author: first-author,
            author-count: names.len(),
            year: year + suffix,
            lang: lang,
            supplement: item.supplement,
          )
        })
        .filter(x => x != none)

      // 按作者分组
      let groups = (:)
      for info in cite-info {
        if info.author not in groups {
          groups.insert(
            info.author,
            (
              author: info.author,
              author-count: info.author-count,
              lang: info.lang,
              years: (),
              first-key: info.key,
            ),
          )
        }
        // 年份带 supplement
        let year-entry = if info.supplement != none {
          (year: info.year, supplement: info.supplement)
        } else {
          (year: info.year, supplement: none)
        }
        groups.at(info.author).years.push(year-entry)
      }

      // 括号
      let lparen = cite-config.lparen
      let rparen = cite-config.rparen

      // 渲染每个作者组
      let parts = ()
      for (author, group) in groups.pairs() {
        // 格式化作者名
        let author-text = if group.author-count >= 2 {
          author + " " + (if group.lang == "zh" { "等" } else { "et al." })
        } else {
          author
        }
        // 连接年份（带 supplement）
        let years-parts = group.years.map(ye => {
          if ye.supplement != none {
            [#ye.year#cite-config.locator-sep#ye.supplement]
          } else {
            ye.year
          }
        })
        let years-content = years-parts.join(cite-config.author-year-sep)

        // 根据 form 决定格式
        if form == "prose" {
          // prose: Author (2020a, 2020b)
          parts.push([#author-text #lparen#years-content#rparen])
        } else {
          // normal: Author, 2020a, 2020b（整体加括号）
          parts.push([#author-text#cite-config.author-year-sep#years-content])
        }
      }

      // 用分号连接不同作者
      let result = parts.join(cite-config.multi-sep)
      let first-key = normalized.first().key

      if form == "prose" {
        // prose: 各组已经带括号，直接连接
        link(label("gb7714-ref-" + first-key), result)
      } else {
        // normal: 整体加括号
        link(label("gb7714-ref-" + first-key), [#lparen#result#rparen])
      }
    }
  }
}
