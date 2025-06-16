#import "@preview/cheda-seu-thesis:0.3.4": bachelor-mid-term-conf

// 注意：不是所有院系都要求填写此中期检查表。部分学院只要求提交在线表格，不需要提交此附件。

#let completed-work = [
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)

  摸鱼，摸鱼，摸鱼。
]

#let next-steps = [
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)

  摸鱼，摸鱼，摸鱼。
]

#let issues-and-solution = [
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)

  鱼不够摸。
]

#let weekly-meetings = [
  #set par(first-line-indent: (amount: 2em, all: true), justify: true)
  
  每天见面24小时，每周见面7天。
]

#bachelor-mid-term-conf(
  student-id: "00121001",
  name: "王东南",
  school: "示例学院",
  major: "示例专业",
  title: "新兴排版方式下的摸鱼科学优化研究",
  progress: "进度条加载中",
  completed-work: completed-work,
  next-steps: next-steps,
  issues-and-solution: issues-and-solution,
  weekly-meetings: weekly-meetings,
  guidance-quality: 1,
)