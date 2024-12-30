#import "@preview/report-flow-ustc:1.1.0": *
#import "./include.typ": *

#show: project.with(
  course: "计算机系统",
  lab_name: "位运算实验",
  stu_name: "顶针",
  stu_num: "SA114514",
  major: "计算机科学与技术",
  department: "计算机科学与技术学院",
  date: (2024, 10, 1),
  show_content_figure: true,
//   text_font: ("STSong"),
//   text_size: 10pt,
//   code_font: ("Jetbrains Mono NL","PingFang SC"),
//   code_size: 8pt,
//   primary: rgb("#004098"),
//   secondary: rgb("#004098"),
//   watermark: "USTC",
//   alpha:94.12%,
//   watermark_font:("Times New Roman"),
//   watermark_size: 240pt,
)

//#set text(size:9pt)

= 计算题

== 

#block(
    fill: rgb("#0000000f"),    
    radius: 10pt,
    inset: 1em,
    width: 100%,)[
基于如下数据集（⼆维），分别使⽤Manhattan和Euclidean距离，计算DBSCAN聚类结果，并标出core points、border points 和 noise points。使⽤如下参数𝜀 = 1.1，𝑚𝑖𝑛𝑃𝑡𝑠 = 2。并讨论两种距离的优劣。 

#figure(
  image("./img/points.svg")
)
]

*Manhattan*

*Cluster1*
#grid(
    columns: 2,
    gutter: 4.5em,
    [
- 点A
    - ε 邻域内的点:B, C
    - core ponint 
- 点B
    - ε 邻域内的点:A, D
    - core ponint 
    ],[
- 点C
    - ε 邻域内的点:A, D
    - core ponint 
- 点D
    - ε 邻域内的点:B, C
    - core ponint 
    ]
)


*Cluster2*
#grid(
    columns: 2,
    gutter: 3em,
    [
- 点E
    - ε 邻域内的点:I, G
    - core ponint 
- 点G
    - ε 邻域内的点:E, F, J, H
    - core ponint 
- 点F
    - ε 邻域内的点:G
    - core ponint 
- 点H
    - ε 邻域内的点:G
    - core ponint 
    ],[
- 点I
    - ε 邻域内的点:E, J, K
    - core ponint 
- 点J
    - ε 邻域内的点:I, G
    - core ponint 
- 点K
    - ε 邻域内的点:I, L
    - core ponint 
- 点L
    - ε 邻域内的点:K
    - core ponint 
    ])


*Cluster3*
#grid(
    columns: 2,
    gutter: 4.5em,
    [
- 点O
    - ε 邻域内的点:P
    - core ponint 
- 点P
    - ε 邻域内的点:O, Q
    - core ponint 
    ],[
- 点Q
    - ε 邻域内的点:P, R
    - core ponint 
- 点R
    - ε 邻域内的点:Q
    - core ponint 
    ])


*noise points*
- 点M, N, S, T

*Euclidean*下结果不变，因为数据点的最近的邻居的Euclidean距离为$1$和$sqrt(2)$, 都小于$epsilon = 1.1$。

== 

#block(
    fill: rgb("#0000000f"),    
    radius: 10pt,
    inset: 1em,
    width: 100%,)[
在课上讨论的Gaussian Mixture Model 和 Multinomial Mixture Model 的基础上，写出Bernoulli Mixture Model 的定义和其对应EM算法的详细过程。
]

*定义:*

Bernoulli Mixture Model是用于处理特征只能取值0或1的数据的概率模型。该模型假设数据是由多个伯努利分布的混合生成的，每个混合成分对应一个伯努利分布。

设有观测数据集 #mi(`\mathbf{X} = \{ \mathbf{x}_1, \mathbf{x}_2, \dots, \mathbf{x}_N \}`)，其中每个数据点 #mi(`\mathbf{x}_n`) 是维度为 #mi(`D`) 的二元向量，#mi(`\mathbf{x}_n \in \{0,1\}^D`)。伯努利混合模型假设存在 #mi(`K`) 个潜在的伯努利分布成分，每个成分 #mi(`k`) 由参数 #mi(`\boldsymbol{\mu}_k = (\mu_{k1}, \mu_{k2}, \dots, \mu_{kD})`) 描述，其中 #mi(`\mu_{kd}`) 表示第 #mi(`k`) 个成分在第 #mi(`d`) 个维度上取值为1的概率。混合系数 #mi(`\pi_k`) 表示选择第 #mi(`k`) 个成分的概率，满足 #mi(`\sum_{k=1}^K \pi_k = 1`)。

*模型生成过程*

对于每个数据点 #mi(`\mathbf{x}_n`)：

1. 从分类分布 #mi(`\text{Categorical}(\pi_1, \pi_2, \dots, \pi_K)`) 中选择一个隐变量 #mi(`z_n \in \{1, 2, \dots, K\}`)，表示选择的成分。
2. 给定 #mi(`z_n`)，在每个维度 #mi(`d`) 上，根据伯努利分布生成
   #mitex(`x_{nd}: p(x_{nd} | z_n) = \mu_{z_n d}^{x_{nd}} (1 - \mu_{z_n d})^{1 - x_{nd}}`)

联合概率分布为：  
#mitex(`p(\mathbf{x}_n, z_n) = \pi_{z_n} \prod_{d=1}^D \mu_{z_n d}^{x_{nd}} (1 - \mu_{z_n d})^{1 - x_{nd}}`)

边缘概率分布为：  
#mitex(`p(\mathbf{x}_n) = \sum_{k=1}^K \pi_k \prod_{d=1}^D \mu_{k d}^{x_{nd}} (1 - \mu_{k d})^{1 - x_{nd}}`)

*EM算法过程*

EM算法用于在给定观测数据 #mi(`\mathbf{X}`) 的情况下，估计模型参数 #mi(`\Theta = \{\pi_k, \boldsymbol{\mu}_k\}_{k=1}^K`)。算法通过交替执行期望步骤（E步）和最大化步骤（M步）来迭代更新参数。

1. 初始化
- 随机初始化混合系数 #mi(`\pi_k`)，满足 #mi(`\sum_{k=1}^K \pi_k = 1`)。
- 随机初始化伯努利参数 #mi(`\boldsymbol{\mu}_k \in [0,1]^D`)。

2. 迭代过程

重复以下步骤直到收敛：

- E步（期望步）
计算每个数据点 #mi(`\mathbf{x}_n`) 属于第 #mi(`k`) 个成分的后验概率（责任） #mi(`\gamma_{nk}`)：  
#mitex(`\gamma_{nk} = p(z_n = k | \mathbf{x}_n, \Theta) = \frac{\pi_k \prod_{d=1}^D \mu_{k d}^{x_{nd}} (1 - \mu_{k d})^{1 - x_{nd}}}{\sum_{j=1}^K \pi_j \prod_{d=1}^D \mu_{j d}^{x_{nd}} (1 - \mu_{j d})^{1 - x_{nd}}}`)
为了数值稳定性，通常在对数空间进行计算：

1) 计算未归一化的对数概率：  
   #mitex(`\ln \tilde{\gamma}_{nk} = \ln \pi_k + \sum_{d=1}^D [x_{nd} \ln \mu_{k d} + (1 - x_{nd}) \ln (1 - \mu_{k d})]`)
2) 通过指数化和归一化得到 #mi(`\gamma_{nk}`)：  
   #mitex(`\gamma_{nk} = \frac{\exp(\ln \tilde{\gamma}_{nk})}{\sum_{j=1}^K \exp(\ln \tilde{\gamma}_{nj})}`)

- M步（最大化步）

更新模型参数 #mi(`\pi_k`) 和 #mi(`\boldsymbol{\mu}_k`)：

1) 更新混合系数 #mi(`\pi_k`)：  
   #mi(`\pi_k^{\text{new}} = \frac{1}{N} \sum_{n=1}^N \gamma_{nk}`)

2) 更新伯努利参数 #mi(`\mu_{k d}`)：  
   #mi(`\mu_{k d}^{\text{new}} = \frac{\sum_{n=1}^N \gamma_{nk} x_{nd}}{\sum_{n=1}^N \gamma_{nk}}`)

3. 收敛判定

计算完整数据的对数似然函数 #mi(`\ln p(\mathbf{X} | \Theta)`)，如果对数似然的增量小于预设阈值，则认为算法收敛。

对数似然函数为：  
#mitex(`\ln p(\mathbf{X} | \Theta) = \sum_{n=1}^N \ln \left( \sum_{k=1}^K \pi_k \prod_{d=1}^D \mu_{k d}^{x_{nd}} (1 - \mu_{k d})^{1 - x_{nd}} \right)`)

= 编程题

== 

#block(
    fill: rgb("#0000000f"),    
    radius: 10pt,
    inset: 1em,
    width: 100%,)[
*高斯混合模型与 EM 算法*

数据集: Iris 数据集  

数据描述: #link("https://www.kaggle.com/datasets/uciml/iris"), 可通过 sklearn 直接导入数据集  

```python
from sklearn import datasets  
iris = datasets.load_iris()
```  

任务描述: 使用高斯混合模型与 EM 算法对数据进行分类计算，mixture components 设置为 3。  

要求输出: 不同高斯分布的 mean 和 variance，每个高斯分布对应的权重，plot 出分布的图。  
EM 算法可以参考#link("https://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html")[https://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html] 

Optional: 尝试不同的 covariance structures，包括 spherical、diagonal、tied 与 full。

]

#GMM

#codly(number-format: none)
#GMMbash
#codly(number-format: (n)=>[#n])

#figure(
    image("img/gmm.svg",width: 115%),
    caption: [不同covariance structures的结果]
)

== 

#block(
    fill: rgb("#0000000f"),    
    radius: 10pt,
    inset: 1em,
    width: 100%,)[
*Node2vec*  

数据集: Node2vec_Dataset.csv。

任务描述: 利用 Node2vec 计算每个节点的 embedding 值。  

要求输出:  
1. 每个节点的 embedding 值列表（csv 文件）；  
2. 随机挑选 10 个 node pair，对比它们在 embedding 上的相似度和在 betweenness centrality 上的相似度（使用 Jaccard similarity）。
]

#N2V

`node_embeddings.csv`文件内容示例：

#N2Vtxt

result:
#codly(number-format: none)
#N2Vrst
#codly(number-format: (n)=>[#n])

== 

#block(
    fill: rgb("#0000000f"),    
    radius: 10pt,
    inset: 1em,
    width: 100%,)[
*Clustering*  
数据集：使用 Make_blobs 生成数据不少于 1000 个 data points，以 3-5 个 cluster 为宜。  
#link("https://scikit-learn.org/dev/modules/generated/sklearn.datasets.make_blobs.html#sklearn.datasets.make_blobs")[https://scikit-learn.org/dev/modules/generated/sklearn.datasets.make_blobs.html#sklearn.datasets.make_blobs]

任务描述：利用 DBSCAN 算法计算数据的聚类。  
要求输出：  
- 原始数据 plot 的图像和聚类后的结果。  
- 尝试不少于三组 \(\varepsilon\)，\(minPts\) 的参数组合。
]

#Clustering

#figure(
    image("img/clst0.svg",width: 120%),
    caption: [原始数据]
)

#figure(
    image("img/clst1.svg",width: 120%),
    caption: [聚类结果1:$epsilon=0.2,"minPts"=5$]
)

#figure(
    image("img/clst2.svg",width: 120%),
    caption: [聚类结果2:$epsilon=0.5,"minPts"=10$]
)

#figure(
    image("img/clst3.svg",width: 120%),
    caption: [聚类结果3:$epsilon=0.8,"minPts"=15$]
)