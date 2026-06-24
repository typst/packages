#import "../consts.typ": *
#import "../utils/lib.typ": *

#let 攻读学位期间取得成果(info: (:)) = [
  #if (info.at(info-keys.攻读学位期间取得成果) == none) {
    return
  }

  #let title = "攻读"
  #if info.at(info-keys.学位类型) == "专业型" {
    title = title + "专业"
  } else if info.at(info-keys.学位类型) == "学术型" {
    title = title + "学术"
  }
  #if info.at(info-keys.申请学位级别) == "硕士" {
    title = title + "硕士"
  } else if info.at(info-keys.申请学位级别) == "博士" {
    title = title + "博士"
  }
  #let title = title + "学位期间取得的成果"

  #set par(first-line-indent: 0em)
  #set enum(numbering: "[1]")

  #let prefix-path = "../../../"
  #let bibs = info.at(info-keys.成果列表).at(成果列表-keys.成果文件)
  #let path = if type(bibs) == str {
    prefix-path + bibs
  } else if type(bibs) == array {
    bibs = bibs.map(item => { prefix-path + item })
  }
  #show heading.where(level: 2): set heading(outlined: false)
  #show heading.where(level: 3): set heading(outlined: false)
  #show heading.where(level: 4): set heading(outlined: false)
  #set text(size: font-size.五号)
  = #title
  #let style = "cite-style.csl"
  #if (info.at(info-keys.匿名)) {
    style = "cite-style-anonymous.csl"
  }
  #if not (
    info.at(info-keys.成果列表).at(成果列表-keys.条目) == none
      or info.at(info-keys.成果列表).at(成果列表-keys.条目).len() == 0
  ) {
    heading(level: 2, "发表论文")
    achievement-list(
      path,
      title: title,
      highlight-names: info.at(info-keys.成果列表).at(成果列表-keys.作者姓名),
      // 2. 核心数据列表：(BibKey, 作者顺序, 注释)
      // 顺序非常重要！列表显示的顺序将严格按照这里写的顺序排列
      items: info.at(info-keys.成果列表).at(成果列表-keys.条目),
      style: style,
    )
  }
  #if (info.at(info-keys.匿名) and info.at(info-keys.成果列表).at(成果列表-keys.其他成果-匿名) != none) {
    info.at(info-keys.成果列表).at(成果列表-keys.其他成果-匿名)
  } else {
    info.at(info-keys.成果列表).at(成果列表-keys.其他成果)
  }
]
