// 算法伪代码环境
#import "@preview/algorithmic:1.0.7": algorithm, algorithm-figure as _algorithm-figure, style-algorithm

#let style-algorithm = style-algorithm

#let algorithm-figure(title, supplement: "算法", ..args) = {
  _algorithm-figure(title, supplement: supplement, ..args)
}
