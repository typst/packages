#import "@preview/ttt-lists:0.1.0": studentlist as list


#set page("a4", margin: 1cm)
#set text(14pt, font:"Rubik", weight: 300, lang: "de")

= Class list

#let data = csv("students.csv")

#{ data = list.add_check_column(data, title: "Attending") }

#list.studentlist(
  numbered: true, 
  lines: true,
  tag: "Year 24/25",
  data,
);
