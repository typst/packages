#import "@preview/uestc-thesis:1.0.0": thesis-figure, thesis-table


= 问题分析

== 表格使用示例
#thesis-table(
  title: [表格标题],
  header: (
    [维度],
    [指标],
    [说明],
  ),
  //设置对齐方式, 默认left（水平居左） +horizon(垂直居中)
  alignment: left + horizon,
  // 设置列宽，以相对比例显示，1fr表示等分
  columns: (1fr, 1fr, 1fr),
  body: (
    [进度],
    [前置时间],
    [从需求确认到发布的平均周期],
    [质量],
    [缺陷密度],
    [单位功能点缺陷数],
    [效率],
    [部署频率],
    [单位时间内成功部署次数],
  ),
  note: [注：这是表格注释],
)

在方法论层面#footnote[这是第二个脚注，数据来源于xxx]，进度与风险管理需在不确定条件下进行动态评估与校准，例如关键路径（CPM）、计划评审技术（PERT）与关键链（CCPM）的对比与融合应用。面向多项目情境，还需引入资源受限下的统筹策略与缓冲管理，以提升整体吞吐与稳定性 。