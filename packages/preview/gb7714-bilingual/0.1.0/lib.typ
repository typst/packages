// gb7714-bilingual - GB/T 7714 双语参考文献系统
// 支持 GB/T 7714—2015 和 GB/T 7714—2025 两个版本
// 基于 citegeist 自定义实现，支持中英文术语自动切换
//
// 使用方法：
//   #import "@preview/gb7714-bilingual:0.1.0": init-gb7714, gb7714-bibliography, multicite
//   #show: init-gb7714.with("/ref.bib", style: "numeric", version: "2025")
//   正文中使用 @key 引用...
//   #gb7714-bibliography()
//
// 多文件支持：
//   #show: init-gb7714.with(("/main.bib", "/extra.bib"), style: "numeric")
//
// 注意：bib-file 路径必须以 "/" 开头（基于项目根目录的绝对路径）
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
/// - bib-files: BibTeX 文件路径，可以是单个路径或路径数组
///              路径必须以 "/" 开头（基于项目根目录）
/// - style: 引用风格，"numeric"（顺序编码制）或 "author-date"（著者-出版年制）
/// - version: 标准版本，"2015" 或 "2025"（默认）
/// - show-url: 是否显示 URL（默认 true）
/// - show-doi: 是否显示 DOI（默认 true）
/// - show-accessed: 是否显示访问日期（默认 true）
#let init-gb7714(
  bib-files,
  style: "numeric",
  version: "2025",
  show-url: true,
  show-doi: true,
  show-accessed: true,
  doc,
) = {
  // 统一转换为数组
  let files = if type(bib-files) == array { bib-files } else { (bib-files,) }

  // 读取并合并所有 bib 文件内容
  let bib-content = files.map(f => read(f)).join("\n\n")

  // 创建隐藏的 bibliography（让 @key 语法工作）
  // Typst 的 bibliography() 函数支持多个文件
  let hidden-bib = hide(bibliography(..files, style: "ieee"))

  // 调用内部实现
  init-gb7714-impl(
    bib-content,
    hidden-bib,
    style: style,
    version: version,
    show-url: show-url,
    show-doi: show-doi,
    show-accessed: show-accessed,
    doc,
  )
}
