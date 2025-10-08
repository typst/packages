#import "@preview/koty:0.1.0": get-ko-josa, get-ko-number

#set page(
  paper: "a4",
  margin: (x: 1cm, y: 2cm)
)

#show heading: this => [
  #this.body
  #v(0.2em)
]

#set text(
  lang: "ko",
  size: 14pt,
)

#let code(body) = block(
    width: 100%,
    stroke: 1pt + luma(80%),
    inset: 1em,
    body
  )

= koty

`koty`는 한국어 문서를 위한 간단한 Typst 라이브러리입니다.

= Usage

#code[
  ```typst
  #import "@preview/koty:0.1.0": get-ko-josa, get-ko-number
  ```
]

== get-ko-josa

`get-ko-josa`의 가장 간단한 사용방법은 다음과 같습니다:

#code[
```typst
#get-ko-josa("나무", "은")
// 나무는
```
]

@particles 에서 지원하는 모든 조사들을 확인 할 수 있습니다.

만약 한글로 쓰이지 않은 단어를 넣는다면, 주어진 조사를 그대로 사용합니다. 만약 해당 단어의 한글 표기의 종성 유무를 미리 알고있다면, `(단어, 종성유무)`의 `(str, bool)` tuple을 넣어 쓸 수 있습니다.

#code[
```typst
#get-ko-josa("Bitcoin", "는")
// Bitcoin는
#get-ko-josa(("Bitcoin", true), "는")
// Bitcoin은
```
]

`concat` argument를 통해 출력값이 검증한 단어를 포함할지 여부를 결정 할 수 있습니다.

#code[
```typst
#get-ko-josa("금", "는", concat: false)
// 은
```
]

== get-ko-number

`get-ko-number`의 가장 간단한 사용방법은 다음과 같습니다:

#code[
```typst
#get-ko-number(42000)
// 4만 2천
```
]

`get-ko-number`는 1양(壤, $10^28$) *미만*의 숫자까지 지원합니다.

#code[
```typst
#get-ko-number(1.23456789E27)
// 1234자 5678해 9000경
#get-ko-number(1E28)
// error
```
]

`full-ko` argument를 사용해서 모든 숫자를 한국어로 변환 할 수 있습니다. 1을 생략하지 않고 모두 표기합니다.
#code[
```typst
#get-ko-number(1.23456789E27, full-ko: true)
// 일천이백삼십사자 오천육백칠십팔해 구천경
```
]

천의 자리가 넘는 숫자들은 기본 whitespace로 이어집니다(e.g. 4만 2천). `join-str` argument로 연결하는 문자를 대체할 수 있습니다.
#code[
```typst
#get-ko-number(1.23456789E27, full-ko: true, join-str: "")
// 일천이백삼십사자오천육백칠십팔해구천경
#get-ko-number(1.23456789E27, full-ko: true, join-str: "_")
// 일천이백삼십사자_오천육백칠십팔해_구천경
```
]

#pagebreak()

#let _josa-list = (
  ("을", "를"),
  ("은", "는"),
  ("이", "가"),
  ("과", "와"),
  ("이나", "나"),
  ("으로", "로"),
  ("아", "야"),
  ("이랑", "랑"),
  ("이며", "며"),
  ("이다", "다"),
  ("이가", "가"),
)

#figure(
  caption: "지원하는 조사 리스트",
  gap: 1em,
  align(
  center+horizon,
  table(
    columns: 4,
    rows: (32pt, 24pt),
    align: horizon + center,
    table.cell(
      colspan: 4,
      align: center+horizon,
      fill: luma(180),
      text(
        weight: "extrabold",
        "조사"
      )
    ),
    ..for j in _josa-list {
    (
    table.cell(
      rowspan: 2,
      align: center+horizon,
      j.at(0) +"/" + j.at(1)
    ),
    "사과",
    get-ko-josa("사과", j.at(0), concat: false),
    raw("get-ko-josa(\"사과\", " + j.at(0) + ")"),
    "당근",
    get-ko-josa("당근", j.at(0), concat: false),
    raw("get-ko-josa(\"당근\", " + j.at(0) + ")"),
  )},
  ),
))<particles>
