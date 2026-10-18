[English](./README-en.md) | **简体中文** |

# 暨南大学实验报告 Typst 模板

## 快速开始

```typst
#import "@preview/modern-jnu-lab-report:0.1.0": jnu-report

#show: jnu-report.with(
  course: "模拟电子技术实验",
  lab-name: "晶体管共射极单管放大器",
  instructor: "李四",
  author: "张三",
  student-id: "2020101234",
  year: "2026", month: "10", day: "16", ampm: "上",
  end-month: "10", end-day: "16", end-ampm: "下",
)

```

编译：

```sh
typst compile main.typ
```

## 参数

| 参数 | 含义 |
| --- | --- |
| `course` | 课程名称 |
| `grade` | 成绩评定 |
| `lab-name` | 实验项目名称 |
| `instructor` | 指导教师 |
| `lab-id` | 实验项目编号 |
| `lab-type` | 实验项目类型 |
| `site` | 实验地点 |
| `author` | 学生姓名 |
| `student-id` | 学号 |
| `college` | 学院 |
| `department` | 系 |
| `major` | 专业 |

表单结构为 `__年__月__日__午 ～ __月__日__午 温度__℃ 湿度__`。

| 参数 | 含义 |
| --- | --- |
| `year` / `month` / `day` / `ampm` | 起始 年 / 月 / 日 / 午 |
| `end-month` / `end-day` / `end-ampm` | 结束 月 / 日 / 午 |
| `temperature` | 温度（单位 ℃） |
| `humidity` | 湿度 |

## 额外配置

| 参数 | 默认值 | 含义 |
| --- | --- | --- |
| `title` | `"暨南大学本科实验报告专用纸"` | 封面标题 |
| `appendix-title` | `"暨南大学本科实验报告专用纸"` | 附页报头主标题 |
| `appendix-suffix` | `"(附页)"` | 报头后缀 |
| `show-appendix-header` | `true` | 是否显示附页报头 |
| `show-header-rule` | `true` | 报头标题下是否画横线 |
