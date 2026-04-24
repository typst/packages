// 论文基本信息配置,请根据实际情况修改以下字段的值，并设置对应的可见性（visible）为 true 或 false。
#let conf = (
  head: (value: "主标题", visible: true, depth: 1), //主标题
  title: (value: "副标题", visible: true, depth: 2), //副标题
  title_en: (value: "English Title", visible: false, depth: 3), //英文标题
  school_semester: (value: "2023-2024学年第一学期", visible: false, depth: 4), //学期信息
  school: (value: "XX大学", visible: true, depth: 5), //学校名称
  course_id: (value: "课程ID", visible: true, depth: 6), //课程ID
  course_name: (value: "课程名称", visible: true, depth: 7), //课程名称
  college: (value: "社会科学与技术学院", visible: true, depth: 8), //学院名称
  author: (value: "张三", visible: true, depth: 9), //学生姓名
  student_id: (value: "1145141314", visible: true, depth: 10), //学号
  class: (value: "XX班", visible: true, depth: 11), //班级信息
  major: (value: "宇宙社会学", visible: true, depth: 12), //专业名称
  supervisor: (value: "罗教授", visible: true, depth: 13), //指导教师姓名
  date: (value: datetime.today().display("[year]年[month]月[day]日"), visible: true, depth: 14), //日期，默认为当天日期，可以根据需要修改
  info-order: (4, 6, 7, 13, 10, 9, 11), //显示信息的顺序，可以根据需要调整顺序，数字对应上面 conf 中字段的 depth 值
)
