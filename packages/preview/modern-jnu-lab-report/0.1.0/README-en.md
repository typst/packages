**English** | [简体中文](./README.md) |

# JiNan University lab typst template

## Quick Start

```typst
#import "lib.typ": jnu-report

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

Compile:

```sh
typst compile main.typ
```

## Parameters

| Parameter | Meaning |
| --- | --- |
| `course` | Course name |
| `grade` | Grade |
| `lab-name` | Experiment name |
| `instructor` | Instructor |
| `lab-id` | Experiment number |
| `lab-type` | Experiment type |
| `site` | Location |
| `author` | Student name |
| `student-id` | Student ID |
| `college` | College |
| `department` | Department |
| `major` | Major |

The experiment-time row is structured as `__年__月__日__午 ～ __月__日__午 温度__℃ 湿度__`.

| Parameter | Meaning |
| --- | --- |
| `year` / `month` / `day` / `ampm` | Start year / month / day / half-day (use `上` for morning, `下` for afternoon) |
| `end-month` / `end-day` / `end-ampm` | End month / day / half-day |
| `temperature` | Temperature (the `℃` unit is pre-printed on the form) |
| `humidity` | Humidity |

## Additional Configuration

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `"暨南大学本科实验报告专用纸"` | Cover title |
| `appendix-title` | `"暨南大学本科实验报告专用纸"` | Appendix letterhead main title |
| `appendix-suffix` | `"(附页)"` | Letterhead suffix |
| `show-appendix-header` | `true` | Show the appendix letterhead |
| `show-header-rule` | `true` | Draw the rule under the letterhead title |
