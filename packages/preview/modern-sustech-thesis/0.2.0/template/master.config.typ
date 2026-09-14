#import "@preview/modern-sustech-thesis:0.2.0": *

#let (
  // 帮手组件
  figures,
  // 页面组件
  cover,
  title-page,
  abstract,
  reviewers-n-committee, // 比学士学位论文多公开评审人和答辩委员会
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
  // 硕士论文
  degree: "master",
  // 学位类型；我们申请的是专业学位，所以设为“professional”
  // 若为学术学位，则留为默认值“academic”
  degree-type: "professional",
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
  // 硕士、博士论文英文标题默认全大写
  // 有符号不能大写时，设置“显示的标题”
  display-title: (
    en: upper[Diary ] + $e$ + upper[ a Madman],
  ),
  keywords: (
    // 中英文版顺序要一致
    zh: ("仁义道德", "吃人", "白话文"),
    en: ("Benevolence and Morality", "Cannibalism", "Baihua"),
  ),
  // 作者姓名
  candidate: (
    zh: "鲁迅",
    // 按南科大标准，用中文姓名顺序
    en: "Lu Xun",
  ),
  // 指导教师，含职称
  supervisor: (
    zh: "周树人教授",
    en: "Professor Zhou Shuren",
  ),
  // 如有，副指导教师，含职称
  associate-supervisor: (
    zh: "郑振铎副教授",
    en: "Assistant Professor Zheng Zhenduo",
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
  // 专业类型
  domain: (
    zh: "文学",
    en: "Literature",
  ),
  // 打印日期，同成文日期；“日”会被忽略
  print-date: datetime(year: 2026, month: 01, day: 01),
  // 答辩日期；“日”会被忽略
  defence-date: datetime(year: 2026, month: 01, day: 06),
  // 公开评审人名单，留空则是全隐名评审
  reviewers: (
    // 可以写字典
    (name: "刘某某", title: "教授", institute: "南方科技大学"),
    // 也可以按顺序写条目
    ("陈某某", "副教授", "某大学"),
  ),
  // 答辩委员会名单，写法类似公开评审人名单
  committee: (
    (position: "主席", name: "赵某某", title: "教授", institute: "南方科技大学"),
    (position: "委员", name: "刘某某", title: "教授", institute: "南方科技大学"),
    ("委员", "杨某某", "研究员", "中国某某某科学院某某研究所"),
    ("秘书", "吴某某", "助理研究员", "南方科技大学"),
  ),
  // 中国图书馆分类编码
  clc: "I242.7",
  // 通用十进制图书分类编码
  udc: "821.581-32:316.344.42",
  // 我们准备打印这篇论文，否则留作默认的 "digital"
  distribution: "printed",
  // 我们默认在生成 PDF 后才填写公开时间
  // 如果要直接生成，在这里填整数
  // 0 是当年/立即公开
  // 中文版里，大于 0 是多少年以后
  // 英文版里，大于 0 是多少月以后
  publication-delay: 3,
)

// 硕士、博士论文较长，不少人喜欢按章分文件写
// 独立符号来源（比如这个文件）就尤其重要
// 否则容易循环引用，导致无限循环

// 定义全局可用的变量
#let my-lil-var = [Öoo]

// 还有函数
#let my-lil-func(a) = (a,) * 3

