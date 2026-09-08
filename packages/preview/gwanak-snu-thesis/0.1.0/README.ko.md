# Gwanak SNU Thesis Typst Template

> “Gwanak”(관악)은 서울대학교 관악캠퍼스 옆 관악산에서 온 이름이며, 서울대학교 캠퍼스를 가리키는 표현으로도 쓰입니다.

서울대학교 학위논문을 Typst로 작성하기 위한 비공식 템플릿입니다. 목표는 논문 작성자가 바로 시작할 수 있는 실용적인 기본 구조입니다. 공식 배포물이 아니므로 최종 제출 전에는 학과와 학교의 최신 안내를 직접 확인해야 합니다.

언어: [English](README.md)

## Quick start

```bash
typst init @preview/gwanak-snu-thesis:0.1.0 my-thesis
cd my-thesis
typst compile main.typ
```

## Minimal document

```typst
#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis

#show: snu-thesis.with(
  body-language: "ko",
  cover-language: "ko",
  approval-language: "ko",
  degree: "master",
  academic-ko: "공학",
  academic-en: "Engineering",
  title: [논문 제목],
  title-alt: [English Thesis Title],
  author: "홍길동",
  student-number: "2026-00000",
  advisor: "김지도",
  grad-date-ko: "2026년 2월",
  grad-date-en: "February 2026",
  submission-date: "2025년 12월",
  approval-date: "2026년 1월",
  committee: (
    chair: "박위원장",
    vice-chair: "이부위원장",
    members: (),
  ),
  abstract-ko: [국문초록을 작성합니다.],
  abstract-en: [Write the English abstract here.],
  bibliography: bibliography("bibliography/references.bib", style: "apa", title: none),
)

= 서론

본문을 작성합니다.
```

## Main options

대부분의 논문 문서는 아래 필드만 설정하면 됩니다. `content`는 `[논문 제목]`처럼 대괄호로 감싼 Typst content이고, `string`은 `"홍길동"`처럼 따옴표로 감싼 텍스트입니다.

### Thesis metadata

| Option | Values | Notes |
|---|---|---|
| `title`, `title-alt` | content | 주 논문 제목과 다른 언어 제목입니다. `draft: true`가 아니면 둘 다 필요합니다. |
| `academic-ko`, `academic-en` | string | 학위명에 들어가는 학문 분야입니다. 예: `공학` / `Engineering`. |
| `school-ko`, `school-en` | string | 사용자가 소유한 대학원, 단과대학, school 줄입니다. `서울대학교` 또는 `Seoul National University`는 넣지 마세요. 고정 학교명은 템플릿이 자동으로 렌더합니다. |
| `major-ko`, `major-en` | string | school 줄 아래에 출력할 학과, 학부, 전공, 프로그램 줄입니다. |
| `author` | string | 저자의 canonical name입니다. `draft: true`가 아니면 필요합니다. |
| `author-display` | string 또는 `none` | 띄어쓰기나 문자 표기가 `author`와 다를 때 출력용 저자명으로 사용합니다. |
| `student-number` | string | 초록 페이지에 출력할 학번입니다. `draft: true`가 아니면 필요합니다. |
| `advisor` | string 또는 `none` | 지도교수 canonical name입니다. 석사/박사 인준지에 필요합니다. |
| `advisor-display` | string 또는 `none` | 띄어쓰기나 문자 표기가 `advisor`와 다를 때 출력용 지도교수명으로 사용합니다. |
| `grad-date-ko`, `grad-date-en` | string | 표지에 출력할 졸업일입니다. `draft: true`가 아니면 필요합니다. |
| `submission-date`, `approval-date` | string 또는 `none` | 제출일과 인준일입니다. 석사/박사 인준지에 필요합니다. |
| `abstract-ko`, `abstract-en` | content | 국문초록과 영문초록입니다. `draft: true`가 아니면 둘 다 필요합니다. |
| `keywords-ko`, `keywords-en` | array | 각 초록 페이지 하단에 표시할 주요어입니다. |

### Rendering and content controls

| Option | Values | Notes |
|---|---|---|
| `body-language` | `"ko"`, `"en"` | 본문 언어, 장/절 라벨, 목차 라벨, 초록 기본 순서. |
| `cover-language` | `"ko"`, `"en"`, `none` | 표지 언어. `none`이면 본문 언어를 따릅니다. |
| `approval-language` | `"ko"` | 석사/박사 인준지는 한국어만 지원합니다. |
| `abstract-languages` | dictionary 또는 `none` | 초록 순서를 `(primary: "en", secondary: "ko")`처럼 덮어씁니다. |
| `degree` | `"bachelor"`, `"master"`, `"phd"` | 학위별 표지 문구와 인준지 요구 여부. |
| `committee` | dictionary 또는 `none` | 석사/박사에서 필요합니다. 아래 예시를 참고하세요. |
| `bibliography` | content 또는 `none` | `bibliography(..., title: none)`를 넘깁니다. 참고문헌 제목은 템플릿이 렌더합니다. |
| `appendices` | array, content, 또는 `none` | 부록별 counter reset을 위해 `((title: [...], body: [...]),)` 형식을 권장합니다. |
| `acknowledgement` | content 또는 `none` | 보조 초록 뒤에 감사의 글 페이지를 추가합니다. |
| `show-table-list`, `show-figure-list` | `true`, `false` | 표 목차와 그림 목차 페이지 출력 여부입니다. |
| `fonts` | array | 문서에 적용할 font family fallback 목록입니다. |
| `draft` | `true`, `false` | `true`이면 frontmatter를 모두 생략하고 본문, 참고문헌, 부록만 렌더합니다. |
| `paper-size` | `"default"`, Typst paper string, dictionary | `default`는 `190mm × 260mm`입니다. 문자열은 Typst에 전달하고, dictionary는 `(width: ..., height: ...)`를 사용합니다. |
| `page-margin` | dictionary 또는 `none` | 기본 margin `left/right: 30mm`, `top: 20mm`, `bottom: 15mm`를 덮어씁니다. |


석사:

```typst
committee: (
  chair: "위원장 이름",
  vice-chair: "부위원장 이름",
  members: (),
)
```

박사:

```typst
committee: (
  chair: "위원장 이름",
  vice-chair: "부위원장 이름",
  members: ("위원1", "위원2"),
)
```

지도교수는 마지막 심사위원으로 자동 추가됩니다. 지도교수 이름은 `chair`, `vice-chair`, `members`와 중복될 수 없습니다.

학사 논문은 기본값에서 인준지, committee, `advisor`, `submission-date`, `approval-date`를 요구하지 않습니다.

소속 필드에는 사용자가 소유한 학교/학과·전공 줄만 지정합니다. 고정 학교명은 템플릿이 자동으로 렌더합니다.

```typst
school-ko: "대학원",
major-ko: "컴퓨터공학부 데이터사이언스 전공",
school-en: "Graduate School of Engineering",
major-en: "Computer Science and Engineering Major",
```

국문 대학원 표지와 인준지는 `서울대학교` + `school-ko`, 이어서 `major-ko`를 렌더하므로 대학원 논문에는 `school-ko: "대학원"`을 사용합니다. 영문 표지는 `school-en` → `Seoul National University` → `major-en` 순서로 렌더합니다. 공식 양식에 맞춘 영문 표지는 `school-en`을 `Graduate School of Engineering`처럼 완성된 줄로, `major-en`을 `Computer Science and Engineering Major`처럼 완성된 전공 줄로 지정합니다. 어떤 소속 필드에도 `서울대학교` 또는 `Seoul National University`를 넣지 마세요. frontmatter가 렌더될 때 `school-ko` 또는 `school-en`에 고정 학교명이 들어 있으면 템플릿이 즉시 실패합니다. 학사 예제는 대학원 학위논문 형식 밖에 있으므로 단과대학 줄을 명시합니다.

## Draft build

빠른 본문 검토용으로 `draft: true`를 사용할 수 있습니다. Draft mode는 표지, 인준지, 초록, 목차, 표/그림목차, 감사의 글을 생략합니다. 본문, 참고문헌, 부록은 그대로 렌더합니다.

```typst
#show: snu-thesis.with(
  body-language: "ko",
  degree: "master",
  draft: true,
)
```

Draft mode에서는 `title`, `student-number`, `abstract-ko`, `committee`, 승인일처럼 frontmatter에서만 쓰는 metadata를 요구하지 않습니다.

## Page size와 margin

기본 `paper-size: "default"`는 `190mm × 260mm`입니다. Typst paper preset을 쓰려면 문자열을 넘깁니다.

```typst
paper-size: "a4"
```

크기를 명확히 지정하려면 치수를 직접 넘깁니다.

```typst
paper-size: (width: 182mm, height: 257mm)
```

Margin은 `page-margin`으로 덮어쓸 수 있습니다.

```typst
page-margin: (
  left: 25mm,
  right: 25mm,
  top: 20mm,
  bottom: 20mm,
)
```

## Bibliography

참고문헌 양식은 사용자가 직접 선택합니다. 템플릿은 참고문헌 제목 위치와 문서 순서만 담당합니다.

```typst
bibliography: bibliography("bibliography/references.bib", style: "apa", title: none)
```

다른 양식도 같은 방식으로 사용할 수 있습니다.

```typst
bibliography: bibliography("bibliography/references.bib", style: "chicago-author-date", title: none)
```

## Fonts

기본 font stack은 한글 명조/바탕 계열만 사용합니다.

```typst
fonts: (
  "Noto Serif CJK KR",
  "Source Han Serif K",
  "NanumMyeongjo",
  "AppleMyungjo",
  "Batang",
  "바탕",
  "UnBatang",
  "Baekmuk Batang",
)
```

설치되지 않은 후보가 있으면 Typst가 warning을 냅니다. 초기화되는 template은 흔한 한국어 환경의 warning을 줄이기 위해 `fonts: ("NanumMyeongjo",)`를 명시합니다. 로컬에서 warning 없이 고정하려면 사용 중인 글꼴만 넘깁니다.

```typst
#show: snu-thesis.with(
  fonts: ("NanumMyeongjo",),
  // ...
)
```

## License

Library 코드는 MIT license를 사용합니다. `template/` 아래 파일은 생성된 논문 프로젝트를 attribution 요구 없이 수정·재배포할 수 있도록 MIT-0 license를 사용합니다.

## More details

- 구현 규격: [`SPECS.md`](SPECS.md)
- 복사해서 바로 쓸 수 있는 예제: [`examples/bachelor.typ`](examples/bachelor.typ), [`examples/master.typ`](examples/master.typ), [`examples/phd.typ`](examples/phd.typ)
