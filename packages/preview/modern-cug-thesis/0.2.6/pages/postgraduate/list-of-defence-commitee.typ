#import "../../utils/style.typ": 字号, 字体, show-cn-fakebold
#import "../../utils/justify-text.typ": justify-text


// 答辩委员会名单
#let list-of-defence-commitee(
  anonymous: false,
  twoside: false, 
  info: (:)
) = {
  // 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 默认参数: 姓名, 职务, 单位
  info = (
    // 主席
    chair: (name: "张三", title: "教授", affiliation: "中国地质大学"),
    // 委员
    // members: (),
    member-1: (name: "李四", title: "研究员", affiliation: "中国地质大学"),
    member-2: (name: "王五", title: "副研究员", affiliation: "中国地质大学"),
    member-3: (name: "一二三", title: "副教授", affiliation: "中国地质大学"),
    member-4: (name: "四五六", title: "正高工", affiliation: "中交第二公路勘察设计有限公司"),
    // 秘书
    secretary:(name: "七八九", title: "高级工程师", affiliation: "中国地质大学")
  ) + info
 
  // 辅助方法
  let distr(s, w: auto) = {
    block(
      width: w,
      stack(
        dir: ltr,
        ..s.clusters().map(x => [#x]).intersperse(1fr),
      ),
    )
  }
  let defence-info(
    body, weight: "regular", 
    font: 字体.宋体, size: 字号.三号, 
    align-type: "default", // str(justify), str(default), left, right, center, 
  ) = {
    rect(width: 100%, stroke: none, 
    text(
      font: font, size: size, weight: weight,
      top-edge: 1.2em, bottom-edge: 1.2em,
      {
        if (align-type == "justify") {
            distr(body, w:3em) // name 3em
          } else if (align-type == "default") {
            body
          } else {align(align-type, body)}
      }
    ))
  }
  let defence-title = defence-info.with(size: 字号.二号, weight: "bold", align-type: center)

  show: show-cn-fakebold
  // 正式渲染
  block(height: auto, grid(
    columns: 15.43cm,
    rows: 3.9cm,
    align: center+horizon,
    defence-title("学位论文答辩委员会名单")
  ))

  {
    set align(center)
    block(height: auto, width: 15.43cm, 
    grid(
      columns: (8.5em, 8em, 9em, 16em),
      rows: auto,
      defence-info("主席"), 
      defence-info(info.chair.at("name"), align-type: "justify"), 
      defence-info(info.chair.at("title"), align-type: center),
      defence-info(info.chair.at("affiliation")),

      grid.cell(
        rowspan: 4,
        defence-info("委员", align-type: "default"), 
      ),
      // member-1
      defence-info(info.member-1.at("name"), align-type: "justify"), 
      defence-info(info.member-1.at("title"), align-type: center), 
      defence-info(info.member-1.at("affiliation")),
      // member-2
      defence-info(info.member-2.at("name"), align-type: "justify"), 
      defence-info(info.member-2.at("title"), align-type: center), 
      defence-info(info.member-2.at("affiliation")),
      // member-3
      defence-info(info.member-3.at("name"), align-type: "justify"), 
      defence-info(info.member-3.at("title"), align-type: center), 
      defence-info(info.member-3.at("affiliation")),
      // member-4
      defence-info(info.member-4.at("name"), align-type: "justify"), 
      defence-info(info.member-4.at("title"), align-type: center), 
      defence-info(info.member-4.at("affiliation")),

      defence-info("秘书"), 
      defence-info(info.secretary.at("name"), align-type: "justify"), 
      defence-info(info.secretary.at("title"), align-type: center),
      defence-info(info.secretary.at("affiliation")),
    )
    )
  }
  pagebreak() //换页
  if twoside {
    pagebreak() // 空白页
  }
}

// #set page(margin: 3cm)
// #list-of-defence-commitee()
