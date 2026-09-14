#let layout-settings = (
  gap-header: 0.4em,   
  gap-line-top: 0.5em, 
  gap-line-btm: 0.4em, 
  inset: 8pt,          
)

#let get-palette(color) = {
  (
    border: color.lighten(80%),
    tag-bg: color.lighten(92%),
    text-gray: rgb("#4b5563"),
    text-light: rgb("#6b7280"),
    bullet: color.lighten(40%)
  )
}

#let wordc(
  term,             
  pos: none,        
  def: "",          
  examples: (),     
  accent-color: rgb("#0f766e")
) = {
  // --- 模式判断 ---
  let is-comparison = (type(term) == array)
  
  let (word-left, word-right) = if is-comparison {
    (term.at(0), term.at(1))
  } else {
    (term, none)
  }

  // --- 确定高亮目标词 ---
  let highlight-target = if is-comparison { word-right } else { word-left }

  // --- 数据清洗 ---
  let example-list = if type(examples) == array { examples } else if type(examples) == str { (examples,) } else { () }
  let palette = get-palette(accent-color)

  // --- 渲染主体 ---
  block(
    width: 100%,
    stroke: 0.5pt + palette.border,
    radius: 4pt,
    fill: white,
    breakable: false,
    clip: true,
    inset: 0pt,
    stack(dir: ttb,
      
      // [A] 头部区域
      block(
        width: 100%,
        inset: layout-settings.inset,
        fill: { palette.tag-bg },
        stroke: { (bottom: 0.5pt + palette.border) } ,
        
        if is-comparison {
          // 对比模式头部
          grid(
            columns: (1fr, auto, 1fr),
            align: horizon,
            align(left, text(size: 1em, fill: palette.text-light, style: "italic", word-left)),
            align(center, text(size: 1em, fill: palette.bullet, sym.arrow.r)),
            align(right, text(size: 1.1em, fill: accent-color, weight: "bold", word-right))
          )
        } else {
          // 标准模式头部
          stack(dir: ltr, spacing: 1fr,
            text(weight: "bold", size: 1.1em, fill: accent-color, word-left),

          )
        }
      ),

      // [B] 内容区域 (释义 + 例句)
      if def != "" or example-list != () {
        block(
          width: 100%,
          inset: (
            left: layout-settings.inset, 
            right: layout-settings.inset, 
            bottom: layout-settings.inset,
            top: if is-comparison { layout-settings.inset } else { 0pt } 
          ),
          {
            // 标准模式下的顶部间距
            if not is-comparison and def != "" { v(layout-settings.gap-header) }
            
            // 释义
            if pos != none {
              box(
                inset: (x: 5pt, y: 2pt),
                baseline: 15%,
                radius: 3pt,
                
                fill: palette.tag-bg,
                text(size: 0.75em, style: "italic", weight: "medium", fill: accent-color, pos)
              )
              h(8pt)
            }
            if def != "" {
              text(size: 0.95em, fill: palette.text-gray, def)
            }

            // 例句
            if example-list != () {
              stack(
                dir: ttb,
                spacing: 0.6em,
                ..example-list.map(ex => {
                  let bullet-symbol = { "”" }
                  let bullet-size = { 1.4em }
                  let bullet-color = { palette.border.darken(20%) }
                  let bullet-baseline = { 0pt }
                  
                  grid(
                    columns: (0.8em, 1fr),
                    gutter: 0.4em,
                    align(top, text(size: bullet-size, fill: bullet-color, baseline: bullet-baseline, bullet-symbol)),
                    par(
                      leading: 0.3em, 
                      {
                        set text(size: 0.9em, fill: palette.text-light, style: "italic")
                        // --- 智能高亮算法 ---
                        let word-len = highlight-target.len()
                        // 提取词根：长单词取前70%，短单词全取
                        let stem = if word-len > 4 {
                           highlight-target.slice(0, int(word-len * 0.7))
                        } else {
                           highlight-target
                        }
                        // 正则匹配：忽略大小写 + 词根开头 + 单词边界
                        show regex("(?i)\\b" + stem + "\\w*"): it => text(
                          weight: "bold", 
                          fill: accent-color, 
                          style: "normal", 
                          it
                        )
                        ex
                      }
                    )
                  )
                })
              )
            }
          }
        )
      }
    )
  )
}