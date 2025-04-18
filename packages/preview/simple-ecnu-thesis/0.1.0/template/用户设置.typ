// true 表示开启盲审， false 表示关闭
#let 盲审模式 = false
// true 表示所有的章节从奇数页开始，false 表示关闭
#let 双页模式 = false
//
#let 页眉标题 = "华东师范大学专业硕士学位论文"

// 封面
#let 毕业年份 = "2025"
#let 学校代码 = "10269"
#let 学校 = "华东师范大学"
#let 学校-英文 = "East China Normal University"
#let 学号 = "512xxxxxxxx"

// 中文封面，分段标题使用 \n 分段
#let 论文类型 = "硕士学位论文"
#let 论文类型-英文 = "Master's Degree Thesis (Professional)"
#let 论文题目 = "一份基于 Typst 的 简易论文模板"
#let 论文题目-分段 = "一份基于 Typst 的 \n简易论文模板"
#let 作者 = "张三"
#let 院系 = "软件工程学院"
#let 专业 = "软件工程"
#let 领域 = "人工智能"
#let 指导教师 = "李四 教授"
#let 日期 = "2025 年 3 月"


// 英文封面
#let 论文题目-英文 = "A Simple Thesis Template Based Typst"
#let 论文题目-分段-英文 = "A Simple Thesis \nTemplate Based Typst"
#let 作者-英文 = "San Zhang"
#let 院系-英文 = "Software Engineering Institute"
#let 专业-英文 = "Software Engineering"
#let 领域-英文 = "Artificial Intelligence"
#let 指导教师-英文 = "Prof. Si Li"
#let 日期-英文 = "Mar, 2025"

// 盲审设置
#let 盲审遮挡 = "██████"
// 可以自行设置盲审模式的为
#if 盲审模式 {
  作者 = "██████"
  指导教师 = "██████"
  学号 = "██████"
  作者-英文 = "██████"
  指导教师-英文 = "██████"
}
