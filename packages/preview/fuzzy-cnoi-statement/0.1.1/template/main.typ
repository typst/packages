#import "@preview/fuzzy-cnoi-statement:0.1.1": *;

// 以下有大量 Fancy 的设置项。你可以根据需求，注释掉你不需要的内容，或者将你需要的内容取消注释。

#let prob-list = (
  (
    name: "圆格染色",            // 题目名
    name-en: "color",           // 英文题目名，同时也是目录
    time-limit: "1.0 秒",       // 每个测试点时限（会显示为 $1.0$ 秒）
    memory-limit: "512 MiB",    // 内存限制（显示同上）
    test-case-count: "10",      // 测试点数目（显示同上）
    test-case-equal: "是",      // 测试点是否等分
    year: "2023",               // 你可以添加自定义的属性
  ),
  // 实际上必需的项只有 name-en
  // 下面是一些花活
  (
    name: "桂花树",
    name-en: "tree",
    type: "交互型",             // 题目类型
    time-limit: "0.5 秒",
    memory-limit: "512 MiB",
    test-case-count: "10",
    test-case-equal: "是",
    year: "2023",
    // submit-file-name 为提交文件名，可以为 str、content 或一个 extension:str=>content 的函数
    // submit-file-name: e => {
    //   show raw: set text(size: 0.8em)
    //   raw("tree." + e)
    // } // 将其字体变小
  ),
  (
    name: "深搜",
    name-en: "dfs",
    type: "提交答案型",
    executable: [无],
    input: [`dfs`$1~10$`.in`],   // 输入文件名
    output: [`dfs`$1~10$`.out`], // 输出文件名
    test-case-count: "10",
    test-case-equal: "是",
    submit-file-name: [`dfs`$1~10$`.out`],
  ),
)

#let contest-info = (
  name: "全国中老年信息学奥林匹克竞赛",
  name-en: "FCC ION 3202",      // 似乎也可以当成副标题用
  round: "第一试",
  time: "时间：2023 年 7 月 24 日 08:00 ~ 13:00",
  // author: "破壁人五号"
)


#let (init, title, problem-table, next-problem, filename, current-filename, current-sample-filename, data-constraints-table-args) = document-class(
  contest-info,
  prob-list,
  // custom-fonts 参数可以更改字体，字典各项的键值为：mono、serif、cjk-serif、cjk-sans、cjk-mono、cjk-italic，值为字体名。你可以只传入部分项。默认分别为：
  // - Consolas
  // - New Computer Modern
  // - 方正书宋（FZShuSong-Z01S）
  // - 方正黑体（FZHei-B01S）
  // - 方正仿宋（FZFangSong-Z02S）
  // - 方正楷体（FZKai-Z03S）
  // header 参数可以自定义页眉，你需要传入一个 (contest-info, current-problem) => content 的函数。
  // footer 参数可以自定义页脚，你需要传入一个 (contest-info, current-problem) => content 的函数。
)

#show: init

#title()

#problem-table(
  // 默认会显示以下行（括号内为默认值，打星号的在没有题目有这一项时不会显示）：
  // - name 题目名称（无）
  // - type 题目类型（传统型）
  // - name-en 目录
  // - executable 可执行文件名（默认为目录名）
  // - input 输入文件名（默认为目录名 + ".in"）
  // - output 输出文件名（默认为目录名 + ".out"）
  // - * time-limit 每个测试点时限（无）
  // - * memory-limit 内存限制（无）
  // - * test-case-count 测试点数目（10）
  // - * subtask-count 子任务数目（1）
  // - * test-case-equal 测试点是否等分（是）
  // 
  // 一般来说，默认显示的行的设置是够用的。但如果你希望增加更多行，或者当你有太多题目需要展示，你可能需要 extra-rows 参数来添加新的行。
  // extra-rows 也可以覆盖掉默认的行。其在题目过多、需要将特定行的字体变小时尤其有用。
  extra-rows:(
    year: (                   // 对应的 field 名
      name: "年份",           // 显示的名字；可以用 content（调整字号等）
      wrap: text,             // 显示的样式：若题目的这一项是 str，则显示为 wrap(str)，否则会直接显示这一项。默认为 text。
      always-display: false,  // 是否总是显示：若为 false，则至少要有一个题目有这一项才会显示。默认为 false。
      default: "2023"         // 默认值，默认为“无”。你也可以传入一个函数，其接受一个参数，为当前题目的信息，返回一个 str 或 content。
    ),
    contest: (
      name: "赛事",
      wrap: text.with(fill: blue), // 你也可以在这里设置更小的字体
      always-display: true,
      default: "NOI"
    ),
    setter: (
      // name: text(size: 0.8em)[出题人], // 也许你需要更小的字号
      name: "出题人",
      always-display: true,
      default: p => { p.name-en + "的出题人" }
    ),
    foo: (
      name: "bar",
      wrap: text,
      default: "这一行不会显示"
    )
  ),
  // 提交源程序文件名的列表，每一种语言为 (语言名, 文件后缀名) 的二元组，或 (语言名, 文件后缀名, 首列字体大小) 的三元组。若 problem 没有指明 submit-file-name，则用题目英文名与后缀名拼接。
  languages:(
    ("C++", "cpp"),
    ("D++", "dpp"),
    // ("D++", "dpp", 0.8em), // 更小的字号
  ),
  // 各个语言的编译选项，每一种语言为 (语言名, 编译选项) 的二元组，或 (语言名, 编译选项, 首列字体大小) 的三元组。
  compile-options: (
    ("C++", "-O2 -std=c++20 -DOFFLINE_JUDGE"),
  )
)

*注意事项（请仔细阅读）*
+ 文件名（程序名和输入输出文件名）必须使用英文小写。
+ C++ 中函数 main() 的返回值类型必须是 int，程序正常结束时的返回值必须是 0。
+ 因违反以上两点而出现的错误或问题，申诉时一律不予受理。
+ 若无特殊说明，结果的比较方式为全文比较（过滤行末空格及文末回车）。
+ 选手提交的程序源文件必须不大于 100KB。
+ 程序可使用的栈空间内存限制与题目的内存限制一致。
+ 只提供 Linux 格式附加样例文件。
+ 禁止在源代码中改变编译器参数（如使用 \#pragma 命令），禁止使用系统结构相关指令（如内联汇编）和其他可能造成不公平的方法。


#next-problem()

== 题目描述

输入两个正整数 $a, b$，输出它们的和。

你可以*强调一段带 $f+or+mu+l+a$ 的文本*。用 `#underline` 加 ``` `` ``` 来实现 #underline[`underlined raw text`]。
+ 第一点
+ 第二点

- 第一点
  - 列表可以嵌套
  - 但目前，有序列表和无序列表的互相嵌套会有缩进上的问题。
- 第二点
  - 第二点的第一点
  - 第二点的第二点


== 输入格式

从文件 #current-filename("in") 中读入数据。// 自动获取当前题目的输入文件名

输入的第一行包含两个正整数 $a, b$，表示需要求和的两个数。

== 输出格式

输出到文件 #filename[color.out] 中。

输出一行一个整数，表示 $a+b$。

== 样例1输入
// 从文件中读取样例
#raw(read("color1.in"), block: true)

== 样例1输出
// 或者直接写在文档中
```text
13
```

== 样例1解释

#figure(caption: "凹包")[#image("fig.png", width: 40%)]<aobao>

如@aobao，这是一个凹包。

#for (i,case) in range(2, 8).zip((
  $1 tilde 5$,
  $6 tilde 9$,
  $10 tilde 13$,
  $14 tilde 17$,
  $18 tilde 19$,
  $20$)){[
== 样例#{i+2}
见选手目录下的 #current-sample-filename(i, "in") 与 #current-sample-filename(i, "ans")。

这个样例满足测试点 #case 的条件限制。
]}

== 数据范围

对于所有测试数据保证：$1 <= a,b <= 10^9$。

#figure(
  table(
    columns: 4,
    ..data-constraints-table-args, // 默认的针对数据范围的三线表样式
    table.header(
    [测试点编号],   $n,m <=$,                      $q<=$,                          [特殊性质],
    ),
    $1 tilde 5$,   $300$,                         $300$,                          table.cell(rowspan:2)[无],
    $6 tilde 9$,   table.cell(rowspan:4)[$10^5$], $2000$,
    $10 tilde 13$,                                table.cell(rowspan:4)[$10^5$],  [A],
    $14 tilde 17$,                                                                [B],
    $18 tilde 19$,                                                                table.cell(rowspan:2)[无],
    $20$,          $10^9$,
  )
)

特殊性质 A: 你可以像上面这样创建复杂的表格。






#next-problem()

*这是一道交互题。*

== 题目描述
#lorem(50)

== 实现细节
请确保你的程序开头有 `#include "tree.h"`。

```cpp
int query(int x, int y);
void answer(std::vector<int> ans);
```

```bash
g++ count.cpp -c -O2 -std=c++14 -lm && g++ count.o grader.o -o count
```

我能吞下玻璃而不伤身体。

- 赵钱孙李周吴郑王，冯陈楮卫蒋沈韩：
  - 杨朱秦尤许何吕施张孔。
    - 曹严华金魏陶姜戚谢。
  - 邹喻柏水窦章云苏潘葛奚。
- 范彭郎鲁韦昌马苗凤花，方俞任袁柳酆鲍史唐费廉岑薛雷。
- 贺倪汤滕殷罗毕郝邬安常乐于时傅皮卞齐康伍余，元卜顾孟平黄和穆萧尹姚邵湛汪，祁毛禹狄米贝明臧计伏成戴。

== 评分标准
#lorem(50)

#lorem(100)

== 数据范围
#lorem(50)




#next-problem()
== 题目描述
#lorem(50)

== 输入格式
从文件 #filename[dfs$1~10$.in] 中读入数据。

#lorem(50)

== 输出格式
输出到文件 #filename[dfs$1~10$.out] 中。

#lorem(50)

== 数据范围
对于所有测试数据保证：$1 <= n <= 10^5$。


