#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis

#show: snu-thesis.with(
  body-language: "en",
  cover-language: "en",
  approval-language: "ko",
  degree: "phd",
  academic-ko: "공학",
  academic-en: "Engineering",
  school-ko: "대학원",
  school-en: "Graduate School of Engineering",
  major-ko: "컴퓨터공학부",
  major-en: "Computer Science and Engineering Major",
  title: [
    Data-Centric Continual Learning
    #linebreak()
    for Urban Mobility Forecasting
  ],
  title-alt: [
    도시 이동성 예측을 위한
    #linebreak()
    데이터 중심 연속 학습 연구
  ],
  author: "Minseo Park",
  author-display: "Minseo Park",
  student-number: "2026-12345",
  advisor: "정지도",
  advisor-display: "정 지 도",
  grad-date-ko: "2026년 8월",
  grad-date-en: "August 2026",
  submission-date: "2026년 6월",
  approval-date: "2026년 7월",
  committee: (
    chair: "김위원장",
    vice-chair: "오부위원장",
    members: ("한교통", "윤데이터"),
  ),
  abstract-ko: include "sections/abstract-ko.typ",
  abstract-en: include "sections/abstract-en.typ",
  keywords-ko: ("연속 학습", "도시 이동성", "시계열 예측", "데이터 중심 인공지능"),
  keywords-en: ("continual learning", "urban mobility", "time-series forecasting", "data-centric AI"),
  acknowledgement: include "sections/acknowledgement.typ",
  bibliography: bibliography(path("bibliography/references.bib"), style: "apa", title: none),
  appendices: (
    (
      title: [Additional drift detection checks],
      body: include "sections/appendix.typ",
    ),
  ),
  fonts: ("NanumMyeongjo",),
)

#include "sections/chapters/1-introduction.typ"
#include "sections/chapters/2-methods.typ"
