// Use this import when the package is published to Typst Universe
// // #import "@preview/invicta-thesis:1.0.0": *

// Import template utilities directly
#import "@preview/invicta-thesis:1.0.0" as feup

#heading(level: 1)[Literature Review]

This chapter provides a comprehensive review of existing literature in machine learning optimization, neural network architectures, and related computational techniques.

This is referenced in @khakipoor_linear_2023.

== Machine Learning Foundations

Machine learning encompasses a broad range of algorithms and techniques designed to enable computers to learn from data without being explicitly programmed for every task.

=== Supervised Learning

Supervised learning algorithms learn from labeled training data to make predictions on new, unseen data. Key approaches include:

- Linear regression and classification
- Support vector machines
- Decision trees and random forests
- Neural networks and deep learning

=== Deep Learning

Deep learning has revolutionized many areas of machine learning through the use of multi-layered neural networks.

#figure(
  image("../figures/uporto.png", width: 80%),
  caption: [Example neural network architecture],
) <fig:network>

== Optimization Techniques

Efficient optimization is crucial for training machine learning models, particularly deep neural networks.

=== Gradient Descent Methods

Gradient descent and its variants form the backbone of most machine learning optimization:

- Stochastic Gradient Descent (SGD)
- Adam optimizer
- RMSprop
- AdaGrad

=== Advanced Optimization

Recent advances include:

- Learning rate scheduling
- Gradient clipping
- Batch normization
- Regularization techniques

// Example of using algorithm function from template
#feup.algorithm("Gradient Descent")[
  1. Initialize parameters $theta_0$
  2. *for* iteration t = 1 to T *do*
     3. Compute gradients: $g_t = nabla L(theta_t)$
     4. Update parameters: $theta_(t+1) = theta_t - alpha g_t$
  5. *end for*
  6. *return* $theta_T$
]

#pagebreak()