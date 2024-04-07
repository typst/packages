// Tested only on GB-7714-2015-Numeric
#let bilingual-bibliography(
  bibliography: none,
  title: "参考文献",
  full: false,
  mapping: (:),
) = {
  assert(bibliography != none, message: "请传入带有 source 的 bibliography 函数。")
  // Please fill in the remaining mapping table here
  mapping = (
    "等": "et al",
    "卷": "Vol.",
  ) + mapping
  let using-chinese = state("using-chinese-in-bibliography", false)
  show regex("^\[\d+\]$"): it => {
    using-chinese.update(false)
    it
  }
  show regex("\p{sc=Hani}+"): it => {
    context if using-chinese.get() {
      it
    } else {
      mapping.at(it.text, default: it)
    }
    using-chinese.update(true)
  }
  set text(lang: "zh")

  bibliography(
    title: title,
    full: full,
    style: "gb-7714-2015-numeric",
  )
}