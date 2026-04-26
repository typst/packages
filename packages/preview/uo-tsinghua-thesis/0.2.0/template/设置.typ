#let settings = (

// 面向初学者：
//   以下每一项只需要修改冒号后的内容，并且不要忘记在每一项的结尾添加英文逗号
//   使用引号包裹的"字符串"，是不支持格式的纯文本。
//   使用方括号包裹的是[内容]，支持格式（加粗/强调等）。
//   使用圆括号包裹的是(数组)，含有多个成员，成员之间用英文逗号分隔。
//   true和false是逻辑值。

文章类型: "Thesis", //"Thesis"或"Dissertation"

作者名: "作者名",

作者_英: "Author Name",

论文题目:[
  清华大学研究生学位论文
  
  Typst模板 v0.2.0
], // 换行需空行

论文题目_书脊:"清华大学研究生学位论文 Typst 模板", //仅用于书脊页，内容同上，但去除换行，中西文之间添加空格，括号用半角

论文题目_英: "Tsinghua Thesis Typst Template",

副标题: "申请清华大学医学博士学位论文",

院系: "基础医学系",

英文学位名: "Doctor of Medicine",

专业: "基础医学",

专业_英: "Basic Medical Sciences",

导师: "导师名 教授",

导师_英: "Professor Sprvsr Name",

副导师: "副导名 教授", //前往template.typ搜索变量名以调整

副导师_英: "Professor AssocSprvsr Name",

// 日期: datetime(year: 2028, month: 5, day: 1), //默认为当前日期

关键词: ("Typst", "模板"),

关键词_英: ("Typst", "Template", [_Italic Text_]),

指导小组名单: /*三个为一组，姓名-职称-单位*/
("某某某", "教授", "清华大学",
"某    某", "副教授", "清华大学",
"某某某", "助理教授", "清华大学"),

公开评阅人名单:
("某某某", "教授", "清华大学",
"某某某", "副教授", "XXXX大学",
"某某某", "研究员", "中国XXXX科学院XXXXXX研究所"),

答辩委员会名单:/*注意，所有委员只有第一个需要写明，其余留空字符串*/
("主席", "某某某", "教授", "清华大学",
"委员", "某某某", "教授", "清华大学",
"", "某某某", "研究员", "中国XXXX科学院\nXXXXXX研究所",
"", "某某某", "教授", "XXXX大学",
"", "某某某", "副教授", "XXXX大学",
"秘书", "某某某", "助理研究员", "清华大学"),

目录深度: 3,

盲审版本: false, // 尚未调整

插图清单: true,

附表清单: true,

代码清单: false, // 尚未调整

右页起章: false, // 目前有bug

// 为避免版权争议，以本项目从v0.2.0开始将内置字体替换为以下开源字体，但效果并不完美
// 可以手动上传Windows版本的字体: 
// Web APP上传字体文件到任意目录后将以下字体名称后替换为: Times New Roman; Arial; SimHei(黑体); SimSun(宋体); FangSong(仿宋); KaiTi(楷体)
字体: ( 
  仿宋: ("Tex Gyre Termes", "FandolFang R"),
  宋体: ("Tex Gyre Termes", "FandolSong"),
  黑体: ("Tex Gyre Heros","FandolHei"),
  楷体: ("Tex Gyre Termes", "FandolKai"),
  代码: ("Cascadia Code", "FandolHei"),
)

)