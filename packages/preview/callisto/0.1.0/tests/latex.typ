#import "@preview/mitex:0.2.5": mitext

#let s = (
  "\\begin{tabular}{r|lllll}\n",
  " Sepal.Length & Sepal.Width & Petal.Length & Petal.Width & Species\\\\\n",
  "\\hline\n",
  "\t 5.1    & 3.5    & 1.4    & 0.2    & setosa\\\\\n",
  "\t 4.9    & 3.0    & 1.4    & 0.2    & setosa\\\\\n",
  "\t 4.7    & 3.2    & 1.3    & 0.2    & setosa\\\\\n",
  "\t 4.6    & 3.1    & 1.5    & 0.2    & setosa\\\\\n",
  "\t 5.0    & 3.6    & 1.4    & 0.2    & setosa\\\\\n",
  "\t 5.4    & 3.9    & 1.7    & 0.4    & setosa\\\\\n",
  "\\end{tabular}\n",
).join()

#mitext(s)
