// 要使用一开始配置好的符号，就要引用配置文件
#import "../master.config.typ": *
// 不能引用主文件，因为主文件也用了这个文件，会循环引用！

#conclusion

// 标准有说结论或结语不编号，本模版干脆创建个变量方便操作
// 也可以自己写个不编号的一级标题
// #heading(level: 1, numbering: none)[结语]

@tb:hoc[不能想了]。// 自定义编号前面的文本

四千年来时时吃人的地方，@tb:hoc-time，今天才明白，我也在其中混了多年；大哥正管着家务，妹子恰恰死了，他未必不和在饭菜里，暗暗给我们吃。

我未必无意之中，不吃了我妹子的几片肉，现在也轮到我自己：@tb:hoc-char

#my-lil-func[有了四千年吃人履历的我，当初虽然不知道，现在明白，难见真的人！].join()

// “figures”不是“figure”——子图！

#figures(
  caption: [吃人履历], // 总图图注
  label: <tb:hoc>, // 总图标签
  kind: table, // 总图类型；一般不用声明，但这里是“表”类却不能自动识别出来
  columns: 2, // 排两列
  figure(
    caption: [按时间],
    // 简单三线表
    table(
      columns: 3,
      table.hline(),
      // 表头
      table.header[时间][标准][强度],
      table.hline(),
      [四千年前], [?], $x$,
      [“现在”], [?], $y/2$,
      [2026年], [?], $log(z)$,
      table.hline(),
    ),
  ),
  <tb:hoc-time>, // 子图标签，写下一个参数里
  figure(
    caption: [按人物],
    table(
      columns: 3,
      table.hline(),
      table.header[人物][标准][强度],
      table.hline(),
      [“我”], [?], $x$,
      [大哥], [?], $y/2$,
      [妹子], [?], $#calc.round(calc.atan(0.5).rad(), digits: 3) "rad"$,
      table.hline(),
    ),
  ),
  <tb:hoc-char>,
)

