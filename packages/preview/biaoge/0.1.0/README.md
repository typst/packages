# 表哥 (biaoge)

Typst 表格工具集——CSV 分组汇总、单元格合并、列拆分，专为中文数据报表场景设计。

## 功能

| 模块 | 函数 | 说明 |
|------|------|------|
| `group-csv` | `summarize` | 按列分组汇总 |
| `group-csv` | `summary-table` | 生成分组汇总表格（带总计行） |
| `group-csv` | `summary-table-style` | 带样式的汇总表格 |
| `group-csv` | `summary-table-style-no-total` | 无总计行的样式汇总表 |
| `group-csv` | `grouped-sum-table` | 二级分组汇总排序表格 |
| `group-csv-tools` | `merge-selected-columns` | 合并选中列 |
| `group-csv-tools` | `split-column-in-rows` | 按分隔符拆分行 |
| `group-csv-tools` | `trim-string` | 去除首尾空格 |
| `merge-cells` | `merge-col` | 提取某列值 |
| `merge-cells` | `merge-table-data` | 纵向合并相同单元格（数据） |
| `merge-cells` | `merge-table-data-value-col` | 纵向合并并汇总数值列 |
| `merge-cells` | `merge-table` | 纵向合并相同单元格（表格） |
| `merge-cells` | `merge-table-value-col` | 纵向合并并汇总（表格） |
| `table-style` | `stroke_light` | 轻量边框样式 |
| `table-style` | `inner_frame` | 内框线样式 |
| `conf` | `conf` | 论文/报告版式（作者网格+摘要） |
| `conf-table` | `group-tables` | 按分组列拆分主表为多个子表 |

## 使用

```typ
#import "@preview/biaoge:0.1.0": *

// 分组汇总
#let data = (
  ("名称", "类别", "金额"),
  ("苹果", "水果", "120"),
  ("香蕉", "水果", "80"),
  ("牛奶", "饮品", "150"),
)

#summary-table(data, groupIndex: 1, valueIndex: 2, title: "分类汇总")

// 纵向合并相同单元格
#let header = ("类别", "名称", "金额")
#let rows = (
  ("水果", "苹果", "120"),
  ("水果", "香蕉", "80"),
  ("饮品", "牛奶", "150"),
)
#merge-table(header, rows, merge-col-index: 0, table-col-count: 3)
```

## 依赖

无外部依赖，纯 Typst 标准库。

## License

MIT — Copyright (c) 2025 songwupei
