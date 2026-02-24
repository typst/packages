// Use this import when the package is published to Typst Universe
// // #import "@preview/invicta-thesis:1.0.0": *

#import "@preview/invicta-thesis:1.0.0" as feup

#heading(level: 1)[Results and Analysis]

This chapter presents comprehensive experimental results and analysis of our proposed approach.

== Performance Comparison

@tab:results shows the performance comparison between our method and existing baselines across different datasets.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [Dataset], [Baseline], [Proposed], [Improvement],
    [CIFAR-10], [85.2%], [92.7%], [+7.5%],
    [ImageNet], [76.1%], [81.3%], [+5.2%],
    [Penn Treebank], [88.9%], [93.1%], [+4.2%],
  ),
  caption: [Performance comparison across datasets],
) <tab:results>

== Training Efficiency

Our proposed method shows significant improvements in training efficiency:

- 40% reduction in training time
- 30% decrease in memory usage
- Better convergence properties

/*
#figure(
  image("figures/uporto.png", width: 70%),
  caption: [Training loss convergence comparison],
) <fig:convergence>
*/

== Statistical Analysis

We performed statistical significance tests to validate our results:

- Paired t-test: p < 0.001
- Effect size (Cohen's d): 1.24 (large effect)
- 95% confidence interval: [0.85, 1.63]

== Discussion

The results demonstrate that our proposed approach achieves superior performance across multiple benchmarks while maintaining computational efficiency. The improvements can be attributed to:

1. *Better architecture design*: The encoder-decoder structure captures hierarchical features effectively
2. *Efficient optimization*: Our algorithm converges faster than traditional methods
3. *Regularization effects*: The bottleneck layer prevents overfitting

#pagebreak()