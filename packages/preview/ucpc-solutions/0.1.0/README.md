# ucpc-solutions

[ucpc-solutions](https://github.com/ShapeLayer/ucpc-solutions__typst) is the template for solutions editorial of algorithm contests, used widely in the ["Baekjoon Online Judge"](https://acmicpc.net) users community in Korea.

The original version of ucpc-solution is written in LaTeX([ucpcc/2020-solutions-theme](https://github.com/ucpcc/2020-solutions-theme)), and this is the port of LaTeX ver.
This contains content-generating utils for making solutions editorial and ["solved.ac"](https://solved.ac) difficulty expression presets, a rating system for Baekjoon Online Judge's problems.

## Getting Started

```typst
#import "@preview/ucpc-solutions:0.1.0" as ucpc

#show: ucpc.ucpc.with(
  title: "Contest Name",
  authors: ("Contest Authors", ),
)
```

### Requirements

**Fonts**
- [Inter](https://fonts.google.com/specimen/Inter)
- (optional) [Gothic A1](https://fonts.google.com/specimen/Gothic+A1)
- (optional) [Pretendard](https://github.com/orioncactus/pretendard/blob/main/packages/pretendard/docs/en/README.md)

## Examples

See [`/examples`](./examples/).

You can also see other usecase using the original LaTeX theme. See the [(KR) "Theme Usage Examples(테마 사용 예)" section](https://github.com/ucpcc/2020-solutions-theme#%ED%85%8C%EB%A7%88-%EC%82%AC%EC%9A%A9-%EC%98%88) in the origin repository's README.

## For Contributing

Requirements: [just](https://github.com/casey/just), [typst-test](https://github.com/tingerrr/typst-test)

**Recompile Refs for Testing**
```sh
just update-test
```

**Run Test**
```sh
just test
```

---

* Special Thanks: [@kiwiyou](https://github.com/kiwiyou) - about technical issue 

* Since this ported version has been re-implemented only for appearance, this repository does not include the source code of any distribution or variant of ucpc-solutions.
