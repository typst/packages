// Imports
#import "@preview/brilliant-cv:2.0.3": cvSection, cvHonor
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvHonor = cvHonor.with(metadata: metadata)


#cvSection("证书")

#cvHonor(
  date: [2022],
  title: [AWS 安全认证],
  issuer: [亚马逊网络服务 (AWS)],
)

#cvHonor(
  date: [2017],
  title: [应用数据科学与 Python],
  issuer: [Coursera],
)

#cvHonor(
  date: [],
  title: [SQL 基础课程],
  issuer: [Datacamp],
)
