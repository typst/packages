#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  body
}

#show: appendix

= First Appendix
