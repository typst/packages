#import "@preview/universal-tongji-thesis:0.1.0": documentclass, indent, no-indent, word-count-cjk, total-words, bilingual-figure

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  appendix,
  // 页面函数
  fonts-display-page,
  cover,
  decl-page,
  abstract,
  abstract-en,
  bilingual-bibliography,
  outline-page,
  list-of-figures,
  list-of-tables,
  notation,
  acknowledgement,
  resume,
  spine,
  cover-statement,
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor", 文档类型，默认为硕士生 master
  doctype: "master",
  twoside: false,
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  degree: "professional",
  anonymous: false, // 盲审模式
  info: (
    title: (cn: "同济大学学位论文中文题目", en: "English Title of the Dissertation for Tongji University"),
    student-id: "2340000",
    author: (cn: "李白", en: "Li Bai"),
    department: (cn: "计算机科学与技术学院", en: "College of Computer Science"),
    categories: (cn: "工学", en: "Engineering"),
    first-level-discipline: (cn: "电子信息", en: "Electonic & Information Engineering"),
    second-level-discipline: (cn: "计算机技术", en: "Computer Technology"),
    research-fields: (cn: "计算机与智能技术", en: "Computer & Intelligent Technology"),
    supervisor: (name: (cn: "张三", en: "Zhang San"), title: (cn: "教授", en: "Prof")),
    associate-supervisor: (name: (cn: "李四", en: "Li Si"), title: (cn: "副教授", en: "Associate Prof")),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)


// 文稿设置。fix-cjk 用于修复中文字符的换行问题。
#show: doc.with(fix-cjk: true)
// 封面页
#cover()
#cover-statement()
#spine()

// 中文摘要
#counter(page).update(1)
// #set page(numbering: "I", header-ascent: 18pt)
#set page(numbering: "I", header-ascent: 6pt)
#abstract(
  keywords: ("随机结构", "马尔可夫过程", "非线性构形状态", "差分方法"),
)[
  在实际工程结构的服役过程中，由于非线性与随机性的耦合作用，工程结构特别是混凝土结构的非线性反应具有不可精确预测的性质。因此，从概率密度演化的角度考察工程结构的非线性性状是准确把握结构非线性性能的必由之路。本文基于随机结构反应概率密度演化的思想对于随机结构分析理论进行了深入的探讨，初步建立了随机结构反应概率密度演化的基本图景。

  结构静力非线性分析是评价结构抗震性能的重要手段。对于具有双线型广义随机本构关系材料的结构，其塑性截面分布状态的演化过程即非线性损伤构形状态转移过程反映了结构内力演化的性质。无记忆特性结构的非线性损伤构形状态转移过程具有马尔可夫性，通过结构的力学分析可建立风险率函数与状态转移速率之间的关系，进一步考虑状态之间的逻辑关系，即可得到概率转移速率矩阵。对于有记忆特性结构及力-状态联合演化过程，可通过引入相应的记忆变量构造向量马尔可夫过程，并采用次序分析方法建立其确定性的概率密度演化方程。关于简单结构的情况进行了解析求解，并据此探讨了结构非线性构形状态演化的若干特征，发现了在实际应用中可能具有重要意义的稳定构形现象。讨论了力-状态的解耦问题。基于非线性构形状态本身的性质以及演化过程的规律，初步研究了可能的简化与近似方法。

  #linebreak()
  #linebreak()

  ......
  #linebreak()
  #linebreak()
  #linebreak()

  最后，关于进一步工作的方向进行了简要的讨论。
]

// 英文摘要
#abstract-en(
  keywords: ("Stochastic Structure", "Markov Process", "Nonlinear Configuration State,", "Difference Method",),
)[
  In practical engineering, the structures usually exhibits strong nonlinearity coupled with randomness of the involved parameters. This makes it almost impossible to exactly predict nonlinear response of the structures, particularly for the concrete structures. To tackle the difficulty, it is necessary to capture the nonlinear performance of the structures in the sense of probability, instead of purely deterministic standpoint. The present thesis is the result of the efforts devoted to developing the probability density evolution method for analysis of nonlinear stochastic structures.

  #linebreak()

  ......
  #linebreak()
  #linebreak()

  In the finality, the problems requiring further studies are discussed.
]

// 目录。preface 中的项目均可以通过可选的 outlined 属性控制是否在目录中显示
#outline-page(outlined: false)

// 前言
#show: preface
// 正文
// 可选的，可以通过 #show: mainmatter.with(figure-clearance: 0pt) 来设置浮动图表的间距或其他参数
#show: mainmatter.with()

// 无序列表的标记符号统一为实心圆点
#set list(marker: [•])

// 字数统计开始
#show: word-count-cjk


= 引言

== 概述

随着现代科学技术的发展和人们生活质量的提高，对于工程结构的性能提出了越来越高的要求。例如：现代精密仪器、大型设备往往对于振动与位移有严格的限制；生命线工程结构，要求在大震和大灾作用下依然保有必要的功能，以为灾后救援与重建提供保障。20世纪中叶以来，尽管社会发展水平有了巨大的提高，然而由于灾害性作用而造成的损失却反而越来越大，这给结构工程学科带来了一系列新的挑战性课题。正是在这样的背景下，基于性能的设计思想开始浮出水面，并在近十年来引起了学者们强烈的兴趣。

#linebreak()

……
#linebreak()
#linebreak()
#linebreak()
#linebreak()


“自然界只有一个，自然现象遵循着不依赖于人类意志的客观规律。然而，数理科学中却有着两套反映这些规律的体系：确定性描述和概率论描述。”@agahiModifiedKullbackLeibler2019 虽然概率论方法的发展引起了科学家和哲学家们关于自然本质的讨论，但是直到本世纪五十年代以前，两套方法在各自独立的领域内都得到了长足的发展。六十年代以来，由于本质非线性行为特别是混沌、分形等现象的发现和深入研究，随机方法的重要性得到了日益深刻的认识 @altaheriDeepLearningTechniques2023b。人们发现，在确定性非线性系统的长期演化行为中会出现与随机行为不能加以区别的现象。而采用概率密度演化描述的方法却能很好地描述其演化密度的长期行为 @alwasitiMotorImageryClassification2020。

== 随机结构分析现状
尼奥
=== 线性随机结构分析
经过三十余年的发展，线性随机结构在静力与动力分析方面的分析方法均已趋于成熟。早期在物理学研究中使用的随机模拟方法于20世纪70年代初期引入随机结构分析以来，已经成为检验各种随机结构分析方法的基本手段。基于随机摄动展开的随机结构静力分析与动力分析也已于20世纪80年代基本完善。

#linebreak()

……
#linebreak()
#linebreak()
#linebreak()
#linebreak()

#pagebreak()
= 测试章节
#pagebreak()
= 结构非线性损伤构形状态的随机演化分析

……

#linebreak()
== 结构非线性构形状态转移过程及其演化方程


……


=== 结构非线性构形状态转移过程分析

……

+ 结构非线性构形状态转移过程
当广义控制截面具有@eqt:2 的广义本构关系时，可定义如下的截面示性数
$
  Phi ( Theta ) = cases(0 \, & "if" & E = E _ ( 0 ), 1 \, & "if" & E = E _ ( 1 ))
$<2>
显然，结构的非线性构形状态就是结构的塑性铰（或发生塑性屈服截面）分布状态。结构的非线性演化过程可以通过可数状态空间中的非线性构形的状态转移过程来研究，如@eqt:2。

#figure(caption: [非线性构形状态转移过程示意图])[
  #image("images/2026-08-09-18-04-17.png")
]

#linebreak()
#linebreak()

……


#pagebreak()

= 结论与展望
== 结论

本文的研究工作初步探讨了随机结构反应的概率密度演化问题，对于具有不同类型本构关系的随机结构反应分析问题提出了两种分析方法，初步建立了随机结构非线性反应的基本图景，给出了具有一定普遍意义的分析方法。

……

== 研究展望
本文的研究虽然取得了初步的成功，但依然任重道远，尚有许多有待进一步深入进行的研究工作，这里择其要者简要讨论如下：

……

#bilingual-bibliography()

// 手动分页
#if twoside {
  pagebreak() + " "
}

#pagebreak(weak: true)



// 致谢
#acknowledgement(
  )[
  逾尺的札记和研究纪录凝聚成这么薄薄的一本，高兴和欣慰之余，不禁感慨系之。记得鲁迅在一篇文章里写道：“人类的奋战前行的历史，正如煤的形成，当时用大量的木材，结果却只是一小块”。倘若这一小块有点意义的话，则是我读书生活的最好纪念，也令我对于即将迈入的新生活更加充满信心。

  回想读书生活，已经整整二十个年头，到同济求学将近六年，攻读博士学位也已四年了。进入同济大学以来，深深醉心于一流学府的大家风范。名师巨擘，各具特点；中西融合，文质相顾。处如此佳境以陶铸自我，实乃人生幸事。
  #linebreak()
  #linebreak()

  ......
  #linebreak()
  #linebreak()
  #linebreak()
]
#resume()
#decl-page()
// #total-words
