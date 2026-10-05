#import "@preview/clean-esi:0.1.0": thesis-table

= Supplementary Material <app:supplementary>

Appendix tables are numbered per appendix (Table A.1, A.2, …).

#figure(
  thesis-table(
    columns: 2,
    table.header[Parameter][Value],
    [Learning rate], [0.001],
    [Epochs], [10],
  ),
  caption: [Example hyperparameters.],
) <tab:hyperparameters>
