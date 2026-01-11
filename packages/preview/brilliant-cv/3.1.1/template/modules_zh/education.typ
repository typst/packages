// Imports
#import "@preview/brilliant-cv:3.1.1": cv-section, cv-entry, h-bar


#cv-section("教育经历")

#cv-entry(
  title: [数据科学硕士],
  society: [加利福尼亚大学洛杉矶分校],
  date: [2018 - 2020],
  location: [美国],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [论文: 使用机器学习算法和网络分析预测电信行业的客户流失],
    [课程: 大数据系统与技术 #h-bar() 数据挖掘与探索 #h-bar() 自然语言处理],
  ),
)

#cv-entry(
  title: [计算机科学学士],
  society: [加利福尼亚大学洛杉矶分校],
  date: [2014 - 2018],
  location: [美国],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [论文: 探索使用机器学习算法预测股票价格: 回归与时间序列模型的比较研究],
    [课程: 数据库系统 #h-bar() 计算机网络 #h-bar() 软件工程 #h-bar() 人工智能],
  ),
)
