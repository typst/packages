// 北京大学学位论文模板
// 使用方法：typst compile main.typ --font-path fonts
//
// 命令行参数：
//   --input blind=true       生成盲审版本
//   --input preview=false    生成打印版（链接不着色）
//   --input alwaysstartodd=false  章节不强制从奇数页开始

#import "@preview/modern-pku-thesis:0.2.2": appendix, conf

#show: conf.with(
  // ========== 基本信息 ==========
  cauthor: "张三",
  eauthor: "San Zhang",
  studentid: "23000xxxxx",
  blindid: "L2023XXXXX",
  cthesisname: "博士研究生学位论文",
  cheader: "北京大学博士学位论文",
  ctitle: "论文中文标题",
  etitle: "English Title of Your Dissertation",
  school: "某个学院",
  cfirstmajor: "某个一级学科",
  cmajor: "某个专业",
  emajor: "Some Major",
  direction: "某个研究方向",
  csupervisor: "李四",
  esupervisor: "Si Li",
  date: (year: 2026, month: 6),
  degree-type: "academic", // "academic" 或 "professional"

  // ========== 中文摘要 ==========
  cabstract: [
    在此处填写中文摘要内容。

    摘要应简明扼要地概述论文的主要内容和研究成果。
  ],
  ckeywords: ("关键词1", "关键词2", "关键词3"),

  // ========== 英文摘要 ==========
  eabstract: [
    Write your English abstract here.

    The abstract should briefly summarize the main content and research findings of your dissertation.
  ],
  ekeywords: ("keyword1", "keyword2", "keyword3"),

  // ========== 致谢 ==========
  acknowledgements: [
    在此处填写致谢内容。
  ],

  // ========== 参考文献 ==========
  bibcontent: read("ref.bib"), // 参考文献文件内容
  bibstyle: "numeric", // 引用风格："numeric" 或 "author-date"
  bibversion: "2015", // GB/T 7714 版本："2015" 或 "2025"
  // override-bib: false, // 自定义引用样式时设为 true

  // ========== 可选参数 ==========
  // first-line-indent: 2em,     // 首行缩进
  // outlinedepth: 3,            // 目录深度
  // blind: false,               // 盲审模式
  // listofimage: true,          // 图片列表
  // listoftable: true,          // 表格列表
  // listofcode: true,           // 代码列表
  // alwaysstartodd: true,       // 章节从奇数页开始
  // cleandeclaration: false,    // 清除声明页页眉页码
  // preview: true,              // 预览模式（链接显示蓝色）
)

// ========== 正文开始 ==========

= 绪论

== 研究背景

在此处撰写研究背景...

== 研究目的与意义

在此处撰写研究目的与意义...

= 相关工作

== 国内外研究现状

在此处撰写文献综述...

= 研究方法

在此处撰写研究方法...

= 实验与结果

在此处撰写实验和结果...

= 总结与展望

在此处撰写总结和展望...

// ========== 附录 ==========
#appendix()

= 附录

在此处添加附录内容...
