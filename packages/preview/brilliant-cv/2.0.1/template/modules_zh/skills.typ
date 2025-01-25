// Import
#import "@preview/brilliant-cv:2.0.1": cvSection, cvSkill, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("技能与兴趣")

#cvSkill(
  type: [语言],
  info: [英语 #hBar() 法语 #hBar() 中文],
)

#cvSkill(
  type: [技术栈],
  info: [Tableau #hBar() Python (Pandas/Numpy) #hBar() PostgreSQL],
)

#cvSkill(
  type: [个人兴趣],
  info: [游泳 #hBar() 烹饪 #hBar() 阅读],
)
