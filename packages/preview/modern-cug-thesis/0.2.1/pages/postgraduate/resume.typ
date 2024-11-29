#import "../../utils/style.typ": 字号, 字体

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
  // 默认参数
  info = (
    // 1. 基本情况信息
    name:"张三", 
    gender: "男", 
    nation: "汉族", 
    birthday: "1996-09-01",
    native-place: "河南省鹤壁市",
    bachelor-time: "2018.09——2022.06",
    bachelor-school: "河南农业大学", 
    bachelor-type: "理学学士",
    master-time: "2022.09——2025.06",
    master-school: "中国地质大学（武汉）",
    master-type: "工程硕士",
    doctor-time: "",
    doctor-school: "",
    doctor-type: "",
    // 2. 学术论文信息
    thesises: (
      "X. X研究[J]. X学报，2004（1）：53-55.",
      "X. X分析[J]. X技术，2005（5）：6-7.",
    ),
    // 3. 获奖、专利情况信息
    awards: (
      "X. X. 江苏省科技进步奖三等奖.排名第2；",
      "2022年度优秀毕业生",
      "2025年度优秀研究生",
    ),
    // 4. 研究项目信息
    projects: (
      "X项目, 国家自然基金,项目编号：X,参加人员；",
    )
  )

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

    #h(4em);#info.bachelor-time;#h(2em);#info.bachelor-school;#info.bachelor-type;

    #h(4em);#info.master-time;#h(2em);#info.master-school;#info.master-type;
    
    #if (info.doctor-time != "") {
      h(4em);info.doctor-time;h(2em);info.doctor-school;info.doctor-type;
    }
  ]
  // 2. 学术论文
  text(font: 字体.黑体, size: 字号.小四)[二、学术论文]
  par(leading: 1.0em, first-line-indent: 2em, hanging-indent: 2em)[
    #info.thesises.join("\n");
  ]
  // 3. 获奖、专利情况
  text(font: 字体.黑体, size: 字号.小四)[三、获奖、专利情况]
  par(leading: 1.0em, first-line-indent: 2em, hanging-indent: 2em)[
    #info.awards.join("\n");
  ]
  // 4. 研究项目
  text(font: 字体.黑体, size: 字号.小四)[四、研究项目]
  par(leading: 1.0em, first-line-indent: 2em, hanging-indent: 2em)[
    #info.projects.join("\n");
  ]
  pagebreak(weak: true, to: if twoside { "odd" })
}

#postgraduate-resume()