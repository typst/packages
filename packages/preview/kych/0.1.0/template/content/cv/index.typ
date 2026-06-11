// =============================================================================
// 简历/个人履历页 (CV / Curriculum Vitae)
// =============================================================================
// 以 Edward R. Tufte（Tufte CSS 的精神来源）为例展示简历页面布局：
// 1. 使用侧注 (margin-note) 放置个人联系方式
// 2. 使用侧注放置图片和图片说明
// 3. 使用 citegeist 包从 BibTeX 文件加载著作和论文列表
// 4. 侧注与正文内容交错排列的排版方式
// =============================================================================

#import "../index.typ": template, kych
#show: template
// citegeist 包：用于加载和处理 BibTeX 文献数据
#import "@preview/citegeist:0.2.2": load-bibliography

// 页面标题
= Edward R. Tufte

// 侧注：个人信息卡片（显示在右侧边距中）
#kych.margin-note[
  统计学家、艺术家、名誉教授 \
  网站: #link("https://www.edwardtufte.com")[edwardtufte.com] \
  邮箱: #link("mailto:noreply@edwardtufte.com")[`noreply@edwardtufte.com`]
]

// 研究方向简介
研究统计证据和用于信息可视化的分析设计，整合统计学、平面设计和认知科学的原理，实现定量数据的有效呈现。

// --- 工作经历 ---
== 工作经历
- *1983 年至今*: Graphics Press 创始人兼出版人。专注于信息设计和数据可视化的独立出版社。
- *1977--1999*: 耶鲁大学名誉教授。政治学、统计学与计算机科学系。
- *1967--1977*: 普林斯顿大学讲师。伍德罗·威尔逊公共与国际事务学院。

// --- 艺术作品 ---
== 艺术作品

// 侧注：展示雕塑作品图片
#kych.margin-note[
  #image("escaping-flatland.webp")
]

// 侧注：图片说明文字
#kych.margin-note[
  致敬 Edward R. Tufte 的大型不锈钢雕塑《逃离平面国》
]

// 正文：艺术成就描述
Hogpen Hill 农场创始人，该农场是位于康涅狄格州伍德伯里的 234 英亩雕塑公园。创作了包括《拉金的枝条》和《逃离平面国》系列在内的大型作品，并在奥尔德里奇当代艺术馆展出。

// --- 研究贡献 ---
== 研究贡献
// sparklines（迷你图）和 data-ink ratio（数据墨水比）是 Tufte 的重要贡献
发明了迷你图（sparklines）——一种在文本中嵌入高分辨率数据图形的方法，并提出了数据墨水比作为衡量图形效率的量化指标。

// --- 著作列表 ---
== 著作
#{
  // 从 books.bib 文件加载著作数据
  let bib = load-bibliography(read("books.bib"))
  // 倒序遍历（rev），显示为：年份 + 书名（斜体）
  for item in bib.values().rev() [
    #let data = item.fields
    - #strong(data.year): #emph(data.title)
  ]
}

// --- 论文列表 ---
== 论文
#{
  // 从 papers.bib 文件加载论文数据
  let bib = load-bibliography(read("papers.bib"))
  // 显示为：作者, "标题," 期刊, 年份. DOI: 链接
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}

// --- 教育背景 ---
== 教育背景
- 政治学博士: 耶鲁大学 (1968)
- 统计学硕士: 斯坦福大学
- 统计学学士: 斯坦福大学
