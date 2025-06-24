// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("教育经历")

#cvEntry(
  title: [数据科学硕士],
  society: [加利福尼亚大学洛杉矶分校],
  date: [2018 - 2020],
  location: [美国],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [论文: 使用机器学习算法和网络分析预测电信行业的客户流失],
    [课程: 大数据系统与技术 #hBar() 数据挖掘与探索 #hBar() 自然语言处理],
  ),
)

#cvEntry(
  title: [计算机科学学士],
  society: [加利福尼亚大学洛杉矶分校],
  date: [2014 - 2018],
  location: [美国],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [论文: 探索使用机器学习算法预测股票价格: 回归与时间序列模型的比较研究],
    [课程: 数据库系统 #hBar() 计算机网络 #hBar() 软件工程 #hBar() 人工智能],
  ),
)
