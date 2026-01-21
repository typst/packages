#import "@preview/tabut:<<VERSION>>": records-from-csv

#let titanic = records-from-csv(csv("titanic.csv"));

#let classes = (
  "N/A",
  "First", 
  "Second", 
  "Third"
);