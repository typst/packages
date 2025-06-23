#import "@preview/simple-bupt-report:0.1.1": experiment-report

#show: doc => experiment-report(
  title: "《信号处理实验》实验报告",
  semester: "2024-2025学年第二学期",
  class: "2023211113",
  name: "张三",
  student-id: "2021123456",
  date: "2024年4月14日",
  doc
)

= 实验一 频谱泄露实验

== 实验目的

（1）掌握MATLAB的基本使用方法；

（2）其他实验目的；

（3）xxx。

== 实验原理
=== 原理一
写一些使用到的原理，简略得当，过长将扣分。
插入公式，建议大家使用MathType，或者采用WPS自带的公式编辑器，如图1所示。
=== 原理二


== 实验步骤
=== 码上使用过程
写明码上问答过程及使用情况。
===	Matlab实验过程
如@bupt-logo ，写明实验步骤，简明扼要。 

#figure(
  image("../assets/bupt-logo.jpg",width: 30%),
  caption: "BUPT校徽"
) <bupt-logo>

代码高亮样例
```matlab
N2 = 128;  % 信号长度，为了脚标统一设置为N2
t2=(0:N2-1)/fs;  % 时间序列
x2 = sin(120*pi*t2);  % 离散信号
X2 = dft(x2,N2);  % DFT变换
```

== 实验结果与分析
展示得到的实验结果，并给出相应的分析。
== 码上使用心得体会
总结采用码上大模型开展实验的收获或者建议。

这是个实验报告模板，所有样式已设置好，点击Word上方样式中相关样式，即可使用。