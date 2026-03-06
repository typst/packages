#import "@preview/modern-sustech-thesis:0.2.0": *

#let (
  // 帮手组件
  figures,
  // 页面组件
  cover,
  title-page,
  abstract,
  declarations,
  outline,
  conclusion,
  // 样式组件
  generic-style,
  front-matter-paginated-style,
  body-matter-style,
  appendix-style,
  attachment-style,
) = setup(
  // 学士论文，为默认值所以不必写
  // degree: "bachelor",
  // 这篇论文用中文和大陆变体写，为默认值，所以不设置 lang 或 region
  // lang: "en",
  title: (
    zh: [狂人日记],
    en: [Diary of a Madman],
  ),
  // 有就写副标题
  subtitle: (
    zh: [救救孩子],
    en: [Save the Children],
  ),
  keywords: (
    // 中英文版顺序要一致
    zh: ("仁义道德", "吃人", "白话文"),
    en: ("Benevolence and Morality", "Cannibalism", "Baihua"),
  ),
  // 作者姓名
  candidate: (
    zh: "鲁迅",
    // 此处按南科大硕士标准，用中文姓名顺序
    en: "Lu Xun",
  ),
  // 作者学号
  student-number: "228547",
  // 指导教师，含职称
  supervisor: (
    zh: "周树人教授",
    en: "Professor Zhou Shuren",
  ),
  // 院系
  department: (
    zh: "文学系",
    en: "Department of Literature",
  ),
  // 专业
  discipline: (
    zh: "创意写作",
    en: "Creative Writing",
  ),
  // 打印日期，同成文日期
  print-date: datetime(year: 2026, month: 01, day: 01),
  // 中国图书馆分类编码
  clc: "I242.7",
  // 通用十进制图书分类编码
  udc: "821.581-32:316.344.42",
  // 南科大论文号
  thesis-number: "8217365",
  // 我们准备打印这篇论文，否则留作默认的 "digital"
  distribution: "printed",
  // 因为是打印模式，所以模版自动生成了装订线
  // 如果不想要，用下面这个选项
  // binding-guide: false,
)

// 如果要其他全局可用的变量，最好也在这里定义
#let my-lil-var = [Öoo]

// 还有函数
#let my-lil-func(a) = (a,) * 3

