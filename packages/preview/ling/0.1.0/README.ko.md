# Ling

[English](README.md)

Ling은 기술 발표를 위한 한국어 우선 [Touying](https://github.com/touying-typ/touying) 테마입니다. 산세리프와 세리프 타이포그래피를 전환할 수 있고, 인쇄에서도 구분되는 콜아웃을 제공합니다. 필수 글꼴은 초기화 후 별도로 내려받으며, Typst Universe 패키지와 템플릿에는 글꼴 바이너리가 포함되지 않습니다.

주 출력물은 PDF입니다. 생성된 발표 자료에는 편집 가능한 PowerPoint 객체가 없으며 PPTX 파일로 편집하도록 만들어지지 않았습니다.

## 발표 자료 시작하기

권장 방법은 템플릿을 초기화하고, 공식 소스에서 고정된 여섯 글꼴을 내려받은 뒤, 그 로컬 글꼴 디렉터리로 컴파일하는 것입니다.

```sh
typst init @preview/ling:0.1.0 my-talk
cd my-talk
sh download-fonts.sh
typst compile main.typ --font-path fonts
```

세리프 타이포그래피는 `--input mode=serif`, 핸드아웃은 `--input handout=true`를 사용합니다.

```sh
typst compile main.typ talk.pdf --font-path fonts --input mode=serif
typst compile main.typ handout.pdf --font-path fonts --input handout=true
```

`download-fonts.sh`는 각 파일을 `fonts/SHA256SUMS`와 대조해 검증하고 이미 일치하는 파일은 건너뜁니다. Pretendard GOV 1.3.9 Regular, SemiBold, Bold, RIDI Batang OpenType 1.000, D2Coding 1.3.3 Regular, Bold를 내려받습니다. 패키지가 글꼴을 직접 등록할 수 없으므로 CLI 빌드에서는 `--font-path fonts`를 유지해야 합니다.

Typst 웹 앱에서는 로컬에서 초기화와 다운로더 실행을 마친 후 `main.typ`와 `fonts/`의 여섯 파일을 함께 웹 프로젝트에 올리세요. 웹 앱은 사용자 프로젝트에 저장된 글꼴을 감지합니다. 글꼴 바이너리는 Typst Universe 패키지 제출물에 추가하면 안 됩니다.

## 직접 가져오기

아래에 나열한 세 글꼴 모음이 Typst에서 사용할 수 있으면 직접 가져오기를 지원합니다.

```typ
#import "@preview/ling:0.1.0": *

#show: ling-theme.with(
  mode: "sans",
  title: [문서가 코드가 되는 순간],
  author: [타치바나 셰리],
)

#title-slide()

= 설계 원칙

== 가장 작은 인터페이스

내용은 구조에 집중합니다.
```

테마 함수의 시그니처는 다음과 같습니다.

```typ
#let ling-theme(
  mode: "sans",
  accent: rgb("#087A5C"),
  aspect-ratio: "16-9",
  title: none,
  author: none,
  institution: none,
  date: none,
  logo: none,
  ..args,
  body,
)
```

추가 이름 인수는 Touying으로 전달됩니다. 패키지는 Touying의 슬라이드, 오버레이, 핸드아웃, 열, 발표자 노트 API를 대체하지 않습니다.

## 타이포그래피

- `mode: "sans"`는 화면 중심의 조밀한 행간으로 Pretendard GOV Regular, SemiBold, Bold를 사용합니다.
- `mode: "serif"`는 모든 비례 텍스트에 RIDI Batang Regular를 사용합니다. Semi-bold와 bold 위계는 0.12 pt 및 0.20 pt 획으로 합성합니다.
- 두 모드 모두 코드에 D2Coding Regular와 Bold를 사용하며 프로그래밍 리가처를 끕니다.

테마에는 Pretendard GOV 1.3.9, RIDI Batang OpenType 1.000, D2Coding 1.3.3이 필요합니다. 활성 글꼴 모음 목록은 의도적으로 `Pretendard GOV`, `RIDIBatang`, `D2Coding`으로만 제한하고 시스템 글꼴 대체 모음을 두지 않습니다. 이렇게 해야 글꼴 누락 진단이 표시되고 디자인이 조용히 바뀌지 않습니다. 직접 가져오기는 글꼴을 별도로 확보해 `--font-path` 또는 웹 프로젝트 업로드로 제공해야 하므로 `typst init`을 권장합니다.

## Touying 기능

Touying의 공개 헬퍼를 사용할 때는 Touying을 가져오세요.

```typ
#import "@preview/touying:0.7.4": *
#import "@preview/ling:0.1.0": *

#show: ling-theme.with(
  config-common(handout: true),
)

== 단계별 설명

항상 보이는 내용입니다.
#pause
두 번째 단계에서 보이는 내용입니다.

#speaker-note[발표자에게만 필요한 메모입니다.]

#slide(composer: (1fr, 1fr))[
  왼쪽 열
][
  오른쪽 열
]
```

`pause`는 오버레이 단계를 만들고, `slide(composer:)`는 Touying의 기본 슬라이드 구성을 사용하며, `config-common(handout: true)`는 핸드아웃 출력물을 만들고, `speaker-note`는 발표자 노트를 기록합니다.

## 콜아웃

정보와 경고 콜아웃은 레이블과 서로 다른 왼쪽 테두리선을 사용하므로 색상 없이도 구별됩니다.

```typ
#info(title: [정보])[배경 지식을 설명합니다.]
#warning(title: [주의])[확인해야 할 위험을 설명합니다.]
```

## 라이선스

테마와 템플릿은 [MIT No Attribution License](LICENSE)에 따라 배포되므로, 초기화한 발표 자료는 저작자 표시를 유지하지 않고 수정·재배포할 수 있습니다. 필수 글꼴은 별도로 내려받으며 SIL Open Font License 1.1 조건을 유지합니다. 패키지는 해당 라이선스와 저작자 표시 파일을 보존합니다.

- [Pretendard GOV license](template/licenses/Pretendard-OFL.txt)
- [RIDI Batang license](template/licenses/RIDIBatang-OFL.txt)
- [D2Coding license](template/licenses/D2Coding-OFL.txt)
