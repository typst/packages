#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis

#show: snu-thesis.with(
  body-language: "ko",
  cover-language: "ko",
  degree: "bachelor",
  academic-ko: "공학",
  academic-en: "Engineering",
  school-ko: "공과대학",
  school-en: "College of Engineering",
  major-ko: "컴퓨터공학부",
  major-en: "Computer Science and Engineering Major",
  title: [
    캠퍼스 순환버스 혼잡도 예측을 위한
    #linebreak()
    모바일 센서 데이터 분석
  ],
  title-alt: [
    Mobile Sensor Data Analysis for
    #linebreak()
    Campus Shuttle Crowding Forecasts
  ],
  author: "최관악",
  author-display: "최 관 악",
  student-number: "2022-11234",
  grad-date-ko: "2026년 2월",
  grad-date-en: "February 2026",
  abstract-ko: [
    본 졸업논문은 캠퍼스 순환버스의 시간대별 혼잡도를 예측하기 위해 모바일 센서 기반 탑승 기록과 학사 일정을 결합하는 방법을 다룬다. 수집된 데이터는 익명화된 승하차 이벤트, 정류장 위치, 강의 시간표, 기상 정보를 포함한다.

    실험 결과, 단순한 전주 동일 시간 평균보다 수업 시작 전후의 이벤트를 반영한 모델이 혼잡 구간을 더 안정적으로 예측했다. 제안 방법은 대규모 인프라 교체 없이도 학생 이동 편의를 개선할 수 있는 경량 분석 절차를 제공한다.
  ],
  abstract-en: [
    This undergraduate thesis analyzes mobile sensor data for forecasting crowding on campus shuttle buses. The dataset combines anonymized boarding events, stop locations, class schedules, and weather information.

    The results show that a model using class-transition events predicts crowded intervals more reliably than a simple same-hour-last-week baseline. The proposed workflow offers a lightweight way to improve student mobility without replacing existing shuttle infrastructure.
  ],
  keywords-ko: ("캠퍼스 이동", "혼잡도 예측", "모바일 센서", "시계열 분석"),
  keywords-en: ("campus mobility", "crowding forecast", "mobile sensing", "time-series analysis"),
  bibliography: bibliography(path("references.bib"), style: "apa", title: none),
)

= 서론

캠퍼스 순환버스는 수업 시작 전후에 수요가 집중된다. 그러나 고정 배차 간격은 갑작스러운 혼잡을 충분히 반영하지 못한다. 혼잡 정보를 사전에 예측할 수 있다면 운영자는 임시 증차 여부를 판단할 수 있고, 학생은 대체 이동 수단을 선택할 수 있다.

본 논문은 학부 졸업논문 규모에서 수행 가능한 데이터 분석 절차를 제안한다. 목표는 가장 복잡한 모델을 만드는 것이 아니라, 이미 수집 가능한 모바일 센서 데이터와 공개 학사 일정을 결합해 설명 가능한 예측 기준을 만드는 것이다.

= 데이터 구성

분석 데이터는 2025년 3월부터 6월까지의 평일 운행 기록을 기준으로 한다. 개인정보를 보호하기 위해 개별 단말 식별자는 저장하지 않고, 정류장별 10분 단위 승하차 수만 사용한다. 학사 일정은 강의 시작 시각과 공휴일 여부로 단순화했다.

#figure(
  table(
    columns: (32mm, 1fr),
    table.header([변수], [설명]),
    [탑승 수], [정류장별 10분 단위 승차 이벤트 수],
    [수업 전환], [다음 20분 안에 시작하거나 끝나는 강의 수],
    [날씨], [강수 여부와 체감 온도 구간],
    [혼잡 라벨], [좌석 수 대비 예상 탑승 수가 80%를 넘는 구간],
  ),
  caption: [예측에 사용한 주요 변수],
)

= 분석 방법

기준선은 전주 같은 요일과 같은 시간대의 평균 탑승 수로 정의했다. 비교 모델은 수업 전환 변수와 날씨 변수를 추가한 회귀 모델이다. 모델 성능은 혼잡 구간 재현율과 비혼잡 구간 정밀도를 함께 확인했다. 단순 정확도만 사용하면 대부분의 비혼잡 구간을 맞히는 모델이 과대평가될 수 있기 때문이다.

시계열 예측에서는 최근 데이터만 사용할수록 새로운 패턴에 빠르게 반응하지만, 일시적인 행사나 우천의 영향을 과하게 반영할 수 있다. 따라서 본 논문은 최근 2주와 학기 전체 평균을 함께 사용하는 절충안을 선택했다.

= 결론

수업 전환 정보를 추가한 모델은 혼잡 구간을 기준선보다 더 많이 탐지했다. 특히 월요일 1교시와 목요일 오후 실험 수업 종료 시간대에서 개선 폭이 컸다. 반면 축제나 입학식처럼 학사 일정에 없는 행사는 예측하지 못했다.

향후 연구에서는 셔틀 위치 정보와 대기열 센서를 결합해 정류장별 실시간 혼잡도를 더 정확하게 추정할 수 있다. 본 연구의 의의는 복잡한 인프라 없이도 학내 이동 데이터를 의사결정에 활용할 수 있음을 보인 데 있다.
