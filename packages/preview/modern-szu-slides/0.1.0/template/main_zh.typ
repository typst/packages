// SZU Typst Slides Template (Chinese Version / 中文版)
#import "@preview/modern-szu-slides:0.1.0": *

// 选择主题（默认 Metropolis 主题）：
// #let szu-theme = szu-uni-theme  // 如需切换为大学经典主题，取消注释此行

#import "section-cover_zh.typ": cover-section, thesis-title, thesis-subtitle, candidate-name, college-name
#import "section-outline_zh.typ": outline-section
#import "section-background_zh.typ": background-section
#import "section-work_zh.typ": work-section
#import "section-summary_zh.typ": summary-section
#import "section-thanks_zh.typ": thanks-section
#import "section-appendix_zh.typ": appendix-section

// ── 主题与定理环境 ───────────────────────────────────────────
#show: show-theorion

#show: szu-theme.with(
  lang: "zh",
  title: thesis-title,
  subtitle: thesis-subtitle,
  author: candidate-name,
  date: datetime.today(),
  institution: college-name,
)

#show: apply-slide-fonts

// ── 排版与标题格式 ───────────────────────────────────────────
#set heading(numbering: numbly("{1}.", default: "1.1"))
#set par(justify: false)
#show strong: set text(fill: black)

// ── 幻灯片页面 ───────────────────────────────────────────────
#cover-section
#outline-section
#background-section
#work-section
#summary-section
#thanks-section
#appendix-section
