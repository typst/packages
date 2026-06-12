// 论文基本信息配置,请根据实际情况修改以下字段的值，name表示左侧名称(最好不超过10个字符)，value表示右侧信息，visible表示字段是否可见，depth表示字段的深度。
// config of basic information, please modify the value of the following fields according to your actual situation. name is the label on the left（you should keep it within 10 characters）, value is the information on the right, visible indicates whether the field is visible, and depth indicates the depth of the field.
#let conf = (
  head: (name: "主标题", value: "主标题", visible: true, depth: 1), //主标题,main title
  title: (name: "副标题", value: "副标题", visible: true, depth: 2), //副标题,subtitle
  title-en: (name: "英文标题", value: "English Title", visible: false, depth: 3), //英文标题,English title
  school-semester: (name: "学期信息", value: "2023-2024学年第一学期", visible: false, depth: 4), //学期信息,semester information
  school: (name: "学校名称", value: "XX大学", visible: true, depth: 5), //学校名称,school name
  course-id: (name: "课程号", value: "课程ID", visible: true, depth: 6), //课程ID,course ID
  course-name: (name: "课程名称", value: "课程名称", visible: true, depth: 7), //课程名称,course name
  college: (name: "学院名称", value: "社会科学与技术学院", visible: true, depth: 8), //学院名称,college name
  author: (name: "学生姓名", value: "张三", visible: true, depth: 9), //学生姓名,student name
  student-id: (name: "学号", value: "1145141314", visible: true, depth: 10), //学号,student ID
  class: (name: "班级信息", value: "XX班", visible: true, depth: 11), //班级信息,class information
  major: (name: "专业名称", value: "宇宙社会学", visible: true, depth: 12), //专业名称,major name
  supervisor: (name: "指导教师", value: "罗教授", visible: true, depth: 13), //指导教师姓名,supervisor name
  date: (name: "日期", value: datetime.today().display("[year]年[month]月[day]日"), visible: true, depth: 14), //日期，默认为当天日期，可以根据需要修改,date, default is today's date, you can modify it as needed
  info-order: (4, 6, 7, 13, 10, 9, 11),
  //显示信息的顺序，可以根据需要调整顺序，数字对应上面 conf 中字段的 depth 值，默认1->3,14不会显示在封面文章信息上（即字段映射表中）。
  //The order of displayed information can be adjusted as needed, the numbers correspond to the depth values of the fields in conf above, by default it is 1->3,14 will not be displayed on the cover article information (that is, in the field mapping table).
)
