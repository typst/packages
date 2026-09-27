// ============================================================
// headings-meta.typ — 标题元数据接口
// ============================================================
//
// 所有通过 heading supplement 传递的元数据字段定义在此集中管理。
// 修改字段名时需检查所有消费者：
//   - headings-show-rule (headings.typ): pagebreak, part, reset-page
//   - sizedheading (headings.typ):       spacing-before/after, linespacing, font
//   - make-header (header.typ):          show-page-marks
//   - make-footer (footer.typ):          show-page-marks
//
//  字段一览：
//   pagebreak: bool         - 是否在此 heading 前分页（默认 true）
//   part: int | none         - 状态转换目标 (0/1/2/none)
//   reset-page: bool        - 是否重置页码为 1（默认 false）
//   show-page-marks: bool   - 是否显示页眉和页码（默认 true）
//   header: content | none  - 自定义页眉文本（替换章节标题）
//   spacing-before/after    - 覆盖默认段间距
//   linespacing             - 覆盖默认行距
//   font                    - 覆盖默认字体

/// 从 heading 的 supplement 中提取元数据字典。
/// 元数据通过 metadata 嵌入在 supplement 字段中。
#let get-heading-meta(it) = {
  if it.supplement != none and it.supplement.func() == metadata {
    it.supplement.value
  } else {
    (:)
  }
}

/// 查找与指定位置相关的 1 级标题
/// - current: 与 location 同一物理页、位于其后的第一个 1 级标题
/// - governing: 本页应遵循的标题
/// 页眉/页脚取 governing 的元数据做显示决策。
/// 注意：本函数内部使用 query / location，须在 context 内调用。
#let get-page-headings(location) = {
  let physical-page = location.page()
  let after = query(selector(heading.where(level: 1)).after(location))
  let before = query(selector(heading.where(level: 1)).before(location))
  let current = if after.len() > 0 {
    let next = after.first()
    if next.location().page() == physical-page { next } else { none }
  } else { none }
  let governing = if current != none {
    current
  } else if before.len() > 0 {
    before.last()
  } else { none }
  (current: current, governing: governing)
}
