// 深圳大学幻灯片封面 (中文)
#import "@preview/modern-szu-slides:0.1.0": title-slide

#let thesis-title = [深圳大学学位论文题目]
#let thesis-subtitle = [硕士学位论文答辩报告]
#let college-name = [计算机与软件学院]
#let major-name = [计算机科学与技术]
#let candidate-name = [答辩人姓名]
#let advisor-names = [指导教师 教授]

#let cover-section = title-slide(
  title: thesis-title,
  subtitle: thesis-subtitle,
  author: candidate-name,
  advisor: advisor-names,
  college: college-name,
  major: major-name,
  lang: "zh",
)
