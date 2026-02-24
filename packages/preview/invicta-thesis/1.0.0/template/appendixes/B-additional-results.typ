#import "@preview/invicta-thesis:1.0.0" as feup

#heading[Additional Results]  

This appendix contains supplementary experimental results and analysis.

#heading(level: 2)[Detailed Performance Metrics]

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    [Method], [Precision], [Recall], [F1-Score], [AUC],
    [Baseline 1], [0.842], [0.838], [0.840], [0.891],
    [Baseline 2], [0.856], [0.851], [0.853], [0.904],
    [Proposed], [0.925], [0.921], [0.923], [0.967],
  ),
  caption: [Detailed performance metrics on test set],
)

#heading(level: 2)[Computational Complexity]

The computational complexity of our proposed method is O(n log n) for training and O(log n) for inference, where n is the input dimension.