#import "@preview/tabut:1.0.1": records-from-csv

#let titanic = records-from-csv(csv("titanic.csv"));

#let classes = (
  "N/A",
  "First", 
  "Second", 
  "Third"
);