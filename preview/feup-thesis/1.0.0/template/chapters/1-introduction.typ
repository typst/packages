// Use this import when the package is published to Typst Universe
// // #import "@preview/feup-thesis:1.0.0": *

// Import template utilities directly
#import "@preview/feup-thesis:1.0.0" as feup

#heading(level: 1)[Introduction]

The field of machine learning has experienced unprecedented growth in recent years, driven by advances in computational power, availability of large datasets, and development of sophisticated algorithms. This thesis addresses fundamental challenges in machine learning optimization and proposes novel solutions that advance the state-of-the-art.

== Motivation

Traditional machine learning approaches often struggle with scalability and efficiency when dealing with large-scale problems. The motivation for this research stems from the need to develop more efficient algorithms that can handle the increasing complexity of real-world applications.

== Research Questions

This thesis aims to answer the following research questions:

1. How can we design neural network architectures that are both accurate and computationally efficient?
2. What optimization techniques can improve the training speed of deep learning models?
3. How do these improvements translate to real-world applications?

== Contributions

The main contributions of this thesis are:

- Development of a novel neural network architecture that achieves superior performance
- Implementation of an efficient training algorithm with theoretical guarantees
- Comprehensive experimental evaluation demonstrating practical benefits

#figure(
  table(
    columns: (auto, auto, auto),
    [Method], [Accuracy], [Training Time],
    [Baseline], [85.2%], [120 min],
    [Proposed], [92.7%], [72 min],
  ),
  caption: [Comparison of proposed method with baseline],
) <tab:comparison>

== Thesis Structure

The remainder of this thesis is organized as follows:

- *Chapter 2* reviews related work in machine learning optimization
- *Chapter 3* presents the theoretical foundations of our approach
- *Chapter 4* describes the proposed methodology in detail
- *Chapter 5* presents experimental results and analysis
- *Chapter 6* concludes the thesis and discusses future work

#lorem(3000)

#pagebreak()