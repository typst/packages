# BUPT-Report-Typst
这里是为北邮同学们打造的实验报告模板

首页自带北邮LOGO和个人信息栏

字体基本格式
- 一级标题，黑体+Times New Roman，四号，加粗
- 二级标题，黑体+Times New Roman，小四号，加粗
- 正文，宋体+Times New Roman，小四号，多倍行距1.2，首行缩进2字符，两端对齐等
- 题注仿宋+Times New Roman，小五号

我的补充(主要是对照docx格式补充的)
- 二级标题的缩进
- 代码的缩进
- 标题行间距相关情况

使用方式
```typst
#show: doc => experiment-report(
  title: "《信号处理实验》实验报告",
  semester: "2024-2025学年第二学期",
  class: "2023211113",
  name: "张三",
  student-id: "2021123456",
  date: "2024年4月14日",
  doc
)

......
```

>（PS：如果遇到排版错误，欢迎来issue区和我分享）
  
