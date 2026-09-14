# BUPT-Report-Typst
A lab report template designed for BUPT students! (Originally created for DSP lab reports)

The cover page has an elegant BUPT logo and information section same with the Word Version.

> [!IMPORTANT]
> Although the template closely follows the university's Word template format, minor discrepancies may exist...

## Basic Font Formatting
- Level-1 heading: SimHei + Times New Roman, 14pt, bold
- Level-2 heading: SimHei + Times New Roman, 12pt, bold
- Main text: SimSun + Times New Roman, 12pt, 1.2 line spacing, 2-character indentation, justified alignment
- Captions: FangSong + Times New Roman, 10.5pt

## My Additions (mainly to match docx formatting)
- Level-2 heading indentation
- Code block indentation
- Title line spacing adjustments
- Auto indentation

Newest Version: `0.1.1`

## Example Usage
```typst
#import "@preview/simple-bupt-report:0.1.1": experiment-report
#show: doc => experiment-report(
  title: "《信号处理实验》实验报告",
  semester: "2024-2025学年第二学期",
  class: "2023211113",
  name: "张三",
  student-id: "2021123456",
  date: "2024年4月14日",
  doc
)

= Main Title

== Section1
...
== Section2
...
```

>（PS: If you encounter any formatting issues, feel free to open an issue）
  
