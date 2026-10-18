#let term-state = state("glossary-terms", ())

// 函数：输入中文和英文，文中显示 "中文 (英文)" 并后台记录
#let term(cn, en) = {
  // 1. 在文中显示文本
  cn + "（" + en + "）"

  // 2. 获取当前位置并更新状态
  context {
    let loc = here() // 获取当前函数被调用时的位置对象
    
    term-state.update(terms => {
      // 检查是否已存在（只记录首次出现，因此如果存在则忽略）
      if terms.any(t => t.cn == cn) {
        terms
      } else {
        // 将中文、英文、以及当前的位置(loc)一起存入
        terms.push((cn: cn, en: en, loc: loc))
        terms
      }
    })
  }
}

#let print-glossary() = {
  context {
    let terms = term-state.final()
    // 按英文首字母排序
    let sorted-terms = terms.sorted(key: t => lower(t.en))

    if sorted-terms.len() == 0 {
      [暂无术语记录。]
    } else {
      // 设置表格样式（这里用了典型的学术三线表风格）
      table(
        columns: (1fr, 2fr, auto), // 三列：中文、英文、页码
        inset: 5pt,
        align: (col, row) => (right, left, center).at(col),
        stroke: (x, y) => {
          if y == 0 { (bottom: 1pt) } // 表头下粗线
          else { (bottom: 0.5pt + gray) } // 内容下细线
        },
        
        // 表头
        [*中文名称*], [*英文全称*], [*首次出现*],
        
        // 数据填充
        ..sorted-terms.map(item => {
          // 获取该位置的页码
          let page-num = item.loc.page()
          
          (
            item.cn, 
            item.en, 
            // 创建一个链接，点击页码跳回原文位置
            link(item.loc)[第 #page-num 页]
          )
        }).flatten()
      )
    }
  }
}