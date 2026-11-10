// GB/T 7714 双语参考文献系统 - 状态管理模块

// ============================================================
//                      状态定义
// ============================================================

#let _bib-data = state("gb7714-bib-data", (:))
#let _style = state("gb7714-style", "numeric")
#let _version = state("gb7714-version", "2025")  // "2015" 或 "2025"

// 显示配置
#let _config = state("gb7714-config", (
  show-url: true, // 是否显示 URL
  show-doi: true, // 是否显示 DOI
  show-accessed: true, // 是否显示访问日期
))

// 用于标记引用的辅助函数（使用 metadata + query 模式）
#let _cite-marker(key) = [#metadata(key)<gb7714-cite>]

// 从文档中收集所有引用并建立顺序映射
#let _collect-citations() = {
  let cites = query(<gb7714-cite>)
  let seen = (:)
  let order = 0
  for c in cites {
    let key = c.value
    if key not in seen {
      order += 1
      seen.insert(key, order)
    }
  }
  seen
}

// 计算年份后缀（用于 author-date 模式消歧）
// 返回 key -> suffix 的映射，如 ("smith2020a": "a", "smith2020b": "b")
#let _compute-year-suffixes(bib, citations) = {
  // 按 (第一作者姓, 年份) 分组
  let groups = (:)
  for key in citations.keys() {
    let entry = bib.at(key, default: none)
    if entry == none { continue }

    let names = entry.parsed_names.at("author", default: ())
    let first-author = if names.len() > 0 {
      names.first().at("family", default: "")
    } else { "" }
    let year = entry.fields.at("year", default: "")
    let group-key = first-author + "|" + str(year)

    if group-key not in groups {
      groups.insert(group-key, ())
    }
    groups
      .at(group-key)
      .push((key: key, title: entry.fields.at("title", default: "")))
  }

  // 为每组分配后缀
  let suffixes = (:)
  for (group-key, items) in groups.pairs() {
    if items.len() > 1 {
      // 按标题排序
      let sorted-items = items.sorted(key: it => it.title)
      let suffix-chars = "abcdefghijklmnopqrstuvwxyz"
      for (i, item) in sorted-items.enumerate() {
        if i < suffix-chars.len() {
          suffixes.insert(item.key, suffix-chars.at(i))
        }
      }
    }
  }
  suffixes
}
