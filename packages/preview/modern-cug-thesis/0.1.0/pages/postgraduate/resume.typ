#import "../../utils/style.typ": 字号, 字体
#import "../../utils/indent.typ": indent

// 作者简历
#let postgraduate-resume(
  anonymous: false,
  twoside: false,
  info: (:),
) = {
  // 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 个人简介
  v(字号.五号 * 4)
  align(
    center,
    text(
      font: 字体.黑体,
      size: 字号.三号,
      weight: "bold",
      "作者简历",
    ),
  )
  v(字号.五号 * 3.0)

  set text(font: 字体.宋体, size: 字号.小四, top-edge: (20pt-1.0em)*0.7, bottom-edge: -(20pt-1.0em)*0.3)
  // 1. 基本情况
  text(font: 字体.黑体, size: 字号.小四)[一、基本情况]
  par(leading: 1.0em, first-line-indent: 2em)[
    姓名：#info.name;#h(2em);性别：#info.gender;#h(2em);民族：#info.nation;#h(2em);出生日期：#info.birthday;#h(2em);籍贯: #info.native-place;

    #h(4em);#info.bachelor-time;#h(2em);#info.bachelor-school;理学学士

    #h(4em);#info.master-time;#h(2em);#info.master-school;工学硕士
  ]
  // 2. 学术论文
  text(font: 字体.黑体, size: 字号.小四)[二、学术论文]
  par(leading: 1.0em, first-line-indent: 2em)[
    #info.thesis-reference-1;

    #info.thesis-reference-2;
  ]
  // 3. 获奖、专利情况
  text(font: 字体.黑体, size: 字号.小四)[三、获奖、专利情况]
  par(leading: 1.0em, first-line-indent: 2em)[
    #info.award-1;
  ]
  // 4. 研究项目
  text(font: 字体.黑体, size: 字号.小四)[四、研究项目]
  par(leading: 1.0em, first-line-indent: 2em)[
    #info.project-1;
  ]
  pagebreak(weak: true, to: if twoside { "odd" })
}

#postgraduate-resume(
  info: (
    // 1. 基本情况信息
    name:"张三", 
    gender: "男", 
    nation: "汉族", 
    birthday: "1996-09-01",
    native-place: "河南省鹤壁市",
    bachelor-time: "2018.09——2022.06",
    bachelor-school: "河南农业大学",
    master-time: "2022.09——2025.06",
    master-school: "中国地质大学",
    doctor-time: "2020-09-01",
    doctor-school: "广东工业大学",
    // 2. 学术论文信息
    thesis-reference-1: "X. X研究[J]. X学报，2004（1）：53-55.",
    thesis-reference-2: "X. X分析[J]. X技术，2005（5）：6-7.",
    // 3. 获奖、专利情况信息
    award-1: "X. X. 江苏省科技进步奖三等奖.排名第2；",
    // 4. 研究项目信息
    project-1: "X项目, 国家自然基金,项目编号：X,参加人员；",
  )
)