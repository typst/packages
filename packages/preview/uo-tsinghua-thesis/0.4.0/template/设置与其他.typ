// 定义字体组合
#let Win版字体 =  ( 
  仿宋: ("Times New Roman",  "FangSong", "Noto Serif CJK SC"),
  宋体: ("Times New Roman",  "SimSun",   "Noto Serif CJK SC"),
  黑体: ("Arial",            "SimHei",   "Noto Sans CJK SC"),
  楷体: ("Times New Roman",  "KaiTi",    "Noto Serif CJK SC"),
  代码: ("DejaVu Sans Mono", "Noto Sans CJK SC"),
) // 不同版本的字体在调用时的名称可能不同，可能需要自行查证并修改。

#let 开源字体 = (
  仿宋: ("Tex Gyre Termes", "FandolFang R"),
  宋体: ("Tex Gyre Termes", "FandolSong"),
  黑体: ("Tex Gyre Heros","FandolHei"),
  楷体: ("Tex Gyre Termes", "FandolKai"),
  代码: ("DejaVu Sans Mono", "Noto Sans CJK SC"),
)



// ==================================
//
//         以下内容为基本信息配置
//
// ==================================
//
// 面向初学者：
//
//   settings的每一个子项只需要修改冒号后的内容
//   并且不要忘记在每一项的结尾添加英文逗号
//
//   使用引号包裹的"字符串"，是纯文本，不支持添加加粗、强调等格式
//   使用方括号包裹的是[内容]，支持格式（加粗/强调等）
//   使用圆括号包裹的是(数组)，含有多个成员，成员之间用英文逗号分隔
//   true和false是逻辑值

#let settings = (

字体: Win版字体, // 填写上方的"Win版字体"或"开源字体"。最佳选择为Win版，但字体文件需自行获取并上传到Web APP目录（如果是本地使用，请安装到本机）。

文章类型: "Thesis", //"Thesis"或"Dissertation"

作者名: "作者名",

作者_英: "Author Name",

论文题目:[
  清华大学研究生学位论文
  
  Typst模板 v0.4.0
], // 换行需空行

论文题目_书脊:"清华大学研究生学位论文 Typst 模板", //仅用于书脊页，内容同上，但去除换行，中西文之间添加空格，括号用半角

论文题目_英: "T4: Tsinghua Thesis Typst Template",

副标题: "申请清华大学医学博士学位论文",

院系: "基础医学系",

英文学位名: "Doctor of Medicine",

专业: "基础医学",

专业_英: "Basic Medical Sciences",

导师: "导师名 教授",

导师_英: "Professor Sprvsr Name",

副导师: "副导名 教授", //没有填none

副导师_英: "Professor AssocSprvsr Name",

// 日期: datetime(year: 2028, month: 12, day: 1), //默认为当前日期

关键词: ("Typst", "模板"),

关键词_英: ("Typst", "Template", [_Italic Text_]),

指导小组名单: /*三个为一组，姓名-职称-单位*/
("某某某", "教授", "清华大学",
"某    某", "副教授", "清华大学",
"某某某", "助理教授", "清华大学"),

公开评阅人名单:
("某某某", "教授", "清华大学",
"某某某", "副教授", "XXXX大学",
"某某某", "研究员", "中国XXXX科学院XXXXXX研究所"),

答辩委员会名单:/*注意，所有委员只有第一个需要写明，其余留空字符串*/
("主席", "某某某", "教授", "清华大学",
"委员", "某某某", "教授", "清华大学",
"", "某某某", "研究员", "中国XXXX科学院\nXXXXXX研究所",
"", "某某某", "教授", "XXXX大学",
"", "某某某", "副教授", "XXXX大学",
"秘书", "某某某", "助理研究员", "清华大学"),

参考文献格式: "cell", // https://typst.app/docs/reference/model/bibliography/#parameters-style

目录深度: 3,


插图清单: true,

附表清单: true,

)



// ==================================
//
//       以下是论文正文以外的其他内容
//
// ==================================

#let 授权 = [

  本人完全了解清华大学有关保留、使用学位论文的规定，即：

  清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）根据《中华人民共和国学位法》及上级教育主管部门具体要求，向国家图书馆报送相应的学位论文。
  
  本人保证遵守上述规定。
  
]

#let 摘要 = [
  
  本项目是清华大学研究生学位论文*Typst模板*，旨在规定论文各部分内容格式与样式，详细介绍模板的使用和制作方法，帮助研究生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。请注意，这是一个非官方、非专业的模板，请在使用前充分确认该模板符合院系要求，并咨询院系负责老师。由于作者是生医药专业学生，该模板优先满足本专业的需求，其他功能随缘更新，敬请理解。

  除常见自动排版功能外，本模板的特色功能包括通过`#tupian()`函数便捷地添加图片、图注，并防止跨页；以及通过`#biaoge()`函数便捷地添加三线表并在跨页时自动生成续表题。
  
  如果有进阶的排版需求，请了解基于LaTeX的ThuThesis模板，这是一个非常成熟的模板，全面支持最新的本科、研究生、博士后论文/报告格式，获研究生院官方推荐。

  本项目受PKUTHSS-Typst和ThuThesis启发，并在PKUTHSS-Typst的基础上修改而来，格式大量参考了ThuWordThesis模板。项目使用了以下Typst包：`tablem`、`cuti`、`a2c-nums`。感谢开发者们的贡献。

  #linebreak()

  - 清华大学研究生学位论文写作指南: https://info2021.tsinghua.edu.cn/f/info/xxfb_fg/xnzx/template/detail?xxid=fa880bdf60102a29fbe3c31f36b76c7e
  - PKUTHSS-Typst: https://github.com/pku-typst/pkuthss-typst
  - ThuWordThesis: https://github.com/fatalerror-i/ThuWordThesis
  - ThuThesis(LaTeX): https://github.com/pku-typst/pkuthss-typst
  
]



#let 摘要_英 = [
  
    This article creates a Tsinghua University graduate dissertation Typst template, which stipulates formats and styles of each section and details usage and creation of template, with the purpose of supporting graduate students writing dissertation, reducing non-standardization and additional workload in editing thesis format.
    
]



#let 符号和缩略语 = [
  
  / _T4_: 清华大学学位论文typst模板（Tsinghua Thesis Typst Template）
  / pt: 磅值、点数（point）
  / $planck.reduce$ : 约化普朗克常数
  / CRISPR/Cas9: 成簇的带有规律间隔序列的短回文重复序列（Clustered Regularly Interspaced Short Palindromic Repeats）和CRISPR相关蛋白9（CRISPR-associated protein 9）

]



#let 附录 = [

= 尚不完善的功能 // 附录A

  - 右页起章功能有时会导致正文页码开始于第一章前的空白页
  - “学位论文指导小组、公开评阅人和答辩委员会名单”页面缺少更多形式
  - 参考文献目前只能纯英文，不支持中英文混合
  - 参考文献缩进量暂无法调整
  - 公式样式尚未调整
  - 代码样式尚未调整
  - 缺少“系统性与创新性“页面
  - 缺少盲审封面
  - `#tupian()`的caption缺少引用功能
  - 待补充...
  
  以上内容随缘更新


= 更新日志 // 附录 B

  == 版本v0.1.0 
  
  - Tsinghua Thesis Typst Template 上线了 

  == 版本v0.2.0

  - 优化了文件结构，以符合Typst Universe的提交要求
  - 将字体替换为开源字体

  == 版本v0.2.1
  - 优化了字体配置提示
  - 设置了个人成果页面的列表样式

  == 版本v0.3.0
  - 新增了博资考模板
  - 修复了封面日期数字十一月/十二月显示有误的bug
  - 改进了图片legend的对齐方式

  == 版本v0.3.1
  - 添加了统一设置特殊名词格式设置的教程
  - 修复了博资考模板正文前页码的bug
  - 修复了正文以外中文*伪粗体*无法显示的bug

  == 版本v0.4.0
  - 添加预览了不正确的文件时的提示
  - 再次优化了字体配置方法
  - 优化了文件结构
  - 为正文格式添加了两端对齐
  - 将授权和声明页内容移至`设置与其他.typ`以便调整，并将内容更新至2025年3月版本
  - 更改了引用节的显示格式（节1.1.1 #sym.arrow 第1.1.1节）
  
]


#let 致谢 = [
  
  致谢正文
  
]

#let 声明 = [
  本人郑重声明：所呈交的学位论文，是本人在导师指导下，独立进行研究工作所取得的成果，不包含涉及国家秘密的内容。尽我所知，除文中已经注明引用的内容外，本学位论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
]



#let 简历和成果 = [
  == 个人简历

  20XX年XX月XX日出生于XX省XX市。
  
  20XX年XX月考入XX大学XX系XX专业，20XX年XX月本科毕业并获得XX学士学位。
  
  20XX年XX月免试进入清华大学XX系攻读XXXX至今。
  
  
  == 在学期间完成的相关学术成果
  
  === 学术论文:

  9. 论文9
  10. 论文10
  
  === 专利:
  + 专利1
  + 专利2
  
]



#let 指导教师评语 = [
  将指导教师（小组）的评语内容誊录于此，指导教师（指导小组成员）无需签名。指导教师评语的内容与学位（毕业）审批材料一致。保持内容一致是论文作者的学术责任，因内容不一致产生的后果由论文作者承担。
]



#let 答辩委员会决议书 = [
  将答辩委员会决议书内容誊录于此，答辩委员会主席、委员和秘书无需签名。答辩委员会决议书内容与学位（毕业）审批材料一致。保持内容一致是论文作者的学术责任，因内容不一致产生的后果由论文作者承担。
]



















// ==================================
//
//           以下内容不要编辑
//
// ==================================

#let other_contents = (
  授权:授权,
  摘要: 摘要, 
  摘要_英:摘要_英, 
  符号和缩略语:符号和缩略语, 
  附录:附录, 
  致谢:致谢, 
  声明:声明,
  简历和成果:简历和成果, 
  指导教师评语:指导教师评语, 
  答辩委员会决议书:答辩委员会决议书,
)

#import "@preview/uo-tsinghua-thesis:0.4.0": *

// tablem包: 允许使用类markdown语法绘制表格
#import "@preview/tablem:0.2.0": tablem

// 可以自动显示续表题的三线表
#let three-line-table = tablem.with(
  render: (caption, columns: auto, headline,..cells) => {
    [
      #let firstHeader = state("fh",true)//标记是否是第一个表头的状态
      #table(
        columns: columns,
        column-gutter: 1.5em,
        inset: (
          x: 1em,
          y: 0.6em,
        ),
        stroke: none,
        align: center + horizon,
        table.hline(y: 1, stroke: 1.5pt),
        table.hline(y: 2, stroke: 1pt),
        table.header(
          // 自动“续表”的实现方式：利用表格的header跨页会重复显示的特性，不显示原有figure默认的caption，而是手动把它放到表格的header中表头的上一行（合并一整行），再根据是否首次显示判定是“表”还是“续表”
          table.cell(colspan: columns,[
            #set text(11pt)
            #context{
              if firstHeader.get(){
                [表]
                firstHeader.update(false)
              }else{
                [续表]
              }
              let loc = query(selector(figure.where(kind:table)).before(here())).last().location()
              chinesenumbering(chaptercounter.at(loc).first(),
              counter(figure.where(kind: table)).at(loc).first()) //手动生成表的编号
            }
            ~~
            #caption //表题本体
            #v(3pt)
          ]),
          ..headline.children //表头
        ),
        ..cells, //表格的其余部分
        table.hline(stroke: 1.5pt),
      )
      #firstHeader.update(true)
    ]
  }
)

// biaoge: 可以生成带有标签和表题的三线表
#let biaogeHint = [
  |#text(red,font: settings.字体.黑体)[【`#biaoge(...)` 使用方法】]|<|
  | -------------- | -------------- |
  | caption:       | [表题]          |
  | body:          | [Markdown表格]  | 
  | label:         | \<标签\>，可不填 |
  | 合并单元格      | `^`或`<`        |
]
#let biaoge(caption:text(red,font: settings.字体.黑体)[【未命名表格】], body: biaogeHint, label: none) = {
  align(center)[
    #show figure: set block(breakable: true)
    #figure(
      caption: caption,
      three-line-table(caption, body),
    ) #label
  ]
}

#let tupian(body: "images/tupianhint.png", width:70%, caption: text(red,font: settings.字体.黑体)[【未命名图片】], legend: none, label: none)={  
  align(center)[
    #block(breakable: false)[
      #figure(
      image(body, width: width),
      caption: caption
      ) #label
      #if legend != none{
        v(-12pt)
        set align(left)
        set par(justify: true)
        text(10.5pt)[#legend]
        v(12pt)
      }
    ]
  ]
}


#[
  #set align(center+horizon)
  #set text(size: 30pt, font: "Noto Sans CJK SC",fill: white)
  #set page(fill: eastern)
  
  您现在正在预览：
  
  "设置与其他.typ"

  \

  请预览"正文.typ"

]