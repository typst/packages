#import "@preview/cupst:0.1.0": *

#show: cupst.with(
  title: [长江流域多源时空水文序列的深度图注意力网络建模与高精度径流预测研究],
  short-title: [长江流域水文图注意力网络建模与预测],
  
  authors: (
    (
      name: "孙娇",
      affiliation: "affi1",
      email: "j.sun@lorem.ac.uk",
      orcid: "0000-0001-2345-6789",
    ),
    (
      name: "孙娇娇",
      affiliation: ("affi1", "affi2"),
      orcid: "0000-0002-3456-7890",
    ),
    (
      name: "孙骄",
      affiliation: "affi2",
      orcid: "0000-0003-9876-5432",
    ),
  ),
  affiliations: (
    (id: "affi1", name: "滚滚学院水利工程系，长江大学，浪花市，英雄省，中华人民共和国"),
    (id: "affi2", name: "是非环境系统重点实验室，成败研究所，青山市，夕阳省，中华人民共和国"),
  ),
  
  abstract: [
    长江流域覆盖范围广阔、水系拓扑复杂、水文气象要素具有极强的空间异质性与非线性动态特征。传统分布式水文物理模型在面对多源异构遥测高频时序数据时，面临参数率定困难、计算耗时巨大以及对极端水文过程响应滞后的技术瓶颈。为此，本文提出了一种融合物理拓扑先验的深度多尺度时空图注意力网络（Spatial-Temporal Hydrological Graph Attention Network, STH-GAT）。该模型将流域拓扑水系解构为有向带权多重拓扑图，通过张量分解捕获干支流间的汇流延迟效应，并结合多头交叉注意力机制联合提取降水、土壤含水量、气温及径流量的高维表征。在长江上中游干支流36个水文控制站点的5年连续逐时实测数据集上的实证评估表明，本文提出的STH-GAT模型在纳什效率系数（NSE）上达到0.924，较主流时序基线模型平均提升11.3%，在暴雨洪峰峰现时间预测误差上降低至1.4小时以内，为流域防洪减灾与智慧调度提供了坚实的理论支持与工程算法示范。
  ],
  
  keywords: ("深度学习", "时空图神经网络", "水文预报", "径流预测", "张量分解", "注意力机制"),
  
  // Article settings
  manuscript: "article",  // article, rescience, data, software, editorial, proceedings, poster
  layout: "publish",     // preprint, publish
  paper-size: "medium",  // large (210×280mm, two-column), medium (174×247mm), small (152×228mm)
  journal: "临江水利水运学报",
  year: 2026,
  volume: 18,
  doi: "10.1000/ljxb.2026.0408",
  
  // For published articles
  received: "2024年1月15日",
  revised: "2024年3月20日",
  accepted: "2024年4月5日",
  published: "2024年4月30日",
  editor: "杨慎",
  reviewers: "匿名审稿人",
  
  // Display options
  show-line-numbers: true,
  section-numbering: true,
  structure-color: rgb(33, 63, 144),
  link-color: rgb(24, 76, 172),
  lang: "zh",

  serif-fonts: ("Linux Libertine", "Libertinus Serif", "Times New Roman", "Noto Serif CJK SC", "SimSun"),
  sans-fonts: ("Source Sans Pro", "Source Sans 3", "Arial", "Noto Sans CJK SC"),
)

= 引言 <sec:intro>

水文预报与流域水资源智能调度是保障防洪安全、水能高效利用与生态平衡的核心工程任务。水文循环系统是一个高度非线性的动态巨系统，涉及降水入渗、坡面汇流、地下水补给以及河道汇流等复杂的物理机制 @Goodfellow2016DeepLearning。传统的水文预测方法主要包含两类：一是基于机理的集总式与分布式水文模型（如新安江模型、VIC模型、SWAT模型等），二是经典时间序列统计算法（如ARIMA、自回归误差修正等）。

然而，随着气象卫星雷达网与地表高频遥测站网的建设，流域观测数据呈现出海量化、高频化与多源异构的鲜明特点 @Achiam2023GPT4。传统物理模型参数率定极其耗时，且在极端天气气候事件下由于水文边界条件发生突变而产生显著的预报衰退；而经典统计方法难以捕捉空间分布上的空间拓扑关联和长周期滞后依赖 @Vaswani2017Attention。

近年来，以深度卷积网络和残差表征为代表的深度学习模型取得了突破性进展 @He2016ResNet。在可解释性分析方面，#cite(<Selvaraju2020Grad>, form: "prose") 提出了梯度加权类激活映射技术，为高维隐空间特征响应定位提供了强有力的工具。在系统科学与复杂网络拓扑建模方面，#cite(<Huerta2016ETE>, form: "prose") 提出的谱系拓扑演化计算框架为大尺度有向树状图拓扑遍历提供了有益的数学灵感。信息论创始人香农早在其经典论著中阐明了符号逻辑与电气回路的深层同构性 @Shannon1940Thesis：

#quote(attribution: [克劳德·香农（Claude E. Shannon, 1940）#cite(<Shannon1940Thesis>)])[
  “通过引入布尔代数对中继与开关电路进行形式化分析，证明了任何能够用符号逻辑表述的命题均可通过物理系统精确计算与验证。”
]

构建兼具物理拓扑先验与数据驱动高拟合能力的混合水文智能模型，已成为现代计算水文学的前沿战略方向 @Russell2020Safety。为系统性解决上述瓶颈，本论文的主要研究贡献概括如下：
- *多重时空水文图表征：* 提出了一种基于流域拓扑关联的有向带权张量建模方法，将物理汇流关系无缝映射为图拓扑结构。
- *双通道时空注意力网络架构：* 设计了集成分层残差卷积与多头时空交叉注意力的统一深度网络，能够联合挖掘时间迟滞性与空间相关性。
- *标准化开源工程实现：* 算法实现遵循现代软件工程规范 @PythonManual2024 与数据词汇标准 @ISO2023Stats，全部排版基于新一代排版系统Typst构建 @Typst2024Docs。
- *大规模基准数据集实证：* 基于长江干支流36个控制站点连续5年实测逐时数据及公开遥感基准集合（包括标准化处理数据集 @Deng2009ImageNet）开展充分实验，验证了算法的优越性与鲁棒性。

= 数学模型与理论基础 <sec:theory>

== 流域时空拓扑图形式化定义

我们将流域内所有水文气象观测测站及主要汇水节点抽象为有向时空图 $cal(G) = (cal(V), cal(E), bold(cal(W)))$。

/ 测站节点集合 ($cal(V)$): 包含流域内的所有雨量站、水文站、水库站及区间汇流节点，总结点数为 $N = |cal(V)|$。
/ 汇流水系边集合 ($cal(E)$): 若节点 $v_i$ 处水流经过河网自然汇入节点 $v_j$，则存在一条有向边 $(v_i, v_j) in cal(E)$。
/ 拓扑加权张量 ($bold(cal(W))$): 维度为 $RR^(N times N times K)$，第 $k$ 个切片记录对应河段的物理属性（如河道坡降、汇流流程、糙率系数等）。

== 目标优化函数与拓扑平滑约束

设历史观测时序窗口长度为 $T_("in")$，预测时间步长为 $T_("out")$。令 $bold(X) in RR^(N times T_("in") times D)$ 为输入特征张量（包含降雨量、温度、土壤饱和度、历史流量等 $D$ 维观测），预测目标流量为 $bold(Y) in RR^(N times T_("out"))$。

整体联合损失函数 $cal(L)(bold(Theta))$ 包含预测拟合误差与物理拓扑一致性正则项：

$ cal(L)(bold(Theta)) = 1/N sum_(i=1)^N sum_(t=1)^(T_("out")) (y_(i, t) - hat(y)_(i, t))^2 + lambda_1 ||bold(Theta)||_2^2 + lambda_2 cal(L)_("phy")(bold(hat(Y)), bold(cal(W))) $ <eq:loss>

其中物理连续性约束项 $cal(L)_("phy")$ 依据水量平衡原理构建：

$ cal(L)_("phy") = sum_(j=1)^N (sum_(i in cal(N)_(i n)(j)) hat(y)_(i, t - tau_(i,j)) + P_(j, t) - hat(y)_(j, t))^2 $ <eq:phy_loss>

式中 $tau_(i, j)$ 表示从测站 $i$ 至测站 $j$ 的汇流滞时参数，$P_(j, t)$ 为区间净降雨入流。

空间注意力转移权重矩阵定义为：

$ alpha_(i, j) = cases(
  (exp(sigma(bold(w)^top [bold(W) h_i || bold(W) h_j]))) / (sum_(m in cal(N)_i) exp(sigma(bold(w)^top [bold(W) h_i || bold(W) h_m]))) & "若" (v_i, v_j) in cal(E),
  0 & "其他"
) $ <eq:zh_attention>

各支流水系之间的状态转移矩阵 $bold(T) in RR^(3 times 3)$ 表征为：

$ bold(T) = mat(
  0.85, 0.10, 0.05;
  0.12, 0.78, 0.10;
  0.06, 0.14, 0.80;
) $ <eq:zh_matrix>

如 @eq:loss 与 @eq:zh_attention 所示，该损失函数既能有效约束网络拟合精度，又保证了输出结果满足基本的水量守恒定律。

= 模型架构与算法实现 <sec:method>

== 模型总体拓扑流水线

本文提出的STH-GAT网络架构由时序特征提取层、拓扑图注意力汇聚层与自适应物理输出头组成，其数据处理流程如 @fig:model 所示。

#figure(
  rect(width: 95%, stroke: 0.8pt + rgb(180, 195, 220), fill: rgb(248, 250, 254), radius: 4pt)[
    #v(6pt)
    #grid(
      columns: (1.1fr, 24pt, 1.3fr, 24pt, 1.1fr),
      align: horizon + center,
      [
        #block(fill: rgb(220, 230, 248), inset: 8pt, radius: 3pt, width: 92%)[
          #text(weight: "semibold", size: 9pt)[多源气象水文输入]\
          $bold(X) in RR^(N times T times D)$\
          #text(size: 7.5pt, fill: luma(80))[雨量、流量、土壤水]
        ]
      ],
      [#text(size: 14pt)[$arrow.r$]],
      [
        #block(fill: rgb(215, 238, 225), inset: 8pt, radius: 3pt, width: 92%)[
          #text(weight: "semibold", size: 9pt)[时空图注意力编码器]\
          $bold(H)^(l+1) = "STH-GAT"(bold(H)^l, bold(cal(W)))$\
          #text(size: 7.5pt, fill: luma(80))[多头汇流有向注意力机制]
        ]
      ],
      [#text(size: 14pt)[$arrow.r$]],
      [
        #block(fill: rgb(252, 235, 215), inset: 8pt, radius: 3pt, width: 92%)[
          #text(weight: "semibold", size: 9pt)[水量守恒解码输出]\
          $bold(hat(Y)) in RR^(N times T_("out"))$\
          #text(size: 7.5pt, fill: luma(80))[纳什系数最优化预报]
        ]
      ]
    )
    #v(6pt)
  ],
  caption: [STH-GAT时空图注意力流域水文预报系统总体流水线拓扑图。],
) <fig:model>

== 核心算法实现

模型基于PyTorch深度学习框架进行开发 @PythonManual2024。关键图注意力更新步骤代码实现如 @lst:hydro_code 所示。

#figure(
  ```python
  import torch
  import torch.nn as nn
  import torch.nn.functional as F

  class HydrologicalGraphAttention(nn.Module):
      """流域拓扑水文图注意力聚合层"""
      def __init__(self, in_features: int, out_features: int, num_heads: int = 4):
          super().__init__()
          self.num_heads = num_heads
          self.out_features = out_features
          self.fc_weight = nn.Linear(in_features, num_heads * out_features, bias=False)
          self.attn_kernel = nn.Parameter(torch.empty(size=(num_heads, 2 * out_features)))
          nn.init.xavier_uniform_(self.attn_kernel.data, gain=1.414)
          self.leaky_relu = nn.LeakyReLU(0.2)

      def forward(self, h: torch.Tensor, adj_sparse: torch.Tensor) -> torch.Tensor:
          # h: [Batch, Nodes, Features]
          b, n, _ = h.shape
          proj = self.fc_weight(h).view(b, n, self.num_heads, self.out_features)
          # 拓扑稀疏矩阵乘法聚合下游测站特征
          out = torch.einsum("bijh, bjhk -> bihk", adj_sparse, proj)
          return F.elu(out.reshape(b, n, -1))
  ```,
  caption: [水文时空图注意力聚合核心代码实现。],
) <lst:hydro_code>

= 实验设计与评估环境 <sec:exp_setup>

== 实验平台配置与观测参数

所有实验均在高性能异构计算平台上执行，测站观测设备与超参数配置见 @tab:params。

#figure(
  table(
    columns: (1.2fr, 1.5fr, 1fr, 2fr),
    align: (left, left, center, left),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      [*配置项*], [*参数规格*], [*物理量纲*], [*详细说明*],
    ),
    table.hline(stroke: 0.6pt),
    [水文测站节点数], [36], [个], [涵盖干流控制站与主要支流入汇口],
    [数据采集频率], [1], [小时/次], [5年逐时连续遥测序列],
    [输入时序步长 $T_("in")$], [72], [小时], [前溯3天降雨与流量演变过程],
    [预报预见期 $T_("out")$], [24], [小时], [未来24小时滚动流量预报],
    [计算加速芯片], [4 $times$ NVIDIA RTX 4090], [GB], [单卡24GB GDDR6X显存],
    [优化求解器], [AdamW], [—], [权重衰减系数 $1.0 times 10^(-4)$],
    [初始学习率], [$5.0 times 10^(-4)$], [—], [余弦退火学习率动态衰减策略],
    table.hline(stroke: 1.2pt),
  ),
  caption: [长江流域水文数据集与计算平台配置参数表。],
) <tab:params>

= 结果与对比分析 <sec:results>

== 基准模型综合性能对比

为全面验证模型的预测能力，我们选取了经典物理概念模型、时序神经网络（LSTM、GRU）以及时空图模型（STGCN、GWNet、HGT）作为对照基准。评估指标包含纳什效率系数（NSE）、相对径流深误差（PBIAS，%）、均方根误差（RMSE， $m^3/s$）以及峰现时间误差（$Delta T_p$，小时）。

结果汇总于 @tab:results。

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1.1fr),
    align: (left, center, center, center, center, center),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      table.cell(rowspan: 2, align: horizon)[*模型名称*],
      table.cell(colspan: 2)[*精度评估指标*],
      table.cell(colspan: 2)[*洪峰预报指标*],
      table.cell(rowspan: 2, align: horizon)[*单步推理耗时*\ (毫秒)],
      table.hline(stroke: 0.4pt),
      [*NSE* ($arrow.t$)], [*PBIAS* (%)], [*RMSE* ($m^3/s$)], [*$Delta T_p$* (h)],
    ),
    table.hline(stroke: 0.6pt),
    [新安江模型], [0.762], [$+8.4$], [148.5], [4.2], [---],
    [LSTM], [0.812], [$-6.1$], [128.2], [3.5], [1.8],
    [Bi-GRU], [0.825], [$-5.4$], [122.9], [3.1], [2.1],
    [STGCN], [0.864], [$+3.8$], [105.4], [2.4], [5.6],
    [Graph WaveNet], [0.887], [$-2.9$], [96.7], [2.0], [8.4],
    [HGT], [0.895], [$-2.4$], [91.3], [1.8], [11.2],
    table.hline(stroke: 0.4pt),
    [*STH-GAT (本文)*], [*0.924*], [*+1.2*], [*78.6*], [*1.4*], [*6.8*],
    table.hline(stroke: 1.2pt),
  ),
  caption: [长江流域36个控制站点24小时流量预报性能对比（粗体表示最优表现）。],
) <tab:results>

如 @tab:results 所示，本文提出的 STH-GAT 模型不仅在综合纳什效率系数（NSE）上达到0.924的高精度水平，而且在洪峰峰现时间误差上相较于经典物理模型提升超过66%，显著优于各基准深度学习架构。

== 训练曲线与收敛动态

模型在训练集与验证集上的收敛轨迹如 @fig:curves 所示。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    rect(width: 100%, height: 3.5cm, fill: rgb(245, 247, 252), stroke: 0.5pt + rgb(180, 195, 220))[
      #align(center + horizon)[
        #text(size: 9pt, weight: "semibold")[训练与验证损失收敛轨迹]\
        #v(4pt)
        #text(size: 8pt, fill: luma(100))[$cal(L)_("train") arrow.b 0.041 quad cal(L)_("val") arrow.b 0.052$]\
        #text(size: 7.5pt, fill: luma(120))[前30轮次快速收敛，无过拟合现象]
      ]
    ],
    rect(width: 100%, height: 3.5cm, fill: rgb(245, 247, 252), stroke: 0.5pt + rgb(180, 195, 220))[
      #align(center + horizon)[
        #text(size: 9pt, weight: "semibold")[纳什效率系数(NSE)迭代演变]\
        #v(4pt)
        #text(size: 8pt, fill: luma(100))[最终稳定于 $0.924 plus.minus 0.003$]\
        #text(size: 7.5pt, fill: luma(120))[大幅超越单站LSTM与传统物理模型]
      ]
    ],
  ),
  caption: [STH-GAT模型训练动态分析：（左）均方误差损失迭代收敛曲线；（右）验证集纳什效率系数动态增长曲线。],
) <fig:curves>

== 模块消融实验

为了量化各设计模块对系统预测精度的贡献度，我们设计了消融实验方案，结果如 @tab:ablation 所示。

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1.2fr),
    align: (left, center, center, center),
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header(
      [*模型配置变体*], [*NSE* ($arrow.t$)], [*RMSE* ($m^3/s$)], [*$Delta$ NSE* (%)],
    ),
    table.hline(stroke: 0.6pt),
    [完整STH-GAT模型], [0.924], [78.6], [基准],
    [移除物理水量守恒项 $cal(L)_("phy")$], [0.881], [98.4], [$-4.65$],
    [移除拓扑空间注意力机制 $alpha_(i,j)$], [0.865], [104.7], [$-6.38$],
    [移除多尺度时间卷积模块], [0.874], [101.2], [$-5.41$],
    [以静态无权邻接矩阵替代加权张量 $bold(cal(W))$], [0.852], [112.5], [$-7.79$],
    table.hline(stroke: 1.2pt),
  ),
  caption: [关键网络结构模块消融实验对比结果表。],
) <tab:ablation>

= 讨论 <sec:discussion>

消融实验结果（@tab:ablation）表明，引入拓扑加权张量 $bold(cal(W))$ 与物理水量连续性损失 $cal(L)_("phy")$ 是保持大流域长链条汇流精度的关键支柱。当水库调蓄导致自然水文过程遭到人为扰动时，纯数据驱动网络往往出现虚假关联，而物理拓扑约束有效避免了非物理负流量的产生。

本研究仍存在以下局限性需要后续深化：
1. 流域下垫面变化对水文参数具有长期缓慢改变效应，当前静态拓扑权重尚未融入时间演进特征。
2. 缺乏对突发溃坝、泥石流等极端稀有灾害过程的在线迁移泛化能力。

= 结论 <sec:conclusion>

针对长江流域多源时空水文序列的高精度实时预报难题，本文提出并验证了融合物理拓扑先验的深度图注意力网络STH-GAT。通过多源遥测数据与拓扑张量的深度交互，该模型在显著提高纳什效率系数（达到0.924）的同时，将洪峰预测时差误差缩短至1.4小时以内。

#acknowledgement[
  感谢长江水文局与临江水资源研究所提供的高精度实测序列与数字化高程网格数据。感谢评审专家提出的宝贵修改意见。
]

#funding[
  本研究得到国家自然科学基金重大研究计划（资助号：52079001）、浪花省水利科技创新重点攻关专项（项目编号：2024-SL-03）的联合资助。
]

#credit[
  *孙娇*： 论文构思、总体方案设计、理论数学建模、论文初稿撰写；
  *孙娇娇*： 观测数据集清洗、算法程序编写、消融对比实验分析、图表绘制；
  *孙骄*： 研究监督、资金申请、关键技术指导、论文最终审核与修订。
]

#reproduce[
  本文所构建的数学公式推导、模型训练代码、验证集超参数配置文件及绘图自动化脚本均已整理为标准可重现代码包，并提供统一的测试用例驱动。
]

#opendata[
  本研究所使用的脱敏水文拓扑矩阵、基准预报代码库及预训练检查点已公开发布于开源平台：
  #link("https://github.com/example/sth-gat-hydro")[https://github.com/example/sth-gat-hydro]。
]

#appendix[
  = 汇流守恒正则项收敛性数学推导

  设区间水体体积满足连续性微分方程 $dif V / (dif t) = I(t) - Q(t)$。根据离散化时间有限差分格式：

  $ V_(t+1) - V_t = Delta t (I_t - Q_t) $ <eq:app_diff>

  定义第 $j$ 节点的储量状态变量 $S_j(t) = k_j Q_j^m(t)$。对式 @eq:app_diff 展开一阶泰勒级数，可得误差能量函数在梯度下降法下的单调有界性，证明过程保证了目标优化函数 @eq:loss 在梯度反向传播过程中的数值稳定性。

  = 补充超参数搜索配置

  实验阶段超参数调优网格范围见 @tab:zh_supp_params。

  #figure(
    table(
      columns: (1.5fr, 1.2fr, 1.2fr, 2fr),
      align: (left, center, center, left),
      stroke: none,
      table.hline(stroke: 1.2pt),
      table.header(
        [*超参数名称*], [*搜索空间*], [*选定最优值*], [*评估依据*],
      ),
      table.hline(stroke: 0.6pt),
      [隐层特征维度 $d$], [$\{32, 64, 128, 256\}$], [128], [验证集NSE得分],
      [注意力头数 $K$], [$\{2, 4, 8, 16\}$], [4], [洪峰峰现时间误差],
      [丢弃率 (Dropout)], [$\{0.1, 0.2, 0.3, 0.5\}$], [0.2], [防止过拟合],
      [物理损失权重 $lambda_2$], [$10^(-3) - 10^0$], [$1.0 times 10^(-2)$], [水量平衡误差指标],
      table.hline(stroke: 1.2pt),
    ),
    caption: [补充超参数搜索空间及最优配置表。],
  ) <tab:zh_supp_params>
]

#bibliography("references.bib", style: "apa")
