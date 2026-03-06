// GB/T 7714 双语参考文献系统 - 文献类型标识模块

#import "versions/mod.typ": get-type-map

/// 渲染文献类型标识 [J] [M] 等
/// - entry-type: BibTeX 条目类型
/// - has-url: 是否有 URL 或 DOI
/// - version: 标准版本 ("2015" | "2025")
#let render-type-id(entry-type, has-url: false, version: "2025") = {
  let type-map = get-type-map(version)
  let base = type-map.at(lower(entry-type), default: "Z")

  // 有 URL 或 DOI 的添加 /OL 载体标识
  if has-url and not base.contains("OL") {
    "[" + base + "/OL]"
  } else if base == "EB" {
    "[EB/OL]" // 网页默认就是在线
  } else {
    "[" + base + "]"
  }
}
