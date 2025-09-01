#import "../thesis-vars.typ": *


#set page(
  paper: "a4",
  margin: (top: 30mm, bottom: 30mm, left: 30mm, right: 30mm),
  header-ascent: 15mm,  // 页眉距边界15mm
  footer-descent: 15mm,  // 页脚距边界15mm
)

#set text(font: ("SimSun", "Times New Roman"))

// Title page layout
#align(center)[
  #v(20pt)
  
  // Header information
  #align(center)[
  #table(
    columns: (180pt, 180pt, 180pt, 180pt),
    stroke: 1pt,
    inset: 6pt,
    align: (left, center, center, center),
    [分类号], [], [密级],[#classification],
    [UDC #text(size: 8pt, baseline: -3pt)[注1]],[],[],[]
  )
  ]

  #v(35pt)
  
  // Main title
  #align(center)[
    #text(font: "SimHei", size: 22pt, weight: "bold")[学 位 论 文]
    
    #v(15pt)
    
    #text(font: "SimHei", size: 16pt, weight: "bold")[#thesis-title]
    
    #v(8pt)
    
    #text(font: "SimSun", size: 12pt)[（题名和副题名）]
  ]
  
  #v(35pt)
  
  // Author information
  #table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: 8pt,
    align: center,
    [], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 14pt, weight: "bold")[#author-name]]]], [],
    [], [（作者姓名）], [],
  )
  
  #v(15pt)
  
  // Advisor information
  #table(
    columns: (100pt, 120pt, 80pt, 100pt),
    stroke: none,
    inset: 8pt,
    align: center,
    [指导教师], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt, weight: "bold")[#advisor-name]]]], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt)[#advisor-title]]]], [],
    [], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[电子科技大学]]], 
  )
  
  #v(20pt)
  
  // Degree information
  #table(
    columns: (140pt, 120pt, 140pt, 140pt),
    stroke: none,
    inset: 8pt,
    align: center,
    [申请学位级别], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt, weight: "bold")[硕士]]]], [专业学位类别], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt, weight: "bold")[#discipline]]]],
  )
  
  #table(
    columns: (140pt, 140pt, 140pt, 140pt),
    stroke: none,
    inset: 8pt,
    align: center,
    [提交论文日期], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt)[#submission-date]]]], [论文答辩日期], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt)[#defense-date]]]],
  )
  
  #table(
    columns: (200pt, 200pt, 140pt),
    stroke: none,
    inset: 8pt,
    align: center,
    [学位授予单位和日期], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #align(center)[#text(size: 12pt)[电子科技大学 #h(10pt) #approval-date]]]], [],
  )
  
  #table(
    columns: (140pt, 400pt),
    stroke: none,
    inset: 8pt,
    align: (left, center),
    [答辩委员会主席], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(size: 12pt)[]]],
  )
  
  #table(
    columns: (140pt, 400pt),
    stroke: none,
    inset: 8pt,
    align: (left, center),
    [评阅人], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(size: 12pt)[]]],
  )
  
  #v(15pt)
  
  #text(size: 9pt)[注 1: 注明《国际十进分类法 UDC》的类号。]
] 