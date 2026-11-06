// 中英双语参考文献：英文条目的“等”显示为“et al.”
//
// 原理：Typst 的 CSL 引擎（hayagriva）只支持单一全局语言环境（由 text.lang 决定），
// 无法像 citeproc-js 那样按条目语言切换。这里对渲染结果做最小字符串替换：
// 检测到纯英文条目时，把其中的“等”替换为“et al.”、“第 N 卷/册”替换为“Vol./Bk. N”。
// 中文判定正则与替换表参考 modern-nju-thesis 的同名函数（MIT License），
// 按本模板所用 CSL（GB/T 7714—2015 顺序编码双语变体）的实际差异项裁剪。
//
// 已知限制：
// - 依赖顺序编码制文献列表的网格结构（序号列 x=0，内容列 x=1）；
//   换用不产生网格的 CSL 样式时静默回退为原始渲染。
// - 被替换的条目以纯文本重新排版，条目内的链接等结构不保留
//   （本 CSL 仅纯电子资源输出 URL，而此类条目通常不含“等”，实际不受影响）。
// - 含译者（“译”）的英文条目未做转换，需人工核对。

#let _to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(_to-string).join("")
  } else if content.has("child") {
    _to-string(content.child)
  } else if content.has("body") {
    _to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// 去除文献列表特征字后仍含两个以上连续汉字，判定为中文条目
#let _is-chinese(text) = {
  let pure = text.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
  pure.find(regex("\p{sc=Hani}{2,}")) != none
}

#let bilingual-bibliography(
  bibliography: none,
  title: "参考文献",
  full: false,
) = {
  assert(bibliography != none, message: "请传入带有 source 的 bibliography 函数。")

  // 结构标签：供 scripts/build.* 定位查重版（for-check）抽页范围
  [#metadata(none) <backmatter-start>]

  [
    #show grid.cell.where(x: 1): it => {
      let t = _to-string(it)
      if _is-chinese(t) {
        it
      } else {
        // 第 N 卷/册、卷/册 N → Vol./Bk. N
        let r = t.replace(
          regex("第\s?(\d+)\s?([卷册])"),
          m => {
            let term = if m.captures.at(1) == "卷" { "Vol. " } else { "Bk. " }
            term + m.captures.at(0)
          },
        )
        r = r.replace(
          regex("([卷册])\s?(\d+)"),
          m => {
            let term = if m.captures.at(0) == "卷" { "Vol. " } else { "Bk. " }
            term + m.captures.at(1)
          },
        )
        // “等”及其后随标点 → “et al.”
        r = r.replace(
          regex("等(.)?"),
          m => {
            "et al."
            let tail = m.captures.at(0)
            if tail != none and tail != "." { tail }
          },
        )
        // 替换未生效时保留原始内容，避免纯文本重排丢失条目内结构
        if r == t { it } else { r }
      }
    }
    #bibliography(title: title, full: full)
  ]
}
