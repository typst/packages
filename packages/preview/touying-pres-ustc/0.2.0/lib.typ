//<>在这里添加第三方库的导入
//时间轴：https://typst.app/universe/package/timeliney
#import "@preview/timeliney:0.0.1"

//代码块：https://typst.app/universe/package/codly
#import "@preview/codly:0.2.0": *

//图表：https://typst.app/universe/package/fletcher
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

//提示框：https://typst.app/universe/package/gentle-clues
#import "@preview/gentle-clues:0.9.0": *

//展示框：https://typst.app/universe/package/showybox
#import "@preview/showybox:2.0.1": showybox

//泡泡框：https://typst.app/universe/package/babble-bubbles
#import "@preview/babble-bubbles:0.1.0": *

//日历：https://typst.app/universe/package/cineca
#import "@preview/cineca:0.2.1": *

//伪代码：https://typst.app/universe/package/lovelace
#import "@preview/lovelace:0.3.0": *

//</>

#let icon(codepoint) = {
  box(
    height: 0.8em,
    baseline: 0.05em,
    image(codepoint)
  )
  h(0.1em)
}

//下面是自定义的方法

#let (
  BLUE,
  GREEN,
  YELLOW,
  RED,
)=(
  rgb("#4285f4"),
  rgb("#34a853"),
  rgb("#fbbc05"),
  rgb("#ea4335"),
)

#let BlueText(_text)={
  set text(fill: BLUE)
  [#_text]
}

#let GreenText(_text)={
  set text(fill: GREEN)
  [#_text]
}

#let YellowText(_text)={
  set text(fill: YELLOW)
  [#_text]
}

#let RedText(_text)={
  set text(fill: RED)
  [#_text]
}

#import "@preview/suiji:0.3.0": *

#let Colorful(_text)={
  let colors = (
     rgb("#4285F4"),
     rgb("#34A853"),
     rgb("#FBBC05"),
     rgb("#EA4335"),
  )

  let i=7;
  let rng = gen-rng(_text.text.len() * i);
  let index_pre = integers(rng, low: 0, high: 4, size: none, endpoint: false).at(1);


  for c in _text.text{
    let rng = gen-rng(i - 1);
    let index_cur = integers(rng, low: 0, high: 4, size: none, endpoint: false).at(1);
    let cnt=100;
    while index_cur == index_pre and cnt>0{
      let rng = gen-rng(cnt + i);
      index_cur = integers(rng, low: 0, high: 4, size: none, endpoint: false).at(1);
      cnt -= 1;
    }
    let color = colors.at(index_cur);
    set text(fill: color)
    [#c]
    index_pre = index_cur;
    i += 2;

  }
}

// #let BlueBox(title:"信息",accent-color:BLUE,header-color:BLUE.lighten(0%),..args)=idea(
//   title:title,
//   accent-color:accent-color,
//   header-color:header-color,
//   ..args
//   )
#let undo(_text)={
  text(fill: black.lighten(80%),_text)
}