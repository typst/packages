#import "@preview/cupst:0.1.0": *

#show: cupst.with(
  title: [Scalable Representation Learning and Structural Inference in Heterogeneous Information Networks],
  short-title: [Scalable Representation Learning],
  
  authors: (
    (
      name: "Joanna Thorne",
      affiliation: "affi1",
      email: "j.thorne@lorem.ac.uk",
      orcid: "0000-0001-2345-6789",
    ),
    (
      name: "Jane Doe",
      affiliation: ("affi1", "affi2"),
      orcid: "0000-0002-3456-7890",
    ),
    (
      name: "Alice Smith",
      affiliation: "affi2",
      orcid: "0000-0003-4567-8901",
    ),
  ),
  affiliations: (
    (id: "affi1", name: "Faculty of Computer Science and Engineering, Lorem University, Cambridge, United Kingdom"),
    (id: "affi2", name: "Department of Applied Mathematics, Ipsum Institute of Technology, Boston, MA, United States"),
  ),
  
  abstract: [
    Heterogeneous information networks provide a principled mathematical foundation for modeling interconnected, multi-modal complex systems. In this work, we present a unified deep representation learning and topological inference framework designed for high-dimensional observational streams. By coupling residual tensor decompositions with multi-head self-attention operators, the proposed architecture simultaneously reconstructs latent graph topology and extracts noise-invariant representations across arbitrary modalities. We establish theoretical guarantees on the convergence rate of our structural inference objective and prove that the induced representations satisfy bound-preserving Lipschitz smoothness. Extensive empirical evaluations conducted on three benchmark datasets demonstrate that our approach outperforms competitive baseline models, achieving an average relative improvement of $14.2\%$ in link prediction accuracy and $8.7\%$ in multi-class entity classification while reducing training wall-clock time by $32\%$.
  ],
  
  keywords: ("deep learning", "graph neural networks", "heterogeneous networks", "representation learning", "tensor factorization"),
  
  // Article settings
  manuscript: "article",  // article, rescience, data, software, editorial, proceedings, poster
  layout: "publish",     // preprint, publish
  paper-size: "large",   // large (210×280mm, two-column), medium (174×247mm), small (152×228mm)
  journal: "Journal of Open Information Systems",
  year: 2026,
  volume: 4,
  doi: "10.1017/cupst.2026.1042",
  
  // For published articles
  received: "January 15, 2024",
  revised: "March 20, 2024",
  accepted: "April 5, 2024",
  published: "April 30, 2024",
  editor: "Prof. Alan Turing",
  reviewers: "Anonymous Reviewers",
  
  // Display options
  show-line-numbers: true,
  section-numbering: true,
  structure-color: rgb(33, 63, 144),
  link-color: rgb(24, 76, 172),
)

= Introduction <sec:intro>

The rapid proliferation of networked sensor systems, biological ontologies, and multi-relational knowledge graphs has underscored the imperative for scalable, expressive representation learning algorithms @Goodfellow2016DeepLearning. Unlike homogeneous graphs where nodes and edges share a uniform attribute space, heterogeneous information networks (HINs) encode multi-typed entities and diverse semantics, presenting unique theoretical and algorithmic challenges @Vaswani2017Attention.

Prior investigations have established foundational principles for localized graph convolutions and residual representations @He2016ResNet. Furthermore, #cite(<Selvaraju2020Grad>, form: "prose") highlighted the necessity of gradient-based interpretability in deep representations, demonstrating how localization maps reflect structural saliency. #cite(<Huerta2016ETE>, form: "author")’s (#cite(<Huerta2016ETE>, form: "year")) tree-traversal techniques and phylogenomic visualization pipelines also illustrate the growing demand for scalable graph-theoretic infrastructure in computational biology.

#quote(attribution: [Claude E. Shannon, 1940 #cite(<Shannon1940Thesis>)])[
  "An algebra is developed for the mathematical analysis of switching circuits... showing that any operation capable of expression in symbolic logic can be performed by electrical systems."
]

Recent advances in foundation models and large-scale multimodal systems @Achiam2023GPT4 suggest that unifying dense self-attention with structured topological inductive biases is crucial for out-of-distribution robustness. Aligning learning dynamics with human intent and verifiable safety bounds remains a key open question in artificial intelligence research @Russell2020Safety.

In this paper, we address these challenges through the following core contributions:
- *Unified Tensor Formulation:* We formulate joint structural and relational message passing as a regularized tensor decomposition problem with provable convergence bounds.
- *Native Typst-Engineered Pipeline:* All algorithmic formulations conform to standard specification protocols according to the international standard @ISO2023Stats and implementation standards @PythonManual2024.
- *Extensive Empirical Validation:* We validate our method across multiple large-scale visual and relational databases, including adapted subsets of ImageNet @Deng2009ImageNet, demonstrating superior stability and parameter efficiency.

The remainder of this article is organized as follows. @sec:formulation details the mathematical formulation and theoretical foundations. @sec:method describes the architecture and algorithmic implementation. @sec:experiments presents our empirical results, followed by the discussion in @sec:discussion and conclusion in @sec:conclusion.

= Mathematical Formulation <sec:formulation>

Let $cal(G) = (cal(V), cal(E), cal(T)_v, cal(T)_e)$ denote a heterogeneous information network, where $cal(V)$ is the node set, $cal(E) subset.eq cal(V) times cal(V)$ represents the directed edge set, and $cal(T)_v, cal(T)_e$ are type mapping functions.

== Topological Definitions and Notations

We introduce the primary structural concepts employed throughout this work:

/ Adjacency Tensor ($bold(cal(A))$): A 3-mode tensor $bold(cal(A)) in RR^(|cal(V)| times |cal(V)| times |cal(T)_e|)$ where entry $cal(A)_(i, j, r) = 1$ if a relation of type $r$ exists from node $v_i$ to $v_j$.
/ Semantic Projection ($bold(W)_tau$): A type-specific parameter matrix $bold(W)_tau in RR^(d_0 times d_tau)$ mapping entity attributes into a shared $d_0$-dimensional metric space.
/ Message-Passing Operator ($cal(M)$): An equivariant mapping that aggregates neighborhood representations conditioned on edge types.

== Optimization Objective

Given node feature matrix $bold(X) in RR^(n times d_0)$ and relation tensor $bold(cal(A))$, the primary joint objective function $cal(L)(bold(Theta))$ is formulated as:

$ cal(L)(bold(Theta)) = underbrace(1/|cal(E)| sum_((i,j,r) in cal(E)) ell(f_bold(Theta)(v_i, v_j, r), y_(i, j, r)), "Supervised Link Loss") + lambda_1 ||bold(Theta)||_F^2 + lambda_2 cal(R)(bold(cal(A))) $ <eq:objective>

where $ell(dot, dot)$ is the binary cross-entropy loss, $lambda_1, lambda_2 > 0$ denote regularization hyperparameters, and the topological smoothness term $cal(R)(bold(cal(A)))$ is defined as:

$ cal(R)(bold(cal(A))) = sum_(r=1)^(|cal(T)_e|) tr(bold(H)_r^top bold(Delta)_r bold(H)_r) $ <eq:smoothness>

Here $bold(Delta)_r = bold(D)_r - bold(A)_r$ denotes the normalized graph Laplacian matrix associated with relation slice $r$.

The piecewise aggregation weight $alpha_(i, j)$ between adjacent entities is governed by:

$ alpha_(i, j) = cases(
  (exp(sigma(bold(a)^top [bold(W) h_i || bold(W) h_j]))) / (sum_(k in cal(N)_i) exp(sigma(bold(a)^top [bold(W) h_i || bold(W) h_k]))) & "if" j in cal(N)_i,
  0 & "otherwise",
) $ <eq:attention>

Additionally, the state transition matrix $bold(P) in RR^(3 times 3)$ between relation latent modes is given by:

$ bold(P) = mat(
  0.72, 0.18, 0.10;
  0.15, 0.65, 0.20;
  0.08, 0.22, 0.70;
) $ <eq:matrix>

As shown in @eq:objective and @eq:attention, the joint formulation ensures that both local semantic fidelity and global geometric invariants are preserved.

= Methodology <sec:method>

== System Architecture

The overall pipeline of the proposed architecture is shown in @fig:pipeline. The input graph first undergoes type-specific feature projection, followed by a multi-hop relational aggregator, and culminates in a structural decoding head.

#figure(
  rect(width: 95%, stroke: 0.8pt + rgb(180, 195, 220), fill: rgb(248, 250, 254), radius: 4pt)[
    #v(6pt)
    #grid(
      columns: (1fr, 30pt, 1.2fr, 30pt, 1fr),
      align: horizon + center,
      [
        #block(fill: rgb(220, 230, 248), inset: 8pt, radius: 3pt, width: 90%)[
          #text(weight: "semibold", size: 9pt)[Input Graph]\
          $cal(G) = (cal(V), cal(E))$\
          #text(size: 7.5pt, fill: luma(80))[Multi-relational HIN]
        ]
      ],
      [#text(size: 14pt)[$arrow.r$]],
      [
        #block(fill: rgb(215, 238, 225), inset: 8pt, radius: 3pt, width: 90%)[
          #text(weight: "semibold", size: 9pt)[Relational Encoder]\
          $bold(H)^(l+1) = sigma(bold(cal(M)) bold(H)^l bold(W))$\
          #text(size: 7.5pt, fill: luma(80))[Multi-Head Tensor Attention]
        ]
      ],
      [#text(size: 14pt)[$arrow.r$]],
      [
        #block(fill: rgb(252, 235, 215), inset: 8pt, radius: 3pt, width: 90%)[
          #text(weight: "semibold", size: 9pt)[Task Decoders]\
          Link & Entity Prediction\
          #text(size: 7.5pt, fill: luma(80))[Cross-Entropy + $cal(R)(bold(cal(A)))$]
        ]
      ]
    )
    #v(6pt)
  ],
  caption: [End-to-end processing pipeline of the proposed representation learning framework.],
) <fig:pipeline>

== Algorithmic Procedure

The training procedure is summarized in @lst:algo. The model was implemented in Python 3.12 @PythonManual2024 with the Typst markup typesetting documentation ecosystem @Typst2024Docs.

#figure(
  ```python
  import torch
  import torch.nn as nn

  class HeteroConvLayer(nn.Module):
      def __init__(self, in_dim: int, out_dim: int, num_relations: int):
          super().__init__()
          self.rel_weights = nn.Parameter(
              torch.randn(num_relations, in_dim, out_dim) * 0.02
          )
          self.attn = nn.Linear(2 * out_dim, 1)
          self.leaky_relu = nn.LeakyReLU(0.2)

      def forward(self, h: torch.Tensor, adj_tensor: torch.Tensor) -> torch.Tensor:
          # Compute relation-specific message transformations
          out = torch.zeros_like(h)
          for r in range(adj_tensor.shape[-1]):
              h_r = torch.matmul(h, self.rel_weights[r])
              adj_r = adj_tensor[..., r]
              out += torch.matmul(adj_r, h_r)
          return torch.relu(out)
  ```,
  caption: [PyTorch implementation snippet of the multi-relational convolution layer.],
) <lst:algo>

= Experimental Setup <sec:experiments>

To rigorously evaluate the proposed method, we compare against widely adopted state-of-the-art baselines.

== Experimental Environment and Datasets

All experiments were executed on an enterprise Linux workstation. The parameter configurations and operational environment are detailed in @tab:setup.

#figure(
  table(
    columns: (1.2fr, 1.5fr, 1fr, 2fr),
    align: (left, left, center, left),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      [*Component*], [*Specification*], [*Unit*], [*Details / Version*],
    ),
    table.hline(stroke: 0.6pt),
    [Processor], [AMD EPYC 7763 64-Core], [GHz], [2.45 base, 3.50 boost],
    [Accelerator], [4 $times$ NVIDIA A100 SXM4], [GB], [80 HBM2e per device],
    [System Memory], [512 DDR4-3200 ECC], [GB], [8-channel configuration],
    [Operating System], [Ubuntu Server 22.04 LTS], [—], [Kernel 5.15.0-generic],
    [Software Stack], [PyTorch 2.3 + CUDA 12.1], [—], [CUDNN 8.9 accelerated],
    [Batch Size], [2048], [samples], [Distributed Data Parallel],
    [Learning Rate], [$1.0 times 10^(-3)$], [—], [Cosine decay with warmup],
    table.hline(stroke: 1.2pt),
  ),
  caption: [Computational infrastructure and experimental hyperparameter configuration.],
) <tab:setup>

= Results and Comparative Analysis <sec:results>

We compare our method with classic and recent baselines. Results are recorded across five independent runs with distinct random seeds.

== Benchmark Performance

@tab:bench provides a comprehensive performance summary across link prediction and node classification tasks.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center, center),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      table.cell(rowspan: 2, align: horizon)[*Model*],
      table.cell(colspan: 2)[*Link Prediction*],
      table.cell(colspan: 3)[*Node Classification*],
      table.hline(stroke: 0.4pt),
      [*MRR* (%)], [*Hits\@10* (%)], [*Accuracy* (%)], [*Macro-F1* (%)], [*Time* (s/epoch)],
    ),
    table.hline(stroke: 0.6pt),
    [DeepWalk], [42.3 $plus.minus$ 0.4], [61.8 $plus.minus$ 0.5], [68.4 $plus.minus$ 0.3], [65.2 $plus.minus$ 0.4], [14.2],
    [GCN], [48.7 $plus.minus$ 0.3], [69.2 $plus.minus$ 0.4], [74.5 $plus.minus$ 0.2], [72.1 $plus.minus$ 0.3], [18.6],
    [GAT], [52.1 $plus.minus$ 0.2], [73.4 $plus.minus$ 0.3], [78.2 $plus.minus$ 0.2], [76.9 $plus.minus$ 0.3], [26.4],
    [RGCN], [55.6 $plus.minus$ 0.3], [77.8 $plus.minus$ 0.2], [81.0 $plus.minus$ 0.3], [79.8 $plus.minus$ 0.2], [32.1],
    [HGT], [58.4 $plus.minus$ 0.2], [81.5 $plus.minus$ 0.3], [83.6 $plus.minus$ 0.2], [82.4 $plus.minus$ 0.2], [37.8],
    table.hline(stroke: 0.4pt),
    [*Proposed*], [*64.7* $plus.minus$ *0.2*], [*88.9* $plus.minus$ *0.2*], [*89.4* $plus.minus$ *0.1*], [*88.6* $plus.minus$ *0.2*], [*24.5*],
    table.hline(stroke: 1.2pt),
  ),
  caption: [Comparative performance evaluation on benchmark heterogeneous graphs. Boldface indicates the top-performing model.],
) <tab:bench>

As observed in @tab:bench, our model consistently surpasses all competing architectures across both relational and attribute-oriented evaluation metrics.

// Full-width figure spanning both columns (demonstrating the full-width function)
#full-width[
  #figure(
    table(
      columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center, center, center, center),
      stroke: none,
      table.hline(stroke: 1.2pt),
      table.header(
        table.cell(rowspan: 2, align: horizon)[*Model*],
        table.cell(colspan: 3)[*Dataset A*],
        table.cell(colspan: 3)[*Dataset B*],
        table.hline(stroke: 0.4pt),
        [*Prec.*], [*Rec.*], [*F1*], [*Prec.*], [*Rec.*], [*F1*],
      ),
      table.hline(stroke: 0.6pt),
      [GCN],      [74.2], [71.8], [73.0], [69.5], [67.2], [68.3],
      [GAT],      [78.5], [76.1], [77.3], [73.8], [72.4], [73.1],
      [HGT],      [82.1], [80.7], [81.4], [78.6], [77.3], [77.9],
      [*Proposed*], [*88.3*], [*87.1*], [*87.7*], [*85.2*], [*84.6*], [*84.9*],
      table.hline(stroke: 1.2pt),
    ),
    caption: [Cross-dataset generalization evaluation (full-width table spanning both columns).],
  ) <tab:cross>
]

== Convergence and Training Dynamics

The loss trajectories and learning dynamics are illustrated in @fig:dynamics.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    rect(width: 100%, height: 3.5cm, fill: rgb(245, 247, 252), stroke: 0.5pt + rgb(180, 195, 220))[
      #align(center + horizon)[
        #text(size: 9pt, weight: "semibold")[Training vs. Validation Loss]\
        #v(4pt)
        #text(size: 8pt, fill: luma(100))[$cal(L)_("train") arrow.b 0.082 quad cal(L)_("val") arrow.b 0.094$]\
        #text(size: 7.5pt, fill: luma(120))[(Monotonic convergence achieved within 40 epochs)]
      ]
    ],
    rect(width: 100%, height: 3.5cm, fill: rgb(245, 247, 252), stroke: 0.5pt + rgb(180, 195, 220))[
      #align(center + horizon)[
        #text(size: 9pt, weight: "semibold")[Validation Macro-F1 Score]\
        #v(4pt)
        #text(size: 8pt, fill: luma(100))[Plateau at $88.6\%$ ($plus.minus 0.2\%$)]\
        #text(size: 7.5pt, fill: luma(120))[(Substantial margin over baseline GAT and RGCN)]
      ]
    ],
  ),
  caption: [Empirical training dynamics: (left) Convergence of objective loss over training epochs; (right) Evolution of validation Macro-F1 score.],
) <fig:dynamics>

== Ablation Study

To investigate the individual contribution of each component, we conduct an extensive ablation study summarized in @tab:ablation.

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      [*Variant / Component Removed*], [*MRR* (%)], [*Hits\@10* (%)], [*Accuracy* (%)], [*$Delta$ F1* (%)],
    ),
    table.hline(stroke: 0.6pt),
    [Full Proposed Framework], [64.7], [88.9], [89.4], [---],
    [w/o Topological Regularizer $cal(R)(bold(cal(A)))$], [59.1], [82.4], [84.1], [$-4.8$],
    [w/o Type-Specific Projections $bold(W)_tau$], [56.3], [79.6], [81.5], [$-7.3$],
    [w/o Relational Attention Weights $alpha_(i,j)$], [60.8], [84.7], [85.9], [$-3.1$],
    [w/o Residual Connections], [57.9], [81.2], [83.0], [$-5.7$],
    table.hline(stroke: 1.2pt),
  ),
  caption: [Ablation analysis demonstrating the effect of each structural module.],
) <tab:ablation>

= Discussion <sec:discussion>

The empirical findings from @tab:bench and @tab:ablation offer compelling insights into the interplay between topological inductive bias and parameter efficiency. Specifically, the introduction of the tensor Laplacian regularizer $cal(R)(bold(cal(A)))$ enforces an informative manifold smoothness constraint, effectively stabilizing gradient variance during backpropagation.

Nevertheless, some limitations persist:
1. *Memory Footprint on Dense Hypergraphs:* As the number of discrete edge types $|cal(T)_e|$ scales beyond $10^3$, explicit materialization of slice representations incurs quadratic complexity.
2. *Dynamic Temporal Drift:* The current formulation assumes static edge connectivity; real-world interaction graphs frequently exhibit temporal shifts.

Future research will explore quantized low-rank tensor kernels and streaming message-passing protocols to extend applicability to web-scale dynamic networks.

= Conclusion <sec:conclusion>

In this study, we introduced a principled representation learning framework for heterogeneous information networks. By marrying tensor-based relational message passing with regularized topological smoothing, our approach establishes superior representational capability and computational scalability. Comprehensive empirical evaluations confirm that our method consistently outperforms prior state-of-the-art architectures.

#acknowledgement[
  The authors would like to thank the anonymous reviewers and journal editors for their insightful feedback and constructive suggestions. We also acknowledge computing cluster support provided by the High Performance Computing Facility at Cambridge University.
]

#funding[
  This work was supported in part by the Engineering and Physical Sciences Research Council (EPSRC) under Grant No. EP/X019283/1 and the European Research Council (ERC) under the Horizon Europe Framework Programme (Grant Agreement No. 892144).
]

#credit[
  *Joanna Thorne:* Conceptualization, Methodology, Formal Analysis, Software, Writing -- Original Draft.
  *Jane Doe:* Data Curation, Validation, Software, Writing -- Review & Editing.
  *Alice Smith:* Supervision, Project Administration, Funding Acquisition, Investigation.
]

#reproduce[
  All core algorithmic implementations, mathematical derivations, hyperparameter logs, and simulation scripts required to replicate the experimental figures and tables are documented and archived under an open-source permissive license.
]

#opendata[
  The source code, preprocessed benchmark datasets, and serialized model checkpoints are publicly hosted on GitHub at #link("https://github.com/example/cupst-hetero-gnn")[https://github.com/example/cupst-hetero-gnn] and permanently archived in Zenodo (DOI: #link("https://doi.org/10.5281/zenodo.1234567")[10.5281/zenodo.1234567]).
]

#appendix[
  = Theoretical Convergence Analysis

  We provide here the formal derivation showing that the structural regularizer $cal(R)(bold(cal(A)))$ maintains bounded gradient norms under stochastic gradient descent.

  Let $f_bold(Theta)$ be $L$-Lipschitz continuous with respect to the node embedding manifold $cal(M)$. From @eq:objective and @eq:smoothness, the gradient with respect to latent representation $bold(H)_r$ is bounded by:

  $ norm(nabla_(bold(H)_r) cal(L)(bold(Theta)))_F <= L + 2 lambda_2 norm(bold(Delta)_r)_2 norm(bold(H)_r)_F $ <eq:bound>

  Since the graph Laplacian matrix $bold(Delta)_r$ has singular values bounded in $[0, 2]$, condition @eq:bound guarantees numerical stability throughout iterative optimization.

  = Supplementary Hyperparameter Details

  @tab:supp_hyperparams lists the detailed grid search bounds explored during parameter tuning.

  #figure(
    table(
      columns: (1.5fr, 1.2fr, 1.2fr, 2fr),
      align: (left, center, center, left),
      stroke: none,
      table.hline(stroke: 1.2pt),
      table.header(
        [*Hyperparameter*], [*Search Range*], [*Optimal*], [*Selection Criterion*],
      ),
      table.hline(stroke: 0.6pt),
      [Hidden Embedding Dimension $d_0$], [$\{64, 128, 256, 512\}$], [256], [Validation MRR],
      [Attention Heads $K$], [$\{2, 4, 8, 16\}$], [8], [Validation Accuracy],
      [Dropout Rate $p$], [$\{0.1, 0.2, 0.3, 0.5\}$], [0.2], [Validation Cross-Entropy],
      [Weight Decay $lambda_1$], [$10^(-5) - 10^(-2)$], [$1.0 times 10^(-4)$], [Grid Search on Cora/OGB],
      [Laplacian Penalty $lambda_2$], [$10^(-4) - 10^(-1)$], [$5.0 times 10^(-3)$], [Topological Smoothness],
      table.hline(stroke: 1.2pt),
    ),
    caption: [Supplementary hyperparameter grid search configurations.],
  ) <tab:supp_hyperparams>
]

#bibliography("references.bib", style: "apa")
