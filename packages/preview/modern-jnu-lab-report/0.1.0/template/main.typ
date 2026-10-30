#import "@preview/modern-jnu-lab-report:0.1.0": jnu-report

#show: jnu-report.with(
  course: "模拟电子技术实验",
  grade: "",
  lab-name: "晶体管共射极单管放大器",
  instructor: "李四",
  lab-id: "08081234",
  lab-type: "验证",
  site: "南海楼302",
  author: "张三",
  student-id: "2020101234",
  college: "信息科学技术学院",
  department: "电子系",
  major: "电子科学与技术",

  year: "2026", month: "10", day: "16", ampm: "上",
  end-month: "10", end-day: "16", end-ampm: "下",
  temperature: "24", humidity: "55",
)

= 实验目的

1. 掌握共射极单管放大器静态工作点的测量与调试方法。
2. 学习放大电路电压放大倍数、输入电阻和输出电阻的测量方法。
3. 观察静态工作点对输出波形的影响，理解非线性失真的成因。

= 实验原理

== 静态工作点

晶体管共射极放大电路的静态工作点由基极偏置电阻决定。当电源电压 $U_(C C)$ 与集电极电阻
$R_C$ 确定后，改变基极偏置即可调整 $I_C$ 与 $U_(C E)$。

== 动态指标

电压放大倍数 $A_u = -beta R'_L \/ r_("be")$，其中 $r_("be")$ 为晶体管输入电阻。

= 实验内容与步骤

== 测量静态工作点

按图连接电路，接通电源后测量 $U_(B E)$、$U_(C E)$ 与 $I_C$。

== 测量电压放大倍数

输入 $f = 1"kHz"$、$U_i = 10"mV"$ 的正弦信号，用示波器观察输出波形并测量幅值。

= 数据记录与处理

#table(
  columns: (auto, auto, auto, auto),
  align: (center, center, center, center),
  stroke: 0.5pt,
  [测量项], [$U_(C E)"/V"$], [$I_C"/mA"$], [$U_o"/V"$],
  [理论值], [6.00], [1.50], [1.20],
  [实测值], [5.86], [1.47], [1.15],
)

= 结论

实验结果与理论分析基本一致，验证了共射极放大电路的放大特性。

\

#lorem(100)