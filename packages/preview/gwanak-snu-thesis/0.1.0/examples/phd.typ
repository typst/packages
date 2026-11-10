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
  student-number: "2021-30482",
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
  abstract-ko: [
    본 논문은 도시 이동성 예측 모델이 시간이 지나며 변화하는 교통 패턴에 적응하도록 데이터 중심 연속 학습 방법을 제안한다. 제안 방법은 모델 구조를 반복적으로 키우기보다 입력 데이터의 품질, 시간 구간별 표본 균형, 변화 감지 기준을 명시적으로 관리한다.

    서울시 공공 자전거와 지하철 혼잡도 데이터를 이용한 실험에서 제안 방법은 계절 변화와 노선 개편 이후의 예측 성능 저하를 완화했다. 분석 결과, 연속 학습에서는 모델 업데이트 주기보다 데이터 선별 기준이 장기 성능에 더 큰 영향을 주었다.
  ],
  abstract-en: [
    This dissertation studies data-centric continual learning for urban mobility forecasting. Instead of expanding model capacity after every distribution shift, the proposed framework manages data quality, temporal sample balance, and drift detection as first-class components of the learning pipeline.

    Experiments on Seoul public bicycle and subway congestion data show that the proposed method reduces performance degradation after seasonal changes and service reorganizations. The analysis suggests that data selection policies can matter more than update frequency in long-running forecasting systems.
  ],
  keywords-ko: ("연속 학습", "도시 이동성", "시계열 예측", "데이터 중심 인공지능"),
  keywords-en: ("continual learning", "urban mobility", "time-series forecasting", "data-centric AI"),
  acknowledgement: [
    I thank my advisor, committee members, lab colleagues, and the public data teams whose careful data maintenance made this research possible.
  ],
  bibliography: bibliography("references.bib", style: "apa", title: none),
  appendices: (
    (
      title: [Additional drift detection checks],
      body: [
        The main experiments use weekly drift checks. As a robustness check, the same pipeline was evaluated with biweekly checks and monthly checks. The relative ranking of data selection strategies was stable across these intervals.
      ],
    ),
  ),
)

= Introduction

Urban mobility forecasting systems are deployed in environments where demand patterns change continuously. Weather, school calendars, public events, service disruptions, and policy changes can all shift the relationship between historical observations and future demand. A forecasting model that performs well at deployment can therefore become unreliable without any change in code.

This dissertation takes a data-centric view of continual learning. The central claim is that long-term forecasting quality depends not only on the model family but also on which new observations are admitted into the training set, how older observations are retained, and when distribution shifts are declared. Deep neural architectures have improved representation learning for vision and language tasks @he2016deep @vaswani2017attention, but operational forecasting pipelines also need explicit data governance.

#figure(
  align(center)[
    #rect(width: 82%, height: 34mm, stroke: 0.6pt, inset: 8pt)[
      #align(center + horizon)[streaming observations → drift check → data selection → model update → forecast audit]
    ]
  ],
  caption: [Continual learning pipeline used in this dissertation],
)

= Data and Method

The study combines two public data sources: station-level public bicycle rentals and subway congestion reports. Each observation is aggregated into hourly counts with calendar, weather, and service metadata. The pipeline separates three decisions that are often bundled together: detecting a shift, selecting training windows, and updating the forecasting model.

#figure(
  table(
    columns: (30mm, 1fr, 28mm),
    table.header([Component], [Decision], [Cadence]),
    [Drift detector], [Compare recent residuals with a rolling seasonal baseline.], [Weekly],
    [Data selector], [Retain examples that cover both recent shifts and recurring seasonal patterns.], [Weekly],
    [Forecaster], [Update the graph-temporal model only after the data selector changes the training set.], [On demand],
  ),
  caption: [Operational decisions in the proposed framework],
)

Graph-based models are used to encode relationships among nearby stations and transit lines. This choice follows prior work showing that graph convolution can propagate local structure across connected nodes @kipf2017semi. The proposed contribution is not a new graph layer; it is the surrounding data policy that decides which observations the model is allowed to learn from.

= Results

The data-centric pipeline improved long-horizon stability compared with fixed-window retraining. The largest gains appeared after abrupt schedule changes, where a naive recent-window policy overfit to the first unstable week. Keeping a small but diverse seasonal memory reduced this failure mode.

The results also show a practical tradeoff. Frequent updates reacted faster to sudden changes, but they also amplified noise when the drift detector was too sensitive. A weekly drift check provided the best balance in the evaluated setting. This supports the dissertation's main argument: continual learning systems should expose data selection and drift criteria as auditable design choices, not hidden preprocessing details.
