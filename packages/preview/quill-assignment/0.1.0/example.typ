#import "lib.typ": *

#show: assignment.with(
  title: "Deep Learning Architectures & Optimization",
  subtitle: "Theoretical Analysis and Empirical Benchmarking",
  course: "CS 480: Advanced Machine Learning",
  assignment: "Assignment 3",
  student: "Alex Rivera",
  student-id: "2024-88912",
  department: "Department of Computer Science",
  university: "Stanford University",
  date: datetime.today(),
  theme: "nord-light",
  cover-page: true,
  cover-style: "swiss",
  toc: true,
  header-show: false,
  footer-show: true,
)

= Machine Learning Foundations

#question(title: "Gradient Derivation for Multi-Layer Perceptrons")[
  Consider a multi-layer perceptron (MLP) with activation function $sigma(z)$ and loss function $L(y, hat(y))$. Derive the parameter update rule for the weight matrix $W^((l))$ at layer $l$ using the chain rule.
]

#answer[
  The forward pass for layer $l$ is defined by:
  $ z^((l)) = W^((l)) a^((l-1)) + b^((l)), quad a^((l)) = sigma(z^((l))) $

  By applying the multivariate chain rule, the error term $delta^((l)) = (partial L) / (partial z^((l)))$ is computed recursively:
  $ delta^((l)) = ((W^((l+1)))^T delta^((l+1))) circle.tiny sigma'(z^((l))) $

  Consequently, the gradient with respect to the weight matrix $W^((l))$ is given by:
  $ (partial L) / (partial W^((l))) = delta^((l)) (a^((l-1)))^T $

  #note(type: "tip", title: "Numerical Stability")[
    When computing gradients for deep networks, use log-sum-exp stabilization to avoid floating-point overflow during softmax calculations.
  ]
]

= Optimization & Implementation

#question(title: "PyTorch Residual Layer")[
  Write a modular PyTorch module implementing a residual dense block with layer normalization and dropout.
]

#answer[
  ```python
  import torch
  import torch.nn as nn

  class ResidualBlock(nn.Module):
      """Residual dense block with LayerNorm and Dropout."""
      def __init__(self, dim: int, dropout: float = 0.1):
          super().__init__()
          self.fc1 = nn.Linear(dim, dim * 4)
          self.act = nn.GELU()
          self.fc2 = nn.Linear(dim * 4, dim)
          self.norm = nn.LayerNorm(dim)
          self.drop = nn.Dropout(dropout)

      def forward(self, x: torch.Tensor) -> torch.Tensor:
          residual = x
          x = self.drop(self.act(self.fc1(self.norm(x))))
          x = self.drop(self.fc2(x))
          return x + residual
  ```

  #note(type: "info", title: "Architecture Note")[
    LayerNorm is applied prior to activation (pre-LN configuration) to promote smooth gradient propagation in ultra-deep networks.
  ]
]

= System Configuration & Key Properties

#question(title: "Hyperparameter Specifications")[
  Summarize the hyperparameter setup and evaluation environment for the model training runs.
]

#answer[
  #kv-table(
    "Model Architecture",
    "Transformer-Encoder (12 Layers)",
    "Optimizer",
    "AdamW (weight decay = 0.01)",
    "Learning Rate",
    "3e-4 with Cosine Annealing",
    "Batch Size",
    "256 across 4 GPUs",
    "Precision",
    "Mixed Precision (FP16)",
  )
]

= Empirical Results & Benchmarks

#question(title: "Optimizer Performance Comparison")[
  Compare the empirical convergence speed and final accuracy across standard optimizers evaluated on ImageNet-1k.
]

#answer[
  #table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    [*Optimizer*], [*Learning Rate*], [*Top-1 Accuracy*], [*Train Time*],
    [SGD + Momentum], [0.1], [76.4%], [12.4 hrs],
    [AdamW], [3e-4], [79.2%], [10.1 hrs],
    [Lion], [1e-4], [79.6%], [8.5 hrs],
  )

  #note(type: "warning", title: "Hyperparameter Sensitivity")[
    The Lion optimizer is notably sensitive to weight decay settings; excessive decay can lead to early convergence plateaus.
  ]

  #watermark("/assets/neural_net.jpg", mark: "2022")

]
