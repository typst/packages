// Use this import when the package is published to Typst Universe
// // #import "@preview/invicta-thesis:1.0.0": *

#import "@preview/invicta-thesis:1.0.0" as feup

#heading(level: 1)[Theoretical Foundations]

This chapter establishes the theoretical foundations for our proposed approach, including mathematical formulations and algorithmic principles.

== Problem Formulation

Let $X = {x_1, x_2, ..., x_n}$ be a dataset of input samples and $Y = {y_1, y_2, ..., y_n}$ be the corresponding target outputs. Our goal is to learn a function $f: X -> Y$ that minimizes the expected risk:

$ R(f) = integral L(y, f(x)) p(x, y) d x d y $

where $L$ is a loss function and $p(x, y)$ is the joint probability distribution.

== Proposed Architecture

Our neural network architecture consists of multiple components designed to optimize both accuracy and computational efficiency.

=== Network Structure

The network follows an encoder-decoder structure with the following key components:

1. *Input layer*: Processes raw input data
2. *Encoder layers*: Extract hierarchical features
3. *Bottleneck layer*: Compresses information
4. *Decoder layers*: Reconstruct output representation
5. *Output layer*: Produces final predictions

=== Optimization Algorithm

We propose a novel optimization algorithm that combines the benefits of adaptive learning rates with momentum-based updates.

#feup.algorithm("Proposed Optimization Algorithm")[
  1. Initialize parameters $theta_0$
  2. *for* t = 1 to T *do*
     3. Sample mini-batch B from training data
     4. Compute gradients: $g_t = nabla_theta L(theta_t, B)$
     5. Update momentum: $m_t = beta_1 m_(t-1) + (1-beta_1)g_t$
     6. Update parameters: $theta_(t+1) = theta_t - alpha_t m_t$
  7. *end for*
]

#pagebreak()
