#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis

#show: snu-thesis.with(
  body-language: "ko",
  cover-language: "ko",
  approval-language: "ko",
  degree: "master",
  academic-ko: "공학",
  academic-en: "Engineering",
  school-ko: "대학원",
  school-en: "Graduate School of Engineering",
  major-ko: "컴퓨터공학부 데이터사이언스 전공",
  major-en: "Computer Science and Engineering Major",
  title: [
    검색 증강 생성을 활용한
    #linebreak()
    한국어 학술 문서 작성 지원 연구
  ],
  title-alt: [
    Retrieval-Augmented Generation for
    #linebreak()
    Korean Academic Writing Assistance
  ],
  author: "김서울",
  author-display: "김 서 울",
  student-number: "2024-23157",
  advisor: "이관악",
  advisor-display: "이 관 악",
  grad-date-ko: "2026년 2월",
  grad-date-en: "February 2026",
  submission-date: "2025년 12월",
  approval-date: "2026년 1월",
  committee: (
    chair: "박위원장",
    vice-chair: "최부위원장",
    members: (),
  ),
  abstract-ko: [
    본 논문은 한국어 학술 문서 작성 과정에서 반복적으로 발생하는 용어 통일, 선행연구 확인, 문장 근거 제시 문제를 줄이기 위한 검색 증강 생성 기반 작성 지원 방법을 제안한다. 제안 시스템은 사용자가 작성 중인 문단을 질의로 변환하고, 연구실 내부 문헌 저장소에서 관련 단락을 검색한 뒤, 검색 결과를 근거로 문장 수정안과 인용 후보를 함께 제시한다.

    서울대학교 대학원생 18명이 작성한 초안과 수정본을 비교한 결과, 제안 방법은 근거 없는 일반화 표현을 줄이고 참고문헌 누락 사례를 감소시켰다. 또한 사용자 평가는 자동 완성보다 근거 표시와 수정 이유 설명이 학술 글쓰기 신뢰도에 더 큰 영향을 준다는 점을 보였다.
  ],
  abstract-en: [
    This thesis presents a retrieval-augmented writing assistant for Korean academic documents. The system converts an in-progress paragraph into a search query, retrieves relevant passages from a local literature collection, and returns revision suggestions with citation candidates.

    In a small user study with 18 graduate students, the proposed method reduced unsupported claims and missing citations in revised drafts. The results indicate that visible evidence and explanations for revisions contribute more to trust than fluent generation alone.
  ],
  keywords-ko: ("검색 증강 생성", "학술 글쓰기", "한국어 자연어 처리", "인용 추천"),
  keywords-en: ("retrieval-augmented generation", "academic writing", "Korean NLP", "citation recommendation"),
  acknowledgement: [
    연구 방향을 세심하게 지도해 주신 이관악 교수님께 감사드립니다. 실험 문서 작성과 사용자 평가에 참여해 준 연구실 동료들에게도 깊이 감사드립니다.
  ],
  bibliography: bibliography("references.bib", style: "apa", title: none),
  appendices: (
    (
      title: [사용자 평가 설문 문항],
      body: [
        본 부록은 사용자 평가 후 수집한 설문 문항의 일부를 정리한다.

        1. 제안된 수정안이 문단의 논지를 유지한다고 느꼈는가?
        2. 함께 제시된 근거 단락이 수정안을 검토하는 데 충분했는가?
        3. 기존 작성 방식과 비교했을 때 참고문헌 확인 시간이 줄었는가?
      ],
    ),
  ),
)

= 서론

한국어 학술 문서는 영문 논문과 다른 문장 호흡, 인용 관습, 용어 표기 일관성을 요구한다. 대학원생은 문헌을 충분히 읽었더라도 초안 작성 단계에서 근거가 약한 문장을 남기거나, 이미 검토한 논문을 다시 찾느라 시간을 소모한다. 대규모 언어 모델은 문장을 자연스럽게 생성하지만, 근거가 없는 인용이나 출처가 불명확한 설명을 만들 수 있다는 한계가 있다.

본 연구는 생성 모델을 단독으로 사용하지 않고, 검색된 문헌 단락을 생성 단계의 입력으로 고정하는 접근을 선택한다. 검색 증강 생성은 모델의 응답을 외부 지식에 연결할 수 있다는 장점이 있으며, 지식 집약적 작업에서 효과가 보고되었다 @lewis2020retrieval. 한국어 학술 문서에서는 검색 결과를 그대로 노출하는 인터페이스가 특히 중요하다. 사용자는 문장 유창성보다 인용 근거의 확인 가능성을 더 크게 평가하기 때문이다.

#figure(
  align(center)[
    #rect(width: 78%, height: 32mm, stroke: 0.6pt, inset: 8pt)[
      #align(center + horizon)[문단 입력 → 문헌 검색 → 근거 정렬 → 수정안 제시]
    ]
  ],
  caption: [검색 증강 작성 지원 흐름],
)

= 방법

제안 시스템은 세 단계로 구성된다. 첫째, 작성 중인 문단에서 핵심 명사구와 주장 문장을 추출한다. 둘째, 추출된 표현을 이용해 내부 문헌 저장소에서 관련 단락을 검색한다. 셋째, 검색 결과를 근거로 수정안을 생성하고 사용자가 확인할 수 있도록 근거 문장과 함께 표시한다. 문장 표현에는 Transformer 기반 언어 모델의 문맥 표현을 사용했다 @vaswani2017attention @devlin2019bert.

#figure(
  table(
    columns: (28mm, 1fr, 34mm),
    table.header([단계], [주요 처리], [사용자에게 보이는 결과]),
    [질의 생성], [문단에서 핵심 주장과 전문 용어를 추출한다.], [검색어 후보],
    [근거 검색], [논문 초록과 본문 단락을 벡터 검색으로 찾는다.], [근거 단락 목록],
    [수정 제안], [검색 결과에 포함된 표현만 사용해 수정안을 만든다.], [문장 수정안],
  ),
  caption: [시스템 처리 단계],
)

사용자 평가는 30분 작성 과제와 사후 설문으로 진행했다. 참가자는 동일한 주제의 문단 두 개를 작성했으며, 한 문단에는 기본 편집기만 사용하고 다른 문단에는 제안 시스템을 사용했다. 평가 지표는 근거 없는 주장 수, 누락된 인용 수, 문장 수정에 걸린 시간, 사용자가 보고한 신뢰도이다.

= 결과 및 논의

제안 시스템을 사용한 문단에서는 누락된 인용이 평균 2.1건에서 0.8건으로 감소했다. 근거 없는 일반화 표현도 감소했지만, 검색 저장소에 없는 최신 연구를 다루는 경우에는 시스템이 적절한 근거를 제시하지 못했다. 이는 검색 품질이 생성 품질의 상한을 결정한다는 점을 보여준다.

참가자 인터뷰에서는 “문장이 더 좋아졌다”는 반응보다 “왜 고쳐야 하는지 확인할 수 있었다”는 반응이 더 자주 나타났다. 따라서 학술 글쓰기 지원 도구는 자동 완성 속도보다 근거 추적성과 사용자의 최종 판단권을 우선해야 한다.
