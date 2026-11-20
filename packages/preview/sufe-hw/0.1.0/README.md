# sufe-hw

上海财经大学课程作业模板。提供课程抬头、姓名学号信息栏和页脚页码，并预置 CeTZ、Physica、Codly。

需要 Typst 0.15.0 或更高版本。

## 使用

命令行创建项目：

```sh
typst init @preview/sufe-hw:0.1.0 my-homework
cd my-homework
typst compile main.typ
```

也可以在已有文件中导入：

```typ
#import "@preview/sufe-hw:0.1.0": homework

#show: homework.with(
  student-name: "张三",
  student-id: "2024000000",
  course-name: "高等数学",
  course-code: "MATH101",
  course-section: "01",
  assignment-title: "第一次作业",
)

= 第一题

在这里写解答。
```

## 参数

| 参数 | 默认值 |
| --- | --- |
| `student-name` | `"张三"` |
| `student-id` | `"2024000000"` |
| `course-name` | `"课程名称"` |
| `course-code` | `"课程代码"` |
| `course-section` | `"课程序号"` |
| `assignment-date` | 当天日期 |
| `assignment-title` | `"课程作业"` |

## 附带包

模板同时导出下列包，可在正文中直接调用：

```typ
#import "@preview/sufe-hw:0.1.0": cetz, physica, codly

#cetz.canvas({
  import cetz.draw: *
  line((0, 0), (1, 1))
})

$ physica.dv(f, x) $
```

## 字体

正文优先使用 Noto Sans SC，其后依次为 Source Han Sans SC、PingFang SC、Microsoft YaHei。系统缺少列表中的某一款时，Typst 会给出字体警告并继续使用其余可用字体。需要其他字体时，用 `#set text(font: ...)` 覆盖即可。

## 许可证

MIT
