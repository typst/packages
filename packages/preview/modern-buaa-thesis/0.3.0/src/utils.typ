#let degree-text(degree-type) = {
  if degree-type == "master" {
    return (
      zh: "硕士",
      zh-student: "硕士研究生",
      zh-thesis: "硕士学位论文",
      zh-achievement: "攻读硕士学位期间取得的成果",
      en: "Master",
    )
  }

  if degree-type == "pro-master" {
    return (
      zh: "专业硕士",
      zh-student: "专业硕士研究生",
      zh-thesis: "专业硕士学位论文",
      zh-achievement: "攻读硕士学位期间取得的成果",
      en: "Professional Master",
    )
  }

  return (
    zh: "博士",
    zh-student: "博士研究生",
    zh-thesis: "博士学位论文",
    zh-achievement: "攻读博士学位期间取得的成果",
    en: "Doctor",
  )
}

#let distr(s, w) = {
  box(width: w, stack(dir: ltr, ..s.clusters().map(x => [#x]).intersperse(1fr)))
}

#let reset-page() = {
  counter(page).update(1)
}

#let show-heading-number = state("show-heading-number", true)

#let disable-heading-number() = {
  show-heading-number.update(false)
}

#let heading-numbering(..num) = context {
  if num.pos().len() == 1 {
    return "第" + numbering("一", ..num) + "章"
  }

  if num.pos().len() == 2 {
    return numbering("1.1", ..num)
  }

  if num.pos().len() == 3 {
    return numbering("1.1.1", ..num)
  }
}


