// Use this import when the package is published to Typst Universe
// // #import "@preview/feup-thesis:1.0.0": *

#import "@preview/feup-thesis:1.0.0" as feup

#heading(level: 1)[Methodology]

This chapter presents our experimental methodology, including dataset preparation, implementation details, and evaluation metrics.

== Experimental Setup

We conducted experiments on several benchmark datasets to evaluate the performance of our proposed approach.

=== Datasets

We used the following datasets for evaluation:

- *CIFAR-10*: 60,000 32×32 color images in 10 classes
- *ImageNet*: Large-scale visual recognition dataset
- *Penn Treebank*: Natural language processing benchmark

=== Implementation Details

All experiments were implemented using Python and PyTorch framework. Training was performed on NVIDIA GPUs with the following specifications:

- GPU: NVIDIA RTX 3080
- Memory: 10GB GDDR6X
- CUDA version: 11.4

== Evaluation Metrics

We evaluated our approach using standard metrics:

- *Accuracy*: Percentage of correctly classified samples
- *Training time*: Wall-clock time for model training
- *Memory usage*: Peak GPU memory consumption
- *FLOPS*: Floating-point operations per second

#pagebreak()
