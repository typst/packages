// 算法伪代码环境
#import "@preview/algorithmic:1.0.7": algorithm, algorithm-figure as _algorithm-figure, style-algorithm as _style-algorithm
#import "@preview/headcount:0.1.1": dependent-numbering

#let algorithm-counter = counter(figure.where(kind: "algorithm"))

// 算法编号按章重置，显示及交叉引用均使用“章号-序号”
#let style-algorithm(..args, body) = {
  show figure.where(kind: "algorithm"): set figure(numbering: dependent-numbering("1-1", levels: 1))
  show heading.where(level: 1): it => {
    algorithm-counter.update(0)
    it
  }
  _style-algorithm(..args, body)
}

#let algorithm-figure(title, supplement: "算法", ..args) = {
  _algorithm-figure(title, supplement: supplement, ..args)
}
