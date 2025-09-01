// Header utility functions
#let header-content(header_text) = [
  #align(center)[
    #text(font: "SimSun", size: 10.5pt)[#header_text]
  ]
  #v(-0.8em)
  #line(length: 100%, stroke: 0.75pt)
]

#let header-text = "电子科技大学硕士学位论文"

// 动态页眉内容
#let dynamic-header = context {
  let current-page = counter(page).get().first()
  if calc.rem(current-page,2)  == 0 {
    header-content("电子科技大学硕士学位论文" )
  } else {
    // 获取本章的标题
    let headings = query(heading.where(level: 1))
    let current-chapter = none
    let current-chapter-num = none
    let here-loc = here()
    
    
    
    // 找到当前位置之前或当前页的最近的一级标题
    for h in headings {
      if h.location().page() <= here-loc.page() {
        current-chapter = h.body
        current-chapter-num = counter(heading).at(h.location()).first()
      } else {
        break
      }
    }
    // 获取标题纯文本
    let title-text = repr(current-chapter)
    title-text = title-text.replace("[", "").replace("]", "").replace("\"", "")
    title-text = title-text.replace(regex("第.+?章\\s*"), "")
    title-text = title-text.trim()
    
    // 判断是否有编号,正文以后的独立部分无numbering
    let has-numbering = false
    if current-chapter != none {
      let heading-els = query(heading.where(body: current-chapter))
      if heading-els.len() > 0 {
        has-numbering = heading-els.first().numbering != none
      }
    }

    
    if current-chapter != none and has-numbering and current-chapter-num != none {
      // 获取中文章节编号
      let chinese-nums = ("一", "二", "三", "四", "五", "六", "七", "八", "九", "十")
      let chapter-chinese = if current-chapter-num <= 10 { chinese-nums.at(current-chapter-num - 1) } else { str(current-chapter-num) }
      let header-text = "第" + chapter-chinese + "章 " + title-text
      header-content(header-text)
    } else if title-text != none {
      header-content(title-text)
    } else {
      header-content(header-text)
    }
  }
}