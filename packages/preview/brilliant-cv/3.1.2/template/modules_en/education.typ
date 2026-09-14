// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, h-bar


#cv-section("Education")

#cv-entry(
  title: [Master of Data Science],
  society: [University of California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Thesis: Predicting Customer Churn in Telecommunications Industry using Machine Learning Algorithms and Network Analysis],
    [Course: Big Data Systems and Technologies #h-bar() Data Mining and Exploration #h-bar() Natural Language Processing],
  ),
)

#cv-entry(
  title: [Bachelors of Science in Computer Science],
  society: [University of California, Los Angeles],
  date: [2014 - 2018],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Thesis: Exploring the Use of Machine Learning Algorithms for Predicting Stock Prices: A Comparative Study of Regression and Time-Series Models],
    [Course: Database Systems #h-bar() Computer Networks #h-bar() Software Engineering #h-bar() Artificial Intelligence],
    [GPA: 3.8/4.0, Magna Cum Laude],
  ),
  tags: ("Computer Science", "Machine Learning", "Statistics"),
)

// Example with multiple date periods (study abroad program)
#cv-entry(
  title: [Exchange Student Program],
  society: [Technical University of Munich],
  date: list(
    [Fall 2016],
    [Spring 2017],
  ),
  location: [Germany],
  description: list(
    [Specialized courses in Advanced Algorithms and Data Structures],
    [Research project on Distributed Computing Systems],
  ),
)
