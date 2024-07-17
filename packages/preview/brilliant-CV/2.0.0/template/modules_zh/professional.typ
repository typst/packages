// Imports
#import "@preview/brilliant-cv:2.0.0": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("职业经历")

#cvEntry(
  title: [数据科学主管],
  society: [XYZ 公司],
  logo: image("../src/logos/xyz_corp.png"),
  date: [2020 - 现在],
  location: [旧金山, CA],
  description: list(
    [领导数据科学家和分析师团队，开发和实施数据驱动的策略，开发预测模型和算法以支持组织内部的决策],
    [与高级管理团队合作，确定商业机会并推动增长，实施数据治理、质量和安全的最佳实践],
  ),
)

#cvEntry(
  title: [数据分析师],
  society: [ABC 公司],
  logo: image("../src/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [纽约, NY],
  description: list(
    [使用 SQL 和 Python 分析大型数据集，与跨职能团队合作以识别商业洞见],
    [使用 Tableau 创建数据可视化和仪表板，使用 AWS 开发和维护数据管道],
  ),
)

#cvEntry(
  title: [数据分析实习生],
  society: [PQR 公司],
  logo: image("../src/logos/pqr_corp.png"),
  date: [2017年夏季],
  location: [芝加哥, IL],
  description: list(
    [协助使用 Python 和 Excel 进行数据清洗、处理和分析，参与团队会议并为项目规划和执行做出贡献],
    [开发数据可视化和报告以向利益相关者传达洞见，与其他实习生和团队成员合作以按时并高质量完成项目],
  ),
)
