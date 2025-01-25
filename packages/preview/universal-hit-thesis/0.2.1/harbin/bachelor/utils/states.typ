#import "../config/constants.typ": current-date

#let thesis-info-state = state(
  "thesis-info",
  (
    title-cn: "",
    title-en: "",
    author: "▢▢▢",
    student-id: "▢▢▢▢▢▢▢▢▢▢",
    supervisor: "▢▢▢ 教授",
    profession: "▢▢▢ 专业",
    collage: "▢▢▢ 学院",
    institute: "哈尔滨工业大学",
    year: current-date.year(),
    month: current-date.month(),
    day: current-date.day(),
  ),
)

#let bibliography-state = state("bibliography")