#import "@preview/invicta-thesis:1.0.0" as feup

#heading[Implementation Details]

This appendix provides additional implementation details and code snippets.

#heading(level: 2)[Network Architecture Code]

#feup.code-block(
```python
import torch
import torch.nn as nn

class ProposedNetwork(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(ProposedNetwork, self).__init__()
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim // 2)
        )
        self.bottleneck = nn.Linear(hidden_dim // 2, hidden_dim // 4)
        self.decoder = nn.Sequential(
            nn.Linear(hidden_dim // 4, hidden_dim // 2),
            nn.ReLU(),
            nn.Linear(hidden_dim // 2, output_dim)
        )
    
    def forward(self, x):
        encoded = self.encoder(x)
        bottleneck = self.bottleneck(encoded)
        output = self.decoder(bottleneck)
        return output
```,
caption: "PyTorch implementation of proposed architecture"
)

#heading(level: 2)[Training Configuration]

The following hyperparameters were used for training:

- Learning rate: 0.001
- Batch size: 32
- Number of epochs: 100
- Optimizer: Adam
- Weight decay: 1e-4