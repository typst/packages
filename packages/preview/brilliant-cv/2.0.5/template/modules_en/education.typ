// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Education")

#cvEntry(
  title: [Master of Data Science],
  society: [University of California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Thesis: Predicting Customer Churn in Telecommunications Industry using Machine Learning Algorithms and Network Analysis],
    [Course: Big Data Systems and Technologies #hBar() Data Mining and Exploration #hBar() Natural Language Processing],
  ),
)

#cvEntry(
  title: [Bachelors of Science in Computer Science],
  society: [University of California, Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Thesis: Exploring the Use of Machine Learning Algorithms for Predicting Stock Prices: A Comparative Study of Regression and Time-Series Models],
    [Course: Database Systems #hBar() Computer Networks #hBar() Software Engineering #hBar() Artificial Intelligence],
  ),
)
