#let 摘要 = [
  
  本项目是清华大学研究生学位论文Typst模板，旨在规定论文各部分内容格式与样式，详细介绍模板的使用和制作方法，帮助研究生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。请注意，这是一个非官方、非专业的模板，请在使用前充分确认该模板符合院系要求，并咨询院系负责老师。由于作者是生医药专业学生，该模板优先满足本专业的需求，其他功能随缘更新，敬请理解。

  除常见自动排版功能外，本模板的特色功能包括通过`#tupian()`函数便捷地添加图片、图注，并防止跨页；以及通过`#biaoge()`函数便捷地添加三线表并在跨页时自动生成续表题。
  
  如果有进阶的排版需求，请了解基于LaTeX的ThuThesis模板，这是一个非常成熟的模板，全面支持最新的本科、研究生、博士后论文/报告格式，获研究生院官方推荐。

  本项目受PKUTHSS-Typst和ThuThesis启发，并在PKUTHSS-Typst的基础上修改而来，格式大量参考了ThuWordThesis模板。项目使用了以下Typst包：`tablem`、`cuti`、`a2c-nums`。感谢开发者们的贡献。

  #linebreak()

  - 清华大学研究生学位论文写作指南2023版: https://info2021.tsinghua.edu.cn/f/info/xxfb_fg/xnzx/template/detail?xxid=fa880bdf60102a29fbe3c31f36b76c7e
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
  = 尚不完善的功能

  + 章节始终从右页开始的功能会导致页码bug
  + “学位论文指导小组、公开评阅人和答辩委员会名单”页面的更多形式
  + 参考文献目前只能纯英文，不支持中英文混合
  + 公式样式尚未调整
  + 代码样式尚未调整
  + 系统性与创新性页面
  + 盲审封面
  + 待补充...
  
  以上内容随缘更新
  
  = 更新日志
  
  == 版本v0.1.0
  
  - Tsinghua Thesis Typst Template 上线了

  == 版本v0.2.0

  - 优化了文件结构，以符合Typst Universe的提交要求
  - 将字体替换为开源字体
]

#let 致谢 = [
  我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。

  我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。我感谢天地，我感谢父母，我是罪人，我危害人间，我辜负苍生，我愿抛开一切消除我名利权力，舍弃金钱物质，归于真我。
]



#let 简历和成果 = [
  == 个人简历

  20XX年XX月XX日出生于XX省XX市。
  
  20XX年XX月考入XX大学XX系XX专业，20XX年XX月本科毕业并获得XX学士学位。
  
  20XX年XX月免试进入清华大学XX系攻读XXXX至今。
  
  
  == 在学期间完成的相关学术成果
  
  === 学术论文:
  
  无。
  
  === 专利:
  
  无。
]



#let 指导教师评语 = [
  将指导教师（小组）的评语内容誊录于此，指导教师（指导小组成员）无需签名。指导教师评语的内容与学位（毕业）审批材料一致。保持内容一致是论文作者的学术责任，因内容不一致产生的后果由论文作者承担。
]



#let 答辩委员会决议书 = [
  将答辩委员会决议书内容誊录于此，答辩委员会主席、委员和秘书无需签名。答辩委员会决议书内容与学位（毕业）审批材料一致。保持内容一致是论文作者的学术责任，因内容不一致产生的后果由论文作者承担。
]









// ==================================
//
//          以下内容不要编辑
//
// ==================================

#let other_contents = (
  摘要: 摘要, 
  摘要_英:摘要_英, 
  符号和缩略语:符号和缩略语, 
  附录:附录, 
  致谢:致谢, 
  简历和成果:简历和成果, 
  指导教师评语:指导教师评语, 
  答辩委员会决议书:答辩委员会决议书
)

#import "@preview/uo-tsinghua-thesis:0.2.0": *

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
  |#text(red,font: 字体.黑体)[【`#biaoge(...)` 使用方法】]|<|
  | -------------- | -------------- |
  | caption:       | [表题]          |
  | body:          | [Markdown表格]  | 
  | label:         | \<标签\>，可不填 |
  | 合并单元格      | `^`或`<`        |
]
#let biaoge(caption:text(red,font: 字体.黑体)[【未命名表格】], body: biaogeHint, label: none) = {
  align(center)[
    #show figure: set block(breakable: true)
    #figure(
      caption: caption,
      three-line-table(caption, body),
    ) #label
  ]
}

#let tupian(body: "images/tupianhint.png", width:70%, caption: text(red,font: 字体.黑体)[【未命名图片】], legend: none, label: none)={  
  align(center)[
    #block(breakable: false)[
      #figure(
      image(body, width: width),
      caption: caption
      ) #label
      #if legend != none{
        v(-12pt)
        set align(center)
        text(10.5pt)[#legend]
        v(12pt)
      }
    ]
  ]
}