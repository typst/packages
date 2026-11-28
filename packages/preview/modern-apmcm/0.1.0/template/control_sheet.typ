#import "@preview/modern-apmcm:0.1.0": apmcm-control-sheet

// Fill in your team information in English, compile to PDF, print, sign, and scan as <problem><team-number>cns.pdf
#show: apmcm-control-sheet.with(
  problem: "A",
  team-number: "263XXXXX",
  school: "XXX University",
  members: (
    "First Member",
    "Second Member",
    "Third Member",
  ),
  supervisor: "Supervisor",
  date: "November 28, 2026",
  year: 2026,
)
