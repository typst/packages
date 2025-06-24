// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Professional Experience")

#cvEntry(
  title: [Director of Data Science],
  society: [XYZ Corporation],
  logo: image("../src/logos/xyz_corp.png"),
  date: [2020 - Present],
  location: [San Francisco, CA],
  description: list(
    [Lead a team of data scientists and analysts to develop and implement data-driven strategies, develop predictive models and algorithms to support decision-making across the organization],
    [Collaborate with executive leadership to identify business opportunities and drive growth, implement best practices for data governance, quality, and security],
  ),
  tags: ("Tags Example here", "Dataiku", "Snowflake", "SparkSQL"),
)

#cvEntry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("../src/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyze large datasets with SQL and Python, collaborate with teams to uncover business insights],
    [Create data visualizations and dashboards in Tableau, develop and maintain data pipelines with AWS],
  ),
)

#cvEntry(
  title: [Data Analysis Intern],
  society: [PQR Corporation],
  logo: image("../src/logos/pqr_corp.png"),
  date: list(
    [Summer 2017],
    [Summer 2016],
  ),
  location: [Chicago, IL],
  description: list([Assisted with data cleaning, processing, and analysis using Python and Excel, participated in team meetings and contributed to project planning and execution]),
)
