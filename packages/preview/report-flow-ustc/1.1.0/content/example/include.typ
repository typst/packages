#let GMM=[
```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler

iris = datasets.load_iris()
X = iris.data
y = iris.target

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 使用高斯混合模型（GMM）进行训练，指定组件数为 3
components = 3
covariance_types = ['spherical', 'diag', 'tied', 'full']

# 绘制不同协方差结构的结果
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for ax, cov_type in zip(axes.flatten(), covariance_types):
    # 训练高斯混合模型
    gmm = GaussianMixture(n_components=components, covariance_type=cov_type, random_state=42)
    gmm.fit(X_scaled)

    # 获取高斯分布的均值、协方差和权重
    means = gmm.means_
    covariances = gmm.covariances_
    weights = gmm.weights_

    print(f"协方差类型: {cov_type}")
    print(f"均值:\n{means}")
    print(f"协方差:\n{covariances}")
    print(f"权重: {weights}")
    print("=" * 50)

    # 预测每个数据点的类别
    y_pred = gmm.predict(X_scaled)

    # 绘制分类结果
    ax.scatter(X_scaled[:, 0], X_scaled[:, 1], c=y_pred, cmap='viridis', s=30, alpha=0.5)
    ax.set_title(f'GMM with {cov_type} covariance')
    ax.set_xlabel('Sepal Length (scaled)')
    ax.set_ylabel('Sepal Width (scaled)')

plt.tight_layout()
plt.show()
```
]

#let GMMbash=[
  ```plaintext
协方差类型: spherical
均值:
[[0.48614091 -0.4396551  0.63218546 0.6094997 ]
 [-0.81321705 1.32625839 -1.28660629 -1.21897299]
 [-1.37900547 0.0679585 -1.33604856 -1.33094464]]
协方差:
[0.46618439 0.13209848 0.03420828]
权重: [0.67333898 0.21762501 0.10903601]
=================================================
协方差类型: diag
均值:
[[0.62101689 -0.30677282 0.73355588 0.72043074]
 [-1.01457897 0.85326268 -1.30498732 -1.25489349]
 [-0.53089805 -1.52078822 -0.08750197 -0.2213797 ]]
协方差:
[[0.55620527 0.47846229 0.17143597 0.25540919]
 [0.17877068 0.74619275 0.00954905 0.01885974]
 [0.19473758 0.18732099 0.03531981 0.00388133]]
权重: [0.60084734 0.33333333 0.06581933]
=================================================
协方差类型: tied
均值:
[[0.50730616 -0.42662289 0.65250696 0.62745616]
 [-0.88956053 1.1589738 -1.30013187 -1.2422589 ]
[-1.29538903 0.16632199 -1.31579418 -1.28315767]]
协方差:
[[0.47360275 0.28664525 0.20928978 0.18016519]
 [0.28664525 0.56599209 0.12717949 0.1663402 ]
 [0.20928978 0.12717949 0.14849049 0.14401705]
 [0.18016519 0.1663402  0.14401705 0.21251446]]
权重: [0.66665686 0.23066374 0.1026794 ]
=================================================
协方差类型: full
均值:
[[0.53745909 -0.39369142 0.6693573 0.64500292]
 [-0.93852253 0.98617415 -1.29410958 -1.24871335]
[-1.53616188 -0.9148767 -1.05760659 -1.00758605]]
协方差:
[[[0.6041439 0.29261198 0.28890501 0.24177881]
  [0.29261198 0.53389164 0.16028899 0.21491843]
  [0.28890501 0.16028899 0.207522 0.2027757 ]
  [0.24177881 0.21491843 0.2027757 0.29967967]]

 [[0.13510948 0.19602161 0.00308347 0.01212811]
  [0.19602161 0.58216106 0.0018129 0.02637945]
  [0.00308347 0.0018129 0.00895969 0.00387616]
  [0.01212811 0.02637945 0.00387616 0.01965801]]

 [[0.1132855 -0.27943484 0.18318977 0.16256471]
[-0.27943484 0.97422493 -0.42626817 -0.39428536]
[0.18318977 -0.42626817 0.30445233 0.26469844]
[0.16256471 -0.39428536 0.26469844 0.23383281]]]
权重: [0.65376794 0.30201321 0.04421885]
=================================================
```
]

#let N2V=[
```python
import pandas as pd
import networkx as nx
from node2vec import Node2Vec
from sklearn.metrics.pairwise import cosine_similarity
import random

# 读取数据
df = pd.read_csv('Node2vec_Dataset.csv')

# 创建图
G = nx.Graph()
for _, row in df.iterrows():
    G.add_edge(row['node_1'], row['node_2'])

# 使用 Node2Vec 生成嵌入
node2vec = Node2Vec(G, dimensions=64, walk_length=30, num_walks=200, workers=4)
model = node2vec.fit()

# 获取节点嵌入值
node_embeddings = {node: model.wv[node] for node in G.nodes()}

# 将嵌入值保存为CSV文件
embedding_df = pd.DataFrame.from_dict(node_embeddings, orient='index')
embedding_df.reset_index(inplace=True)
embedding_df.columns = ['node_id'] + [f'embedding_{i}' for i in range(embedding_df.shape[1] - 1)]
embedding_df.to_csv('node_embeddings.csv', index=False)

# 计算 Betweenness Centrality 的 Jaccard 相似度
def jaccard_similarity(u, v):
    u_neighbors = set(G.neighbors(u))
    v_neighbors = set(G.neighbors(v))
    intersection = u_neighbors.intersection(v_neighbors)
    union = u_neighbors.union(v_neighbors)
    return len(intersection) / len(union) if union else 0

# 获取 10 对随机节点
pairs = random.sample(list(df.values), 10)

# 计算 Betweenness Centrality 的相似度
betweenness_similarities = [(node_u, node_v, jaccard_similarity(node_u, node_v)) for (node_u, node_v) in pairs]

# 计算嵌入向量的余弦相似度
def cosine_sim(u, v):
    return cosine_similarity([node_embeddings[u]], [node_embeddings[v]])[0][0]

embedding_similarities = [(node_u, node_v, cosine_sim(node_u, node_v)) for (node_u, node_v) in pairs]

# 输出结果
print("Betweenness Centrality Jaccard Similarities:")
for (node_u, node_v, similarity) in betweenness_similarities:
    print(f"Node pair ({node_u}, {node_v}): Jaccard Similarity = {similarity:.4f}")

print("\nNode2Vec Embedding Cosine Similarities:")
for (node_u, node_v, similarity) in embedding_similarities:
    print(f"Node pair ({node_u}, {node_v}): Cosine Similarity = {similarity:.4f}")
```
]

#let N2Vtxt=[
```plaintext
node_id,embedding_0,...,embedding_63
747,0.4846666,...,-0.24324873
```
]

#let N2Vrst=[
```
Betweenness Centrality Jaccard Similarities:
(5854, 7575): Jaccard Similarity = 0.0882
(667, 6341): Jaccard Similarity = 0.0556
(2229, 2566): Jaccard Similarity = 0.1071
(5463, 7029): Jaccard Similarity = 0.1000
(3060, 4740): Jaccard Similarity = 0.0000
(527, 4147): Jaccard Similarity = 0.1364
(1584, 6886): Jaccard Similarity = 0.3077
(2170, 5457): Jaccard Similarity = 0.0492
(2259, 5979): Jaccard Similarity = 0.0270
(4566, 6981): Jaccard Similarity = 0.0000

Node2Vec Embedding Cosine Similarities:
(5854, 7575): Cosine Similarity = 0.6807
(667, 6341): Cosine Similarity = 0.1414
(2229, 2566): Cosine Similarity = 0.3300
(5463, 7029): Cosine Similarity = 0.3630
(3060, 4740): Cosine Similarity = 0.2527
(527, 4147): Cosine Similarity = 0.2747
(1584, 6886): Cosine Similarity = 0.3698
(2170, 5457): Cosine Similarity = 0.1791
(2259, 5979): Cosine Similarity = 0.3012
(4566, 6981): Cosine Similarity = 0.2086
```  
]

#let Clustering=[
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
import seaborn as sns
import matplotlib

# 设置 matplotlib 使用支持中文的字体（例如 SimHei）
matplotlib.rcParams['font.sans-serif'] = ['SimHei']  # 指定字体为黑体
matplotlib.rcParams['axes.unicode_minus'] = False  # 正常显示负号

# 设置随机种子以确保结果可重复
np.random.seed(42)

# 生成数据集：1000个数据点，3到5个聚类
X, y = make_blobs(n_samples=1000, centers=4, random_state=42)

# 标准化数据
X = StandardScaler().fit_transform(X)

# 绘制原始数据的散点图
plt.figure(figsize=(8, 6))
sns.scatterplot(x=X[:, 0], y=X[:, 1], color='gray', alpha=0.6, label='原始数据', s=50)
plt.title('原始数据点分布', fontsize=16)
plt.xlabel('特征1', fontsize=14)
plt.ylabel('特征2', fontsize=14)
plt.grid(True)
plt.legend()
plt.show()

# 尝试 3 组 DBSCAN 的参数组合
params = [(0.2, 5), (0.5, 10), (0.8, 15)]  # 每组参数为 (ε, minPts)

for eps, min_samples in params:
    # 使用 DBSCAN 进行聚类
    dbscan = DBSCAN(eps=eps, min_samples=min_samples)
    labels = dbscan.fit_predict(X)

    # 创建聚类结果的图
    plt.figure(figsize=(8, 6))

    # 聚类的颜色显示，-1表示噪声点
    plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis', s=50, alpha=0.6)

    # 显示聚类结果
    plt.title(f'DBSCAN 聚类结果 (ε={eps}, minPts={min_samples})', fontsize=16)
    plt.xlabel('特征1', fontsize=14)
    plt.ylabel('特征2', fontsize=14)
    plt.colorbar(label='聚类标签')
    plt.grid(True)
    plt.show()

```
]