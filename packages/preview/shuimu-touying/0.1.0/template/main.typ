#import "@preview/shuimu-touying:0.1.0": *
//#import "../lib.typ": *

#show: shuimu-touying-theme.with(
  config-info(
    title: [Rust 机器学习与工业视觉],
    subtitle: [基于 YOLO 和线阵相机的缺陷检测系统],
    author: [陈海翔（CHEN MASON）],
    date: datetime.today(),
    institution: [清华大学社科学院经济学研究所],
  ),
)

#title-slide()

#outline-slide()

= 项目背景

== 工业场景痛点

我们在木材缺陷检测中面临以下挑战：

- 数据量巨大：线阵相机生成的图片尺寸高达 $2800 times 1024$ 或更长。
- 实时性要求：传统的 Python 推理速度难以满足工业流水线需求。
- 环境复杂：需要精确控制白平衡和伽马校正。

#tblock(title: "核心目标")[
  利用 Rust 的内存安全特性和 CUDA 加速能力，构建一套高吞吐量的视觉识别系统。
]

//#new-section-slide(title: "技术架构")[11]

= 技术栈选择

== 为什么选择 Rust?

1. 零成本抽象：在不牺牲性能的前提下提供高级语言特性。
2. 所有权机制：避免了 C++ 中常见的内存泄漏问题。
3. 生态系统：
   - tch-rs (Libtorch 绑定)
   - ort (ONNX Runtime)
   - candle (Hugging Face 的 Rust ML 框架)

== 关键代码示例
- Rust代码示例
#lorem(80)

= YOLO 模型集成
== YOLOv11简介
我们集成了 YOLOv11 模型，利用其高效的目标检测能力来识别木材缺陷。