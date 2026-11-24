#import "@preview/ling:0.1.0": *
#import "@preview/touying:0.7.4": *

#let mode = sys.inputs.at("mode", default: "sans")
#let handout = sys.inputs.at("handout", default: "false") == "true"

#show: ling-theme.with(
  mode: mode,
  title: [문서가 코드가 되는 순간],
  author: [타치바나 셰리],
  institution: [Engineering],
  date: datetime.today(),
  config-common(handout: handout),
)

#title-slide()

= 설계 원칙

== 가장 작은 인터페이스

- 내용은 구조에 집중합니다.
- 테마는 타이포그래피를 책임집니다.

#pause

#info[한국어와 English 2026을 함께 사용합니다.]

== 코드

```typ
#let theme = ling-theme.with(mode: "sans")
```

#speaker-note[코드와 본문 글꼴의 차이를 설명한다.]

#focus-slide[복잡성을 줄이는 가장 작은 인터페이스]

#slide(composer: (1fr, 1fr))[
  왼쪽에는 설명을 둡니다.
][
  오른쪽에는 그림이나 코드를 둡니다.
]

#warning[인쇄 결과에서도 선과 레이블로 의미를 구분합니다.]

#slide[
  #align(left + horizon)[감사합니다.]
]
