// 双语参考文献：按条目语言选择「等」还是「et al.」
//
// 问题
// ----
// GB/T 7714 规定：作者超过 3 位时列前 3 位，中文文献后加「等」，英文文献后加「et al.」。
// 但 Typst 只支持用 `set text(lang: …)` **整篇统一**选择「等」或「et al.」，
// 不支持逐条设置 —— 实测给条目加 `language` / `langid` 字段均无效。
// 于是 `lang: "zh"` 的论文里，英文文献也会显示成「等」，与规范不符。
//
// 上游现状
// --------
// CSL 本身无法描述「按文献语言切换渲染」；CSL-M 扩展可以，但 Typst 用的参考文献引擎
// （hayagriva）不支持。Typst 中文社区的 FAQ 给了两类解法：
//   ① 替换字符（本文件）—— 简单快速，在 Typst 内置机制上做后处理；可能有误判
//   ② 换用 citext / gb7714-bilingual 等替换引擎 —— 根治，但性能差（1s → 10s+）、
//      `@a @b` 不能直接用、不支持导出 HTML
// 本模板取法 ①，与 modern-nju-thesis 的 `bilingual-bibliography` 同思路，
// 只保留最必要的一条替换（等 → et al.），不引入外部依赖。
//
// 参考：Typst 中文社区《如何修复英文参考文献中的"等"？》
//       https://typst-doc-cn.github.io/guide/FAQ/bib-etal-lang.html

// 把内容递归拍平成字符串（参考文献条目是 grid 单元格，内容是嵌套的）
#let 转文本(content) = {
  if content == none { "" }
  else if content.has("text") { content.text }
  else if content.has("children") { content.children.map(转文本).join("") }
  else if content.has("child") { 转文本(content.child) }
  else if content.has("body") { 转文本(content.body) }
  else if content == [ ] { " " }
  else { "" }
}

// 判断条目是否为中文文献：去掉常见著录字词后仍有「至少两个连续汉字」
#let 是中文条目(s) = {
  let 纯 = s.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
  纯.find(regex("\\p{sc=Hani}{2,}")) != none
}

// 给 bibliography 的输出套一层：非中文条目把「等」换成「et al.」
// 用法：`#双语文献(bibliography("refs.bib", style: "gb-7714-2005-numeric", title: none))`
#let 双语文献(body) = {
  show grid.cell.where(x: 1): it => {
    let s = 转文本(it)
    // 替换成「et al」而不带句点：CSL 输出的是「等.」，补上句点正好得到「et al.」
    if 是中文条目(s) { it } else { s.replace("等", "et al") }
  }
  body
}
