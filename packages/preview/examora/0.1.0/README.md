# `examora` - A package to create examination papers

This package provide following controlled parameters in `documentclass` function.:

| Parameter | Description | Default Value |
| :---: | :---: | :---: |
| info.school | Scholl Infomatin | "布鲁斯特大学" |
| info.subject | subject | "高等数学" |
| info.major | major for this exam | "" |
| info.class | class for students | "" |
| info.time | exam time | [] |
| info.date | exam date | datetime.today() |
| info.duration | exam duration | [120 分钟]
| info.columns | columns number for info display | -1 |
| margin | page margin (for double page, also use outside and inside, don't use left and right) | (top: 3cm, bottom: 3cm, outside: 2cm, inside: 4cm) |
| student-info | information for students that should be filled | student-info: ("学院", "专业班级", "姓名", "学号") |
| font | main font family | font: ("Times New Roman", "KaiTi") |
| font-size | main font size | 13pt |
| type | type for exam paper | "" |
| method | exam method | "闭卷" |
| random | whether should shuffle questions | true |
| frame | whether should add frame to each page | true |
| frame-stroke | stroke style for frame | frame-stroke: 0.2pt + black |
| choice-question-breakable | whether can break question and choices into different page for choice questions | true |
| double-page | whether put two pages into one paper | true |
| show-answer | show answer of all questions | false |
| seed | random seed (negative means generate according to exam type) | -1 |
| answer-color | font color for answers | red |
| mono-font | font for raw text | ("Cascadia Code", "LXGW WenKai Mono GB") |
| mono-font-size | font size for raw text | 13pt |
| title-font | font for title | ("Times New Roman", "KaiTi") |
| title-underline | whether add underline for title | true |
| title-font-size | font size for title | 1.5em |

To see how to use in details, please refer to the `template/exam.typ` file.