#let make-prob-meta = (
  difficulty_prefix: "출제진 의도 — ",
  difficulty_postfix: "",
  author: "출제자",
  authors: "출제자",
  submitted_prefix: "제출 ",
  submitted_postfix: "회",
  passed_prefix: "정답 ",
  passed_postfix: "건",
  ac-ratio_prefix: "정답률: ",
  ac-ratio_postfix: "%",
  first-solver_prefix: "최초 해결: ",
  first-solver_postfix: "",
  online-open-contest: "온라인 오픈 콘테스트",
  offline-onsite-contest: "오프라인 온사이트 대회",
  first_solved_at_prefix: "+",
  first_solved_at_postfix: "분",
)
#let make-prob-overview = (
  problem: "문제",
  difficulty: "의도한 난이도",
  author: "출제자",
)

#let make-problem = (
  make-prob-meta: make-prob-meta
)

#let problem = make-problem
