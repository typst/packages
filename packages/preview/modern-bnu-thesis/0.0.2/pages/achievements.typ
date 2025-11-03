#import "../utils/style.typ":字体,字号

#let achievement(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "在学期间完成的相关学术成果",
  outlined: true,
  papers:(),
  patents:()
) = {
  if (not anonymous) {
    pagebreak(weak: true, to: if twoside { "odd" })
    [
      #heading(level: 1, numbering: none, outlined: outlined, title) <no-auto-pagebreak>
       
      #align(center,text(font: 字体.黑体, size: 16pt, weight: "bold", "学术论文"))
      #{
        set text(font: 字体.宋体, size: 12pt)
        for (i,body) in papers.enumerate() {
          grid(columns: (2em,1fr),"["+str(i + 1)+"]",block(width: auto,body))
          
        }
      }
      #v(1em)

      #align(center,text(font: 字体.黑体, size: 16pt, weight: "bold", "专利"))
      #{
        set text(font: 字体.宋体, size: 12pt)
        for (i,body) in patents.enumerate() {
          grid(columns: (2em,1fr),"["+str(papers.len() + i + 1)+"]",block(width: auto,body))
          
        }
      }
       
      
    ]
  }
}