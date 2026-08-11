// Imports
#import "@preview/brilliant-cv:3.1.1": cv-section, cv-entry, cv-entry-start, cv-entry-continued


#cv-section("职业经历")

#cv-entry-start(
  society: [XYZ 公司],
  logo: image("../assets/logos/xyz_corp.png"),
  location: [旧金山, CA],
)

#cv-entry-continued(
  title: [数据科学主管],
  date: [2020 - 现在],
  description: list(
    [领导数据科学家和分析师团队，开发和实施数据驱动的策略，开发预测模型和算法以支持组织内部的决策],
    [与高级管理团队合作，确定商业机会并推动增长，实施数据治理、质量和安全的最佳实践],
  ),
  tags: ("Dataiku", "Snowflake", "SparkSQL"),
)

#cv-entry(
  title: [数据分析师],
  society: [ABC 公司],
  logo: image("../assets/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [纽约, NY],
  description: list(
    [使用 SQL 和 Python 分析大型数据集，与团队合作发现商业洞见],
    [使用 Tableau 创建数据可视化和仪表板，使用 AWS 开发和维护数据管道],
  ),
)

#cv-entry(
  title: [数据分析实习生],
  society: [PQR 公司],
  logo: image("../assets/logos/pqr_corp.png"),
  date: list(
    [2017年夏季],
    [2016年夏季],
  ),
  location: [芝加哥, IL],
  description: list([协助使用 Python 和 Excel 进行数据清洗、处理和分析，参与团队会议并为项目规划和执行做出贡献]),
)
