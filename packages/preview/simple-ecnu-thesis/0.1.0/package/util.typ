// 双页模式
#let switch-two-side(to-page) = {
  if to-page {
    pagebreak(weak: true, to: "odd")
  } else {
    pagebreak(weak: true)
  }
}

// CJK 换行问题修复
#let han-or-punct = "[-\p{sc=Hani}。．，、：；！‼？⁇⸺——……⋯⋯～–—·・‧/／「」『』“”‘’（）《》〈〉【】〖〗〔〕［］｛｝＿﹏●•]"
#let cjk-fix(doc) = {
  show regex(han-or-punct + " " + han-or-punct): it => {
    let (a, _, b) = it.text.clusters()
    a + b
  }
  doc
}

