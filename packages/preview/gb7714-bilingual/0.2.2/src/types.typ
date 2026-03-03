// GB/T 7714 双语参考文献系统 - 文献类型标识模块

#import "versions/mod.typ": get-type-map

/// 渲染文献类型标识 [J] [M] 等
/// - entry-type: BibTeX 条目类型
/// - has-url: 是否有 URL 或 DOI
/// - version: 标准版本 ("2015" | "2025")
/// - mark: 用户指定的类型标识（覆盖自动检测）
/// - medium: 用户指定的载体标识（覆盖自动检测）
#let render-type-id(
  entry-type,
  has-url: false,
  version: "2025",
  mark: none,
  medium: none,
) = {
  let type-map = get-type-map(version)

  // 类型标识：优先使用用户指定的 mark，否则从 type-map 查找
  let base = if mark != none {
    upper(mark)
  } else {
    type-map.at(lower(entry-type), default: "Z")
  }

  // 载体标识：优先使用用户指定的 medium
  // 否则根据 has-url 自动添加 /OL
  let carrier = if medium != none {
    upper(medium)
  } else if has-url and not base.contains("OL") and base != "EB" {
    "OL"
  } else {
    none
  }

  // 组合输出
  if base == "EB" {
    "[EB/OL]" // 网页默认就是在线
  } else if carrier != none {
    "[" + base + "/" + carrier + "]"
  } else {
    "[" + base + "]"
  }
}
