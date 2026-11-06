// Imports
#import "@preview/brilliant-cv:2.0.4": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("项目与协会")

#cvEntry(
  title: [志愿数据分析师],
  society: [ABC 非营利组织],
  date: [2019 - 现在],
  location: [纽约, NY],
  description: list(
    [分析捐赠者和筹款数据以识别增长的趋势和机会],
    [创建数据可视化和仪表板以向董事会传达洞见],
  ),
)
