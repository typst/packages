#import "@preview/modern-hust-cse-report:0.1.0": report, fig, tbl

#show:report.with(
  name: "",
  class: "",
  id: "U202",
  contact: "(电子邮件)",
  date: "", // 可以使用 datetime.today() 或空字符串，为空则不显示
  requirements: false, // 设置为 true 显示课程设计报告要求页
  head: "", // 页眉内容
  title: [本科：《》实践报告],
  scoretable: [], // 评分表格内容
  chinese-heading-number: true, // 设置为 false 使用阿拉伯数字
  title-font: "SimSun", // 标题页字体，可选 "SimSun"(宋体) 或 "FangSong"(仿宋)
  signature: none, // 签名图片路径，如 "signature.png"，留空则不显示签名
)

// 使用示例：
// = 第一章
// == 第一节
//
// #fig("image.png", caption: "示例图片", width: 80%)
// 这将显示为：图1-1-1:示例图片
//
// #tbl(
//   table(
//     columns: 3,
//     [列1], [列2], [列3],
//     [数据1], [数据2], [数据3],
//   ),
//   caption: "示例表格"
// )
// 这将显示为：表1-1-1:示例表格
//
// $ E = m c^2 $
// 这将自动显示为：E = m c^2  (1-1-1)
