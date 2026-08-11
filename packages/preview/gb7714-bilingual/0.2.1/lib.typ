// gb7714-bilingual - GB/T 7714 双语参考文献系统
// 支持 GB/T 7714—2015 和 GB/T 7714—2025 两个版本
// 基于 citegeist 自定义实现，支持中英文术语自动切换
//
// 使用方法：
//   #import "@preview/gb7714-bilingual:0.2.1": init-gb7714, gb7714-bibliography, multicite
//   #show: init-gb7714.with(read("ref.bib"), style: "numeric", version: "2025")
//   正文中使用 @key 引用...
//   #gb7714-bibliography()
//
// 多文件支持：
//   #show: init-gb7714.with(read("main.bib") + read("extra.bib"), style: "numeric")
//
// 版本选择：
//   - version: "2015" - 符合 GB/T 7714—2015
//   - version: "2025" - 符合 GB/T 7714—2025（2026-07-01实施，默认）

// 导入内部实现
#import "src/api.typ": (
  gb7714-bibliography, get-cited-entries, init-gb7714-impl, multicite,
)

/// 初始化 GB/T 7714 双语参考文献系统
///
/// - bib-content: BibTeX 文件内容（使用 `read("ref.bib")` 读取）
///                多文件可用 `read("a.bib") + read("b.bib")` 合并
/// - style: 引用风格，"numeric"（顺序编码制）或 "author-date"（著者-出版年制）
/// - version: 标准版本，"2015" 或 "2025"（默认）
/// - show-url: 是否显示 URL（默认 true）
/// - show-doi: 是否显示 DOI（默认 true）
/// - show-accessed: 是否显示访问日期（默认 true）
#let init-gb7714(
  bib-content,
  style: "numeric",
  version: "2025",
  show-url: true,
  show-doi: true,
  show-accessed: true,
  doc,
) = {
  // 调用内部实现
  init-gb7714-impl(
    bib-content,
    style: style,
    version: version,
    show-url: show-url,
    show-doi: show-doi,
    show-accessed: show-accessed,
    doc,
  )
}
