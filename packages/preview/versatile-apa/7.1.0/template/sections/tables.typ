#import "@preview/versatile-apa:7.1.0": apa-figure

= Sample Tables
// Sample tables taken from https://apastyle.apa.org/style-grammar-guidelines/tables-figures/sample-tables
== Sample Demographic Characteristics Table
Referencing @table:sample-demographic-characteristics.

#apa-figure(
  table(
    align: (x, y) => if (y == 0 or y == 1) and x >= 0 {
      center
    } else if x == 0 and y > 0 {
      left
    } else {
      center
    },
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.header(
      table.hline(),
      table.cell(rowspan: 2)[Baseline characteristic],
      table.cell(colspan: 2)[Guided self-help],
      table.cell(colspan: 2)[Unguided self-help],
      table.cell(colspan: 2)[Wait-list control],
      table.cell(colspan: 2)[Full sample],
      table.hline(),
      [n],
      [%],
      [n],
      [%],
      [n],
      [%],
      [n],
      [%],
    ),
    table.hline(),
    [Gender],
    table.cell(colspan: 8)[],
    [~Female],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Male],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Marital status],
    table.cell(colspan: 8)[],
    [~Single],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Married/partnered],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Divorced/widowed],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Other],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Children #super([a])],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Cohabitating],
    [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Highest educational level], table.cell(colspan: 8)[],
    [~Middle school], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~High school/some college], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~University or postgraduate degree], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Employment], table.cell(colspan: 8)[],
    [~Unemployed], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Student], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Self-employed], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [~Retired], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Previous psychological treatment#super[a]], [25], [50], [20], [40], [23], [46], [68], [45.3],
    [Previous psychotropic medication#super[a]], [25], [50], [20], [40], [23], [46], [68], [45.3],
    table.hline(),
  ),
  note: [N = 150 (n = 50 for each condition). Participants were on average 39.5 years old (SD = 10.1), and participant age did not differ by condition.],
  specific-note: [
    #super[a] Reflects the number and percentage of participants answering “yes” to this question.],
  caption: [Sociodemographic Characteristics of Participants at Baseline],
  label: "table:sample-demographic-characteristics",
)

== Sample Results of Several $t$ Tests Table
Referencing @table:sample-results-of-several-t-tests.

#apa-figure(
  table(
    align: (x, y) => if (y == 0 or y == 1) and x >= 0 {
      center
    } else if x == 0 and y > 0 {
      left
    } else {
      center
    },
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.header(
      table.hline(),
      table.cell(rowspan: 2)[Logistic parameter],
      table.cell(colspan: 2)[9-year-olds],
      table.cell(colspan: 2)[16-year-olds],
      table.cell(rowspan: 2)[$t(40)$],
      table.cell(rowspan: 2)[$p$],
      table.cell(rowspan: 2)[Cohen's $d$],
      table.hline(),
      [M],
      [SD],
      [M],
      [SD],
    ),
    table.hline(),
    [Maximum asymptote, proportion],
    [0.85], [0.05], [0.90], [0.04], [2.56], [.014], [.63],
    [Crossover, in ms],
    [500], [50], [450], [40], [2.34], [.024], [.56],
    [Slope, as change in proportion per ms],
    [.002], [.0005], [.0025], [.0004], [2.56], [.014], [.63],
    table.hline(),
  ),
  note: [For each subject, the logistic function was fit to target fixations separately. The maximum asymptote is the asymptotic degree of looking at the end of the time course of fixations. The crossover point is the point in time the function crosses the midway point between peak and baseline. The slope represents the rate of change in the function measured at the crossover. Mean parameter values for each of the analyses are shown for the 9-year-olds (n = 24) and 16-year-olds (n = 18), as well as the results of t tests (assuming unequal variance) comparing the parameter estimates between the two ages.],
  caption: [Results of Curve-Fitting Analysis Examining the Time Course of Fixations to the Target],
  label: "table:sample-results-of-several-t-tests",
)

== Sample Correlation Table
Referencing @table:sample-correlation.

#apa-figure(
  table(
    align: (x, y) => if y == 0 and x >= 0 {
      center
    } else if x == 0 and y > 0 {
      left
    } else {
      center
    },
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.hline(),
    table.header(
      [Variable],
      [_n_],
      [_M_],
      [_SD_],
      [1],
      [2],
      [3],
      [4],
      [5],
      [6],
      [7],
    ),
    [1. Internal-external status#super[a]], [3,697], [0.43], [0.49], [-], [-], [-], [-], [-], [-], [-],
    [2. Manager job performance], [2,134], [3.14], [0.62], [-.08\*\*], [-], [-], [-], [-], [-], [-],
    [3. Starting salary#super[b]], [3,697], [1.01], [0.27], [.45\*\*], [-.01], [-], [-], [-], [-], [-],
    [4. Subsequent promotion], [3,697], [0.33], [0.47], [.08\*\*], [-.07\*\*], [.04\*], [-], [-], [-], [-],
    [5. Organizational tenure], [3,697], [6.45], [6.62], [-.29\*\*], [.09\*\*], [.01], [.09\*\*], [-], [-], [-],
    [6. Unit service performance#super[c]], [3,505], [85.00], [6.98], [-.25\*\*], [-.39\*\*], [.24\*\*], [.08\*\*], [.01], [-], [-],
    [7. Unit financial performance#super[c]], [694], [42.61], [5.86], [.00], [-.03], [.12\*], [-.07], [-.02], [.16\*\*], [-],
    table.hline(),
  ),
  specific-note: [
    #super[a] 0 = internal hires and 1 = external hires.

    #super[b] A linear transformation was performed on the starting salary values to maintain pay practice confidentiality. The standard deviation (0.27) can be interpreted as 27% of the average starting salary for all managers. Thus, ±1 SD includes a range of starting salaries from 73% (i.e., 1.00 – 0.27) to 127% (i.e., 1.00 + 0.27) of the average starting salaries for all managers.

    #super[c] Values reflect the average across 3 years of data.
  ],
  probability-note: [#super[\*]$p < .05$. #super[\*\*]$p < .01$.],
  caption: [Descriptive Statistics and Correlations for Study Variables],
  label: "table:sample-correlation",
)
