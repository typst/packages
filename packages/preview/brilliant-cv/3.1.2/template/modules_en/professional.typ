// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, cv-entry-start, cv-entry-continued


#cv-section("Professional Experience")

#cv-entry-start(
  society: [XYZ Corporation],
  logo: image("../assets/logos/xyz_corp.png"),
  location: [San Francisco, CA],
)

#cv-entry-continued(
  title: [Director of Data Science],
  description: list(
    [Lead a team of data scientists and analysts to develop and implement data-driven strategies, develop predictive models and algorithms to support decision-making across the organization],
    [Collaborate with executive leadership to identify business opportunities and drive growth, implement best practices for data governance, quality, and security],
  ),
  tags: ("Dataiku", "Snowflake", "SparkSQL"),
)

#cv-entry-continued(
  title: [Data Scientist],
  date: [2017 - 2020 #linebreak() 2021 - 2022],
  description: list(
    [Analyze large datasets with SQL and Python, collaborate with teams to uncover business insights],
    [Create data visualizations and dashboards in Tableau, develop and maintain data pipelines with AWS],
  ),
)

#cv-entry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("../assets/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyze large datasets with SQL and Python, collaborate with teams to uncover business insights],
    [Create data visualizations and dashboards in Tableau, develop and maintain data pipelines with AWS],
  ),
)

#cv-entry(
  title: [Data Analysis Intern],
  society: [PQR Corporation],
  logo: image("../assets/logos/pqr_corp.png"),
  date: list(
    [Summer 2017],
    [Summer 2016],
  ),
  location: [Chicago, IL],
  description: list([Assisted with data cleaning, processing, and analysis using Python and Excel, participated in team meetings and contributed to project planning and execution]),
)
